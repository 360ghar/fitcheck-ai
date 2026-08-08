"""Handler-branch coverage for app/api/v1/auth.py.

Complements tests/api/test_auth_flow.py (which owns the ASGI-level
register/login contract) and tests/integration/test_auth.py by exercising the
handler branches the flow test cannot reach: profile-creation failures,
referral redemption outcomes, token refresh/logout/password-reset paths,
rate-limit rejection, and the oauth_sync new/existing-user splits.

Follows the house convention of calling route functions directly with a fake
Supabase client (tests/utils/fake_db.FakeDB) and Mock anon clients; Supabase
Auth is never touched. The in-memory IP rate-limit store is reset after every
test via the autouse _clear_ip_rate_limits fixture.
"""
from types import SimpleNamespace
from unittest.mock import AsyncMock, Mock, patch

import pytest
from fastapi import Request
from postgrest.exceptions import APIError as PostgrestAPIError
from supabase_auth.errors import AuthApiError

import app.core.ip_rate_limit as iprl
from app.api.v1 import auth as auth_module
from app.core.exceptions import (
    AuthenticationError,
    DatabaseError,
    EmailAlreadyExistsError,
    RateLimitError,
    SchemaNotInitializedError,
    ValidationError,
)
from app.core.security import TokenData
from app.models.subscription import RedeemReferralResponse
from app.services.referral_service import ReferralService
from tests.factories.row_factories import user_row
from tests.utils.auth_helpers import bearer_credentials
from tests.utils.fake_db import FakeDB

USER_ID = "11111111-1111-1111-1111-111111111111"
EMAIL = "ada@example.com"


def _request(ip: str = "1.2.3.4") -> Request:
    """A minimal ASGI scope so get_client_ip sees request.client.host."""
    return Request(
        scope={
            "type": "http",
            "asgi": {"version": "3.0"},
            "http_version": "1.1",
            "method": "POST",
            "scheme": "http",
            "path": "/api/v1/auth/register",
            "raw_path": b"/api/v1/auth/register",
            "query_string": b"",
            "headers": [],
            "client": (ip, 4321),
            "server": ("testserver", 80),
        }
    )


def _auth_response(user_id: str = USER_ID, email: str = EMAIL, with_session: bool = True):
    """A supabase-py shaped sign_up/sign_in_with_password response."""
    user = Mock(
        id=user_id,
        email=email,
        user_metadata={"full_name": "Ada Lovelace"},
        email_confirmed_at="2026-01-01T00:00:00",
    )
    session = (
        Mock(access_token="access-token-1", refresh_token="refresh-token-1")
        if with_session
        else None
    )
    return SimpleNamespace(user=user, session=session)


def _token_data() -> TokenData:
    """TokenData with the email claim set (as verify_token would)."""
    token = TokenData(sub=USER_ID)
    token.email = EMAIL
    return token


class _FakeAsyncClient:
    """httpx.AsyncClient stand-in whose async context manager yields itself."""

    def __init__(self, error: Exception | None = None):
        self.post = AsyncMock(return_value=Mock(status_code=204))
        if error is not None:
            self.post.side_effect = error

    async def __aenter__(self):
        return self

    async def __aexit__(self, *_args):
        return False


def _fk_error() -> PostgrestAPIError:
    return PostgrestAPIError(
        {
            "code": "23503",
            "message": 'insert or update on table "users" violates foreign key constraint "users_id_fkey"',
            "hint": None,
            "details": None,
        }
    )


@pytest.fixture(autouse=True)
def _clear_ip_rate_limits():
    """The IP rate-limit store is process-global; never leak state between tests."""
    yield
    iprl._ip_usage.clear()


# ===========================================================================
# Schema gate
# ===========================================================================


def test_check_schema_tables_raises_schema_not_initialized():
    class _RaisingDB:
        def table(self, _name):
            def _raise(*_a, **_k):
                raise PostgrestAPIError(
                    {"code": "PGRST205", "message": "Could not find the table", "hint": None, "details": None}
                )

            query = Mock()
            query.select.return_value.limit.return_value.execute.side_effect = _raise
            return query

    with pytest.raises(SchemaNotInitializedError):
        auth_module._check_schema_tables(_RaisingDB())


def test_check_schema_tables_reraises_unrelated_api_errors():
    class _RaisingDB:
        def table(self, _name):
            def _raise(*_a, **_k):
                raise PostgrestAPIError(
                    {"code": "42P01", "message": "undefined_table", "hint": None, "details": None}
                )

            query = Mock()
            query.select.return_value.limit.return_value.execute.side_effect = _raise
            return query

    with pytest.raises(PostgrestAPIError):
        auth_module._check_schema_tables(_RaisingDB())


def test_require_schema_short_circuits_after_first_success(monkeypatch):
    """Once confirmed, the schema probes never re-run (cached flag)."""
    monkeypatch.setattr(auth_module, "_schema_confirmed_ready", False)
    probe = Mock(side_effect=[None])
    monkeypatch.setattr(auth_module, "_check_schema_tables", probe)
    try:
        auth_module._require_schema(FakeDB())
        assert auth_module._schema_confirmed_ready is True
        assert probe.call_count == 1
        auth_module._require_schema(FakeDB())
        assert probe.call_count == 1  # short-circuited
    finally:
        monkeypatch.setattr(auth_module, "_schema_confirmed_ready", False)


