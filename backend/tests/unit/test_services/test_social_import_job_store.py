"""
Tests for SocialImportJobStore persistence operations.

Every method talks to hosted Supabase through the synchronous supabase-py
client (routed via ``asyncio.to_thread``); the suite's in-memory FakeDB
stands in for the client, so these tests assert real query construction
(filters, inserts, updates, RPC params) as well as return values.
"""
from unittest.mock import Mock

import pytest

from app.models.social_import import (
    SocialImportItemStatus,
    SocialImportJobStatus,
    SocialImportPhotoStatus,
)
from app.services.social_import_job_store import SocialImportJobStore

USER_ID = "user-1"
JOB_ID = "job-1"


def _job_row(**overrides):
    row = {
        "id": JOB_ID,
        "user_id": USER_ID,
        "status": SocialImportJobStatus.DISCOVERING.value,
        "platform": "instagram",
        "source_url": "https://instagram.com/p/abc",
        "normalized_url": "https://instagram.com/p/abc",
        "discovered_photos": 0,
        "total_photos": 0,
    }
    row.update(overrides)
    return row


def _photo_row(**overrides):
    row = {
        "id": "photo-1",
        "job_id": JOB_ID,
        "user_id": USER_ID,
        "ordinal": 1,
        "source_photo_url": "https://cdn.example/1.jpg",
        "status": SocialImportPhotoStatus.QUEUED.value,
    }
    row.update(overrides)
    return row


def _item_row(**overrides):
    row = {
        "id": "item-1",
        "job_id": JOB_ID,
        "photo_id": "photo-1",
        "user_id": USER_ID,
        "temp_id": "temp-1",
        "name": "Tee",
        "category": "tops",
        "status": SocialImportItemStatus.GENERATED.value,
    }
    row.update(overrides)
    return row


@pytest.fixture
def _not_property(monkeypatch):
    """Work around the in-flight FakeDB defect: it models postgrest-py's
    ``not_`` as a method, but real postgrest-py exposes it as a property
    (``.not_.in_(...)``), so ``count_active_jobs`` cannot run against the
    fake as written. Restore property semantics for the duration of the test
    (reported to the parent; do not edit the shared helper)."""
    from tests.utils.fake_db import FakeBuilder

    monkeypatch.setattr(FakeBuilder, "not_", property(lambda self: self._not))
    return FakeBuilder


# =============================================================================
# Jobs
# =============================================================================


@pytest.mark.asyncio
async def test_create_job_calls_rpc_and_returns_first_row():
    db = Mock()
    db.rpc.return_value.execute.return_value = Mock(
        data=[{"id": JOB_ID, "status": "created"}]
    )

    job = await SocialImportJobStore.create_job(
        db,
        user_id=USER_ID,
        platform="instagram",
        source_url="https://instagram.com/p/abc",
        normalized_url="https://instagram.com/p/abc",
        max_concurrent_jobs=2,
    )

    assert job == {"id": JOB_ID, "status": "created"}
    db.rpc.assert_called_once_with(
        "create_social_import_job",
        {
            "p_user_id": USER_ID,
            "p_platform": "instagram",
            "p_source_url": "https://instagram.com/p/abc",
            "p_normalized_url": "https://instagram.com/p/abc",
            "p_max_concurrent_jobs": 2,
        },
    )


@pytest.mark.asyncio
async def test_create_job_raises_when_rpc_returns_no_rows():
    db = Mock()
    db.rpc.return_value.execute.return_value = Mock(data=[])

    with pytest.raises(RuntimeError, match="Failed to create social import job"):
        await SocialImportJobStore.create_job(
            db,
            user_id=USER_ID,
            platform="instagram",
            source_url="https://instagram.com/p/abc",
            normalized_url="https://instagram.com/p/abc",
        )


@pytest.mark.asyncio
async def test_get_job_returns_row_when_found(fake_db):
    fake_db.rows["social_import_jobs"] = [_job_row()]

    job = await SocialImportJobStore.get_job(fake_db, job_id=JOB_ID, user_id=USER_ID)

    assert job["id"] == JOB_ID
    assert ("social_import_jobs", "eq", "id", JOB_ID) in fake_db.filters
    assert ("social_import_jobs", "eq", "user_id", USER_ID) in fake_db.filters


@pytest.mark.asyncio
async def test_get_job_returns_none_when_missing(fake_db):
    job = await SocialImportJobStore.get_job(fake_db, job_id=JOB_ID, user_id=USER_ID)

    assert job is None


