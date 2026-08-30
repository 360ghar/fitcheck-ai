-- FitCheck AI - Pro gift vouchers
--
-- Gift value is stored outside subscriptions so Stripe, Apple, and Google
-- synchronization can never erase it. Browser roles cannot read the raw
-- tables because a recipient row contains sender, payment, and internal IDs.
-- All access is shaped by the backend service role.

BEGIN;

CREATE TABLE IF NOT EXISTS public.gift_vouchers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    purchaser_user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    source VARCHAR(20) NOT NULL CHECK (source IN ('paid', 'complimentary', 'admin')),
    duration_months SMALLINT NOT NULL CHECK (duration_months IN (1, 3, 12)),
    retail_value_cents INTEGER NOT NULL CHECK (retail_value_cents IN (2000, 6000, 20000)),
    currency VARCHAR(3) NOT NULL DEFAULT 'USD' CHECK (currency = 'USD'),
    from_name VARCHAR(80) NOT NULL CHECK (char_length(btrim(from_name)) BETWEEN 1 AND 80),
    to_name VARCHAR(80) NOT NULL CHECK (char_length(btrim(to_name)) BETWEEN 1 AND 80),
    message VARCHAR(240) CHECK (message IS NULL OR char_length(message) <= 240),
    status VARCHAR(24) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'issued', 'claimed', 'expired', 'voided', 'revoked', 'payment_failed', 'payment_review')),
    payment_status VARCHAR(24) NOT NULL DEFAULT 'not_applicable'
        CHECK (payment_status IN ('not_applicable', 'pending', 'paid', 'failed', 'review', 'partially_refunded', 'refunded', 'disputed')),
    client_request_id VARCHAR(100) NOT NULL,
    token_version INTEGER NOT NULL DEFAULT 1 CHECK (token_version > 0),
    artwork_version INTEGER NOT NULL DEFAULT 1 CHECK (artwork_version > 0),
    issued_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    claimed_by_user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    claimed_at TIMESTAMPTZ,
    stripe_checkout_session_id VARCHAR(255) UNIQUE,
    stripe_payment_intent_id VARCHAR(255) UNIQUE,
    stripe_customer_id VARCHAR(255),
    amount_paid_cents INTEGER CHECK (amount_paid_cents IS NULL OR amount_paid_cents >= 0),
    amount_refunded_cents INTEGER NOT NULL DEFAULT 0 CHECK (amount_refunded_cents >= 0),
    payment_completed_at TIMESTAMPTZ,
    payment_failure_reason TEXT,
    admin_note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK ((source = 'complimentary' AND expires_at IS NOT NULL) OR source <> 'complimentary'),
    CHECK ((status = 'claimed' AND claimed_at IS NOT NULL) OR status <> 'claimed'),
    CHECK (amount_paid_cents IS NULL OR amount_refunded_cents <= amount_paid_cents)
);

CREATE UNIQUE INDEX IF NOT EXISTS gift_vouchers_owner_request_unique
    ON public.gift_vouchers (purchaser_user_id, client_request_id)
    WHERE purchaser_user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS gift_vouchers_purchaser_created_idx
    ON public.gift_vouchers (purchaser_user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS gift_vouchers_claimant_created_idx
    ON public.gift_vouchers (claimed_by_user_id, claimed_at DESC);
CREATE INDEX IF NOT EXISTS gift_vouchers_status_created_idx
    ON public.gift_vouchers (status, created_at DESC);
CREATE INDEX IF NOT EXISTS gift_vouchers_expiry_idx
    ON public.gift_vouchers (expires_at)
    WHERE expires_at IS NOT NULL AND status = 'issued';

CREATE TABLE IF NOT EXISTS public.gift_voucher_allowances (
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    duration_months SMALLINT NOT NULL CHECK (duration_months IN (1, 3, 12)),
    granted_count INTEGER NOT NULL CHECK (granted_count >= 0),
    used_count INTEGER NOT NULL DEFAULT 0 CHECK (used_count >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, duration_months)
);

CREATE TABLE IF NOT EXISTS public.gift_entitlement_grants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    voucher_id UUID NOT NULL UNIQUE REFERENCES public.gift_vouchers(id) ON DELETE RESTRICT,
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    duration_months SMALLINT NOT NULL CHECK (duration_months IN (1, 3, 12)),
    status VARCHAR(20) NOT NULL DEFAULT 'queued'
        CHECK (status IN ('queued', 'active', 'consumed', 'revoked')),
    remaining_seconds BIGINT CHECK (remaining_seconds IS NULL OR remaining_seconds > 0),
    claimed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    started_at TIMESTAMPTZ,
    ends_at TIMESTAMPTZ,
    consumed_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    revoke_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS gift_entitlement_one_active_per_user
    ON public.gift_entitlement_grants (user_id)
    WHERE status = 'active' AND user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS gift_entitlement_queue_idx
    ON public.gift_entitlement_grants (user_id, status, claimed_at);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'gift_vouchers_updated_at') THEN
        CREATE TRIGGER gift_vouchers_updated_at
            BEFORE UPDATE ON public.gift_vouchers
            FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'gift_allowances_updated_at') THEN
        CREATE TRIGGER gift_allowances_updated_at
            BEFORE UPDATE ON public.gift_voucher_allowances
            FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'gift_entitlements_updated_at') THEN
        CREATE TRIGGER gift_entitlements_updated_at
            BEFORE UPDATE ON public.gift_entitlement_grants
            FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
    END IF;
END;
$$;

