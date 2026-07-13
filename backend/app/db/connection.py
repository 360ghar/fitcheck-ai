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

logger = logging.getLogger(__name__)


class SupabaseDB:
    """Singleton Supabase client for database operations."""

    _instance: Optional[Client] = None
    _service_instance: Optional[Client] = None

    @classmethod
    def get_client(cls) -> Client:
        """Get or create the Supabase client singleton."""
        if cls._instance is None:
            if not settings.SUPABASE_URL or not settings.SUPABASE_PUBLISHABLE_KEY:
                raise ValueError("SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY must be set")

            cls._instance = create_client(settings.SUPABASE_URL, settings.SUPABASE_PUBLISHABLE_KEY)
            logger.info("Supabase client initialized")
        return cls._instance

    @classmethod
    def get_service_client(cls) -> Client:
        """Get or create the Supabase service client with elevated privileges."""
        if cls._service_instance is None:
            if not settings.SUPABASE_URL or not settings.SUPABASE_SECRET_KEY:
                raise ValueError("SUPABASE_URL and SUPABASE_SECRET_KEY must be set for service client")

            cls._service_instance = create_client(settings.SUPABASE_URL, settings.SUPABASE_SECRET_KEY)
            logger.info("Supabase service client initialized")
        return cls._service_instance

    @classmethod
    def reset(cls):
        """Reset the singleton instance (useful for testing)."""
        cls._instance = None
        cls._service_instance = None


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
