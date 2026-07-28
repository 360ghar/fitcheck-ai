"""
Regression: in-memory job stores must reclaim failed/expired jobs.

Batch and photoshoot jobs live in process memory and hold large base64
payloads. If a failed or abandoned job is never evicted, memory grows without
bound (the historical OOM driver on single-worker deploys). These tests assert
that:
  * a failure marks the job terminal (so the TTL sweep can reclaim it),
  * finished jobs are evicted after the finished TTL,
  * stale active jobs are evicted after the active TTL,
  * finished jobs free their base64 payloads/history promptly on sweep.
"""

from datetime import datetime, timezone, timedelta

import pytest

from app.models.photoshoot import PhotoshootJobStatus
from app.services.batch_job_service import (
    _ACTIVE_JOB_TTL as BATCH_ACTIVE_TTL,
    _FINISHED_JOB_TTL as BATCH_FINISHED_TTL,
    BatchJobService,
    BatchJobStatus,
)
from app.services.photoshoot_job_service import (
    _ACTIVE_JOB_TTL as PHOTOSHOOT_ACTIVE_TTL,
    _FINISHED_JOB_TTL as PHOTOSHOOT_FINISHED_TTL,
    PhotoshootJobService,
)


@pytest.fixture(autouse=True)
def _clear_job_stores():
    BatchJobService._jobs.clear()
    PhotoshootJobService._jobs.clear()
    yield
    BatchJobService._jobs.clear()
    PhotoshootJobService._jobs.clear()


def _age(job_service, job_id, ttl: timedelta):
    """Backdate a job's created_at so it appears older than the given TTL."""
    job_service._jobs[job_id].created_at = datetime.now(timezone.utc) - (ttl + timedelta(seconds=1))


# ---------------------------------------------------------------------------
# Batch job store
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_batch_set_error_marks_failed_with_message():
    job = await BatchJobService.create_job(
        user_id="u1",
        images=[{"image_id": "img1", "image_base64": "abc"}],
    )
    await BatchJobService.set_error(job.job_id, "kaboom")

    stored = BatchJobService._jobs[job.job_id]
    assert stored.status == BatchJobStatus.FAILED
    assert stored.error_message == "kaboom"


@pytest.mark.asyncio
async def test_batch_failed_job_evicted_after_finished_ttl():
    job = await BatchJobService.create_job(
        user_id="u1",
        images=[{"image_id": "img1", "image_base64": "abc"}],
    )
    await BatchJobService.set_error(job.job_id, "kaboom")
    _age(BatchJobService, job.job_id, BATCH_FINISHED_TTL)

    await BatchJobService._cleanup_expired_jobs()

    assert job.job_id not in BatchJobService._jobs


@pytest.mark.asyncio
async def test_batch_stale_active_job_evicted_after_active_ttl():
    job = await BatchJobService.create_job(
        user_id="u1",
        images=[{"image_id": "img1", "image_base64": "abc"}],
    )
    # Job remains PENDING (active) but is backdated past the active TTL.
    _age(BatchJobService, job.job_id, BATCH_ACTIVE_TTL)

    await BatchJobService._cleanup_expired_jobs()

    assert job.job_id not in BatchJobService._jobs


@pytest.mark.asyncio
async def test_batch_finished_job_frees_payloads_before_eviction():
    job = await BatchJobService.create_job(
        user_id="u1",
        images=[{"image_id": "img1", "image_base64": "payload-data"}],
    )
    await BatchJobService.update_status(job.job_id, BatchJobStatus.COMPLETED)

    # Recent finished job: not evicted yet, but payloads/history freed.
    await BatchJobService._cleanup_expired_jobs()

    stored = BatchJobService._jobs[job.job_id]
    assert stored.images["img1"].image_base64 == ""
    assert stored.event_history == []


# ---------------------------------------------------------------------------
# Photoshoot job store
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_photoshoot_set_error_marks_failed_with_message():
    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["abc"],
        use_case="aesthetic",
        num_images=1,
    )
    await PhotoshootJobService.set_error(job.job_id, "kaboom")

    stored = PhotoshootJobService._jobs[job.job_id]
    assert stored.status == PhotoshootJobStatus.FAILED
    assert stored.error_message == "kaboom"


@pytest.mark.asyncio
async def test_photoshoot_failed_job_evicted_after_finished_ttl():
    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["abc"],
        use_case="aesthetic",
        num_images=1,
    )
    await PhotoshootJobService.set_error(job.job_id, "kaboom")
    _age(PhotoshootJobService, job.job_id, PHOTOSHOOT_FINISHED_TTL)

    await PhotoshootJobService._cleanup_expired_jobs()

    assert job.job_id not in PhotoshootJobService._jobs


@pytest.mark.asyncio
async def test_photoshoot_stale_active_job_evicted_after_active_ttl():
    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["abc"],
        use_case="aesthetic",
        num_images=1,
    )
    _age(PhotoshootJobService, job.job_id, PHOTOSHOOT_ACTIVE_TTL)

    await PhotoshootJobService._cleanup_expired_jobs()

    assert job.job_id not in PhotoshootJobService._jobs


@pytest.mark.asyncio
async def test_photoshoot_finished_job_frees_reference_photos_before_eviction():
    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["ref-photo-base64"],
        use_case="aesthetic",
        num_images=1,
    )
    await PhotoshootJobService.update_status(job.job_id, PhotoshootJobStatus.COMPLETE)

    await PhotoshootJobService._cleanup_expired_jobs()

    stored = PhotoshootJobService._jobs[job.job_id]
    assert stored.photos == []
    assert stored.event_history == []
