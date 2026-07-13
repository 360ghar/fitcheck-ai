"""
Unit tests for core authentication: JWT verification (app/core/security.py)
and the login route (app/api/v1/auth.py).

Previously had zero test coverage despite gating every authenticated request
in the app (see architecture review, section 16).
"""
import time
from contextlib import asynccontextmanager
from unittest.mock import Mock, patch

import jwt as pyjwt
import pytest
from cryptography.hazmat.primitives.asymmetric import ec
from fastapi import HTTPException
from fastapi.security import HTTPAuthorizationCredentials
from jose import jwt

from app.api.v1.auth import LoginRequest, login
from app.core.config import settings
from app.core.security import reset_jwks_client, verify_password_strength, verify_token


def _make_token(sub="user-1", aud="authenticated", exp_delta_seconds=3600, **extra_claims):
    payload = {"sub": sub, "aud": aud, "exp": int(time.time()) + exp_delta_seconds, **extra_claims}
    return jwt.encode(payload, settings.SUPABASE_JWT_SECRET, algorithm="HS256")


def _credentials(token: str) -> HTTPAuthorizationCredentials:
    return HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)


def _make_es256_keypair():
    private_key = ec.generate_private_key(ec.SECP256R1())
    public_key = private_key.public_key()
    return private_key, public_key


def _make_es256_token(
    private_key,
    *,
    sub="user-es256",
    aud="authenticated",
    exp_delta_seconds=3600,
    kid="test-es256-kid",
    **extra_claims,
):
    payload = {
        "sub": sub,
        "aud": aud,
        "exp": int(time.time()) + exp_delta_seconds,
        **extra_claims,
    }
    return pyjwt.encode(
        payload,
        private_key,
        algorithm="ES256",
        headers={"kid": kid},
    )


# ==========================================================================
# verify_token — HS256 (legacy / unit-test path)
# ==========================================================================


@pytest.mark.asyncio
async def test_verify_token_accepts_valid_signed_token():
    token = _make_token(sub="user-123", email="user@example.com")

    token_data = await verify_token(_credentials(token))

    assert token_data.sub == "user-123"
    assert token_data.email == "user@example.com"


@pytest.mark.asyncio
async def test_verify_token_rejects_wrong_signature():
    bad_token = jwt.encode({"sub": "user-1", "aud": "authenticated"}, "wrong-secret", algorithm="HS256")

    with pytest.raises(HTTPException) as exc_info:
        await verify_token(_credentials(bad_token))
    assert exc_info.value.status_code == 401


@pytest.mark.asyncio
async def test_verify_token_rejects_expired_token():
    expired = _make_token(exp_delta_seconds=-3600)

    with pytest.raises(HTTPException) as exc_info:
        await verify_token(_credentials(expired))
    assert exc_info.value.status_code == 401


@pytest.mark.asyncio
async def test_verify_token_rejects_wrong_audience():
    wrong_aud = _make_token(aud="not-authenticated")

    with pytest.raises(HTTPException) as exc_info:
        await verify_token(_credentials(wrong_aud))
    assert exc_info.value.status_code == 401


@pytest.mark.asyncio
async def test_verify_token_rejects_missing_credentials():
    with pytest.raises(HTTPException) as exc_info:
        await verify_token(None)
    assert exc_info.value.status_code == 401


# ==========================================================================
# verify_token — ES256 via JWKS (Supabase JWT Signing Keys)
# ==========================================================================


@pytest.fixture(autouse=True)
def _clear_jwks_client():
    """Avoid cross-test JWKS client leakage."""
    reset_jwks_client()
    yield
    reset_jwks_client()


@pytest.mark.asyncio
async def test_verify_token_accepts_es256_jwks_signed_token():
    private_key, public_key = _make_es256_keypair()
    token = _make_es256_token(
        private_key,
        sub="user-es",
        email="es@example.com",
        kid="kid-1",
    )

    mock_signing_key = Mock()
    mock_signing_key.key = public_key
    mock_client = Mock()
    mock_client.get_signing_key_from_jwt.return_value = mock_signing_key

    with patch("app.core.security._get_jwks_client", return_value=mock_client):
        token_data = await verify_token(_credentials(token))

    assert token_data.sub == "user-es"
    assert token_data.email == "es@example.com"
    mock_client.get_signing_key_from_jwt.assert_called()


