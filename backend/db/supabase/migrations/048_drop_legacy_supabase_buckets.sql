-- FitCheck AI - Drop legacy Supabase Storage buckets (R2-only storage)
--
-- FitCheck migrated file storage to a private S3-compatible bucket (Cloudflare
-- R2; backend/.env.example OBJECT_STORAGE_*). Migration 001 created the legacy
-- Supabase Storage buckets (fitcheck-images/items/outfits/avatars) with
-- public=true, and an earlier version of migration 046 flipped them private.
-- No app code reads or writes them anymore, so this migration drops them from
-- environments that still have them (dev/staging/prod where 001 ran before
-- the R2 cutover). Fresh environments never create them (001 no longer
-- inserts buckets), making this a no-op there.
--
-- Rerunnable: every statement is guarded - the storage schema and each bucket
-- are existence-checked, so re-running (or running on a fresh DB) is a no-op.
-- The storage schema check also keeps this safe on non-Supabase Postgres where
-- the storage extension/schema does not exist.
--
-- Pre-R2 rows that still store Supabase public URLs in image_url /
-- attachment_urls are unaffected: they are rescued to R2 keys at read time
-- (backend/app/services/storage_service.py key_from_path), and
-- scripts/backfill_storage_paths.py backfills their storage_path columns.
--
-- Target: Supabase Postgres

BEGIN;

-- Drop the four legacy buckets and any objects still tracked under them.
-- storage.objects is deleted first because rows reference their bucket.
DO $$
DECLARE
    legacy_bucket_ids TEXT[] := ARRAY['fitcheck-images', 'items', 'outfits', 'avatars'];
    b TEXT;
BEGIN
    IF to_regclass('storage.buckets') IS NULL THEN
        RAISE NOTICE 'storage schema not present; skipping legacy bucket drop';
        RETURN;
    END IF;

    FOREACH b IN ARRAY legacy_bucket_ids LOOP
        IF EXISTS (SELECT 1 FROM storage.buckets WHERE id = b) THEN
            IF to_regclass('storage.objects') IS NOT NULL THEN
                DELETE FROM storage.objects WHERE bucket_id = b;
            END IF;
            DELETE FROM storage.buckets WHERE id = b;
            RAISE NOTICE 'dropped legacy Supabase Storage bucket %', b;
        END IF;
    END LOOP;
END $$;

COMMIT;
