"""Coverage for POST /items/batch-from-extraction and the batch save core.

Pins the fast-save contract the mobile review pages rely on:
- one call saves many pieces, each echoed with the client's ``temp_id``;
- a per-item failure (e.g. an unowned image key) lands in ``failed`` while
  the batch continues — the client retries only the failed subset;
- a repeated ``client_request_id`` replays the committed row (no duplicate);
- an empty batch is rejected by the request model (422 at parse time).
"""

from datetime import timedelta
from typing import Any, Dict, Optional
from unittest.mock import AsyncMock, Mock

import pytest

from app.api.v1 import items as items_module
from app.models.item import BatchSaveRequest, ItemCreate, ItemImageBase
from app.services import item_save_service as save_service
from app.services.ai_settings_service import AISettingsService
from app.utils.datetime_util import utcnow, utcnow_iso
from tests.utils.fake_db import FakeDB

USER_ID = "11111111-1111-1111-1111-111111111111"
FOREIGN = "22222222-2222-2222-2222-222222222222"
HEX = "0123456789abcdef0123456789abcdef"
OTHER_HEX = "fedcba9876543210fedcba9876543210"


def _patch_no_embedding(monkeypatch) -> None:
    """Skip the embedding side-effect: quota exhausted means no vector work."""
    monkeypatch.setattr(
        AISettingsService, "reserve_usage", AsyncMock(return_value=False)
    )
    monkeypatch.setattr(
        save_service, "get_vector_service", lambda: Mock(upsert_item=AsyncMock())
    )


def _entry(temp_id: str, **overrides: Any) -> Dict[str, Any]:
    body: Dict[str, Any] = {
        "name": f"Piece {temp_id}",
        "category": "tops",
        "condition": "clean",
    }
    body.update(overrides)
    return {"temp_id": temp_id, "item": body}


@pytest.mark.asyncio
async def test_batch_saves_many_items_in_one_call(monkeypatch):
    db = FakeDB()
    _patch_no_embedding(monkeypatch)

    request = BatchSaveRequest(
        job_id="job-1",
        items=[
            {"temp_id": "t1", "item": ItemCreate(name="Tee", category="tops")},
            {"temp_id": "t2", "item": ItemCreate(name="Jeans", category="bottoms")},
        ],
    )
    result = await items_module.batch_create_from_extraction(
        request=request, user_id=USER_ID, db=db
    )

    assert result["message"] == "Saved 2"
    saved = result["data"]["saved"]
    failed = result["data"]["failed"]
    assert [s["temp_id"] for s in saved] == ["t1", "t2"]
    assert failed == []
    assert saved[0]["item"]["name"] == "Tee"
    assert saved[1]["item"]["name"] == "Jeans"


@pytest.mark.asyncio
async def test_batch_promotes_generated_url_without_client_reupload(monkeypatch):
    """A generated preview URL reduces to its key and is promoted server-side,
    so the client never downloads + re-uploads the bytes."""
    db = FakeDB()
    _patch_no_embedding(monkeypatch)
    promoted = {
        "image_url": "https://cdn.example/canonical.png",
        "thumbnail_url": "https://cdn.example/canonical_thumb.png",
        "storage_path": f"users/{USER_ID}/items/{HEX}.png",
    }
    monkeypatch.setattr(
        save_service.StorageService,
        "copy_temp_image_to_item",
        AsyncMock(return_value=promoted),
    )

    request = BatchSaveRequest(
        items=[
            {
                "temp_id": "t1",
                "item": ItemCreate(
                    name="Tee",
                    category="tops",
                    images=[
                        ItemImageBase(
                            image_url=f"https://cdn.example/users/{USER_ID}/tmp/batch/{HEX}.webp",
                            is_primary=True,
                        )
                    ],
                ),
            }
        ],
    )
    result = await items_module.batch_create_from_extraction(
        request=request, user_id=USER_ID, db=db
    )

    assert result["data"]["failed"] == []
    images = result["data"]["saved"][0]["item"]["images"]
    assert images[0]["storage_path"] == f"users/{USER_ID}/items/{HEX}.png"


