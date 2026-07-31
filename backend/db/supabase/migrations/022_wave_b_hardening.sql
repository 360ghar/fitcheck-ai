-- Wave B backend hardening: atomic reservations, referral redemption, and
-- database-enforced active social-import admission.

BEGIN;

-- Count and insert under an advisory transaction lock so the configured
-- per-user limit remains authoritative across workers/processes. A unique
-- index cannot represent limits greater than one.
CREATE OR REPLACE FUNCTION public.create_social_import_job(
    p_user_id UUID,
    p_platform VARCHAR(20),
    p_source_url TEXT,
    p_normalized_url TEXT,
    p_max_concurrent_jobs INTEGER DEFAULT 1
)
RETURNS SETOF public.social_import_jobs AS $$
DECLARE
    active_count INTEGER;
    created_job public.social_import_jobs;
BEGIN
    IF p_max_concurrent_jobs < 1 THEN
        RAISE EXCEPTION 'Invalid social import concurrency limit';
    END IF;

    -- pg_advisory_xact_lock serializes admissions for this user only and does
    -- not hold a row lock on an unrelated table or require a schema change.
    PERFORM pg_advisory_xact_lock(hashtextextended(p_user_id::TEXT, 0));

    SELECT COUNT(*) INTO active_count
    FROM public.social_import_jobs
    WHERE user_id = p_user_id
      AND status NOT IN ('completed', 'cancelled', 'failed');

    IF active_count >= p_max_concurrent_jobs THEN
        RAISE EXCEPTION 'Social import concurrency limit reached';
    END IF;

    INSERT INTO public.social_import_jobs (
        user_id,
        platform,
        source_url,
        normalized_url,
        status,
        created_at,
        updated_at
    ) VALUES (
        p_user_id,
        p_platform,
        p_source_url,
        p_normalized_url,
        'created',
        NOW(),
        NOW()
    )
    RETURNING * INTO created_job;

    RETURN NEXT created_job;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.create_social_import_job(UUID, VARCHAR, TEXT, TEXT, INTEGER) TO service_role;

