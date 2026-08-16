-- A webhook row is a delivery ledger, not a success marker. Processing state
-- lets a failed handler be retried instead of being acknowledged forever.
ALTER TABLE public.stripe_webhook_events
    ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'processed',
    ADD COLUMN IF NOT EXISTS attempts INTEGER NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS processing_started_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS processed_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS last_error TEXT;

-- Natural no-op on rerun (no rows left with a NULL/'pending' status); wrapped
-- in a DO block to keep top-level DML out of the migration (re-runnability
-- contract).
DO $$
BEGIN
  UPDATE public.stripe_webhook_events
  SET status = 'processed', processed_at = COALESCE(processed_at, received_at)
  WHERE status IS NULL OR status = 'pending';
END;
$$;

ALTER TABLE public.stripe_webhook_events
    DROP CONSTRAINT IF EXISTS stripe_webhook_events_status_check;
ALTER TABLE public.stripe_webhook_events
    ADD CONSTRAINT stripe_webhook_events_status_check
    CHECK (status IN ('pending', 'processing', 'processed', 'failed'));