# ===========================================================================
# _upsert_user_profile
# ===========================================================================


@pytest.mark.asyncio
async def test_upsert_user_profile_retries_fk_error_then_succeeds():
    db = Mock()
    upsert = Mock()
    upsert.execute.side_effect = [_fk_error(), SimpleNamespace(data=[])]
    db.table.return_value.upsert.return_value = upsert

    ok = await auth_module._upsert_user_profile(
        db, {"id": USER_ID}, max_attempts=2, retry_delay_seconds=0.001
    )

    assert ok is True
    assert upsert.execute.call_count == 2


@pytest.mark.asyncio
async def test_upsert_user_profile_fk_error_persists_then_fallback_finds_user():
    db = Mock()
    upsert = Mock()
    upsert.execute.side_effect = _fk_error()
    db.table.return_value.upsert.return_value = upsert
    select_chain = Mock()
    select_chain.execute.return_value = SimpleNamespace(data=[{"id": USER_ID}])
    db.table.return_value.select.return_value.eq.return_value.limit.return_value = select_chain

    ok = await auth_module._upsert_user_profile(
        db, {"id": USER_ID}, max_attempts=2, retry_delay_seconds=0.001
    )

    assert ok is True


@pytest.mark.asyncio
async def test_upsert_user_profile_fallback_missing_user_returns_false():
    db = Mock()
    upsert = Mock()
    upsert.execute.side_effect = _fk_error()
    db.table.return_value.upsert.return_value = upsert
    select_chain = Mock()
    select_chain.execute.return_value = SimpleNamespace(data=[])
    db.table.return_value.select.return_value.eq.return_value.limit.return_value = select_chain

    ok = await auth_module._upsert_user_profile(
        db, {"id": USER_ID}, max_attempts=2, retry_delay_seconds=0.001
    )

    assert ok is False


@pytest.mark.asyncio
async def test_upsert_user_profile_fallback_query_error_returns_false():
    db = Mock()
    upsert = Mock()
    upsert.execute.side_effect = _fk_error()
    db.table.return_value.upsert.return_value = upsert
    select_chain = Mock()
    select_chain.execute.side_effect = RuntimeError("db down")
    db.table.return_value.select.return_value.eq.return_value.limit.return_value = select_chain

    ok = await auth_module._upsert_user_profile(
        db, {"id": USER_ID}, max_attempts=2, retry_delay_seconds=0.001
    )

    assert ok is False


@pytest.mark.asyncio
async def test_upsert_user_profile_zero_attempts_returns_false():
    """An empty retry budget never enters the loop: last_fk_error stays False
    and the function returns False via the loop-exit tail (no FK fallback)."""
    ok = await auth_module._upsert_user_profile(
        Mock(), {"id": USER_ID}, max_attempts=0, retry_delay_seconds=0.001
    )

    assert ok is False


@pytest.mark.asyncio
async def test_upsert_user_profile_reraises_non_fk_errors():
    db = Mock()
    db.table.return_value.upsert.return_value.execute.side_effect = PostgrestAPIError(
        {"code": "42P01", "message": "undefined_table", "hint": None, "details": None}
    )

    with pytest.raises(PostgrestAPIError):
        await auth_module._upsert_user_profile(db, {"id": USER_ID})


# ===========================================================================
# POST /register
# ===========================================================================


@pytest.mark.asyncio
async def test_register_creates_profile_preferences_settings_and_normalizes_email(anon_db):
    anon_db.auth.sign_up.return_value = _auth_response()
    db = FakeDB()

    result = await auth_module.register(
        auth_module.RegisterRequest(
            email="ADA@Example.com", password="Str0ng!Pass", full_name="Ada Lovelace"
        ),
        http_request=_request(),
        anon_db=anon_db,
        db=db,
    )

    assert result["message"] == "Registered"
    assert result["data"]["access_token"] == "access-token-1"
    assert result["data"]["refresh_token"] == "refresh-token-1"
    assert result["data"]["requires_email_confirmation"] is False
    assert result["data"]["user"]["id"] == USER_ID
    assert result["data"]["user"]["email"] == "ada@example.com"
    assert db.rows["users"][0]["email"] == "ada@example.com"
    assert db.rows["user_preferences"][0]["user_id"] == USER_ID
    assert db.rows["user_settings"][0]["user_id"] == USER_ID
    anon_db.auth.sign_up.assert_called_once()


@pytest.mark.asyncio
async def test_register_without_session_requires_email_confirmation(anon_db):
    anon_db.auth.sign_up.return_value = _auth_response(with_session=False)

    result = await auth_module.register(
        auth_module.RegisterRequest(email="ada@example.com", password="Str0ng!Pass"),
        http_request=_request(),
        anon_db=anon_db,
        db=FakeDB(),
    )

    assert result["data"]["access_token"] == ""
    assert result["data"]["requires_email_confirmation"] is True


@pytest.mark.asyncio
async def test_register_duplicate_auth_email_raises_conflict(anon_db):
    anon_db.auth.sign_up.side_effect = AuthApiError("User already registered", 400, "user_already_exists")

    with pytest.raises(EmailAlreadyExistsError):
        await auth_module.register(
            auth_module.RegisterRequest(email="dup@example.com", password="Str0ng!Pass"),
            http_request=_request(),
            anon_db=anon_db,
            db=FakeDB(),
        )