@pytest.mark.asyncio
async def test_batch_keeps_shared_tmp_source_until_batch_ends(monkeypatch):
    """Pieces cut from one photo share one staged tmp key. It must survive the
    first commit (siblings still copy from it) and be deleted exactly once."""
    db = FakeDB()
    _patch_no_embedding(monkeypatch)
    promoted = {
        "image_url": "https://cdn.example/canonical.png",
        "thumbnail_url": "https://cdn.example/canonical_thumb.png",
        "storage_path": f"users/{USER_ID}/items/{HEX}.png",
    }
    delete_image = AsyncMock()
    monkeypatch.setattr(save_service.StorageService, "delete_image", delete_image)
    deletes_seen_at_copy = []

    async def fake_copy(*args, **kwargs):
        deletes_seen_at_copy.append(delete_image.await_count)
        return promoted

    monkeypatch.setattr(
        save_service.StorageService, "copy_temp_image_to_item", fake_copy
    )

    shared = f"https://cdn.example/users/{USER_ID}/tmp/batch/{HEX}.webp"
    entries = [
        (
            temp_id,
            ItemCreate(
                name=temp_id,
                category="tops",
                images=[ItemImageBase(image_url=shared, is_primary=True)],
            ),
        )
        for temp_id in ("t1", "t2")
    ]
    result = await save_service.batch_create_items(db, USER_ID, entries)

    assert [s["temp_id"] for s in result["saved"]] == ["t1", "t2"]
    assert deletes_seen_at_copy == [0, 0]
    assert delete_image.await_count == 1


def _shared_tmp_entries(*temp_ids: str, keys: Optional[Dict[str, str]] = None):
    """Entries that all reference the staged tmp key ``HEX``; ``keys`` maps a
    temp_id to a different tmp key for that entry."""
    keys = keys or {}
    return [
        (
            temp_id,
            ItemCreate(
                name=temp_id,
                category="tops",
                images=[
                    ItemImageBase(
                        image_url=(
                            f"https://cdn.example/users/{USER_ID}/tmp/batch/"
                            f"{keys.get(temp_id, HEX)}.webp"
                        ),
                        is_primary=True,
                    )
                ],
            ),
        )
        for temp_id in temp_ids
    ]


@pytest.mark.asyncio
async def test_batch_keeps_tmp_source_when_a_sibling_fails(monkeypatch):
    """A failed sibling's retry re-sends the shared tmp key, so it must survive."""
    db = FakeDB()
    _patch_no_embedding(monkeypatch)
    promoted = {
        "image_url": "https://cdn.example/canonical.png",
        "thumbnail_url": "https://cdn.example/canonical_thumb.png",
        "storage_path": f"users/{USER_ID}/items/{HEX}.png",
    }
    delete_image = AsyncMock()
    monkeypatch.setattr(save_service.StorageService, "delete_image", delete_image)
    monkeypatch.setattr(
        save_service.StorageService,
        "copy_temp_image_to_item",
        AsyncMock(side_effect=[promoted, save_service.ValidationError("boom")]),
    )

    result = await save_service.batch_create_items(
        db, USER_ID, _shared_tmp_entries("t1", "t2")
    )

    assert [s["temp_id"] for s in result["saved"]] == ["t1"]
    assert [f["temp_id"] for f in result["failed"]] == ["t2"]
    assert delete_image.await_count == 0


def _patch_schema_abort_on_second_copy(monkeypatch):
    """First copy succeeds, the second raises SchemaNotInitializedError."""
    promoted = {
        "image_url": "https://cdn.example/canonical.png",
        "thumbnail_url": "https://cdn.example/canonical_thumb.png",
        "storage_path": f"users/{USER_ID}/items/{HEX}.png",
    }
    delete_image = AsyncMock()
    monkeypatch.setattr(save_service.StorageService, "delete_image", delete_image)
    monkeypatch.setattr(
        save_service.StorageService,
        "copy_temp_image_to_item",
        AsyncMock(side_effect=[promoted, save_service.SchemaNotInitializedError()]),
    )
    return delete_image


