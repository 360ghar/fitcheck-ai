-- FitCheck AI - User Profile Auto-Creation Trigger
-- This migration should be run after 001_full_schema.sql to add automatic
-- user profile creation when a new auth user is created.
--
-- Target: Supabase Postgres

BEGIN;

-- =============================================================================
-- FUNCTION: Handle new user creation
-- =============================================================================

-- This function creates a profile in public.users when a new user signs up
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

    RETURN NEW;
END;
$$;

-- =============================================================================
-- TRIGGER: on_auth_user_created
-- =============================================================================

-- Drop the trigger if it exists (for idempotence)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create the trigger to run after user creation in auth.users
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- =============================================================================
-- RLS POLICY: Allow INSERT on public.users for new registrations
-- =============================================================================

-- The service role can insert new users
DROP POLICY IF EXISTS "Service role can insert users" ON public.users;
CREATE POLICY "Service role can insert users"
    ON public.users FOR INSERT
    WITH CHECK (TRUE);

-- Users can insert their own profile (if trigger doesn't handle it)
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
CREATE POLICY "Users can insert own profile"
    ON public.users FOR INSERT
    WITH CHECK (auth.uid() = id);

COMMIT;
