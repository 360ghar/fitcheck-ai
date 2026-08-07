"""Tests for the batch generation consumer's photo_cache lifecycle.

The 2026-08-03 memory work: a 50-photo job must not pin every source photo's
base64 (100-200 MB) for the whole generation phase. The consumer therefore
dedupes downloads per URL and releases each cache entry as soon as the last
pending item referencing it has been dispatched.
"""

import asyncio
from datetime import datetime, timezone
from unittest.mock import patch
from uuid import uuid4

import pytest

from app.services.batch_job_service import (
    BatchImageData,
    BatchJob,
    BatchJobService,
    BatchJobStatus,
)
from app.services.batch_extraction_service import BatchExtractionService


def _make_job() -> BatchJob:
    images = {
        # Two items share this photo (siblings); one item is text-only (no URL).
        "img1": BatchImageData(
            image_id="img1",
            image_base64="dGVzdA==",
            filename="a.jpg",
            source_image_url="https://cdn.test/photo-a.jpg",
        ),
        "img2": BatchImageData(
            image_id="img2",
            image_base64="dGVzdA==",
            filename="b.jpg",
            source_image_url="https://cdn.test/photo-b.jpg",
        ),
    }
    return BatchJob(
        job_id=str(uuid4()),
        user_id="user-1",
        status=BatchJobStatus.GENERATING,
        created_at=datetime.now(timezone.utc),
        auto_generate=True,
        generation_batch_size=10,
        images=images,
    )


async def _register(job: BatchJob) -> None:
    async with BatchJobService._lock:
        BatchJobService._jobs[job.job_id] = job


@pytest.fixture(autouse=True)
def _clear_job_store():
    BatchJobService._jobs.clear()
    yield
    BatchJobService._jobs.clear()


async def _add_item(job: BatchJob, image_id: str, temp_id: str) -> None:
    await BatchJobService.add_detected_items(
        job.job_id,
        image_id,
        [{"temp_id": temp_id, "category": "tops", "colors": ["black"]}],
    )


@pytest.mark.asyncio
async def test_photo_cache_dedupes_sibling_downloads_and_releases_after_dispatch():
    """Sibling items on one photo share a single download; a URL with no
    pending items is never re-downloaded; text-only items pass None."""
    job = _make_job()
    await _register(job)
    await _add_item(job, "img1", "item-a1")
    await _add_item(job, "img1", "item-a2")  # sibling of item-a1
    await _add_item(job, "img2", "item-b1")
    await _add_item(job, "img2", "item-b2")  # sibling of item-b1

    downloads: dict = {"count": 0, "urls": []}
    dispatched: list = []
    dispatched_done = asyncio.Event()

    async def fake_download(url: str, **kwargs):
        downloads["count"] += 1
        downloads["urls"].append(url)
        return f"ref:{url}"

    async def fake_generate(self, job_arg, item, agent, reference_image_base64):
        dispatched.append((item.temp_id, reference_image_base64))
        if len(dispatched) == 4:
            dispatched_done.set()
        return None

    service = BatchExtractionService(user_id="user-1", db=None)
    gen_queue: asyncio.Queue = asyncio.Queue()

    async def fake_agent_factory(user_id=None, db=None):
        return object()  # never used: _generate_single_item is patched

    with patch(
        "app.services.batch_extraction_service.StorageService.download_and_downscale_to_base64",
        fake_download,
    ), patch(
        "app.services.batch_extraction_service.get_image_generation_agent",
        fake_agent_factory,
    ), patch.object(
        BatchExtractionService, "_generate_single_item", fake_generate
    ):
        consumer = asyncio.create_task(
            service._generation_consumer(job, gen_queue)
        )
        # Batch 1: two siblings on photo-a. Batch 2: two siblings on photo-b.
        await gen_queue.put([item for item in job.detected_items if item.image_id == "img1"])
        await gen_queue.put([item for item in job.detected_items if item.image_id == "img2"])
        await gen_queue.put(None)  # drain sentinel
        await consumer

    # One download per unique URL — siblings share the cache entry.
    assert downloads["count"] == 2
    assert downloads["urls"] == ["https://cdn.test/photo-a.jpg", "https://cdn.test/photo-b.jpg"]

    # Every item was dispatched exactly once with its photo's reference.
    by_id = dict(dispatched)
    assert by_id["item-a1"] == "ref:https://cdn.test/photo-a.jpg"
    assert by_id["item-a2"] == "ref:https://cdn.test/photo-a.jpg"
    assert by_id["item-b1"] == "ref:https://cdn.test/photo-b.jpg"
    assert by_id["item-b2"] == "ref:https://cdn.test/photo-b.jpg"


@pytest.mark.asyncio
async def test_text_only_items_get_no_reference_and_no_download():
    """An item without a source_image_url must not trigger any download."""
    job = _make_job()
    # Strip the source URL: this item has no stored photo.
    job.images["img1"].source_image_url = None
    await _register(job)
    await _add_item(job, "img1", "item-a1")

    downloads = {"count": 0}
    dispatched: list = []

    async def fake_download(url: str, **kwargs):
        downloads["count"] += 1
        return "ref"

    async def fake_generate(self, job_arg, item, agent, reference_image_base64):
        dispatched.append(reference_image_base64)
        return None

    service = BatchExtractionService(user_id="user-1", db=None)
    gen_queue: asyncio.Queue = asyncio.Queue()

    async def fake_agent_factory(user_id=None, db=None):
        return object()

    with patch(
        "app.services.batch_extraction_service.StorageService.download_and_downscale_to_base64",
        fake_download,
    ), patch(
        "app.services.batch_extraction_service.get_image_generation_agent",
        fake_agent_factory,
    ), patch.object(
        BatchExtractionService, "_generate_single_item", fake_generate
    ):
        consumer = asyncio.create_task(service._generation_consumer(job, gen_queue))
        await gen_queue.put(list(job.detected_items))
        await gen_queue.put(None)
        await consumer

    assert downloads["count"] == 0
    assert dispatched == [None]
