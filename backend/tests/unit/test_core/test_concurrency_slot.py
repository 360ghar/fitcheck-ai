"""
Tests for the shared, reentrant image-generation concurrency slots.

Two gates, both reentrant per task:

* GENERATION_SEMAPHORE via image_gen_slot() bounds OUR memory. The 2026-08-03
  production incident class: try-on/outfit generation ran with no process-wide
  cap, and a concurrent image-gen storm OOM-killed the container (TD-044).
* IMAGE_PROVIDER_SEMAPHORE via provider_image_slot() bounds the fan-out at the
  shared image gateway, which enforces its own cap and answered
  "WARNING: Exceeded concurrency limit." to a 30-wide batch (2026-09-17).

Both are reentrant because entry points nest (variations -> generate_outfit ->
_generate_with_references; batch -> generate_product_image ->
_generate_image) and asyncio.Semaphore is not.
"""

import asyncio

import pytest

from app.core.concurrency import image_gen_slot, provider_image_slot


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


@pytest.mark.asyncio
async def test_provider_image_slot_acquires_and_releases(monkeypatch):
    sem = asyncio.Semaphore(4)
    monkeypatch.setattr("app.core.concurrency.IMAGE_PROVIDER_SEMAPHORE", sem)

    assert sem._value == 4
    async with provider_image_slot():
        assert sem._value == 3
    assert sem._value == 4


@pytest.mark.asyncio
async def test_provider_image_slot_is_reentrant_within_task(monkeypatch):
    sem = asyncio.Semaphore(1)
    monkeypatch.setattr("app.core.concurrency.IMAGE_PROVIDER_SEMAPHORE", sem)

    async with provider_image_slot():
        async with provider_image_slot():
            assert sem._value == 0
        assert sem._value == 0
    assert sem._value == 1


@pytest.mark.asyncio
async def test_provider_image_slot_still_binds_inside_a_generation_slot(monkeypatch):
    """Each gate needs its OWN held-state flag: if the provider slot shared the
    generation ContextVar, acquiring it inside a generation slot would be a
    silent no-op and the provider cap would stop binding - exactly the
    2026-09-17 failure mode."""
    gen_sem = asyncio.Semaphore(1)
    provider_sem = asyncio.Semaphore(1)
    monkeypatch.setattr("app.core.concurrency.GENERATION_SEMAPHORE", gen_sem)
    monkeypatch.setattr("app.core.concurrency.IMAGE_PROVIDER_SEMAPHORE", provider_sem)

    async with image_gen_slot():
        assert gen_sem._value == 0
        async with provider_image_slot():
            assert provider_sem._value == 0
        assert provider_sem._value == 1
    assert gen_sem._value == 1


@pytest.mark.asyncio
async def test_provider_image_slot_serializes_concurrent_tasks(monkeypatch):
    sem = asyncio.Semaphore(1)
    monkeypatch.setattr("app.core.concurrency.IMAGE_PROVIDER_SEMAPHORE", sem)

    order = []

    async def worker(name: str) -> None:
        async with provider_image_slot():
            order.append(f"start-{name}")
            await asyncio.sleep(0.01)
            order.append(f"end-{name}")

    await asyncio.gather(worker("a"), worker("b"))

    assert order == ["start-a", "end-a", "start-b", "end-b"]


@pytest.mark.asyncio
async def test_provider_image_slot_releases_on_exception(monkeypatch):
    sem = asyncio.Semaphore(1)
    monkeypatch.setattr("app.core.concurrency.IMAGE_PROVIDER_SEMAPHORE", sem)

    with pytest.raises(RuntimeError, match="boom"):
        async with provider_image_slot():
            raise RuntimeError("boom")

    assert sem._value == 1
