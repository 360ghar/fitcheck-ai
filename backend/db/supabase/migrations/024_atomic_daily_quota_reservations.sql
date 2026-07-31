-- Atomic reservations for the legacy daily AI and photoshoot quotas.
-- These counters remain separate from subscription_usage monthly counters
-- because existing clients and settings pages still expose both contracts.

BEGIN;

CREATE OR REPLACE FUNCTION public.reserve_ai_usage(
    p_user_id UUID,
    p_operation TEXT,
    p_count INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 0
)
RETURNS BOOLEAN AS $$
DECLARE
    reserved BOOLEAN := FALSE;
BEGIN
    IF p_count <= 0 OR p_limit < 0 THEN
        RAISE EXCEPTION 'Invalid AI usage reservation';
    END IF;

    -- Take the row lock while resetting stale counters. The subsequent
    -- conditional UPDATE is therefore the authoritative admission check.
    UPDATE public.user_ai_settings
    SET daily_extraction_count = 0,
        daily_generation_count = 0,
        daily_embedding_count = 0,
        last_reset_date = CURRENT_DATE,
        updated_at = NOW()
    WHERE user_id = p_user_id
      AND (last_reset_date IS NULL OR last_reset_date < CURRENT_DATE);

    IF p_operation = 'extraction' THEN
        UPDATE public.user_ai_settings
        SET daily_extraction_count = COALESCE(daily_extraction_count, 0) + p_count,
            total_extractions = COALESCE(total_extractions, 0) + p_count,
            updated_at = NOW()
        WHERE user_id = p_user_id
          AND COALESCE(daily_extraction_count, 0) + p_count <= p_limit;
        reserved := FOUND;
    ELSIF p_operation = 'generation' THEN
        UPDATE public.user_ai_settings
        SET daily_generation_count = COALESCE(daily_generation_count, 0) + p_count,
            total_generations = COALESCE(total_generations, 0) + p_count,
            updated_at = NOW()
        WHERE user_id = p_user_id
          AND COALESCE(daily_generation_count, 0) + p_count <= p_limit;
        reserved := FOUND;
    ELSIF p_operation = 'embedding' THEN
        UPDATE public.user_ai_settings
        SET daily_embedding_count = COALESCE(daily_embedding_count, 0) + p_count,
            total_embeddings = COALESCE(total_embeddings, 0) + p_count,
            updated_at = NOW()
        WHERE user_id = p_user_id
          AND COALESCE(daily_embedding_count, 0) + p_count <= p_limit;
        reserved := FOUND;
    ELSE
        RAISE EXCEPTION 'Invalid AI operation: %', p_operation;
    END IF;

    RETURN reserved;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.release_ai_usage(
    p_user_id UUID,
    p_operation TEXT,
    p_count INTEGER DEFAULT 1
)
RETURNS BOOLEAN AS $$
BEGIN
    IF p_count <= 0 THEN
        RAISE EXCEPTION 'Invalid AI usage release';
    END IF;

    IF p_operation = 'extraction' THEN
        UPDATE public.user_ai_settings
        SET daily_extraction_count = GREATEST(0, COALESCE(daily_extraction_count, 0) - p_count),
            total_extractions = GREATEST(0, COALESCE(total_extractions, 0) - p_count),
            updated_at = NOW()
        WHERE user_id = p_user_id;
    ELSIF p_operation = 'generation' THEN
        UPDATE public.user_ai_settings
        SET daily_generation_count = GREATEST(0, COALESCE(daily_generation_count, 0) - p_count),
            total_generations = GREATEST(0, COALESCE(total_generations, 0) - p_count),
            updated_at = NOW()
        WHERE user_id = p_user_id;
    ELSIF p_operation = 'embedding' THEN
        UPDATE public.user_ai_settings
        SET daily_embedding_count = GREATEST(0, COALESCE(daily_embedding_count, 0) - p_count),
            total_embeddings = GREATEST(0, COALESCE(total_embeddings, 0) - p_count),
            updated_at = NOW()
        WHERE user_id = p_user_id;
    ELSE
        RAISE EXCEPTION 'Invalid AI operation: %', p_operation;
    END IF;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.reserve_daily_photoshoot_usage(
    p_user_id UUID,
    p_period_start DATE,
    p_count INTEGER,
    p_limit INTEGER
)
RETURNS BOOLEAN AS $$
DECLARE
    reserved BOOLEAN := FALSE;
BEGIN
    IF p_count <= 0 OR p_limit < 0 THEN
        RAISE EXCEPTION 'Invalid photoshoot usage reservation';
    END IF;

    -- Reset and reserve under row-level locks so concurrent jobs cannot both
    -- pass the daily limit check.
    UPDATE public.subscription_usage
    SET daily_photoshoot_images = 0,
        last_photoshoot_reset = CURRENT_DATE,
        updated_at = NOW()
    WHERE user_id = p_user_id
      AND period_start = p_period_start
      AND (last_photoshoot_reset IS NULL OR last_photoshoot_reset < CURRENT_DATE);

    UPDATE public.subscription_usage
    SET daily_photoshoot_images = COALESCE(daily_photoshoot_images, 0) + p_count,
        updated_at = NOW()
    WHERE user_id = p_user_id
      AND period_start = p_period_start
      AND COALESCE(daily_photoshoot_images, 0) + p_count <= p_limit;
    reserved := FOUND;

    RETURN reserved;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

COMMIT;
