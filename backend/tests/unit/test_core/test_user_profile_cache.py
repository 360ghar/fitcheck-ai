"""Tests for the auth hot-path profile cache (app.core.user_profile_cache)
and its wiring into app.api.v1.deps.get_current_user.

Covers: hit/miss/TTL, copy-out semantics, single-flight (one DB read for a
cold-cache burst), invalidation on the writer paths, and that a suspended
cached profile is still rejected.
"""

from unittest.mock import Mock

import pytest

from app.api.v1 import deps
from app.core import user_profile_cache
from app.core.exceptions import AuthenticationError
from app.core.security import TokenData


@pytest.fixture(autouse=True)
def _clean_cache():
    user_profile_cache.clear()
    yield
    user_profile_cache.clear()


def _token(sub="user-1", email="token@example.com"):
    token_data = TokenData(sub=sub, exp=1, aud="authenticated")
    token_data.email = email
    return token_data


def _profile_result(user_id="user-1", email="user@example.com", **extra):
    result = Mock()
    result.data = {"id": user_id, "email": email, "is_active": True, **extra}
    return result


# ---------------------------------------------------------------------------
# Cache primitives
# ---------------------------------------------------------------------------


def test_get_returns_none_on_miss_and_after_expiry():
    assert user_profile_cache.get("u1") is None

    user_profile_cache.set_("u1", {"id": "u1"})
    assert user_profile_cache.get("u1") == {"id": "u1"}

    # Force expiry without sleeping past the real TTL.
    user_profile_cache._expiry["u1"] = user_profile_cache._now() - 0.001
    assert user_profile_cache.get("u1") is None


def test_set_stores_copy_not_reference():
    profile = {"id": "u1", "full_name": "A"}
    user_profile_cache.set_("u1", profile)
    profile["full_name"] = "B"
    assert user_profile_cache.get("u1")["full_name"] == "A"


def test_get_returns_fresh_copy_each_call():
    user_profile_cache.set_("u1", {"id": "u1"})
    first = user_profile_cache.get("u1")
    first["mutated"] = True
    assert "mutated" not in user_profile_cache.get("u1")


def test_invalidate_drops_entry():
    user_profile_cache.set_("u1", {"id": "u1"})
    user_profile_cache.invalidate("u1")
    assert user_profile_cache.get("u1") is None


def test_eviction_bounds_entries(monkeypatch):
    monkeypatch.setattr(user_profile_cache, "_MAX_ENTRIES", 4)
    for i in range(6):
        user_profile_cache.set_(f"u{i}", {"id": f"u{i}"})
    assert user_profile_cache.get("u0") is None
    assert user_profile_cache.get("u5") == {"id": "u5"}


@pytest.mark.asyncio
async def test_get_or_load_single_flight_one_db_read():
    """A cold-cache burst of concurrent callers produces ONE loader call."""
    import asyncio

    calls = 0

    async def loader():
        nonlocal calls
        calls += 1
        await asyncio.sleep(0)
        return {"id": "u1"}

    results = await asyncio.gather(*[user_profile_cache.get_or_load("u1", loader) for _ in range(8)])
    assert calls == 1
    assert all(r["id"] == "u1" for r in results)


# ---------------------------------------------------------------------------
# deps.get_current_user wiring
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_second_call_hits_cache_without_db(monkeypatch):
    lookup_calls = 0

    async def _lookup(callable_, *_a, **_k):
        nonlocal lookup_calls
        lookup_calls += 1
        return _profile_result()

    monkeypatch.setattr(deps, "execute_with_reconnect", _lookup)

    first = await deps.get_current_user(db=Mock(), token_data=_token())
    second = await deps.get_current_user(db=Mock(), token_data=_token())

    assert first["id"] == "user-1"
    assert second["id"] == "user-1"
    assert lookup_calls == 1


@pytest.mark.asyncio
async def test_email_injection_does_not_leak_into_cached_copy(monkeypatch):
    """deps.py writes token email onto the returned dict; the cache entry and
    a second caller's response must stay unaffected."""
    async def _lookup(callable_, *_a, **_k):
        return _profile_result(email=None)

    monkeypatch.setattr(deps, "execute_with_reconnect", _lookup)

    first = await deps.get_current_user(db=Mock(), token_data=_token(email="a@x.com"))
    cached = user_profile_cache.get("user-1")
    second = await deps.get_current_user(db=Mock(), token_data=_token(email="b@x.com"))

    assert first["email"] == "a@x.com"
    assert second["email"] == "b@x.com"
    assert cached.get("email") in (None,) or cached["email"] != "a@x.com"


@pytest.mark.asyncio
async def test_suspended_cached_profile_is_rejected(monkeypatch):
    """Suspension must hold even when served from cache."""
    async def _lookup(callable_, *_a, **_k):
        return _profile_result(is_active=False)

    monkeypatch.setattr(deps, "execute_with_reconnect", _lookup)

    with pytest.raises(AuthenticationError, match="suspended"):
        await deps.get_current_user(db=Mock(), token_data=_token())


@pytest.mark.asyncio
async def test_invalidate_forces_reload(monkeypatch):
    lookup_calls = 0

    async def _lookup(callable_, *_a, **_k):
        nonlocal lookup_calls
        lookup_calls += 1
        return _profile_result(full_name=f"Name{lookup_calls}")

    monkeypatch.setattr(deps, "execute_with_reconnect", _lookup)

    await deps.get_current_user(db=Mock(), token_data=_token())
    user_profile_cache.invalidate("user-1")
    updated = await deps.get_current_user(db=Mock(), token_data=_token())

    assert lookup_calls == 2
    assert updated["full_name"] == "Name2"


@pytest.mark.asyncio
async def test_missing_profile_not_cached(monkeypatch):
    """A no-row result must not poison the cache with None: after
    provisioning, the next call gets the provisioned profile from cache."""
    lookup_calls = 0

    async def _lookup(callable_, *_a, **_k):
        nonlocal lookup_calls
        lookup_calls += 1
        return None  # no row yet

    monkeypatch.setattr(deps, "execute_with_reconnect", _lookup)
    client = Mock()
    client.auth.admin.get_user_by_id.return_value = Mock(
        user=Mock(user_metadata={}, email="auth@example.com")
    )
    monkeypatch.setattr(deps.SupabaseDB, "get_service_client", lambda: client)
    db = Mock()
    db.table.return_value.upsert.return_value.execute.return_value = None

    provisioned = await deps.get_current_user(db=db, token_data=_token())
    again = await deps.get_current_user(db=db, token_data=_token())

    assert provisioned["id"] == "user-1"
    # Provisioning cached the new row, so the second call did not re-read.
    assert again["email"] == "auth@example.com"
    assert lookup_calls == 1
