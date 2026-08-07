"""Tests for parallel_with_retry's should_retry predicate.

Permanent 4xx-style errors (invalid image bytes, unsupported media type) can
never succeed on retry, yet the items upload retried them 3 extra times per
file ("All 4 attempts failed" observed 2026-08-03) because every exception
type was retryable by default. The predicate lets callers fail those fast
while transient failures still back off.
"""

import pytest

from app.core.exceptions import UnsupportedMediaTypeError
from app.utils.parallel import parallel_with_retry


@pytest.mark.asyncio
async def test_permanent_error_is_not_retried():
    calls = {"n": 0}

    async def fail(item, index):
        calls["n"] += 1
        raise UnsupportedMediaTypeError(allowed_types=["image/jpeg"])

    results = await parallel_with_retry(
        [1],
        fail,
        max_retries=3,
        initial_delay=0.0,
        should_retry=lambda e: not isinstance(e, UnsupportedMediaTypeError),
    )

    assert results[0].success is False
    assert isinstance(results[0].error, UnsupportedMediaTypeError)
    assert calls["n"] == 1  # exactly one attempt, no retries


@pytest.mark.asyncio
async def test_transient_error_still_retries_and_recovers():
    calls = {"n": 0}

    async def flaky(item, index):
        calls["n"] += 1
        if calls["n"] < 3:
            raise ConnectionError("storage gateway restarted")
        return "ok"

    results = await parallel_with_retry(
        [1],
        flaky,
        max_retries=3,
        initial_delay=0.0,
        should_retry=lambda e: not isinstance(e, UnsupportedMediaTypeError),
    )

    assert results[0].success is True
    assert results[0].data == "ok"
    assert calls["n"] == 3


@pytest.mark.asyncio
async def test_mixed_items_are_independent():
    """One permanently-bad file must not block (or retry along with) a
    healthy file in the same batch."""
    calls = {"bad": 0, "good": 0}

    async def upload(item, index):
        if index == 0:
            calls["bad"] += 1
            raise UnsupportedMediaTypeError(allowed_types=["image/jpeg"])
        calls["good"] += 1
        return f"url-{index}"

    results = await parallel_with_retry(
        ["bad.jpg", "good.jpg"],
        upload,
        max_retries=3,
        initial_delay=0.0,
        should_retry=lambda e: not isinstance(e, UnsupportedMediaTypeError),
    )

    assert [r.success for r in results] == [False, True]
    assert results[1].data == "url-1"
    assert calls["bad"] == 1
    assert calls["good"] == 1
