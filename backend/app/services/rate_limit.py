"""
Rate limiting utilities for AI operations.

Provides a context manager to simplify rate limit checking and usage tracking.
Uses subscription-based monthly limits as primary, with daily limits as fallback.
"""

from contextlib import asynccontextmanager
from typing import Union

from supabase import Client

from app.core.exceptions import RateLimitError
from app.models.subscription import OperationType
from app.services.subscription_service import SubscriptionService


@asynccontextmanager
async def rate_limited_operation(
    user_id: str,
    operation_type: Union[OperationType, str],
    db: Client,
    count: int = 1,
):
    """
    Context manager for rate-limited AI operations.

    Uses subscription-based monthly limits. Checks rate limit before yielding,
    increments usage after successful completion.

    Args:
        user_id: The user performing the operation
        operation_type: OperationType (or its string value) - one of
            OperationType.EXTRACTION / GENERATION / EMBEDDING.
        db: Supabase client
        count: Number of operations (for batch operations)

    Yields:
        Rate check result dict with 'limit', 'current_count', 'remaining', 'plan_type' keys

    Raises:
        RateLimitError: If rate limit is exceeded
        ValueError: If operation_type is not a known OperationType.
    """
    # Normalize at the boundary so the rest of this function (and downstream
    # SubscriptionService calls) can rely on a typed value. Unknown strings
    # raise ValueError here rather than silently branching at the DB layer.
    op = OperationType(operation_type) if not isinstance(operation_type, OperationType) else operation_type

    # Check subscription-based monthly limit
    rate_check = await SubscriptionService.check_limit(
        user_id=user_id,
        operation_type=op,
        db=db,
        count=count,
    )

    if not rate_check.allowed:
        plan_name = SubscriptionService.plan_display_name(rate_check.plan_type)
        msg = f"Monthly {op.value} limit ({rate_check.limit}) exceeded on {plan_name} plan."
        if count > 1:
            msg += f" Requested {count} with {rate_check.remaining} remaining."
        # Only upsell when a higher tier exists - never tell a Pro user to
        # "upgrade to Pro".
        if SubscriptionService.can_upgrade(rate_check.plan_type):
            msg += " Upgrade to Pro for more!"
        raise RateLimitError(msg)

    # Reserve usage before yielding (not after the operation completes) so
    # concurrent requests can't all read the same pre-increment count and
    # collectively exceed the limit. Matches auth_rate_limited_operation's
    # already-correct pattern, which also counts every attempt rather than
    # only successful ones - appropriate here too since a failed AI call
    # still costs real provider spend.
    await SubscriptionService.increment_usage(
        user_id=user_id,
        operation_type=op,
        db=db,
        count=count,
    )

    # Convert to dict for backward compatibility
    yield {
        "allowed": rate_check.allowed,
        "limit": rate_check.limit,
        "used": rate_check.current_count,
        "remaining": rate_check.remaining - count,
        "plan_type": rate_check.plan_type.value,
    }
