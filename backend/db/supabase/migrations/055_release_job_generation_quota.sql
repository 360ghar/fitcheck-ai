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
-- by job id. The unused count is derived from the durable job row
-- (reserved_generations minus items that actually generated) so a worker
-- with a stale in-memory generation_completed set cannot over/under-refund.
-- The daily counter is only decremented when it still belongs to the
-- reservation's day (last_reset_date is before today, or the job was created
-- today); a leftover yesterday-job must not shrink today's counter after
-- the daily reset. Lifetime totals always decrement. Returns FALSE when the
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
    v_reserved INTEGER;
    v_generated INTEGER;
    v_unused INTEGER;
    v_created DATE;
    v_last_reset DATE;
    v_items JSONB;
BEGIN
    IF p_count < 0 THEN
        RAISE EXCEPTION 'Invalid generation quota release';
    END IF;

    SELECT reserved_generations,
           (created_at AT TIME ZONE 'UTC')::date,
           COALESCE(items, '[]'::jsonb)
    INTO v_reserved, v_created, v_items
    FROM public.extraction_jobs
    WHERE id = p_job_id
      AND user_id = p_user_id
      AND reserved_generations > 0
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    UPDATE public.extraction_jobs
    SET reserved_generations = 0,
        updated_at = NOW()
    WHERE id = p_job_id
      AND user_id = p_user_id;

    SELECT COUNT(*)::integer
    INTO v_generated
    FROM jsonb_array_elements(v_items) AS elem
    WHERE NULLIF(elem->>'generated_image_url', '') IS NOT NULL
       OR elem->>'status' = 'generated';

    v_unused := GREATEST(0, v_reserved - v_generated);
    IF v_unused <= 0 THEN
        RETURN TRUE;
    END IF;

    SELECT last_reset_date
    INTO v_last_reset
    FROM public.user_ai_settings
    WHERE user_id = p_user_id
    FOR UPDATE;

    UPDATE public.user_ai_settings
    SET daily_generation_count = CASE
            WHEN v_last_reset IS NULL
              OR v_last_reset < CURRENT_DATE
              OR v_created = CURRENT_DATE
            THEN GREATEST(0, COALESCE(daily_generation_count, 0) - v_unused)
            ELSE daily_generation_count
        END,
        total_generations = GREATEST(0, COALESCE(total_generations, 0) - v_unused),
        updated_at = NOW()
    WHERE user_id = p_user_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- The backend calls this with the service-role client, so browser roles must
-- not be able to invoke it (same policy as 022/024/026).
REVOKE EXECUTE ON FUNCTION public.release_job_generation_quota(TEXT, UUID, INTEGER)
    FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.release_job_generation_quota(TEXT, UUID, INTEGER) TO service_role;

COMMIT;
