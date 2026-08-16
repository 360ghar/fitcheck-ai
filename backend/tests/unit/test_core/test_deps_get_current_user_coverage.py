"""Residual branch coverage for app.api.v1.deps.get_current_user.

The sibling test_deps_get_current_user.py covers the happy paths; this file
covers the remaining branches: confirmed-missing-profile auto-provisioning
(including upsert failures and the outer catch-all) and the non-missing
lookup error path.
"""

from unittest.mock import AsyncMock, Mock

import pytest

from app.api.v1 import deps
from app.api.v1.deps import get_current_user
from app.core.exceptions import AuthenticationError
from app.core.security import TokenData


def _profile_result(user_id="user-1", email="user@example.com", full_name="Test", **extra):
    result = Mock()
    data = {
        "id": user_id,
        "email": email,
        "full_name": full_name,
        "is_active": True,
        **extra,
    }
    result.data = data
    return result


def _token(sub="user-1", email="token@example.com"):
    token_data = TokenData(sub=sub, exp=1, aud="authenticated")
    token_data.email = email
    return token_data


@pytest.mark.asyncio
async def test_non_missing_lookup_error_raises_lookup_failure(monkeypatch):
    class _DBError(Exception):
        code = "PGRST100"  # not a missing-row code

    async def _lookup(*_a, **_k):
        raise _DBError("boom")

    monkeypatch.setattr(deps, "execute_with_reconnect", _lookup)
    with pytest.raises(AuthenticationError, match="lookup failed"):
        await get_current_user(db=Mock(), token_data=_token())


@pytest.mark.asyncio
async def test_missing_profile_auto_provisions(monkeypatch):
    """No-row (bare None, A2-17) -> auto-create profile from auth metadata."""

    class _Recorder:
        """Records the query chain built by the lookup lambda."""

        def __init__(self):
            self.calls = []

        def table(self, name):
            self.calls.append(("table", name))
            return self

        def select(self, *a, **k):
            self.calls.append(("select", a, k))
            return self

        def eq(self, *a, **k):
            self.calls.append(("eq", a, k))
            return self

        def maybe_single(self, *a, **k):
            self.calls.append(("maybe_single", a, k))
            return self

        def execute(self, *a, **k):
            return None

    recorder = _Recorder()

    async def _run_query(callable_, *_a, **_k):
        return callable_(recorder)

    monkeypatch.setattr(deps, "execute_with_reconnect", _run_query)
    client = Mock()
    # Auth lookup succeeds with metadata.
    client.auth.admin.get_user_by_id.return_value = Mock(
        user=Mock(
            user_metadata={"full_name": "Ada Lovelace", "avatar_url": "http://av"},
            email="auth@example.com",
        )
    )
    monkeypatch.setattr(deps.SupabaseDB, "get_service_client", lambda: client)

    db = Mock()
    db.table.return_value.upsert.return_value.execute.side_effect = [None, None, None]

    user = await get_current_user(db=db, token_data=_token())

    assert user["id"] == "user-1"
    # A2-17: the lookup used maybe_single, not single().
    assert "maybe_single" in [c[0] for c in recorder.calls]
    # The profile + preferences + settings upserts all ran.
    upserted = [c.args[0] for c in db.table.return_value.upsert.call_args_list]
    assert any("favorite_colors" in u for u in upserted)
    assert any("measurement_units" in u for u in upserted)


@pytest.mark.asyncio
async def test_missing_profile_legacy_pgrst116_still_provisions(monkeypatch):
    """Back-compat: an error whose structured code is PGRST116 still means
    'no row' and enters auto-provisioning."""
    monkeypatch.setattr(
        deps,
        "execute_with_reconnect",
        AsyncMock(side_effect=type("_E", (Exception,), {"code": "PGRST116"})()),
    )
    client = Mock()
    client.auth.admin.get_user_by_id.return_value = Mock(
        user=Mock(user_metadata={}, email=None)
    )
    monkeypatch.setattr(deps.SupabaseDB, "get_service_client", lambda: client)

    db = Mock()
    db.table.return_value.upsert.return_value.execute.side_effect = [None, None, None]

    user = await get_current_user(db=db, token_data=_token())
    assert user["id"] == "user-1"


@pytest.mark.asyncio
async def test_missing_profile_auto_provision_survives_preference_failures(monkeypatch):
    monkeypatch.setattr(
        deps,
        "execute_with_reconnect",
        AsyncMock(return_value=None),
    )
    client = Mock()
    client.auth.admin.get_user_by_id.return_value = Mock(
        user=Mock(user_metadata={}, email=None)
    )
    monkeypatch.setattr(deps.SupabaseDB, "get_service_client", lambda: client)

    db = Mock()
    # Profile upsert succeeds; the two preference upserts raise (already
    # exist / trigger race) and must be swallowed.
    db.table.return_value.upsert.return_value.execute.side_effect = [
        None,
        RuntimeError("preferences exist"),
        RuntimeError("settings exist"),
    ]

    user = await get_current_user(db=db, token_data=_token())
    assert user["id"] == "user-1"


@pytest.mark.asyncio
async def test_missing_profile_deleted_auth_user_not_resurrected(monkeypatch):
    """A1-04: the Auth user is gone (deleted account) while the token is
    still valid — the profile must NOT be auto-created, and the
    AUTH_PROFILE_NOT_FOUND error must surface unwrapped."""
    monkeypatch.setattr(
        deps,
        "execute_with_reconnect",
        AsyncMock(return_value=None),
    )
    client = Mock()
    client.auth.admin.get_user_by_id.return_value = None
    monkeypatch.setattr(deps.SupabaseDB, "get_service_client", lambda: client)

    with pytest.raises(AuthenticationError) as exc_info:
        await get_current_user(db=Mock(), token_data=_token())

    assert exc_info.value.error_code == "AUTH_PROFILE_NOT_FOUND"


@pytest.mark.asyncio
async def test_missing_profile_provision_crash_raises_auth_error(monkeypatch):
    def _boom(*_a, **_k):
        raise RuntimeError("profile creation crashed")

    monkeypatch.setattr(
        deps,
        "execute_with_reconnect",
        AsyncMock(return_value=None),
    )
    monkeypatch.setattr(deps.SupabaseDB, "get_service_client", _boom)

    with pytest.raises(AuthenticationError, match="could not be loaded or created"):
        await get_current_user(db=Mock(), token_data=_token())


@pytest.mark.asyncio
async def test_suspended_account_is_rejected(monkeypatch):
    monkeypatch.setattr(
        deps,
        "execute_with_reconnect",
        AsyncMock(return_value=_profile_result(is_active=False)),
    )
    with pytest.raises(AuthenticationError, match="suspended"):
        await get_current_user(db=Mock(), token_data=_token())
