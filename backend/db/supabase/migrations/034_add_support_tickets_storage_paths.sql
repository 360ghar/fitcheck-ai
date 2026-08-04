-- FitCheck AI - Track feedback attachment storage paths for orphan cleanup
-- and account deletion.
--
-- Railway Bucket migration (2026-08-04-railway-bucket-migration-contract.md):
-- buckets are PRIVATE and the DB stores durable bucket keys, never public URLs.
-- support_tickets.attachment_urls may hold SHORT-LIVED presigned GET URLs for
-- display only; they expire and are not suitable for deletion/cleanup.
--
-- This column records the durable object keys (storage_path) for each ticket's
-- attachments so account deletion and the orphan inventory can locate and
-- delete the underlying objects. The values are BUCKET KEYS (not URLs).
--
-- Idempotent (ADD COLUMN IF NOT EXISTS): safe to re-run.
--
-- Target: Supabase Postgres

BEGIN;

ALTER TABLE public.support_tickets
    ADD COLUMN IF NOT EXISTS attachment_storage_paths TEXT[] DEFAULT '{}';

COMMIT;