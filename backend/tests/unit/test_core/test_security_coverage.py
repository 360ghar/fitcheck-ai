"""Residual branch coverage for app.core.security.

The sibling integration tests (test_auth.py, test_auth_flow.py) cover the
verify-token happy paths via mocked JWKS; this file covers the remaining
helpers directly: JWKS client lazy construction, the configured-issuer path,
missing-sub rejection, user-id/email extraction, and best-effort optional
auth.
"""

from unittest.mock import patch

import pytest
from fastapi import HTTPException

from app.core import security
from app.core.security import (
    TokenData,
    get_current_user_email,
    get_current_user_id,
    get_optional_user_id,
    reset_jwks_client,
    verify_token,
    _expected_issuer,
)


def test_jwks_client_is_lazily_built_and_cached():
    reset_jwks_client()
    try:
        client = security._get_jwks_client()
        assert security._get_jwks_client() is client
    finally:
        reset_jwks_client()


def test_expected_issuer_falls_back_to_project_url(monkeypatch):
    # SUPABASE_JWT_ISSUER is not a real settings field; the getattr guard
    # always falls through to the derived issuer.
    monkeypatch.setattr(security.settings, "SUPABASE_URL", "https://proj.supabase.co/")
    assert _expected_issuer() == "https://proj.supabase.co/auth/v1"


@pytest.mark.asyncio
async def test_verify_token_rejects_payload_without_sub():
    with patch.object(security, "_get_jwks_client") as mock_client:
        mock_client.return_value.get_signing_key.return_value.key = "k"
        with patch.object(security, "_decode_payload", return_value={"aud": "authenticated"}):
            with pytest.raises(HTTPException, match="Invalid token"):
                await verify_token(_fake_credentials())


@pytest.mark.asyncio
async def test_verify_token_accepts_valid_payload():
    with patch.object(security, "_get_jwks_client") as mock_client:
        mock_client.return_value.get_signing_key.return_value.key = "k"
        with patch.object(
            security,
            "_decode_payload",
            return_value={"sub": "user-1", "aud": "authenticated", "email": "a@b.c"},
        ):
            token_data = await verify_token(_fake_credentials())
    assert token_data.sub == "user-1"
    assert token_data.email == "a@b.c"


@pytest.mark.asyncio
async def test_get_current_user_id_and_email():
    token_data = TokenData(sub="user-9", exp=123, aud="authenticated")
    token_data.email = "x@y.z"
    assert await get_current_user_id(token_data) == "user-9"
    assert await get_current_user_email(token_data) == "x@y.z"


@pytest.mark.asyncio
async def test_get_optional_user_id_returns_none_without_credentials():
    assert await get_optional_user_id(None) is None


@pytest.mark.asyncio
async def test_get_optional_user_id_returns_none_on_verify_failure():
    with patch.object(security, "verify_token", side_effect=HTTPException(401)):
        assert await get_optional_user_id(_fake_credentials()) is None


@pytest.mark.asyncio
async def test_get_optional_user_id_returns_sub_on_success():
    token_data = TokenData(sub="user-7", exp=123, aud="authenticated")
    with patch.object(security, "verify_token", return_value=token_data):
        assert await get_optional_user_id(_fake_credentials()) == "user-7"


def _fake_credentials():
    class _Creds:
        scheme = "Bearer"
        credentials = "fake.jwt.token"

    return _Creds()
