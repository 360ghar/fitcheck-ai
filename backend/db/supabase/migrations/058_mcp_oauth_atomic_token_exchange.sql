-- FitCheck AI - Atomic MCP OAuth token exchanges
--
-- Migration 057 created the OAuth artifacts. Its initial service consumed a
-- code and rotated a refresh token with separate read and write requests.
-- Concurrent /token requests could therefore both observe an unconsumed row
-- and mint independent token pairs. These RPCs serialize the artifact row
-- with FOR UPDATE and apply every related mutation in one transaction.
--
-- Target: Supabase Postgres

BEGIN;

CREATE OR REPLACE FUNCTION public.consume_mcp_oauth_authorization_code(
    p_code_hash TEXT,
    p_client_id TEXT,
    p_redirect_uri TEXT,
    p_code_challenge TEXT
)
RETURNS TABLE (
    outcome TEXT,
    user_id UUID,
    scope TEXT
) AS $$
DECLARE
    v_code public.mcp_oauth_auth_codes%ROWTYPE;
BEGIN
    SELECT * INTO v_code
    FROM public.mcp_oauth_auth_codes
    WHERE code_hash = p_code_hash
    FOR UPDATE;

    IF NOT FOUND OR v_code.used_at IS NOT NULL THEN
        RETURN QUERY SELECT 'invalid'::TEXT, NULL::UUID, NULL::TEXT;
        RETURN;
    END IF;

    IF v_code.expires_at <= NOW() THEN
        RETURN QUERY SELECT 'expired'::TEXT, NULL::UUID, NULL::TEXT;
        RETURN;
    END IF;

    IF v_code.client_id IS DISTINCT FROM p_client_id
       OR v_code.redirect_uri IS DISTINCT FROM p_redirect_uri THEN
        RETURN QUERY SELECT 'client_mismatch'::TEXT, NULL::UUID, NULL::TEXT;
        RETURN;
    END IF;

    IF v_code.code_challenge IS DISTINCT FROM p_code_challenge THEN
        RETURN QUERY SELECT 'pkce_failed'::TEXT, NULL::UUID, NULL::TEXT;
        RETURN;
    END IF;

    IF v_code.user_id IS NULL THEN
        RETURN QUERY SELECT 'unbound'::TEXT, NULL::UUID, NULL::TEXT;
        RETURN;
    END IF;

    UPDATE public.mcp_oauth_auth_codes
    SET used_at = NOW()
    WHERE id = v_code.id;

    RETURN QUERY SELECT 'consumed'::TEXT, v_code.user_id, v_code.scope;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.rotate_mcp_oauth_refresh_token(
    p_token_hash TEXT,
    p_replacement_id UUID,
    p_replacement_token_hash TEXT,
    p_replacement_expires_at TIMESTAMPTZ
)
RETURNS TABLE (
    outcome TEXT,
    user_id UUID,
    client_id TEXT,
    scope TEXT,
    family UUID
) AS $$
DECLARE
    v_token public.mcp_oauth_refresh_tokens%ROWTYPE;
BEGIN
    SELECT * INTO v_token
    FROM public.mcp_oauth_refresh_tokens
    WHERE token_hash = p_token_hash
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'invalid'::TEXT, NULL::UUID, NULL::TEXT, NULL::TEXT, NULL::UUID;
        RETURN;
    END IF;

    IF v_token.revoked_at IS NOT NULL THEN
        -- This lock is held until the replacement insert has committed, so a
        -- replay cannot revoke a family before its just-issued child exists.
        UPDATE public.mcp_oauth_refresh_tokens
        SET revoked_at = COALESCE(revoked_at, NOW())
        WHERE public.mcp_oauth_refresh_tokens.family = v_token.family;
        RETURN QUERY SELECT 'reused'::TEXT, NULL::UUID, NULL::TEXT, NULL::TEXT, v_token.family;
        RETURN;
    END IF;

    IF v_token.expires_at <= NOW() THEN
        RETURN QUERY SELECT 'expired'::TEXT, NULL::UUID, NULL::TEXT, NULL::TEXT, v_token.family;
        RETURN;
    END IF;

    UPDATE public.mcp_oauth_refresh_tokens
    SET revoked_at = NOW(),
        replaced_by = p_replacement_id
    WHERE id = v_token.id;

    INSERT INTO public.mcp_oauth_refresh_tokens (
        id,
        token_hash,
        user_id,
        client_id,
        scope,
        family,
        expires_at,
        revoked_at,
        replaced_by
    ) VALUES (
        p_replacement_id,
        p_replacement_token_hash,
        v_token.user_id,
        v_token.client_id,
        v_token.scope,
        v_token.family,
        p_replacement_expires_at,
        NULL,
        NULL
    );

    RETURN QUERY SELECT
        'rotated'::TEXT,
        v_token.user_id,
        v_token.client_id,
        v_token.scope,
        v_token.family;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE ALL ON FUNCTION public.consume_mcp_oauth_authorization_code(TEXT, TEXT, TEXT, TEXT)
    FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.rotate_mcp_oauth_refresh_token(TEXT, UUID, TEXT, TIMESTAMPTZ)
    FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.consume_mcp_oauth_authorization_code(TEXT, TEXT, TEXT, TEXT)
    TO service_role;
GRANT EXECUTE ON FUNCTION public.rotate_mcp_oauth_refresh_token(TEXT, UUID, TEXT, TIMESTAMPTZ)
    TO service_role;

COMMIT;