@pytest.mark.asyncio
async def test_count_active_jobs_excludes_terminal_statuses(fake_db, _not_property):
    fake_db.rows["social_import_jobs"] = [
        _job_row(id="j1", status=SocialImportJobStatus.CREATED.value),
        _job_row(id="j2", status=SocialImportJobStatus.PROCESSING.value),
        _job_row(id="j3", status=SocialImportJobStatus.COMPLETED.value),
        _job_row(id="j4", status=SocialImportJobStatus.CANCELLED.value),
        _job_row(id="j5", status=SocialImportJobStatus.FAILED.value),
    ]

    count = await SocialImportJobStore.count_active_jobs(fake_db, user_id=USER_ID)

    assert count == 2
    terminal = ("social_import_jobs", "not_in", "status",
                [SocialImportJobStatus.COMPLETED.value,
                 SocialImportJobStatus.CANCELLED.value,
                 SocialImportJobStatus.FAILED.value])
    assert terminal in fake_db.filters


@pytest.mark.asyncio
async def test_update_job_merges_updates_with_updated_at(fake_db):
    fake_db.rows["social_import_jobs"] = [_job_row()]

    updated = await SocialImportJobStore.update_job(
        fake_db,
        job_id=JOB_ID,
        user_id=USER_ID,
        updates={"status": SocialImportJobStatus.PROCESSING.value},
    )

    assert updated["status"] == SocialImportJobStatus.PROCESSING.value
    assert updated["updated_at"]
    fake_db.assert_update(
        "social_import_jobs",
        status=SocialImportJobStatus.PROCESSING.value,
    )


@pytest.mark.asyncio
async def test_update_job_returns_none_when_missing(fake_db):
    updated = await SocialImportJobStore.update_job(
        fake_db,
        job_id=JOB_ID,
        user_id=USER_ID,
        updates={"status": SocialImportJobStatus.PROCESSING.value},
    )

    assert updated is None


@pytest.mark.asyncio
async def test_set_job_status_without_completed_flag(fake_db):
    fake_db.rows["social_import_jobs"] = [_job_row()]

    updated = await SocialImportJobStore.set_job_status(
        fake_db,
        job_id=JOB_ID,
        user_id=USER_ID,
        status=SocialImportJobStatus.FAILED,
        error_message="boom",
    )

    assert updated["status"] == SocialImportJobStatus.FAILED.value
    assert updated["error_message"] == "boom"
    assert "completed_at" not in updated


@pytest.mark.asyncio
async def test_set_job_status_with_completed_flag(fake_db):
    fake_db.rows["social_import_jobs"] = [_job_row()]

    updated = await SocialImportJobStore.set_job_status(
        fake_db,
        job_id=JOB_ID,
        user_id=USER_ID,
        status=SocialImportJobStatus.COMPLETED,
        completed=True,
    )

    assert updated["status"] == SocialImportJobStatus.COMPLETED.value
    assert updated["completed_at"]


# =============================================================================
# Photos
# =============================================================================


@pytest.mark.asyncio
async def test_add_discovered_photos_noop_on_empty_list(fake_db):
    inserted = await SocialImportJobStore.add_discovered_photos(
        fake_db,
        job_id=JOB_ID,
        user_id=USER_ID,
        start_ordinal=0,
        photos=[],
    )

    assert inserted == []
    assert fake_db.inserts == []


@pytest.mark.asyncio
async def test_add_discovered_photos_inserts_and_bumps_job_counts(fake_db):
    fake_db.rows["social_import_jobs"] = [
        _job_row(discovered_photos=2, total_photos=5)
    ]

    inserted = await SocialImportJobStore.add_discovered_photos(
        fake_db,
        job_id=JOB_ID,
        user_id=USER_ID,
        start_ordinal=3,
        photos=[
            {
                "source_photo_id": "sp-1",
                "source_photo_url": "https://cdn.example/1.jpg",
                "source_thumb_url": "https://cdn.example/1_t.jpg",
                "source_taken_at": "2026-08-01T00:00:00Z",
                "metadata": {"likes": 3},
            },
            {"source_photo_url": "https://cdn.example/2.jpg"},
        ],
    )

    assert len(inserted) == 2
    # Multi-row inserts are recorded with a list payload; assert on the
    # payload directly (assert_insert only handles single-row payloads).
    table, payload, on_conflict = fake_db.inserts[0]
    assert table == "social_import_photos"
    assert on_conflict is None
    assert len(payload) == 2
    assert payload[0]["job_id"] == JOB_ID
    assert payload[0]["user_id"] == USER_ID
    assert payload[0]["ordinal"] == 3
    assert payload[0]["source_photo_id"] == "sp-1"
    assert payload[0]["status"] == SocialImportPhotoStatus.QUEUED.value
    assert payload[0]["source_thumb_url"] == "https://cdn.example/1_t.jpg"
    assert payload[1]["ordinal"] == 4
    assert payload[1]["source_photo_id"] is None
    assert payload[1]["metadata"] == {}
    fake_db.assert_update("social_import_jobs", discovered_photos=4, total_photos=5)


