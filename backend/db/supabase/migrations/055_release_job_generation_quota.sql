-- FitCheck AI - Idempotent batch-generation quota release
--
-- Batch jobs reserve generation quota at admission (total_images x 3) and
-- release the unused remainder at the terminal transition. The release was a
-- two-step dance in Python (CAS the durable reserved_generations to 0, then
-- call release_ai_usage) with a blind restore on failure; a LOST RPC response
-- after the CAS committed could then restore the reservation and let a later
-- cleanup release the same slots twice, inflating daily_generation_count past
-- the user's plan limit.
--
-- This RPC makes the claim + release a SINGLE atomic database operation keyed
-- by job id: the caller only gets the quota decrement when it also wins the
-- claim (reserved_generations > 0 still holds), so an ambiguous retry or a
-- concurrent cleanup/cancel can never double-release. Returns FALSE when the
-- reservation was already released (nothing to do) - the caller treats that
-- as success.
--
-- Rerunnable (CREATE OR REPLACE + guarded REVOKE/GRANT): safe to re-run.
--
-- Target: Supabase Postgres

BEGIN;

CREATE OR REPLACE FUNCTION public.release_job_generation_quota(
    p_job_id TEXT,
    p_user_id UUID,
    p_count INTEGER DEFAULT 0
)
RETURNS BOOLEAN AS $$
DECLARE
    v_released BOOLEAN;
BEGIN
    IF p_count < 0 THEN
        RAISE EXCEPTION 'Invalid generation quota release';
    END IF;

    -- Atomic claim: zero the durable reservation only while it still holds
    -- (WHERE reserved_generations > 0). A concurrent caller or a retry after
    -- a lost response sees no row and returns FALSE - the release happens
    -- exactly once per reservation, so daily_generation_count can never be
    -- decremented twice for the same reserved slots.
    UPDATE public.extraction_jobs
    SET reserved_generations = 0,
        updated_at = NOW()
    WHERE id = p_job_id
      AND user_id = p_user_id
      AND reserved_generations > 0;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    IF p_count > 0 THEN
        UPDATE public.user_ai_settings
        SET daily_generation_count = GREATEST(0, COALESCE(daily_generation_count, 0) - p_count),
            total_generations = GREATEST(0, COALESCE(total_generations, 0) - p_count),
            updated_at = NOW()
        WHERE user_id = p_user_id;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- The backend calls this with the service-role client, so browser roles must
-- not be able to invoke it (same policy as 022/024/026).
REVOKE EXECUTE ON FUNCTION public.release_job_generation_quota(TEXT, UUID, INTEGER)
    FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.release_job_generation_quota(TEXT, UUID, INTEGER) TO service_role;

COMMIT;
