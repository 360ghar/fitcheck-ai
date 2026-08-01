"""
Tests for the pooled-connection resilience helpers in app/utils/db.py.

Cover the 2026-08-01 incident class: a dead pooled HTTP/2 connection to
Supabase (gateway restart / idle) made every request on the singleton client
fail with 500 until a process restart. The helpers detect the error class and
retry once through a freshly built client.
"""

import httpx
import pytest

from app.utils.db import (
    execute_with_reconnect,
    is_db_connection_error,
    run_sync_with_reconnect,
)


# ---------------------------------------------------------------------------
# is_db_connection_error
# ---------------------------------------------------------------------------


def test_is_db_connection_error_matches_httpx_transport_errors():
    assert is_db_connection_error(httpx.RemoteProtocolError("x"))
    assert is_db_connection_error(httpx.LocalProtocolError("x"))
    assert is_db_connection_error(httpx.ConnectError("x"))
    assert is_db_connection_error(httpx.ReadTimeout("x"))
    assert is_db_connection_error(httpx.PoolTimeout("x"))


def test_is_db_connection_error_matches_embedded_h2_repr():
    """postgrest/httpx versions can surface the raw h2 exception repr without
    a wrapping type we isinstance-check - the string fallback must catch the
    exact repr seen in production logs."""
    err = RuntimeError(
        "<ConnectionTerminated error_code:1, last_stream_id:223, additional_data:None>"
    )
    assert is_db_connection_error(err)


def test_is_db_connection_error_rejects_unrelated_errors():
    assert not is_db_connection_error(ValueError("bad value"))
    assert not is_db_connection_error(RuntimeError("users_id_fkey 23503"))
    assert not is_db_connection_error(RuntimeError("PGRST202 could not find the function"))


# ---------------------------------------------------------------------------
# execute_with_reconnect (async)
# ---------------------------------------------------------------------------


def _patch_supabase_db(monkeypatch):
    """Record reset calls and hand out a distinct fresh client each time."""
    from app.db.connection import SupabaseDB

    events = []

    def fake_reset():
        events.append("reset")

    def fake_get_service_client():
        fresh = object()
        events.append(fresh)
        return fresh

    monkeypatch.setattr(SupabaseDB, "reset", staticmethod(fake_reset))
    monkeypatch.setattr(SupabaseDB, "get_service_client", staticmethod(fake_get_service_client))
    return events


@pytest.mark.asyncio
async def test_execute_with_reconnect_retries_once_with_fresh_client(monkeypatch):
    events = _patch_supabase_db(monkeypatch)
    old_db = object()

    def builder(d):
        events.append(d)
        if d is old_db:
            raise httpx.RemoteProtocolError("Server disconnected without sending a response.")
        return "ok"

    result = await execute_with_reconnect(builder, old_db)

    assert result == "ok"
    # builder ran exactly twice: once on the dead client, once on the fresh
    # one, with a singleton reset in between.
    assert events == [old_db, "reset", events[2], events[2]]


@pytest.mark.asyncio
async def test_execute_with_reconnect_awaits_coroutine_function_builders(monkeypatch):
    _patch_supabase_db(monkeypatch)

    async def builder(d):
        return "async-ok"

    assert await execute_with_reconnect(builder, object()) == "async-ok"


@pytest.mark.asyncio
async def test_execute_with_reconnect_awaits_lambda_wrapping_async_fn(monkeypatch):
    """Call sites wrap async helpers in lambdas (e.g. oauth_sync's
    _upsert_user_profile): the lambda itself is not a coroutine function, but
    calling it returns a coroutine that must still be awaited."""
    _patch_supabase_db(monkeypatch)

    async def inner(d):
        return "inner-ok"

    result = await execute_with_reconnect(lambda d: inner(d), object())
    assert result == "inner-ok"


@pytest.mark.asyncio
async def test_execute_with_reconnect_rethrows_non_connection_errors(monkeypatch):
    events = _patch_supabase_db(monkeypatch)

    with pytest.raises(ValueError, match="boom"):
        await execute_with_reconnect(lambda d: (_ for _ in ()).throw(ValueError("boom")), object())
    assert "reset" not in events


@pytest.mark.asyncio
async def test_execute_with_reconnect_retry_also_fails_propagates(monkeypatch):
    events = _patch_supabase_db(monkeypatch)

    def builder(d):
        raise httpx.RemoteProtocolError("goaway")

    with pytest.raises(httpx.RemoteProtocolError):
        await execute_with_reconnect(builder, object())
    assert "reset" in events


# ---------------------------------------------------------------------------
# run_sync_with_reconnect (sync)
# ---------------------------------------------------------------------------


def test_run_sync_with_reconnect_retries_once(monkeypatch):
    events = _patch_supabase_db(monkeypatch)
    old_db = object()

    def fn(d):
        events.append(d)
        if d is old_db:
            raise httpx.RemoteProtocolError("goaway")
        return "ok"

    assert run_sync_with_reconnect(fn, old_db) == "ok"
    assert events[0] is old_db
    assert "reset" in events


def test_run_sync_with_reconnect_rethrows_non_connection_errors(monkeypatch):
    events = _patch_supabase_db(monkeypatch)

    with pytest.raises(ValueError, match="boom"):
        run_sync_with_reconnect(lambda d: (_ for _ in ()).throw(ValueError("boom")), object())
    assert "reset" not in events
