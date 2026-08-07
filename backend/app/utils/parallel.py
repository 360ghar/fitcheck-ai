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
ItemT = TypeVar("ItemT")


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
    items: List[ItemT],
    fn: Callable[[ItemT, int], Awaitable[T]],
    max_retries: int = 3,
    initial_delay: float = 1.0,
    max_delay: float = 30.0,
    backoff_factor: float = 2.0,
    jitter: bool = True,
    retryable_exceptions: Tuple[Type[Exception], ...] = (Exception,),
    on_item_complete: Optional[Callable[[int, "ParallelResult"], None]] = None,
    should_retry: Optional[Callable[[Exception], bool]] = None,
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
        should_retry: Optional predicate; when it returns False for an error
            the item fails immediately without further retries (mirrors
            with_retry). Use it to keep permanent 4xx errors (invalid image
            bytes, auth failures) from burning retry cycles - observed
            2026-08-03: "Uploaded bytes are not a valid image" retried 3
            extra times per file ("All 4 attempts failed") even though the
            error could never clear.

    Returns:
        List of ParallelResult objects in the same order as input items
    """

    async def process_item(item: ItemT, index: int) -> ParallelResult:
        try:
            result = await with_retry(
                lambda: fn(item, index),
                max_retries=max_retries,
                initial_delay=initial_delay,
                max_delay=max_delay,
                backoff_factor=backoff_factor,
                jitter=jitter,
                retryable_exceptions=retryable_exceptions,
                should_retry=should_retry,
            )
            pr = ParallelResult(success=True, data=result, index=index)
        except Exception as e:
            # Drop the traceback chain before storing: a retained exception
            # pins every frame in __traceback__ and their locals — which in
            # the image pipeline hold multi-MB base64 strings — for as long as
            # the ParallelResult lives (potentially the whole job). The
            # exception TYPE, message, and attributes (retryable/error_kind)
            # are all callers ever inspect.
            try:
                e.__traceback__ = None
            except Exception:  # pragma: no cover - clearing traceback never raises
                pass
            logger.warning(
                "Item failed after all retries",
                extra={
                    "item_index": index,
                    "exception_type": type(e).__name__,
                    "exception_message": str(e)[:500],
                },
                exc_info=False,
            )
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
    items: List[ItemT],
    fn: Callable[[ItemT], Awaitable[T]],
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

    async def process_item(item: ItemT, index: int) -> T:
        result = await fn(item)
        if on_item_complete:
            on_item_complete(index, result)
        return result

    tasks = [process_item(item, i) for i, item in enumerate(items)]
    return await asyncio.gather(*tasks)


async def parallel_map_settled(
    items: List[ItemT],
    fn: Callable[[ItemT], Awaitable[T]],
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

    async def process_item(item: ItemT, index: int) -> ParallelResult:
        try:
            result = await fn(item)
            return ParallelResult(success=True, data=result, index=index)
        except Exception as e:
            # Drop the traceback chain before storing: a retained exception
            # pins its frames' locals (multi-MB base64 strings) for as long as
            # the ParallelResult lives. Type/message/attributes are all
            # callers inspect.
            try:
                e.__traceback__ = None
            except Exception:  # pragma: no cover - clearing traceback never raises
                pass
            return ParallelResult(success=False, error=e, index=index)

    tasks = [process_item(item, i) for i, item in enumerate(items)]
    return await asyncio.gather(*tasks)
