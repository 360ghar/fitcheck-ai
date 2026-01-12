-- =============================================================================
-- Migration 007: Add Instagram Credentials Table
-- =============================================================================
-- This migration creates a table for storing encrypted Instagram credentials
-- to enable session-based scraping of public profiles.
-- =============================================================================

BEGIN;

-- =============================================================================
-- CREATE INSTAGRAM CREDENTIALS TABLE
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.user_instagram_credentials (
  -- Primary key referencing users table
  user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,

  -- Encrypted credentials (Fernet encryption)
  username_encrypted TEXT NOT NULL,
  password_encrypted TEXT NOT NULL,

  -- Encrypted session data (JSON string with cookies)
  session_data TEXT,

  -- Validity tracking
  is_valid BOOLEAN DEFAULT TRUE,
  last_used TIMESTAMPTZ,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add comments
COMMENT ON TABLE public.user_instagram_credentials IS 'Encrypted Instagram credentials for user session-based scraping';
COMMENT ON COLUMN public.user_instagram_credentials.username_encrypted IS 'Fernet-encrypted Instagram username';
COMMENT ON COLUMN public.user_instagram_credentials.password_encrypted IS 'Fernet-encrypted Instagram password';
COMMENT ON COLUMN public.user_instagram_credentials.session_data IS 'Fernet-encrypted JSON session cookies';
COMMENT ON COLUMN public.user_instagram_credentials.is_valid IS 'Whether the credentials are still valid';
COMMENT ON COLUMN public.user_instagram_credentials.last_used IS 'Last time the credentials were used successfully';

-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================

-- Enable RLS
ALTER TABLE public.user_instagram_credentials ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (for idempotency)
DROP POLICY IF EXISTS "Users can view own Instagram credentials" ON public.user_instagram_credentials;
DROP POLICY IF EXISTS "Users can insert own Instagram credentials" ON public.user_instagram_credentials;
DROP POLICY IF EXISTS "Users can update own Instagram credentials" ON public.user_instagram_credentials;
DROP POLICY IF EXISTS "Users can delete own Instagram credentials" ON public.user_instagram_credentials;

-- RLS Policies
CREATE POLICY "Users can view own Instagram credentials"
  ON public.user_instagram_credentials FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own Instagram credentials"
  ON public.user_instagram_credentials FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own Instagram credentials"
  ON public.user_instagram_credentials FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own Instagram credentials"
  ON public.user_instagram_credentials FOR DELETE
  USING (auth.uid() = user_id);

-- =============================================================================
-- TRIGGER FOR UPDATED_AT
-- =============================================================================

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS update_user_instagram_credentials_updated_at ON public.user_instagram_credentials;

-- Create trigger for automatic updated_at
CREATE TRIGGER update_user_instagram_credentials_updated_at
  BEFORE UPDATE ON public.user_instagram_credentials
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

COMMIT;
