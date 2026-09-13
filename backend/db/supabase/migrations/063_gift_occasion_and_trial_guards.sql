-- FitCheck AI - gift occasion + admin trial-extension guards
--
-- Three hardening fixes shipped together after review:
--   1. The 062 occasion CHECK (and RPC guard) accepted NULL occasion with a
--      non-NULL greeting: SQL's three-valued logic made every branch UNKNOWN
--      instead of FALSE. Constrain explicitly.
--   2. Migration 062 replaced the complimentary-issue RPC and silently
--      dropped 061's post-lock replay recheck. Concurrent requests sharing a
--      client_request_id could each consume an allowance again. Restore it.
--   3. admin_extend_user_trial extended ANY subscription row. Trials only
--      exist on paid plans — guard the RPC so free/active rows are no-ops.

BEGIN;

ALTER TABLE public.gift_vouchers
    DROP CONSTRAINT IF EXISTS gift_vouchers_occasion_valid,
    ADD CONSTRAINT gift_vouchers_occasion_valid
    CHECK (
        (occasion IS NULL AND occasion_greeting IS NULL)
        OR (
            occasion IS NOT NULL
            AND occasion IN ('birthday', 'anniversary')
            AND occasion_greeting IS NULL
        )
        OR (
            occasion IS NOT NULL
            AND occasion = 'other'
            AND occasion_greeting IS NOT NULL
            AND occasion_greeting = btrim(occasion_greeting)
            AND char_length(occasion_greeting) BETWEEN 1 AND 80
        )
    );

-- Same function as migration 062 (12-argument signature) with the explicit
-- NULL-occasion guard and 061's post-lock replay recheck restored.
DROP FUNCTION IF EXISTS public.issue_complimentary_gift_for_recipient(
    UUID, UUID, UUID, SMALLINT, INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, TIMESTAMPTZ
);

CREATE OR REPLACE FUNCTION public.issue_complimentary_gift_for_recipient(
    p_voucher_id UUID,
    p_public_id UUID,
    p_user_id UUID,
    p_duration_months SMALLINT,
    p_retail_value_cents INTEGER,
    p_from_name VARCHAR,
    p_to_name VARCHAR,
    p_recipient_email VARCHAR,
    p_message VARCHAR,
    p_occasion VARCHAR,
    p_occasion_greeting VARCHAR,
    p_client_request_id VARCHAR,
    p_expires_at TIMESTAMPTZ
)
RETURNS SETOF public.gift_vouchers AS $$
DECLARE
    v_existing public.gift_vouchers;
    v_allowance public.gift_voucher_allowances;
    v_created public.gift_vouchers;
    v_occasion VARCHAR := NULLIF(btrim(p_occasion), '');
    v_occasion_greeting VARCHAR := NULLIF(btrim(p_occasion_greeting), '');
