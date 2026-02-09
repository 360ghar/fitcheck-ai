-- FitCheck AI - Social Import Pipeline
-- Adds persisted jobs/photos/items/auth sessions for Instagram/Facebook URL imports.

BEGIN;

-- =============================================================================
-- TABLES
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.social_import_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    platform VARCHAR(20) NOT NULL,
    source_url TEXT NOT NULL,
    normalized_url TEXT NOT NULL,
    status VARCHAR(40) NOT NULL DEFAULT 'created',
    total_photos INTEGER NOT NULL DEFAULT 0,
    discovered_photos INTEGER NOT NULL DEFAULT 0,
    processed_photos INTEGER NOT NULL DEFAULT 0,
    approved_photos INTEGER NOT NULL DEFAULT 0,
    rejected_photos INTEGER NOT NULL DEFAULT 0,
    failed_photos INTEGER NOT NULL DEFAULT 0,
    error_message TEXT,
    auth_required BOOLEAN NOT NULL DEFAULT FALSE,
    discovery_completed BOOLEAN NOT NULL DEFAULT FALSE,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    CONSTRAINT social_import_jobs_status_check
        CHECK (status IN (
            'created',
            'discovering',
            'awaiting_auth',
            'processing',
            'paused_rate_limited',
            'completed',
            'cancelled',
            'failed'
        ))
);

CREATE TABLE IF NOT EXISTS public.social_import_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID NOT NULL REFERENCES public.social_import_jobs(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    ordinal INTEGER NOT NULL,
    source_photo_id TEXT,
    source_photo_url TEXT NOT NULL,
    source_thumb_url TEXT,
    source_taken_at TIMESTAMPTZ,
    status VARCHAR(30) NOT NULL DEFAULT 'queued',
    processing_started_at TIMESTAMPTZ,
    processing_completed_at TIMESTAMPTZ,
    reviewed_at TIMESTAMPTZ,
    error_message TEXT,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT social_import_photos_status_check
        CHECK (status IN (
            'queued',
            'processing',
            'awaiting_review',
            'buffered_ready',
            'approved',
            'rejected',
            'failed'
        )),
    CONSTRAINT social_import_photos_job_ordinal_unique UNIQUE (job_id, ordinal)
);

CREATE TABLE IF NOT EXISTS public.social_import_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID NOT NULL REFERENCES public.social_import_jobs(id) ON DELETE CASCADE,
    photo_id UUID NOT NULL REFERENCES public.social_import_photos(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    temp_id TEXT NOT NULL,
    name VARCHAR(255),
    category VARCHAR(50) NOT NULL,
    sub_category VARCHAR(50),
    colors JSONB NOT NULL DEFAULT '[]'::jsonb,
    material VARCHAR(50),
    pattern VARCHAR(50),
    brand VARCHAR(100),
    confidence DOUBLE PRECISION NOT NULL DEFAULT 0,
    bounding_box JSONB,
    detailed_description TEXT,
    generated_image_url TEXT,
    generated_thumbnail_url TEXT,
    generated_storage_path TEXT,
    generation_error TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'generated',
    saved_item_id UUID REFERENCES public.items(id) ON DELETE SET NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT social_import_items_status_check
        CHECK (status IN ('generated', 'edited', 'failed', 'saved', 'discarded')),
    CONSTRAINT social_import_items_job_temp_unique UNIQUE (job_id, temp_id)
);

CREATE TABLE IF NOT EXISTS public.social_import_auth_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID NOT NULL REFERENCES public.social_import_jobs(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    auth_type VARCHAR(20) NOT NULL,
    encrypted_session_blob TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT social_import_auth_sessions_auth_type_check
        CHECK (auth_type IN ('oauth', 'scraper')),
    CONSTRAINT social_import_auth_sessions_job_auth_unique UNIQUE (job_id, auth_type)
);

