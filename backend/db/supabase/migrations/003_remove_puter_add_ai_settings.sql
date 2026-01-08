-- =============================================================================
-- Migration 003: Remove Puter Integration, Add AI Provider Settings
-- =============================================================================
-- This migration:
-- 1. Removes Puter-related columns from users table
-- 2. Creates user_ai_settings table for per-user AI provider configuration
-- =============================================================================

BEGIN;

-- =============================================================================
-- REMOVE PUTER COLUMNS FROM USERS TABLE
-- =============================================================================

-- Drop the unique index on puter_uuid if it exists
DROP INDEX IF EXISTS idx_users_puter_uuid_unique;

-- Remove Puter-related columns from users table
ALTER TABLE public.users
  DROP COLUMN IF EXISTS puter_token,
  DROP COLUMN IF EXISTS puter_username,
  DROP COLUMN IF EXISTS puter_email,
  DROP COLUMN IF EXISTS puter_uuid,
  DROP COLUMN IF EXISTS puter_linked_at;

-- =============================================================================
-- CREATE USER AI SETTINGS TABLE
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.user_ai_settings (
  -- Primary key referencing users table
  user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,

  -- Provider-level configuration (JSON structure per provider)
  -- Format: {
  --   "gemini": {"api_url": "...", "api_key_encrypted": "...", "model": "..."},
  --   "openai": {"api_url": "...", "api_key_encrypted": "...", "model": "..."},
  --   "custom": {"api_url": "...", "api_key_encrypted": "...", "model": "..."}
  -- }
  provider_configs JSONB DEFAULT '{}'::jsonb,

  -- Default provider to use (gemini, openai, custom)
  default_provider VARCHAR(50) DEFAULT 'gemini',

  -- Rate limiting tracking (reset daily)
  daily_extraction_count INTEGER DEFAULT 0,
  daily_generation_count INTEGER DEFAULT 0,
  last_reset_date DATE DEFAULT CURRENT_DATE,

  -- Total usage tracking (cumulative)
  total_extractions INTEGER DEFAULT 0,
  total_generations INTEGER DEFAULT 0,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add comment to table
COMMENT ON TABLE public.user_ai_settings IS 'Per-user AI provider configuration and usage tracking';

-- Add comments to columns
COMMENT ON COLUMN public.user_ai_settings.provider_configs IS 'JSON object containing per-provider configuration (api_url, encrypted api_key, model settings)';
COMMENT ON COLUMN public.user_ai_settings.default_provider IS 'Default AI provider: gemini, openai, or custom';
COMMENT ON COLUMN public.user_ai_settings.daily_extraction_count IS 'Number of item extractions today (for rate limiting)';
COMMENT ON COLUMN public.user_ai_settings.daily_generation_count IS 'Number of image generations today (for rate limiting)';
COMMENT ON COLUMN public.user_ai_settings.last_reset_date IS 'Date when daily counts were last reset';

-- Create index for fast lookups
CREATE INDEX IF NOT EXISTS idx_user_ai_settings_user_id ON public.user_ai_settings(user_id);

-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================

-- Enable RLS on the table
ALTER TABLE public.user_ai_settings ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (for idempotency)
DROP POLICY IF EXISTS "Users can view own AI settings" ON public.user_ai_settings;
DROP POLICY IF EXISTS "Users can insert own AI settings" ON public.user_ai_settings;
DROP POLICY IF EXISTS "Users can update own AI settings" ON public.user_ai_settings;
DROP POLICY IF EXISTS "Users can delete own AI settings" ON public.user_ai_settings;

-- Create RLS policies
CREATE POLICY "Users can view own AI settings"
  ON public.user_ai_settings FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own AI settings"
  ON public.user_ai_settings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own AI settings"
  ON public.user_ai_settings FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own AI settings"
  ON public.user_ai_settings FOR DELETE
  USING (auth.uid() = user_id);

-- =============================================================================
-- TRIGGER FOR UPDATED_AT
-- =============================================================================

-- Create or replace the trigger function (may already exist from previous migrations)
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS update_user_ai_settings_updated_at ON public.user_ai_settings;

-- Create trigger for automatic updated_at
CREATE TRIGGER update_user_ai_settings_updated_at
  BEFORE UPDATE ON public.user_ai_settings
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- =============================================================================
-- FUNCTION TO RESET DAILY LIMITS
-- =============================================================================

-- Function to reset daily limits if date has changed
CREATE OR REPLACE FUNCTION public.reset_ai_daily_limits()
RETURNS TRIGGER AS $$
BEGIN
  -- If the last reset date is not today, reset the daily counts
  IF NEW.last_reset_date < CURRENT_DATE THEN
    NEW.daily_extraction_count := 0;
    NEW.daily_generation_count := 0;
    NEW.last_reset_date := CURRENT_DATE;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trigger_reset_ai_daily_limits ON public.user_ai_settings;

-- Create trigger to auto-reset daily limits on access
CREATE TRIGGER trigger_reset_ai_daily_limits
  BEFORE UPDATE ON public.user_ai_settings
  FOR EACH ROW
  EXECUTE FUNCTION public.reset_ai_daily_limits();

COMMIT;
