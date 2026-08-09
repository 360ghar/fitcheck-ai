-- =============================================================================
-- Migration 014: Align Astrology Profile Columns
-- =============================================================================
-- Purpose:
-- 1) Ensure backend-expected columns exist on public.users
-- 2) Backfill from legacy date_of_birth if it was added earlier
-- =============================================================================

BEGIN;

-- Canonical columns used by backend + clients
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS birth_date DATE,
  ADD COLUMN IF NOT EXISTS birth_time TIME,
  ADD COLUMN IF NOT EXISTS birth_place VARCHAR(255);

-- Optional compatibility: some environments added date_of_birth earlier.
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS date_of_birth DATE;

-- Backfill canonical birth_date from legacy date_of_birth when needed.
-- Guarded by a column-existence check so the file stays re-runnable after
-- migration 015 drops date_of_birth (a rerun would otherwise hit 42703).
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'users'
      AND column_name = 'date_of_birth'
  ) THEN
    UPDATE public.users
    SET birth_date = date_of_birth
    WHERE birth_date IS NULL
      AND date_of_birth IS NOT NULL;
  END IF;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'users_birth_date_not_future'
      AND conrelid = 'public.users'::regclass
  ) THEN
    ALTER TABLE public.users
      ADD CONSTRAINT users_birth_date_not_future
      CHECK (birth_date IS NULL OR birth_date <= CURRENT_DATE);
  END IF;
END;
$$;

COMMIT;
