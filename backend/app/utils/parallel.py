"""
Parallel execution utilities with retry support.

Provides utilities for processing multiple items in parallel
with individual retry logic for each item.
"""

import asyncio
import logging
from typing import TypeVar, List, Callable, Awaitable, Any, Optional, Tuple, Type
from dataclasses import dataclass

from .retry import with_retry

logger = logging.getLogger(__name__)

T = TypeVar("T")
I = TypeVar("I")


@dataclass
class ParallelResult:
    """Result of a parallel operation for a single item."""

    success: bool
    """Whether the operation succeeded."""

    data: Any = None
    """The result data if successful."""

    error: Optional[Exception] = None
    """The error if failed."""

    index: int = 0
    """The index of this item in the original list."""


async def parallel_with_retry(
    items: List[I],
    fn: Callable[[I, int], Awaitable[T]],
    max_retries: int = 3,
    initial_delay: float = 1.0,
    max_delay: float = 30.0,
    backoff_factor: float = 2.0,
    jitter: bool = True,
    retryable_exceptions: Tuple[Type[Exception], ...] = (Exception,),
    on_item_complete: Optional[Callable[[int, "ParallelResult"], None]] = None,
) -> List[ParallelResult]:
    """
    Process items in parallel with individual retry logic for each.

    Each item is processed independently - if one fails, others continue.
    Each item gets its own retry attempts with exponential backoff.

    Args:
        items: List of items to process
        fn: Async function to apply to each item. Takes (item, index) as arguments.
        max_retries: Maximum retry attempts per item
        initial_delay: Initial delay before first retry
        max_delay: Maximum delay between retries
        backoff_factor: Exponential backoff multiplier
        jitter: Add random jitter to delays
        retryable_exceptions: Exception types that trigger retry
        on_item_complete: Optional callback when each item completes (success or failure)

    Returns:
        List of ParallelResult objects in the same order as input items
    """

    async def process_item(item: I, index: int) -> ParallelResult:
        try:
            result = await with_retry(
                lambda: fn(item, index),
                max_retries=max_retries,
                initial_delay=initial_delay,
                max_delay=max_delay,
                backoff_factor=backoff_factor,
                jitter=jitter,
                retryable_exceptions=retryable_exceptions,
            )
            pr = ParallelResult(success=True, data=result, index=index)
        except Exception as e:
            logger.warning(f"Item {index} failed after all retries: {e}")
            pr = ParallelResult(success=False, error=e, index=index)

        if on_item_complete:
            try:
                on_item_complete(index, pr)
            except Exception as callback_error:
                logger.error(f"on_item_complete callback failed: {callback_error}")

        return pr

    # Create tasks for all items
    tasks = [process_item(item, i) for i, item in enumerate(items)]

    # Execute all tasks in parallel
    results = await asyncio.gather(*tasks, return_exceptions=False)

    return results


async def parallel_map(
    items: List[I],
    fn: Callable[[I], Awaitable[T]],
    on_item_complete: Optional[Callable[[int, T], None]] = None,
) -> List[T]:
    """
    Simple parallel map without retry logic.

    Args:
        items: List of items to process
        fn: Async function to apply to each item
        on_item_complete: Optional callback when each item completes

    Returns:
        List of results in the same order as input items

    Raises:
        Exception if any item fails
    """

    async def process_item(item: I, index: int) -> T:
        result = await fn(item)
        if on_item_complete:
            on_item_complete(index, result)
        return result

    tasks = [process_item(item, i) for i, item in enumerate(items)]
    return await asyncio.gather(*tasks)


async def parallel_map_settled(
    items: List[I],
    fn: Callable[[I], Awaitable[T]],
) -> List[ParallelResult]:
    """
    Parallel map that doesn't raise on individual failures.

    Similar to JavaScript's Promise.allSettled().

    Args:
        items: List of items to process
        fn: Async function to apply to each item

    Returns:
        List of ParallelResult objects in the same order as input items
    """

    async def process_item(item: I, index: int) -> ParallelResult:
        try:
            result = await fn(item)
            return ParallelResult(success=True, data=result, index=index)
        except Exception as e:
            return ParallelResult(success=False, error=e, index=index)

    tasks = [process_item(item, i) for i, item in enumerate(items)]
    return await asyncio.gather(*tasks)
