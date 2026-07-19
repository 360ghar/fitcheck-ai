"""
Regression: process-wide concurrent job caps and base64 release helpers.

Uncapped in-memory base64 jobs were the leading OOM / restart driver on Railway.
"""
import pytest

from app.core.exceptions import RateLimitError
from app.services.batch_job_service import (
    MAX_CONCURRENT_BATCH_JOBS,
    BatchJobService,
    BatchJobStatus,
)
from app.services.photoshoot_job_service import (
    MAX_CONCURRENT_PHOTOSHOOT_JOBS,
    PhotoshootJobService,
)


@pytest.fixture(autouse=True)
def _clear_job_stores():
    BatchJobService._jobs.clear()
    PhotoshootJobService._jobs.clear()
    yield
    BatchJobService._jobs.clear()
    PhotoshootJobService._jobs.clear()


@pytest.mark.asyncio
async def test_batch_job_cap_rejects_when_full():
    for i in range(MAX_CONCURRENT_BATCH_JOBS):
        await BatchJobService.create_job(
            user_id=f"u{i}",
            images=[{"image_id": "img1", "image_base64": "abc"}],
        )

    with pytest.raises(RateLimitError):
        await BatchJobService.create_job(
            user_id="overflow",
            images=[{"image_id": "img1", "image_base64": "abc"}],
        )


@pytest.mark.asyncio
async def test_batch_release_image_payloads_clears_base64():
    job = await BatchJobService.create_job(
        user_id="u1",
        images=[{"image_id": "img1", "image_base64": "dGVzdA=="}],
    )
    assert job.images["img1"].image_base64 == "dGVzdA=="

    await BatchJobService.release_image_payloads(job.job_id)
    assert BatchJobService._jobs[job.job_id].images["img1"].image_base64 == ""


@pytest.mark.asyncio
async def test_batch_clear_event_history_keeps_generated_for_status():
    job = await BatchJobService.create_job(
        user_id="u1",
        images=[{"image_id": "img1", "image_base64": "dGVzdA=="}],
    )
    await BatchJobService.broadcast_event(
        job.job_id,
        "item_generation_complete",
        {"generated_image_base64": "a" * 1000},
    )
    assert len(BatchJobService._jobs[job.job_id].event_history) == 1

    await BatchJobService.clear_event_history(job.job_id)
    assert BatchJobService._jobs[job.job_id].event_history == []


@pytest.mark.asyncio
async def test_photoshoot_job_cap_rejects_when_full():
    for i in range(MAX_CONCURRENT_PHOTOSHOOT_JOBS):
        await PhotoshootJobService.create_job(
            user_id=f"u{i}",
            photos=["dGVzdA=="],
            use_case="aesthetic",
            num_images=1,
        )

    with pytest.raises(RateLimitError):
        await PhotoshootJobService.create_job(
            user_id="overflow",
            photos=["dGVzdA=="],
            use_case="aesthetic",
            num_images=1,
        )


@pytest.mark.asyncio
async def test_photoshoot_release_reference_photos():
    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["dGVzdA==", "YWJj"],
        use_case="aesthetic",
        num_images=1,
    )
    assert len(job.photos) == 2

    await PhotoshootJobService.release_reference_photos(job.job_id)
    assert PhotoshootJobService._jobs[job.job_id].photos == []


@pytest.mark.asyncio
async def test_batch_finished_jobs_do_not_count_against_cap():
    job = await BatchJobService.create_job(
        user_id="u1",
        images=[{"image_id": "img1", "image_base64": "abc"}],
    )
    await BatchJobService.update_status(job.job_id, BatchJobStatus.COMPLETED)

    # Cap slots free once the job is no longer active
    for i in range(MAX_CONCURRENT_BATCH_JOBS):
        await BatchJobService.create_job(
            user_id=f"u{i}",
            images=[{"image_id": "img1", "image_base64": "abc"}],
        )
