"""
Rate limiting utilities for AI operations.

Provides a context manager to simplify rate limit checking and usage tracking.
"""

from contextlib import asynccontextmanager
from typing import Any, Dict, Optional

from supabase import Client

from app.core.exceptions import RateLimitError
from app.services.ai_settings_service import AISettingsService


@asynccontextmanager
async def rate_limited_operation(
    user_id: str,
    operation_type: str,
    db: Client,
    count: int = 1,
):
    """
    Context manager for rate-limited AI operations.

    Checks rate limit before yielding, increments usage after successful completion.

    Args:
        user_id: The user performing the operation
        operation_type: Type of operation ("extraction", "generation", "embedding")
        db: Supabase client
        count: Number of operations (for batch operations)

    Yields:
        Rate check result dict with 'limit', 'used', 'remaining' keys

    Raises:
        RateLimitError: If rate limit is exceeded
    """
    rate_check = await AISettingsService.check_rate_limit(
        user_id=user_id,
        operation_type=operation_type,
        db=db,
        count=count,
    )
    if not rate_check["allowed"]:
        msg = f"Daily {operation_type} limit ({rate_check['limit']}) exceeded."
        if count > 1:
            msg += f" Requested {count} with {rate_check['remaining']} remaining."
        raise RateLimitError(msg)

    yield rate_check

    await AISettingsService.increment_usage(
        user_id=user_id,
        operation_type=operation_type,
        db=db,
        count=count,
    )
