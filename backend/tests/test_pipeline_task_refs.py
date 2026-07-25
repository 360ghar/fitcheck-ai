"""Regression: background pipeline tasks must be strongly referenced.

``asyncio.create_task`` returns a task the event loop only holds a *weak*
reference to. A route that discards the return value can have its pipeline
garbage-collected mid-run: the job then sits in PROCESSING until the 30-minute
TTL evicts it, ``/status`` starts 404ing, and the daily quota was already spent.

These tests drive the real routes and assert the module-level strong-reference
set is populated while the pipeline runs and drained after it finishes. They
deliberately do not assert "create_task was called" — that passed before the
fix.
"""

import asyncio

import pytest

from app.services.batch_job_service import BatchJobService
from app.services.photoshoot_job_service import PhotoshootJobService


@pytest.fixture(autouse=True)
def _clear_job_stores():
    BatchJobService._jobs.clear()
    PhotoshootJobService._jobs.clear()
    yield
    BatchJobService._jobs.clear()
    PhotoshootJobService._jobs.clear()


class _StubUsage:
    remaining = 100


@pytest.mark.asyncio
async def test_photoshoot_generate_holds_strong_ref_to_pipeline_task(monkeypatch):
    from app.api.v1 import photoshoot as ps
    from app.models.photoshoot import PhotoshootUseCase, StartPhotoshootRequest
    from app.services.photoshoot_service import (
        PhotoshootService,
        PhotoshootStreamingService,
    )

    release = asyncio.Event()
    ran_to_completion = asyncio.Event()

    async def _fake_check_daily_limit(user_id, num_images, db):
        return True, _StubUsage()

    async def _fake_run_pipeline(self, job):
        await release.wait()
        ran_to_completion.set()

    monkeypatch.setattr(
        PhotoshootService, "check_daily_limit", staticmethod(_fake_check_daily_limit)
    )
    monkeypatch.setattr(PhotoshootStreamingService, "run_pipeline", _fake_run_pipeline)

    assert not ps._pipeline_tasks, "leaked tasks from a previous test"

    body = StartPhotoshootRequest(
        photos=["ZmFrZS1waG90bw=="],
        use_case=PhotoshootUseCase.AESTHETIC,
        num_images=1,
    )
    result = await ps.generate_photoshoot(
        body=body, sync=False, db=object(), user={"id": "u1"}
    )
    assert result["data"]["job_id"]

    # While the pipeline is in flight the route must hold a strong reference,
    # otherwise the only reference is the loop's weak one.
    assert len(ps._pipeline_tasks) == 1
    task = next(iter(ps._pipeline_tasks))

    release.set()
    await task

    assert ran_to_completion.is_set(), "pipeline did not run to completion"
    # add_done_callback must clean the set up so it is not a leak.
    assert ps._pipeline_tasks == set()


@pytest.mark.asyncio
async def test_batch_start_holds_strong_ref_to_pipeline_task(monkeypatch):
    """Sibling coverage: batch already had the fix; keep it from regressing."""
    from app.api.v1 import batch_processing as bp
    from app.services.batch_extraction_service import BatchExtractionService

    release = asyncio.Event()
    ran_to_completion = asyncio.Event()

    async def _no_rate_limit(**kwargs):
        return None

    async def _fake_run_pipeline(self, job):
        await release.wait()
        ran_to_completion.set()

    monkeypatch.setattr(bp, "_check_batch_rate_limits", _no_rate_limit)
    monkeypatch.setattr(BatchExtractionService, "run_pipeline", _fake_run_pipeline)

    assert not bp._pipeline_tasks, "leaked tasks from a previous test"

    response = await bp._start_batch_job(
        user_id="u1",
        db=object(),
        images_data=[{"image_id": "img1", "image_base64": "abc"}],
        auto_generate=False,
        generation_batch_size=1,
    )
    assert response.job_id

    assert len(bp._pipeline_tasks) == 1
    task = next(iter(bp._pipeline_tasks))

    release.set()
    await task

    assert ran_to_completion.is_set()
    assert bp._pipeline_tasks == set()
