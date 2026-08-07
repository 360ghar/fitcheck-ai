"""Tests for job lifecycle memory freeing (2026-08-03 512 MB budget).

A finished job used to pin every generated image's base64 (multi-MB each) for
the whole finished TTL, and its event history duplicated base64 for late
joiners. These tests pin the lifecycle contract for BOTH batch and photoshoot
stores:
- history stores base64-STRIPPED copies while live broadcasts carry base64;
- terminal transition frees generated base64 for items WITH a URL (upload
  failure retains it, so the image is still deliverable);
- per-image source base64 is releasable as each extraction finishes.
"""

import pytest

from app.services.batch_job_service import BatchJobService
from app.services.photoshoot_job_service import PhotoshootJobService
from app.utils.sse_queue import EVENT_HISTORY_MAX, strip_history_base64


@pytest.fixture(autouse=True)
def _clear_job_stores():
    BatchJobService._jobs.clear()
    PhotoshootJobService._jobs.clear()
    yield
    BatchJobService._jobs.clear()
    PhotoshootJobService._jobs.clear()


async def _make_job_with_item(**generation_kwargs):
    job = await BatchJobService.create_job(
        user_id="u1",
        images=[{"image_id": "img1", "image_base64": "c291cmNl"}],
    )
    added = await BatchJobService.add_detected_items(
        job.job_id,
        "img1",
        [{"temp_id": "item-1", "category": "tops", "colors": ["black"]}],
    )
    await BatchJobService.update_item_generation(
        job.job_id,
        "item-1",
        generated_image_base64="Z2VuZXJhdGVk",
        **generation_kwargs,
    )
    return job, added[0]


@pytest.mark.asyncio
async def test_history_strips_base64_but_live_broadcast_carries_it():
    job, _ = await _make_job_with_item(generated_image_url="https://cdn.test/i.png")
    await BatchJobService.broadcast_event(
        job.job_id,
        "item_generation_complete",
        {
            "temp_id": "item-1",
            "generated_image_base64": "Z2VuZXJhdGVk",
            "generated_image_url": "https://cdn.test/i.png",
        },
    )

    # Live subscribers get the full event (the client save flow needs base64).
    assert job.event_history
    history_event = job.event_history[-1]
    assert history_event["data"]["generated_image_base64"] is None
    assert history_event["data"]["generated_image_url"] == "https://cdn.test/i.png"


@pytest.mark.asyncio
async def test_history_strip_recurses_into_nested_lists():
    event = {
        "type": "image_extraction_complete",
        "data": {
            "items": [
                {"temp_id": "a", "generated_image_base64": "c2VjcmV0"},
                {"temp_id": "b"},
            ]
        },
    }
    stripped = strip_history_base64(event)
    assert stripped["data"]["items"][0]["generated_image_base64"] is None
    assert stripped["data"]["items"][1] == {"temp_id": "b"}


@pytest.mark.asyncio
async def test_history_is_length_bounded():
    job = await BatchJobService.create_job(
        user_id="u1",
        images=[{"image_id": "img1", "image_base64": "c291cmNl"}],
    )
    for i in range(EVENT_HISTORY_MAX + 50):
        await BatchJobService.broadcast_event(
            job.job_id, "image_extraction_complete", {"i": i}
        )
    assert len(job.event_history) == EVENT_HISTORY_MAX


@pytest.mark.asyncio
async def test_terminal_release_frees_base64_for_items_with_url():
    job, item = await _make_job_with_item(generated_image_url="https://cdn.test/i.png")
    assert item.generated_image_base64 == "Z2VuZXJhdGVk"

    await BatchJobService.release_generated_payloads(job.job_id)

    assert item.generated_image_base64 is None
    assert item.generated_image_url == "https://cdn.test/i.png"


