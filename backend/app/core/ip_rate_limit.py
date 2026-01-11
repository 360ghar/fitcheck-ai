"""
IP-based rate limiting for demo features.

Provides rate limiting for anonymous users based on IP address.
Uses in-memory storage with configurable limits.
"""

import asyncio
from collections import defaultdict
from contextlib import asynccontextmanager
from datetime import datetime, timedelta
from typing import Dict, List

from fastapi import Request

from app.core.exceptions import RateLimitError
from app.core.logging_config import get_context_logger

logger = get_context_logger(__name__)

# In-memory storage for IP rate limits
# Structure: { "ip_address": { "operation_type": [(timestamp1), (timestamp2), ...] } }
_ip_usage: Dict[str, Dict[str, List[datetime]]] = defaultdict(
    lambda: defaultdict(list)
)
_lock = asyncio.Lock()

# Rate limit configuration for demo features
DEMO_RATE_LIMITS = {
    "extraction": 3,  # 3 extractions per day per IP
    "try_on": 2,  # 2 try-ons per day per IP
}

RATE_LIMIT_WINDOW = timedelta(hours=24)


def get_client_ip(request: Request) -> str:
    """
    Extract client IP from request, handling proxies.

    Checks common proxy headers before falling back to direct client IP.
    """
    # Check X-Forwarded-For header (for reverse proxies)
    forwarded = request.headers.get("X-Forwarded-For")
    if forwarded:
        # Take the first IP (original client)
        return forwarded.split(",")[0].strip()

    # Check X-Real-IP header
    real_ip = request.headers.get("X-Real-IP")
    if real_ip:
        return real_ip

    # Fall back to direct client IP
    if request.client:
        return request.client.host

    return "unknown"


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
    cutoff = datetime.utcnow() - RATE_LIMIT_WINDOW

    async with _lock:
        # Clean old entries
        current_usage = _ip_usage[ip_address][operation_type]
        current_usage[:] = [ts for ts in current_usage if ts > cutoff]

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
    async with _lock:
        _ip_usage[ip_address][operation_type].append(datetime.utcnow())


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

    yield rate_check

    await increment_ip_usage(ip_address, operation_type)


async def get_ip_usage_stats(ip_address: str) -> dict:
    """
    Get current usage stats for an IP address.

    Useful for displaying remaining quota to users.
    """
    stats = {}
    cutoff = datetime.utcnow() - RATE_LIMIT_WINDOW

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

    return stats
