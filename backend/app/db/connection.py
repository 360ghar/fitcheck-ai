"""
Supabase database connection module.

The FastAPI backend is a trusted server and should use the Supabase service-role
key for database/storage operations. Authentication is still enforced at the API
layer via Supabase JWT verification (see app.core.security).

We also expose an "anon" client for operations that must be performed with the
publishable key (e.g., certain Auth flows), but most route handlers should use
the service client.

NOTE on async: `Client` here is supabase-py's *synchronous* client, called
directly inside `async def` route handlers/services throughout the app -
each `.execute()` call blocks the event loop for the request's duration.
supabase-py also ships `create_async_client`/`AsyncClient` (same API shape,
`await`-able), which would remove this entirely, but migrating all ~300
call sites is a dedicated project requiring live integration testing (see
architecture review, section 7) - not something to do as one more
incremental change late in a launch-prep session. As a stopgap, the highest-
traffic call site (`get_current_user` in app/api/v1/deps.py) offloads its
query via `asyncio.to_thread` so it stops blocking the loop on nearly every
authenticated request, without changing the client architecture.
"""

import httpx
from supabase import create_client, Client
from supabase.lib.client_options import SyncClientOptions
from app.core.config import settings
from typing import Optional, Tuple
import logging
import threading
import time

logger = logging.getLogger(__name__)

# Guards creation/rebuild of the singleton clients. supabase-py's sync client
# owns ONE httpx connection pool (HTTP/1.1, see below); when the Supabase
# gateway drops a connection every concurrent request detects it. Without a
# lock, each one independently tears down and rebuilds the singleton, which
# (a) wastes connections and (b) races inside httpx's pool bookkeeping. All
# creation/rebuild paths take this lock so a failure wave produces exactly ONE
# fresh client that every waiter then shares.
_client_lock = threading.Lock()

# ============================================================================
# Transport configuration: HTTP/1.1, explicit limits, bounded timeouts.
#
# RCA 2026-09-17 (production log): postgrest-py builds its sync httpx client
# with ``http2=True``, i.e. ONE multiplexed connection shared by every
# ``asyncio.to_thread`` worker (~32 by default). httpcore 1.0.9 calls
# ``h2_state.send_headers()`` (which mutates ``h2_state.streams``) BEFORE
# taking its write lock - see httpcore/_sync/http2.py:249 vs :465 - while
# another thread iterates that same dict in
# ``h2.connection.open_outbound_streams``. The result is
# ``RuntimeError: dictionary keys changed during iteration`` on
# ``/api/v1/items`` and every later request on that pool failing with
# ``Supabase pooled connection error``. HTTP/1.1 removes the race
# structurally: httpcore's HTTP11Connection refuses concurrent use
# (``ConnectionNotAvailable``) and the pool hands the second caller a second
# connection, so one request owns one connection at a time.
#
# The timeouts are equally load-bearing: postgrest's default is 120s
# (DEFAULT_POSTGREST_CLIENT_TIMEOUT), so a hung gateway call pinned a worker
# thread for two minutes and the bounded executor saturated, turning every
# route into an 8-26s queue wait (observed 25.7s ``POST /api/v1/items``).
# ============================================================================

SUPABASE_HTTP_LIMITS = httpx.Limits(
    max_connections=40,
    max_keepalive_connections=20,
    keepalive_expiry=30.0,
)
SUPABASE_HTTP_TIMEOUT = httpx.Timeout(
    connect=5.0,
    read=15.0,
    write=15.0,
    pool=10.0,
)

# Minimum seconds between two pool rebuilds. A second failure inside the
# window reuses the current client: an HTTP/1.1 pool discards a dead
# connection and opens a fresh one on the next request by itself, so the
# retry is still effective, while churning pools adds load on a gateway that
# is already unhealthy.
SUPABASE_REBUILD_MIN_INTERVAL_SECONDS = 2.0


def _build_http_client() -> httpx.Client:
    """Transport shared by the postgrest/storage/auth/functions clients.

    ``http2=False`` is the fix for the 2026-09-17 h2 state race (see the block
    comment above); the limits bound how many sockets a rebuild storm can
    accumulate; the timeout bounds how long a hung call can hold a worker
    thread. ``follow_redirects`` matches postgrest's/storage3's own default so
    passing our client changes only the transport, not the redirect behavior.
    """
    return httpx.Client(
        http2=False,
        follow_redirects=True,
        timeout=SUPABASE_HTTP_TIMEOUT,
        limits=SUPABASE_HTTP_LIMITS,
    )


