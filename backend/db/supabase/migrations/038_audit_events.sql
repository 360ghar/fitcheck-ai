-- FitCheck AI - Admin audit trail
--
-- Append-only audit log for admin mutations (admin panel M1, 2026-08-06 spec).
-- Every admin write endpoint records one row here (actor, action, entity,
-- payload, ip, user-agent). The table is service-role only: RLS is enabled,
-- the sole policy is explicitly scoped TO service_role, and anon/authenticated
-- are REVOKEd — browser roles can neither read nor write it. The backend
-- writes through the service client.
--
-- Idempotent (CREATE TABLE IF NOT EXISTS + DROP POLICY IF EXISTS guards):
-- safe to re-run in the SQL editor.
--
-- Target: Supabase Postgres

BEGIN;

CREATE TABLE IF NOT EXISTS public.audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT,
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    ip TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_audit_events_entity
    ON public.audit_events(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_events_actor_created
    ON public.audit_events(actor_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_events_created
    ON public.audit_events(created_at DESC);

-- RLS: service-role only. The sole policy carries an explicit
-- ``TO service_role`` clause and anon/authenticated are additionally
-- REVOKEd, so neither anon nor authenticated browser roles can read or
-- write the audit trail through PostgREST. (A CREATE POLICY without a TO
-- clause defaults to PUBLIC — the original bug this migration fixes.)
ALTER TABLE public.audit_events ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON public.audit_events FROM anon, authenticated;

DROP POLICY IF EXISTS "Service role manages audit events" ON public.audit_events;
CREATE POLICY "Service role manages audit events"
    ON public.audit_events FOR ALL
    TO service_role
    USING (TRUE)
    WITH CHECK (TRUE);

COMMENT ON TABLE public.audit_events IS
    'Append-only admin audit trail. Written by every admin mutation; read via /api/v1/admin/audit.';
COMMENT ON COLUMN public.audit_events.actor_id IS
    'Admin user who performed the action (NULL after user deletion).';
COMMENT ON COLUMN public.audit_events.payload IS
    'Structured before/after or metadata for the action (JSON).';

COMMIT;