@pytest.mark.asyncio
async def test_add_discovered_photos_grows_total_photos_when_below(fake_db):
    fake_db.rows["social_import_jobs"] = [
        _job_row(discovered_photos=2, total_photos=2)
    ]

    await SocialImportJobStore.add_discovered_photos(
        fake_db,
        job_id=JOB_ID,
        user_id=USER_ID,
        start_ordinal=2,
        photos=[{"source_photo_url": "https://cdn.example/3.jpg"}],
    )

    fake_db.assert_update("social_import_jobs", discovered_photos=3, total_photos=3)


@pytest.mark.asyncio
async def test_add_discovered_photos_skips_job_update_when_job_missing(fake_db):
    await SocialImportJobStore.add_discovered_photos(
        fake_db,
        job_id=JOB_ID,
        user_id=USER_ID,
        start_ordinal=0,
        photos=[{"source_photo_url": "https://cdn.example/1.jpg"}],
    )

    assert len(fake_db.inserts) == 1
    assert fake_db.updates == []


@pytest.mark.asyncio
async def test_get_photo_returns_row_when_found(fake_db):
    fake_db.rows["social_import_photos"] = [_photo_row()]

    photo = await SocialImportJobStore.get_photo(
        fake_db, job_id=JOB_ID, user_id=USER_ID, photo_id="photo-1"
    )

    assert photo["id"] == "photo-1"
    assert ("social_import_photos", "eq", "id", "photo-1") in fake_db.filters


@pytest.mark.asyncio
async def test_get_photo_returns_none_when_missing(fake_db):
    photo = await SocialImportJobStore.get_photo(
        fake_db, job_id=JOB_ID, user_id=USER_ID, photo_id="nope"
    )

    assert photo is None


@pytest.mark.asyncio
async def test_list_photos_without_status_filter_returns_all(fake_db):
    fake_db.rows["social_import_photos"] = [
        _photo_row(id="p1", ordinal=1),
        _photo_row(id="p2", ordinal=2),
    ]

    photos = await SocialImportJobStore.list_photos(
        fake_db, job_id=JOB_ID, user_id=USER_ID
    )

    assert [p["id"] for p in photos] == ["p1", "p2"]


@pytest.mark.asyncio
async def test_list_photos_single_status_uses_eq(fake_db):
    fake_db.rows["social_import_photos"] = [
        _photo_row(id="p1", status=SocialImportPhotoStatus.QUEUED.value),
        _photo_row(id="p2", status=SocialImportPhotoStatus.PROCESSING.value),
    ]

    photos = await SocialImportJobStore.list_photos(
        fake_db,
        job_id=JOB_ID,
        user_id=USER_ID,
        statuses=[SocialImportPhotoStatus.QUEUED],
    )

    assert [p["id"] for p in photos] == ["p1"]
    assert ("social_import_photos", "eq", "status", "queued") in fake_db.filters


@pytest.mark.asyncio
async def test_list_photos_multiple_statuses_uses_in_and_limit(fake_db):
    fake_db.rows["social_import_photos"] = [
        _photo_row(id="p1", status=SocialImportPhotoStatus.QUEUED.value),
        _photo_row(id="p2", status=SocialImportPhotoStatus.PROCESSING.value),
        _photo_row(id="p3", status=SocialImportPhotoStatus.REJECTED.value),
    ]

    photos = await SocialImportJobStore.list_photos(
        fake_db,
        job_id=JOB_ID,
        user_id=USER_ID,
        statuses=[SocialImportPhotoStatus.QUEUED, SocialImportPhotoStatus.PROCESSING],
        limit=1,
    )

    assert len(photos) == 1
    assert ("social_import_photos", "in", "status", ["queued", "processing"]) in fake_db.filters