def _build_supabase_client(url: str, key: str) -> Tuple[Client, httpx.Client]:
    """Build a Supabase client plus the httpx transport it owns.

    supabase-py forwards ``options.httpx_client`` to postgrest, storage, auth
    and functions, so ONE transport is shared by all four - which is also why
    the transport handle is returned and kept: rebuilding the client must close
    the old pool or every rebuild leaks one.
    """
    http_client = _build_http_client()
    return (
        create_client(url, key, options=SyncClientOptions(httpx_client=http_client)),
        http_client,
    )


def _close_http_client(http_client: Optional[httpx.Client]) -> None:
    """Close a superseded transport; never raise on teardown."""
    if http_client is None:
        return
    try:
        http_client.close()
    except Exception as close_error:  # pragma: no cover - teardown is best-effort
        logger.warning("Failed to close superseded Supabase transport: %s", close_error)


# Grace period before a retired transport is closed. In-flight requests hold a
# reference to the old pool; closing it under them raises "client has been
# closed". Retiring first and closing after the window lets them drain. Sized
# above the worst-case single call the pool can hold (connect 5 + read 15 +
# write 15 + pool-wait 10 = 45s) plus margin, and above
# SUPABASE_HTTP_LIMITS.keepalive_expiry so idle sockets are already reaped.
_RETIRED_TRANSPORT_GRACE_SECONDS = 60.0


def _retire_http_client(http_client: Optional[httpx.Client]) -> None:
    """Retire a superseded transport; close it after in-flight calls drain.

    Never raise on teardown. The timer thread is a daemon so it cannot block
    interpreter shutdown; the pool bounds total sockets in the meantime.
    """
    if http_client is None:
        return
    try:
        timer = threading.Timer(
            _RETIRED_TRANSPORT_GRACE_SECONDS, _close_http_client, args=(http_client,)
        )
        timer.daemon = True
        timer.start()
    except Exception as retire_error:  # pragma: no cover - teardown is best-effort
        logger.warning("Failed to retire superseded Supabase transport: %s", retire_error)


