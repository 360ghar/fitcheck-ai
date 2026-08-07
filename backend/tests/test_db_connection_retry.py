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


def test_is_db_connection_error_rejects_postgrest_api_errors():
    """A structured PostgREST response carrying a SQLSTATE/PGRST `code`
    (22P02, PGRST202, 42703, ...) is NEVER a dead pooled connection:
    rebuilding the client cannot fix a query/authorization error, and
    retrying churns the shared pool (amplifying the real HTTP/2 races).
    Regression for 2026-08-07: a deterministic jsonb `contains` filter sent
    a Postgres array literal (`cs.{informal}`) for a JSONB column, PostgREST
    answered 22P02 "invalid input syntax for type jsonb", and the `invalid
    input` text marker (added for h2 ProtocolError state strings)
    misclassified it as a connection error - so /items burned 2 client
    rebuilds and 3 attempts on every poll before 500ing. A structured
    GATEWAY error (HTTP-status `code` from a non-JSON 5xx/429 body) is the
    one retryable case - see
    test_is_db_connection_error_retries_gateway_status_errors."""
    from postgrest.exceptions import APIError

    incident_error = APIError(
        {
            "code": "22P02",
            "message": "invalid input syntax for type jsonb",
            "hint": None,
            "details": 'Token "informal" is invalid.',
        }
    )
    assert not is_db_connection_error(incident_error)
    # Proof of the 2026-08-07 misclassification: the APIError's str() embeds
    # the message text, which the `invalid input` marker (added for h2
    # ProtocolError state strings) matches - the OLD classifier returned True
    # for this deterministic query error, burning 2 client rebuilds per poll.
    assert "invalid input" in str(incident_error).lower()
    # Other structured DB errors, same policy.
    assert not is_db_connection_error(
        APIError(
            {
                "code": "PGRST202",
                "message": "Could not find the function public.reserve_ai_usage(p_user_id, p_operation, p_count, p_limit) in the schema cache",
                "hint": None,
                "details": None,
            }
        )
    )
    assert not is_db_connection_error(
        APIError({"code": 400, "message": "JSON could not be generated", "hint": None, "details": "x"})
    )
    # A deterministic PostgREST 500 still carries a SQLSTATE code, not a bare
    # status; only a NON-JSON gateway 5xx body lands on the HTTP status.
    assert not is_db_connection_error(
        APIError({"code": "PGRST104", "message": "Database connection error. Retry your request.", "hint": None, "details": None})
    )
    # The h2 ProtocolError state-machine text the marker was originally added
    # for is a plain RuntimeError (no .code) and must keep matching.
    assert is_db_connection_error(
        RuntimeError("Invalid input StreamInputs.SEND_HEADERS in state 5")
    )


def test_is_db_connection_error_retries_gateway_status_errors():
    """A structured error whose `code` is a bare HTTP status means the
    response body was NOT PostgREST JSON - the Supabase/Cloudflare gateway
    itself answered in a bad state (502/503/520/... or a rate-limit 429).
    That is the transient gateway-blip class the rebuild+retry mechanism
    exists for, so these stay retryable even though they arrive wrapped in
    APIError."""
    from postgrest.exceptions import APIError

    def status_error(code):
        return APIError(
            {
                "code": code,
                "message": "JSON could not be generated",
                "hint": "Refer to full message for details",
                "details": "<html>Bad Gateway</html>",
            }
        )

    for code in (429, 500, 502, 503, 520, 521, 522, 524):
        assert is_db_connection_error(status_error(code)), f"code {code} should retry"

    # Non-gateway statuses and missing codes stay deterministic.
    assert not is_db_connection_error(status_error(404))
    assert not is_db_connection_error(status_error(401))
    assert not is_db_connection_error(status_error(None))


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
    """Record rebuild calls and hand out a distinct fresh client each time.

    The reconnect wrappers now rebuild via a single atomic
    ``SupabaseDB.rebuild_service_client()`` (reset + recreate under one lock) so
    a wave of concurrent failures shares one fresh client instead of each
    tearing the singleton down independently.
    """
    from app.db.connection import SupabaseDB

    events = []

    def fake_rebuild_service_client(_stale=None):
        fresh = object()
        events.append("rebuild")
        events.append(fresh)
        return fresh

    monkeypatch.setattr(
        SupabaseDB, "rebuild_service_client", staticmethod(fake_rebuild_service_client)
    )
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
    # rebuilt client, with a single atomic rebuild in between.
    assert events == [old_db, "rebuild", events[2], events[2]]


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
    assert "rebuild" not in events


