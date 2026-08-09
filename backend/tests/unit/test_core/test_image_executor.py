"""Tests for app.core.image_executor: the bounded image-processing pool.

The 2026-08-03 OOM fix: `asyncio.to_thread` sizes its pool to host cores
(up to 32 on Railway), letting that many full-res Pillow decodes buffer tens
of MB each simultaneously. image_executor owns ONE pool with a small fixed
width (IMAGE_PROCESS_WORKERS, default 4) and is what every CPU-bound image
op runs on.
"""

import asyncio
import threading

import pytest

from app.core import image_executor
from app.core.config import settings


def test_executor_width_is_bounded(monkeypatch):
    # A low IMAGE_PROCESS_WORKERS must bound concurrent workers even when the
    # host has many cores.
    monkeypatch.setattr(settings, "IMAGE_PROCESS_WORKERS", 2)
    # Fresh module state for this test: force re-creation with the new width.
    image_executor.shutdown()

    peak = {"n": 0}
    # Handshake (no fixed sleeps): every op parks on `release` until the main
    # coroutine has submitted all 8 ops to the pool, so the width bound is
    # what limits concurrency — not timing luck.
    release = threading.Event()

    def slow_op():
        peak["n"] += 1
        try:
            if not release.wait(5):
                raise AssertionError("image op never released")
            return "ok"
        finally:
            peak["n"] -= 1

    async def main():
        # run_image_op returns a Future (loop.run_in_executor); calling it
        # submits the op to the bounded pool immediately.
        ops = [image_executor.run_image_op(slow_op) for _ in range(8)]
        # Yield until every op is running or queued in the executor, then
        # release the parked workers (queued ones drain 2 at a time).
        await asyncio.sleep(0)
        await asyncio.sleep(0)
        release.set()
        await asyncio.gather(*ops)
        return peak["n"]

    assert asyncio.run(main()) == 0
    assert peak["n"] <= 2, f"executor exceeded worker bound: peak {peak['n']}"
    image_executor.shutdown()


@pytest.mark.asyncio
async def test_image_ops_still_succeed():
    result = await image_executor.run_image_op(lambda x: x * 2, 21)
    assert result == 42


def test_shutdown_is_recoverable():
    """shutdown() (called by the app lifespan teardown) must not permanently
    break later run_image_op calls — pytest reuses the process, and any future
    in-process reload would too."""

    async def main():
        return await image_executor.run_image_op(lambda: "alive")

    image_executor.shutdown()
    assert asyncio.run(main()) == "alive"
    image_executor.shutdown()
