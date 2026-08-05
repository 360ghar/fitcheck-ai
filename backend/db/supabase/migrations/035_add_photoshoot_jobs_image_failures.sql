-- FitCheck AI - Photoshoot: retain per-index provider error detail on jobs.
--
-- Photoshoot 0-images RCA (2026-08-05): a provider failure that produced no
-- images now fails the job loudly (job_failed with the first retained error).
-- To keep that detail durable across process restarts (the row is hydrated
-- back into memory), the job row stores one entry per requested slot:
--   [{"index": 0, "error": "<provider detail, 500 chars max>"}]
--
-- Without this column, PostgREST rejects the payload key on every upsert /
-- terminal transition (PGRST204), breaking job creation entirely - apply
-- BEFORE deploying the 2026-08-05 backend.
--
-- Idempotent (ADD COLUMN IF NOT EXISTS): safe to re-run.
--
-- Target: Supabase Postgres

BEGIN;

ALTER TABLE public.photoshoot_jobs
    ADD COLUMN IF NOT EXISTS image_failures JSONB NOT NULL DEFAULT '[]'::jsonb;

COMMIT;
