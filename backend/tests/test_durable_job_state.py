"""Focused regressions for hosted persistence of batch/photoshoot job state."""

from datetime import datetime, timezone
from unittest.mock import Mock

import pytest

from app.models.photoshoot import PhotoshootJobStatus
from app.api.v1.calendar import CalendarEventData, CreateEventRequest
from app.services import storage_service as storage_module
from app.services.batch_job_service import BatchJobService, BatchJobStatus
from app.services.photoshoot_job_service import PhotoshootJobService
from app.services.storage_service import StorageService


USER_ID = "11111111-1111-1111-1111-111111111111"


def _db_with_rows(row, *, update_data=None):
    db = Mock()
    result = Mock(data=row)
    chain = (
        db.table.return_value.select.return_value.eq.return_value.eq.return_value
        .maybe_single.return_value
    )
    chain.execute.return_value = result
    db.table.return_value.upsert.return_value.execute.return_value = Mock(data=[row])
    db.table.return_value.update.return_value.eq.return_value.eq.return_value.eq.return_value.execute.return_value = Mock(
        data=[row] if update_data is None else update_data
    )
    return db


@pytest.fixture(autouse=True)
def clear_job_stores():
    BatchJobService._jobs.clear()
    PhotoshootJobService._jobs.clear()
    yield
    BatchJobService._jobs.clear()
    PhotoshootJobService._jobs.clear()


