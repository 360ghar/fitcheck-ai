"""
Unit tests for core authentication: JWT verification (app/core/security.py)
and the login route (app/api/v1/auth.py).

Previously had zero test coverage despite gating every authenticated request
in the app (see architecture review, section 16).
"""
import time
from contextlib import asynccontextmanager
from unittest.mock import AsyncMock, Mock, patch

import httpx
import jwt as pyjwt
import pytest
from cryptography.hazmat.primitives.asymmetric import ec
from fastapi import HTTPException
from fastapi.security import HTTPAuthorizationCredentials
from jose import jwt

from app.api.v1.auth import LoginRequest, RegisterRequest, login, logout
from app.core.config import settings
from app.core.security import reset_jwks_client, verify_password_strength, verify_token


def _make_token(sub="user-1", aud="authenticated", exp_delta_seconds=3600, **extra_claims):
    payload = {
        "sub": sub,
        "aud": aud,
        "iss": f"{settings.SUPABASE_URL.rstrip('/')}/auth/v1",
        "exp": int(time.time()) + exp_delta_seconds,
        **extra_claims,
    }
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
        "iss": f"{settings.SUPABASE_URL.rstrip('/')}/auth/v1",
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
async def test_verify_token_rejects_wrong_issuer():
    wrong_issuer = _make_token(iss="https://attacker.example.com/auth/v1")

    with pytest.raises(HTTPException) as exc_info:
        await verify_token(_credentials(wrong_issuer))

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


# ==========================================================================
# RegisterRequest — password contract (2026-08-03 RCA)
# ==========================================================================


def test_register_accepts_length_gated_password_without_strength_rules():
    """The shipped web form only gates on 8+ chars ("strength checklist is
    guidance, not a hard gate") and mobile signs up via Supabase directly, so
    the backend must not 422 passwords missing upper/lower/digit/special
    (observed 2026-08-03: ~40 register 422s)."""
    req = RegisterRequest(email="user@example.com", password="aaaaaaaa")
    assert req.password == "aaaaaaaa"


def test_register_still_rejects_short_password():
    from pydantic import ValidationError

    with pytest.raises(ValidationError):
        RegisterRequest(email="user@example.com", password="short")


def test_confirm_reset_keeps_full_strength_requirement():
    """Password RESET keeps the strict rule: the reset page gates on full
    strength client-side, so the backend enforcement is consistent there."""
    from pydantic import ValidationError

    from app.api.v1.auth import ConfirmResetRequest

    with pytest.raises(ValidationError):
        ConfirmResetRequest(new_password="aaaaaaaa", token="t")
    ConfirmResetRequest(new_password="Str0ng!Pass", token="t")


# ==========================================================================
# register — transient referral failure must not crash the response
# ==========================================================================


class _FakeAuthSession:
    access_token = "access-token"
    refresh_token = "refresh-token"


class _FakeAuthUser:
    id = "user-referral-transient"
    error = None


class _FakeAuthResponse:
    user = _FakeAuthUser()
    session = _FakeAuthSession()


@pytest.mark.asyncio
async def test_register_transient_referral_failure_returns_will_retry_message(monkeypatch):
    """A transient redeem_referral failure (missing RPC from an unapplied
    migration, dead pooled connection) must not break registration: the code
    was persisted on users.referred_by_code, so the response surfaces a
    "will retry" message and process_pending_referral completes the grant on
    next sign-in.

    Regression: the fallback constructed RedeemReferralResponse without
    importing it, so this exact path raised NameError -> DatabaseError -> 500
    (fixed 2026-08-04)."""
    from app.api.v1 import auth as auth_module

    anon_db = Mock()
    anon_db.auth.sign_up.return_value = _FakeAuthResponse()

    @asynccontextmanager
    async def _noop_rate_limit(_request, _name):
        yield None

    import inspect

    async def _fake_execute(fn, _db, **_kwargs):
        # Mirrors the real execute_with_reconnect: a callable that RETURNS a
        # coroutine (lambda wrapping an async def) is awaited. A raw return
        # here leaked the un-awaited _upsert_user_profile coroutine.
        outcome = fn(Mock())
        if inspect.iscoroutine(outcome):
            outcome = await outcome
        return outcome

    monkeypatch.setattr(auth_module, "_require_schema", lambda _db: None)
    monkeypatch.setattr(auth_module, "auth_rate_limited_operation", _noop_rate_limit)
    monkeypatch.setattr(auth_module, "execute_with_reconnect", _fake_execute)
    monkeypatch.setattr(
        auth_module.ReferralService,
        "redeem_referral",
        AsyncMock(side_effect=RuntimeError("connection died")),
    )

    result = await auth_module.register(
        auth_module.RegisterRequest(
            email="referral@example.com",
            password="aaaaaaaa",
            referral_code="FIT-ABC123",
        ),
        Mock(),
        anon_db=anon_db,
        db=Mock(),
    )

    assert result["message"] == "Registered"
    assert result["data"]["user"]["id"] == "user-referral-transient"
    referral = result["data"]["referral"]
    assert referral["success"] is False
    assert "automatically on your next sign-in" in referral["message"]