ALTER TABLE public.gift_vouchers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gift_voucher_allowances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gift_entitlement_grants ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS gift_vouchers_read_own ON public.gift_vouchers;
DROP POLICY IF EXISTS gift_allowances_read_own ON public.gift_voucher_allowances;
DROP POLICY IF EXISTS gift_entitlements_read_own ON public.gift_entitlement_grants;
REVOKE ALL ON TABLE public.gift_vouchers FROM PUBLIC, anon, authenticated;
REVOKE ALL ON TABLE public.gift_voucher_allowances FROM PUBLIC, anon, authenticated;
REVOKE ALL ON TABLE public.gift_entitlement_grants FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.initialize_gift_allowances(user_uuid UUID)
RETURNS SETOF public.gift_voucher_allowances AS $$
BEGIN
    INSERT INTO public.gift_voucher_allowances (user_id, duration_months, granted_count)
    VALUES (user_uuid, 1, 3), (user_uuid, 3, 1), (user_uuid, 12, 1)
    ON CONFLICT (user_id, duration_months) DO NOTHING;

    RETURN QUERY
    SELECT * FROM public.gift_voucher_allowances
    WHERE user_id = user_uuid
    ORDER BY duration_months;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.issue_complimentary_gift(
    p_voucher_id UUID,
    p_public_id UUID,
    p_user_id UUID,
    p_duration_months SMALLINT,
    p_retail_value_cents INTEGER,
    p_from_name VARCHAR,
    p_to_name VARCHAR,
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
        retail_value_cents, currency, from_name, to_name, message, status,
        payment_status, client_request_id, issued_at, expires_at
    ) VALUES (
        p_voucher_id, p_public_id, p_user_id, 'complimentary', p_duration_months,
        p_retail_value_cents, 'USD', btrim(p_from_name), btrim(p_to_name),
        NULLIF(btrim(p_message), ''), 'issued', 'not_applicable',
        p_client_request_id, NOW(), p_expires_at
    ) RETURNING * INTO v_created;

    RETURN NEXT v_created;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

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
        SELECT 1 FROM public.users
        WHERE id = p_user_id AND email_verified = TRUE AND is_active IS DISTINCT FROM FALSE
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

CREATE OR REPLACE FUNCTION public.resolve_gift_entitlements(
    p_user_id UUID,
    p_base_pro_active BOOLEAN,
    p_now TIMESTAMPTZ DEFAULT NOW()
)
RETURNS TABLE (
    active_grant_id UUID,
    active_ends_at TIMESTAMPTZ,
    queued_count INTEGER,
    queued_months INTEGER
) AS $$
DECLARE
    v_active public.gift_entitlement_grants;
    v_next public.gift_entitlement_grants;
BEGIN
    PERFORM pg_advisory_xact_lock(hashtextextended(p_user_id::TEXT, 0));

    UPDATE public.gift_entitlement_grants
    SET status = 'consumed', consumed_at = p_now
    WHERE user_id = p_user_id AND status = 'active' AND ends_at <= p_now;

    SELECT * INTO v_active
    FROM public.gift_entitlement_grants
    WHERE user_id = p_user_id AND status = 'active'
    LIMIT 1
    FOR UPDATE;

    IF p_base_pro_active AND FOUND THEN
        UPDATE public.gift_entitlement_grants
        SET status = 'queued',
            remaining_seconds = GREATEST(1, CEIL(EXTRACT(EPOCH FROM (ends_at - p_now)))::BIGINT),
            started_at = NULL,
            ends_at = NULL
        WHERE id = v_active.id;
        v_active := NULL;
    ELSIF NOT p_base_pro_active AND NOT FOUND THEN
        SELECT * INTO v_next
        FROM public.gift_entitlement_grants
        WHERE user_id = p_user_id AND status = 'queued'
        ORDER BY claimed_at, id
        LIMIT 1
        FOR UPDATE;

        IF FOUND THEN
            UPDATE public.gift_entitlement_grants
            SET status = 'active',
                started_at = p_now,
                ends_at = CASE
                    WHEN v_next.remaining_seconds IS NOT NULL
                        THEN p_now + make_interval(secs => v_next.remaining_seconds::DOUBLE PRECISION)
                    ELSE p_now + make_interval(months => v_next.duration_months)
                END,
                remaining_seconds = NULL
            WHERE id = v_next.id
            RETURNING * INTO v_active;
        END IF;
    END IF;

    RETURN QUERY
    SELECT
        a.id,
        a.ends_at,
        COUNT(q.id)::INTEGER,
        COALESCE(SUM(q.duration_months), 0)::INTEGER
    FROM (SELECT 1) seed
    LEFT JOIN public.gift_entitlement_grants a
        ON a.user_id = p_user_id AND a.status = 'active'
    LEFT JOIN public.gift_entitlement_grants q
        ON q.user_id = p_user_id AND q.status = 'queued'
    GROUP BY a.id, a.ends_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE ALL ON FUNCTION public.initialize_gift_allowances(UUID) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.issue_complimentary_gift(UUID, UUID, UUID, SMALLINT, INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TIMESTAMPTZ) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.claim_gift_voucher(UUID, UUID, TIMESTAMPTZ) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.resolve_gift_entitlements(UUID, BOOLEAN, TIMESTAMPTZ) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.initialize_gift_allowances(UUID) TO service_role;
GRANT EXECUTE ON FUNCTION public.issue_complimentary_gift(UUID, UUID, UUID, SMALLINT, INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TIMESTAMPTZ) TO service_role;
GRANT EXECUTE ON FUNCTION public.claim_gift_voucher(UUID, UUID, TIMESTAMPTZ) TO service_role;
GRANT EXECUTE ON FUNCTION public.resolve_gift_entitlements(UUID, BOOLEAN, TIMESTAMPTZ) TO service_role;

GRANT SELECT, INSERT, UPDATE ON public.gift_vouchers TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.gift_voucher_allowances TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.gift_entitlement_grants TO service_role;

COMMIT;