BEGIN
    IF p_recipient_email IS NULL
       OR p_recipient_email <> lower(btrim(p_recipient_email))
       OR char_length(p_recipient_email) NOT BETWEEN 3 AND 320 THEN
        RAISE EXCEPTION 'A normalized recipient email is required';
    END IF;

    -- Explicit NULL-occasion check: with occasion NULL and a greeting
    -- present, every branch of the NOT(...) block below evaluates UNKNOWN,
    -- NOT FALSE, and the exception never fires. Fail loudly instead.
    IF v_occasion IS NULL AND v_occasion_greeting IS NOT NULL THEN
        RAISE EXCEPTION 'Gift occasion data is invalid';
    END IF;

    IF NOT (
        (v_occasion IS NULL AND v_occasion_greeting IS NULL)
        OR (
            v_occasion IS NOT NULL
            AND v_occasion IN ('birthday', 'anniversary')
            AND v_occasion_greeting IS NULL
        )
        OR (
            v_occasion = 'other'
            AND v_occasion_greeting IS NOT NULL
            AND char_length(v_occasion_greeting) BETWEEN 1 AND 80
        )
    ) THEN
        RAISE EXCEPTION 'Gift occasion data is invalid';
    END IF;

    SELECT * INTO v_existing
    FROM public.gift_vouchers
    WHERE purchaser_user_id = p_user_id AND client_request_id = p_client_request_id;
    IF FOUND THEN
        RETURN NEXT v_existing;
        RETURN;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM public.users
        WHERE id = p_user_id AND email_verified = TRUE AND is_active IS DISTINCT FROM FALSE
    ) THEN
        RETURN;
    END IF;

    PERFORM public.initialize_gift_allowances(p_user_id);
    SELECT * INTO v_allowance
    FROM public.gift_voucher_allowances
    WHERE user_id = p_user_id AND duration_months = p_duration_months
    FOR UPDATE;

    -- Concurrent requests with the same client_request_id can both pass the
    -- lookup above. Serializing on the allowance row and rechecking the key
    -- guarantees the loser replays the winner's voucher instead of consuming
    -- a second allowance (or colliding with the unique request-key index).
    -- Restored from migration 061, which 062's re-emit dropped.
    SELECT * INTO v_existing
    FROM public.gift_vouchers
    WHERE purchaser_user_id = p_user_id AND client_request_id = p_client_request_id;
    IF FOUND THEN
        RETURN NEXT v_existing;
        RETURN;
    END IF;

    -- FOUND belongs to the voucher recheck above (FALSE on the normal
    -- new-issue path), never to the allowance lock: gate on the allowance
    -- row itself. A NULL row means this duration was never initialized, so
    -- there is no allowance to spend.
    IF v_allowance IS NULL OR v_allowance.used_count >= v_allowance.granted_count THEN
        RETURN;
    END IF;

    UPDATE public.gift_voucher_allowances
    SET used_count = used_count + 1
    WHERE user_id = p_user_id AND duration_months = p_duration_months;

    INSERT INTO public.gift_vouchers (
        id, public_id, purchaser_user_id, source, duration_months,
        retail_value_cents, currency, from_name, to_name, recipient_email,
        message, occasion, occasion_greeting, status, payment_status,
        client_request_id, issued_at, expires_at
    ) VALUES (
        p_voucher_id, p_public_id, p_user_id, 'complimentary', p_duration_months,
        p_retail_value_cents, 'USD', btrim(p_from_name), btrim(p_to_name),
        lower(btrim(p_recipient_email)), NULLIF(btrim(p_message), ''), v_occasion,
        v_occasion_greeting, 'issued', 'not_applicable', p_client_request_id,
        NOW(), p_expires_at
    ) RETURNING * INTO v_created;

    RETURN NEXT v_created;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE ALL ON FUNCTION public.issue_complimentary_gift_for_recipient(
    UUID, UUID, UUID, SMALLINT, INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR, VARCHAR, TIMESTAMPTZ
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.issue_complimentary_gift_for_recipient(
    UUID, UUID, UUID, SMALLINT, INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR, VARCHAR, TIMESTAMPTZ
) TO service_role;

-- Same function as migration 060 with a paid-trial guard: trials only
-- exist on paid plans, so extending a free or already-active subscription
-- is a no-op rather than a surprise downgrade-free extension.
CREATE OR REPLACE FUNCTION public.admin_extend_user_trial(
    p_user_id UUID,
    p_days INTEGER
)
RETURNS TABLE (
    subscription JSONB,
    before_trial_end TIMESTAMPTZ,
    after_trial_end TIMESTAMPTZ
) AS $$
DECLARE
    v_subscription public.subscriptions%ROWTYPE;
BEGIN
    IF p_days < 1 OR p_days > 90 THEN
        RAISE EXCEPTION 'Trial extension must be between 1 and 90 days';
    END IF;

    SELECT * INTO v_subscription
    FROM public.subscriptions
    WHERE user_id = p_user_id
    FOR UPDATE;

    -- Plan values mirror the promo-codes CHECK (migration 031): the paid
    -- variants are plus_monthly/plus_yearly/pro_monthly/pro_yearly.
    IF NOT FOUND
       OR v_subscription.status <> 'trial'
       OR v_subscription.plan_type NOT IN ('plus_monthly', 'plus_yearly', 'pro_monthly', 'pro_yearly') THEN
        RETURN;
    END IF;

    before_trial_end := v_subscription.trial_end;
    after_trial_end := GREATEST(COALESCE(before_trial_end, NOW()), NOW())
        + make_interval(days => p_days);

    UPDATE public.subscriptions
    SET trial_end = after_trial_end,
        updated_at = NOW()
    WHERE user_id = p_user_id
    RETURNING * INTO v_subscription;

    subscription := to_jsonb(v_subscription);
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE ALL ON FUNCTION public.admin_extend_user_trial(UUID, INTEGER)
    FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.admin_extend_user_trial(UUID, INTEGER)
    TO service_role;

COMMIT;
