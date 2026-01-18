-- FitCheck AI - Photoshoot Generator Support
-- This migration adds daily photoshoot usage tracking to subscription_usage.
--
-- Target: Supabase Postgres

BEGIN;

-- =============================================================================
-- ALTER TABLE: subscription_usage - Add photoshoot tracking columns
-- =============================================================================

-- Add daily photoshoot image counter
ALTER TABLE public.subscription_usage
    ADD COLUMN IF NOT EXISTS daily_photoshoot_images INTEGER DEFAULT 0;

-- Add date of last photoshoot reset (for daily limit tracking)
ALTER TABLE public.subscription_usage
    ADD COLUMN IF NOT EXISTS last_photoshoot_reset DATE;

-- =============================================================================
-- FUNCTION: Update increment_usage to support photoshoot field
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
    IF p_field NOT IN (
        'monthly_extractions',
        'monthly_generations',
        'monthly_embeddings',
        'daily_photoshoot_images'
    ) THEN
        RAISE EXCEPTION 'Invalid field name: %', p_field;
    END IF;

    -- Atomic increment using dynamic SQL
    EXECUTE format(
        'UPDATE public.subscription_usage SET %I = COALESCE(%I, 0) + $1, updated_at = NOW() WHERE user_id = $2 AND period_start = $3',
        p_field, p_field
    ) USING p_count, p_user_id, p_period_start;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- =============================================================================
-- FUNCTION: Reset daily photoshoot usage
-- =============================================================================

CREATE OR REPLACE FUNCTION public.reset_daily_photoshoot_if_needed(
    p_user_id UUID,
    p_period_start DATE
)
RETURNS INTEGER AS $$
DECLARE
    current_count INTEGER;
    last_reset DATE;
BEGIN
    -- Get current usage and last reset date
    SELECT daily_photoshoot_images, last_photoshoot_reset
    INTO current_count, last_reset
    FROM public.subscription_usage
    WHERE user_id = p_user_id AND period_start = p_period_start;

    -- If last reset is before today, reset the counter
    IF last_reset IS NULL OR last_reset < CURRENT_DATE THEN
        UPDATE public.subscription_usage
        SET daily_photoshoot_images = 0,
            last_photoshoot_reset = CURRENT_DATE,
            updated_at = NOW()
        WHERE user_id = p_user_id AND period_start = p_period_start;

        RETURN 0;
    END IF;

    RETURN COALESCE(current_count, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- =============================================================================
-- Initialize photoshoot tracking for existing usage records
-- =============================================================================

-- Set default values for existing records
UPDATE public.subscription_usage
SET daily_photoshoot_images = 0,
    last_photoshoot_reset = CURRENT_DATE
WHERE daily_photoshoot_images IS NULL
   OR last_photoshoot_reset IS NULL;

COMMIT;