@pytest.mark.asyncio
async def test_execute_with_reconnect_retry_also_fails_propagates(monkeypatch):
    events = _patch_supabase_db(monkeypatch)

    def builder(d):
        raise httpx.RemoteProtocolError("goaway")

    with pytest.raises(httpx.RemoteProtocolError):
        await execute_with_reconnect(builder, object())
    assert "rebuild" in events


@pytest.mark.asyncio
async def test_execute_with_reconnect_max_retries_heals_sustained_blip(monkeypatch):
    """Hot read paths pass max_retries=2 so a 1-2 s gateway blip (where the
    first rebuilt client hits the SAME dead gateway) heals instead of 500ing
    - observed 2026-08-04 as /items bursts after a single-retry rebuild."""
    events = _patch_supabase_db(monkeypatch)
    dead_client = object()
    seen_clients = set()

    def builder(d):
        events.append(d)
        seen_clients.add(id(d))
        # The original client AND the first rebuilt client are both dead;
        # the second rebuilt client succeeds.
        if len(seen_clients) < 3:
            raise httpx.RemoteProtocolError("Server disconnected")
        return "ok"

    result = await execute_with_reconnect(builder, dead_client, max_retries=2, backoff_seconds=0)

    assert result == "ok"
    # original + 2 rebuilt clients were tried, with a rebuild before each retry.
    assert len(seen_clients) == 3
    assert events.count("rebuild") == 2


# ---------------------------------------------------------------------------
# Builder shape: the builder must CALL .execute(), not hand back the method
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_execute_with_reconnect_returns_response_not_bound_method(monkeypatch):
    """A builder written as ``lambda d: ....execute`` (no parens) returns the
    bound METHOD instead of running the query, so the caller's
    ``result.data`` blows up on every request - not just during an outage.

    Regression for 2026-08-05: `create_item` / `get_item` were wrapped with the
    parenless form. `asyncio.to_thread` happily returns the callable, and
    `execute_with_reconnect` cannot tell the difference, so nothing failed until
    the caller touched `.data`. This asserts the wrapper hands back whatever the
    builder produced, making the contract explicit for call sites."""
    _patch_supabase_db(monkeypatch)

    class _Resp:
        data = [{"id": "abc"}]

    class _Query:
        def execute(self):
            return _Resp()

    # Correct shape: parens -> a real response object.
    result = await execute_with_reconnect(lambda d: _Query().execute(), object())
    assert not callable(result)
    assert result.data == [{"id": "abc"}]

    # Buggy shape: no parens -> the bound method leaks through to the caller.
    leaked = await execute_with_reconnect(lambda d: _Query().execute, object())
    assert callable(leaked), (
        "a parenless .execute builder returns the method; call sites must use .execute()"
    )


def test_no_parenless_execute_builders_in_app_code():
    """Structural guard: an ``execute_with_reconnect`` lambda builder must CALL
    ``.execute()``, never hand back the bare bound method.

    Note the two OPPOSITE conventions, which is exactly why this bug was easy to
    introduce:

    * ``asyncio.to_thread(chain.execute)``   -> pass the UNCALLED method (correct;
      to_thread invokes it for you).
    * ``execute_with_reconnect(lambda d: chain.execute())`` -> CALL it (correct;
      the lambda is the thing to_thread invokes, so its body must run the query).

    Getting the second one wrong returns the method to the caller, so
    ``result.data`` fails on EVERY request, not only during a connection blip.
    `tests/test_small_routes_async.py` cannot catch it - it treats everything
    inside `execute_with_reconnect(...)` as offloaded and never checks whether
    `.execute` is actually invoked. Regression for 2026-08-05."""
    import ast
    from pathlib import Path

    app_dir = Path(__file__).resolve().parents[1] / "app"
    offenders: list[str] = []

    def _returns_bare_execute(node: ast.AST) -> bool:
        """True if the expression is an `....execute` attribute access that is
        not itself being called."""
        return isinstance(node, ast.Attribute) and node.attr == "execute"

    for path in app_dir.rglob("*.py"):
        tree = ast.parse(path.read_text())
        for node in ast.walk(tree):
            if not isinstance(node, ast.Call):
                continue
            func = node.func
            name = func.attr if isinstance(func, ast.Attribute) else getattr(func, "id", None)
            if name not in {"execute_with_reconnect", "run_sync_with_reconnect"}:
                continue
            # First positional arg is the builder.
            if not node.args:
                continue
            builder = node.args[0]
            if isinstance(builder, ast.Lambda) and _returns_bare_execute(builder.body):
                offenders.append(
                    f"{path.relative_to(app_dir.parent)}:{builder.lineno}"
                )

    assert not offenders, (
        "execute_with_reconnect builders must CALL .execute() - a bare "
        "`.execute` returns the bound method and breaks the caller:\n  "
        + "\n  ".join(offenders)
    )


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
    assert "rebuild" in events


