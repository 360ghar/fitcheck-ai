"""
IP-based rate limiting for demo features.

Provides rate limiting for anonymous users based on IP address.
Uses in-memory storage with configurable limits.

LIMITATIONS:
- In-memory storage: Rate limit state is lost on server restart and not shared
  across multiple server instances. For production, consider using Redis.
- Client IP resolution relies on uvicorn's --proxy-headers (see Dockerfile) to
  safely parse X-Forwarded-For, since this container is only reachable via
  Railway's edge proxy. If ever deployed somewhere directly internet-facing,
  that flag/trust assumption would need revisiting.

TRUST ASSUMPTION (get_client_ip):
The container is only reachable through a trusted edge proxy (Railway's edge
proxy / ngrok), which APPENDS the real client IP to X-Forwarded-For. uvicorn's
ProxyHeadersMiddleware (--proxy-headers --forwarded-allow-ips='*') resolves
``request.client.host`` from the FIRST X-Forwarded-For entry, which any direct
peer could forge (A5-01) — so this module parses the LAST entry itself, the
hop only the trusted proxy can append. If this service is ever exposed
directly to the internet WITHOUT a trusted edge proxy, rate limiting keys on
the connecting peer only and the flags must be revisited.
"""

import asyncio
import ipaddress
from collections import defaultdict
from contextlib import asynccontextmanager
from datetime import datetime, timedelta
from app.utils.datetime_util import utcnow
from typing import Dict, List

from fastapi import Request

from app.core.exceptions import RateLimitError
from app.core.logging_config import get_context_logger

logger = get_context_logger(__name__)

# In-memory storage for IP rate limits
# Structure: { "ip_address": { "operation_type": [(timestamp1), (timestamp2), ...] } }
_ip_usage: Dict[str, Dict[str, List[datetime]]] = defaultdict(lambda: defaultdict(list))
_lock = asyncio.Lock()

# Rate limit configuration for demo features
DEMO_RATE_LIMITS = {
    "extraction": 3,  # 3 extractions per day per IP
    "try_on": 2,  # 2 try-ons per day per IP
    "photoshoot": 1,  # 1 demo photoshoot per day per IP (2 images per generation)
}

# Rate limit configuration for unauthenticated write endpoints (stricter,
# shorter window than the demo limits). Named for auth because that was the
# first caller; it now covers every anonymous public write. Keys are used
# verbatim in the user-facing "Too many {key} attempts" message, so they must
# read as a noun phrase.
AUTH_RATE_LIMITS = {
    "login": 10,  # 10 login attempts per hour per IP
    "register": 5,  # 5 registration attempts per hour per IP
    "password_reset": 5,  # 5 password reset requests per hour per IP
    # Anonymous public writes (no auth, straight to Postgres)
    "waitlist signup": 5,  # 5 signups per hour per IP
    "feedback submission": 10,  # 10 tickets per hour per IP (each up to 5 uploads)
    "shared outfit feedback": 20,  # 20 ratings per hour per IP (shared NAT-friendly)
}

AUTH_RATE_LIMIT_WINDOW = timedelta(hours=1)

RATE_LIMIT_WINDOW = timedelta(hours=24)

# Bounds on the in-memory ``_ip_usage`` map (A1-10): the dict grows one key
# per distinct client IP forever without a sweep. Once the map passes
# ``_IP_SWEEP_THRESHOLD`` keys, every rate-limited operation prunes keys with
# no fresh entries; ``_MAX_TRACKED_IPS`` hard-caps the map by evicting the
# least-recently-active keys. Both are generous: a demo/edge deployment never
# sees thousands of distinct IPs in one process lifetime.
_IP_SWEEP_THRESHOLD = 512
_MAX_TRACKED_IPS = 10_000


def _prune_ip_usage_locked(cutoff: datetime) -> None:
    """Drop expired/empty tracked IP keys and enforce the key cap.

    Callers hold ``_lock``. ``cutoff`` is the rate-limit window boundary;
    keys whose per-operation lists contain no timestamp newer than it are
    dead weight and are removed. When the map still exceeds
    ``_MAX_TRACKED_IPS`` after pruning, the least-recently-active keys are
    evicted so memory stays bounded regardless of traffic shape.
    """
    if len(_ip_usage) >= _IP_SWEEP_THRESHOLD:
        stale_keys = [
            ip
            for ip, operations in _ip_usage.items()
            if not any(
                any(ts > cutoff for ts in entries) for entries in operations.values()
            )
        ]
        for ip in stale_keys:
            del _ip_usage[ip]
    if len(_ip_usage) > _MAX_TRACKED_IPS:
        def _last_active(item):
            newest = None
            for entries in item[1].values():
                if entries:
                    candidate = max(entries)
                    if newest is None or candidate > newest:
                        newest = candidate
            return newest

        for ip, _ in sorted(
            _ip_usage.items(), key=_last_active, reverse=True
        )[_MAX_TRACKED_IPS:]:
            del _ip_usage[ip]


