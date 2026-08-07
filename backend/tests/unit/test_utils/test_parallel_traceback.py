"""Tests for app.utils.parallel: stored exceptions must not pin payloads.

A retained exception holds its __traceback__ chain, and every frame in that
chain holds its locals — which in the image pipeline are multi-MB base64
strings. Stored exceptions (ParallelResult.error) therefore drop their
tracebacks; the exception TYPE, message, and attributes (retryable) are all
callers inspect.
"""

import pytest

from app.core.exceptions import AIServiceError
from app.utils.parallel import parallel_map_settled, parallel_with_retry


@pytest.mark.asyncio
async def test_parallel_map_settled_stored_exception_has_no_traceback():
    async def fail(item):
        raise ValueError(f"boom {item}")

    results = await parallel_map_settled([1, 2, 3], fail)

    assert [r.success for r in results] == [False, False, False]
    for result in results:
        assert isinstance(result.error, ValueError)
        assert result.error.__traceback__ is None
        # The exception itself (type + message) survives for classification.
        assert "boom" in str(result.error)


@pytest.mark.asyncio
async def test_parallel_with_retry_stored_exception_has_no_traceback():
    async def fail(item, index):
        raise AIServiceError("provider 503", retryable=True)

    results = await parallel_with_retry(
        [1],
        fail,
        max_retries=0,  # no retry delay in tests
    )

    assert results[0].success is False
    error = results[0].error
    assert isinstance(error, AIServiceError)
    assert error.__traceback__ is None
    # is_retryable_error still classifies from the attribute, not the frames.
    from app.utils.retry import is_retryable_error

    assert is_retryable_error(error) is True
    assert is_retryable_error(ValueError("nope")) is False


@pytest.mark.asyncio
async def test_successes_keep_data_and_index():
    async def double(item):
        return item * 2

    results = await parallel_map_settled([1, 2], double)
    assert [r.data for r in results] == [2, 4]
    assert [r.index for r in results] == [0, 1]
