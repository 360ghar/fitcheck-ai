"""
Lifespan must yield (accept traffic) without waiting on schema/Pinecone.

Railway healthchecks hit /health as soon as the port binds; awaiting
30–40 sequential Supabase queries before yield made cold deploys flaky.
"""
import asyncio
from unittest.mock import patch

import pytest

import app.main as main_module


@pytest.mark.asyncio
async def test_lifespan_yields_before_background_init_finishes():
    started = asyncio.Event()
    released = asyncio.Event()

    async def slow_background(logger):
        started.set()
        await released.wait()

    with patch.object(
        main_module,
        "_background_startup",
        side_effect=slow_background,
    ):
        async with main_module.lifespan(main_module.app):
            # Let the scheduled background task begin (create_task is lazy
            # until the event loop spins).
            await asyncio.sleep(0)
            assert started.is_set()
            # If lifespan had awaited background work, we would hang above.
            body = await main_module.health_check()
            assert body["status"] == "healthy"
            released.set()


@pytest.mark.asyncio
async def test_lifespan_cancels_background_task_on_shutdown():
    cancel_seen = asyncio.Event()

    async def hang_until_cancel(logger):
        try:
            await asyncio.Event().wait()
        except asyncio.CancelledError:
            cancel_seen.set()
            raise

    with patch.object(
        main_module,
        "_background_startup",
        side_effect=hang_until_cancel,
    ):
        async with main_module.lifespan(main_module.app):
            await asyncio.sleep(0)  # let background task schedule

    # After exiting the context, background work should have been cancelled
    assert cancel_seen.is_set()
