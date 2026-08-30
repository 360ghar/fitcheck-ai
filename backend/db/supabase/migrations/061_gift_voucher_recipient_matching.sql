-- FitCheck AI - named gift voucher recipients
--
-- New vouchers bind to a normalized recipient address. Existing vouchers keep
-- a NULL address and retain their private-link claim behavior.

BEGIN;

ALTER TABLE public.gift_vouchers
    ADD COLUMN IF NOT EXISTS recipient_email VARCHAR(320),
    DROP CONSTRAINT IF EXISTS gift_vouchers_recipient_email_normalized,
    ADD CONSTRAINT gift_vouchers_recipient_email_normalized
    CHECK (
        recipient_email IS NULL
        OR (
            recipient_email = lower(btrim(recipient_email))
            AND char_length(recipient_email) BETWEEN 3 AND 320
        )
    );

CREATE INDEX IF NOT EXISTS gift_vouchers_incoming_recipient_idx
    ON public.gift_vouchers (recipient_email, created_at DESC)
    WHERE recipient_email IS NOT NULL AND status = 'issued';

-- Existing link-only rows remain valid. All inserts after this migration must
-- be named, including any future service-role caller that bypasses the API.
CREATE OR REPLACE FUNCTION public.require_gift_voucher_recipient_email()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.recipient_email IS NULL THEN
        RAISE EXCEPTION 'A recipient email is required for new gift vouchers';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

DROP TRIGGER IF EXISTS gift_vouchers_require_recipient_email ON public.gift_vouchers;
CREATE TRIGGER gift_vouchers_require_recipient_email
    BEFORE INSERT ON public.gift_vouchers
    FOR EACH ROW EXECUTE FUNCTION public.require_gift_voucher_recipient_email();

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
    p_client_request_id VARCHAR,
    p_expires_at TIMESTAMPTZ
)
RETURNS SETOF public.gift_vouchers AS $$
DECLARE
    v_existing public.gift_vouchers;
    v_allowance public.gift_voucher_allowances;
    v_created public.gift_vouchers;
BEGIN
    IF p_recipient_email IS NULL
       OR p_recipient_email <> lower(btrim(p_recipient_email))
       OR char_length(p_recipient_email) NOT BETWEEN 3 AND 320 THEN
        RAISE EXCEPTION 'A normalized recipient email is required';
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
        message, status, payment_status, client_request_id, issued_at, expires_at
    ) VALUES (
        p_voucher_id, p_public_id, p_user_id, 'complimentary', p_duration_months,
        p_retail_value_cents, 'USD', btrim(p_from_name), btrim(p_to_name),
        lower(btrim(p_recipient_email)), NULLIF(btrim(p_message), ''), 'issued',
        'not_applicable', p_client_request_id, NOW(), p_expires_at
    ) RETURNING * INTO v_created;

    RETURN NEXT v_created;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Preserve the legacy private-link flow for vouchers with a NULL recipient
-- while atomically enforcing named-recipient matching for all new vouchers.
CREATE OR REPLACE FUNCTION public.claim_gift_voucher(
    p_voucher_id UUID,
    p_user_id UUID,
    p_now TIMESTAMPTZ DEFAULT NOW()
)
RETURNS SETOF public.gift_vouchers AS $$
DECLARE
    v_voucher public.gift_vouchers;
BEGIN
    SELECT * INTO v_voucher
    FROM public.gift_vouchers
    WHERE id = p_voucher_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN;
    END IF;
    IF v_voucher.status <> 'issued' THEN
        RETURN;
    END IF;
    IF v_voucher.purchaser_user_id = p_user_id THEN
        RETURN;
    END IF;
    IF v_voucher.expires_at IS NOT NULL AND v_voucher.expires_at <= p_now THEN
        UPDATE public.gift_vouchers SET status = 'expired' WHERE id = p_voucher_id;
        RETURN;
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM public.users
        WHERE id = p_user_id
          AND email_verified = TRUE
          AND is_active IS DISTINCT FROM FALSE
          AND (
              v_voucher.recipient_email IS NULL
              OR lower(btrim(email)) = v_voucher.recipient_email
          )
    ) THEN
        RETURN;
    END IF;

    INSERT INTO public.gift_entitlement_grants (
        voucher_id, user_id, duration_months, status, claimed_at
    ) VALUES (
        v_voucher.id, p_user_id, v_voucher.duration_months, 'queued', p_now
    );

    UPDATE public.gift_vouchers
    SET status = 'claimed', claimed_by_user_id = p_user_id, claimed_at = p_now
    WHERE id = p_voucher_id
    RETURNING * INTO v_voucher;

    RETURN NEXT v_voucher;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE ALL ON FUNCTION public.issue_complimentary_gift_for_recipient(UUID, UUID, UUID, SMALLINT, INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TIMESTAMPTZ) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.claim_gift_voucher(UUID, UUID, TIMESTAMPTZ) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.issue_complimentary_gift_for_recipient(UUID, UUID, UUID, SMALLINT, INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TIMESTAMPTZ) TO service_role;
GRANT EXECUTE ON FUNCTION public.claim_gift_voucher(UUID, UUID, TIMESTAMPTZ) TO service_role;

COMMIT;