@pytest.mark.asyncio
async def test_batch_keeps_tmp_source_for_entries_skipped_by_schema_abort(monkeypatch):
    """SchemaNotInitializedError aborts the batch. t1 saves (its key ``HEX`` is
    deferred), t2 aborts on a different key, t3 is never tried but shares ``HEX``
    with t1. ``HEX`` is referenced only by the skipped t3 among the unsaved
    entries, so it must survive: retaining just the aborting entry would delete
    it."""
    db = FakeDB()
    _patch_no_embedding(monkeypatch)
    delete_image = _patch_schema_abort_on_second_copy(monkeypatch)

    with pytest.raises(save_service.SchemaNotInitializedError):
        await save_service.batch_create_items(
            db,
            USER_ID,
            _shared_tmp_entries("t1", "t2", "t3", keys={"t2": OTHER_HEX}),
        )

    assert delete_image.await_count == 0


@pytest.mark.asyncio
async def test_batch_schema_abort_deletes_tmp_source_no_unsaved_entry_references(
    monkeypatch,
):
    """Control for the test above: without the skipped t3, nothing unsaved
    references ``HEX``, so it is deleted. Proves the zero-delete assertion
    above is not vacuous."""
    db = FakeDB()
    _patch_no_embedding(monkeypatch)
    delete_image = _patch_schema_abort_on_second_copy(monkeypatch)

    with pytest.raises(save_service.SchemaNotInitializedError):
        await save_service.batch_create_items(
            db, USER_ID, _shared_tmp_entries("t1", "t2", keys={"t2": OTHER_HEX})
        )

    assert delete_image.await_count == 1
    assert delete_image.await_args.kwargs["storage_path"].endswith(f"{HEX}.webp")


@pytest.mark.asyncio
async def test_batch_replay_of_half_committed_item_is_retryable_failure(monkeypatch):
    """The item row commits before its image rows: a replay that lands in that
    window has no images yet and must fail retryably, not return an image-less item."""
    db = FakeDB(
        rows={
            "items": [
                {
                    "id": "existing-1",
                    "user_id": USER_ID,
                    "client_request_id": "req-t1",
                    "is_deleted": False,
                    "name": "Tee",
                }
            ]
        }
    )
    _patch_no_embedding(monkeypatch)
    entry = ItemCreate(
        name="Tee",
        category="tops",
        client_request_id="req-t1",
        images=[
            ItemImageBase(
                image_url="", storage_path=f"users/{USER_ID}/items/{HEX}.png"
            )
        ],
    )

    result = await save_service.batch_create_items(db, USER_ID, [("t1", entry)])

    assert result["saved"] == []
    assert [f["temp_id"] for f in result["failed"]] == ["t1"]
    assert "still being saved" in result["failed"][0]["error"]


def _orphan_db(created_at: str) -> FakeDB:
    """An item row whose creator died before inserting its image rows."""
    return FakeDB(
        rows={
            "items": [
                {
                    "id": "orphan-1",
                    "user_id": USER_ID,
                    "client_request_id": "req-t1",
                    "is_deleted": False,
                    "name": "Tee",
                    "created_at": created_at,
                }
            ]
        }
    )


def _tmp_image_entry() -> ItemCreate:
    return ItemCreate(
        name="Tee",
        category="tops",
        client_request_id="req-t1",
        images=[
            ItemImageBase(
                image_url=f"https://cdn.example/users/{USER_ID}/tmp/batch/{HEX}.webp",
                is_primary=True,
            )
        ],
    )


@pytest.mark.asyncio
async def test_batch_keeps_retryable_failure_for_recent_half_committed_item(monkeypatch):
    """A row younger than the orphan window may still have a live creator: the
    retry fails retryably and the row is left alone."""
    db = _orphan_db(utcnow_iso())
    _patch_no_embedding(monkeypatch)

    result = await save_service.batch_create_items(
        db, USER_ID, [("t1", _tmp_image_entry())]
    )

    assert result["saved"] == []
    assert "still being saved" in result["failed"][0]["error"]
    assert db.deletes == []
    assert [r["id"] for r in db.rows["items"]] == ["orphan-1"]


