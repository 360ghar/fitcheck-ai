"""
Tests for the shared, reentrant image-generation concurrency slot.

The 2026-08-03 production incident class: try-on/outfit generation ran with no
process-wide cap, and a concurrent image-gen storm OOM-killed the container
(TD-044). Every image-generation caller now acquires GENERATION_SEMAPHORE
through image_gen_slot(), which is reentrant per task because entry points
nest (variations -> generate_outfit -> _generate_with_references; batch ->
generate_product_image -> _generate_image) and asyncio.Semaphore is not.
"""

import asyncio

import pytest

from app.core.concurrency import image_gen_slot


@pytest.mark.asyncio
async def test_image_gen_slot_acquires_and_releases(monkeypatch):
    sem = asyncio.Semaphore(2)
    monkeypatch.setattr("app.core.concurrency.GENERATION_SEMAPHORE", sem)

    assert sem._value == 2
    async with image_gen_slot():
        assert sem._value == 1
    assert sem._value == 2


@pytest.mark.asyncio
async def test_image_gen_slot_is_reentrant_within_task(monkeypatch):
    """A nested acquisition from the same task must not deadlock (a plain
    Semaphore would block on the slot it already holds) and must not
    double-count the held slot."""
    sem = asyncio.Semaphore(1)
    monkeypatch.setattr("app.core.concurrency.GENERATION_SEMAPHORE", sem)

    async with image_gen_slot():
        async with image_gen_slot():
            assert sem._value == 0
        # Inner exit released nothing - still held by the outer scope.
        assert sem._value == 0
    assert sem._value == 1


@pytest.mark.asyncio
async def test_image_gen_slot_serializes_concurrent_tasks(monkeypatch):
    """Two independent tasks still contend for the one shared slot."""
    sem = asyncio.Semaphore(1)
    monkeypatch.setattr("app.core.concurrency.GENERATION_SEMAPHORE", sem)

    order = []

    async def worker(name: str) -> None:
        async with image_gen_slot():
            order.append(f"start-{name}")
            await asyncio.sleep(0.01)
            order.append(f"end-{name}")

    await asyncio.gather(worker("a"), worker("b"))

    assert order == ["start-a", "end-a", "start-b", "end-b"]


@pytest.mark.asyncio
async def test_image_gen_slot_releases_on_exception(monkeypatch):
    sem = asyncio.Semaphore(1)
    monkeypatch.setattr("app.core.concurrency.GENERATION_SEMAPHORE", sem)

    with pytest.raises(RuntimeError, match="boom"):
        async with image_gen_slot():
            raise RuntimeError("boom")

    assert sem._value == 1
