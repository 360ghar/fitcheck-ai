-- ============================================================================
-- Migration: Extraction Jobs Persistence
-- Description: Add table for persisting extraction job state to enable resume
-- Date: 2026-02-15
-- ============================================================================

-- Create extraction_jobs table for persisting job state
CREATE TABLE IF NOT EXISTS extraction_jobs (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('pending', 'extracting', 'generating', 'completed', 'failed', 'cancelled')),
    job_type TEXT NOT NULL CHECK (job_type IN ('single', 'batch')),
    total_images INTEGER NOT NULL DEFAULT 1,
    total_items INTEGER NOT NULL DEFAULT 0,
    extractions_completed INTEGER NOT NULL DEFAULT 0,
    extractions_failed INTEGER NOT NULL DEFAULT 0,
    generations_completed INTEGER NOT NULL DEFAULT 0,
    generations_failed INTEGER NOT NULL DEFAULT 0,
    auto_generate BOOLEAN NOT NULL DEFAULT true,
    generation_batch_size INTEGER NOT NULL DEFAULT 5,
    error_message TEXT,
    items JSONB,
    images JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    CONSTRAINT valid_batch_size CHECK (generation_batch_size > 0 AND generation_batch_size <= 10)
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_extraction_jobs_user_id ON extraction_jobs(user_id);
CREATE INDEX IF NOT EXISTS idx_extraction_jobs_status ON extraction_jobs(status);
CREATE INDEX IF NOT EXISTS idx_extraction_jobs_created_at ON extraction_jobs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_extraction_jobs_user_status ON extraction_jobs(user_id, status);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION update_extraction_jobs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER extraction_jobs_updated_at
    BEFORE UPDATE ON extraction_jobs
    FOR EACH ROW
    EXECUTE FUNCTION update_extraction_jobs_updated_at();

-- Add RLS policies
ALTER TABLE extraction_jobs ENABLE ROW LEVEL SECURITY;

-- Users can only see their own jobs
CREATE POLICY extraction_jobs_select_own
    ON extraction_jobs
    FOR SELECT
    USING (auth.uid() = user_id);

-- Users can only insert their own jobs
CREATE POLICY extraction_jobs_insert_own
    ON extraction_jobs
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can only update their own jobs
CREATE POLICY extraction_jobs_update_own
    ON extraction_jobs
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Users can only delete their own jobs
CREATE POLICY extraction_jobs_delete_own
    ON extraction_jobs
    FOR DELETE
    USING (auth.uid() = user_id);

-- Cleanup function: Delete completed/failed/cancelled jobs older than 7 days
CREATE OR REPLACE FUNCTION cleanup_old_extraction_jobs()
RETURNS void AS $$
BEGIN
    DELETE FROM extraction_jobs
    WHERE status IN ('completed', 'failed', 'cancelled')
    AND updated_at < NOW() - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql;

-- Optional: Schedule cleanup (requires pg_cron extension)
-- SELECT cron.schedule('cleanup-extraction-jobs', '0 2 * * *', 'SELECT cleanup_old_extraction_jobs()');

COMMENT ON TABLE extraction_jobs IS 'Persisted extraction job state for resume capability';
COMMENT ON COLUMN extraction_jobs.id IS 'Job ID (UUID)';
COMMENT ON COLUMN extraction_jobs.user_id IS 'User who created the job';
COMMENT ON COLUMN extraction_jobs.status IS 'Current job status';
COMMENT ON COLUMN extraction_jobs.job_type IS 'Single or batch extraction';
COMMENT ON COLUMN extraction_jobs.items IS 'Detected items (JSON array)';
COMMENT ON COLUMN extraction_jobs.images IS 'Image data (JSON object)';
COMMENT ON COLUMN extraction_jobs.completed_at IS 'When job completed/failed/cancelled';
