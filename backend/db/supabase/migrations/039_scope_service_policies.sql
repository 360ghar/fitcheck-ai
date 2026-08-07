-- FitCheck AI - Scope service-only policies to service_role
--
-- Migrations 030 (webhook dedupe ledgers apple_iap_events / google_rtdn_events)
-- and 038 (admin audit trail audit_events) created FOR ALL policies named
-- "Service role ..." WITHOUT a TO clause. A CREATE POLICY without TO applies
-- to PUBLIC, so any anon/authenticated JWT could read, forge, or delete the
-- webhook ledgers and the admin audit trail through PostgREST — the opposite
-- of what the policy names and comments claim.
--
-- This migration re-creates those policies with an explicit ``TO service_role``
-- (DROP + CREATE, idempotent via DROP POLICY IF EXISTS) and additionally
-- REVOKEs the browser roles for belt-and-braces. Only backend/service-only
-- tables are touched; tables that legitimately serve anon/authenticated
-- (001/002/005/007/009/012/017/023/031 etc.) are left untouched.
--
-- 038 as committed already carries the fix; re-running this over it is a
-- no-op (DROP + identical CREATE). Safe to re-run in the SQL editor.
--
-- Target: Supabase Postgres

BEGIN;

-- =============================================================================
-- apple_iap_events - App Store Server Notification V2 dedupe ledger (030)
-- =============================================================================

REVOKE ALL ON public.apple_iap_events FROM anon, authenticated;

DROP POLICY IF EXISTS "Service role manages apple iap events" ON public.apple_iap_events;
CREATE POLICY "Service role manages apple iap events"
    ON public.apple_iap_events FOR ALL
    TO service_role
    USING (TRUE)
    WITH CHECK (TRUE);

-- =============================================================================
-- google_rtdn_events - Play Real-time Developer Notification dedupe ledger (030)
-- =============================================================================

REVOKE ALL ON public.google_rtdn_events FROM anon, authenticated;

DROP POLICY IF EXISTS "Service role manages google rtdn events" ON public.google_rtdn_events;
CREATE POLICY "Service role manages google rtdn events"
    ON public.google_rtdn_events FOR ALL
    TO service_role
    USING (TRUE)
    WITH CHECK (TRUE);

-- =============================================================================
-- audit_events - admin audit trail (038)
-- =============================================================================

REVOKE ALL ON public.audit_events FROM anon, authenticated;

DROP POLICY IF EXISTS "Service role manages audit events" ON public.audit_events;
CREATE POLICY "Service role manages audit events"
    ON public.audit_events FOR ALL
    TO service_role
    USING (TRUE)
    WITH CHECK (TRUE);

COMMIT;