def test_run_sync_with_reconnect_rethrows_non_connection_errors(monkeypatch):
    events = _patch_supabase_db(monkeypatch)

    with pytest.raises(ValueError, match="boom"):
        run_sync_with_reconnect(lambda d: (_ for _ in ()).throw(ValueError("boom")), object())
    assert "rebuild" not in events


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

    monkeypatch.setattr(SupabaseDB, "rebuild_service_client", staticmethod(lambda _stale=None: fresh_db))

    sub = await SubscriptionService.get_subscription(USER_ID, dead_db)

    assert sub.plan_type == PlanType.PLUS_MONTHLY
    # The dead client was hit exactly once, then rebuilt and retried on fresh.
    dead_chain.execute.assert_called_once()


# ---------------------------------------------------------------------------
# SupabaseDB.rebuild_service_client — one rebuild per failure wave
# ---------------------------------------------------------------------------


def test_rebuild_service_client_shares_one_client_across_a_failure_wave(monkeypatch):
    """A wave of concurrent failures must produce exactly ONE new client.

    Every waiter passes the client it saw fail; the first through the lock
    rebuilds, the rest observe the singleton is no longer their stale client and
    reuse it. Without the ``stale`` double-check each of K failing requests built
    its own client (and its own httpx HTTP/2 pool) and serialized a worker thread
    on the lock, so recovery cost grew linearly with concurrency.
    """
    from app.db.connection import SupabaseDB

    created = []

    def fake_create_client(url, key):
        client = object()
        created.append(client)
        return client

    monkeypatch.setattr("app.db.connection.create_client", fake_create_client)
    monkeypatch.setattr("app.db.connection.settings.SUPABASE_URL", "https://x.supabase.co")
    monkeypatch.setattr("app.db.connection.settings.SUPABASE_SECRET_KEY", "secret")
    monkeypatch.setattr(SupabaseDB, "_service_instance", None)
    monkeypatch.setattr(SupabaseDB, "_instance", None)

    dead = SupabaseDB.get_service_client()
    assert len(created) == 1

    # Ten concurrent requests all saw `dead` fail.
    rebuilt = [SupabaseDB.rebuild_service_client(dead) for _ in range(10)]

    assert len(created) == 2, "the wave should have produced exactly one new client"
    assert all(c is created[1] for c in rebuilt), "every waiter must share the rebuild"
    assert SupabaseDB._service_instance is created[1]


def test_rebuild_service_client_without_stale_always_rebuilds(monkeypatch):
    """Callers that cannot name the failing client keep the old unconditional
    behaviour — the dedup is opt-in via ``stale``, never a silent no-op."""
    from app.db.connection import SupabaseDB

    created = []
    monkeypatch.setattr(
        "app.db.connection.create_client",
        lambda url, key: created.append(object()) or created[-1],
    )
    monkeypatch.setattr("app.db.connection.settings.SUPABASE_URL", "https://x.supabase.co")
    monkeypatch.setattr("app.db.connection.settings.SUPABASE_SECRET_KEY", "secret")
    monkeypatch.setattr(SupabaseDB, "_service_instance", None)
    monkeypatch.setattr(SupabaseDB, "_instance", None)

    SupabaseDB.rebuild_service_client()
    SupabaseDB.rebuild_service_client()

    assert len(created) == 2