class SupabaseDB:
    """Singleton Supabase client for database operations."""

    _instance: Optional[Client] = None
    _service_instance: Optional[Client] = None
    # The httpx transport each singleton owns (see _build_supabase_client):
    # kept so a rebuild can close the superseded pool instead of leaking it.
    _instance_http: Optional[httpx.Client] = None
    _service_http: Optional[httpx.Client] = None
    # Monotonic timestamp of the last service-client rebuild (rebuild coalescing).
    _last_service_rebuild_at: float = 0.0

    @classmethod
    def get_client(cls) -> Client:
        """Get or create the Supabase client singleton."""
        if cls._instance is None:
            with _client_lock:
                # Double-check: another waiter may have created it while we
                # blocked on the lock. The false arc only exists during a
                # concurrent-creation race.
                if cls._instance is None:  # pragma: no cover - only a creation race hits this
                    if not settings.SUPABASE_URL or not settings.SUPABASE_PUBLISHABLE_KEY:
                        raise ValueError("SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY must be set")

                    cls._instance, cls._instance_http = _build_supabase_client(
                        settings.SUPABASE_URL, settings.SUPABASE_PUBLISHABLE_KEY
                    )
                    logger.info("Supabase client initialized")
        return cls._instance

    @classmethod
    def get_service_client(cls) -> Client:
        """Get or create the Supabase service client with elevated privileges."""
        if cls._service_instance is None:
            with _client_lock:
                # Double-check: another waiter may have created it while we
                # blocked on the lock. The false arc only exists during a
                # concurrent-creation race.
                if cls._service_instance is None:  # pragma: no cover - only a creation race hits this
                    if not settings.SUPABASE_URL or not settings.SUPABASE_SECRET_KEY:
                        raise ValueError("SUPABASE_URL and SUPABASE_SECRET_KEY must be set for service client")

                    cls._service_instance, cls._service_http = _build_supabase_client(
                        settings.SUPABASE_URL, settings.SUPABASE_SECRET_KEY
                    )
                    logger.info("Supabase service client initialized")
        return cls._service_instance

    @classmethod
    def reset(cls):
        """Reset the singleton instance (useful for testing)."""
        with _client_lock:
            _close_http_client(cls._instance_http)
            _close_http_client(cls._service_http)
            cls._instance = None
            cls._service_instance = None
            cls._instance_http = None
            cls._service_http = None
            cls._last_service_rebuild_at = 0.0

    @classmethod
    def rebuild_service_client(cls, stale: Optional[Client] = None) -> Client:
        """Atomically reset + recreate the service client.

        Used by the reconnect/retry wrappers (``app.utils.db``) so that a wave
        of concurrent failures shares a single rebuilt client instead of each
        tearing the singleton down and stampeding ``create_client``. Returns the
        client callers should retry on. Safe to call off the event loop (via
        ``asyncio.to_thread``) or from sync code.

        Pass ``stale`` — the client the caller just saw fail — to get that
        share-one-rebuild property. It is what makes this a double-check
        rather than an unconditional teardown: when a gateway blip fails K concurrent
        requests, the first waiter through the lock rebuilds and the other K-1
        observe that the singleton is no longer the client they found dead and
        reuse it. Without it every waiter builds its own client and its own httpx
        pool, and because the async wrapper calls this via
        ``asyncio.to_thread`` they also serialize K worker threads on this lock,
        so recovery latency grows linearly with concurrency.

        Omitting ``stale`` keeps the old unconditional behaviour, for callers
        that cannot name the client that failed.

        Two further guards, both added with the 2026-09-17 HTTP/1.1 transport:

        - The superseded SERVICE httpx transport is CLOSED. It used to be
          dropped on the floor, so every rebuild leaked a pool of keep-alive
          sockets. A request still in flight on the closed pool raises
          ``RuntimeError: ... client has been closed``, which
          ``app.utils.db`` treats as a retryable pooled-connection error and
          replays through the fresh client.
        - The ANON singleton is reset (so a gateway blip that killed its pool
          heals on the next ``get_client()``) and its transport is retired on
          the same grace timer as the service one: retirement closes the pool
          only after in-flight calls drain, so anon auth calls (which do not
          go through the retry helper) are not closed under, while the
          abandoned pool no longer leaks one client per rebuild.
        - A rebuild inside ``SUPABASE_REBUILD_MIN_INTERVAL_SECONDS`` of the
          previous one is coalesced (the current client is returned
          unchanged). With HTTP/1.1 a dead connection is discarded and
          replaced on the next request without any rebuild, so retrying on the
          current client still recovers from a blip, while rebuilding again
          would only churn a new pool against a gateway that is already
          unhealthy.
        """
        with _client_lock:
            current = cls._service_instance
            if stale is not None and current is not None and current is not stale:
                # Another waiter in this same failure wave already rebuilt.
                return current
            now = time.monotonic()
            if (
                stale is not None
                and current is not None
                and now - cls._last_service_rebuild_at < SUPABASE_REBUILD_MIN_INTERVAL_SECONDS
            ):
                logger.warning(
                    "Supabase client rebuild coalesced; retrying on the current client",
                    extra={
                        "seconds_since_last_rebuild": round(
                            now - cls._last_service_rebuild_at, 3
                        )
                    },
                )
                return current
            # Retire (not close) the superseded SERVICE transport: in-flight
            # requests may still hold it, and closing under them raises
            # "client has been closed". The retired pool closes after the
            # grace window; its sockets stay bounded by keepalive limits.
            # The anon transport is retired too (its pool would otherwise leak
            # one client per rebuild). Retirement is grace-delayed, not
            # immediate, so in-flight anon auth calls — which do not go
            # through the retry helper — still drain instead of 500ing.
            retired_service_http = cls._service_http
            retired_anon_http = cls._instance_http
            cls._service_instance = None
            cls._service_http = None
            cls._instance = None
            cls._instance_http = None
            if not settings.SUPABASE_URL or not settings.SUPABASE_SECRET_KEY:
                raise ValueError("SUPABASE_URL and SUPABASE_SECRET_KEY must be set for service client")
            cls._service_instance, cls._service_http = _build_supabase_client(
                settings.SUPABASE_URL, settings.SUPABASE_SECRET_KEY
            )
            cls._last_service_rebuild_at = time.monotonic()
            logger.info("Supabase service client rebuilt (pooled connection recovery)")
            _retire_http_client(retired_service_http)
            _retire_http_client(retired_anon_http)
            return cls._service_instance


async def get_db() -> Client:
    """Dependency function to get the Supabase client.

    Usage in FastAPI routes:
        db: Client = Depends(get_db)
    """
    # Prefer the service client for server-side operations.
    return SupabaseDB.get_service_client()


async def get_anon_db() -> Client:
    """Dependency function to get the Supabase "anon/publishable" client.

    Use for Auth endpoints when a publishable key is required.
    """
    return SupabaseDB.get_client()


async def get_service_db() -> Client:
    """Dependency function to get the Supabase service client with elevated privileges.

    Usage in FastAPI routes:
        db: Client = Depends(get_service_db)
    """
    return SupabaseDB.get_service_client()
