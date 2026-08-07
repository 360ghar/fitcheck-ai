-- FitCheck AI - Widen the served-image URL columns from VARCHAR(500) to TEXT.
--
-- WHY (Cloudflare R2 cutover, 2026-08-05-railway-egress-rca.md):
-- These columns are written with the LIVE presigned GET URL at upload time
-- (items.py / outfits.py / users.py) even though the durable reference is
-- storage_path and read paths always re-materialize a fresh URL. Nothing
-- validates length before the INSERT, so an over-long URL is a hard Postgres
-- 22001 (value too long) that fails the upload.
--
-- Measured presigned URL lengths for one `{uuid4-user}/items/{32hex}.webp` key
-- at OBJECT_STORAGE_PRESIGN_TTL=3600:
--     Railway (t3.storageapi.dev)                          397 chars
--     R2 (32-hex account host), bucket "fitcheck"           429 chars
--     R2, bucket "fitcheck-images"                          436 chars
--     R2, bucket "fitcheck-images-production"               447 chars
-- R2's 32-hex account subdomain costs ~35 chars over Railway's host, cutting
-- the headroom under the 500 cap from ~100 to ~55. Still fits, but the margin
-- is now thin enough that a longer bucket name, a session-token credential
-- (X-Amz-Security-Token), or one extra signed query parameter (e.g.
-- response-content-disposition for a download) overflows it and breaks uploads.
--
-- TEXT and VARCHAR(n) are the same storage in Postgres (varlena) and TEXT has
-- no length check, so this only removes a constraint. No data is rewritten and
-- no index is invalidated; ALTER TYPE to a less-restrictive type of the same
-- underlying representation does not rewrite the table.
--
-- items.source_image_url, social_import_*.generated_image_url and
-- support_tickets.attachment_urls are already TEXT. outfit_shares.share_url
-- stays VARCHAR(255) on purpose: it is a short share slug, not a bucket URL.
--
-- Idempotent: ALTER ... TYPE TEXT is a no-op when the column is already TEXT.
--
-- Target: Supabase Postgres

BEGIN;

ALTER TABLE public.users
    ALTER COLUMN avatar_url TYPE TEXT;

ALTER TABLE public.item_images
    ALTER COLUMN image_url TYPE TEXT,
    ALTER COLUMN thumbnail_url TYPE TEXT;

ALTER TABLE public.outfit_images
    ALTER COLUMN image_url TYPE TEXT,
    ALTER COLUMN thumbnail_url TYPE TEXT;

COMMIT;

-- Verify:
--   SELECT table_name, column_name, data_type, character_maximum_length
--   FROM information_schema.columns
--   WHERE table_schema = 'public'
--     AND column_name IN ('avatar_url', 'image_url', 'thumbnail_url')
--   ORDER BY table_name, column_name;
-- Expect data_type = 'text' and character_maximum_length = NULL for all five.
