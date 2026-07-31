-- Replace the original one-active-job unique index with an atomic admission
-- function that supports SOCIAL_IMPORT_MAX_CONCURRENT_JOBS > 1.

BEGIN;

DROP INDEX IF EXISTS public.idx_social_import_one_active_job_per_user;

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

COMMIT;
