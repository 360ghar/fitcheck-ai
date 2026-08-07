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
    """PGRST116 -> auto-create profile from auth metadata + preferences."""
    monkeypatch.setattr(
        deps,
        "execute_with_reconnect",
        AsyncMock(side_effect=type("_E", (Exception,), {"code": "PGRST116"})()),
    )
    client = Mock()
    # Auth lookup returns nothing (arc: auth_user falsy) -> token email used.
    client.auth.admin.get_user_by_id.return_value = None
    monkeypatch.setattr(deps.SupabaseDB, "get_service_client", lambda: client)

    db = Mock()
    chain = db.table.return_value.select.return_value.eq.return_value.single.return_value
    chain.execute.return_value = _profile_result()

    user = await get_current_user(db=db, token_data=_token())

    assert user["id"] == "user-1"
    assert user["email"] == "token@example.com"
    # The profile + preferences + settings upserts all ran.
    upserted = [c.args[0] for c in db.table.return_value.upsert.call_args_list]
    assert any("favorite_colors" in u for u in upserted)
    assert any("measurement_units" in u for u in upserted)


@pytest.mark.asyncio
async def test_missing_profile_auto_provision_survives_preference_failures(monkeypatch):
    monkeypatch.setattr(
        deps,
        "execute_with_reconnect",
        AsyncMock(side_effect=type("_E", (Exception,), {"code": "PGRST116"})()),
    )
    monkeypatch.setattr(deps.SupabaseDB, "get_service_client", lambda: Mock())

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
async def test_missing_profile_provision_crash_raises_auth_error(monkeypatch):
    def _boom(*_a, **_k):
        raise RuntimeError("profile creation crashed")

    monkeypatch.setattr(
        deps,
        "execute_with_reconnect",
        AsyncMock(side_effect=type("_E", (Exception,), {"code": "PGRST116"})()),
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