@pytest.mark.asyncio
async def test_register_rejected_referral_returns_rejection_not_will_retry(monkeypatch, caplog):
    """A definitive referral rejection (invalid/own code) must surface the
    rejection message and log cleanly - NOT crash the logger and fall into
    the transient "will retry" branch.

    Regression: the rejection log passed ``message=`` to
    ContextLogger.warning, whose first positional parameter is named
    ``message``, raising ``TypeError: warning() got multiple values for
    argument 'message'``; the except-Exception handler then mis-reported the
    definitive rejection as a transient failure ("will retry on next
    sign-in") and spammed the log (observed 2026-08-04)."""
    import inspect

    from app.api.v1 import auth as auth_module
    from app.models.subscription import RedeemReferralResponse

    anon_db = Mock()
    anon_db.auth.sign_up.return_value = _FakeAuthResponse()

    @asynccontextmanager
    async def _noop_rate_limit(_request, _name):
        yield None

    async def _fake_execute(fn, _db, **_kwargs):
        outcome = fn(Mock())
        if inspect.iscoroutine(outcome):
            outcome = await outcome
        return outcome

    monkeypatch.setattr(auth_module, "_require_schema", lambda _db: None)
    monkeypatch.setattr(auth_module, "auth_rate_limited_operation", _noop_rate_limit)
    monkeypatch.setattr(auth_module, "execute_with_reconnect", _fake_execute)
    monkeypatch.setattr(
        auth_module.ReferralService,
        "redeem_referral",
        AsyncMock(
            return_value=RedeemReferralResponse(
                success=False,
                message="Invalid referral code",
                credit_months=0,
            )
        ),
    )

    result = await auth_module.register(
        auth_module.RegisterRequest(
            email="rejected@example.com",
            password="aaaaaaaa",
            referral_code="FIT-ABC123",
        ),
        Mock(),
        anon_db=anon_db,
        db=Mock(),
    )

    assert result["message"] == "Registered"
    referral = result["data"]["referral"]
    assert referral["success"] is False
    # The definitive rejection text, NOT the transient "will retry" message.
    assert referral["message"] == "Invalid referral code"
    assert "next sign-in" not in referral["message"]
    # The logger no longer crashes: no "Failed to redeem referral code" line.
    assert not any(
        "Failed to redeem referral code" in record.getMessage()
        for record in caplog.records
    )


@pytest.mark.asyncio
async def test_login_retries_pending_referral():
    """A redemption that failed at signup leaves users.referred_by_code set;
    login must call process_pending_referral so the grant completes on the
    next sign-in (RCA 2026-08-04)."""
    from app.api.v1 import auth as auth_module

    anon_db = Mock()
    db = Mock()

    auth_user = Mock(id="user-pending", email="pending@example.com", user_metadata={})
    auth_session = Mock(access_token="access-tok", refresh_token="refresh-tok")
    anon_db.auth.sign_in_with_password.return_value = Mock(user=auth_user, session=auth_session)

    # Profile exists (select on users returns one row).
    db.table.return_value.select.return_value.eq.return_value.execute.return_value = Mock(
        data=[{"full_name": "Pending", "avatar_url": None, "is_active": True, "email_verified": True}]
    )

    process_pending = AsyncMock(return_value=None)
    with patch("app.api.v1.auth.auth_rate_limited_operation", _noop_rate_limit()), \
         patch("app.api.v1.auth._require_schema"), \
         patch.object(auth_module.ReferralService, "process_pending_referral", process_pending):
        result = await login(
            LoginRequest(email="pending@example.com", password="Str0ng!Pass"),
            Mock(),
            anon_db=anon_db,
            db=db,
        )

    assert result["data"]["access_token"] == "access-tok"
    process_pending.assert_awaited_once_with("user-pending", db)


