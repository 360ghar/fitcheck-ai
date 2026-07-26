"""
Tests for overlapped extract → generate batch pipeline.
"""

import asyncio
from datetime import datetime
from typing import List
from unittest.mock import AsyncMock, MagicMock, patch
from uuid import uuid4

import pytest

from app.services.batch_job_service import (
    BatchImageData,
    BatchJob,
    BatchJobService,
    BatchJobStatus,
)
from app.services.batch_extraction_service import BatchExtractionService


def _make_job(image_ids: List[str], auto_generate: bool = True) -> BatchJob:
    images = {
        iid: BatchImageData(image_id=iid, image_base64="dGVzdA==", filename=f"{iid}.jpg")
        for iid in image_ids
    }
    return BatchJob(
        job_id=str(uuid4()),
        user_id="user-1",
        status=BatchJobStatus.PENDING,
        created_at=datetime.utcnow(),
        auto_generate=auto_generate,
        generation_batch_size=5,
        images=images,
    )


async def _register(job: BatchJob) -> None:
    async with BatchJobService._lock:
        BatchJobService._jobs[job.job_id] = job


async def _unregister(job_id: str) -> None:
    async with BatchJobService._lock:
        BatchJobService._jobs.pop(job_id, None)


@pytest.mark.asyncio
async def test_generation_starts_before_all_extractions_complete():
    """Items from image A should begin generation while image B is still extracting."""
    job = _make_job(["img-a", "img-b"], auto_generate=True)
    await _register(job)

    events: List[str] = []
    gen_started_while_b_pending = asyncio.Event()

    real_broadcast = BatchJobService.broadcast_event

    async def track_broadcast(job_id, event_type, data):
        events.append(event_type)
        if event_type == "generation_started" and "img-b" not in job.extraction_completed:
            gen_started_while_b_pending.set()
        # Still update subscribers / history
        return await real_broadcast(job_id, event_type, data)

    async def fake_extract(self, job_arg, image_id, image_base64, agent, **kwargs):
        on_items_ready = kwargs.get("on_items_ready")
        if image_id == "img-a":
            await asyncio.sleep(0.02)
            items = [
                {
                    "temp_id": "item-a1",
                    "category": "tops",
                    "colors": ["black"],
                    "confidence": 0.9,
                    "detailed_description": "black tee",
                }
            ]
            added = await BatchJobService.add_detected_items(job_arg.job_id, image_id, items)
            await BatchJobService.broadcast_event(
                job_arg.job_id,
                "image_extraction_complete",
                {"image_id": image_id, "items": items},
            )
            if on_items_ready:
                await on_items_ready(added)
            return items

        # Slow second image
        await asyncio.sleep(0.2)
        items = [
            {
                "temp_id": "item-b1",
                "category": "bottoms",
                "colors": ["blue"],
                "confidence": 0.85,
                "detailed_description": "blue jeans",
            }
        ]
        added = await BatchJobService.add_detected_items(job_arg.job_id, image_id, items)
        await BatchJobService.broadcast_event(
            job_arg.job_id,
            "image_extraction_complete",
            {"image_id": image_id, "items": items},
        )
        if on_items_ready:
            await on_items_ready(added)
        return items

    async def fake_generate(self, job_arg, item, agent):
        await asyncio.sleep(0.05)
        await BatchJobService.update_item_generation(
            job_arg.job_id, item.temp_id, generated_image_base64="ZmFrZQ=="
        )
        await BatchJobService.broadcast_event(
            job_arg.job_id,
            "item_generation_complete",
            {
                "temp_id": item.temp_id,
                "completed_count": len(job_arg.generation_completed),
                "total_items": job_arg.total_items,
            },
        )
        return "ZmFrZQ=="

    service = BatchExtractionService(user_id="user-1", db=MagicMock())

    with (
        patch.object(BatchExtractionService, "_extract_single_image", fake_extract),
        patch.object(BatchExtractionService, "_generate_single_item", fake_generate),
        patch.object(
            BatchExtractionService,
            "_fetch_user_avatar_base64",
            AsyncMock(return_value=None),
        ),
        patch(
            "app.services.batch_extraction_service.get_item_extraction_agent",
            AsyncMock(return_value=MagicMock()),
        ),
        patch(
            "app.services.batch_extraction_service.get_image_generation_agent",
            AsyncMock(return_value=MagicMock()),
        ),
        patch.object(BatchJobService, "broadcast_event", side_effect=track_broadcast),
        patch.object(BatchJobService, "release_image_payloads", AsyncMock()),
        patch.object(BatchJobService, "clear_event_history", AsyncMock()),
        patch.object(BatchExtractionService, "_cache_extraction_results", AsyncMock()),
    ):
        await service.run_pipeline(job)

    assert "generation_started" in events
    assert "all_extractions_complete" in events
    assert "all_generations_complete" in events
    assert job.status == BatchJobStatus.COMPLETED
    assert gen_started_while_b_pending.is_set(), (
        "generation_started should fire before all extractions complete"
    )
    assert "item-a1" in job.generation_completed
    assert "item-b1" in job.generation_completed

    await _unregister(job.job_id)


