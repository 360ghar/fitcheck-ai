-- FitCheck AI - Subscriptions and Referrals
-- This migration adds subscription management and referral system tables.
--
-- Target: Supabase Postgres

BEGIN;

-- =============================================================================
-- TABLE: subscriptions
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

    -- Subscription tier and billing
    plan_type VARCHAR(20) NOT NULL DEFAULT 'free',  -- 'free', 'pro_monthly', 'pro_yearly'
    status VARCHAR(20) NOT NULL DEFAULT 'active',   -- 'active', 'cancelled', 'past_due', 'trial'

    -- Billing dates
    current_period_start TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    current_period_end TIMESTAMPTZ,  -- NULL for free tier
    cancel_at_period_end BOOLEAN DEFAULT FALSE,

    -- Payment provider integration
    stripe_customer_id VARCHAR(255),
    stripe_subscription_id VARCHAR(255),

    -- Trial/referral credits
    trial_end TIMESTAMPTZ,
    referral_credit_months INTEGER DEFAULT 0,  -- Months earned from referrals

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id)
);

-- Indexes for subscriptions
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_stripe_customer_id ON public.subscriptions(stripe_customer_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_stripe_subscription_id ON public.subscriptions(stripe_subscription_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON public.subscriptions(status);

-- =============================================================================
-- TABLE: subscription_usage
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.subscription_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

    -- Billing period (first day of the period)
    period_start DATE NOT NULL,

    -- Monthly usage counters
    monthly_extractions INTEGER DEFAULT 0,
    monthly_generations INTEGER DEFAULT 0,
    monthly_embeddings INTEGER DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, period_start)
);

-- Indexes for subscription_usage
CREATE INDEX IF NOT EXISTS idx_subscription_usage_user_id ON public.subscription_usage(user_id);
CREATE INDEX IF NOT EXISTS idx_subscription_usage_period ON public.subscription_usage(user_id, period_start);

-- =============================================================================
-- TABLE: referral_codes
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.referral_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

    -- Referral code (e.g., "sakshammittal-abc123")
    code VARCHAR(50) NOT NULL,

    -- Statistics
    times_used INTEGER DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id),
    UNIQUE(code)
);

-- Case-insensitive index for referral code lookup
CREATE INDEX IF NOT EXISTS idx_referral_codes_code_lower ON public.referral_codes(LOWER(code));

-- =============================================================================
-- TABLE: referral_redemptions
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.referral_redemptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Who referred whom
    referrer_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    referred_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    referral_code_id UUID NOT NULL REFERENCES public.referral_codes(id) ON DELETE CASCADE,

    -- Credit status
    referrer_credit_applied BOOLEAN DEFAULT FALSE,
    referred_credit_applied BOOLEAN DEFAULT FALSE,

    -- Timestamps
    redeemed_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(referred_user_id)  -- Each user can only be referred once
);

-- Indexes for referral_redemptions
CREATE INDEX IF NOT EXISTS idx_referral_redemptions_referrer ON public.referral_redemptions(referrer_user_id);
CREATE INDEX IF NOT EXISTS idx_referral_redemptions_referred ON public.referral_redemptions(referred_user_id);

-- =============================================================================
-- ALTER TABLE: users - Add referral columns
-- =============================================================================

ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS referred_by_code VARCHAR(50);

-- =============================================================================
-- FUNCTION: Generate referral code from user name
-- =============================================================================

CREATE OR REPLACE FUNCTION public.generate_referral_code(p_user_id UUID, p_full_name TEXT)
RETURNS TEXT AS $$
DECLARE
    base_slug TEXT;
    short_id TEXT;
    final_code TEXT;
BEGIN
    -- Generate base slug from name (lowercase, alphanumeric only)
    base_slug := LOWER(REGEXP_REPLACE(COALESCE(p_full_name, 'user'), '[^a-z0-9]', '', 'g'));

    -- Ensure minimum length
    IF LENGTH(base_slug) < 3 THEN
        base_slug := 'user';
    END IF;

    -- Truncate to max 20 chars
    base_slug := LEFT(base_slug, 20);

    -- Generate short unique ID (6 chars from UUID, avoiding hyphens)
    short_id := LOWER(LEFT(REPLACE(p_user_id::TEXT, '-', ''), 6));

    -- Combine into final code
    final_code := base_slug || '-' || short_id;

    RETURN final_code;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- FUNCTION: Atomic usage increment
-- =============================================================================

CREATE OR REPLACE FUNCTION public.increment_usage(
    p_user_id UUID,
    p_period_start DATE,
    p_field TEXT,
    p_count INTEGER DEFAULT 1
)
RETURNS VOID AS $$
BEGIN
    -- Validate field name to prevent SQL injection
    IF p_field NOT IN ('monthly_extractions', 'monthly_generations', 'monthly_embeddings') THEN
        RAISE EXCEPTION 'Invalid field name: %', p_field;
    END IF;

    -- Atomic increment using dynamic SQL
    EXECUTE format(
        'UPDATE public.subscription_usage SET %I = COALESCE(%I, 0) + $1, updated_at = NOW() WHERE user_id = $2 AND period_start = $3',
        p_field, p_field
    ) USING p_count, p_user_id, p_period_start;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: Atomic referral code times_used increment
