"""
Process-wide concurrency gates for AI extraction and generation.

Single source of truth for the asyncio.Semaphore singletons shared across all
concurrent batch jobs (batch_extraction_service.py) and the outfit-variation
fan-out (image_generation_agent.generate_variations). Caps are configurable via
AI_EXTRACTION_CONCURRENCY / AI_GENERATION_CONCURRENCY (see app/core/config.py).

Built eagerly at import. On Python 3.10+ asyncio.Semaphore() no longer
requires a running event loop, so importing this module outside an asyncio
context (e.g. at FastAPI startup) is safe. Floors at 1 so a misconfigured
env (0/negative) cannot deadlock the pipeline by yielding a zero-cap semaphore.
"""

import asyncio
from contextvars import ContextVar

from app.core.config import settings

EXTRACTION_SEMAPHORE: asyncio.Semaphore = asyncio.Semaphore(
    max(1, settings.AI_EXTRACTION_CONCURRENCY)
)
GENERATION_SEMAPHORE: asyncio.Semaphore = asyncio.Semaphore(
    max(1, settings.AI_GENERATION_CONCURRENCY)
)
REFERENCE_DOWNLOAD_SEMAPHORE: asyncio.Semaphore = asyncio.Semaphore(
    max(1, settings.AI_OUTFIT_ITEM_REFERENCE_DOWNLOAD_CONCURRENCY)
)


_IMAGE_GEN_SLOT_HELD: ContextVar[bool] = ContextVar(
    "image_gen_slot_held", default=False
)


class ImageGenSlot:
    """Reentrant per-task acquisition of GENERATION_SEMAPHORE.

    Every image-generation entry point (try-on, outfit, product, photoshoot,
    batch items, variations) acquires the process-wide GENERATION_SEMAPHORE
    through this manager so ALL callers share ONE concurrency budget instead
    of each running unbounded (2026-08-03: container OOM during a try-on /
    image-gen storm - TD-044; each in-flight request buffers multi-MB base64).

    Reentrancy: entry points nest (variations -> generate_outfit ->
    _generate_with_references; batch -> generate_product_image -> _generate_image),
    and ``asyncio.Semaphore`` is not reentrant - a second acquire from the same
    task would block forever on the slot it already holds. The held-state is
    therefore tracked per task via a ContextVar: the outermost acquisition
    takes the slot; nested acquisitions from the same task are no-ops. Child
    tasks copy the parent context at creation, so work spawned under a held
    slot shares the parent's budget instead of deadlocking.

    Use ``image_gen_slot()`` at every acquisition site - never the raw
    semaphore - so the reentrancy bookkeeping stays consistent.
    """

    def __init__(self) -> None:
        self._token = None

    async def __aenter__(self) -> "ImageGenSlot":
        if _IMAGE_GEN_SLOT_HELD.get():
            self._token = None
            return self
        await GENERATION_SEMAPHORE.acquire()
        self._token = _IMAGE_GEN_SLOT_HELD.set(True)
        return self

    async def __aexit__(self, exc_type, exc, tb) -> None:
        if self._token is not None:
            _IMAGE_GEN_SLOT_HELD.reset(self._token)
            GENERATION_SEMAPHORE.release()


def image_gen_slot() -> ImageGenSlot:
    """Async context manager acquiring the shared image-generation slot.

    Example::

        async with image_gen_slot():
            response = await ai_service.chat(...)
    """
    return ImageGenSlot()