@pytest.mark.asyncio
async def test_auto_generate_false_skips_generation():
    job = _make_job(["img-a"], auto_generate=False)
    await _register(job)

    events: List[str] = []

    async def track_broadcast(job_id, event_type, data):
        events.append(event_type)

    async def fake_extract(self, job_arg, image_id, image_base64, agent, **kwargs):
        items = [
            {
                "temp_id": "only",
                "category": "tops",
                "colors": ["red"],
                "confidence": 0.9,
            }
        ]
        await BatchJobService.add_detected_items(job_arg.job_id, image_id, items)
        return items

    service = BatchExtractionService(user_id="user-1", db=MagicMock())

    with (
        patch.object(BatchExtractionService, "_extract_single_image", fake_extract),
        patch.object(
            BatchExtractionService,
            "_fetch_user_avatar_base64",
            AsyncMock(return_value=None),
        ),
        patch(
            "app.services.batch_extraction_service.get_item_extraction_agent",
            AsyncMock(return_value=MagicMock()),
        ),
        patch.object(BatchJobService, "broadcast_event", side_effect=track_broadcast),
        patch.object(BatchJobService, "release_image_payloads", AsyncMock()),
        patch.object(BatchJobService, "clear_event_history", AsyncMock()),
        patch.object(BatchExtractionService, "_cache_extraction_results", AsyncMock()),
    ):
        await service.run_pipeline(job)

    assert "generation_started" not in events
    assert "all_generations_complete" not in events
    assert job.status == BatchJobStatus.COMPLETED

    await _unregister(job.job_id)


@pytest.mark.asyncio
async def test_persist_source_image_uploads_and_returns_url():
    """_persist_source_image should call StorageService.upload_source_image
    and return its {image_url, storage_path}."""
    from app.services.batch_extraction_service import BatchExtractionService

    service = BatchExtractionService(user_id="user-1", db=MagicMock())

    captured: dict = {}

    async def fake_upload(*, db, user_id, file_data, extension):
        captured.update(user_id=user_id, file_data=file_data, extension=extension)
        return {"image_url": "https://example/source.jpg", "storage_path": "u/sources/s.jpg"}

    with patch(
        "app.services.batch_extraction_service.StorageService.upload_source_image",
        new=fake_upload,
    ):
        result = await service._persist_source_image("img-a", "dGVzdA==")

    assert result == {
        "image_url": "https://example/source.jpg",
        "storage_path": "u/sources/s.jpg",
    }
    assert captured["user_id"] == "user-1"
    assert captured["extension"] == ".jpg"
    # base64 "dGVzdA==" decodes to b"test"
    assert captured["file_data"] == b"test"


@pytest.mark.asyncio
async def test_persist_source_image_returns_none_on_garbage_input():
    from app.services.batch_extraction_service import BatchExtractionService

    service = BatchExtractionService(user_id="user-1", db=MagicMock())
    result = await service._persist_source_image("img-a", "!!!not-base64!!!")
    assert result is None


@pytest.mark.asyncio
async def test_add_detected_items_inherits_source_image_from_photo():
    """Items extracted from a photo must carry that photo's source_image_url."""
    job = _make_job(["img-a"])
    # Simulate the source image having been uploaded before extraction.
    job.images["img-a"].source_image_url = "https://example/source.jpg"
    job.images["img-a"].source_image_storage_path = "u/sources/s.jpg"
    await _register(job)

    added = await BatchJobService.add_detected_items(
        job.job_id,
        "img-a",
        [
            {
                "temp_id": "i1",
                "category": "tops",
                "bounding_box": {"x": 10, "y": 20, "width": 40, "height": 50},
            },
            {"temp_id": "i2", "category": "bottoms"},
        ],
    )

    assert len(added) == 2
    for item in added:
        assert item.source_image_url == "https://example/source.jpg"
        assert item.source_image_storage_path == "u/sources/s.jpg"

    # to_dict round-trips the fields.
    serialized = added[0].to_dict()
    assert serialized["source_image_url"] == "https://example/source.jpg"
    assert serialized["source_image_storage_path"] == "u/sources/s.jpg"

    await _unregister(job.job_id)