@pytest.mark.asyncio
async def test_register_other_auth_api_error_raises_authentication_error(anon_db):
    anon_db.auth.sign_up.side_effect = AuthApiError("Something broke", 400, "bad_request")

    with pytest.raises(AuthenticationError) as exc_info:
        await auth_module.register(
            auth_module.RegisterRequest(email="ada@example.com", password="Str0ng!Pass"),
            http_request=_request(),
            anon_db=anon_db,
            db=FakeDB(),
        )
    assert exc_info.value.error_code == "AUTH_REGISTRATION_FAILED"


@pytest.mark.asyncio
async def test_register_missing_user_with_response_error(anon_db):
    anon_db.auth.sign_up.return_value = SimpleNamespace(user=None, error={"message": "no user"})

    with pytest.raises(AuthenticationError) as exc_info:
        await auth_module.register(
            auth_module.RegisterRequest(email="ada@example.com", password="Str0ng!Pass"),
            http_request=_request(),
            anon_db=anon_db,
            db=FakeDB(),
        )
    assert "no user" in str(exc_info.value)


@pytest.mark.asyncio
async def test_register_missing_user_without_error(anon_db):
    anon_db.auth.sign_up.return_value = SimpleNamespace(user=None)

    with pytest.raises(AuthenticationError) as exc_info:
        await auth_module.register(
            auth_module.RegisterRequest(email="ada@example.com", password="Str0ng!Pass"),
            http_request=_request(),
            anon_db=anon_db,
            db=FakeDB(),
        )
    assert exc_info.value.error_code == "AUTH_REGISTRATION_FAILED"


@pytest.mark.asyncio
async def test_register_redeems_referral_code(anon_db):
    anon_db.auth.sign_up.return_value = _auth_response()
    db = FakeDB()
    with patch.object(
        ReferralService,
        "redeem_referral",
        new=AsyncMock(return_value=RedeemReferralResponse(success=True, message="Applied", credit_months=1)),
    ) as redeem:
        result = await auth_module.register(
            auth_module.RegisterRequest(
                email="ada@example.com", password="Str0ng!Pass", referral_code="abc-123"
            ),
            http_request=_request(),
            anon_db=anon_db,
            db=db,
        )

    redeem.assert_awaited_once()
    assert result["data"]["referral"] == {"success": True, "message": "Applied", "credit_months": 1}


@pytest.mark.asyncio
async def test_register_rejected_referral_is_reported(anon_db):
    anon_db.auth.sign_up.return_value = _auth_response()
    db = FakeDB()
    with patch.object(
        ReferralService,
        "redeem_referral",
        new=AsyncMock(return_value=RedeemReferralResponse(success=False, message="Invalid code", credit_months=0)),
    ):
        result = await auth_module.register(
            auth_module.RegisterRequest(
                email="ada@example.com", password="Str0ng!Pass", referral_code="abc-123"
            ),
            http_request=_request(),
            anon_db=anon_db,
            db=db,
        )

    assert result["data"]["referral"]["success"] is False
    assert result["data"]["referral"]["message"] == "Invalid code"


@pytest.mark.asyncio
async def test_register_referral_failure_is_deferred(anon_db):
    anon_db.auth.sign_up.return_value = _auth_response()
    db = FakeDB()
    with patch.object(
        ReferralService, "redeem_referral", new=AsyncMock(side_effect=RuntimeError("missing rpc"))
    ):
        result = await auth_module.register(
            auth_module.RegisterRequest(
                email="ada@example.com", password="Str0ng!Pass", referral_code="abc-123"
            ),
            http_request=_request(),
            anon_db=anon_db,
            db=db,
        )

    assert result["data"]["referral"]["success"] is False
    assert "next sign-in" in result["data"]["referral"]["message"]


@pytest.mark.asyncio
async def test_register_duplicate_profile_email_raises_conflict(anon_db):
    anon_db.auth.sign_up.return_value = _auth_response()
    with patch.object(
        auth_module,
        "_upsert_user_profile",
        new=AsyncMock(
            side_effect=PostgrestAPIError(
                {
                    "code": "23505",
                    "message": 'duplicate key value violates unique constraint "users_email_key"',
                    "hint": None,
                    "details": None,
                }
            )
        ),
    ):
        with pytest.raises(EmailAlreadyExistsError):
            await auth_module.register(
                auth_module.RegisterRequest(email="ada@example.com", password="Str0ng!Pass"),
                http_request=_request(),
                anon_db=anon_db,
                db=FakeDB(),
            )


@pytest.mark.asyncio
async def test_register_other_postgrest_error_raises_database_error(anon_db):
    anon_db.auth.sign_up.return_value = _auth_response()
    with patch.object(
        auth_module,
        "_upsert_user_profile",
        new=AsyncMock(
            side_effect=PostgrestAPIError(
                {"code": "42P01", "message": "undefined_table", "hint": None, "details": None}
            )
        ),
    ):
        with pytest.raises(DatabaseError):
            await auth_module.register(
                auth_module.RegisterRequest(email="ada@example.com", password="Str0ng!Pass"),
                http_request=_request(),
                anon_db=anon_db,
                db=FakeDB(),
            )


@pytest.mark.asyncio
async def test_register_profile_upsert_failure_raises_database_error(anon_db):
    anon_db.auth.sign_up.return_value = _auth_response()
    with patch.object(auth_module, "_upsert_user_profile", new=AsyncMock(return_value=False)):
        with pytest.raises(DatabaseError) as exc_info:
            await auth_module.register(
                auth_module.RegisterRequest(email="ada@example.com", password="Str0ng!Pass"),
                http_request=_request(),
                anon_db=anon_db,
                db=FakeDB(),
            )
    assert "not available" in str(exc_info.value)


