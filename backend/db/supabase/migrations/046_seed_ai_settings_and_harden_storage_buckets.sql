-- FitCheck AI - Seed user_ai_settings inside reserve_ai_usage + harden buckets
--
-- 1. reserve_ai_usage returned reserved=FALSE for users with no
--    user_ai_settings row: the conditional UPDATE matched zero rows, so a
--    brand-new (or never-provisioned) user could never pass an AI admission
--    check even with quota available. The RPC now seeds the row with
--    INSERT ... ON CONFLICT (user_id) DO NOTHING before the admission
--    UPDATE. Idempotent, and the function signature is unchanged, so the
--    quota-RPC probes in app/utils/db.py keep working.
--
-- 2. Migration 001 inserted the pre-R2 storage buckets with public=true
--    (fitcheck-images/items/outfits/avatars). R2 is the serving path now,
--    so nothing must be readable from Supabase Storage without the worker's
--    per-object authorization. The buckets are kept (do not delete them)
--    but flipped to private. Safe: no app path reads these buckets via
--    Supabase Storage URLs anymore.
--
-- RPC redefinition style follows 026/031/033: REVOKE the old grants, CREATE
-- OR REPLACE, then GRANT service_role only (the backend calls these RPCs
-- with the service-role client).
--
-- Target: Supabase Postgres

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

    -- Seed the settings row for users who have none (new users, or users
    -- created before the read-path provisioning existed). Without this the
    -- UPDATE below matched zero rows and every reservation returned FALSE
    -- for them regardless of quota. ON CONFLICT DO NOTHING keeps the seed
    -- idempotent and never overwrites an existing row's counters.
    INSERT INTO public.user_ai_settings (user_id)
    VALUES (p_user_id)
    ON CONFLICT (user_id) DO NOTHING;

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

-- Harden RPC privileges (same policy as 022/026/033: the backend calls this
-- with the service-role client, so browser roles must not be able to invoke
-- it). REVOKE first so a re-run of this file is idempotent, then GRANT the
-- single role the application uses.
REVOKE EXECUTE ON FUNCTION public.reserve_ai_usage(UUID, TEXT, INTEGER, INTEGER)
    FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.reserve_ai_usage(UUID, TEXT, INTEGER, INTEGER)
    TO service_role;

-- Pre-R2 legacy buckets are no longer a serving path; keep the buckets (the
-- corpus history and any tooling references them) but make them private so
-- nothing is publicly readable from Supabase Storage.
UPDATE storage.buckets
SET public = false
WHERE id IN ('fitcheck-images', 'items', 'outfits', 'avatars');

COMMIT;
