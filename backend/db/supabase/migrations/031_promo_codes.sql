-- FitCheck AI - Promo Codes
-- Adds shareable promo codes that grant Plus/Pro plans for free.
--
-- A promo code carries the exact plan variant it grants (e.g. 'pro_monthly',
-- 'plus_yearly') plus a free-access duration in months. Redemption writes the
-- standard `subscriptions` row (plan_type + status='trial' + trial_end), so
-- entitlement flows through the existing SubscriptionService.effective_plan_type
-- with zero new entitlement code: when the trial expires the user is
-- automatically downgraded to free.
--
-- Target: Supabase Postgres

BEGIN;

-- =============================================================================
-- TABLE: promo_codes
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.promo_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL,

    -- Plan variant granted on redemption ('plus_monthly', 'pro_yearly', ...)
    plan_type VARCHAR(20) NOT NULL,
    -- Free-access duration granted (1 = one month of the plan)
    months INTEGER NOT NULL DEFAULT 1 CHECK (months >= 1),

    -- Campaign controls: NULL max_uses = unlimited; expires_at NULL = never
    max_uses INTEGER CHECK (max_uses IS NULL OR max_uses > 0),
    used_count INTEGER NOT NULL DEFAULT 0,
    expires_at TIMESTAMPTZ,
    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT promo_codes_plan_type_check CHECK (
        plan_type IN ('plus_monthly', 'plus_yearly', 'pro_monthly', 'pro_yearly')
    ),
    CONSTRAINT promo_codes_code_format CHECK (
        code ~ '^[a-zA-Z0-9][a-zA-Z0-9_-]{2,49}$'
    )
);

-- Unique on the normalized (lowercased, trimmed) code so "Launch30" and
-- "launch30" cannot both exist. Lookups use LOWER(TRIM(code)).
CREATE UNIQUE INDEX IF NOT EXISTS idx_promo_codes_code_lower
    ON public.promo_codes (LOWER(TRIM(code)));

CREATE INDEX IF NOT EXISTS idx_promo_codes_active ON public.promo_codes(active);

-- =============================================================================
-- TABLE: promo_redemptions
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.promo_redemptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    promo_code_id UUID NOT NULL REFERENCES public.promo_codes(id) ON DELETE CASCADE,

    -- Snapshot of what was granted (survives later promo-code edits)
    plan_type VARCHAR(20) NOT NULL,
    months INTEGER NOT NULL DEFAULT 1,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- One promo redemption per user: a user can never stack promos or reuse a
    -- code after their grant expires.
    CONSTRAINT promo_redemptions_user_unique UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_promo_redemptions_user_id ON public.promo_redemptions(user_id);
CREATE INDEX IF NOT EXISTS idx_promo_redemptions_promo_code_id ON public.promo_redemptions(promo_code_id);

-- =============================================================================
-- RPC: redeem_promo_atomic
-- =============================================================================

-- Validates and applies a promo code in one transaction (same shape as
-- redeem_referral_atomic in 022). Locks the promo row so concurrent
-- redemptions cannot overshoot max_uses, and locks the user's existing
-- redemption row so a retry collapses onto a no-op instead of double-granting.
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

-- =============================================================================
-- RLS Policies for promo_codes
-- =============================================================================

ALTER TABLE public.promo_codes ENABLE ROW LEVEL SECURITY;

-- Anyone can read promo codes: the public validate endpoint needs the code's
-- state (active / expiry / plan) before a user signs up. Codes themselves are
-- not secrets - they are campaign links meant to be shared.
DROP POLICY IF EXISTS "Anyone can validate promo codes" ON public.promo_codes;
CREATE POLICY "Anyone can validate promo codes"
    ON public.promo_codes FOR SELECT
    USING (TRUE);

DROP POLICY IF EXISTS "Service role can manage promo codes" ON public.promo_codes;
CREATE POLICY "Service role can manage promo codes"
    ON public.promo_codes FOR ALL
    USING (TRUE)
    WITH CHECK (TRUE);

-- =============================================================================
-- RLS Policies for promo_redemptions
-- =============================================================================

ALTER TABLE public.promo_redemptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own promo redemptions" ON public.promo_redemptions;
CREATE POLICY "Users can view own promo redemptions"
    ON public.promo_redemptions FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Service role can manage promo redemptions" ON public.promo_redemptions;
CREATE POLICY "Service role can manage promo redemptions"
    ON public.promo_redemptions FOR ALL
    USING (TRUE)
    WITH CHECK (TRUE);

-- =============================================================================
-- Harden RPC privileges (same policy as 026: the backend calls this with the
-- service-role client, so browser roles must not be able to invoke it).
-- =============================================================================

REVOKE EXECUTE ON FUNCTION public.redeem_promo_atomic(UUID, TEXT)
    FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.redeem_promo_atomic(UUID, TEXT) TO service_role;

COMMIT;