# ==========================================================================
# verify_token — JWKS re-fetch behavior (2026-08-03 RCA)
# ==========================================================================


@pytest.mark.asyncio
async def test_expired_es256_token_does_not_refetch_jwks():
    """An expired signature is the normal app-resume refresh flow: re-fetching
    JWKS cannot help (expiry is checked against the token's exp claim, not the
    signing key) and must not happen. Observed 2026-08-03: an app launch fired
    ~6 parallel requests, each logging a JWKS-refresh warn and a network
    round-trip that could never succeed."""
    private_key, public_key = _make_es256_keypair()
    token = _make_es256_token(private_key, exp_delta_seconds=-3600, kid="kid-1")

    mock_signing_key = Mock()
    mock_signing_key.key = public_key
    mock_client = Mock()
    mock_client.get_signing_key_from_jwt.return_value = mock_signing_key

    with patch("app.core.security._get_jwks_client", return_value=mock_client), \
         patch("app.core.security.reset_jwks_client") as mock_reset:
        with pytest.raises(HTTPException) as exc_info:
            await verify_token(_credentials(token))

    assert exc_info.value.status_code == 401
    mock_client.get_signing_key_from_jwt.assert_called_once()
    mock_reset.assert_not_called()


@pytest.mark.asyncio
async def test_unknown_kid_retries_jwks_exactly_once():
    """Unknown kid / stale JWKS cache is the ONE case that justifies a
    re-fetch; the retry must use a fresh client and can still succeed."""
    private_key, public_key = _make_es256_keypair()
    token = _make_es256_token(private_key, kid="rotated-kid")

    mock_signing_key = Mock()
    mock_signing_key.key = public_key
    stale_client = Mock()
    stale_client.get_signing_key_from_jwt.side_effect = Exception("Unable to find a signing key")
    fresh_client = Mock()
    fresh_client.get_signing_key_from_jwt.return_value = mock_signing_key

    with patch("app.core.security._get_jwks_client", side_effect=[stale_client, fresh_client]), \
         patch("app.core.security.reset_jwks_client") as mock_reset:
        token_data = await verify_token(_credentials(token))

    assert token_data.sub == "user-es256"
    stale_client.get_signing_key_from_jwt.assert_called_once()
    fresh_client.get_signing_key_from_jwt.assert_called_once()
    mock_reset.assert_called_once()


# ==========================================================================
# logout route
# ==========================================================================


@pytest.mark.asyncio
async def test_logout_with_access_token_posts_to_supabase_logout(monkeypatch):
    """With a Bearer access token the backend must POST to Supabase
    /auth/v1/logout so the session's refresh token is revoked server-side
    (regression: sign_out() on the session-less anon client revoked nothing)."""
    calls: list[dict] = []

    async def mock_post(self, url, headers=None, **kwargs):
        calls.append({"url": str(url), "headers": headers or {}})
        return httpx.Response(204)

    monkeypatch.setattr(httpx.AsyncClient, "post", mock_post, raising=True)
    anon_db = Mock()

    result = await logout(request=None, credentials=_credentials("access-tok"), anon_db=anon_db)

    assert result is None
    assert len(calls) == 1
    assert calls[0]["url"].rstrip("/").endswith("/auth/v1/logout")
    assert calls[0]["headers"]["Authorization"] == "Bearer access-tok"
    assert calls[0]["headers"]["apikey"] == settings.SUPABASE_PUBLISHABLE_KEY
    # The token path must not fall back to the (no-op) anon sign_out.
    anon_db.auth.sign_out.assert_not_called()


@pytest.mark.asyncio
async def test_logout_without_access_token_keeps_legacy_sign_out():
    """No Bearer token: keep the existing best-effort sign_out() behavior."""
    anon_db = Mock()

    result = await logout(request=None, credentials=None, anon_db=anon_db)

    assert result is None
    anon_db.auth.sign_out.assert_called_once()


@pytest.mark.asyncio
async def test_logout_is_best_effort_when_supabase_call_fails(monkeypatch):
    """A failed Supabase logout must not fail the request: log and still 204."""

    async def mock_post(self, url, headers=None, **kwargs):
        raise httpx.ConnectError("connection refused")

    monkeypatch.setattr(httpx.AsyncClient, "post", mock_post, raising=True)

    result = await logout(request=None, credentials=_credentials("access-tok"), anon_db=Mock())

    assert result is None