@pytest.mark.asyncio
async def test_verify_token_rejects_es256_when_jwks_key_missing():
    private_key, _public_key = _make_es256_keypair()
    token = _make_es256_token(private_key, kid="unknown-kid")

    mock_client = Mock()
    mock_client.get_signing_key_from_jwt.side_effect = Exception("Unable to find a signing key")

    with patch("app.core.security._get_jwks_client", return_value=mock_client):
        with pytest.raises(HTTPException) as exc_info:
            await verify_token(_credentials(token))

    assert exc_info.value.status_code == 401


@pytest.mark.asyncio
async def test_verify_token_rejects_es256_wrong_audience():
    private_key, public_key = _make_es256_keypair()
    token = _make_es256_token(private_key, aud="not-authenticated", kid="kid-1")

    mock_signing_key = Mock()
    mock_signing_key.key = public_key
    mock_client = Mock()
    mock_client.get_signing_key_from_jwt.return_value = mock_signing_key

    with patch("app.core.security._get_jwks_client", return_value=mock_client):
        with pytest.raises(HTTPException) as exc_info:
            await verify_token(_credentials(token))

    assert exc_info.value.status_code == 401


# ==========================================================================
# verify_password_strength
# ==========================================================================


def test_verify_password_strength_accepts_strong_password():
    ok, error = verify_password_strength("Str0ng!Pass")
    assert ok is True
    assert error is None


@pytest.mark.parametrize(
    "password",
    ["short1!", "nouppercase1!", "NOLOWERCASE1!", "NoDigitsHere!", "NoSpecialChars1"],
)
def test_verify_password_strength_rejects_weak_passwords(password):
    ok, error = verify_password_strength(password)
    assert ok is False
    assert error is not None


# ==========================================================================
# login route
# ==========================================================================


def _noop_rate_limit():
    @asynccontextmanager
    async def _cm(request, operation_type):
        yield
    return _cm


@pytest.mark.asyncio
async def test_login_returns_tokens_and_profile_on_success():
    anon_db = Mock()
    db = Mock()

    auth_user = Mock(id="user-1", email="user@example.com", user_metadata={"full_name": "Test User"})
    auth_session = Mock(access_token="access-tok", refresh_token="refresh-tok")
    anon_db.auth.sign_in_with_password.return_value = Mock(user=auth_user, session=auth_session)

    db.table.return_value.select.return_value.eq.return_value.execute.return_value = Mock(
        data=[{"full_name": "Test User", "avatar_url": None, "is_active": True, "email_verified": True}]
    )

    with patch("app.api.v1.auth.auth_rate_limited_operation", _noop_rate_limit()), \
         patch("app.api.v1.auth._require_schema"):
        result = await login(
            LoginRequest(email="user@example.com", password="Str0ng!Pass"),
            Mock(),
            anon_db=anon_db,
            db=db,
        )

    assert result["data"]["access_token"] == "access-tok"
    assert result["data"]["user"]["email"] == "user@example.com"


@pytest.mark.asyncio
async def test_login_rejects_invalid_credentials():
    from supabase_auth.errors import AuthApiError

    anon_db = Mock()
    db = Mock()
    anon_db.auth.sign_in_with_password.side_effect = AuthApiError("Invalid login credentials", 400, "invalid_credentials")

    with patch("app.api.v1.auth.auth_rate_limited_operation", _noop_rate_limit()), \
         patch("app.api.v1.auth._require_schema"):
        with pytest.raises(Exception) as exc_info:
            await login(
                LoginRequest(email="user@example.com", password="wrong-password"),
                Mock(),
                anon_db=anon_db,
                db=db,
            )

    assert "AUTH_INVALID_CREDENTIALS" in str(exc_info.value) or "Invalid email or password" in str(exc_info.value)
