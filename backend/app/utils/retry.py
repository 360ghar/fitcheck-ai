"""
Retry utility with exponential backoff for async operations.

Provides robust retry logic for async functions with configurable
exponential backoff and jitter to prevent thundering herd problems.
"""

import asyncio
import random
import logging
from typing import TypeVar, Callable, Awaitable, Optional, Tuple, Type
from dataclasses import dataclass, field

logger = logging.getLogger(__name__)

T = TypeVar("T")


@dataclass
class RetryConfig:
    """Configuration for retry behavior."""

    max_retries: int = 3
    """Maximum number of retry attempts."""

    initial_delay: float = 1.0
    """Initial delay in seconds before first retry."""

    max_delay: float = 30.0
    """Maximum delay between retries in seconds."""

    backoff_factor: float = 2.0
    """Exponential backoff multiplier."""

    jitter: bool = True
    """Add random jitter to prevent thundering herd."""

    retryable_exceptions: Tuple[Type[Exception], ...] = field(
        default_factory=lambda: (Exception,)
    )
    """Exception types that should trigger a retry."""


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

            if attempt >= max_retries:
                logger.warning(
                    f"All {max_retries + 1} attempts failed, raising exception",
                    exc_info=True,
                )
                raise

            delay = _calculate_delay(
                attempt, initial_delay, max_delay, backoff_factor, jitter
            )

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


def retry_decorator(
    max_retries: int = 3,
    initial_delay: float = 1.0,
    max_delay: float = 30.0,
    backoff_factor: float = 2.0,
    jitter: bool = True,
    retryable_exceptions: Tuple[Type[Exception], ...] = (Exception,),
):
    """
    Decorator version of with_retry for async functions.

    Usage:
        @retry_decorator(max_retries=3)
        async def my_function():
            ...
    """

    def decorator(fn: Callable[..., Awaitable[T]]) -> Callable[..., Awaitable[T]]:
        async def wrapper(*args, **kwargs) -> T:
            return await with_retry(
                lambda: fn(*args, **kwargs),
                max_retries=max_retries,
                initial_delay=initial_delay,
                max_delay=max_delay,
                backoff_factor=backoff_factor,
                jitter=jitter,
                retryable_exceptions=retryable_exceptions,
            )

        return wrapper

    return decorator