def get_client_ip(request: Request) -> str:
    """
    Extract the client IP from the request.

    A5-01: uvicorn runs with --proxy-headers --forwarded-allow-ips='*' (see
    Dockerfile) because this container is only reachable through Railway's
    edge proxy. uvicorn's ProxyHeadersMiddleware resolves request.client.host
    from the FIRST X-Forwarded-For entry, which a peer that can reach uvicorn
    directly can forge (rotating the header defeats every per-IP limit).
    The edge proxy APPENDS the real client IP, so the LAST entry is the hop
    only the trusted proxy can place — resolve the client from it here, and
    only fall back to the resolved peer when the header is absent or
    malformed.
    """
    forwarded_for = request.headers.get("x-forwarded-for")
    if isinstance(forwarded_for, str) and forwarded_for:
        candidate = forwarded_for.split(",")[-1].strip()
        try:
            ipaddress.ip_address(candidate)
        except ValueError:
            candidate = ""
        if candidate:
            return candidate
    return request.client.host if request.client else "unknown"


async def check_ip_rate_limit(
    ip_address: str,
    operation_type: str,
) -> dict:
    """
    Check if IP has exceeded rate limit.

    Args:
        ip_address: The client IP address
        operation_type: Type of operation (extraction, try_on)

    Returns:
        Dict with allowed, current_count, limit, remaining
    """
    limit = DEMO_RATE_LIMITS.get(operation_type, 3)
    cutoff = utcnow() - RATE_LIMIT_WINDOW

    # A5-06: loopback is exempt — local dev (run-dev.sh serves everything
    # from 127.0.0.1 without --proxy-headers) would otherwise burn the
    # shared per-IP buckets after a handful of requests. Production peers
    # are Railway's edge proxy, never loopback, so the exemption cannot be
    # reached there.
    if _is_loopback(ip_address):
        return {"allowed": True, "current_count": 0, "limit": limit, "remaining": limit}

    async with _lock:
        # Clean old entries
        current_usage = _ip_usage[ip_address][operation_type]
        current_usage[:] = [ts for ts in current_usage if ts > cutoff]
        _prune_ip_usage_locked(cutoff)

        current_count = len(current_usage)
        allowed = current_count < limit

        return {
            "allowed": allowed,
            "current_count": current_count,
            "limit": limit,
            "remaining": max(0, limit - current_count),
        }


async def increment_ip_usage(ip_address: str, operation_type: str) -> None:
    """Record a usage for rate limiting."""
    if _is_loopback(ip_address):
        return
    async with _lock:
        _ip_usage[ip_address][operation_type].append(utcnow())


async def decrement_ip_usage(ip_address: str, operation_type: str) -> None:
    """Undo the most recent usage for a rate-limited operation.

    Used by ip_rate_limited_operation to refund the slot reserved up front
    when the operation body fails (A5-11) — a provider 503 or timeout must
    not burn one of the 3-per-day demo slots. Best-effort: if no usage was
    recorded (e.g. a previous failure already refunded it), this is a no-op.
    """
    if _is_loopback(ip_address):
        return
    async with _lock:
        usage_list = _ip_usage[ip_address][operation_type]
        if usage_list:
            usage_list.pop()


def _is_loopback(ip_address: str) -> bool:
    """True for 127.0.0.0/8 and ::1 (local dev peers)."""
    try:
        return ipaddress.ip_address(ip_address).is_loopback
    except ValueError:
        return False


