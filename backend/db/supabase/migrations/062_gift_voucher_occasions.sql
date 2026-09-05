-- FitCheck AI - optional gift voucher occasions
--
-- No occasion is intentionally represented by NULL. New and existing generic
-- vouchers therefore keep a blank greeting instead of a synthetic default.

BEGIN;

ALTER TABLE public.gift_vouchers
    ADD COLUMN IF NOT EXISTS occasion VARCHAR(20),
    ADD COLUMN IF NOT EXISTS occasion_greeting VARCHAR(80),
    DROP CONSTRAINT IF EXISTS gift_vouchers_occasion_valid,
    ADD CONSTRAINT gift_vouchers_occasion_valid
    CHECK (
        (occasion IS NULL AND occasion_greeting IS NULL)
        OR (occasion IN ('birthday', 'anniversary') AND occasion_greeting IS NULL)
        OR (
            occasion = 'other'
            AND occasion_greeting IS NOT NULL
            AND occasion_greeting = btrim(occasion_greeting)
            AND char_length(occasion_greeting) BETWEEN 1 AND 80
        )
    );

-- Migration 061 replaced the original free-issue RPC. Replace that signature
-- once more so complimentary issuance persists nullable occasion data too.
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

    IF NOT (
        (v_occasion IS NULL AND v_occasion_greeting IS NULL)
        OR (v_occasion IN ('birthday', 'anniversary') AND v_occasion_greeting IS NULL)
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

    IF NOT FOUND OR v_allowance.used_count >= v_allowance.granted_count THEN
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

COMMIT;
