-- PR9 hardening follow-ups.
--
-- 1. Social-import admission: clients could bypass the atomic
--    `create_social_import_job` cap by inserting rows directly through the
--    client INSERT policy (012). Drop the policy and revoke PUBLIC execution
--    of the SECURITY DEFINER RPC so admission runs only through the backend.
-- 2. Align the durable `generation_batch_size` bound with the API: the API
--    mirrors the configurable concurrency cap into this column, and config
--    now clamps that cap to 100, so the CHECK must accept 100.
-- 3. Photoshoot quota reconcile: partial failures / cancellations currently
--    consume the entire requested daily reservation. Add a release RPC so the
--    pipeline can hand back images it never produced.

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. Social import admission hardening
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS "Users can insert own social import jobs"
    ON public.social_import_jobs;

REVOKE EXECUTE ON FUNCTION public.create_social_import_job(UUID, VARCHAR, TEXT, TEXT, INTEGER)
    FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.create_social_import_job(UUID, VARCHAR, TEXT, TEXT, INTEGER)
    TO service_role;

-- ---------------------------------------------------------------------------
-- 2. generation_batch_size bound aligned with config clamp (max 100)
-- ---------------------------------------------------------------------------
ALTER TABLE IF EXISTS public.extraction_jobs
    DROP CONSTRAINT IF EXISTS valid_batch_size;

ALTER TABLE IF EXISTS public.extraction_jobs
    ADD CONSTRAINT valid_batch_size
    CHECK (generation_batch_size > 0 AND generation_batch_size <= 100);

-- ---------------------------------------------------------------------------
-- 3. Photoshoot daily-quota release for failure/cancellation reconciliation
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.release_daily_photoshoot_usage(
    p_user_id UUID,
    p_period_start DATE,
    p_count INTEGER DEFAULT 1
)
RETURNS BOOLEAN AS $$
BEGIN
    IF p_count <= 0 THEN
        RAISE EXCEPTION 'Invalid photoshoot usage release';
    END IF;

    UPDATE public.subscription_usage
    SET daily_photoshoot_images = GREATEST(0, COALESCE(daily_photoshoot_images, 0) - p_count),
        updated_at = NOW()
    WHERE user_id = p_user_id
      AND period_start = p_period_start;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE EXECUTE ON FUNCTION public.release_daily_photoshoot_usage(UUID, DATE, INTEGER)
    FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.release_daily_photoshoot_usage(UUID, DATE, INTEGER)
    TO service_role;

COMMIT;
