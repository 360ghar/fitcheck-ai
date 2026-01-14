"""
Rate limiting utilities for AI operations.

Provides a context manager to simplify rate limit checking and usage tracking.
Uses subscription-based monthly limits as primary, with daily limits as fallback.
"""

from contextlib import asynccontextmanager
from typing import Any, Dict, Optional

from supabase import Client

from app.core.exceptions import RateLimitError
from app.services.subscription_service import SubscriptionService


@asynccontextmanager
async def rate_limited_operation(
    user_id: str,
    operation_type: str,
    db: Client,
    count: int = 1,
):
    """
    Context manager for rate-limited AI operations.

    Uses subscription-based monthly limits. Checks rate limit before yielding,
    increments usage after successful completion.

    Args:
        user_id: The user performing the operation
        operation_type: Type of operation ("extraction", "generation", "embedding")
        db: Supabase client
        count: Number of operations (for batch operations)

    Yields:
        Rate check result dict with 'limit', 'current_count', 'remaining', 'plan_type' keys

    Raises:
        RateLimitError: If rate limit is exceeded
    """
    # Check subscription-based monthly limit
    rate_check = await SubscriptionService.check_limit(
        user_id=user_id,
        operation_type=operation_type,
        db=db,
        count=count,
    )

    if not rate_check.allowed:
        plan_name = "Pro" if rate_check.plan_type.value.startswith("pro") else "Free"
        msg = f"Monthly {operation_type} limit ({rate_check.limit}) exceeded on {plan_name} plan."
        if count > 1:
            msg += f" Requested {count} with {rate_check.remaining} remaining."
        msg += " Upgrade to Pro for more!"
        raise RateLimitError(msg)

    # Convert to dict for backward compatibility
    yield {
        "allowed": rate_check.allowed,
        "limit": rate_check.limit,
        "used": rate_check.current_count,
        "remaining": rate_check.remaining,
        "plan_type": rate_check.plan_type.value,
    }

    # Increment monthly usage after successful operation
    await SubscriptionService.increment_usage(
        user_id=user_id,
        operation_type=operation_type,
        db=db,
        count=count,
    )