@pytest.mark.asyncio
async def test_register_generic_profile_error_raises_database_error(anon_db):
    anon_db.auth.sign_up.return_value = _auth_response()
    with patch.object(
        auth_module, "_upsert_user_profile", new=AsyncMock(side_effect=RuntimeError("boom"))
    ):
        with pytest.raises(DatabaseError):
            await auth_module.register(
                auth_module.RegisterRequest(email="ada@example.com", password="Str0ng!Pass"),
                http_request=_request(),
                anon_db=anon_db,
                db=FakeDB(),
            )


@pytest.mark.asyncio
async def test_register_generic_error_wraps(anon_db):
    anon_db.auth.sign_up.side_effect = RuntimeError("unexpected")

    with pytest.raises(DatabaseError) as exc_info:
        await auth_module.register(
            auth_module.RegisterRequest(email="ada@example.com", password="Str0ng!Pass"),
            http_request=_request(),
            anon_db=anon_db,
            db=FakeDB(),
        )
    assert "registration" in str(exc_info.value).lower()


class _FlakyDefaultsDB(FakeDB):
    """Fails upserts on user_preferences/user_settings; everything else works.

    Used to exercise the best-effort default-row creation: a trigger may
    already own the row, so an upsert failure is logged and ignored.
    """

    def table(self, name):
        query = super().table(name)
        if name in ("user_preferences", "user_settings"):

            def _flaky_upsert(_payload, **_kwargs):
                raise RuntimeError("upsert failed")

            query.upsert = _flaky_upsert
        return query


@pytest.mark.asyncio
async def test_register_skips_defaults_when_upserts_fail(anon_db):
    anon_db.auth.sign_up.return_value = _auth_response()
    db = _FlakyDefaultsDB()

    result = await auth_module.register(
        auth_module.RegisterRequest(email="ada@example.com", password="Str0ng!Pass"),
        http_request=_request(),
        anon_db=anon_db,
        db=db,
    )

    assert result["message"] == "Registered"
    assert [row["id"] for row in db.rows["users"]] == [USER_ID]
    assert "user_preferences" not in db.rows
    assert "user_settings" not in db.rows


@pytest.mark.asyncio
async def test_register_rate_limited():
    for _ in range(5):
        await iprl.increment_auth_usage("9.9.9.9", "register")
    anon_db = Mock()

    with pytest.raises(RateLimitError):
        await auth_module.register(
            auth_module.RegisterRequest(email="ada@example.com", password="Str0ng!Pass"),
            http_request=_request(ip="9.9.9.9"),
            anon_db=anon_db,
            db=FakeDB(),
        )


# ===========================================================================
# POST /login
# ===========================================================================


@pytest.mark.asyncio
async def test_login_returns_profile_and_touches_last_login(anon_db):
    anon_db.auth.sign_in_with_password.return_value = _auth_response()
    db = FakeDB(
        rows={
            "users": [
                user_row(
                    id=USER_ID,
                    email=EMAIL,
                    full_name="Ada Lovelace",
                    avatar_url="http://avatar",
                    gender="f",
                )
            ]
        }
    )

    with patch.object(ReferralService, "process_pending_referral", new=AsyncMock(return_value=None)) as ppr:
        result = await auth_module.login(
            auth_module.LoginRequest(email="ADA@Example.com", password="whatever"),
            http_request=_request(),
            anon_db=anon_db,
            db=db,
        )

    ppr.assert_awaited_once_with(USER_ID, db)
    assert result["message"] == "OK"
    assert result["data"]["user"]["id"] == USER_ID
    assert result["data"]["user"]["email"] == EMAIL
    assert result["data"]["user"]["full_name"] == "Ada Lovelace"
    assert result["data"]["user"]["gender"] == "f"
    assert any(tbl == "users" and "last_login_at" in payload for tbl, payload in db.updates)


@pytest.mark.asyncio
async def test_login_email_not_confirmed(anon_db):
    anon_db.auth.sign_in_with_password.side_effect = AuthApiError("Email not confirmed", 400, "email_not_confirmed")

    with pytest.raises(AuthenticationError) as exc_info:
        await auth_module.login(
            auth_module.LoginRequest(email="ada@example.com", password="whatever"),
            http_request=_request(),
            anon_db=anon_db,
            db=FakeDB(),
        )
    assert exc_info.value.error_code == "AUTH_EMAIL_NOT_CONFIRMED"


@pytest.mark.asyncio
async def test_login_invalid_credentials(anon_db):
    anon_db.auth.sign_in_with_password.side_effect = AuthApiError(
        "Invalid login credentials", 400, "invalid_credentials"
    )

    with pytest.raises(AuthenticationError) as exc_info:
        await auth_module.login(
            auth_module.LoginRequest(email="ada@example.com", password="wrong"),
            http_request=_request(),
            anon_db=anon_db,
            db=FakeDB(),
        )
    assert exc_info.value.error_code == "AUTH_INVALID_CREDENTIALS"