@pytest.mark.asyncio
async def test_update_photo_merges_updates_with_updated_at(fake_db):
    fake_db.rows["social_import_photos"] = [_photo_row()]

    updated = await SocialImportJobStore.update_photo(
        fake_db,
        job_id=JOB_ID,
        user_id=USER_ID,
        photo_id="photo-1",
        updates={"status": SocialImportPhotoStatus.APPROVED.value},
    )

    assert updated["status"] == SocialImportPhotoStatus.APPROVED.value
    assert updated["updated_at"]
    fake_db.assert_update(
        "social_import_photos",
        status=SocialImportPhotoStatus.APPROVED.value,
    )


@pytest.mark.asyncio
async def test_update_photo_returns_none_when_missing(fake_db):
    updated = await SocialImportJobStore.update_photo(
        fake_db,
        job_id=JOB_ID,
        user_id=USER_ID,
        photo_id="nope",
        updates={"status": SocialImportPhotoStatus.APPROVED.value},
    )

    assert updated is None


@pytest.mark.asyncio
async def test_claim_next_queued_photo_returns_none_without_queued(fake_db):
    fake_db.rows["social_import_photos"] = [
        _photo_row(status=SocialImportPhotoStatus.PROCESSING.value)
    ]

    claimed = await SocialImportJobStore.claim_next_queued_photo(
        fake_db, job_id=JOB_ID, user_id=USER_ID
    )

    assert claimed is None
    assert fake_db.updates == []


@pytest.mark.asyncio
async def test_claim_next_queued_photo_cas_update_succeeds(fake_db):
    fake_db.rows["social_import_photos"] = [_photo_row()]

    claimed = await SocialImportJobStore.claim_next_queued_photo(
        fake_db, job_id=JOB_ID, user_id=USER_ID
    )

    assert claimed["id"] == "photo-1"
    assert claimed["status"] == SocialImportPhotoStatus.PROCESSING.value
    assert claimed["processing_started_at"]
    payload = fake_db.updates[-1][1]
    assert payload["status"] == SocialImportPhotoStatus.PROCESSING.value


@pytest.mark.asyncio
async def test_claim_next_queued_photo_returns_none_when_cas_loses(fake_db, monkeypatch):
    """A concurrent writer flipping the row between list and update means the
    CAS update matches zero rows - the claim is abandoned."""
    fake_db.rows["social_import_photos"] = [
        _photo_row(status=SocialImportPhotoStatus.PROCESSING.value)
    ]

    async def fake_list_photos(db, *, job_id, user_id, statuses=None, limit=None):
        # Stale read: the row was queued at list time but is processing now.
        return [{"id": "photo-1", "status": SocialImportPhotoStatus.QUEUED.value}]

    monkeypatch.setattr(SocialImportJobStore, "list_photos", staticmethod(fake_list_photos))

    claimed = await SocialImportJobStore.claim_next_queued_photo(
        fake_db, job_id=JOB_ID, user_id=USER_ID
    )

    assert claimed is None


@pytest.mark.asyncio
async def test_get_slots_returns_awaiting_buffered_processing(fake_db):
    fake_db.rows["social_import_photos"] = [
        _photo_row(id="p1", status=SocialImportPhotoStatus.AWAITING_REVIEW.value),
        _photo_row(id="p2", status=SocialImportPhotoStatus.BUFFERED_READY.value),
        _photo_row(id="p3", status=SocialImportPhotoStatus.PROCESSING.value),
        _photo_row(id="p4", status=SocialImportPhotoStatus.QUEUED.value),
    ]

    slots = await SocialImportJobStore.get_slots(fake_db, job_id=JOB_ID, user_id=USER_ID)

    assert slots["awaiting"]["id"] == "p1"
    assert slots["buffered"]["id"] == "p2"
    assert slots["processing"]["id"] == "p3"
    assert ("social_import_photos", "in", "status", [
        SocialImportPhotoStatus.AWAITING_REVIEW.value,
        SocialImportPhotoStatus.BUFFERED_READY.value,
        SocialImportPhotoStatus.PROCESSING.value,
    ]) in fake_db.filters


@pytest.mark.asyncio
async def test_get_slots_partial_returns_none_for_missing(fake_db):
    fake_db.rows["social_import_photos"] = [
        _photo_row(id="p1", status=SocialImportPhotoStatus.AWAITING_REVIEW.value),
    ]

    slots = await SocialImportJobStore.get_slots(fake_db, job_id=JOB_ID, user_id=USER_ID)

    assert slots["awaiting"]["id"] == "p1"
    assert slots["buffered"] is None
    assert slots["processing"] is None


