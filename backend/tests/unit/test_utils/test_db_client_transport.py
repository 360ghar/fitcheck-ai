"""Transport-level coverage for the Supabase client (2026-09-17 production RCA).

The production log's first traceback was
``RuntimeError: dictionary keys changed during iteration`` raised from
``h2.connection.open_outbound_streams`` while httpcore's *sync* HTTP/2
connection was multiplexing concurrent requests: postgrest-py builds its httpx
client with ``http2=True``, so every ``asyncio.to_thread`` worker shared ONE
connection whose ``h2_state.streams`` dict was mutated (``send_headers``)
without a lock while another thread iterated it. HTTP/1.1 removes the race
because httpcore's HTTP11Connection refuses concurrent reuse and the pool
opens a second connection instead.

These tests pin the four things that keep that fix in place:

1. the injected transport is HTTP/1.1 with bounded limits/timeouts;
2. a rebuild CLOSES the superseded transport (it used to leak a pool) and
   installs the new one;
3. a rebuild inside the coalescing window is a no-op (no pool churn);
4. the new error texts (h2 dict mutation, closed-client race, pool saturation)
   are classified correctly by ``app.utils.db``.
"""

import httpx
import pytest

from app.db import connection
from app.db.connection import SupabaseDB
from app.utils.db import (
    execute_with_reconnect,
    is_db_connection_error,
    is_pool_saturation_error,
)


@pytest.fixture(autouse=True)
def _clean_singletons():
    SupabaseDB.reset()
    yield
    SupabaseDB.reset()


# ---------------------------------------------------------------------------
# 1. Transport shape
# ---------------------------------------------------------------------------


def test_built_http_client_is_http11_with_bounded_limits_and_timeouts():
    client = connection._build_http_client()
    try:
        # HTTP/1.1 is the fix: no h2 state to corrupt, and httpcore's HTTP/1.1
        # connection refuses concurrent reuse (the pool opens another).
        assert client._transport._pool._http2 is False
        pool = client._transport._pool
        assert pool._max_connections == connection.SUPABASE_HTTP_LIMITS.max_connections
        assert (
            pool._max_keepalive_connections
            == connection.SUPABASE_HTTP_LIMITS.max_keepalive_connections
        )
        assert pool._keepalive_expiry == 30.0
        # postgrest's default is 120s, which pinned a worker thread for two
        # minutes and saturated the to_thread executor (25.7s responses).
        timeout = client.timeout
        assert timeout.connect == 5.0
        assert timeout.read == 15.0
        assert timeout.write == 15.0
        assert timeout.pool == 10.0
        assert timeout.read < 120
    finally:
        client.close()


def test_build_supabase_client_injects_the_transport(monkeypatch):
    """The transport must reach the Supabase client (and through it postgrest
    and storage), otherwise the HTTP/1.1 guarantee is not in effect."""
    captured = {}

    def fake_create_client(url, key, options=None):
        captured["url"] = url
        captured["key"] = key
        captured["options"] = options
        return object()

    monkeypatch.setattr(connection, "create_client", fake_create_client)

    client, http_client = connection._build_supabase_client("https://x.supabase.co", "k")

    assert captured["options"] is not None
    assert captured["options"].httpx_client is http_client
    assert http_client._transport._pool._http2 is False
    assert client is not None
    http_client.close()


# ---------------------------------------------------------------------------
# 2/3. Rebuild: closes the superseded transport, coalesces inside the window
# ---------------------------------------------------------------------------


def test_rebuild_closes_superseded_transports(monkeypatch):
    monkeypatch.setattr(connection.settings, "SUPABASE_URL", "https://x.supabase.co")
    monkeypatch.setattr(connection.settings, "SUPABASE_SECRET_KEY", "secret")

    old_service_transport = httpx.Client()
    old_anon_transport = httpx.Client()
    monkeypatch.setattr(SupabaseDB, "_service_instance", object())
    monkeypatch.setattr(SupabaseDB, "_service_http", old_service_transport)
    monkeypatch.setattr(SupabaseDB, "_instance", object())
    monkeypatch.setattr(SupabaseDB, "_instance_http", old_anon_transport)

    monkeypatch.setattr(
        connection,
        "_build_supabase_client",
        lambda url, key: (object(), "fresh-transport"),
    )

    rebuilt = SupabaseDB.rebuild_service_client()

    assert rebuilt is SupabaseDB._service_instance
    assert SupabaseDB._service_http == "fresh-transport"
    # Leaking one pool per rebuild is what this guards against - for the client
    # actually being replaced.
    assert old_service_transport.is_closed
    # The anon singleton is reset (its pool heals on the next get_client()) but
    # NOT closed: anon auth calls (anon_db.auth.*) do not go through the retry
    # helper, so closing its pool under an in-flight sign-in would surface
    # httpx's "client has been closed" as an unretried 500.
    assert SupabaseDB._instance is None
    assert not old_anon_transport.is_closed
    old_anon_transport.close()