@pytest.mark.asyncio
async def test_login_other_auth_error(anon_db):
    anon_db.auth.sign_in_with_password.side_effect = AuthApiError(
        "Over request rate limit", 429, "over_request_rate_limit"
    )

    with pytest.raises(AuthenticationError) as exc_info:
        await auth_module.login(
            auth_module.LoginRequest(email="ada@example.com", password="whatever"),
            http_request=_request(),
            anon_db=anon_db,
            db=FakeDB(),
        )
    assert exc_info.value.error_code == "AUTH_LOGIN_FAILED"


@pytest.mark.asyncio
async def test_login_auth_api_error_from_unguarded_profile_read(anon_db, monkeypatch):
    """An AuthApiError escaping the unguarded profile re-read (after the
    profile-ensure try/except) must be translated by the outer handler
    instead of leaking as an untranslated error."""
    monkeypatch.setattr(auth_module, "_schema_confirmed_ready", True)
    anon_db.auth.sign_in_with_password.return_value = _auth_response()

    with patch(
        "app.api.v1.auth.asyncio.to_thread",
        side_effect=AuthApiError("profile read boom", 500, "boom"),
    ):
        with pytest.raises(AuthenticationError) as exc_info:
            await auth_module.login(
                auth_module.LoginRequest(email="ada@example.com", password="whatever"),
                http_request=_request(),
                anon_db=anon_db,
                db=FakeDB(),
            )
    assert exc_info.value.error_code == "AUTH_LOGIN_FAILED"


@pytest.mark.asyncio
async def test_login_missing_user(anon_db):
    anon_db.auth.sign_in_with_password.return_value = SimpleNamespace(user=None, session=None)

    with pytest.raises(AuthenticationError) as exc_info:
        await auth_module.login(
            auth_module.LoginRequest(email="ada@example.com", password="whatever"),
            http_request=_request(),
            anon_db=anon_db,
            db=FakeDB(),
        )
    assert exc_info.value.error_code == "AUTH_INVALID_CREDENTIALS"


@pytest.mark.asyncio
async def test_login_creates_missing_profile(anon_db):
    anon_db.auth.sign_in_with_password.return_value = _auth_response()
    db = FakeDB()

    with patch.object(ReferralService, "process_pending_referral", new=AsyncMock(return_value=None)):
        result = await auth_module.login(
            auth_module.LoginRequest(email="ada@example.com", password="whatever"),
            http_request=_request(),
            anon_db=anon_db,
            db=db,
        )

    assert result["message"] == "OK"
    assert db.rows["users"][0]["id"] == USER_ID
    assert db.rows["users"][0]["email"] == EMAIL
    assert "last_login_at" in db.rows["users"][0]
    assert db.rows["user_preferences"][0]["user_id"] == USER_ID
    assert db.rows["user_settings"][0]["user_id"] == USER_ID


@pytest.mark.asyncio
async def test_login_profile_ensure_failure_logs_and_still_returns_profile(anon_db):
    anon_db.auth.sign_in_with_password.return_value = _auth_response()
    chain = Mock()
    profile_row = {
        "id": USER_ID,
        "email": EMAIL,
        "full_name": "Ada",
        "avatar_url": None,
        "gender": None,
        "is_active": True,
        "email_verified": True,
        "created_at": "c",
        "updated_at": "u",
        "last_login_at": "l",
    }
    chain.execute.side_effect = [RuntimeError("boom"), SimpleNamespace(data=[profile_row])]
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value = chain

    with patch.object(ReferralService, "process_pending_referral", new=AsyncMock(return_value=None)):
        result = await auth_module.login(
            auth_module.LoginRequest(email="ada@example.com", password="whatever"),
            http_request=_request(),
            anon_db=anon_db,
            db=db,
        )

    assert result["data"]["user"]["full_name"] == "Ada"


@pytest.mark.asyncio
async def test_login_falls_back_to_auth_metadata_when_profile_missing(anon_db):
    anon_db.auth.sign_in_with_password.return_value = _auth_response()
    db = FakeDB()

    with patch.object(auth_module, "_upsert_user_profile", new=AsyncMock(return_value=True)):
        with patch.object(ReferralService, "process_pending_referral", new=AsyncMock(return_value=None)):
            result = await auth_module.login(
                auth_module.LoginRequest(email="ada@example.com", password="whatever"),
                http_request=_request(),
                anon_db=anon_db,
                db=db,
            )

    assert result["data"]["user"]["full_name"] == "Ada Lovelace"
    assert result["data"]["user"]["avatar_url"] is None


@pytest.mark.asyncio
async def test_login_pending_referral_error_is_logged(anon_db):
    anon_db.auth.sign_in_with_password.return_value = _auth_response()
    db = FakeDB(rows={"users": [user_row(id=USER_ID, email=EMAIL)]})

    with patch.object(
        ReferralService, "process_pending_referral", new=AsyncMock(side_effect=RuntimeError("rpc down"))
    ):
        result = await auth_module.login(
            auth_module.LoginRequest(email="ada@example.com", password="whatever"),
            http_request=_request(),
            anon_db=anon_db,
            db=db,
        )

    assert result["message"] == "OK"


@pytest.mark.asyncio
async def test_login_generic_error_wraps(anon_db):
    anon_db.auth.sign_in_with_password.side_effect = RuntimeError("boom")

    with pytest.raises(DatabaseError):
        await auth_module.login(
            auth_module.LoginRequest(email="ada@example.com", password="whatever"),
            http_request=_request(),
            anon_db=anon_db,
            db=FakeDB(),
        )