@pytest.mark.asyncio
async def test_count_by_status_counts_rows_including_unknown(fake_db):
    fake_db.rows["social_import_photos"] = [
        _photo_row(id="p1", status=SocialImportPhotoStatus.QUEUED.value),
        _photo_row(id="p2", status=SocialImportPhotoStatus.QUEUED.value),
        _photo_row(id="p3", status=SocialImportPhotoStatus.PROCESSING.value),
        {"id": "p4", "job_id": JOB_ID, "user_id": USER_ID, "ordinal": 4},
    ]

    counts = await SocialImportJobStore.count_by_status(
        fake_db, job_id=JOB_ID, user_id=USER_ID
    )

    assert counts == {"queued": 2, "processing": 1, "unknown": 1}


# =============================================================================
# Items
# =============================================================================


@pytest.mark.asyncio
async def test_upsert_photo_items_noop_on_empty_list(fake_db):
    inserted = await SocialImportJobStore.upsert_photo_items(
        fake_db,
        job_id=JOB_ID,
        photo_id="photo-1",
        user_id=USER_ID,
        items=[],
    )

    assert inserted == []
    assert fake_db.inserts == []


@pytest.mark.asyncio
async def test_upsert_photo_items_applies_defaults_and_on_conflict(fake_db):
    inserted = await SocialImportJobStore.upsert_photo_items(
        fake_db,
        job_id=JOB_ID,
        photo_id="photo-1",
        user_id=USER_ID,
        items=[
            {
                "temp_id": "temp-1",
                "name": "Tee",
                "category": None,
                "colors": None,
                "confidence": None,
                "status": None,
                "generated_image_url": "https://cdn.example/item.webp",
            },
            {
                "temp_id": "temp-2",
                "name": "Jeans",
                "category": "bottoms",
                "generated_thumbnail_url": "https://cdn.example/item_t.webp",
            },
        ],
    )

    assert len(inserted) == 2
    table, payload, on_conflict = fake_db.inserts[0]
    assert table == "social_import_items"
    assert on_conflict == "job_id,temp_id"
    assert len(payload) == 2
    assert payload[0]["job_id"] == JOB_ID
    assert payload[0]["photo_id"] == "photo-1"
    assert payload[0]["user_id"] == USER_ID
    assert payload[0]["temp_id"] == "temp-1"
    assert payload[0]["category"] == "other"
    assert payload[0]["colors"] == []
    assert payload[0]["confidence"] == 0
    assert payload[0]["status"] == SocialImportItemStatus.GENERATED.value
    assert payload[0]["generated_thumbnail_url"] == "https://cdn.example/item.webp"
    assert payload[1]["temp_id"] == "temp-2"
    assert payload[1]["category"] == "bottoms"
    assert payload[1]["generated_thumbnail_url"] == "https://cdn.example/item_t.webp"


@pytest.mark.asyncio
async def test_list_items_for_photo_returns_matching_rows(fake_db):
    fake_db.rows["social_import_items"] = [
        _item_row(id="item-1", photo_id="photo-1"),
        _item_row(id="item-2", photo_id="photo-1"),
        _item_row(id="item-3", photo_id="photo-2"),
    ]

    items = await SocialImportJobStore.list_items_for_photo(
        fake_db, job_id=JOB_ID, photo_id="photo-1", user_id=USER_ID
    )

    assert [i["id"] for i in items] == ["item-1", "item-2"]
    assert ("social_import_items", "eq", "photo_id", "photo-1") in fake_db.filters


@pytest.mark.asyncio
async def test_update_item_merges_updates_with_updated_at(fake_db):
    fake_db.rows["social_import_items"] = [_item_row()]

    updated = await SocialImportJobStore.update_item(
        fake_db,
        job_id=JOB_ID,
        photo_id="photo-1",
        item_id="item-1",
        user_id=USER_ID,
        updates={"name": "Silk tee"},
    )

    assert updated["name"] == "Silk tee"
    assert updated["updated_at"]
    fake_db.assert_update("social_import_items", name="Silk tee")


@pytest.mark.asyncio
async def test_update_item_returns_none_when_missing(fake_db):
    updated = await SocialImportJobStore.update_item(
        fake_db,
        job_id=JOB_ID,
        photo_id="photo-1",
        item_id="nope",
        user_id=USER_ID,
        updates={"name": "Silk tee"},
    )

    assert updated is None


