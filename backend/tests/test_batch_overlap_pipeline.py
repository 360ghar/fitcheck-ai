"""
Tests for overlapped extract → generate batch pipeline.
"""

import asyncio
from datetime import datetime
from typing import Any, Dict, List
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
