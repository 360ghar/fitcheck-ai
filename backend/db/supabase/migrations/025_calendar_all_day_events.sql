-- Preserve the all-day setting used by the web and Flutter calendar clients.
ALTER TABLE public.calendar_events
    ADD COLUMN IF NOT EXISTS is_all_day BOOLEAN NOT NULL DEFAULT FALSE;
