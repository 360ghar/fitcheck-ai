"""End-to-end OAuth 2.1 gateway tests (DCR → authorize → complete → token →
refresh rotation → MCP tool call with the issued access token).

Uses the real app + FakeDB via the standard api-layer overrides. Supabase
identity is faked at the one seam the bridge provides: the
``decode_supabase_token`` callable the route passes into the service.
"""

from __future__ import annotations

import base64
import hashlib
import time

import httpx
import jwt
import pytest

import app.api.v1.oauth as oauth_module
from app.services import mcp_oauth_service as oauth_service
from tests.factories.row_factories import user_row

pytestmark = pytest.mark.api

CHATGPT_REDIRECT = "https://chatgpt.com/connector_platform_oauth_redirect"


@pytest.fixture
def oauth_enabled(monkeypatch):
    """Turn the gateway on with a ChatGPT-style allowlist."""
    monkeypatch.setattr(oauth_service.settings, "MCP_OAUTH_ISSUER", "https://api.test/api/v1/oauth")
    monkeypatch.setattr(oauth_service.settings, "PUBLIC_API_BASE_URL", "https://api.test")
    monkeypatch.setattr(
        oauth_service.settings, "MCP_REDIRECT_URI_ALLOWLIST", "https://chatgpt.com/connector_platform_oauth_redirect"
    )
    yield


def _verifier_and_challenge(verifier: str) -> tuple[str, str]:
    digest = hashlib.sha256(verifier.encode("ascii")).digest()
    challenge = base64.urlsafe_b64encode(digest).rstrip(b"=").decode("ascii")
    return verifier, challenge


# ---------------------------------------------------------------------------
# Discovery + registration
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_discovery_metadata_served_when_enabled(oauth_enabled, async_client: httpx.AsyncClient):
    response = await async_client.get("/api/v1/oauth/.well-known/oauth-authorization-server")
    assert response.status_code == 200
    body = response.json()
    assert body["issuer"] == "https://api.test/api/v1/oauth"
    assert body["code_challenge_methods_supported"] == ["S256"]
    assert body["grant_types_supported"] == ["authorization_code", "refresh_token"]

    resource = await async_client.get("/api/v1/oauth/.well-known/oauth-protected-resource")
    assert resource.status_code == 200
    assert resource.json()["resource"] == "https://api.test/mcp"


@pytest.mark.asyncio
async def test_dcr_rejects_unlisted_redirect(oauth_enabled, async_client: httpx.AsyncClient, db):
    response = await async_client.post(
        "/api/v1/oauth/register",
        json={"redirect_uris": ["https://evil.example/callback"], "client_name": "evil"},
    )
    assert response.status_code == 400
    # Global HTTPException handler nests the detail dict under "error".
    assert response.json()["error"]["error"] == "invalid_client_metadata"


@pytest.mark.asyncio
async def test_dcr_rejects_redirect_lookalike(oauth_enabled, async_client: httpx.AsyncClient):
    response = await async_client.post(
        "/api/v1/oauth/register",
        json={
            "redirect_uris": [
                "https://chatgpt.com/connector_platform_oauth_redirect.evil/callback"
            ],
            "client_name": "lookalike",
        },
    )
    assert response.status_code == 400


@pytest.mark.asyncio
async def test_dcr_registers_public_client(oauth_enabled, async_client: httpx.AsyncClient, db):
    response = await async_client.post(
        "/api/v1/oauth/register",
        json={"redirect_uris": [CHATGPT_REDIRECT], "client_name": "ChatGPT"},
    )
    assert response.status_code == 200
    body = response.json()
    assert body["client_id"].startswith("mcp_")
    assert body["token_endpoint_auth_method"] == "none"
    assert len(db.rows["mcp_oauth_clients"]) == 1


