-- FitCheck AI - Atomic administrative gift void and revoke
--
-- An admin action can race a recipient claim. Keep the voucher transition and
-- entitlement revocation in one database transaction so a claimed voucher
-- never becomes voided without its grant being revoked.

BEGIN;

CREATE OR REPLACE FUNCTION public.void_or_revoke_gift_voucher(
    p_voucher_id UUID,
    p_expected_status TEXT,
    p_reason TEXT,
    p_now TIMESTAMPTZ DEFAULT NOW()
)
RETURNS SETOF public.gift_vouchers AS $$
DECLARE
    v_voucher public.gift_vouchers;
BEGIN
    IF p_expected_status NOT IN ('issued', 'claimed') THEN
        RETURN;
    END IF;

    UPDATE public.gift_vouchers
    SET status = CASE
            WHEN p_expected_status = 'claimed' THEN 'revoked'
            ELSE 'voided'
        END,
        admin_note = p_reason,
        updated_at = p_now
    WHERE id = p_voucher_id
      AND source <> 'paid'
      AND status = p_expected_status
    RETURNING * INTO v_voucher;

    IF NOT FOUND THEN
        RETURN;
    END IF;

    IF p_expected_status = 'claimed' THEN
        UPDATE public.gift_entitlement_grants
        SET status = 'revoked',
            revoked_at = p_now,
            revoke_reason = p_reason,
            updated_at = p_now
        WHERE voucher_id = p_voucher_id
          AND status IN ('queued', 'active');
    END IF;

    RETURN NEXT v_voucher;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE ALL ON FUNCTION public.void_or_revoke_gift_voucher(UUID, TEXT, TEXT, TIMESTAMPTZ)
    FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.void_or_revoke_gift_voucher(UUID, TEXT, TEXT, TIMESTAMPTZ)
    TO service_role;

COMMIT;