@pytest.mark.asyncio
async def test_batch_db_create_and_hydrate_preserves_status_metadata_without_payload():
    db = _db_with_rows(None)
    job = await BatchJobService.create_job(
        user_id=USER_ID,
        images=[{"image_id": "img-1", "image_base64": "large-payload"}],
        db=db,
    )

    assert db.table.return_value.upsert.called
    BatchJobService._jobs.clear()
    persisted = {
        "id": job.job_id,
        "user_id": USER_ID,
        "status": "completed",
        "job_type": "batch",
        "total_images": 1,
        "total_items": 1,
        "extractions_completed": 1,
        "extractions_failed": 0,
        "generations_completed": 1,
        "generations_failed": 0,
        "auto_generate": True,
        "generation_batch_size": 1,
        "error_message": None,
        "images": [{"image_id": "img-1", "filename": "shirt.jpg"}],
        "items": [{
            "temp_id": "item-1",
            "image_id": "img-1",
            "category": "tops",
            "status": "generated",
            "generated_image_url": "https://storage.example/item.webp",
        }],
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    db = _db_with_rows(persisted)

    hydrated = await BatchJobService.get_job(job.job_id, USER_ID, db=db)

    assert hydrated is not None
    assert hydrated.status == BatchJobStatus.COMPLETED
    assert hydrated.detected_items[0].generated_image_url.endswith("item.webp")
    assert hydrated.images["img-1"].image_base64 == ""


@pytest.mark.asyncio
async def test_batch_terminal_transition_uses_persisted_compare_and_set():
    db = _db_with_rows(None)
    job = await BatchJobService.create_job(USER_ID, [{"image_id": "img-1", "image_base64": "x"}], db=db)

    await BatchJobService.update_status(job.job_id, BatchJobStatus.COMPLETED)

    update = db.table.return_value.update.return_value
    assert update.eq.return_value.eq.return_value.eq.call_args.args == ("status", "pending")


@pytest.mark.asyncio
async def test_batch_hydration_preserves_mixed_per_image_recovery_state():
    persisted = {
        "id": "batch-mixed",
        "user_id": USER_ID,
        "status": "failed",
        "job_type": "batch",
        "total_images": 3,
        "total_items": 1,
        "images": [
            {"image_id": "complete", "extraction_status": "completed"},
            {"image_id": "failed", "extraction_status": "failed", "extraction_error": "provider timeout"},
            {"image_id": "pending", "extraction_status": "pending"},
        ],
        "items": [],
        "created_at": datetime.now(timezone.utc).isoformat(),
    }

    job = BatchJobService._hydrate(persisted, Mock())

    assert job is not None
    assert job.extraction_completed == {"complete"}
    assert job.extraction_failed == {"failed": "provider timeout"}
    assert job.images["pending"].extraction_status == "pending"


def test_storage_reference_paths_are_reduced_to_known_bucket_keys(monkeypatch):
    """URLs and keys are reduced to a bucket key via key_from_path (SSRF-safe).

    The old `_validate_storage_url` rejected non-Supabase hosts by raising;
    the new `key_from_path` never raises and never contacts a host — it only
    extracts a bucket key so the S3 backend can fetch it. An attacker URL is
    therefore reduced to a path that is looked up in the bucket, never fetched
    from the attacker's host.
    """
    monkeypatch.setattr(storage_module.settings, "SUPABASE_STORAGE_BUCKET", "items")
    monkeypatch.setattr(storage_module.settings, "OBJECT_STORAGE_BUCKET", "bucket")

    # Supabase public object URL -> key (bucket segment dropped).
    assert StorageService.key_from_path(
        "https://project.supabase.co/storage/v1/object/public/items/user-a/item.webp"
    ) == "user-a/item.webp"

    # A bare key passes through unchanged.
    assert StorageService.key_from_path("user-a/items/item.webp") == "user-a/items/item.webp"

    # Any host is fine — the function only extracts a key, never fetches the URL.
    assert StorageService.key_from_path(
        "https://attacker.example/storage/v1/object/public/items/item.webp"
    ) == "item.webp"

    # Empty / None -> None.
    assert StorageService.key_from_path("") is None
    assert StorageService.key_from_path(None) is None


def test_calendar_all_day_contract_is_explicit_and_round_trips():
    request = CreateEventRequest(
        title="Holiday",
        start_time="2026-08-01T00:00:00Z",
        end_time="2026-08-02T00:00:00Z",
        is_all_day=True,
        outfit_id="outfit-1",
    )
    event = CalendarEventData(
        id="event-1",
        title=request.title,
        start_time=request.start_time,
        end_time=request.end_time,
        is_all_day=request.is_all_day,
        outfit_id=request.outfit_id,
    )

    assert event.is_all_day is True
    assert event.outfit_id == "outfit-1"


@pytest.mark.asyncio
async def test_photoshoot_db_create_and_hydrate_preserves_final_result_without_reference_payload():
    db = _db_with_rows(None)
    job = await PhotoshootJobService.create_job(
        user_id=USER_ID,
        photos=["large-reference-payload"],
        use_case="aesthetic",
        num_images=1,
        db=db,
    )

    assert db.table.return_value.upsert.called
    PhotoshootJobService._jobs.clear()
    persisted = {
        "id": job.job_id,
        "user_id": USER_ID,
        "status": "complete",
        "session_id": job.session_id,
        "use_case": "aesthetic",
        "num_images": 1,
        "batch_size": 1,
        "aspect_ratio": "1:1",
        "total_batches": 1,
        "current_batch": 1,
        "generated_images": [{"id": "image-1", "index": 0, "image_url": "https://storage.example/1.webp"}],
        "failed_indices": [],
        "usage": {"used_today": 1},
        "error_message": None,
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    db = _db_with_rows(persisted)

    hydrated = await PhotoshootJobService.get_job(job.job_id, USER_ID, db=db)

    assert hydrated is not None
    assert hydrated.status == PhotoshootJobStatus.COMPLETE
    assert hydrated.generated_images[0]["image_url"].endswith("1.webp")
    assert hydrated.photos == []


@pytest.mark.asyncio
async def test_photoshoot_terminal_transition_uses_persisted_compare_and_set():
    db = _db_with_rows(None)
    job = await PhotoshootJobService.create_job(
        user_id=USER_ID,
        photos=["reference"],
        use_case="aesthetic",
        num_images=1,
        db=db,
    )

    await PhotoshootJobService.update_status(job.job_id, PhotoshootJobStatus.COMPLETE)

    update = db.table.return_value.update.return_value
    assert update.eq.return_value.eq.return_value.eq.call_args.args == ("status", "pending")


@pytest.mark.asyncio
async def test_terminal_transition_does_not_mutate_when_persisted_cas_loses():
    db = _db_with_rows(None, update_data=[])
    batch_job = await BatchJobService.create_job(
        USER_ID,
        [{"image_id": "img-1", "image_base64": "x"}],
        db=db,
    )
    await BatchJobService.update_status(batch_job.job_id, BatchJobStatus.COMPLETED)
    assert batch_job.status == BatchJobStatus.PENDING

    PhotoshootJobService._jobs.clear()
    photo_job = await PhotoshootJobService.create_job(
        user_id=USER_ID,
        photos=["reference"],
        use_case="aesthetic",
        num_images=1,
        db=db,
    )
    await PhotoshootJobService.update_status(photo_job.job_id, PhotoshootJobStatus.COMPLETE)
    assert photo_job.status == PhotoshootJobStatus.PENDING


@pytest.mark.asyncio
async def test_no_db_unit_path_remains_in_memory_only():
    job = await BatchJobService.create_job(USER_ID, [{"image_id": "img-1", "image_base64": "x"}])
    await BatchJobService.update_status(job.job_id, BatchJobStatus.COMPLETED)
    assert (await BatchJobService.get_job(job.job_id, USER_ID)).status == BatchJobStatus.COMPLETED