@pytest.mark.asyncio
async def test_batch_reaps_stale_half_committed_item_and_recreates(monkeypatch):
    """The creator died between the item row and its image rows (no rollback
    ran). Past the orphan window a retry reaps the orphan and creates fresh
    under the same key instead of returning 503 forever."""
    stale = (utcnow() - save_service._ORPHAN_AFTER - timedelta(seconds=1)).isoformat()
    db = _orphan_db(stale)
    _patch_no_embedding(monkeypatch)
    promoted = {
        "image_url": "https://cdn.example/canonical.png",
        "thumbnail_url": "https://cdn.example/canonical_thumb.png",
        "storage_path": f"users/{USER_ID}/items/{HEX}.png",
    }
    monkeypatch.setattr(
        save_service.StorageService,
        "copy_temp_image_to_item",
        AsyncMock(return_value=promoted),
    )
    monkeypatch.setattr(save_service.StorageService, "delete_image", AsyncMock())

    result = await save_service.batch_create_items(
        db, USER_ID, [("t1", _tmp_image_entry())]
    )

    assert result["failed"] == []
    new_id = result["saved"][0]["item"]["id"]
    assert new_id != "orphan-1"
    assert ("items", None) in db.deletes
    assert [r["id"] for r in db.rows["items"]] == [new_id]
    assert db.rows["items"][0]["client_request_id"] == "req-t1"


@pytest.mark.asyncio
async def test_batch_isolates_per_item_failures(monkeypatch):
    """An unowned image key fails its own entry; the batch continues and the
    client can retry just the failed temp_id."""
    db = FakeDB()
    _patch_no_embedding(monkeypatch)

    request = BatchSaveRequest(
        items=[
            {"temp_id": "good", "item": ItemCreate(name="Tee", category="tops")},
            {
                "temp_id": "bad",
                "item": ItemCreate(
                    name="Stolen",
                    category="tops",
                    images=[
                        ItemImageBase(
                            image_url="",
                            storage_path=f"users/{FOREIGN}/items/{HEX}.png",
                        )
                    ],
                ),
            },
        ],
    )
    result = await items_module.batch_create_from_extraction(
        request=request, user_id=USER_ID, db=db
    )

    assert result["message"] == "Saved 1 of 2"
    assert [s["temp_id"] for s in result["data"]["saved"]] == ["good"]
    assert [f["temp_id"] for f in result["data"]["failed"]] == ["bad"]
    assert "own objects" in result["data"]["failed"][0]["error"]


@pytest.mark.asyncio
async def test_batch_replays_repeated_idempotency_keys(monkeypatch):
    """Saving the same batch twice replays committed rows instead of
    inserting duplicates (re-tapped Save / lost response)."""
    db = FakeDB()
    _patch_no_embedding(monkeypatch)

    def make_request() -> BatchSaveRequest:
        return BatchSaveRequest(
            items=[
                {
                    "temp_id": "t1",
                    "item": ItemCreate(
                        name="Tee",
                        category="tops",
                        client_request_id="req-t1",
                    ),
                }
            ],
        )

    first = await items_module.batch_create_from_extraction(
        request=make_request(), user_id=USER_ID, db=db
    )
    second = await items_module.batch_create_from_extraction(
        request=make_request(), user_id=USER_ID, db=db
    )

    assert first["data"]["failed"] == []
    assert second["data"]["failed"] == []
    assert (
        first["data"]["saved"][0]["item"]["id"]
        == second["data"]["saved"][0]["item"]["id"]
    )
    item_inserts = [i for i in db.inserts if i[0] == "items"]
    assert len(item_inserts) == 1


@pytest.mark.asyncio
async def test_batch_service_returns_raw_shapes(monkeypatch):
    """The service core (not just the route) returns saved/failed shapes the
    mobile client parses for its partial-retry banner."""
    db = FakeDB()
    _patch_no_embedding(monkeypatch)

    result = await save_service.batch_create_items(
        db,
        USER_ID,
        [("t1", ItemCreate(name="Tee", category="tops"))],
    )

    assert [s["temp_id"] for s in result["saved"]] == ["t1"]
    assert result["failed"] == []
    assert result["saved"][0]["item"]["name"] == "Tee"


def test_batch_request_rejects_empty_items():
    """An empty batch never reaches the handler (422 at parse time)."""
    import pydantic

    with pytest.raises(pydantic.ValidationError):
        BatchSaveRequest(items=[])
