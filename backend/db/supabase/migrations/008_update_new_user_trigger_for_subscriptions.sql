-- FitCheck AI - Update new user trigger for subscriptions and referrals
-- This migration updates the auth.users trigger function so new users get:
-- - a default free subscription
-- - a referral code
-- - a subscription usage record for the current month
--
-- Target: Supabase Postgres

BEGIN;

-- =============================================================================
-- FUNCTION: Handle new user creation (updated)
-- =============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insert into public.users with data from auth.users
    INSERT INTO public.users (id, email, full_name, email_verified, is_active, created_at, updated_at)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        COALESCE(NEW.email_confirmed_at IS NOT NULL, FALSE),
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
    ON CONFLICT (id) DO UPDATE
    SET email = EXCLUDED.email,
        full_name = COALESCE(EXCLUDED.full_name, public.users.full_name),
        updated_at = CURRENT_TIMESTAMP;

    -- Create default user preferences if they don't exist
    INSERT INTO public.user_preferences (user_id, favorite_colors, preferred_styles, liked_brands, disliked_patterns, preferred_occasions, data_points_collected)
    VALUES (
        NEW.id,
        '[]'::jsonb,
        '[]'::jsonb,
        '[]'::jsonb,
        '[]'::jsonb,
        '[]'::jsonb,
        0
    )
    ON CONFLICT (user_id) DO NOTHING;

    -- Create default user settings if they don't exist
    INSERT INTO public.user_settings (user_id, language, measurement_units, notifications_enabled, email_marketing, dark_mode)
    VALUES (
        NEW.id,
        'en',
        'imperial',
        TRUE,
        FALSE,
        FALSE
    )
    ON CONFLICT (user_id) DO NOTHING;

    -- Create free subscription for new user
    INSERT INTO public.subscriptions (user_id, plan_type, status, current_period_start)
    VALUES (
        NEW.id,
        'free',
        'active',
        NOW()
    )
    ON CONFLICT (user_id) DO NOTHING;

    -- Generate referral code for new user
    INSERT INTO public.referral_codes (user_id, code)
    VALUES (
        NEW.id,
        public.generate_referral_code(NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name', 'user'))
    )
    ON CONFLICT (user_id) DO NOTHING;

    -- Create current month usage record
    INSERT INTO public.subscription_usage (user_id, period_start)
    VALUES (
        NEW.id,
        DATE_TRUNC('month', CURRENT_DATE)::DATE
    )
    ON CONFLICT (user_id, period_start) DO NOTHING;

    RETURN NEW;
END;
$$;

-- =============================================================================
-- BACKFILL: Ensure subscriptions and referral data exist
-- =============================================================================

-- Create free subscriptions for any users who don't have one
INSERT INTO public.subscriptions (user_id, plan_type, status, current_period_start)
SELECT id, 'free', 'active', COALESCE(created_at, NOW())
FROM public.users
WHERE id NOT IN (SELECT user_id FROM public.subscriptions)
ON CONFLICT (user_id) DO NOTHING;

-- Generate referral codes for any users who don't have one
INSERT INTO public.referral_codes (user_id, code)
SELECT id, public.generate_referral_code(id, full_name)
FROM public.users
WHERE id NOT IN (SELECT user_id FROM public.referral_codes)
ON CONFLICT (user_id) DO NOTHING;

-- Create current month usage records for any users missing one
INSERT INTO public.subscription_usage (user_id, period_start)
SELECT id, DATE_TRUNC('month', CURRENT_DATE)::DATE
FROM public.users
WHERE id NOT IN (
    SELECT user_id FROM public.subscription_usage
    WHERE period_start = DATE_TRUNC('month', CURRENT_DATE)::DATE
)
ON CONFLICT (user_id, period_start) DO NOTHING;

COMMIT;

