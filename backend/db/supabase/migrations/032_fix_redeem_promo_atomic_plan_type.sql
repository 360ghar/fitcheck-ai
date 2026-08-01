-- FitCheck AI - Fix redeem_promo_atomic return-type mismatch (42804)
--
-- Production 2026-08-01: every POST /api/v1/promo/redeem returned 500 with
--   'structure of query does not match function result type', code 42804,
--   details: 'Returned type character varying(20) does not match expected
--   type text in column 3.'
--
-- The function declares RETURNS TABLE (... plan_type TEXT ...) but the two
-- runtime RETURN QUERY branches selected redemption_row.plan_type /
-- promo_row.plan_type, both character varying(20) (columns declared in the
-- 031 tables). Postgres is strict: a TABLE-returning function's RETURN QUERY
-- column types must match the declared signature exactly, and varchar(20) is
-- NOT text - so the function was created successfully and failed at the first
-- successful redemption path.
--
-- Fix: explicit ::TEXT casts on both branches. Also applied in-place to
-- 031_promo_codes.sql so fresh installs create the corrected function.
-- Safe to run repeatedly (CREATE OR REPLACE + idempotent REVOKE/GRANT).

BEGIN;

CREATE OR REPLACE FUNCTION public.redeem_promo_atomic(
    p_user_id UUID,
    p_code TEXT
)
RETURNS TABLE (
    success BOOLEAN,
    already_redeemed BOOLEAN,
    plan_type TEXT,
    months INTEGER,
    message TEXT
) AS $$
DECLARE
    promo_row public.promo_codes%ROWTYPE;
    redemption_row public.promo_redemptions%ROWTYPE;
    sub_row public.subscriptions%ROWTYPE;
    new_trial_end TIMESTAMPTZ;
BEGIN
    SELECT * INTO promo_row
    FROM public.promo_codes
    WHERE LOWER(TRIM(code)) = LOWER(TRIM(p_code))
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, FALSE, NULL::TEXT, 0, 'Promo code not found'::TEXT;
        RETURN;
    END IF;

    IF NOT promo_row.active THEN
        RETURN QUERY SELECT FALSE, FALSE, NULL::TEXT, 0, 'This promo code is no longer active'::TEXT;
        RETURN;
    END IF;

    IF promo_row.expires_at IS NOT NULL AND promo_row.expires_at <= NOW() THEN
        RETURN QUERY SELECT FALSE, FALSE, NULL::TEXT, 0, 'This promo code has expired'::TEXT;
        RETURN;
    END IF;

    IF promo_row.max_uses IS NOT NULL AND promo_row.used_count >= promo_row.max_uses THEN
        RETURN QUERY SELECT FALSE, FALSE, NULL::TEXT, 0, 'This promo code has reached its usage limit'::TEXT;
        RETURN;
    END IF;

    SELECT * INTO redemption_row
    FROM public.promo_redemptions
    WHERE user_id = p_user_id
    FOR UPDATE;

    IF FOUND THEN
        RETURN QUERY SELECT
            FALSE,
            TRUE,
            redemption_row.plan_type::TEXT,
            redemption_row.months,
            'You have already redeemed a promo code'::TEXT;
        RETURN;
    END IF;

    -- Never overwrite a paying subscriber (same rule as grant_free_pro_month.py
    -- and the referral grant). "Paying" is judged on the EFFECTIVE plan exactly
    -- like SubscriptionService.effective_plan_type: an expired trial
    -- (stored plan_type pro_monthly, trial_end in the past) is effectively
    -- free, so its holder can still redeem a promo.
    SELECT * INTO sub_row
    FROM public.subscriptions
    WHERE user_id = p_user_id
    FOR UPDATE;

    IF FOUND
       AND sub_row.plan_type <> 'free'
       AND (
           (sub_row.status = 'trial' AND sub_row.trial_end IS NOT NULL AND sub_row.trial_end > NOW())
           OR (sub_row.status = 'active' AND sub_row.current_period_end IS NOT NULL AND sub_row.current_period_end > NOW())
       ) THEN
        RETURN QUERY SELECT
            FALSE,
            FALSE,
            NULL::TEXT,
            0,
            'You already have an active plan'::TEXT;
        RETURN;
    END IF;

    -- Extend from any existing trial instead of restarting it, so stacking a
    -- promo on top of a running referral trial does not shrink it.
    new_trial_end := GREATEST(
        COALESCE(sub_row.trial_end, NOW()),
        NOW()
    ) + make_interval(months => promo_row.months);

    INSERT INTO public.subscriptions (
        user_id,
        plan_type,
        status,
        current_period_start,
        current_period_end,
        cancel_at_period_end,
        trial_end,
        referral_credit_months
    ) VALUES (
        p_user_id,
        promo_row.plan_type,
        'trial',
        NOW(),
        new_trial_end,
        FALSE,
        new_trial_end,
        0
    )
    ON CONFLICT (user_id) DO UPDATE SET
        plan_type = EXCLUDED.plan_type,
        status = EXCLUDED.status,
        current_period_start = EXCLUDED.current_period_start,
        current_period_end = EXCLUDED.current_period_end,
        cancel_at_period_end = FALSE,
        trial_end = EXCLUDED.trial_end,
        updated_at = NOW();

    INSERT INTO public.promo_redemptions (
        user_id,
        promo_code_id,
        plan_type,
        months
    ) VALUES (
        p_user_id,
        promo_row.id,
        promo_row.plan_type,
        promo_row.months
    );

    UPDATE public.promo_codes
    SET used_count = used_count + 1,
        updated_at = NOW()
    WHERE id = promo_row.id;

    RETURN QUERY SELECT
        TRUE,
        FALSE,
        promo_row.plan_type::TEXT,
        promo_row.months,
        'Promo code applied'::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Harden RPC privileges (same policy as 031: the backend calls this with the
-- service-role client, so browser roles must not be able to invoke it).
REVOKE EXECUTE ON FUNCTION public.redeem_promo_atomic(UUID, TEXT)
    FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.redeem_promo_atomic(UUID, TEXT) TO service_role;

COMMIT;
