-- =============================================================================
-- Migration 006: Add Embedding Columns to user_ai_settings
-- =============================================================================
-- This migration adds embedding-related usage tracking columns to support
-- the new embedding endpoints for similarity matching and semantic search.
-- =============================================================================

BEGIN;

-- =============================================================================
-- ADD EMBEDDING COLUMNS
-- =============================================================================

-- Add daily embedding count for rate limiting
ALTER TABLE public.user_ai_settings
  ADD COLUMN IF NOT EXISTS daily_embedding_count INTEGER DEFAULT 0;

-- Add total embeddings count for usage tracking
ALTER TABLE public.user_ai_settings
  ADD COLUMN IF NOT EXISTS total_embeddings INTEGER DEFAULT 0;

-- Add comments to new columns
COMMENT ON COLUMN public.user_ai_settings.daily_embedding_count IS 'Number of embedding generations today (for rate limiting)';
COMMENT ON COLUMN public.user_ai_settings.total_embeddings IS 'Total number of embedding generations (cumulative)';

-- =============================================================================
-- UPDATE DAILY RESET FUNCTION
-- =============================================================================

-- Update the function to also reset embedding counts
CREATE OR REPLACE FUNCTION public.reset_ai_daily_limits()
RETURNS TRIGGER AS $$
BEGIN
  -- If the last reset date is not today, reset the daily counts
  IF NEW.last_reset_date < CURRENT_DATE THEN
    NEW.daily_extraction_count := 0;
    NEW.daily_generation_count := 0;
    NEW.daily_embedding_count := 0;
    NEW.last_reset_date := CURRENT_DATE;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMIT;