# ---------------------------------------------------------------------------
# Full authorization-code flow
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_full_code_flow_issues_and_rotates_tokens(
    oauth_enabled, async_client: httpx.AsyncClient, db, monkeypatch
):
    register = await async_client.post(
        "/api/v1/oauth/register",
        json={"redirect_uris": [CHATGPT_REDIRECT], "client_name": "ChatGPT"},
    )
    client_id = register.json()["client_id"]

    verifier, challenge = _verifier_and_challenge("test-verifier-string-with-enough-entropy-123456")
    authorize = await async_client.get(
        "/api/v1/oauth/authorize",
        params={
            "response_type": "code",
            "client_id": client_id,
            "redirect_uri": CHATGPT_REDIRECT,
            "code_challenge": challenge,
            "code_challenge_method": "S256",
            "state": "txn-state-1",
        },
    )
    assert authorize.status_code == 302
    assert "/oauth/bridge?state=txn-state-1" in authorize.headers["location"]

    # The frontend bridge binds a (faked) Supabase session.
    user = user_row()
    db.rows["users"] = [user]
    monkeypatch.setattr(oauth_module, "decode_supabase_token", lambda token: {"sub": user["id"]})
    complete = await async_client.post(
        "/api/v1/oauth/authorize/complete",
        json={"state": "txn-state-1", "access_token": "supabase-jwt"},
    )
    assert complete.status_code == 200
    redirect_url = complete.json()["redirect"]
    assert redirect_url.startswith(CHATGPT_REDIRECT)
    code = redirect_url.split("code=")[1].split("&")[0]

    token_response = await async_client.post(
        "/api/v1/oauth/token",
        data={
            "grant_type": "authorization_code",
            "client_id": client_id,
            "code": code,
            "redirect_uri": CHATGPT_REDIRECT,
            "code_verifier": verifier,
        },
    )
    assert token_response.status_code == 200
    tokens = token_response.json()
    assert tokens["token_type"] == "bearer"
    assert tokens["refresh_token"]

    # Code is single-use.
    replay = await async_client.post(
        "/api/v1/oauth/token",
        data={
            "grant_type": "authorization_code",
            "client_id": client_id,
            "code": code,
            "redirect_uri": CHATGPT_REDIRECT,
            "code_verifier": verifier,
        },
    )
    assert replay.status_code == 400
    assert replay.json()["error"] == "invalid_grant"

    # Refresh rotation: first use works and mints a NEW refresh token.
    first_refresh = tokens["refresh_token"]
    rotate = await async_client.post(
        "/api/v1/oauth/token",
        data={"grant_type": "refresh_token", "client_id": client_id, "refresh_token": first_refresh},
    )
    assert rotate.status_code == 200
    new_refresh = rotate.json()["refresh_token"]
    assert new_refresh != first_refresh

    # Replay of the rotated-away token → 400 and the whole family dies.
    reuse = await async_client.post(
        "/api/v1/oauth/token",
        data={"grant_type": "refresh_token", "client_id": client_id, "refresh_token": first_refresh},
    )
    assert reuse.status_code == 400
    assert reuse.json()["error"] == "invalid_grant"

    after = await async_client.post(
        "/api/v1/oauth/token",
        data={"grant_type": "refresh_token", "client_id": client_id, "refresh_token": new_refresh},
    )
    assert after.status_code == 400  # family revoked by reuse detection


@pytest.mark.asyncio
async def test_authorize_state_reuse_replaces_pending_row(
    oauth_enabled, async_client: httpx.AsyncClient, db
):
    """A client that re-sends /authorize with the same `state` must end with
    exactly ONE pending row (complete resolves it via maybe_single)."""
    register = await async_client.post(
        "/api/v1/oauth/register",
        json={"redirect_uris": [CHATGPT_REDIRECT], "client_name": "ChatGPT"},
    )
    client_id = register.json()["client_id"]
    _, challenge = _verifier_and_challenge("state-reuse-verifier-1234567890")
    params = {
        "response_type": "code",
        "client_id": client_id,
        "redirect_uri": CHATGPT_REDIRECT,
        "code_challenge": challenge,
        "state": "reused-state",
    }
    first = await async_client.get("/api/v1/oauth/authorize", params=params)
    assert first.status_code == 302
    second = await async_client.get("/api/v1/oauth/authorize", params=params)
    assert second.status_code == 302

    pending = [
        row
        for row in db.rows.get("mcp_oauth_auth_codes", [])
        if row.get("txn_state") == "reused-state"
    ]
    assert len(pending) == 1


