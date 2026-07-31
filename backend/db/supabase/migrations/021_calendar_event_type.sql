-- Preserve the event category used by calendar markers and screen readers.
ALTER TABLE public.calendar_events
    ADD COLUMN IF NOT EXISTS event_type VARCHAR(30) NOT NULL DEFAULT 'other';
