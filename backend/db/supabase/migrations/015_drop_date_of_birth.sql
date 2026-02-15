-- Migration: Drop legacy date_of_birth column
-- The canonical field is birth_date, which was added in migration 014_add_user_dob.sql
-- This migration removes the redundant date_of_birth column after data migration

-- First, migrate any remaining data from date_of_birth to birth_date
UPDATE users
SET birth_date = date_of_birth
WHERE birth_date IS NULL AND date_of_birth IS NOT NULL;

-- Drop the legacy column
ALTER TABLE users DROP COLUMN IF EXISTS date_of_birth;

-- Add comment to document the canonical field
COMMENT ON COLUMN users.birth_date IS 'User date of birth (canonical field). Use this instead of any legacy date_of_birth.';
