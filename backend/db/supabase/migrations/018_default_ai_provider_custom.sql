-- =============================================================================
-- Migration 018: Drop Gemini as a Default AI Provider Option
-- =============================================================================
-- Gemini is no longer a selectable chat/vision/image provider (it remains the
-- embeddings backend only, unrelated to this column). This migration:
-- 1. Moves any existing user rows still defaulted to 'gemini' onto 'custom'
-- 2. Fixes the column's own default, which predates the Agnes ('custom') migration
-- =============================================================================

BEGIN;

UPDATE public.user_ai_settings
  SET default_provider = 'custom'
  WHERE default_provider = 'gemini';

ALTER TABLE public.user_ai_settings
  ALTER COLUMN default_provider SET DEFAULT 'custom';

COMMENT ON COLUMN public.user_ai_settings.default_provider IS 'Default AI provider: openai or custom';

COMMIT;
