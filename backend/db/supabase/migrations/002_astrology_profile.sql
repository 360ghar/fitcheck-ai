-- Add optional birth profile fields for astrology recommendations

BEGIN;

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS birth_date DATE,
  ADD COLUMN IF NOT EXISTS birth_time TIME,
  ADD COLUMN IF NOT EXISTS birth_place VARCHAR(255);

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
