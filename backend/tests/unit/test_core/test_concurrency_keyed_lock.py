"""Unit tests for app.core.concurrency.KeyedLock (A1-17).

The per-user lock serializes read-modify-write sections that a database
unique constraint cannot express — e.g. "first body profile becomes the
default" — so concurrent coroutines for the SAME key must not interleave,
while DIFFERENT keys must not block each other, and the registry must stay
bounded (one lock per key, evicting idle locks once the cap is passed).
"""

import asyncio

import pytest

from app.core.concurrency import PER_USER_LOCK, KeyedLock


@pytest.mark.asyncio
async def test_keyed_lock_serializes_same_key():
    lock = KeyedLock()
    order = []
    in_critical = 0
    max_concurrent = 0

    async def worker(name):
        nonlocal in_critical, max_concurrent
        async with lock(f"user-{name}"):
            in_critical += 1
            max_concurrent = max(max_concurrent, in_critical)
            order.append(name)
            await asyncio.sleep(0.01)
            in_critical -= 1

    # Same key ("user-1" for all) must serialize: at most one inside.
    await asyncio.gather(*(worker("1") for _ in range(5)))
    assert max_concurrent == 1
    assert order == ["1"] * 5


@pytest.mark.asyncio
async def test_keyed_lock_different_keys_do_not_block_each_other():
    lock = KeyedLock()
    in_critical = 0
    max_concurrent = 0

    async def worker(key):
        nonlocal in_critical, max_concurrent
        async with lock(key):
            in_critical += 1
            max_concurrent = max(max_concurrent, in_critical)
            await asyncio.sleep(0.01)
            in_critical -= 1

    await asyncio.gather(*(worker(f"user-{i}") for i in range(5)))
    assert max_concurrent == 5


@pytest.mark.asyncio
async def test_keyed_lock_registry_is_bounded():
    lock = KeyedLock(max_keys=4)
    for i in range(4):
        async with lock(f"k{i}"):
            pass
    assert len(lock._locks) == 4
    # A new key over the cap evicts an idle lock instead of growing.
    async with lock("k4"):
        pass
    assert len(lock._locks) <= 4


@pytest.mark.asyncio
async def test_keyed_lock_busy_lock_is_not_evicted():
    lock = KeyedLock(max_keys=2)
    async with lock("busy"):
        async with lock("k2"):
            async with lock("k3"):
                # All three are held concurrently, so none may be evicted
                # (evicting a held lock would corrupt mutual exclusion).
                assert len(lock._locks) == 3
                assert lock._locks["busy"] is not None
    # Once idle, a NEW key can evict an unlocked lock to stay bounded.
    async with lock("k4"):
        assert len(lock._locks) <= 3


@pytest.mark.asyncio
async def test_keyed_lock_nested_full_registry_does_not_deadlock():
    # Regression: the contended-registry fallback used to return an ARBITRARY
    # cached lock — when every lock was held by the CURRENT task (nested
    # acquisition with a full registry), re-acquiring one deadlocked forever
    # (asyncio.Lock is not reentrant).
    lock = KeyedLock(max_keys=2)
    order = []

    async def holder():
        async with lock("busy"):
            async with lock("k2"):
                # Both slots held by this task; k3 must get its own lock
                # rather than re-acquiring one already held.
                async with lock("k3"):
                    order.append("held")
                    await asyncio.sleep(0.01)

    await asyncio.wait_for(holder(), timeout=5)
    assert order == ["held"]


@pytest.mark.asyncio
async def test_keyed_lock_fallback_serializes_other_tasks():
    # When the registry is full, a NEW key falls back onto an existing
    # (contended) lock: a different task must WAIT, never run concurrently
    # inside the holder's section.
    lock = KeyedLock(max_keys=2)
    order = []

    async def holder():
        async with lock("busy"):
            async with lock("k2"):
                await asyncio.sleep(0.05)
                order.append("holder-release")

    async def contender():
        await asyncio.sleep(0.01)  # let the holder enter first
        async with lock("k9"):
            order.append("contender-enter")

    await asyncio.gather(holder(), contender())
    assert order == ["holder-release", "contender-enter"]


@pytest.mark.asyncio
async def test_keyed_lock_child_task_waits_for_parent():
    # Reentrancy bookkeeping is per task id (not a ContextVar): a child task
    # spawned inside a held section must still acquire the lock for real —
    # it waits for the parent to release rather than skipping the section.
    lock = KeyedLock()
    order = []

    async def child():
        order.append("child-start")
        async with lock("k"):
            order.append("child-held")

    async def parent():
        async with lock("k"):
            order.append("parent-hold")
            task = asyncio.create_task(child())
            await asyncio.sleep(0.02)
            order.append("parent-release")
            # Release happens on exit; only then may the child enter.
        await task

    await parent()
    assert order == ["parent-hold", "child-start", "parent-release", "child-held"]


@pytest.mark.asyncio
async def test_per_user_lock_singleton_is_usable():
    async with PER_USER_LOCK("user-abc"):
        pass
