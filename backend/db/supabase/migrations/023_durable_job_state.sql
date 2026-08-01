-- Durable metadata/final-state snapshots for API job reconnects.
-- Active jobs are recoverable for polling only; this does not resume a worker
-- pipeline after a process restart. Image base64 is intentionally excluded.

ALTER TABLE IF EXISTS extraction_jobs
    DROP CONSTRAINT IF EXISTS valid_batch_size;

ALTER TABLE IF EXISTS extraction_jobs
    ADD CONSTRAINT valid_batch_size
    CHECK (generation_batch_size > 0 AND generation_batch_size <= 50);

CREATE TABLE IF NOT EXISTS public.photoshoot_jobs (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'complete', 'failed', 'cancelled')),
    session_id TEXT NOT NULL,
    use_case TEXT NOT NULL,
    custom_prompt TEXT,
    num_images INTEGER NOT NULL CHECK (num_images > 0),
    batch_size INTEGER NOT NULL CHECK (batch_size > 0),
    aspect_ratio TEXT NOT NULL DEFAULT '1:1',
    total_batches INTEGER NOT NULL DEFAULT 1,
    current_batch INTEGER NOT NULL DEFAULT 0,
    generated_images JSONB NOT NULL DEFAULT '[]'::jsonb,
    failed_indices JSONB NOT NULL DEFAULT '[]'::jsonb,
    usage JSONB,
    error_message TEXT,
    reference_photo_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_photoshoot_jobs_user_id
    ON public.photoshoot_jobs(user_id);
CREATE INDEX IF NOT EXISTS idx_photoshoot_jobs_status
    ON public.photoshoot_jobs(status);
CREATE INDEX IF NOT EXISTS idx_photoshoot_jobs_user_status
    ON public.photoshoot_jobs(user_id, status);
CREATE INDEX IF NOT EXISTS idx_photoshoot_jobs_created_at
    ON public.photoshoot_jobs(created_at DESC);

CREATE OR REPLACE FUNCTION update_photoshoot_jobs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Re-runnable guards: Postgres has no CREATE TRIGGER / CREATE POLICY IF NOT
-- EXISTS, so drop-then-create keeps the SQL-editor runbook idempotent (a
-- partial or repeated application must not abort with 42710 "already exists").
DROP TRIGGER IF EXISTS photoshoot_jobs_updated_at
    ON public.photoshoot_jobs;

CREATE TRIGGER photoshoot_jobs_updated_at
    BEFORE UPDATE ON public.photoshoot_jobs
    FOR EACH ROW EXECUTE FUNCTION update_photoshoot_jobs_updated_at();

ALTER TABLE public.photoshoot_jobs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS photoshoot_jobs_select_own
    ON public.photoshoot_jobs;

CREATE POLICY photoshoot_jobs_select_own
    ON public.photoshoot_jobs FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS photoshoot_jobs_insert_own
    ON public.photoshoot_jobs;

CREATE POLICY photoshoot_jobs_insert_own
    ON public.photoshoot_jobs FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS photoshoot_jobs_update_own
    ON public.photoshoot_jobs;

CREATE POLICY photoshoot_jobs_update_own
    ON public.photoshoot_jobs FOR UPDATE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS photoshoot_jobs_delete_own
    ON public.photoshoot_jobs;

CREATE POLICY photoshoot_jobs_delete_own
    ON public.photoshoot_jobs FOR DELETE
    USING (auth.uid() = user_id);

COMMENT ON TABLE public.photoshoot_jobs IS
    'Durable photoshoot job metadata and final storage URLs; active jobs are polling-only after restart';
