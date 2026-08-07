-- FitCheck AI - Admin roles + per-user quota override
--
-- Admin panel (M1 backend contract, 2026-08-06 spec):
--   * users.is_admin        - legacy boolean admin flag (kept for the existing
--                             blog.py verify_admin semantics and the admin app;
--                             new rows default FALSE).
--   * users.role            - RBAC role: 'user' (default) or one of
--                             super_admin | admin | ops | support | content_editor.
--                             The admin app never grants the plain 'user' role
--                             via UI; it is the default for normal users.
--   * users.custom_daily_quota - per-user override of the daily AI usage limit
--                             (NULL = use plan default). No existing override
--                             column exists in user_ai_settings (migration 003
--                             only has counters), so the override lives on
--                             users, read by the admin quotas endpoints.
--   * support_tickets.internal_notes - internal admin-only notes for the
--                             support-ticket workflow (admin feedback endpoint).
--                             There is no column in migration 009/034 for
--                             internal staff notes, so this migration adds one.
--
-- Idempotent (ADD COLUMN IF NOT EXISTS): safe to re-run in the SQL editor.
--
-- Target: Supabase Postgres

BEGIN;

ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS is_admin BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'user';

ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS custom_daily_quota INTEGER;

CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);

ALTER TABLE public.support_tickets
    ADD COLUMN IF NOT EXISTS internal_notes TEXT;

COMMENT ON COLUMN public.users.is_admin IS
    'Legacy admin flag (True grants admin role via the RBAC fallback). New rows default FALSE.';
COMMENT ON COLUMN public.users.role IS
    'RBAC role: user (default), super_admin, admin, ops, support, content_editor.';
COMMENT ON COLUMN public.users.custom_daily_quota IS
    'Per-user daily AI usage limit override (NULL = plan default). Set by admin quota endpoints.';
COMMENT ON COLUMN public.support_tickets.internal_notes IS
    'Internal staff-only notes on a support ticket (never shown to end users).';

COMMIT;