@pytest.mark.asyncio
async def test_login_rate_limited():
    for _ in range(10):
        await iprl.increment_auth_usage("9.9.9.9", "login")
    anon_db = Mock()

    with pytest.raises(RateLimitError):
        await auth_module.login(
            auth_module.LoginRequest(email="ada@example.com", password="whatever"),
            http_request=_request(ip="9.9.9.9"),
            anon_db=anon_db,
            db=FakeDB(),
        )


# ===========================================================================
# POST /logout
# ===========================================================================


@pytest.mark.asyncio
async def test_logout_revokes_session_via_supabase(monkeypatch, anon_db):
    client = _FakeAsyncClient()
    monkeypatch.setattr(auth_module.httpx, "AsyncClient", lambda *a, **k: client)

    result = await auth_module.logout(
        credentials=bearer_credentials("tok-123"), anon_db=anon_db
    )

    assert result is None
    client.post.assert_awaited_once()
    call_kwargs = client.post.await_args.kwargs
    assert client.post.await_args.args[0].endswith("auth/v1/logout")
    assert call_kwargs["headers"]["Authorization"] == "Bearer tok-123"


@pytest.mark.asyncio
async def test_logout_without_token_signs_out(anon_db):
    result = await auth_module.logout(request=None, credentials=None, anon_db=anon_db)

    assert result is None
    anon_db.auth.sign_out.assert_called_once()


@pytest.mark.asyncio
async def test_logout_revocation_failure_is_best_effort(monkeypatch, anon_db):
    client = _FakeAsyncClient(error=RuntimeError("network down"))
    monkeypatch.setattr(auth_module.httpx, "AsyncClient", lambda *a, **k: client)

    result = await auth_module.logout(
        credentials=bearer_credentials("tok-123"), anon_db=anon_db
    )

    assert result is None


@pytest.mark.asyncio
async def test_logout_sign_out_failure_is_best_effort(anon_db):
    anon_db.auth.sign_out.side_effect = RuntimeError("no session")

    result = await auth_module.logout(request=None, credentials=None, anon_db=anon_db)

    assert result is None


# ===========================================================================
# POST /refresh
# ===========================================================================


@pytest.mark.asyncio
async def test_refresh_token_returns_new_session(monkeypatch, anon_db):
    from app.services import token_refresh_service

    monkeypatch.setattr(
        token_refresh_service,
        "refresh_token_with_deduplication",
        AsyncMock(
            return_value={
                "access_token": "new-at",
                "refresh_token": "new-rt",
                "user": {"id": USER_ID, "email": EMAIL},
            }
        ),
    )

    result = await auth_module.refresh_token(
        auth_module.RefreshTokenRequest(refresh_token="rt-1"), anon_db=anon_db
    )

    assert result["message"] == "OK"
    assert result["data"]["access_token"] == "new-at"


@pytest.mark.asyncio
async def test_refresh_token_requires_a_token(anon_db):
    with pytest.raises(ValidationError):
        await auth_module.refresh_token(
            auth_module.RefreshTokenRequest(refresh_token=""), anon_db=anon_db
        )


@pytest.mark.asyncio
async def test_refresh_token_propagates_fitcheck_exception(monkeypatch, anon_db):
    from app.services import token_refresh_service

    monkeypatch.setattr(
        token_refresh_service,
        "refresh_token_with_deduplication",
        AsyncMock(side_effect=AuthenticationError("expired", error_code="AUTH_TOKEN_EXPIRED")),
    )

    with pytest.raises(AuthenticationError) as exc_info:
        await auth_module.refresh_token(
            auth_module.RefreshTokenRequest(refresh_token="rt-1"), anon_db=anon_db
        )
    assert exc_info.value.error_code == "AUTH_TOKEN_EXPIRED"


@pytest.mark.asyncio
async def test_refresh_token_wraps_generic_errors(monkeypatch, anon_db):
    from app.services import token_refresh_service

    monkeypatch.setattr(
        token_refresh_service,
        "refresh_token_with_deduplication",
        AsyncMock(side_effect=RuntimeError("boom")),
    )

    with pytest.raises(AuthenticationError) as exc_info:
        await auth_module.refresh_token(
            auth_module.RefreshTokenRequest(refresh_token="rt-1"), anon_db=anon_db
        )
    assert exc_info.value.error_code == "AUTH_REFRESH_FAILED"


# ===========================================================================
# POST /reset-password
# ===========================================================================


@pytest.mark.asyncio
async def test_reset_password_sends_email_and_hides_enumeration(anon_db):
    result = await auth_module.reset_password(
        auth_module.ResetPasswordRequest(email="ada@example.com"),
        http_request=_request(),
        anon_db=anon_db,
    )

    assert "reset link has been sent" in result["message"]
    anon_db.auth.reset_password_for_email.assert_called_once()


@pytest.mark.asyncio
async def test_reset_password_failure_still_hides_enumeration(anon_db):
    anon_db.auth.reset_password_for_email.side_effect = RuntimeError("smtp down")

    result = await auth_module.reset_password(
        auth_module.ResetPasswordRequest(email="ada@example.com"),
        http_request=_request(),
        anon_db=anon_db,
    )

    assert "reset link has been sent" in result["message"]


# ===========================================================================
# POST /confirm-reset-password
# ===========================================================================


