-- Migration: Drop legacy date_of_birth column
-- The canonical field is birth_date, which was added in migration 014_add_user_dob.sql
-- This migration removes the redundant date_of_birth column after data migration
--
-- Re-runnable: the backfill UPDATE references date_of_birth, which this file
-- itself drops, so it is guarded by a column-existence check. On a rerun the
-- column is already gone and the block no-ops instead of failing (42703).

-- First, migrate any remaining data from date_of_birth to birth_date
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'users'
      AND column_name = 'date_of_birth'
  ) THEN
    UPDATE users
    SET birth_date = date_of_birth
    WHERE birth_date IS NULL AND date_of_birth IS NOT NULL;
  END IF;
END;
$$;

-- Drop the legacy column
ALTER TABLE users DROP COLUMN IF EXISTS date_of_birth;

-- Add comment to document the canonical field
COMMENT ON COLUMN users.birth_date IS 'User date of birth (canonical field). Use this instead of any legacy date_of_birth.';
