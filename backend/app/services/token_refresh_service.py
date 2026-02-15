"""
Token Refresh Service with Deduplication

Prevents "Invalid Refresh Token: Already Used" errors by coordinating concurrent
refresh token requests. Uses per-token in-flight coordination so only one
Supabase refresh call is made for simultaneous requests with the same token.

Architecture:
- Per-token in-flight state (not global): different tokens refresh concurrently
- First request creates in-flight state → calls Supabase
- Concurrent requests await same in-flight result (no second refresh call)
- No long-lived token cache (preserves one-time refresh-token semantics)
- 10-second lock timeout prevents deadlocks

Follows existing pattern from app/core/ip_rate_limit.py.
"""

import asyncio
import hashlib
from dataclasses import dataclass, field
from typing import Any, Dict, Optional
from supabase import Client

from app.core.logging_config import get_context_logger
from app.core.exceptions import AuthenticationError

logger = get_context_logger(__name__)

# Configuration
LOCK_TIMEOUT_SECONDS = 10  # Max time to wait for in-flight refresh completion

# In-memory storage
# Legacy placeholders kept for backward-compatible imports in tests.
_locks: Dict[str, asyncio.Lock] = {}
_token_cache: Dict[str, Any] = {}


@dataclass
class _InflightRefresh:
    """Holds result/error for waiters while a refresh is in progress."""
    event: asyncio.Event = field(default_factory=asyncio.Event)
    result: Optional[Dict[str, Any]] = None
    error: Optional[AuthenticationError] = None


_inflight_refreshes: Dict[str, _InflightRefresh] = {}
_inflight_lock = asyncio.Lock()


def _hash_token(token: str) -> str:
    """
    Create a SHA256 hash of the refresh token for cache/lock keys.

    Never log or store the actual token - only its hash.
    """
    return hashlib.sha256(token.encode()).hexdigest()[:16]  # First 16 chars sufficient


async def _get_or_create_inflight(token_hash: str) -> tuple[_InflightRefresh, bool]:
    """Get existing in-flight state or create it for the request leader."""
    async with _inflight_lock:
        existing = _inflight_refreshes.get(token_hash)
        if existing is not None:
            return existing, False

        created = _InflightRefresh()
        _inflight_refreshes[token_hash] = created
        return created, True


async def _await_inflight(token_hash: str, inflight: _InflightRefresh) -> Dict[str, Any]:
    """Wait for in-flight refresh result produced by another request."""
    try:
        await asyncio.wait_for(inflight.event.wait(), timeout=LOCK_TIMEOUT_SECONDS)
    except asyncio.TimeoutError as exc:
        logger.error(
            f"Wait timeout ({LOCK_TIMEOUT_SECONDS}s) for in-flight token refresh",
            extra={"token_hash": token_hash},
        )
        raise AuthenticationError(
            "Token refresh is taking too long. Please try again.",
            error_code="AUTH_REFRESH_TIMEOUT",
        ) from exc

    if inflight.error is not None:
        raise inflight.error
    if inflight.result is None:
        raise AuthenticationError(
            "Failed to refresh token",
            error_code="AUTH_REFRESH_FAILED",
        )
    return inflight.result


async def refresh_token_with_deduplication(
    supabase_client: Client,
    refresh_token: str,
) -> Dict[str, Any]:
    """
    Refresh access token with deduplication for concurrent requests.

    Key behavior:
    - First concurrent request for a token becomes leader and calls Supabase
    - Other concurrent requests for the same token await leader result
    - Different tokens process concurrently

    Args:
        supabase_client: Supabase client (anon client with publishable key)
        refresh_token: The refresh token to use

    Returns:
        Dict with:
            - access_token: New access token
            - refresh_token: New refresh token
            - user: User info (id, email)

    Raises:
        AuthenticationError: If token is invalid, expired, or refresh fails
        asyncio.TimeoutError: If waiting for in-flight completion times out
    """
    # Hash token for cache/lock key (never log actual token)
    token_hash = _hash_token(refresh_token)
    inflight, is_leader = await _get_or_create_inflight(token_hash)

    # Followers wait for the request leader's result.
    if not is_leader:
        return await _await_inflight(token_hash, inflight)

    try:
        logger.info(
            "Refreshing token (in-flight leader)",
            extra={"token_hash": token_hash},
        )
        auth_response = await asyncio.to_thread(
            supabase_client.auth.refresh_session,
            refresh_token,
        )

        if auth_response.session is None:
            raise AuthenticationError(
                "Invalid or expired refresh token",
                error_code="AUTH_TOKEN_EXPIRED",
            )

        session = auth_response.session
        user = auth_response.user
        response_data = {
            "access_token": session.access_token,
            "refresh_token": session.refresh_token,
            "user": {
                "id": user.id,
                "email": user.email,
            },
        }
        inflight.result = response_data
        inflight.event.set()

        logger.info(
            "Token refreshed successfully",
            extra={
                "user_id": user.id,
                "token_hash": token_hash,
            },
        )
        return response_data
    except AuthenticationError as auth_error:
        inflight.error = auth_error
        inflight.event.set()
        raise
    except Exception as e:
        error_msg = str(e)
        if "already used" in error_msg.lower():
            logger.warning(
                "Refresh token already used",
                extra={"token_hash": token_hash, "error": error_msg},
            )
        else:
            logger.error(
                "Token refresh failed",
                extra={"token_hash": token_hash, "error": error_msg},
            )
        auth_error = AuthenticationError(
            "Failed to refresh token",
            error_code="AUTH_REFRESH_FAILED",
        )
        inflight.error = auth_error
        inflight.event.set()
        raise auth_error
    finally:
        async with _inflight_lock:
            current = _inflight_refreshes.get(token_hash)
            if current is inflight:
                _inflight_refreshes.pop(token_hash, None)


async def clear_token_cache(refresh_token: str) -> None:
    """
    Clear in-flight refresh state for a token (e.g., on logout).

    Args:
        refresh_token: The refresh token whose in-flight state should be cleared
    """
    token_hash = _hash_token(refresh_token)
    async with _inflight_lock:
        inflight = _inflight_refreshes.pop(token_hash, None)

    if inflight and not inflight.event.is_set():
        inflight.error = AuthenticationError(
            "Token refresh was cancelled",
            error_code="AUTH_REFRESH_CANCELLED",
        )
        inflight.event.set()
    logger.debug(
        "Cleared in-flight token state",
        extra={"token_hash": token_hash},
    )


def get_cache_stats() -> Dict[str, Any]:
    """
    Get cache statistics for monitoring/debugging.

    Returns:
        Dict with cache/in-flight counters.
    """
    return {
        "cache_size": 0,
        "lock_count": len(_inflight_refreshes),
        "inflight_count": len(_inflight_refreshes),
    }