@pytest.mark.asyncio
async def test_pkce_failure_rejects_exchange(oauth_enabled, async_client: httpx.AsyncClient, db, monkeypatch):
    register = await async_client.post(
        "/api/v1/oauth/register",
        json={"redirect_uris": [CHATGPT_REDIRECT], "client_name": "ChatGPT"},
    )
    client_id = register.json()["client_id"]
    _, challenge = _verifier_and_challenge("correct-verifier-1234567890abcdef")
    await async_client.get(
        "/api/v1/oauth/authorize",
        params={
            "response_type": "code",
            "client_id": client_id,
            "redirect_uri": CHATGPT_REDIRECT,
            "code_challenge": challenge,
            "state": "txn-pkce",
        },
    )
    user = user_row()
    db.rows["users"] = [user]
    monkeypatch.setattr(oauth_module, "decode_supabase_token", lambda token: {"sub": user["id"]})
    complete = await async_client.post(
        "/api/v1/oauth/authorize/complete",
        json={"state": "txn-pkce", "access_token": "supabase-jwt"},
    )
    code = complete.json()["redirect"].split("code=")[1].split("&")[0]

    response = await async_client.post(
        "/api/v1/oauth/token",
        data={
            "grant_type": "authorization_code",
            "client_id": client_id,
            "code": code,
            "redirect_uri": CHATGPT_REDIRECT,
            "code_verifier": "WRONG-verifier-9876543210-fedcba",
        },
    )
    assert response.status_code == 400
    assert response.json()["error"] == "invalid_grant"
    assert "PKCE" in response.json()["error_description"]


@pytest.mark.asyncio
async def test_authorize_rejects_unsupported_scope(oauth_enabled, async_client: httpx.AsyncClient):
    _, challenge = _verifier_and_challenge("scope-verifier-1234567890abcdef")

    response = await async_client.get(
        "/api/v1/oauth/authorize",
        params={
            "response_type": "code",
            "client_id": "unused-client-id",
            "redirect_uri": CHATGPT_REDIRECT,
            "code_challenge": challenge,
            "scope": "mcp profile",
        },
    )

    assert response.status_code == 400
    assert response.json() == {
        "error": "invalid_scope",
        "error_description": "unsupported scope",
    }


# ---------------------------------------------------------------------------
# MCP tokens authenticate loopback tool calls (the double-gate fix)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_mcp_access_token_authenticates_real_route(oauth_enabled, async_client: httpx.AsyncClient, db):
    """An MCP-issued JWT (not a Supabase JWT) must pass verify_token via the
    MCP branch and authorize a normal API call — no dependency overrides."""
    user = user_row()
    db.rows["users"] = [user]

    minted = oauth_service.mint_access_token(user["id"], "mcp_client")
    response = await async_client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {minted['token']}"},
    )
    assert response.status_code == 200
    assert response.json()["data"]["id"] == user["id"]


def test_minted_mcp_access_token_includes_expiry(oauth_enabled):
    minted = oauth_service.mint_access_token("user-id", "mcp_client")
    claims = jwt.decode(minted["token"], options={"verify_signature": False})

    assert claims["exp"] == claims["iat"] + oauth_service.ACCESS_TOKEN_TTL_SECONDS


def test_service_rejects_mcp_access_token_without_expiry(oauth_enabled):
    token = jwt.encode(
        {
            "iss": oauth_service.issuer(),
            "sub": "user-id",
            "aud": oauth_service.MCP_TOKEN_AUDIENCE,
            "typ": oauth_service.MCP_TOKEN_TYPE,
            "iat": int(time.time()),
        },
        oauth_service.signing_key(),
        algorithm="HS256",
    )

    with pytest.raises(jwt.MissingRequiredClaimError):
        oauth_service.verify_access_token(token)


@pytest.mark.asyncio
async def test_real_route_rejects_mcp_access_token_without_expiry(
    oauth_enabled, async_client: httpx.AsyncClient, db
):
    user = user_row()
    db.rows["users"] = [user]
    token = jwt.encode(
        {
            "iss": oauth_service.issuer(),
            "sub": user["id"],
            "aud": oauth_service.MCP_TOKEN_AUDIENCE,
            "typ": oauth_service.MCP_TOKEN_TYPE,
            "iat": int(time.time()),
        },
        oauth_service.signing_key(),
        algorithm="HS256",
    )

    response = await async_client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 401


@pytest.mark.asyncio
async def test_garbage_token_still_401s(oauth_enabled, async_client: httpx.AsyncClient):
    response = await async_client.get(
        "/api/v1/users/me",
        headers={"Authorization": "Bearer not-a-real-token"},
    )
    assert response.status_code == 401
