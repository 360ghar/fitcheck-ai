-- =============================================================================
-- Migration 004: Add Gender to Users Table
-- =============================================================================
-- Purpose: Add optional gender field for AI image generation personalization
-- Values: 'male', 'female', 'non_binary', 'prefer_not_to_say', NULL
-- =============================================================================

BEGIN;

-- Add gender column to users table
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS gender VARCHAR(20) DEFAULT NULL;

-- Add constraint to validate gender values
ALTER TABLE public.users
  ADD CONSTRAINT users_gender_check CHECK (
    gender IS NULL OR gender IN ('male', 'female', 'non_binary', 'prefer_not_to_say')
  );

COMMIT;
