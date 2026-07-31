"""
Tests for BatchExtractionService._generate_single_item's reference-image
strategy: the fix for single-item product generation bleeding in other
garments (or passing the source photo through unchanged) when multiple items
were detected in the same source photo.
"""

import base64
import io
from datetime import datetime, timezone
from unittest.mock import AsyncMock
from uuid import uuid4

import pytest
from PIL import Image

from app.services.batch_extraction_service import BatchExtractionService
from app.services.batch_job_service import BatchJob, BatchJobStatus, DetectedItemData


def _make_photo_b64(size=(1000, 1000)) -> str:
    img = Image.new("RGB", size, (10, 20, 30))
    buf = io.BytesIO()
    img.save(buf, format="JPEG", quality=90)
    return base64.b64encode(buf.getvalue()).decode("utf-8")


def _make_job(items) -> BatchJob:
    return BatchJob(
        job_id=str(uuid4()),
        user_id="user-1",
        status=BatchJobStatus.GENERATING,
        created_at=datetime.now(timezone.utc),
        detected_items=items,
    )


def _make_item(**overrides) -> DetectedItemData:
    defaults = dict(
        temp_id=f"item-{uuid4().hex[:6]}",
        image_id="photo-1",
        category="tops",
        sub_category="t-shirt",
        colors=["blue"],
        confidence=0.9,
        bounding_box=None,
        detailed_description="blue crew-neck t-shirt",
        source_image_url="https://example.test/photo.jpg",
    )
    defaults.update(overrides)
    return DetectedItemData(**defaults)


class _FakeGeneratedImage:
    def __init__(self, image_base64: str = "Z2VuZXJhdGVk"):
        self.image_base64 = image_base64


def _make_agent() -> AsyncMock:
    agent = AsyncMock()
    agent.generate_product_image = AsyncMock(return_value=_FakeGeneratedImage())
    return agent


@pytest.mark.asyncio
async def test_single_item_photo_passes_full_reference_unchanged():
    """Only one item detected in this photo - nothing else in frame to
    confuse the model, so the full downloaded photo is sent as-is."""
    photo_b64 = _make_photo_b64()
    item = _make_item(bounding_box=None)
    job = _make_job([item])
    agent = _make_agent()

    service = BatchExtractionService(user_id="user-1", db=None)
    # The source photo is now pre-fetched by the pipeline consumer and passed
    # in (one download per unique photo); _generate_single_item only decides
    # how to use it via resolve_product_reference_image.
    result = await service._generate_single_item(job, item, agent, photo_b64)

    assert result == "Z2VuZXJhdGVk"
    kwargs = agent.generate_product_image.call_args.kwargs
    assert kwargs["reference_image"] == photo_b64


@pytest.mark.asyncio
async def test_multi_item_photo_with_trustworthy_bbox_sends_cropped_reference():
    """Two items share this photo; this item has a confident, reasonably
    sized bbox - the reference sent to generation should be a crop, not the
    full multi-item photo."""
    photo_b64 = _make_photo_b64()
    item = _make_item(
        bounding_box={"x": 10.0, "y": 10.0, "width": 20.0, "height": 20.0},
        confidence=0.9,
    )
    sibling = _make_item(image_id=item.image_id, category="bottoms")
    job = _make_job([item, sibling])
    agent = _make_agent()

    service = BatchExtractionService(user_id="user-1", db=None)
    # The source photo is now pre-fetched by the pipeline consumer and passed
    # in (one download per unique photo); _generate_single_item only decides
    # how to use it via resolve_product_reference_image.
    await service._generate_single_item(job, item, agent, photo_b64)

    kwargs = agent.generate_product_image.call_args.kwargs
    assert kwargs["reference_image"] is not None
    assert kwargs["reference_image"] != photo_b64


@pytest.mark.asyncio
async def test_multi_item_photo_with_missing_bbox_sends_no_reference():
    """Two items share this photo; this item has no usable bbox - sending the
    full uncropped multi-item photo is what causes the isolation bug, so the
    fix drops the reference entirely and falls back to text-only generation
    (matching the web app's proven-correct Regenerate behavior)."""
    photo_b64 = _make_photo_b64()
    item = _make_item(bounding_box=None)
    sibling = _make_item(image_id=item.image_id, category="shoes")
    job = _make_job([item, sibling])
    agent = _make_agent()

    service = BatchExtractionService(user_id="user-1", db=None)
    # The source photo is now pre-fetched by the pipeline consumer and passed
    # in (one download per unique photo); _generate_single_item only decides
    # how to use it via resolve_product_reference_image.
    await service._generate_single_item(job, item, agent, photo_b64)

    kwargs = agent.generate_product_image.call_args.kwargs
    assert kwargs["reference_image"] is None


@pytest.mark.asyncio
async def test_multi_item_photo_with_low_confidence_bbox_sends_no_reference():
    """A bbox is present but below the trust threshold - still falls back to
    text-only rather than risking a wrong-region crop."""
    photo_b64 = _make_photo_b64()
    item = _make_item(
        bounding_box={"x": 10.0, "y": 10.0, "width": 20.0, "height": 20.0},
        confidence=0.2,
    )
    sibling = _make_item(image_id=item.image_id, category="accessories")
    job = _make_job([item, sibling])
    agent = _make_agent()

    service = BatchExtractionService(user_id="user-1", db=None)
    # The source photo is now pre-fetched by the pipeline consumer and passed
    # in (one download per unique photo); _generate_single_item only decides
    # how to use it via resolve_product_reference_image.
    await service._generate_single_item(job, item, agent, photo_b64)

    kwargs = agent.generate_product_image.call_args.kwargs
    assert kwargs["reference_image"] is None