@pytest.mark.asyncio
async def test_set_items_status_for_photo_updates_matching_rows(fake_db):
    fake_db.rows["social_import_items"] = [
        _item_row(id="item-1", photo_id="photo-1"),
        _item_row(id="item-2", photo_id="photo-1"),
    ]

    await SocialImportJobStore.set_items_status_for_photo(
        fake_db,
        job_id=JOB_ID,
        photo_id="photo-1",
        user_id=USER_ID,
        status=SocialImportItemStatus.SAVED,
    )

    assert len(fake_db.updates) == 1
    payload = fake_db.updates[0][1]
    assert payload["status"] == SocialImportItemStatus.SAVED.value
    assert payload["updated_at"]


# =============================================================================
# Events and teardown
# =============================================================================


@pytest.mark.asyncio
async def test_create_event_inserts_row(fake_db):
    event = await SocialImportJobStore.create_event(
        fake_db,
        job_id=JOB_ID,
        user_id=USER_ID,
        event_type="photo_ready_for_review",
        payload={"photo_id": "photo-1"},
    )

    assert event["event_type"] == "photo_ready_for_review"
    assert event["payload"] == {"photo_id": "photo-1"}
    fake_db.assert_insert(
        "social_import_events",
        job_id=JOB_ID,
        user_id=USER_ID,
        event_type="photo_ready_for_review",
    )


@pytest.mark.asyncio
async def test_create_event_returns_empty_dict_when_no_rows():
    db = Mock()
    db.table.return_value.insert.return_value.execute.return_value = Mock(data=[])

    event = await SocialImportJobStore.create_event(
        db,
        job_id=JOB_ID,
        user_id=USER_ID,
        event_type="heartbeat",
        payload={},
    )

    assert event == {}


@pytest.mark.asyncio
async def test_list_events_after_id_uses_gt_filter(fake_db):
    fake_db.rows["social_import_events"] = [
        {"id": 1, "job_id": JOB_ID, "user_id": USER_ID, "event_type": "a"},
        {"id": 2, "job_id": JOB_ID, "user_id": USER_ID, "event_type": "b"},
        {"id": 3, "job_id": JOB_ID, "user_id": USER_ID, "event_type": "c"},
    ]

    events = await SocialImportJobStore.list_events(
        fake_db, job_id=JOB_ID, user_id=USER_ID, after_id=1
    )

    assert [e["id"] for e in events] == [2, 3]
    assert ("social_import_events", "gt", "id", 1) in fake_db.filters


@pytest.mark.asyncio
async def test_list_events_without_after_id_returns_all(fake_db):
    fake_db.rows["social_import_events"] = [
        {"id": 1, "job_id": JOB_ID, "user_id": USER_ID, "event_type": "a"},
        {"id": 2, "job_id": JOB_ID, "user_id": USER_ID, "event_type": "b"},
    ]

    events = await SocialImportJobStore.list_events(
        fake_db, job_id=JOB_ID, user_id=USER_ID
    )

    assert [e["id"] for e in events] == [1, 2]
    assert all(f[0] != "social_import_events" or f[1] != "gt" for f in fake_db.filters)


@pytest.mark.asyncio
async def test_delete_job_artifacts_deletes_only_owned_sessions(fake_db):
    fake_db.rows["social_import_auth_sessions"] = [
        {"id": "s1", "job_id": JOB_ID, "user_id": USER_ID},
        {"id": "s2", "job_id": "other-job", "user_id": USER_ID},
    ]

    await SocialImportJobStore.delete_job_artifacts(
        fake_db, job_id=JOB_ID, user_id=USER_ID
    )

    assert fake_db.deletes == [("social_import_auth_sessions", None)]
    remaining = fake_db.rows["social_import_auth_sessions"]
    assert [s["id"] for s in remaining] == ["s2"]


# =============================================================================
# Composition helpers
# =============================================================================


@pytest.mark.asyncio
async def test_get_photo_with_items_returns_none_without_photo(fake_db):
    enriched = await SocialImportJobStore.get_photo_with_items(
        fake_db, job_id=JOB_ID, photo=None, user_id=USER_ID
    )

    assert enriched is None
    assert fake_db.selects == []


@pytest.mark.asyncio
async def test_get_photo_with_items_enriches_photo(fake_db):
    fake_db.rows["social_import_items"] = [
        _item_row(id="item-1", photo_id="photo-1"),
        _item_row(id="item-2", photo_id="photo-1"),
    ]
    photo = _photo_row()

    enriched = await SocialImportJobStore.get_photo_with_items(
        fake_db, job_id=JOB_ID, photo=photo, user_id=USER_ID
    )

    assert enriched["id"] == "photo-1"
    assert [i["id"] for i in enriched["items"]] == ["item-1", "item-2"]