@asynccontextmanager
async def ip_rate_limited_operation(request: Request, operation_type: str):
    """
    Context manager for IP-based rate-limited demo operations.

    Checks rate limit before operation, increments after successful completion.

    Args:
        request: FastAPI request object
        operation_type: Type of operation (extraction, try_on)

    Raises:
        RateLimitError: If rate limit exceeded

    Usage:
        async with ip_rate_limited_operation(request, "extraction"):
            # perform operation
    """
    ip_address = get_client_ip(request)

    rate_check = await check_ip_rate_limit(ip_address, operation_type)
    if not rate_check["allowed"]:
        logger.warning(
            "Demo rate limit exceeded",
            ip=ip_address,
            operation=operation_type,
            limit=rate_check["limit"],
        )
        raise RateLimitError(
            message=(
                f"Demo {operation_type.replace('_', ' ')} limit "
                f"({rate_check['limit']} per day) exceeded. "
                "Sign up for unlimited access!"
            ),
            retry_after=86400,  # 24 hours in seconds
        )

    logger.debug(
        "Demo rate limit check passed",
        ip=ip_address,
        operation=operation_type,
        remaining=rate_check["remaining"] - 1,
    )

    # Reserve before yielding, not after - otherwise concurrent requests from
    # the same IP all read the same pre-increment count and collectively
    # exceed the daily limit. Matches auth_rate_limited_operation's pattern.
    await increment_ip_usage(ip_address, operation_type)

    try:
        yield rate_check
    except Exception:
        # A5-11: a failed operation must not consume the daily slot. The
        # reservation was made up front (so concurrent requests share one
        # counter), so hand it back when the body raises — a provider
        # 503/timeout used to burn one of the 3-per-day demo slots.
        await decrement_ip_usage(ip_address, operation_type)
        raise


async def get_ip_usage_stats(ip_address: str) -> dict:
    """
    Get current usage stats for an IP address.

    Useful for displaying remaining quota to users.
    """
    stats = {}
    cutoff = utcnow() - RATE_LIMIT_WINDOW

    async with _lock:
        for operation_type, limit in DEMO_RATE_LIMITS.items():
            usage_list = _ip_usage[ip_address][operation_type]
            # Clean old entries
            usage_list[:] = [ts for ts in usage_list if ts > cutoff]
            current_count = len(usage_list)

            stats[operation_type] = {
                "used": current_count,
                "limit": limit,
                "remaining": max(0, limit - current_count),
            }
        _prune_ip_usage_locked(cutoff)

    return stats


async def check_auth_rate_limit(
    ip_address: str,
    operation_type: str,
) -> dict:
    """
    Check if IP has exceeded auth rate limit (stricter than demo).

    Args:
        ip_address: The client IP address
        operation_type: Type of auth operation (login, register, password_reset)

    Returns:
        Dict with allowed, current_count, limit, remaining
    """
    limit = AUTH_RATE_LIMITS.get(operation_type, 10)
    cutoff = utcnow() - AUTH_RATE_LIMIT_WINDOW

    # A5-06: loopback exempt (local dev; see check_ip_rate_limit).
    if _is_loopback(ip_address):
        return {"allowed": True, "current_count": 0, "limit": limit, "remaining": limit}

    async with _lock:
        # Use auth-specific key to avoid collision with demo limits
        auth_key = f"auth_{operation_type}"
        current_usage = _ip_usage[ip_address][auth_key]
        current_usage[:] = [ts for ts in current_usage if ts > cutoff]
        _prune_ip_usage_locked(cutoff)

        current_count = len(current_usage)
        allowed = current_count < limit

        return {
            "allowed": allowed,
            "current_count": current_count,
            "limit": limit,
            "remaining": max(0, limit - current_count),
        }


async def increment_auth_usage(ip_address: str, operation_type: str) -> None:
    """Record an auth attempt for rate limiting."""
    if _is_loopback(ip_address):
        return
    async with _lock:
        auth_key = f"auth_{operation_type}"
        _ip_usage[ip_address][auth_key].append(utcnow())


@asynccontextmanager
async def auth_rate_limited_operation(request: Request, operation_type: str):
    """
    Context manager for IP-based rate-limited auth operations.

    Checks rate limit before operation, increments after attempt (success or failure).

    Args:
        request: FastAPI request object
        operation_type: Type of auth operation (login, register, password_reset)

    Raises:
        RateLimitError: If rate limit exceeded

    Usage:
        async with auth_rate_limited_operation(request, "login"):
            # perform login
    """
    ip_address = get_client_ip(request)

    rate_check = await check_auth_rate_limit(ip_address, operation_type)
    if not rate_check["allowed"]:
        logger.warning(
            "Auth rate limit exceeded",
            ip=ip_address,
            operation=operation_type,
            limit=rate_check["limit"],
        )
        raise RateLimitError(
            message=(
                f"Too many {operation_type} attempts. Please wait before trying again."
            ),
            retry_after=3600,  # 1 hour in seconds
        )

    logger.debug(
        "Auth rate limit check passed",
        ip=ip_address,
        operation=operation_type,
        remaining=rate_check["remaining"] - 1,
    )

    # Increment before yielding - count all attempts, not just successful ones
    await increment_auth_usage(ip_address, operation_type)

    yield rate_check
