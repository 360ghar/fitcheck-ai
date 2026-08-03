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


def test_is_db_connection_error_matches_deque_mutation():
    """httpcore's HTTP/2 pool raises `RuntimeError: deque mutated during
    iteration` when the same shared Supabase client is used concurrently (one
    coroutine iterating the pool's deque while another pops/extends it). It is
    transient - the retry through a fresh client heals it. Observed 2026-08-03
    as "Error checking limit for user ... deque mutated during iteration"
    turning into a generate-outfit 500."""
    assert is_db_connection_error(RuntimeError("deque mutated during iteration"))
    assert is_db_connection_error(RuntimeError("list changed size during iteration"))


def test_is_db_connection_error_matches_protocol_state_machine_errors():
    """h2 ProtocolError state text seen on 2026-08-03 when a dead connection
    receives frames after a gateway restart: SEND_HEADERS/RECV_DATA/RECV_HEADERS
    in an invalid state. Also the plain "Server disconnected" bursts."""
    assert is_db_connection_error(
        RuntimeError("Invalid input StreamInputs.SEND_HEADERS in state 5")
    )
    assert is_db_connection_error(
        RuntimeError("Invalid input ConnectionInputs.RECV_DATA in state ConnectionState.CLOSED")
    )
    assert is_db_connection_error(
        RuntimeError("Invalid input ConnectionInputs.RECV_HEADERS in state ConnectionState.CLOSED")
    )
    assert is_db_connection_error(RuntimeError("Server disconnected"))


def test_is_db_connection_error_matches_bare_numeric_error_code():
    """Some h2/httpcore versions collapse ConnectionTerminated to the bare
    error code with no message (observed 2026-08-03: "Error getting subscription
    for user ...: 11" / "41" / "45" / "79" / "81"). A numeric-only error text
    must be treated as connection-class so the retry can heal it."""
    for code in ("11", "41", "45", "79", "81"):
        assert is_db_connection_error(RuntimeError(code))


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


# ---------------------------------------------------------------------------
# Hot-path wiring: get_subscription (the shared choke point behind /subscription,
# /referral/* and /users/dashboard) now runs its reads through
# execute_with_reconnect, so a dead pooled connection retries once instead of
# 500ing every request until a process restart.
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_subscription_retries_on_dead_connection(monkeypatch):
    from unittest.mock import Mock

    from app.db.connection import SupabaseDB
    from app.models.subscription import PlanType
    from app.services.subscription_service import SubscriptionService

    USER_ID = "11111111-1111-1111-1111-111111111111"
    dead_db = Mock()
    dead_chain = (
        dead_db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value
    )
    dead_chain.execute.side_effect = httpx.RemoteProtocolError(
        "Server disconnected without sending a response."
    )

    fresh_db = Mock()
    row = {
        "id": "22222222-2222-2222-2222-222222222222",
        "user_id": USER_ID,
        "plan_type": "plus_monthly",
        "status": "active",
        "current_period_start": "2026-08-01T00:00:00+00:00",
        # A paid plan without a current_period_end is not entitled
        # (effective_plan_type downgrades it) - give it a future end so the
        # row is treated as an active Plus subscription.
        "current_period_end": "2026-08-31T00:00:00+00:00",
        "cancel_at_period_end": False,
        "trial_end": None,
        "referral_credit_months": 0,
        "created_at": "2026-08-01T00:00:00+00:00",
        "updated_at": "2026-08-01T00:00:00+00:00",
    }
    result = Mock()
    result.data = row
    fresh_chain = (
        fresh_db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value
    )
    fresh_chain.execute.return_value = result

    monkeypatch.setattr(SupabaseDB, "reset", staticmethod(lambda: None))
    monkeypatch.setattr(SupabaseDB, "get_service_client", staticmethod(lambda: fresh_db))

    sub = await SubscriptionService.get_subscription(USER_ID, dead_db)

    assert sub.plan_type == PlanType.PLUS_MONTHLY
    # The dead client was hit exactly once, then rebuilt and retried on fresh.
    dead_chain.execute.assert_called_once()
