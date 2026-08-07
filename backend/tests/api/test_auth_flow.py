"""End-to-end auth contract tests through the real app with the REAL
``verify_token`` dependency: register → login → authenticated request,
plus the 401/403 boundary matrix.

The Supabase Auth calls are mocked (``anon_db`` fixture); everything else —
token verification, dependency wiring, middleware, handlers, envelopes —
runs for real.
"""

from __future__ import annotations

from types import SimpleNamespace
from unittest.mock import Mock

import pytest

from app.api.v1 import auth as auth_module
from tests.factories.row_factories import user_row
from tests.utils.assertions import assert_error_envelope, assert_success_envelope
from tests.utils.auth_helpers import auth_header, make_hs256_token

USER_ID = "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"


def _auth_response(user_id: str = USER_ID, email: str = "ada@example.com"):
    """A supabase-py shaped sign_up/sign_in response."""
    user = Mock(id=user_id, email=email, user_metadata={"full_name": "Ada Lovelace"})
    session = Mock(access_token="mock-access-token", refresh_token="mock-refresh-token")
    return SimpleNamespace(user=user, session=session)


# ---------------------------------------------------------------------------
# The full happy-path flow
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_register_login_me_flow(async_client, db, anon_db):
    anon_db.auth.sign_up.return_value = _auth_response()

    register = await async_client.post(
        "/api/v1/auth/register",
        json={"email": "ada@example.com", "password": "Str0ng!Pass", "full_name": "Ada Lovelace"},
    )
    body = assert_success_envelope(register, status_code=201)
    assert body["data"]["access_token"] == "mock-access-token"
    assert body["data"]["user"]["id"] == USER_ID
    # Registration persisted the profile through the real handler path.
    assert db.rows["users"][0]["id"] == USER_ID
    assert db.rows["user_preferences"][0]["user_id"] == USER_ID

    # Login: same user signs in; the profile read comes from the same FakeDB.
    anon_db.auth.sign_in_with_password.return_value = _auth_response()
    login = await async_client.post(
        "/api/v1/auth/login",
        json={"email": "ada@example.com", "password": "Str0ng!Pass"},
    )
    login_body = assert_success_envelope(login, status_code=200)
    assert login_body["data"]["access_token"] == "mock-access-token"

    # /users/me with a REAL signed token matching the created profile.
    token = make_hs256_token(sub=USER_ID, email="ada@example.com")
    me = await async_client.get("/api/v1/users/me", headers=auth_header(token))

    me_body = assert_success_envelope(me, status_code=200)
    assert me_body["data"]["id"] == USER_ID
    assert me_body["data"]["email"] == "ada@example.com"


@pytest.mark.asyncio
async def test_register_rejects_duplicate_email(async_client, db, anon_db):
    from supabase_auth.errors import AuthApiError

    anon_db.auth.sign_up.side_effect = AuthApiError(
        "User already registered", 400, "user_already_exists"
    )

    response = await async_client.post(
        "/api/v1/auth/register",
        json={"email": "dup@example.com", "password": "Str0ng!Pass"},
    )

    assert_error_envelope(response, status_code=409, code="AUTH_EMAIL_EXISTS")


@pytest.mark.asyncio
async def test_login_invalid_credentials(async_client, db, anon_db):
    from supabase_auth.errors import AuthApiError

    anon_db.auth.sign_in_with_password.side_effect = AuthApiError(
        "Invalid login credentials", 400, "invalid_credentials"
    )

    response = await async_client.post(
        "/api/v1/auth/login",
        json={"email": "ada@example.com", "password": "wrong-password"},
    )

    assert response.status_code == 401


# ---------------------------------------------------------------------------
# 401 boundary matrix (real verify_token)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_protected_route_requires_bearer_token(async_client, db):
    response = await async_client.get("/api/v1/users/me")

    assert_error_envelope(response, status_code=401, code="HTTP_ERROR")


@pytest.mark.asyncio
async def test_protected_route_rejects_malformed_token(async_client, db):
    response = await async_client.get(
        "/api/v1/users/me", headers=auth_header("not-a-jwt-at-all")
    )

    assert_error_envelope(response, status_code=401, code="HTTP_ERROR")


@pytest.mark.asyncio
async def test_protected_route_rejects_expired_token(async_client, db):
    token = make_hs256_token(sub=USER_ID, exp_delta_seconds=-3600)

    response = await async_client.get("/api/v1/users/me", headers=auth_header(token))

    assert_error_envelope(response, status_code=401, code="HTTP_ERROR")