-- =============================================================================

CREATE OR REPLACE FUNCTION public.increment_referral_times_used(
    p_referral_code_id UUID,
    p_count INTEGER DEFAULT 1
)
RETURNS VOID AS $$
BEGIN
    UPDATE public.referral_codes
    SET times_used = COALESCE(times_used, 0) + p_count
    WHERE id = p_referral_code_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: Get current billing period start
-- =============================================================================

CREATE OR REPLACE FUNCTION public.get_billing_period_start(p_user_id UUID)
RETURNS DATE AS $$
DECLARE
    period_start_date DATE;
    subscription_start TIMESTAMPTZ;
BEGIN
    -- Get the subscription start date
    SELECT current_period_start INTO subscription_start
    FROM public.subscriptions
    WHERE user_id = p_user_id;

    -- If no subscription, use first of current month
    IF subscription_start IS NULL THEN
        RETURN DATE_TRUNC('month', CURRENT_DATE)::DATE;
    END IF;

    -- For free tier or first period, use first of current month
    RETURN DATE_TRUNC('month', CURRENT_DATE)::DATE;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- RLS Policies for subscriptions
-- =============================================================================

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own subscription" ON public.subscriptions;
CREATE POLICY "Users can view own subscription"
    ON public.subscriptions FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Service role can manage subscriptions" ON public.subscriptions;
CREATE POLICY "Service role can manage subscriptions"
    ON public.subscriptions FOR ALL
    USING (TRUE)
    WITH CHECK (TRUE);

-- =============================================================================
-- RLS Policies for subscription_usage
-- =============================================================================

ALTER TABLE public.subscription_usage ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own usage" ON public.subscription_usage;
CREATE POLICY "Users can view own usage"
    ON public.subscription_usage FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Service role can manage usage" ON public.subscription_usage;
CREATE POLICY "Service role can manage usage"
    ON public.subscription_usage FOR ALL
    USING (TRUE)
    WITH CHECK (TRUE);

-- =============================================================================
-- RLS Policies for referral_codes
-- =============================================================================

ALTER TABLE public.referral_codes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own referral code" ON public.referral_codes;
CREATE POLICY "Users can view own referral code"
    ON public.referral_codes FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Anyone can validate referral codes" ON public.referral_codes;
CREATE POLICY "Anyone can validate referral codes"
    ON public.referral_codes FOR SELECT
    USING (TRUE);

DROP POLICY IF EXISTS "Service role can manage referral codes" ON public.referral_codes;
CREATE POLICY "Service role can manage referral codes"
    ON public.referral_codes FOR ALL
    USING (TRUE)
    WITH CHECK (TRUE);

-- =============================================================================
-- RLS Policies for referral_redemptions
-- =============================================================================

ALTER TABLE public.referral_redemptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own referral redemptions" ON public.referral_redemptions;
CREATE POLICY "Users can view own referral redemptions"
    ON public.referral_redemptions FOR SELECT
    USING (auth.uid() = referrer_user_id OR auth.uid() = referred_user_id);

DROP POLICY IF EXISTS "Service role can manage referral redemptions" ON public.referral_redemptions;
CREATE POLICY "Service role can manage referral redemptions"
    ON public.referral_redemptions FOR ALL
    USING (TRUE)
    WITH CHECK (TRUE);

-- =============================================================================
-- BACKFILL: Create subscriptions and referral codes for existing users
-- =============================================================================

-- Create free subscriptions for existing users who don't have one
INSERT INTO public.subscriptions (user_id, plan_type, status, current_period_start)
SELECT id, 'free', 'active', COALESCE(created_at, NOW())
FROM public.users
WHERE id NOT IN (SELECT user_id FROM public.subscriptions)
ON CONFLICT (user_id) DO NOTHING;

-- Generate referral codes for existing users who don't have one
INSERT INTO public.referral_codes (user_id, code)
SELECT id, public.generate_referral_code(id, full_name)
FROM public.users
WHERE id NOT IN (SELECT user_id FROM public.referral_codes)
ON CONFLICT (user_id) DO NOTHING;

-- Create current month usage records for existing users
INSERT INTO public.subscription_usage (user_id, period_start)
SELECT id, DATE_TRUNC('month', CURRENT_DATE)::DATE
FROM public.users
WHERE id NOT IN (
    SELECT user_id FROM public.subscription_usage
    WHERE period_start = DATE_TRUNC('month', CURRENT_DATE)::DATE
)
ON CONFLICT (user_id, period_start) DO NOTHING;

COMMIT;
