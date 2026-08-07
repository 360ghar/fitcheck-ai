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

from supabase import create_client, Client
from app.core.config import settings
from typing import Optional
import logging
import threading

logger = logging.getLogger(__name__)

# Guards creation/rebuild of the singleton clients. supabase-py's sync client
# owns ONE httpx HTTP/2 connection pool; when the Supabase gateway drops that
# connection every concurrent request detects it. Without a lock, each one
# independently tears down and rebuilds the singleton, which (a) wastes
# connections and (b) races inside httpx's pool bookkeeping (the
# "deque mutated during iteration" / "list changed size during iteration"
# transport errors). All creation/rebuild paths take this lock so a failure
# wave produces exactly ONE fresh client that every waiter then shares.
_client_lock = threading.Lock()


class SupabaseDB:
    """Singleton Supabase client for database operations."""

    _instance: Optional[Client] = None
    _service_instance: Optional[Client] = None

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

                    cls._instance = create_client(settings.SUPABASE_URL, settings.SUPABASE_PUBLISHABLE_KEY)
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

                    cls._service_instance = create_client(settings.SUPABASE_URL, settings.SUPABASE_SECRET_KEY)
                    logger.info("Supabase service client initialized")
        return cls._service_instance

    @classmethod
    def reset(cls):
        """Reset the singleton instance (useful for testing)."""
        with _client_lock:
            cls._instance = None
            cls._service_instance = None

    @classmethod
    def rebuild_service_client(cls, stale: Optional[Client] = None) -> Client:
        """Atomically reset + recreate the service client.

        Used by the reconnect/retry wrappers (``app.utils.db``) so that a wave
        of concurrent failures shares a single rebuilt client instead of each
        tearing the singleton down and stampeding ``create_client``. Returns the
        client callers should retry on. Safe to call off the event loop (via
        ``asyncio.to_thread``) or from sync code.

        Pass ``stale`` — the client the caller just saw fail — to get that
        share-one-rebuild property. It is what makes this a double-check rather
        than an unconditional teardown: when a gateway blip fails K concurrent
        requests, the first waiter through the lock rebuilds and the other K-1
        observe that the singleton is no longer the client they found dead and
        reuse it. Without it every waiter builds its own client and its own httpx
        HTTP/2 pool, and because the async wrapper calls this via
        ``asyncio.to_thread`` they also serialize K worker threads on this lock,
        so recovery latency grows linearly with concurrency.

        Omitting ``stale`` keeps the old unconditional behaviour, for callers
        that cannot name the client that failed.
        """
        with _client_lock:
            current = cls._service_instance
            if stale is not None and current is not None and current is not stale:
                # Another waiter in this same failure wave already rebuilt.
                return current
            cls._service_instance = None
            cls._instance = None
            if not settings.SUPABASE_URL or not settings.SUPABASE_SECRET_KEY:
                raise ValueError("SUPABASE_URL and SUPABASE_SECRET_KEY must be set for service client")
            cls._service_instance = create_client(settings.SUPABASE_URL, settings.SUPABASE_SECRET_KEY)
            logger.info("Supabase service client rebuilt (pooled connection recovery)")
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