@pytest.mark.asyncio
async def test_protected_route_rejects_wrong_audience_token(async_client, db):
    token = make_hs256_token(sub=USER_ID, aud="not-authenticated")

    response = await async_client.get("/api/v1/users/me", headers=auth_header(token))

    assert_error_envelope(response, status_code=401, code="HTTP_ERROR")


@pytest.mark.asyncio
async def test_protected_route_rejects_forged_signature(async_client, db):
    token = make_hs256_token(sub=USER_ID)
    # Tamper with the signature so verification must fail.
    forged = token[:-4] + "AAAA"

    response = await async_client.get("/api/v1/users/me", headers=auth_header(forged))

    assert_error_envelope(response, status_code=401, code="HTTP_ERROR")


@pytest.mark.asyncio
async def test_valid_token_but_missing_profile_is_401(async_client, db):
    """A valid token for a user with no profile row must not be treated as
    authenticated (get_active_user_id fails closed)."""
    token = make_hs256_token(sub="no-such-user")

    response = await async_client.get("/api/v1/users/me", headers=auth_header(token))

    # The token verified; the missing profile is what fails the request.
    assert_error_envelope(response, status_code=401, code="AUTH_PROFILE_NOT_FOUND")


@pytest.mark.asyncio
async def test_suspended_account_is_rejected(async_client, db):
    """An explicitly suspended profile 401s even with a valid token."""
    db.rows["users"] = [user_row(id=USER_ID, is_active=False)]

    token = make_hs256_token(sub=USER_ID)
    response = await async_client.get("/api/v1/users/me", headers=auth_header(token))

    assert response.status_code == 401
    assert response.json()["code"] == "ACCOUNT_SUSPENDED"


# ---------------------------------------------------------------------------
# Admin boundary
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_admin_route_requires_auth(async_client, db):
    response = await async_client.get("/api/v1/admin/me")

    assert_error_envelope(response, status_code=401, code="HTTP_ERROR")


@pytest.mark.asyncio
async def test_admin_route_forbids_plain_user(async_client, user):
    """A validly authenticated non-admin gets 403 PERMISSION_DENIED, never a
    data leak or a 200."""
    response = await async_client.get("/api/v1/admin/me")

    assert_error_envelope(response, status_code=403, code="PERMISSION_DENIED")


@pytest.mark.asyncio
async def test_admin_route_allows_admin(async_client, admin_user):
    response = await async_client.get("/api/v1/admin/me")

    # The admin console routes use the AdminMeResponse contract
    # (user/role/permissions), not the app-wide data envelope.
    assert response.status_code == 200
    body = response.json()
    assert body["user"]["id"] == admin_user["id"]
    assert body["role"] == "admin"
    assert body["permissions"] == ["*"]


# ---------------------------------------------------------------------------
# OAuth profile auto-provisioning (first API call for a new OAuth user)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_first_request_auto_provisions_profile(async_client, db, monkeypatch):
    """A valid token with no users row triggers get_current_user's
    auto-provision path (users + preferences + settings upserts)."""
    from app.core.security import reset_jwks_client

    reset_jwks_client()
    monkeypatch.setattr(auth_module, "_schema_confirmed_ready", True)

    service_client = Mock()
    service_client.auth.admin.get_user_by_id.return_value = SimpleNamespace(
        user=SimpleNamespace(
            email="oauth@example.com",
            user_metadata={"full_name": "OAuth User", "picture": "https://pics.example/a.jpg"},
        )
    )

    from app.db.connection import SupabaseDB

    monkeypatch.setattr(SupabaseDB, "get_service_client", staticmethod(lambda: service_client))

    token = make_hs256_token(sub=USER_ID, email="oauth@example.com")
    response = await async_client.get(
        "/api/v1/feedback/my-tickets", headers=auth_header(token)
    )

    assert_success_envelope(response, status_code=200)
    assert db.rows["users"][0]["id"] == USER_ID
    assert db.rows["users"][0]["full_name"] == "OAuth User"
    assert db.rows["users"][0]["avatar_url"] == "https://pics.example/a.jpg"
    assert db.rows["user_preferences"][0]["user_id"] == USER_ID
    assert db.rows["user_settings"][0]["user_id"] == USER_ID