CREATE TABLE IF NOT EXISTS public.social_import_events (
    id BIGSERIAL PRIMARY KEY,
    job_id UUID NOT NULL REFERENCES public.social_import_jobs(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    event_type VARCHAR(80) NOT NULL,
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- INDEXES
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_social_import_jobs_user_status_created
    ON public.social_import_jobs(user_id, status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_social_import_jobs_created
    ON public.social_import_jobs(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_social_import_photos_job_status_ordinal
    ON public.social_import_photos(job_id, status, ordinal ASC);

CREATE INDEX IF NOT EXISTS idx_social_import_photos_job_ordinal
    ON public.social_import_photos(job_id, ordinal ASC);

CREATE INDEX IF NOT EXISTS idx_social_import_items_job_photo
    ON public.social_import_items(job_id, photo_id);

CREATE INDEX IF NOT EXISTS idx_social_import_items_photo_status
    ON public.social_import_items(photo_id, status);

CREATE INDEX IF NOT EXISTS idx_social_import_auth_sessions_user_expires
    ON public.social_import_auth_sessions(user_id, expires_at);

CREATE INDEX IF NOT EXISTS idx_social_import_events_job_created
    ON public.social_import_events(job_id, created_at ASC, id ASC);

-- =============================================================================
-- RLS
-- =============================================================================

ALTER TABLE public.social_import_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.social_import_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.social_import_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.social_import_auth_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.social_import_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own social import jobs" ON public.social_import_jobs;
DROP POLICY IF EXISTS "Users can insert own social import jobs" ON public.social_import_jobs;
DROP POLICY IF EXISTS "Users can update own social import jobs" ON public.social_import_jobs;
DROP POLICY IF EXISTS "Users can delete own social import jobs" ON public.social_import_jobs;

CREATE POLICY "Users can read own social import jobs"
    ON public.social_import_jobs FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own social import jobs"
    ON public.social_import_jobs FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own social import jobs"
    ON public.social_import_jobs FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own social import jobs"
    ON public.social_import_jobs FOR DELETE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can read own social import photos" ON public.social_import_photos;
DROP POLICY IF EXISTS "Users can insert own social import photos" ON public.social_import_photos;
DROP POLICY IF EXISTS "Users can update own social import photos" ON public.social_import_photos;
DROP POLICY IF EXISTS "Users can delete own social import photos" ON public.social_import_photos;

CREATE POLICY "Users can read own social import photos"
    ON public.social_import_photos FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own social import photos"
    ON public.social_import_photos FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own social import photos"
    ON public.social_import_photos FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own social import photos"
    ON public.social_import_photos FOR DELETE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can read own social import items" ON public.social_import_items;
DROP POLICY IF EXISTS "Users can insert own social import items" ON public.social_import_items;
DROP POLICY IF EXISTS "Users can update own social import items" ON public.social_import_items;
DROP POLICY IF EXISTS "Users can delete own social import items" ON public.social_import_items;

CREATE POLICY "Users can read own social import items"
    ON public.social_import_items FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own social import items"
    ON public.social_import_items FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own social import items"
    ON public.social_import_items FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own social import items"
    ON public.social_import_items FOR DELETE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can read own social import auth sessions" ON public.social_import_auth_sessions;
DROP POLICY IF EXISTS "Users can insert own social import auth sessions" ON public.social_import_auth_sessions;
DROP POLICY IF EXISTS "Users can update own social import auth sessions" ON public.social_import_auth_sessions;
DROP POLICY IF EXISTS "Users can delete own social import auth sessions" ON public.social_import_auth_sessions;

CREATE POLICY "Users can read own social import auth sessions"
    ON public.social_import_auth_sessions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own social import auth sessions"
    ON public.social_import_auth_sessions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own social import auth sessions"
    ON public.social_import_auth_sessions FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own social import auth sessions"
    ON public.social_import_auth_sessions FOR DELETE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can read own social import events" ON public.social_import_events;
DROP POLICY IF EXISTS "Users can insert own social import events" ON public.social_import_events;
DROP POLICY IF EXISTS "Users can delete own social import events" ON public.social_import_events;

CREATE POLICY "Users can read own social import events"
    ON public.social_import_events FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own social import events"
    ON public.social_import_events FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own social import events"
    ON public.social_import_events FOR DELETE
    USING (auth.uid() = user_id);

-- =============================================================================
-- updated_at triggers
-- =============================================================================

CREATE OR REPLACE FUNCTION public.update_social_import_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS social_import_jobs_updated_at ON public.social_import_jobs;
CREATE TRIGGER social_import_jobs_updated_at
    BEFORE UPDATE ON public.social_import_jobs
    FOR EACH ROW
    EXECUTE FUNCTION public.update_social_import_updated_at();

DROP TRIGGER IF EXISTS social_import_photos_updated_at ON public.social_import_photos;
CREATE TRIGGER social_import_photos_updated_at
    BEFORE UPDATE ON public.social_import_photos
    FOR EACH ROW
    EXECUTE FUNCTION public.update_social_import_updated_at();

DROP TRIGGER IF EXISTS social_import_items_updated_at ON public.social_import_items;
CREATE TRIGGER social_import_items_updated_at
    BEFORE UPDATE ON public.social_import_items
    FOR EACH ROW
    EXECUTE FUNCTION public.update_social_import_updated_at();

DROP TRIGGER IF EXISTS social_import_auth_sessions_updated_at ON public.social_import_auth_sessions;
CREATE TRIGGER social_import_auth_sessions_updated_at
    BEFORE UPDATE ON public.social_import_auth_sessions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_social_import_updated_at();

COMMIT;