def test_rebuild_inside_coalescing_window_reuses_the_current_client(monkeypatch):
    """A second failure moments after a rebuild must not churn another pool.

    With HTTP/1.1 a dead connection is discarded and replaced on the next
    request without any rebuild, so retrying on the current client still
    recovers; rebuilding again would only add load to an unhealthy gateway.
    """
    monkeypatch.setattr(connection.settings, "SUPABASE_URL", "https://x.supabase.co")
    monkeypatch.setattr(connection.settings, "SUPABASE_SECRET_KEY", "secret")

    current = object()
    monkeypatch.setattr(SupabaseDB, "_service_instance", current)
    monkeypatch.setattr(SupabaseDB, "_service_http", httpx.Client())
    monkeypatch.setattr(SupabaseDB, "_last_service_rebuild_at", __import__("time").monotonic())
    monkeypatch.setattr(
        connection,
        "_build_supabase_client",
        lambda url, key: pytest.fail("a coalesced rebuild must not create a client"),
    )

    assert SupabaseDB.rebuild_service_client(current) is current
    assert SupabaseDB._service_instance is current


def test_rebuild_after_the_window_rebuilds_again(monkeypatch):
    import time as _time

    monkeypatch.setattr(connection.settings, "SUPABASE_URL", "https://x.supabase.co")
    monkeypatch.setattr(connection.settings, "SUPABASE_SECRET_KEY", "secret")

    current = object()
    fresh = object()
    monkeypatch.setattr(SupabaseDB, "_service_instance", current)
    monkeypatch.setattr(SupabaseDB, "_service_http", httpx.Client())
    monkeypatch.setattr(
        SupabaseDB,
        "_last_service_rebuild_at",
        _time.monotonic() - connection.SUPABASE_REBUILD_MIN_INTERVAL_SECONDS - 0.1,
    )
    monkeypatch.setattr(
        connection, "_build_supabase_client", lambda url, key: (fresh, httpx.Client())
    )

    assert SupabaseDB.rebuild_service_client(current) is fresh


# ---------------------------------------------------------------------------
# 4. Error classification
# ---------------------------------------------------------------------------


def test_h2_dict_mutation_and_closed_client_are_retryable():
    # The exact production traceback text (postgrest -> httpx -> httpcore ->
    # h2 send_headers, concurrent threads on the shared connection).
    assert is_db_connection_error(
        RuntimeError("dictionary keys changed during iteration")
    )
    # The race this change introduces by closing superseded transports: an
    # in-flight request on the closed pool must retry through the fresh one.
    assert is_db_connection_error(
        RuntimeError("Cannot send a request, as the client has been closed.")
    )


def test_pool_saturation_is_retryable_but_not_rebuild_worthy():
    error = httpx.PoolTimeout("timed out")
    assert is_db_connection_error(error)
    assert is_pool_saturation_error(error)
    # A dead connection is the opposite: it is what a rebuild exists for.
    assert not is_pool_saturation_error(httpx.RemoteProtocolError("goaway"))
    assert not is_pool_saturation_error(RuntimeError("bulk insert failed"))


@pytest.mark.asyncio
async def test_pool_timeout_retries_without_rebuilding(monkeypatch):
    from app.db.connection import SupabaseDB as _SupabaseDB

    rebuilds = []
    monkeypatch.setattr(
        _SupabaseDB,
        "rebuild_service_client",
        staticmethod(lambda stale=None: rebuilds.append(stale) or object()),
    )

    clients = []

    def builder(d):
        clients.append(d)
        if len(clients) == 1:
            raise httpx.PoolTimeout("pool exhausted")
        return "ok"

    assert await execute_with_reconnect(builder, object(), backoff_seconds=0) == "ok"
    assert len(clients) == 2
    # Same client, no rebuild: the pool is healthy, just busy.
    assert clients[0] is clients[1]
    assert rebuilds == []


@pytest.mark.asyncio
async def test_dead_connection_still_rebuilds(monkeypatch):
    from app.db.connection import SupabaseDB as _SupabaseDB

    fresh = object()
    rebuilds = []
    monkeypatch.setattr(
        _SupabaseDB,
        "rebuild_service_client",
        staticmethod(lambda stale=None: rebuilds.append(stale) or fresh),
    )

    def builder(d):
        if d is not fresh:
            raise httpx.RemoteProtocolError("goaway")
        return "ok"

    assert await execute_with_reconnect(builder, object(), backoff_seconds=0) == "ok"
    assert len(rebuilds) == 1
