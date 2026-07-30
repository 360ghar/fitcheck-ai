"""
Retry utility with exponential backoff for async operations.

Provides robust retry logic for async functions with configurable
exponential backoff and jitter to prevent thundering herd problems.
"""

import asyncio
import random
import logging
from typing import TypeVar, Callable, Awaitable, Optional, Tuple, Type

logger = logging.getLogger(__name__)

T = TypeVar("T")


def is_retryable_error(exc: Exception) -> bool:
    """True when an exception opts into retries via a truthy ``retryable`` flag.

    Used with AIServiceError (and any other exception that sets ``retryable``)
    so permanent failures (401/400) fail fast while 429/503 still back off.
    """
    return bool(getattr(exc, "retryable", False))


def _calculate_delay(
    attempt: int,
    initial_delay: float,
    max_delay: float,
    backoff_factor: float,
    jitter: bool,
) -> float:
    """Calculate delay with exponential backoff and optional jitter."""
    exponential_delay = initial_delay * (backoff_factor ** attempt)
    bounded_delay = min(exponential_delay, max_delay)

    if jitter:
        # Add random jitter between 0-50% of the delay
        jitter_amount = bounded_delay * random.random() * 0.5
        return bounded_delay + jitter_amount

    return bounded_delay


async def with_retry(
    fn: Callable[[], Awaitable[T]],
    max_retries: int = 3,
    initial_delay: float = 1.0,
    max_delay: float = 30.0,
    backoff_factor: float = 2.0,
    jitter: bool = True,
    retryable_exceptions: Tuple[Type[Exception], ...] = (Exception,),
    on_retry: Optional[Callable[[int, Exception, float], None]] = None,
    should_retry: Optional[Callable[[Exception], bool]] = None,
) -> T:
    """
    Execute an async function with exponential backoff retry logic.

    Args:
        fn: The async function to execute (should be a zero-argument callable)
        max_retries: Maximum number of retry attempts
        initial_delay: Initial delay in seconds before first retry
        max_delay: Maximum delay between retries in seconds
        backoff_factor: Exponential backoff multiplier
        jitter: Add random jitter to prevent thundering herd
        retryable_exceptions: Tuple of exception types that should trigger retry
        on_retry: Optional callback called before each retry with (attempt, error, delay)
        should_retry: Optional predicate; if it returns False the exception is
            re-raised immediately without further retries (e.g. non-retryable
            AIServiceError after a 401).

    Returns:
        The result of the function call

    Raises:
        The last exception if all retries are exhausted
    """
    last_exception: Optional[Exception] = None

    for attempt in range(max_retries + 1):
        try:
            return await fn()
        except retryable_exceptions as e:
            last_exception = e

            if should_retry is not None and not should_retry(e):
                raise

            if attempt >= max_retries:
                logger.warning(
                    f"All {max_retries + 1} attempts failed, raising exception",
                    exc_info=True,
                )
                raise

            delay = _calculate_delay(
                attempt, initial_delay, max_delay, backoff_factor, jitter
            )
            # If the failing provider told us how long to wait (e.g. Gemini's
            # RetryInfo "56s" for a per-minute free-tier quota), honour it as a
            # floor so the retry actually lands after the reset window instead
            # of hammering every 2s. Bounded by max_delay.
            advised = getattr(e, "retry_after_seconds", None)
            if advised:
                delay = max(delay, min(float(advised), max_delay))

            logger.info(
                f"Retry attempt {attempt + 1}/{max_retries} after {delay:.2f}s delay"
            )

            if on_retry:
                on_retry(attempt + 1, e, delay)

            await asyncio.sleep(delay)

    # This should never be reached, but just in case
    if last_exception:
        raise last_exception
    raise RuntimeError("Unexpected state in retry logic")