@pytest.mark.asyncio
async def test_confirm_reset_password_with_session_tokens(anon_db):
    result = await auth_module.confirm_reset_password(
        auth_module.ConfirmResetRequest(access_token="at", refresh_token="rt", new_password="Str0ng!Pass"),
        anon_db=anon_db,
    )

    assert result["message"] == "Password has been reset successfully"
    anon_db.auth.set_session.assert_called_once_with("at", "rt")
    anon_db.auth.update_user.assert_called_once_with({"password": "Str0ng!Pass"})
    anon_db.auth.sign_out.assert_called_once()


@pytest.mark.asyncio
async def test_confirm_reset_password_with_otp_token(anon_db):
    result = await auth_module.confirm_reset_password(
        auth_module.ConfirmResetRequest(token="otp-1", new_password="Str0ng!Pass"),
        anon_db=anon_db,
    )

    assert result["message"] == "Password has been reset successfully"
    anon_db.auth.verify_otp.assert_called_once_with({"token": "otp-1", "type": "recovery"})


@pytest.mark.asyncio
async def test_confirm_reset_password_missing_recovery_session():
    anon_db = Mock()

    with pytest.raises(ValidationError):
        await auth_module.confirm_reset_password(
            auth_module.ConfirmResetRequest(new_password="Str0ng!Pass"), anon_db=anon_db
        )


@pytest.mark.asyncio
async def test_confirm_reset_password_sign_out_failure_is_best_effort(anon_db):
    anon_db.auth.sign_out.side_effect = RuntimeError("no session")

    result = await auth_module.confirm_reset_password(
        auth_module.ConfirmResetRequest(access_token="at", refresh_token="rt", new_password="Str0ng!Pass"),
        anon_db=anon_db,
    )

    assert "reset successfully" in result["message"]


@pytest.mark.asyncio
async def test_confirm_reset_password_generic_error_raises_database_error(anon_db):
    anon_db.auth.update_user.side_effect = RuntimeError("auth down")

    with pytest.raises(DatabaseError):
        await auth_module.confirm_reset_password(
            auth_module.ConfirmResetRequest(access_token="at", refresh_token="rt", new_password="Str0ng!Pass"),
            anon_db=anon_db,
        )


def test_confirm_reset_password_rejects_weak_passwords():
    """The strength checklist is enforced on password RESET (unlike register)."""
    from pydantic import ValidationError as PydanticValidationError

    with pytest.raises(PydanticValidationError):
        auth_module.ConfirmResetRequest(access_token="at", refresh_token="rt", new_password="weakpass")


# ===========================================================================
# POST /oauth/sync
# ===========================================================================


@pytest.mark.asyncio
async def test_oauth_sync_new_user_creates_profile_and_redeems_referral(monkeypatch):
    admin_client = Mock()
    admin_client.auth.admin.get_user_by_id.return_value = SimpleNamespace(
        user=SimpleNamespace(user_metadata={"name": "Meta Name", "picture": "http://pic"}, email="meta@example.com")
    )
    monkeypatch.setattr(auth_module.SupabaseDB, "get_service_client", staticmethod(lambda: admin_client))
    db = FakeDB()

    with patch.object(
        ReferralService,
        "redeem_referral",
        new=AsyncMock(return_value=RedeemReferralResponse(success=True, message="Applied", credit_months=1)),
    ) as redeem:
        result = await auth_module.oauth_sync(
            auth_module.OAuthSyncRequest(full_name="Ada", avatar_url="http://av", referral_code="abc"),
            db=db,
            token_data=_token_data(),
        )

    redeem.assert_awaited_once()
    assert result["data"]["is_new_user"] is True
    assert result["data"]["user"]["full_name"] == "Ada"
    assert result["data"]["user"]["avatar_url"] == "http://av"
    assert result["data"]["user"]["email"] == EMAIL
    assert result["data"]["referral"]["success"] is True
    assert db.rows["users"][0]["id"] == USER_ID
    assert db.rows["user_preferences"][0]["user_id"] == USER_ID
    assert db.rows["user_settings"][0]["user_id"] == USER_ID


@pytest.mark.asyncio
async def test_oauth_sync_new_user_metadata_fetch_failure_uses_defaults(monkeypatch):
    def _raise(*_a, **_k):
        raise RuntimeError("admin client unavailable")

    monkeypatch.setattr(auth_module.SupabaseDB, "get_service_client", staticmethod(_raise))
    db = FakeDB()

    result = await auth_module.oauth_sync(
        request=None, db=db, token_data=_token_data()
    )

    assert result["data"]["is_new_user"] is True
    assert result["data"]["user"]["full_name"] == ""
    assert result["data"]["user"]["avatar_url"] is None


@pytest.mark.asyncio
async def test_oauth_sync_new_user_without_request_uses_auth_metadata(monkeypatch):
    admin_client = Mock()
    admin_client.auth.admin.get_user_by_id.return_value = SimpleNamespace(
        user=SimpleNamespace(
            user_metadata={"full_name": "Meta Name", "avatar_url": "http://pic"}, email=None
        )
    )
    monkeypatch.setattr(auth_module.SupabaseDB, "get_service_client", staticmethod(lambda: admin_client))
    db = FakeDB()

    result = await auth_module.oauth_sync(
        request=None, db=db, token_data=_token_data()
    )

    assert result["data"]["user"]["full_name"] == "Meta Name"
    assert result["data"]["user"]["avatar_url"] == "http://pic"


