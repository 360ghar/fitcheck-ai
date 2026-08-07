"""Tests for app.core.image_executor: the bounded image-processing pool.

The 2026-08-03 OOM fix: `asyncio.to_thread` sizes its pool to host cores
(up to 32 on Railway), letting that many full-res Pillow decodes buffer tens
of MB each simultaneously. image_executor owns ONE pool with a small fixed
width (IMAGE_PROCESS_WORKERS, default 4) and is what every CPU-bound image
op runs on.
"""

import asyncio
import time

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

    def slow_op():
        peak["n"] += 1
        try:
            time.sleep(0.3)
            return "ok"
        finally:
            peak["n"] -= 1

    async def main():
        await asyncio.gather(*(image_executor.run_image_op(slow_op) for _ in range(8)))
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
