-- FitCheck AI - MCP OAuth 2.1 gateway storage
--
-- Backs the OAuth layer in front of the MCP server (docs/references/mcp.md):
-- dynamic client registration (ChatGPT Apps SDK requires OAuth 2.1 + DCR),
-- authorization codes with PKCE, and refresh tokens with rotation.
-- Identity comes from Supabase Auth (frontend bridge); these tables only
-- track OAuth artifacts.
--
-- Service-role only, same policy shape as migration 038 (audit_events): RLS
-- enabled, sole policy scoped TO service_role, anon/authenticated REVOKEd.
-- All hashes are SHA-256 — raw codes/refresh tokens are never stored.
--
-- Idempotent (IF NOT EXISTS / DROP POLICY IF EXISTS guards): safe to re-run.
--
-- Target: Supabase Postgres

BEGIN;

-- Registered MCP clients (public clients only: PKCE, no secret).
CREATE TABLE IF NOT EXISTS public.mcp_oauth_clients (
    client_id TEXT PRIMARY KEY,
    client_name TEXT NOT NULL DEFAULT 'unknown',
    redirect_uris JSONB NOT NULL DEFAULT '[]'::jsonb,
    scope TEXT NOT NULL DEFAULT 'mcp',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Authorization-code flow: pending (txn_state set, user NULL) → completed
-- (code_hash set, user bound) → consumed (used_at set). One row per flow;
-- txn_state is nulled on completion so a state value cannot be replayed.
CREATE TABLE IF NOT EXISTS public.mcp_oauth_auth_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    txn_state TEXT,
    code_hash TEXT,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    client_id TEXT NOT NULL,
    redirect_uri TEXT NOT NULL,
    scope TEXT NOT NULL DEFAULT 'mcp',
    code_challenge TEXT NOT NULL,
    challenge_method TEXT NOT NULL DEFAULT 'S256',
    expires_at TIMESTAMPTZ NOT NULL,
    used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Refresh tokens (rotated on every use; reuse of a revoked token revokes the
-- whole family — RFC 6819 replay mitigation).
CREATE TABLE IF NOT EXISTS public.mcp_oauth_refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token_hash TEXT NOT NULL UNIQUE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    client_id TEXT NOT NULL,
    scope TEXT NOT NULL DEFAULT 'mcp',
    family UUID NOT NULL DEFAULT gen_random_uuid(),
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    replaced_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
-- txn_state is UNIQUE among pending rows: a client reusing a state value must
-- not leave two resolvable pending rows (complete_authorization uses
-- maybe_single). The service additionally deletes stale same-state rows
-- before inserting; this index is the DB-level backstop.
CREATE UNIQUE INDEX IF NOT EXISTS uq_mcp_oauth_codes_state
    ON public.mcp_oauth_auth_codes(txn_state) WHERE txn_state IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_mcp_oauth_codes_hash
    ON public.mcp_oauth_auth_codes(code_hash) WHERE code_hash IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_mcp_oauth_codes_expiry
    ON public.mcp_oauth_auth_codes(expires_at);
CREATE INDEX IF NOT EXISTS idx_mcp_oauth_refresh_family
    ON public.mcp_oauth_refresh_tokens(family);
CREATE INDEX IF NOT EXISTS idx_mcp_oauth_refresh_user
    ON public.mcp_oauth_refresh_tokens(user_id);

-- RLS: service-role only (same shape as migration 038).
ALTER TABLE public.mcp_oauth_clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mcp_oauth_auth_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mcp_oauth_refresh_tokens ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON public.mcp_oauth_clients FROM anon, authenticated;
REVOKE ALL ON public.mcp_oauth_auth_codes FROM anon, authenticated;
REVOKE ALL ON public.mcp_oauth_refresh_tokens FROM anon, authenticated;

DROP POLICY IF EXISTS "Service role manages mcp oauth clients" ON public.mcp_oauth_clients;
CREATE POLICY "Service role manages mcp oauth clients"
    ON public.mcp_oauth_clients FOR ALL
    TO service_role
    USING (TRUE)
    WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Service role manages mcp oauth codes" ON public.mcp_oauth_auth_codes;
CREATE POLICY "Service role manages mcp oauth codes"
    ON public.mcp_oauth_auth_codes FOR ALL
    TO service_role
    USING (TRUE)
    WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Service role manages mcp oauth refresh tokens" ON public.mcp_oauth_refresh_tokens;
CREATE POLICY "Service role manages mcp oauth refresh tokens"
    ON public.mcp_oauth_refresh_tokens FOR ALL
    TO service_role
    USING (TRUE)
    WITH CHECK (TRUE);

COMMENT ON TABLE public.mcp_oauth_clients IS
    'MCP OAuth clients created via dynamic registration (RFC 7591). Public clients only: PKCE, no secrets.';
COMMENT ON TABLE public.mcp_oauth_auth_codes IS
    'Authorization-code flow state: pending → completed (code_hash) → consumed. Codes are SHA-256 hashed and single-use.';
COMMENT ON TABLE public.mcp_oauth_refresh_tokens IS
    'MCP refresh tokens (SHA-256 hashed), rotated on use with family revocation on replay.';

COMMIT;