@pytest.mark.asyncio
async def test_oauth_sync_new_user_auth_user_missing_keeps_empty_metadata(monkeypatch):
    """get_user_by_id returning None must not fail the sync; defaults are used."""
    admin_client = Mock()
    admin_client.auth.admin.get_user_by_id.return_value = None
    monkeypatch.setattr(auth_module.SupabaseDB, "get_service_client", staticmethod(lambda: admin_client))
    db = FakeDB()

    result = await auth_module.oauth_sync(
        auth_module.OAuthSyncRequest(full_name="Ada"),
        db=db,
        token_data=_token_data(),
    )

    assert result["data"]["user"]["full_name"] == "Ada"
    assert result["data"]["user"]["avatar_url"] is None


@pytest.mark.asyncio
async def test_oauth_sync_new_user_fills_email_from_auth_metadata(monkeypatch):
    """When the token carries no email, the auth user's email is used."""
    admin_client = Mock()
    admin_client.auth.admin.get_user_by_id.return_value = SimpleNamespace(
        user=SimpleNamespace(user_metadata={}, email="meta@example.com")
    )
    monkeypatch.setattr(auth_module.SupabaseDB, "get_service_client", staticmethod(lambda: admin_client))
    db = FakeDB()
    token = TokenData(sub=USER_ID)
    token.email = None

    result = await auth_module.oauth_sync(request=None, db=db, token_data=token)

    assert result["data"]["user"]["email"] == "meta@example.com"
    assert db.rows["users"][0]["email"] == "meta@example.com"


@pytest.mark.asyncio
async def test_oauth_sync_new_user_skips_defaults_when_upserts_fail(monkeypatch):
    monkeypatch.setattr(auth_module.SupabaseDB, "get_service_client", staticmethod(lambda: Mock()))
    db = _FlakyDefaultsDB()

    result = await auth_module.oauth_sync(
        request=None, db=db, token_data=_token_data()
    )

    assert result["data"]["is_new_user"] is True
    assert "user_preferences" not in db.rows
    assert "user_settings" not in db.rows


@pytest.mark.asyncio
async def test_oauth_sync_profile_creation_failure_raises_database_error(monkeypatch):
    monkeypatch.setattr(auth_module.SupabaseDB, "get_service_client", staticmethod(lambda: Mock()))
    db = FakeDB()

    with patch.object(auth_module, "_upsert_user_profile", new=AsyncMock(return_value=False)):
        with pytest.raises(DatabaseError):
            await auth_module.oauth_sync(
                request=None, db=db, token_data=_token_data()
            )


@pytest.mark.asyncio
async def test_oauth_sync_new_user_referral_rejected(monkeypatch):
    monkeypatch.setattr(auth_module.SupabaseDB, "get_service_client", staticmethod(lambda: Mock()))
    db = FakeDB()
    with patch.object(
        ReferralService,
        "redeem_referral",
        new=AsyncMock(return_value=RedeemReferralResponse(success=False, message="Invalid code", credit_months=0)),
    ):
        result = await auth_module.oauth_sync(
            auth_module.OAuthSyncRequest(referral_code="abc"),
            db=db,
            token_data=_token_data(),
        )

    assert result["data"]["referral"]["success"] is False


@pytest.mark.asyncio
async def test_oauth_sync_new_user_referral_failure_deferred(monkeypatch):
    monkeypatch.setattr(auth_module.SupabaseDB, "get_service_client", staticmethod(lambda: Mock()))
    db = FakeDB()
    with patch.object(
        ReferralService, "redeem_referral", new=AsyncMock(side_effect=RuntimeError("missing rpc"))
    ):
        result = await auth_module.oauth_sync(
            auth_module.OAuthSyncRequest(referral_code="abc"),
            db=db,
            token_data=_token_data(),
        )

    assert result["data"]["referral"]["success"] is False
    assert "next sign-in" in result["data"]["referral"]["message"]


@pytest.mark.asyncio
async def test_oauth_sync_existing_user_touches_login_and_processes_pending():
    db = FakeDB(rows={"users": [user_row(id=USER_ID, email=EMAIL, full_name="Ada")]})

    with patch.object(ReferralService, "process_pending_referral", new=AsyncMock(return_value=None)) as ppr:
        result = await auth_module.oauth_sync(
            request=None, db=db, token_data=_token_data()
        )

    ppr.assert_awaited_once_with(USER_ID, db)
    assert result["data"]["is_new_user"] is False
    assert result["data"]["user"]["full_name"] == "Ada"
    assert any(tbl == "users" and "last_login_at" in payload for tbl, payload in db.updates)


@pytest.mark.asyncio
async def test_oauth_sync_existing_user_pending_referral_error_logged():
    db = FakeDB(rows={"users": [user_row(id=USER_ID, email=EMAIL)]})

    with patch.object(
        ReferralService, "process_pending_referral", new=AsyncMock(side_effect=RuntimeError("rpc down"))
    ):
        result = await auth_module.oauth_sync(
            request=None, db=db, token_data=_token_data()
        )

    assert result["message"] == "OK"


@pytest.mark.asyncio
async def test_oauth_sync_generic_error_wraps():
    db = FakeDB()

    with patch.object(auth_module, "_require_schema", side_effect=RuntimeError("boom")):
        with pytest.raises(DatabaseError) as exc_info:
            await auth_module.oauth_sync(
                request=None, db=db, token_data=_token_data()
            )
    assert "OAuth sync" in str(exc_info.value)
