-- =============================================================================
-- Migration 019: Add source_image columns to public.items
-- =============================================================================
-- Stores a reference to the ORIGINAL source photo that an item was extracted
-- from, so the image-generation pipeline can re-fetch it as a reference image
-- and reproduce the exact garment (pattern, texture, hardware, branding).
-- Decouples source bytes from process memory entirely (no OOM risk) and makes
-- the source reusable for re-generation, audit, and UI display.
--
-- Both columns are nullable so existing items continue to work unchanged.
-- Multiple items extracted from the same photo share the same source_image_url.
-- =============================================================================

BEGIN;

ALTER TABLE public.items
  ADD COLUMN IF NOT EXISTS source_image_url TEXT,
  ADD COLUMN IF NOT EXISTS source_image_storage_path TEXT;

COMMENT ON COLUMN public.items.source_image_url IS
  'Public URL of the original source photo this item was extracted from. Used as reference image for product-image generation.';
COMMENT ON COLUMN public.items.source_image_storage_path IS
  'Supabase Storage path of the source photo (for cleanup when item is deleted).';

COMMIT;