@pytest.mark.asyncio
async def test_generate_single_item_passes_reference_image_and_description():
    """_generate_single_item must fetch the source URL and pass it as
    reference_image to generate_product_image. The item is identified by its
    dense description; the bounding_box is NOT forwarded to generation."""
    from app.services.batch_extraction_service import BatchExtractionService
    from app.services.batch_job_service import DetectedItemData
    from app.agents.image_generation_agent import GeneratedImage

    job = _make_job(["img-a"])
    await _register(job)

    item = DetectedItemData(
        temp_id="i1",
        image_id="img-a",
        category="tops",
        sub_category="t-shirt",
        colors=["white"],
        detailed_description="white crew tee; solid; ribbed collar",
        bounding_box={"x": 10.0, "y": 20.0, "width": 40.0, "height": 50.0},
        source_image_url="https://example/source.jpg",
    )
    job.detected_items.append(item)

    captured_kwargs: dict = {}

    async def fake_generate_product_image(**kwargs):
        captured_kwargs.update(kwargs)
        return GeneratedImage(
            image_base64="ZmFrZQ==", prompt="p", model="m", provider="p"
        )

    fake_agent = MagicMock()
    fake_agent.generate_product_image = fake_generate_product_image

    download_calls: List[str] = []

    async def fake_download(url, timeout=10.0):
        download_calls.append(url)
        return "c291cmNl"  # base64 of b"source"

    service = BatchExtractionService(user_id="user-1", db=MagicMock())

    with (
        patch(
            "app.services.batch_extraction_service.StorageService.download_to_base64",
            new=fake_download,
        ),
        patch.object(BatchJobService, "broadcast_event", AsyncMock()),
        patch.object(BatchJobService, "update_item_generation", AsyncMock()),
    ):
        result = await service._generate_single_item(job, item, fake_agent)

    assert result == "ZmFrZQ=="
    assert download_calls == ["https://example/source.jpg"]
    assert captured_kwargs["reference_image"] == "c291cmNl"
    # The bounding box is intentionally not forwarded to image generation —
    # the item is identified by its dense description instead.
    assert "bounding_box" not in captured_kwargs
    assert captured_kwargs["item_description"] == "white crew tee; solid; ribbed collar"

    await _unregister(job.job_id)


@pytest.mark.asyncio
async def test_generate_single_item_falls_back_when_source_unavailable():
    """If the source URL is missing or download fails, generation still runs
    text-only (no reference_image)."""
    from app.services.batch_extraction_service import BatchExtractionService
    from app.services.batch_job_service import DetectedItemData
    from app.agents.image_generation_agent import GeneratedImage

    job = _make_job(["img-a"])
    await _register(job)

    # No source_image_url on the item (e.g. upload failed in extraction phase).
    item = DetectedItemData(
        temp_id="i2",
        image_id="img-a",
        category="tops",
        colors=["blue"],
        detailed_description="blue tee",
        bounding_box={"x": 5.0, "y": 5.0, "width": 20.0, "height": 20.0},
        source_image_url=None,
    )
    job.detected_items.append(item)

    captured_kwargs: dict = {}

    async def fake_generate_product_image(**kwargs):
        captured_kwargs.update(kwargs)
        return GeneratedImage(
            image_base64="ZmFrZQ==", prompt="p", model="m", provider="p"
        )

    fake_agent = MagicMock()
    fake_agent.generate_product_image = fake_generate_product_image

    service = BatchExtractionService(user_id="user-1", db=MagicMock())

    with (
        patch.object(BatchJobService, "broadcast_event", AsyncMock()),
        patch.object(BatchJobService, "update_item_generation", AsyncMock()),
    ):
        result = await service._generate_single_item(job, item, fake_agent)

    assert result == "ZmFrZQ=="
    assert captured_kwargs["reference_image"] is None
    # No bounding box is forwarded to generation.
    assert "bounding_box" not in captured_kwargs

    await _unregister(job.job_id)