-- Stripe retries the same event. Keeping event IDs makes webhook handling
-- idempotent at the database boundary.
CREATE TABLE IF NOT EXISTS public.stripe_webhook_events (
    event_id TEXT PRIMARY KEY,
    event_type TEXT NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.stripe_webhook_events ENABLE ROW LEVEL SECURITY;

-- Conditional monthly reservation. The UPDATE row lock makes the quota
-- check and increment one operation, so concurrent requests cannot overshoot.
CREATE OR REPLACE FUNCTION public.reserve_usage(
    p_user_id UUID,
    p_period_start DATE,
    p_field TEXT,
    p_count INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 0
)
RETURNS BOOLEAN AS $$
DECLARE
    reserved BOOLEAN := FALSE;
BEGIN
    IF p_count <= 0 OR p_limit < 0 THEN
        RAISE EXCEPTION 'Invalid usage reservation';
    END IF;

    IF p_field = 'monthly_extractions' THEN
        UPDATE public.subscription_usage
        SET monthly_extractions = COALESCE(monthly_extractions, 0) + p_count,
            updated_at = NOW()
        WHERE user_id = p_user_id
          AND period_start = p_period_start
          AND COALESCE(monthly_extractions, 0) + p_count <= p_limit;
        reserved := FOUND;
    ELSIF p_field = 'monthly_generations' THEN
        UPDATE public.subscription_usage
        SET monthly_generations = COALESCE(monthly_generations, 0) + p_count,
            updated_at = NOW()
        WHERE user_id = p_user_id
          AND period_start = p_period_start
          AND COALESCE(monthly_generations, 0) + p_count <= p_limit;
        reserved := FOUND;
    ELSIF p_field = 'monthly_embeddings' THEN
        UPDATE public.subscription_usage
        SET monthly_embeddings = COALESCE(monthly_embeddings, 0) + p_count,
            updated_at = NOW()
        WHERE user_id = p_user_id
          AND period_start = p_period_start
          AND COALESCE(monthly_embeddings, 0) + p_count <= p_limit;
        reserved := FOUND;
    ELSE
        RAISE EXCEPTION 'Invalid field name: %', p_field;
    END IF;

    RETURN reserved;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Referral credits are also applied inside the redemption transaction. This
-- helper is intentionally idempotent only when called by the redemption
-- function while its redemption row is locked.
CREATE OR REPLACE FUNCTION public.apply_referral_credit_atomic(
    p_user_id UUID,
    p_months INTEGER
)
RETURNS VOID AS $$
BEGIN
    IF p_months <= 0 THEN
        RAISE EXCEPTION 'Referral credit must be positive';
    END IF;

    INSERT INTO public.subscriptions (user_id, plan_type, status, current_period_start)
    VALUES (p_user_id, 'free', 'active', NOW())
    ON CONFLICT (user_id) DO NOTHING;

    UPDATE public.subscriptions
    SET plan_type = CASE WHEN plan_type = 'free' THEN 'pro_monthly' ELSE plan_type END,
        status = CASE WHEN plan_type = 'free' THEN 'trial' ELSE status END,
        trial_end = CASE
            WHEN plan_type = 'free'
                THEN GREATEST(COALESCE(trial_end, NOW()), NOW()) + make_interval(months => p_months)
            ELSE trial_end
        END,
        referral_credit_months = COALESCE(referral_credit_months, 0) + p_months,
        updated_at = NOW()
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Insert, credit, flag, and user attribution are one transaction. A retry
-- locks the existing redemption and only applies any missing side once.
CREATE OR REPLACE FUNCTION public.redeem_referral_atomic(
    p_referred_user_id UUID,
    p_code TEXT,
    p_credit_months INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    already_redeemed BOOLEAN,
    message TEXT,
    credit_months INTEGER
) AS $$
DECLARE
    code_row public.referral_codes%ROWTYPE;
    redemption_row public.referral_redemptions%ROWTYPE;
    had_redemption BOOLEAN := FALSE;
BEGIN
    SELECT * INTO code_row
    FROM public.referral_codes
    WHERE LOWER(code) = LOWER(TRIM(p_code))
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, FALSE, 'Referral code not found'::TEXT, 0;
        RETURN;
    END IF;

    IF code_row.user_id = p_referred_user_id THEN
        RETURN QUERY SELECT FALSE, FALSE, 'You cannot use your own referral code'::TEXT, 0;
        RETURN;
    END IF;

    SELECT * INTO redemption_row
    FROM public.referral_redemptions
    WHERE referred_user_id = p_referred_user_id
    FOR UPDATE;

    IF FOUND THEN
        had_redemption := TRUE;
    ELSE
        INSERT INTO public.referral_redemptions (
            referrer_user_id,
            referred_user_id,
            referral_code_id,
            referrer_credit_applied,
            referred_credit_applied
        ) VALUES (
            code_row.user_id,
            p_referred_user_id,
            code_row.id,
            FALSE,
            FALSE
        )
        RETURNING * INTO redemption_row;

        UPDATE public.referral_codes
        SET times_used = COALESCE(times_used, 0) + 1
        WHERE id = code_row.id;
    END IF;

    IF NOT redemption_row.referred_credit_applied THEN
        PERFORM public.apply_referral_credit_atomic(p_referred_user_id, p_credit_months);
        UPDATE public.referral_redemptions
        SET referred_credit_applied = TRUE
        WHERE id = redemption_row.id;
    END IF;

    IF NOT redemption_row.referrer_credit_applied THEN
        PERFORM public.apply_referral_credit_atomic(code_row.user_id, p_credit_months);
        UPDATE public.referral_redemptions
        SET referrer_credit_applied = TRUE
        WHERE id = redemption_row.id;
    END IF;

    UPDATE public.users
    SET referred_by_code = LOWER(TRIM(p_code))
    WHERE id = p_referred_user_id;

    RETURN QUERY SELECT
        TRUE,
        had_redemption,
        CASE WHEN had_redemption THEN 'Referral already applied' ELSE 'Referral code applied' END::TEXT,
        p_credit_months;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

COMMIT;
