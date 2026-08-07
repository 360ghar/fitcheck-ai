"""Residual branch coverage for app.utils.parallel.

Sibling files cover parallel_with_retry's retry predicate logic; this file
covers the on_item_complete callback failure branch, parallel_map with a
callback, and parallel_map_settled's failure path.
"""

import pytest

from app.utils.parallel import parallel_map, parallel_map_settled, parallel_with_retry


@pytest.mark.asyncio
async def test_parallel_with_retry_callback_failure_is_swallowed():
    async def ok(item, index):
        return item * 2

    def on_item_complete(index, result):
        if index == 0:
            raise RuntimeError("callback boom")

    results = await parallel_with_retry(
        [1, 2], ok, max_retries=0, initial_delay=0.0, on_item_complete=on_item_complete
    )
    assert [r.success for r in results] == [True, True]
    assert [r.data for r in results] == [2, 4]
    assert results[0].index == 0
    assert results[1].index == 1


@pytest.mark.asyncio
async def test_parallel_with_retry_failure_records_error_without_traceback():
    async def boom(item, index):
        raise ValueError(f"bad-{item}")

    results = await parallel_with_retry(
        [1, 2], boom, max_retries=0, initial_delay=0.0
    )
    assert [r.success for r in results] == [False, False]
    assert str(results[0].error) == "bad-1"
    assert results[0].error.__traceback__ is None


@pytest.mark.asyncio
async def test_parallel_map_with_callback():
    seen = []

    async def double(item):
        return item * 2

    def on_item_complete(index, result):
        seen.append((index, result))

    results = await parallel_map([1, 2, 3], double, on_item_complete=on_item_complete)
    assert results == [2, 4, 6]
    assert sorted(seen) == [(0, 2), (1, 4), (2, 6)]


@pytest.mark.asyncio
async def test_parallel_map_empty_items():
    assert await parallel_map([], lambda x: x) == []


@pytest.mark.asyncio
async def test_parallel_map_without_callback():
    async def double(item):
        return item * 2

    assert await parallel_map([1, 2], double) == [2, 4]


@pytest.mark.asyncio
async def test_parallel_map_settled_failure_path():
    async def flaky(item):
        if item == "bad":
            raise ConnectionError("nope")
        return f"ok-{item}"

    results = await parallel_map_settled(["good", "bad", "good2"], flaky)
    assert [r.success for r in results] == [True, False, True]
    assert results[0].data == "ok-good"
    assert isinstance(results[1].error, ConnectionError)
    assert results[1].error.__traceback__ is None
    assert results[1].index == 1
    assert results[2].data == "ok-good2"