@pytest.mark.asyncio
async def test_terminal_release_keeps_base64_when_upload_failed():
    job, item = await _make_job_with_item()  # no URL: upload failed
    assert item.generated_image_base64 == "Z2VuZXJhdGVk"

    await BatchJobService.release_generated_payloads(job.job_id)

    # Memory is the price of delivering the image; it must survive the release.
    assert item.generated_image_base64 == "Z2VuZXJhdGVk"


@pytest.mark.asyncio
async def test_concurrent_job_cap_raises_server_busy_code():
    """The process-wide cap is SERVER capacity, not the user's own plan
    limit: it must carry the SERVER_BUSY code so clients show "retry in a
    minute" instead of the upgrade prompt (observed 2026-08-03: batch-extract
    429s at 18:08/18:26 were all RATE_LIMIT_EXCEEDED)."""
    from app.core.exceptions import RateLimitError
    from app.services.batch_job_service import MAX_CONCURRENT_BATCH_JOBS

    # Occupy both slots (jobs are held in the class store; references are
    # not needed - the autouse fixture clears them after the test).
    await BatchJobService.create_job(
        user_id="u1",
        images=[{"image_id": "img1", "image_base64": "c291cmNl"}],
    )
    await BatchJobService.create_job(
        user_id="u2",
        images=[{"image_id": "img2", "image_base64": "c291cmNl"}],
    )
    assert MAX_CONCURRENT_BATCH_JOBS == 2

    with pytest.raises(RateLimitError) as exc_info:
        await BatchJobService.create_job(
            user_id="u3",
            images=[{"image_id": "img3", "image_base64": "c291cmNl"}],
        )

    assert exc_info.value.error_code == "SERVER_BUSY"
    assert exc_info.value.status_code == 429
    assert exc_info.value.details.get("retry_after_seconds") == 60
    body = exc_info.value.to_dict()
    assert body["code"] == "SERVER_BUSY"
    # User-facing copy, no implementation detail.
    assert "batch job" not in body["error"].lower()


@pytest.mark.asyncio
async def test_single_image_payload_release_is_per_image():
    job = await BatchJobService.create_job(
        user_id="u1",
        images=[
            {"image_id": "img1", "image_base64": "Zmlyc3Q="},
            {"image_id": "img2", "image_base64": "c2Vjb25k"},
        ],
    )
    await BatchJobService.release_single_image_payload(job.job_id, "img1")

    assert job.images["img1"].image_base64 == ""
    assert job.images["img2"].image_base64 == "c2Vjb25k"


@pytest.mark.asyncio
async def test_phase_end_release_drops_all_source_payloads():
    job = await BatchJobService.create_job(
        user_id="u1",
        images=[
            {"image_id": "img1", "image_base64": "Zmlyc3Q="},
            {"image_id": "img2", "image_base64": "c2Vjb25k"},
        ],
    )
    await BatchJobService.release_image_payloads(job.job_id)

    assert all(image.image_base64 == "" for image in job.images.values())


# ---------------------------------------------------------------------------
# Photoshoot store
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_photoshoot_terminal_release_frees_base64_for_images_with_url():
    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["c291cmNl"],
        use_case="aesthetic",
        num_images=2,
    )
    await PhotoshootJobService.add_generated_image(
        job.job_id, "img-1", 0,
        image_base64="Z2VuZXJhdGVk",
        image_url="https://cdn.test/shot1.png",
    )
    await PhotoshootJobService.add_generated_image(
        job.job_id, "img-2", 1,
        image_base64="Z2VuZXJhdGVk",
        # No URL: upload failed, base64 must survive so the image still renders.
    )

    await PhotoshootJobService.release_generated_payloads(job.job_id)

    by_index = {image["index"]: image for image in job.generated_images}
    assert "image_base64" not in by_index[0]
    assert by_index[0]["image_url"] == "https://cdn.test/shot1.png"
    # Upload-failure image keeps its base64 (memory is the price of delivery).
    assert by_index[1]["image_base64"] == "Z2VuZXJhdGVk"
