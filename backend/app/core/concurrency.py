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
from contextlib import asynccontextmanager
from contextvars import ContextVar
from typing import AsyncIterator, Dict, Set

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

# Task id -> set of lock object ids held by that task. Reentrancy bookkeeping
# for KeyedLock (an asyncio.Lock is not reentrant; nested acquisition of a
# lock the current task already holds would deadlock). Keyed by task id (not
# a ContextVar) so child tasks spawned inside a held section still acquire
# the lock for real.
_HELD_LOCKS: Dict[int, Set[int]] = {}


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


class KeyedLock:
    """In-process per-key mutual exclusion (e.g. one lock per user id).

    Used to serialize short critical sections that a database unique
    constraint cannot express (A1-17: concurrent body-profile creates both
    deciding they are the first and setting ``is_default``). The registry is
    bounded: when the key count passes ``max_keys``, an unlocked lock is
    evicted to make room, so a high-cardinality key space (one key per user)
    cannot grow the dict forever. Locks are process-local by design —
    cross-process serialization must come from the database.
    """

    def __init__(self, max_keys: int = 4096) -> None:
        self._locks: Dict[str, asyncio.Lock] = {}
        self._guard = asyncio.Lock()
        self._max_keys = max_keys

    async def _get(self, key: str) -> asyncio.Lock:
        async with self._guard:
            lock = self._locks.get(key)
            if lock is None:
                if len(self._locks) >= self._max_keys:
                    evicted = False
                    for candidate, existing in list(self._locks.items()):
                        if not existing.locked():
                            del self._locks[candidate]
                            evicted = True
                            break
                    if not evicted:
                        # A5-08: every cached lock is contended — do not grow
                        # the dict past max_keys. Serialize the caller on a
                        # stable existing lock instead (choosing a fixed
                        # victim keeps the mapping bounded and the fallback
                        # lock itself stable across calls). Cross-key
                        # serialization is a strict superset of the intended
                        # guarantee — safe, just slightly less concurrent.
                        # F1-A5b: never return a lock the CURRENT TASK
                        # already holds — asyncio.Lock is not reentrant, so
                        # nested acquisition of the same lock object would
                        # deadlock (observed in
                        # test_keyed_lock_busy_lock_is_not_evicted).
                        task_held = _HELD_LOCKS.get(id(asyncio.current_task()), ())
                        for candidate, existing in list(self._locks.items()):
                            if id(existing) not in task_held:
                                return existing
                        # Every cached lock is held by THIS task (nested
                        # acquisition with a full registry). Re-acquiring
                        # any of them would deadlock, and waiting on another
                        # task's lock while holding the guard can too. Grow
                        # past the cap: this growth is bounded by the app's
                        # lock-nesting depth, not by key cardinality.
                        lock = asyncio.Lock()
                        self._locks[key] = lock
                        return lock
                lock = asyncio.Lock()
                self._locks[key] = lock
            return lock

    @asynccontextmanager
    async def __call__(self, key: str) -> AsyncIterator[None]:
        """Acquire the lock for ``key``: ``async with keyed_lock(key): ...``."""
        lock = await self._get(key)
        # Reentrancy guard: a task that already holds this lock OBJECT (via a
        # direct acquisition or the contended-registry fallback) must not
        # re-acquire it — asyncio.Lock is not reentrant and would deadlock.
        # The record is per task id (not a ContextVar) so child tasks spawned
        # inside a held section still take the lock for real.
        task_id = id(asyncio.current_task())
        held = _HELD_LOCKS.setdefault(task_id, set())
        if id(lock) in held:
            yield
            return
        held.add(id(lock))
        try:
            async with lock:
                yield
        finally:
            held.discard(id(lock))
            if not held:
                _HELD_LOCKS.pop(task_id, None)


PER_USER_LOCK = KeyedLock()
