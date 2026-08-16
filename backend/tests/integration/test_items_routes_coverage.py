"""Route-level coverage for app/api/v1/items.py.

Complements the sibling items tests (test_items_list_filters.py,
test_items_stats.py, test_item_occasion_tags.py, test_wave_a_auth_ownership_storage.py,
test_read_path_url_materialization.py, test_phase2e_hardening.py) by exercising
the handlers those do not reach: create/update/delete CRUD, favorite/wear
actions, image add/delete, batch delete, categorization, duplicate checks,
similar-item search, the upload endpoint's failure modes, and the private
helpers (_release_embedding_reservation, _normalize_item_images,
_calculate_text_similarity, _generate_duplicate_reasons,
_fallback_duplicate_check).

Follows the house convention of calling route functions directly with a fake
Supabase client (tests.utils.fake_db.FakeDB) and patching services with
AsyncMock; auth is asserted at the dependency level.
"""
from datetime import date, datetime
from types import SimpleNamespace
from typing import Any, Dict, List, Optional
from unittest.mock import AsyncMock, Mock

import pytest

from app.api.v1 import items as items_module
from app.core.exceptions import (
    AIServiceError,
    DatabaseError,
    ImageNotFoundError,
    ItemNotFoundError,
    RateLimitError,
    StorageServiceError,
    UnsupportedMediaTypeError,
    ValidationError,
)
from app.models.item import ItemCreate, ItemImageBase, ItemUpdate
from app.models.subscription import OperationType
from app.services.ai_service import AIService
from app.services.ai_settings_service import AISettingsService
from app.services.storage_service import StorageService
from app.utils.parallel import ParallelResult
from tests.utils.fake_db import FakeDB, PGRSTDuplicateError

USER_ID = "11111111-1111-1111-1111-111111111111"
ITEM_ID = "22222222-2222-2222-2222-222222222222"
OTHER_ITEM_ID = "33333333-3333-3333-3333-333333333333"
IMAGE_ID = "44444444-4444-4444-4444-444444444444"
NOW = "2026-01-01T00:00:00+00:00"


def _item_row(**overrides: Any) -> Dict[str, Any]:
    """A realistic items row with the columns the handlers read."""
    row: Dict[str, Any] = {
        "id": ITEM_ID,
        "user_id": USER_ID,
        "name": "Crew-neck tee",
        "category": "tops",
        "sub_category": None,
        "brand": "Nike",
        "colors": [],
        "style": None,
        "material": None,
        "materials": [],
        "pattern": None,
        "seasonal_tags": [],
        "occasion_tags": [],
        "size": None,
        "price": None,
        "purchase_date": None,
        "purchase_location": None,
        "tags": [],
        "notes": None,
        "condition": "clean",
        "is_favorite": False,
        "usage_times_worn": 0,
        "usage_last_worn": None,
        "cost_per_wear": None,
        "source_image_url": None,
        "source_image_storage_path": None,
        "created_at": NOW,
        "updated_at": NOW,
        "is_deleted": False,
    }
    row.update(overrides)
    return row


def _image_row(**overrides: Any) -> Dict[str, Any]:
    row: Dict[str, Any] = {
        "id": IMAGE_ID,
        "item_id": ITEM_ID,
        "image_url": "https://cdn.example/1.jpg",
        "thumbnail_url": "https://cdn.example/1-t.jpg",
        "storage_path": None,
        "is_primary": True,
        "width": None,
        "height": None,
        "created_at": NOW,
    }
    row.update(overrides)
    return row


class _FakeUpload:
    """Minimal UploadFile double (read chunks, seek to 0, content_type).

    ``seek(0)`` rewinds the read position, mirroring real UploadFile/Spooled
    semantics — a route that re-reads the file after validation must see the
    bytes again, not an empty buffer.
    """

    def __init__(self, data: bytes = b"png-bytes", filename: str = "a.png", content_type: str = "image/png"):
        self._original = data
        self._pos = 0
        self.filename = filename
        self.content_type = content_type

    async def read(self, size: int = -1) -> bytes:
        if size is None or size < 0:
            out = self._original[self._pos:]
            self._pos = len(self._original)
            return out
        out = self._original[self._pos : self._pos + size]
        self._pos += len(out)
        return out

    async def seek(self, offset: int) -> None:
        assert offset == 0, "fake only supports seek(0)"
        self._pos = 0


def _patch_embedding(
    monkeypatch,
    *,
    reserved: bool = True,
    embedding: Optional[List[float]] = [0.1],
    embedding_error: Optional[Exception] = None,
):
    """Patch the embedding quota + generation services; returns the mocks."""
    reserve = AsyncMock(return_value=reserved)
    if embedding_error is not None:
        generate = AsyncMock(side_effect=embedding_error)
    else:
        generate = AsyncMock(return_value=embedding)
    release = AsyncMock(return_value=True)
    monkeypatch.setattr(AISettingsService, "reserve_usage", reserve)
    monkeypatch.setattr(AIService, "generate_item_embedding", generate)
    monkeypatch.setattr(AISettingsService, "release_usage", release)
    return reserve, generate, release


def _patch_vector_service(monkeypatch) -> Mock:
    """Patch items_module.get_vector_service to return a Mock with AsyncMock ops."""
    vector = Mock()
    vector.upsert_item = AsyncMock(return_value=True)
    vector.delete_item = AsyncMock(return_value=True)
    vector.batch_delete = AsyncMock(return_value=0)
    vector.find_similar = AsyncMock(return_value=[])
    monkeypatch.setattr(items_module, "get_vector_service", lambda: vector)
    return vector


def _error_db(error: Exception) -> Mock:
    """A db whose first select chain raises `error` on execute.

    The handlers' existence checks build `.select(...).eq(...).eq(...)
    .maybe_single().execute`; chained MagicMock method calls nest, so the
    second `.eq()` lives on `eq.return_value.eq.return_value`.
    """
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.maybe_single.return_value.execute.side_effect = error
    return db


def _row_then_empty_update_db(row: Dict[str, Any]) -> Mock:
    """A db where the existence check finds `row` but the update returns nothing."""
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.single.return_value.execute.return_value = SimpleNamespace(
        data=row
    )
    db.table.return_value.update.return_value.eq.return_value.eq.return_value.execute.return_value = Mock(
        data=[]
    )
    return db


def _duplicate_request(**overrides: Any) -> "items_module.DuplicateCheckRequest":
    base = {
        "name": "Blue Blazer",
        "category": "tops",
        "colors": ["blue"],
        "brand": "Zara",
    }
    base.update(overrides)
    return items_module.DuplicateCheckRequest(**base)


# ============================================================================
# POST /items/upload (multi-file parallel upload)
# ============================================================================


@pytest.mark.asyncio
async def test_upload_item_images_rejects_more_than_the_file_cap():
    files = [Mock(content_type="image/png") for _ in range(items_module.MAX_UPLOAD_FILES + 1)]

    with pytest.raises(ValidationError):
        await items_module.upload_item_images(files=files, user_id=USER_ID, db=Mock())


@pytest.mark.asyncio
async def test_upload_item_images_rejects_non_image_content_type():
    files = [_FakeUpload(data=b"x", filename="a.txt", content_type="text/plain")]

    with pytest.raises(UnsupportedMediaTypeError):
        await items_module.upload_item_images(files=files, user_id=USER_ID, db=Mock())


@pytest.mark.asyncio
async def test_upload_item_images_uploads_all_files_in_parallel(monkeypatch):
    """The real parallel_with_retry path: first file is primary, uploads
    succeed and the envelope reports "completed"."""
    seen = []

    async def fake_upload(**kwargs):
        seen.append(kwargs)
        return {
            "image_url": f"https://cdn/{kwargs['filename']}",
            "thumbnail_url": f"https://cdn/{kwargs['filename']}-t.jpg",
            "storage_path": f"u/items/{kwargs['filename']}",
        }

    monkeypatch.setattr(StorageService, "upload_item_image", fake_upload)

    result = await items_module.upload_item_images(
        files=[_FakeUpload(filename="a.png"), _FakeUpload(filename="b.png")],
        user_id=USER_ID,
        db=Mock(),
    )

    assert result["message"] == "Uploaded"
    data = result["data"]
    assert data["status"] == "completed"
    assert data["uploaded_count"] == 2
    assert data["failed_count"] == 0
    assert len(data["images"]) == 2
    assert [s["is_primary"] for s in seen] == [True, False]
    assert [s["filename"] for s in seen] == ["a.png", "b.png"]


@pytest.mark.asyncio
async def test_upload_item_images_reports_partial_when_some_files_fail(monkeypatch):
    failed = ParallelResult(
        success=False, error=StorageServiceError("boom"), index=1
    )
    ok = ParallelResult(
        success=True,
        data={"image_url": "https://cdn/a.jpg", "thumbnail_url": None, "storage_path": "u/a.jpg"},
        index=0,
    )
    monkeypatch.setattr(
        items_module, "parallel_with_retry", AsyncMock(return_value=[ok, failed])
    )

    result = await items_module.upload_item_images(
        files=[_FakeUpload(), _FakeUpload()], user_id=USER_ID, db=Mock()
    )

    assert result["data"]["status"] == "partial"
    assert result["data"]["uploaded_count"] == 1
    assert result["data"]["failed_count"] == 1


@pytest.mark.asyncio
async def test_upload_item_images_reraises_storage_errors(monkeypatch):
    monkeypatch.setattr(
        items_module,
        "parallel_with_retry",
        AsyncMock(side_effect=StorageServiceError("backend down")),
    )

    with pytest.raises(StorageServiceError):
        await items_module.upload_item_images(
            files=[_FakeUpload()], user_id=USER_ID, db=Mock()
        )


@pytest.mark.asyncio
async def test_upload_item_images_wraps_unexpected_errors(monkeypatch):
    monkeypatch.setattr(
        items_module, "parallel_with_retry", AsyncMock(side_effect=RuntimeError("boom"))
    )

    with pytest.raises(StorageServiceError):
        await items_module.upload_item_images(
            files=[_FakeUpload()], user_id=USER_ID, db=Mock()
        )


# ============================================================================
# POST /items (create)
# ============================================================================


@pytest.mark.asyncio
async def test_create_item_inserts_with_images_and_stores_embedding(monkeypatch):
    db = FakeDB()
    reserve, generate, release = _patch_embedding(monkeypatch)
    vector = _patch_vector_service(monkeypatch)

    item = ItemCreate(
        name="Linen shirt",
        category="tops",
        colors=["white"],
        brand="Uniqlo",
        images=[ItemImageBase(image_url="https://cdn/1.jpg", is_primary=True)],
    )
    result = await items_module.create_item(item=item, user_id=USER_ID, db=db)

    assert result["message"] == "Created"
    data = result["data"]
    assert data["name"] == "Linen shirt"
    assert data["user_id"] == USER_ID
    assert data["usage_times_worn"] == 0
    assert len(data["images"]) == 1
    assert data["images"][0]["image_url"] == "https://cdn/1.jpg"

    assert db.inserts[0][0] == "items"
    assert db.inserts[1][0] == "item_images"
    assert len(db.inserts[1][1]) == 1

    reserve.assert_awaited_once()
    assert reserve.await_args.kwargs["operation_type"] == OperationType.EMBEDDING
    generate.assert_awaited_once()
    vector.upsert_item.assert_awaited_once()
    release.assert_not_awaited()


@pytest.mark.asyncio
async def test_create_item_skips_embedding_when_quota_exhausted(monkeypatch):
    db = FakeDB()
    reserve, generate, release = _patch_embedding(monkeypatch, reserved=False)
    vector = _patch_vector_service(monkeypatch)

    result = await items_module.create_item(
        item=ItemCreate(name="Tee", category="tops"), user_id=USER_ID, db=db
    )

    assert result["message"] == "Created"
    assert result["data"]["images"] == []
    generate.assert_not_awaited()
    vector.upsert_item.assert_not_awaited()
    release.assert_not_awaited()


@pytest.mark.asyncio
async def test_create_item_releases_reservation_when_embedding_is_empty(monkeypatch):
    db = FakeDB()
    reserve, generate, release = _patch_embedding(monkeypatch, embedding=None)
    vector = _patch_vector_service(monkeypatch)

    result = await items_module.create_item(
        item=ItemCreate(name="Tee", category="tops"), user_id=USER_ID, db=db
    )

    assert result["message"] == "Created"
    vector.upsert_item.assert_not_awaited()
    release.assert_awaited_once()


@pytest.mark.asyncio
async def test_create_item_releases_reservation_when_embedding_fails(monkeypatch):
    db = FakeDB()
    reserve, generate, release = _patch_embedding(
        monkeypatch, embedding_error=RuntimeError("provider down")
    )

    result = await items_module.create_item(
        item=ItemCreate(name="Tee", category="tops"), user_id=USER_ID, db=db
    )

    assert result["message"] == "Created"
    release.assert_awaited_once()


@pytest.mark.asyncio
async def test_create_item_raises_database_error_when_insert_returns_nothing(monkeypatch):
    monkeypatch.setattr(
        items_module, "execute_with_reconnect", AsyncMock(return_value=Mock(data=[]))
    )

    with pytest.raises(DatabaseError):
        await items_module.create_item(
            item=ItemCreate(name="Tee", category="tops"), user_id=USER_ID, db=Mock()
        )


@pytest.mark.asyncio
async def test_create_item_wraps_unexpected_errors(monkeypatch):
    monkeypatch.setattr(
        items_module,
        "execute_with_reconnect",
        AsyncMock(side_effect=RuntimeError("boom")),
    )

    with pytest.raises(DatabaseError):
        await items_module.create_item(
            item=ItemCreate(name="Tee", category="tops"), user_id=USER_ID, db=Mock()
        )


@pytest.mark.asyncio
async def test_create_item_persists_client_request_id(monkeypatch):
    """F1-07: the idempotency key rides the insert payload."""
    db = FakeDB()
    reserve, generate, release = _patch_embedding(monkeypatch, reserved=False)
    _patch_vector_service(monkeypatch)

    await items_module.create_item(
        item=ItemCreate(name="Tee", category="tops", client_request_id="req-abc"),
        user_id=USER_ID,
        db=db,
    )

    assert db.inserts[0][0] == "items"
    assert db.inserts[0][1]["client_request_id"] == "req-abc"
    reserve.assert_awaited_once()
    generate.assert_not_awaited()


@pytest.mark.asyncio
async def test_create_item_replays_existing_row_for_repeated_client_request_id(monkeypatch):
    """F1-07: a transport retry that committed before the response was lost
    must replay the original row instead of inserting a duplicate item."""
    db = FakeDB(rows={"items": [_item_row(client_request_id="req-abc")]})
    reserve, generate, release = _patch_embedding(monkeypatch)
    _patch_vector_service(monkeypatch)

    result = await items_module.create_item(
        item=ItemCreate(
            name="Tee",
            category="tops",
            images=[ItemImageBase(image_url="https://cdn/1.jpg", is_primary=True)],
            client_request_id="req-abc",
        ),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Created"
    assert result["data"]["id"] == ITEM_ID
    assert result["data"]["name"] == "Crew-neck tee"
    # No second items insert (the replay path returns before the write).
    assert all(t != "items" for t, _p, _c in db.inserts)
    reserve.assert_not_awaited()
    generate.assert_not_awaited()
    release.assert_not_awaited()


@pytest.mark.asyncio
async def test_create_item_replay_ignores_deleted_rows(monkeypatch):
    """A hard-deleted item with the same key is not a replay target — the
    client gets a fresh insert (and its own key, but this pins the lookup's
    is_deleted filter)."""
    db = FakeDB(
        rows={"items": [_item_row(client_request_id="req-abc", is_deleted=True)]}
    )
    reserve, generate, release = _patch_embedding(monkeypatch, reserved=False)
    _patch_vector_service(monkeypatch)

    result = await items_module.create_item(
        item=ItemCreate(name="Tee", category="tops", client_request_id="req-abc"),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Created"
    assert result["data"]["id"] != ITEM_ID
    assert db.inserts[0][0] == "items"
    assert db.inserts[0][1]["client_request_id"] == "req-abc"


@pytest.mark.asyncio
async def test_create_item_race_collapses_onto_client_request_id_winner(monkeypatch):
    """F1-07: two concurrent requests with the same key both miss the replay
    lookup; the loser's insert hits the unique index (23505) and must replay
    the winner's row instead of 500ing."""
    winner = _item_row(client_request_id="req-abc")
    calls = {"n": 0}

    async def flaky_execute(builder, db, *, extra=None, max_retries=1, backoff_seconds=0.4):
        calls["n"] += 1
        if extra and extra.get("operation") == "create_item.insert":
            raise PGRSTDuplicateError("items", ("user_id", "client_request_id"))
        if extra and extra.get("operation") == "create_item.replay_lookup":
            # First lookup (pre-insert) misses; the post-race lookup wins.
            if calls["n"] > 1:
                return SimpleNamespace(data=winner, count=1)
            return SimpleNamespace(data=[], count=0)
        raise AssertionError(f"unexpected operation: {extra}")

    monkeypatch.setattr(items_module, "execute_with_reconnect", flaky_execute)

    result = await items_module.create_item(
        item=ItemCreate(name="Tee", category="tops", client_request_id="req-abc"),
        user_id=USER_ID,
        db=Mock(),
    )

    assert result["message"] == "Created"
    assert result["data"]["id"] == ITEM_ID


# ============================================================================
# GET /items (list + filters + pagination)
# ============================================================================


@pytest.mark.asyncio
async def test_list_items_applies_every_filter_and_normalizes_rows(monkeypatch):
    db = FakeDB(
        rows={
            "items": [
                _item_row(
                    id=ITEM_ID,
                    name="White tee",
                    category="tops",
                    condition="clean",
                    is_favorite=True,
                    brand="Nike",
                    colors=["red"],
                    occasion_tags=["party"],
                ),
                _item_row(
                    id=OTHER_ITEM_ID,
                    name="Blue tee",
                    category="outerwear",
                    condition="clean",
                    is_favorite=True,
                    brand="Nike",
                    colors=["red"],
                    occasion_tags=["party"],
                ),
                _item_row(
                    id="55555555-5555-5555-5555-555555555555",
                    name="Denim jacket",
                    category="outerwear",
                    condition="dirty",
                    is_favorite=False,
                    brand="Levi's",
                ),
            ]
        }
    )
    jsonb_calls: List[tuple] = []

    def fake_jsonb_contains(builder, column, values):
        jsonb_calls.append((column, values))
        return builder

    monkeypatch.setattr(items_module, "jsonb_contains", fake_jsonb_contains)

    result = await items_module.list_items(
        page=1,
        page_size=2,
        category="tops,outerwear",
        color="red",
        occasion=" party ",
        condition="clean",
        brand="Nike",
        search="tee",
        is_favorite=True,
        user_id=USER_ID,
        db=db,
    )

    data = result["data"]
    assert data["total"] == 2
    assert [i["id"] for i in data["items"]] == [ITEM_ID, OTHER_ITEM_ID]
    assert data["total_pages"] == 1
    assert data["has_next"] is False
    assert data["has_prev"] is False
    assert data["ignored_filters"] == {}
    # Both queries (count + page) apply color and occasion containment.
    assert jsonb_calls == [
        ("colors", ["red"]),
        ("occasion_tags", ["party"]),
        ("colors", ["red"]),
        ("occasion_tags", ["party"]),
    ]
    # Every row came back normalized with an `images` list.
    assert all("images" in i for i in data["items"])


@pytest.mark.asyncio
async def test_list_items_paginates_when_no_filters_are_given():
    db = FakeDB(
        rows={
            "items": [
                _item_row(id=ITEM_ID),
                _item_row(id=OTHER_ITEM_ID),
                _item_row(id="55555555-5555-5555-5555-555555555555"),
            ]
        }
    )

    result = await items_module.list_items(
        page=2,
        page_size=1,
        category=None,
        color=None,
        occasion=None,
        condition=None,
        brand=None,
        search=None,
        is_favorite=None,
        user_id=USER_ID,
        db=db,
    )

    data = result["data"]
    assert data["total"] == 3
    assert len(data["items"]) == 1
    assert data["total_pages"] == 3
    assert data["has_next"] is True
    assert data["has_prev"] is True


@pytest.mark.asyncio
async def test_list_items_single_category_uses_eq_and_empty_occasion_is_dropped():
    db = FakeDB(rows={"items": [_item_row()]})

    result = await items_module.list_items(
        page=1,
        page_size=20,
        category="tops",
        color=None,
        occasion="   ",
        condition=None,
        brand=None,
        search=None,
        is_favorite=None,
        user_id=USER_ID,
        db=db,
    )

    assert result["data"]["total"] == 1
    ops = {entry[1] for entry in db.filters}
    assert "eq" in ops
    assert "in" not in ops
    assert ("items", "eq", "category", "tops") in db.filters


@pytest.mark.asyncio
async def test_list_items_wraps_unexpected_errors(monkeypatch):
    monkeypatch.setattr(
        items_module,
        "execute_with_reconnect",
        AsyncMock(side_effect=RuntimeError("boom")),
    )

    with pytest.raises(DatabaseError):
        await items_module.list_items(
            page=1,
            page_size=20,
            category=None,
            color=None,
            occasion=None,
            condition=None,
            brand=None,
            search=None,
            is_favorite=None,
            user_id=USER_ID,
            db=Mock(),
        )


@pytest.mark.asyncio
async def test_list_items_reraises_database_errors(monkeypatch):
    monkeypatch.setattr(
        items_module,
        "execute_with_reconnect",
        AsyncMock(side_effect=DatabaseError("db down", operation="select")),
    )

    with pytest.raises(DatabaseError):
        await items_module.list_items(
            page=1,
            page_size=20,
            category=None,
            color=None,
            occasion=None,
            condition=None,
            brand=None,
            search=None,
            is_favorite=None,
            user_id=USER_ID,
            db=Mock(),
        )


# ============================================================================
# GET /items/{item_id}
# ============================================================================


@pytest.mark.asyncio
async def test_get_item_returns_normalized_item_with_images():
    db = FakeDB(
        rows={
            "items": [
                _item_row(item_images=[_image_row()]),
            ]
        }
    )

    result = await items_module.get_item(item_id=ITEM_ID, user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    assert result["data"]["id"] == ITEM_ID
    assert result["data"]["images"][0]["image_url"] == "https://cdn.example/1.jpg"


@pytest.mark.asyncio
async def test_get_item_defaults_images_for_rows_without_item_images():
    """A row with no `item_images` key must come back with images=[] (the
    `item.get("images")` fallback branch of _normalize_item_images)."""
    db = FakeDB(rows={"items": [_item_row(name="Plain tee")]})

    result = await items_module.get_item(item_id=ITEM_ID, user_id=USER_ID, db=db)

    assert result["data"]["name"] == "Plain tee"
    assert result["data"]["images"] == []


@pytest.mark.asyncio
async def test_get_item_raises_not_found():
    db = FakeDB(rows={"items": []})

    with pytest.raises(ItemNotFoundError):
        await items_module.get_item(item_id=ITEM_ID, user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_get_item_wraps_unexpected_errors(monkeypatch):
    monkeypatch.setattr(
        items_module,
        "execute_with_reconnect",
        AsyncMock(side_effect=RuntimeError("boom")),
    )

    with pytest.raises(DatabaseError):
        await items_module.get_item(item_id=ITEM_ID, user_id=USER_ID, db=Mock())


@pytest.mark.asyncio
async def test_get_item_maps_pgrst116_to_not_found(monkeypatch):
    """Real-client regression for the 2026-08-09 production 500 burst.

    postgrest-py's ``single()`` RAISES APIError (406/PGRST116) when the
    query matches zero rows, so a deleted or not-owned item 500'd instead of
    404ing. The handler now uses ``maybe_single()`` and, as belt-and-
    suspenders, maps a structured PGRST116 to ItemNotFoundError.
    """
    from postgrest.exceptions import APIError as PostgrestAPIError

    monkeypatch.setattr(
        items_module,
        "execute_with_reconnect",
        AsyncMock(
            side_effect=PostgrestAPIError(
                {
                    "code": "PGRST116",
                    "message": "JSON object requested, multiple (or no) rows returned",
                    "details": None,
                    "hint": None,
                }
            )
        ),
    )

    with pytest.raises(ItemNotFoundError):
        await items_module.get_item(item_id=ITEM_ID, user_id=USER_ID, db=Mock())


# ============================================================================
# PUT /items/{item_id}
# ============================================================================


@pytest.mark.asyncio
async def test_update_item_applies_patch_and_refreshes(monkeypatch):
    db = FakeDB(rows={"items": [_item_row(name="Old name")]})
    reserve, generate, release = _patch_embedding(monkeypatch)
    vector = _patch_vector_service(monkeypatch)

    result = await items_module.update_item(
        item_id=ITEM_ID,
        update=ItemUpdate(name="New name", purchase_date=datetime(2026, 2, 1)),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Updated"
    db.assert_update("items", name="New name")
    assert db.updates[0][1]["purchase_date"] == "2026-02-01"
    assert db.updates[0][1]["updated_at"]
    generate.assert_awaited_once()
    vector.upsert_item.assert_awaited_once()
    release.assert_not_awaited()


@pytest.mark.asyncio
async def test_update_item_with_an_empty_patch_reads_instead_of_writing():
    db = FakeDB(rows={"items": [_item_row()]})

    result = await items_module.update_item(
        item_id=ITEM_ID, update=ItemUpdate(), user_id=USER_ID, db=db
    )

    assert result["message"] == "OK"
    assert result["data"]["id"] == ITEM_ID
    assert db.updates == []


@pytest.mark.asyncio
async def test_update_item_with_non_embedding_fields_skips_vector(monkeypatch):
    db = FakeDB(rows={"items": [_item_row()]})
    _patch_embedding(monkeypatch)
    vector = _patch_vector_service(monkeypatch)

    result = await items_module.update_item(
        item_id=ITEM_ID, update=ItemUpdate(price=42.0), user_id=USER_ID, db=db
    )

    assert result["message"] == "Updated"
    db.assert_update("items", price=42.0)
    vector.upsert_item.assert_not_awaited()


@pytest.mark.asyncio
async def test_update_item_raises_not_found():
    db = FakeDB(rows={"items": []})

    with pytest.raises(ItemNotFoundError):
        await items_module.update_item(
            item_id=ITEM_ID, update=ItemUpdate(name="X"), user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_update_item_skips_embedding_when_quota_exhausted(monkeypatch):
    db = FakeDB(rows={"items": [_item_row()]})
    reserve, generate, release = _patch_embedding(monkeypatch, reserved=False)
    vector = _patch_vector_service(monkeypatch)

    result = await items_module.update_item(
        item_id=ITEM_ID, update=ItemUpdate(name="X"), user_id=USER_ID, db=db
    )

    assert result["message"] == "Updated"
    generate.assert_not_awaited()
    vector.upsert_item.assert_not_awaited()
    release.assert_not_awaited()


@pytest.mark.asyncio
async def test_update_item_releases_reservation_when_embedding_is_empty(monkeypatch):
    """An empty embedding (no vector) releases the reservation and skips upsert."""
    db = FakeDB(rows={"items": [_item_row()]})
    reserve, generate, release = _patch_embedding(monkeypatch, embedding=None)
    vector = _patch_vector_service(monkeypatch)

    result = await items_module.update_item(
        item_id=ITEM_ID, update=ItemUpdate(name="X"), user_id=USER_ID, db=db
    )

    assert result["message"] == "Updated"
    vector.upsert_item.assert_not_awaited()
    release.assert_awaited_once()


@pytest.mark.asyncio
async def test_update_item_releases_reservation_when_embedding_fails(monkeypatch):
    db = FakeDB(rows={"items": [_item_row()]})
    reserve, generate, release = _patch_embedding(
        monkeypatch, embedding_error=RuntimeError("provider down")
    )

    result = await items_module.update_item(
        item_id=ITEM_ID, update=ItemUpdate(name="X"), user_id=USER_ID, db=db
    )

    assert result["message"] == "Updated"
    release.assert_awaited_once()


@pytest.mark.asyncio
async def test_update_item_raises_not_found_when_the_refresh_read_misses():
    """The update succeeds but the follow-up refresh read returns nothing:
    the handler reports ItemNotFoundError (row vanished mid-update)."""
    db = Mock()
    select_execute = db.table.return_value.select.return_value.eq.return_value.eq.return_value.maybe_single.return_value.execute
    select_execute.side_effect = [
        SimpleNamespace(data={"id": ITEM_ID}),  # existence check
        SimpleNamespace(data=None),  # refresh read
    ]
    db.table.return_value.update.return_value.eq.return_value.eq.return_value.execute.return_value = SimpleNamespace(
        data=[{"id": ITEM_ID}]
    )

    with pytest.raises(ItemNotFoundError):
        await items_module.update_item(
            item_id=ITEM_ID, update=ItemUpdate(name="X"), user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_update_item_raises_database_error_when_update_returns_nothing():
    db = _row_then_empty_update_db({"id": ITEM_ID})

    with pytest.raises(DatabaseError):
        await items_module.update_item(
            item_id=ITEM_ID, update=ItemUpdate(name="X"), user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_update_item_wraps_unexpected_errors():
    db = _error_db(RuntimeError("boom"))

    with pytest.raises(DatabaseError):
        await items_module.update_item(
            item_id=ITEM_ID, update=ItemUpdate(name="X"), user_id=USER_ID, db=db
        )


# ============================================================================
# DELETE /items/{item_id}
# ============================================================================


@pytest.mark.asyncio
async def test_delete_item_removes_row_and_storage_paths(monkeypatch):
    # A2-01: source keys are re-verified against the canonical key format
    # (owner segment + 32-hex name) at deletion resolution time, so the
    # fixture must use a real-shaped key, not "u/sources/shot.jpg".
    source_key = f"users/{USER_ID}/sources/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.jpg"
    db = FakeDB(
        rows={
            "items": [
                _item_row(source_image_storage_path=source_key),
            ],
            "item_images": [
                _image_row(storage_path=f"users/{USER_ID}/items/11111111111111111111111111111111.jpg"),
            ],
        }
    )
    deleted_paths: List[str] = []

    async def fake_delete_multiple_images(*, db, storage_paths, bucket=None):
        deleted_paths.extend(storage_paths)
        return len(storage_paths)

    monkeypatch.setattr(
        StorageService, "delete_multiple_images", staticmethod(fake_delete_multiple_images)
    )
    vector = _patch_vector_service(monkeypatch)

    result = await items_module.delete_item(item_id=ITEM_ID, user_id=USER_ID, db=db)

    assert result is None
    assert ("items", None) in db.deletes
    vector.delete_item.assert_awaited_once_with(ITEM_ID)
    # Canonical fixture keys pass through the delete-path normalizer unchanged.
    assert sorted(deleted_paths) == sorted([
        f"users/{USER_ID}/items/11111111111111111111111111111111.jpg",
        f"users/{USER_ID}/items/11111111111111111111111111111111_thumb.webp",
        f"users/{USER_ID}/sources/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.jpg",
        f"users/{USER_ID}/sources/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa_thumb.webp",
    ])


@pytest.mark.asyncio
async def test_delete_item_raises_not_found():
    db = FakeDB(rows={"items": []})

    with pytest.raises(ItemNotFoundError):
        await items_module.delete_item(item_id=ITEM_ID, user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_delete_item_survives_storage_path_resolution_failure(monkeypatch):
    db = FakeDB(rows={"items": [_item_row()]})
    monkeypatch.setattr(
        StorageService,
        "resolve_owned_storage_paths",
        AsyncMock(side_effect=RuntimeError("storage down")),
    )
    _patch_vector_service(monkeypatch)

    result = await items_module.delete_item(item_id=ITEM_ID, user_id=USER_ID, db=db)

    assert result is None
    assert ("items", None) in db.deletes


@pytest.mark.asyncio
async def test_delete_item_survives_vector_and_storage_failures(monkeypatch):
    db = FakeDB(
        rows={
            "items": [_item_row()],
            "item_images": [_image_row(storage_path="u/items/one.jpg")],
        }
    )
    vector = _patch_vector_service(monkeypatch)
    vector.delete_item = AsyncMock(side_effect=RuntimeError("vector down"))
    monkeypatch.setattr(
        StorageService,
        "delete_multiple_images",
        AsyncMock(side_effect=StorageServiceError("storage down")),
    )

    result = await items_module.delete_item(item_id=ITEM_ID, user_id=USER_ID, db=db)

    assert result is None
    assert ("items", None) in db.deletes


@pytest.mark.asyncio
async def test_delete_item_wraps_unexpected_errors():
    db = _error_db(RuntimeError("boom"))

    with pytest.raises(DatabaseError):
        await items_module.delete_item(item_id=ITEM_ID, user_id=USER_ID, db=db)


# ============================================================================
# POST /items/{item_id}/favorite
# ============================================================================


@pytest.mark.asyncio
async def test_toggle_favorite_marks_an_unfavorite_item():
    db = FakeDB(rows={"items": [_item_row(is_favorite=False)]})

    result = await items_module.toggle_favorite(item_id=ITEM_ID, user_id=USER_ID, db=db)

    assert result["data"] == {"id": ITEM_ID, "is_favorite": True}
    assert db.updates[0][1]["is_favorite"] is True


@pytest.mark.asyncio
async def test_toggle_favorite_unmarks_a_favorite_item():
    db = FakeDB(rows={"items": [_item_row(is_favorite=True)]})

    result = await items_module.toggle_favorite(item_id=ITEM_ID, user_id=USER_ID, db=db)

    assert result["data"] == {"id": ITEM_ID, "is_favorite": False}


@pytest.mark.asyncio
async def test_toggle_favorite_raises_not_found():
    db = FakeDB(rows={"items": []})

    with pytest.raises(ItemNotFoundError):
        await items_module.toggle_favorite(item_id=ITEM_ID, user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_toggle_favorite_wraps_unexpected_errors():
    db = _error_db(RuntimeError("boom"))

    with pytest.raises(DatabaseError):
        await items_module.toggle_favorite(item_id=ITEM_ID, user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_toggle_favorite_raises_database_error_when_update_returns_nothing():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.single.return_value.execute.return_value = SimpleNamespace(
        data={"id": ITEM_ID, "is_favorite": False}
    )
    db.table.return_value.update.return_value.eq.return_value.execute.return_value = Mock(data=[])

    with pytest.raises(DatabaseError):
        await items_module.toggle_favorite(item_id=ITEM_ID, user_id=USER_ID, db=db)


# ============================================================================
# POST /items/{item_id}/wear
# ============================================================================


@pytest.mark.asyncio
async def test_mark_worn_increments_the_wear_count():
    """mark_worn now calls the atomic increment_item_worn RPC (migration 044)
    and reports the count from the RETURNING * row."""

    db = FakeDB(
        rows={"items": [_item_row(usage_times_worn=2)]},
        rpc_results={"increment_item_worn": [_item_row(usage_times_worn=3)]},
    )

    result = await items_module.mark_worn(item_id=ITEM_ID, user_id=USER_ID, db=db)

    assert result["data"] == {"id": ITEM_ID, "usage_times_worn": 3}
    assert db.rpc_calls == [
        ("increment_item_worn", {"item_uuid": ITEM_ID, "user_uuid": USER_ID})
    ]
    # No read-modify-write update anywhere: the RPC owns the increment.
    assert db.updates == []
    assert db.selects == []


@pytest.mark.asyncio
async def test_mark_worn_defaults_a_missing_count_to_zero():
    """The RPC row is the single source of truth; a NULL count in the
    returned row is coerced to 0 like the legacy path did."""

    row = _item_row()
    row["usage_times_worn"] = None  # RPC row with a NULL count
    db = FakeDB(
        rows={"items": [_item_row()]},
        rpc_results={"increment_item_worn": [row]},
    )

    result = await items_module.mark_worn(item_id=ITEM_ID, user_id=USER_ID, db=db)

    assert result["data"]["usage_times_worn"] == 0


@pytest.mark.asyncio
async def test_mark_worn_raises_not_found():
    """The RPC returns zero rows for a missing/unowned item -> 404."""

    db = FakeDB(rows={"items": []})

    with pytest.raises(ItemNotFoundError):
        await items_module.mark_worn(item_id=ITEM_ID, user_id=USER_ID, db=db)

    assert db.rpc_calls == [
        ("increment_item_worn", {"item_uuid": ITEM_ID, "user_uuid": USER_ID})
    ]


@pytest.mark.asyncio
async def test_mark_worn_falls_back_when_rpc_missing():
    """Migration-gap fallback: when increment_item_worn is absent (PGRST202),
    the endpoint degrades to the legacy read-modify-write instead of 500ing."""

    db = Mock()
    db.rpc.return_value.execute.side_effect = RuntimeError(
        "PGRST202 could not find the function public.increment_item_worn in "
        "the schema cache"
    )
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.maybe_single.return_value.execute.return_value = SimpleNamespace(
        data={"id": ITEM_ID, "usage_times_worn": 4}
    )

    result = await items_module.mark_worn(item_id=ITEM_ID, user_id=USER_ID, db=db)

    assert result["data"] == {"id": ITEM_ID, "usage_times_worn": 5}
    # The legacy fallback wrote read+1 via the table update.
    update_call = db.table.return_value.update.call_args[0][0]
    assert update_call["usage_times_worn"] == 5
    assert update_call["usage_last_worn"]
    assert update_call["updated_at"]


@pytest.mark.asyncio
async def test_mark_worn_wraps_unexpected_errors():
    db = Mock()
    db.rpc.return_value.execute.side_effect = RuntimeError("boom")

    with pytest.raises(DatabaseError):
        await items_module.mark_worn(item_id=ITEM_ID, user_id=USER_ID, db=db)


# ============================================================================
# POST /items/{item_id}/images
# ============================================================================


@pytest.mark.asyncio
async def test_upload_item_image_inserts_and_clears_other_primaries(monkeypatch):
    """The primary flag is flipped atomically via set_primary_item_image
    (migration 044); the two-step clear is no longer used on this path."""
    db = FakeDB(rows={"items": [_item_row()]})

    async def fake_upload(*, db, user_id, filename, file_data, is_primary=False):
        return {
            "image_url": "https://cdn/new.jpg",
            "thumbnail_url": "https://cdn/new-t.jpg",
            "storage_path": "u/items/new.jpg",
            "width": 100,
            "height": 200,
        }

    monkeypatch.setattr(StorageService, "upload_item_image", staticmethod(fake_upload))

    result = await items_module.upload_item_image(
        item_id=ITEM_ID,
        file=_FakeUpload(filename="new.jpg"),
        is_primary=True,
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Created"
    assert result["data"]["image_url"] == "https://cdn/new.jpg"
    assert db.inserts[0][0] == "item_images"
    inserted_id = db.inserts[0][1]["id"]
    assert db.rpc_calls == [
        ("set_primary_item_image", {"item_uuid": ITEM_ID, "image_uuid": inserted_id})
    ]
    # The atomic RPC replaces the two-step clear: no second UPDATE.
    assert db.updates == []


@pytest.mark.asyncio
async def test_upload_item_image_falls_back_to_two_step_clear_when_rpc_missing(monkeypatch):
    """Migration-gap fallback: when set_primary_item_image is absent
    (PGRST202), the old two-step clear keeps the endpoint working."""
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.maybe_single.return_value.execute.return_value = SimpleNamespace(
        data={"id": ITEM_ID}
    )
    db.table.return_value.insert.return_value.execute.return_value = Mock(
        data=[{"id": "img-new"}]
    )
    db.rpc.return_value.execute.side_effect = RuntimeError(
        "PGRST202 could not find the function public.set_primary_item_image in "
        "the schema cache"
    )
    monkeypatch.setattr(
        StorageService,
        "upload_item_image",
        staticmethod(
            AsyncMock(
                return_value={
                    "image_url": "https://cdn/new.jpg",
                    "thumbnail_url": None,
                    "storage_path": "u/items/new.jpg",
                }
            )
        ),
    )

    result = await items_module.upload_item_image(
        item_id=ITEM_ID,
        file=_FakeUpload(),
        is_primary=True,
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Created"
    db.rpc.assert_called_once_with(
        "set_primary_item_image", {"item_uuid": ITEM_ID, "image_uuid": "img-new"}
    )
    # Fallback two-step clear ran (is_primary=False on the OTHER rows).
    db.table.return_value.update.assert_called_once_with({"is_primary": False})
    db.table.return_value.update.return_value.eq.return_value.neq.assert_called_once_with(
        "id", "img-new"
    )


@pytest.mark.asyncio
async def test_upload_item_image_non_primary_skips_the_clear_step(monkeypatch):
    db = FakeDB(rows={"items": [_item_row()]})
    monkeypatch.setattr(
        StorageService,
        "upload_item_image",
        staticmethod(
            AsyncMock(
                return_value={
                    "image_url": "https://cdn/new.jpg",
                    "thumbnail_url": None,
                    "storage_path": "u/items/new.jpg",
                }
            )
        ),
    )

    result = await items_module.upload_item_image(
        item_id=ITEM_ID,
        file=_FakeUpload(),
        is_primary=False,
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Created"
    assert result["data"]["is_primary"] is False
    # Non-primary uploads never touch the RPC or the clear step.
    assert db.updates == []
    assert db.rpc_calls == []


@pytest.mark.asyncio
async def test_upload_item_image_raises_not_found():
    db = FakeDB(rows={"items": []})

    with pytest.raises(ItemNotFoundError):
        await items_module.upload_item_image(
            item_id=ITEM_ID, file=_FakeUpload(), is_primary=False, user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_upload_item_image_rejects_non_image_content_type():
    db = FakeDB(rows={"items": [_item_row()]})
    upload = _FakeUpload(data=b"x", filename="a.txt", content_type="text/plain")

    with pytest.raises(UnsupportedMediaTypeError):
        await items_module.upload_item_image(
            item_id=ITEM_ID, file=upload, is_primary=False, user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_upload_item_image_wraps_value_error_as_validation_error(monkeypatch):
    db = FakeDB(rows={"items": [_item_row()]})
    monkeypatch.setattr(
        StorageService, "upload_item_image", AsyncMock(side_effect=ValueError("bad image"))
    )

    with pytest.raises(ValidationError):
        await items_module.upload_item_image(
            item_id=ITEM_ID, file=_FakeUpload(), is_primary=False, user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_upload_item_image_wraps_unexpected_errors(monkeypatch):
    db = FakeDB(rows={"items": [_item_row()]})
    monkeypatch.setattr(
        StorageService, "upload_item_image", AsyncMock(side_effect=RuntimeError("boom"))
    )

    with pytest.raises(StorageServiceError):
        await items_module.upload_item_image(
            item_id=ITEM_ID, file=_FakeUpload(), is_primary=False, user_id=USER_ID, db=db
        )


# ============================================================================
# DELETE /items/{item_id}/images/{image_id}
# ============================================================================


@pytest.mark.asyncio
async def test_delete_item_image_deletes_storage_and_row(monkeypatch):
    db = FakeDB(
        rows={
            "items": [_item_row()],
            "item_images": [_image_row(storage_path="u/items/one.jpg")],
        }
    )
    deleted: List[str] = []

    async def fake_delete_image(*, db, storage_path, bucket=None):
        deleted.append(storage_path)

    monkeypatch.setattr(StorageService, "delete_image", staticmethod(fake_delete_image))

    result = await items_module.delete_item_image(
        item_id=ITEM_ID, image_id=IMAGE_ID, user_id=USER_ID, db=db
    )

    assert result["data"] == {"deleted": True}
    # The route passes the stored path to delete_image verbatim; the legacy
    # -> users/ mapping happens inside the real delete_image (not the fake).
    assert deleted == ["u/items/one.jpg"]
    assert ("item_images", None) in db.deletes


@pytest.mark.asyncio
async def test_delete_item_image_raises_image_not_found():
    db = FakeDB(rows={"items": [_item_row()]})

    with pytest.raises(ImageNotFoundError):
        await items_module.delete_item_image(
            item_id=ITEM_ID, image_id=IMAGE_ID, user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_delete_item_image_raises_item_not_found():
    db = FakeDB(rows={"items": [], "item_images": [_image_row()]})

    with pytest.raises(ItemNotFoundError):
        await items_module.delete_item_image(
            item_id=ITEM_ID, image_id=IMAGE_ID, user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_delete_item_image_survives_storage_failure(monkeypatch):
    db = FakeDB(
        rows={
            "items": [_item_row()],
            "item_images": [_image_row(storage_path="u/items/one.jpg")],
        }
    )
    monkeypatch.setattr(
        StorageService, "delete_image", AsyncMock(side_effect=RuntimeError("storage down"))
    )

    result = await items_module.delete_item_image(
        item_id=ITEM_ID, image_id=IMAGE_ID, user_id=USER_ID, db=db
    )

    assert result["data"] == {"deleted": True}
    assert ("item_images", None) in db.deletes


@pytest.mark.asyncio
async def test_delete_item_image_without_storage_path_skips_storage(monkeypatch):
    """A legacy image row with no storage_path is deleted from the DB only."""
    db = FakeDB(
        rows={
            "items": [_item_row()],
            "item_images": [_image_row(storage_path=None)],
        }
    )
    delete_image = AsyncMock()
    monkeypatch.setattr(StorageService, "delete_image", delete_image)

    result = await items_module.delete_item_image(
        item_id=ITEM_ID, image_id=IMAGE_ID, user_id=USER_ID, db=db
    )

    assert result["data"] == {"deleted": True}
    delete_image.assert_not_awaited()


@pytest.mark.asyncio
async def test_delete_item_image_wraps_unexpected_errors():
    db = _error_db(RuntimeError("boom"))

    with pytest.raises(DatabaseError):
        await items_module.delete_item_image(
            item_id=ITEM_ID, image_id=IMAGE_ID, user_id=USER_ID, db=db
        )


# ============================================================================
# POST /items/batch-delete
# ============================================================================


@pytest.mark.asyncio
async def test_batch_delete_requires_at_least_one_item_id():
    request = items_module.BatchDeleteItemsRequest(item_ids=[""])

    with pytest.raises(ValidationError):
        await items_module.batch_delete_items(request=request, user_id=USER_ID, db=Mock())


@pytest.mark.asyncio
async def test_batch_delete_cleans_storage_and_embeddings(monkeypatch):
    # A2-01: source keys must be canonical ({user}/sources/{32-hex}.{ext}) —
    # see test_delete_item_removes_row_and_storage_paths.
    source_key = f"users/{USER_ID}/sources/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.jpg"
    db = FakeDB(
        rows={
            "items": [
                _item_row(source_image_storage_path=source_key),
                _item_row(id=OTHER_ITEM_ID),
            ],
            "item_images": [
                _image_row(storage_path=f"users/{USER_ID}/items/11111111111111111111111111111111.jpg"),
                _image_row(
                    id="55555555-5555-5555-5555-555555555555",
                    item_id=OTHER_ITEM_ID,
                    storage_path=f"users/{USER_ID}/items/22222222222222222222222222222222.jpg",
                ),
            ],
        }
    )
    deleted_paths: List[str] = []

    async def fake_delete_multiple_images(*, db, storage_paths, bucket=None):
        deleted_paths.extend(storage_paths)
        return len(storage_paths)

    monkeypatch.setattr(
        StorageService, "delete_multiple_images", staticmethod(fake_delete_multiple_images)
    )
    vector = _patch_vector_service(monkeypatch)

    request = items_module.BatchDeleteItemsRequest(item_ids=[ITEM_ID, OTHER_ITEM_ID])
    result = await items_module.batch_delete_items(request=request, user_id=USER_ID, db=db)

    assert result["data"]["deleted_count"] == 2
    vector.batch_delete.assert_awaited_once_with([ITEM_ID, OTHER_ITEM_ID])
    # Canonical fixture keys pass through the delete-path normalizer unchanged.
    assert sorted(deleted_paths) == sorted([
        f"users/{USER_ID}/items/11111111111111111111111111111111.jpg",
        f"users/{USER_ID}/items/11111111111111111111111111111111_thumb.webp",
        f"users/{USER_ID}/items/22222222222222222222222222222222.jpg",
        f"users/{USER_ID}/items/22222222222222222222222222222222_thumb.webp",
        f"users/{USER_ID}/sources/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.jpg",
        f"users/{USER_ID}/sources/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa_thumb.webp",
    ])


@pytest.mark.asyncio
async def test_batch_delete_skips_storage_when_nothing_is_owned(monkeypatch):
    """Rows with no image paths resolve zero storage paths, so the storage
    cleanup branch is skipped entirely (but embeddings still run)."""
    db = FakeDB(rows={"items": [_item_row(), _item_row(id=OTHER_ITEM_ID)]})
    delete_multiple = AsyncMock(return_value=0)
    monkeypatch.setattr(StorageService, "delete_multiple_images", delete_multiple)
    vector = _patch_vector_service(monkeypatch)

    request = items_module.BatchDeleteItemsRequest(item_ids=[ITEM_ID])
    result = await items_module.batch_delete_items(request=request, user_id=USER_ID, db=db)

    assert result["data"]["deleted_count"] == 1
    vector.batch_delete.assert_awaited_once_with([ITEM_ID])
    delete_multiple.assert_not_awaited()


@pytest.mark.asyncio
async def test_batch_delete_survives_storage_failure(monkeypatch):
    db = FakeDB(
        rows={
            "items": [_item_row()],
            "item_images": [_image_row(storage_path="u/items/one.jpg")],
        }
    )
    monkeypatch.setattr(
        StorageService,
        "delete_multiple_images",
        AsyncMock(side_effect=StorageServiceError("storage down")),
    )
    _patch_vector_service(monkeypatch)

    request = items_module.BatchDeleteItemsRequest(item_ids=[ITEM_ID])
    result = await items_module.batch_delete_items(request=request, user_id=USER_ID, db=db)

    assert result["data"]["deleted_count"] == 1


@pytest.mark.asyncio
async def test_batch_delete_survives_embedding_failure(monkeypatch):
    db = FakeDB(
        rows={
            "items": [_item_row()],
            "item_images": [_image_row(storage_path="u/items/one.jpg")],
        }
    )
    vector = _patch_vector_service(monkeypatch)
    vector.batch_delete = AsyncMock(side_effect=RuntimeError("vector down"))
    monkeypatch.setattr(
        StorageService, "delete_multiple_images", AsyncMock(return_value=1)
    )

    request = items_module.BatchDeleteItemsRequest(item_ids=[ITEM_ID])
    result = await items_module.batch_delete_items(request=request, user_id=USER_ID, db=db)

    assert result["data"]["deleted_count"] == 1


@pytest.mark.asyncio
async def test_batch_delete_reraises_database_errors(monkeypatch):
    monkeypatch.setattr(
        StorageService,
        "resolve_owned_storage_paths",
        AsyncMock(side_effect=DatabaseError("db down", operation="select")),
    )

    request = items_module.BatchDeleteItemsRequest(item_ids=[ITEM_ID])
    with pytest.raises(DatabaseError):
        await items_module.batch_delete_items(request=request, user_id=USER_ID, db=Mock())


@pytest.mark.asyncio
async def test_batch_delete_wraps_unexpected_errors(monkeypatch):
    monkeypatch.setattr(
        StorageService,
        "resolve_owned_storage_paths",
        AsyncMock(side_effect=RuntimeError("boom")),
    )

    request = items_module.BatchDeleteItemsRequest(item_ids=[ITEM_ID])
    with pytest.raises(DatabaseError):
        await items_module.batch_delete_items(request=request, user_id=USER_ID, db=Mock())


# ============================================================================
# GET /items/stats
# ============================================================================


@pytest.mark.asyncio
async def test_stats_survives_unparseable_prices():
    """A non-numeric price is skipped with a debug log, not fatal."""
    db = FakeDB(
        rows={
            "items": [
                {
                    "id": "1",
                    "user_id": USER_ID,
                    "name": "A",
                    "category": "tops",
                    "colors": ["Red"],
                    "condition": "good",
                    "price": "oops",
                    "usage_times_worn": 3,
                },
                {
                    "id": "2",
                    "user_id": USER_ID,
                    "name": "B",
                    "category": "bottoms",
                    "colors": [],
                    "condition": None,
                    "price": None,
                    "usage_times_worn": None,
                },
                {
                    "id": "3",
                    "user_id": USER_ID,
                    "name": "C",
                    "category": None,
                    "colors": ["blue"],
                    "condition": "dirty",
                    "price": 12.5,
                    "usage_times_worn": 0,
                },
            ]
        }
    )

    result = await items_module.get_item_stats(user_id=USER_ID, db=db)

    data = result["data"]
    assert data["total_items"] == 3
    assert data["items_by_category"] == {"tops": 1, "bottoms": 1, "other": 1}
    assert data["items_by_condition"] == {"good": 1, "clean": 1, "dirty": 1}
    assert data["items_by_color"] == {"red": 1, "blue": 1}
    assert data["total_value"] == 12.5
    assert data["most_worn_items"][0] == {"id": "1", "name": "A", "times_worn": 3}
    assert {"id": "2", "name": "B", "times_worn": 0} in data["least_worn_items"]


@pytest.mark.asyncio
async def test_stats_reraises_database_errors():
    db = Mock()
    eq_chain = db.table.return_value.select.return_value.eq.return_value
    error = DatabaseError("db down", operation="select")
    eq_chain.execute.side_effect = error
    eq_chain.limit.return_value.execute.side_effect = error
    eq_chain.order.return_value.limit.return_value.execute.side_effect = error

    with pytest.raises(DatabaseError):
        await items_module.get_item_stats(user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_stats_wraps_unexpected_errors():
    db = Mock()
    eq_chain = db.table.return_value.select.return_value.eq.return_value
    error = RuntimeError("boom")
    eq_chain.execute.side_effect = error
    eq_chain.limit.return_value.execute.side_effect = error
    eq_chain.order.return_value.limit.return_value.execute.side_effect = error

    with pytest.raises(DatabaseError):
        await items_module.get_item_stats(user_id=USER_ID, db=db)


# ============================================================================
# GET /items/by-category/{category}
# ============================================================================


@pytest.mark.asyncio
async def test_by_category_rejects_an_unknown_category():
    with pytest.raises(ValidationError):
        await items_module.get_items_by_category(category="bogus", user_id=USER_ID, db=Mock())


@pytest.mark.asyncio
async def test_by_category_reraises_database_errors():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.order.return_value.execute.side_effect = DatabaseError(
        "db down", operation="select"
    )

    with pytest.raises(DatabaseError):
        await items_module.get_items_by_category(category="tops", user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_by_category_wraps_unexpected_errors():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.order.return_value.execute.side_effect = RuntimeError(
        "boom"
    )

    with pytest.raises(DatabaseError):
        await items_module.get_items_by_category(category="tops", user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_by_category_returns_normalized_items():
    db = FakeDB(rows={"items": [_item_row(name="White tee"), _item_row(id=OTHER_ITEM_ID, name="Denim jacket", category="outerwear")]})

    result = await items_module.get_items_by_category(category="tops", user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    items = result["data"]["items"]
    assert [i["id"] for i in items] == [ITEM_ID]
    assert items[0]["images"] == []


# ============================================================================
# GET /items/search
# ============================================================================


@pytest.mark.asyncio
async def test_search_reraises_database_errors():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.or_.return_value.limit.return_value.execute.side_effect = DatabaseError(
        "db down", operation="select"
    )

    with pytest.raises(DatabaseError):
        await items_module.search_items(q="tee", limit=10, user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_search_wraps_unexpected_errors():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.or_.return_value.limit.return_value.execute.side_effect = RuntimeError(
        "boom"
    )

    with pytest.raises(DatabaseError):
        await items_module.search_items(q="tee", limit=10, user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_search_returns_normalized_items():
    db = FakeDB(
        rows={
            "items": [
                _item_row(name="White tee", brand="Nike"),
                _item_row(id=OTHER_ITEM_ID, name="Denim jacket", brand="Levi's"),
            ]
        }
    )

    result = await items_module.search_items(q="tee", limit=10, user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    items = result["data"]["items"]
    assert [i["id"] for i in items] == [ITEM_ID]
    assert items[0]["images"] == []


# ============================================================================
# POST /items/{item_id}/categorize
# ============================================================================


@pytest.mark.asyncio
async def test_categorize_item_derives_style_season_and_materials():
    db = FakeDB(
        rows={
            "items": [
                _item_row(
                    tags=["Casual", "Winter"],
                    category="outerwear",
                    sub_category="coats",
                    material="wool",
                    colors=["Black", "blue"],
                )
            ]
        }
    )

    result = await items_module.categorize_item(item_id=ITEM_ID, user_id=USER_ID, db=db)

    data = result["data"]
    assert data["style"] == "casual"
    assert data["seasonal_tags"] == ["winter"]
    assert data["materials"] == ["wool"]
    assert data["colors"] == ["black", "blue"]
    assert data["category"] == "outerwear"
    assert data["sub_category"] == "coats"
    assert data["confidence"] == 0.7
    assert db.updates[0][1]["style"] == "casual"


@pytest.mark.asyncio
async def test_categorize_item_defaults_to_all_season():
    db = FakeDB(rows={"items": [_item_row(category="tops", tags=[])]})

    result = await items_module.categorize_item(item_id=ITEM_ID, user_id=USER_ID, db=db)

    assert result["data"]["seasonal_tags"] == ["all-season"]
    assert result["data"]["style"] is None
    assert result["data"]["materials"] == []


@pytest.mark.asyncio
async def test_categorize_item_applies_summer_rules():
    db = FakeDB(
        rows={
            "items": [
                _item_row(tags=["summer", "shorts"], category="bottoms", sub_category="shorts")
            ]
        }
    )

    result = await items_module.categorize_item(item_id=ITEM_ID, user_id=USER_ID, db=db)

    assert result["data"]["seasonal_tags"] == ["summer"]


@pytest.mark.asyncio
async def test_categorize_item_accepts_a_string_materials_column():
    """A legacy row whose materials column is a single string is wrapped."""
    db = FakeDB(rows={"items": [_item_row(category="tops", materials="cotton")]})

    result = await items_module.categorize_item(item_id=ITEM_ID, user_id=USER_ID, db=db)

    assert result["data"]["materials"] == ["cotton"]


@pytest.mark.asyncio
async def test_categorize_item_raises_not_found():
    db = FakeDB(rows={"items": []})

    with pytest.raises(ItemNotFoundError):
        await items_module.categorize_item(item_id=ITEM_ID, user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_categorize_item_wraps_unexpected_errors():
    db = _error_db(RuntimeError("boom"))

    with pytest.raises(DatabaseError):
        await items_module.categorize_item(item_id=ITEM_ID, user_id=USER_ID, db=db)


# ============================================================================
# PUT /items/{item_id}/categories
# ============================================================================


@pytest.mark.asyncio
async def test_update_item_categories_normalizes_and_persists():
    db = FakeDB(rows={"items": [_item_row()]})
    request = items_module.UpdateItemCategoriesRequest(
        category="Tops",
        sub_category="Tees",
        colors=["black"],
        occasion_tags=[" Formal ", "Party"],
    )

    result = await items_module.update_item_categories(
        item_id=ITEM_ID, request=request, user_id=USER_ID, db=db
    )

    assert result["message"] == "Updated"
    payload = db.updates[0][1]
    assert payload["category"] == "tops"
    assert payload["sub_category"] == "Tees"
    assert payload["occasion_tags"] == ["formal", "party"]
    assert payload["colors"] == ["black"]


@pytest.mark.asyncio
async def test_update_item_categories_allows_explicit_nulls():
    """Explicit nulls are passed through (user clears a category field)."""
    db = FakeDB(rows={"items": [_item_row()]})
    request = items_module.UpdateItemCategoriesRequest(category=None, occasion_tags=None)

    result = await items_module.update_item_categories(
        item_id=ITEM_ID, request=request, user_id=USER_ID, db=db
    )

    assert result["message"] == "Updated"
    payload = db.updates[0][1]
    assert payload["category"] is None
    assert payload["occasion_tags"] is None


@pytest.mark.asyncio
async def test_update_item_categories_raises_not_found():
    db = FakeDB(rows={"items": []})
    request = items_module.UpdateItemCategoriesRequest()

    with pytest.raises(ItemNotFoundError):
        await items_module.update_item_categories(
            item_id=ITEM_ID, request=request, user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_update_item_categories_raises_database_error_when_update_returns_nothing():
    db = _row_then_empty_update_db({"id": ITEM_ID})
    request = items_module.UpdateItemCategoriesRequest(category="tops")

    with pytest.raises(DatabaseError):
        await items_module.update_item_categories(
            item_id=ITEM_ID, request=request, user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_update_item_categories_wraps_unexpected_errors():
    db = _error_db(RuntimeError("boom"))
    request = items_module.UpdateItemCategoriesRequest(category="tops")

    with pytest.raises(DatabaseError):
        await items_module.update_item_categories(
            item_id=ITEM_ID, request=request, user_id=USER_ID, db=db
        )


# ============================================================================
# POST /items/check-duplicates
# ============================================================================


@pytest.mark.asyncio
async def test_check_duplicates_returns_early_for_an_empty_wardrobe(monkeypatch):
    db = FakeDB(rows={"items": []})
    reserve = AsyncMock(return_value=True)
    monkeypatch.setattr(AISettingsService, "reserve_usage", reserve)
    _patch_vector_service(monkeypatch)

    result = await items_module.check_duplicates(
        request=_duplicate_request(), threshold=0.75, limit=5, user_id=USER_ID, db=db
    )

    assert result["data"]["has_duplicates"] is False
    assert result["data"]["duplicates"] == []
    assert result["message"] == "No duplicates found"
    reserve.assert_not_awaited()


@pytest.mark.asyncio
async def test_check_duplicates_falls_back_to_text_when_quota_exhausted(monkeypatch):
    db = FakeDB(
        rows={
            "items": [
                _item_row(
                    name="Blue Blazer",
                    brand="Zara",
                    colors=["blue"],
                    item_images=[
                        {
                            "image_url": "https://cdn/1.jpg",
                            "thumbnail_url": "https://cdn/1-t.jpg",
                            "is_primary": True,
                        }
                    ],
                )
            ]
        }
    )
    _patch_embedding(monkeypatch, reserved=False)

    result = await items_module.check_duplicates(
        request=_duplicate_request(), threshold=0.75, limit=5, user_id=USER_ID, db=db
    )

    assert result["message"] == "Fallback text-based duplicate check"
    assert result["data"]["has_duplicates"] is True
    dup = result["data"]["duplicates"][0]
    assert dup["id"] == ITEM_ID
    assert dup["similarity_score"] == 0.9
    assert dup["image_url"] == "https://cdn/1.jpg"
    assert "Very high similarity" in dup["reasons"]


@pytest.mark.asyncio
async def test_check_duplicates_fallback_drops_below_threshold_matches(monkeypatch):
    """A name-matching row whose other attributes score below the threshold is
    not reported (the score >= threshold branch's false side)."""
    db = FakeDB(
        rows={
            "items": [
                _item_row(name="Blue Blazer"),  # matches the name query, nothing else
            ]
        }
    )
    _patch_embedding(monkeypatch, reserved=False)

    result = await items_module.check_duplicates(
        request=_duplicate_request(), threshold=0.75, limit=5, user_id=USER_ID, db=db
    )

    assert result["message"] == "Fallback text-based duplicate check"
    assert result["data"]["has_duplicates"] is False
    assert result["data"]["duplicates"] == []


@pytest.mark.asyncio
async def test_check_duplicates_falls_back_when_embedding_generation_fails(monkeypatch):
    db = FakeDB(
        rows={
            "items": [
                _item_row(name="Blue Blazer", brand="Zara", colors=["blue"]),
            ]
        }
    )
    reserve, generate, release = _patch_embedding(
        monkeypatch, embedding_error=RuntimeError("provider down")
    )

    result = await items_module.check_duplicates(
        request=_duplicate_request(), threshold=0.75, limit=5, user_id=USER_ID, db=db
    )

    assert result["message"] == "Fallback text-based duplicate check"
    assert result["data"]["has_duplicates"] is True
    release.assert_awaited_once()


@pytest.mark.asyncio
async def test_check_duplicates_reports_no_matches_when_vector_search_is_empty(monkeypatch):
    db = FakeDB(rows={"items": [_item_row()]})
    _patch_embedding(monkeypatch)
    vector = _patch_vector_service(monkeypatch)
    vector.find_similar.return_value = []

    result = await items_module.check_duplicates(
        request=_duplicate_request(), threshold=0.75, limit=5, user_id=USER_ID, db=db
    )

    assert result["data"]["has_duplicates"] is False
    assert result["message"] == "No duplicates found"


@pytest.mark.asyncio
async def test_check_duplicates_builds_duplicate_list_from_vector_matches(monkeypatch):
    db = FakeDB(
        rows={
            "items": [
                _item_row(
                    name="Blue Blazer",
                    brand="Zara",
                    colors=["blue"],
                    item_images=[
                        {
                            "image_url": "https://cdn/1.jpg",
                            "thumbnail_url": "https://cdn/1-t.jpg",
                            "is_primary": False,
                        }
                    ],
                )
            ]
        }
    )
    _patch_embedding(monkeypatch)
    vector = _patch_vector_service(monkeypatch)
    vector.find_similar.return_value = [{"item_id": ITEM_ID, "score": 0.92}]

    result = await items_module.check_duplicates(
        request=_duplicate_request(), threshold=0.75, limit=5, user_id=USER_ID, db=db
    )

    assert result["message"] == "Found 1 potential duplicate(s)"
    dup = result["data"]["duplicates"][0]
    assert dup["id"] == ITEM_ID
    assert dup["similarity_score"] == 0.92
    # No is_primary image -> falls back to the first image.
    assert dup["image_url"] == "https://cdn/1.jpg"
    assert dup["reasons"]
    assert result["data"]["threshold"] == 0.75


@pytest.mark.asyncio
async def test_check_duplicates_skips_matches_without_fetched_rows(monkeypatch):
    """A vector match whose item row cannot be fetched is skipped (the loop's
    `continue` branch). The wardrobe must be non-empty, or the handler returns
    before the match loop ever runs."""
    db = FakeDB(rows={"items": [_item_row()]})
    _patch_embedding(monkeypatch)
    vector = _patch_vector_service(monkeypatch)
    vector.find_similar.return_value = [{"item_id": "ghost-id", "score": 0.8}]

    result = await items_module.check_duplicates(
        request=_duplicate_request(), threshold=0.75, limit=5, user_id=USER_ID, db=db
    )

    assert result["data"]["has_duplicates"] is False
    assert result["message"] == "No duplicates found"


@pytest.mark.asyncio
async def test_check_duplicates_reraises_ai_service_errors(monkeypatch):
    db = FakeDB(rows={"items": [_item_row()]})
    _patch_embedding(monkeypatch)
    vector = _patch_vector_service(monkeypatch)
    vector.find_similar.side_effect = AIServiceError("ai down")

    with pytest.raises(AIServiceError):
        await items_module.check_duplicates(
            request=_duplicate_request(), threshold=0.75, limit=5, user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_check_duplicates_wraps_unexpected_errors(monkeypatch):
    db = FakeDB(rows={"items": [_item_row()]})
    _patch_embedding(monkeypatch)
    vector = _patch_vector_service(monkeypatch)
    vector.find_similar.side_effect = RuntimeError("boom")

    with pytest.raises(DatabaseError):
        await items_module.check_duplicates(
            request=_duplicate_request(), threshold=0.75, limit=5, user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_check_duplicates_falls_back_to_row_count_when_count_missing(monkeypatch):
    """A result without a count attribute uses the fetched row length."""
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.limit.return_value.execute.return_value = SimpleNamespace(
        data=[{"id": ITEM_ID}], count=None
    )
    reserve, generate, release = _patch_embedding(monkeypatch)
    vector = _patch_vector_service(monkeypatch)
    vector.find_similar.return_value = []

    result = await items_module.check_duplicates(
        request=_duplicate_request(), threshold=0.75, limit=5, user_id=USER_ID, db=db
    )

    assert result["message"] == "No duplicates found"
    reserve.assert_awaited_once()
    generate.assert_awaited_once()


# ============================================================================
# GET /items/{item_id}/similar
# ============================================================================


@pytest.mark.asyncio
async def test_find_similar_raises_not_found():
    db = FakeDB(rows={"items": []})

    with pytest.raises(ItemNotFoundError):
        await items_module.find_similar_items(item_id=ITEM_ID, limit=5, min_score=0.6, user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_find_similar_raises_rate_limit_when_quota_exhausted(monkeypatch):
    db = FakeDB(rows={"items": [_item_row()]})
    _patch_embedding(monkeypatch, reserved=False)

    with pytest.raises(RateLimitError):
        await items_module.find_similar_items(item_id=ITEM_ID, limit=5, min_score=0.6, user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_find_similar_returns_unavailable_when_embedding_fails(monkeypatch):
    db = FakeDB(rows={"items": [_item_row()]})
    reserve, generate, release = _patch_embedding(
        monkeypatch, embedding_error=RuntimeError("provider down")
    )

    result = await items_module.find_similar_items(
        item_id=ITEM_ID, limit=5, min_score=0.6, user_id=USER_ID, db=db
    )

    assert result["data"] == {"items": [], "source_item_id": ITEM_ID}
    assert result["message"] == "Similarity search unavailable - AI service error"
    release.assert_awaited_once()


@pytest.mark.asyncio
async def test_find_similar_reports_no_matches(monkeypatch):
    db = FakeDB(rows={"items": [_item_row()]})
    _patch_embedding(monkeypatch)
    vector = _patch_vector_service(monkeypatch)
    vector.find_similar.return_value = []

    result = await items_module.find_similar_items(
        item_id=ITEM_ID, limit=5, min_score=0.6, user_id=USER_ID, db=db
    )

    assert result["message"] == "No similar items found"
    assert result["data"]["items"] == []


@pytest.mark.asyncio
async def test_find_similar_returns_scored_items(monkeypatch):
    db = FakeDB(rows={"items": [_item_row(), _item_row(id=OTHER_ITEM_ID, name="Blue tee")]})
    _patch_embedding(monkeypatch)
    vector = _patch_vector_service(monkeypatch)
    vector.find_similar.return_value = [{"item_id": OTHER_ITEM_ID, "score": 0.88}]

    result = await items_module.find_similar_items(
        item_id=ITEM_ID, limit=5, min_score=0.6, user_id=USER_ID, db=db
    )

    assert result["message"] == "Found 1 similar item(s)"
    assert result["data"]["source_item_id"] == ITEM_ID
    assert result["data"]["items"][0]["id"] == OTHER_ITEM_ID
    assert result["data"]["items"][0]["similarity_score"] == 0.88


@pytest.mark.asyncio
async def test_find_similar_skips_matches_without_rows(monkeypatch):
    db = FakeDB(rows={"items": [_item_row()]})
    _patch_embedding(monkeypatch)
    vector = _patch_vector_service(monkeypatch)
    vector.find_similar.return_value = [{"item_id": "ghost-id", "score": 0.9}]

    result = await items_module.find_similar_items(
        item_id=ITEM_ID, limit=5, min_score=0.6, user_id=USER_ID, db=db
    )

    assert result["message"] == "Found 0 similar item(s)"
    assert result["data"]["items"] == []


@pytest.mark.asyncio
async def test_find_similar_wraps_unexpected_errors(monkeypatch):
    db = FakeDB(rows={"items": [_item_row()]})
    monkeypatch.setattr(
        AISettingsService, "reserve_usage", AsyncMock(side_effect=RuntimeError("boom"))
    )

    with pytest.raises(DatabaseError):
        await items_module.find_similar_items(item_id=ITEM_ID, limit=5, min_score=0.6, user_id=USER_ID, db=db)


# ============================================================================
# _fallback_duplicate_check
# ============================================================================


@pytest.mark.asyncio
async def test_fallback_duplicate_check_returns_unavailable_on_error():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.ilike.return_value.limit.return_value.execute.side_effect = RuntimeError(
        "boom"
    )

    result = await items_module._fallback_duplicate_check(
        db, USER_ID, _duplicate_request(), 0.75, 5
    )

    assert result["data"]["has_duplicates"] is False
    assert result["message"] == "Duplicate check unavailable"


# ============================================================================
# Private helpers
# ============================================================================


@pytest.mark.asyncio
async def test_release_embedding_reservation_skips_a_stale_reservation_day(monkeypatch):
    release = AsyncMock()
    monkeypatch.setattr(AISettingsService, "release_usage", release)

    await items_module._release_embedding_reservation(
        USER_ID, Mock(), reserved_on=date(2020, 1, 1)
    )

    release.assert_not_awaited()


@pytest.mark.asyncio
async def test_release_embedding_reservation_swallows_release_failures(monkeypatch):
    release = AsyncMock(side_effect=RuntimeError("rpc down"))
    monkeypatch.setattr(AISettingsService, "release_usage", release)

    # Must not raise: a failed release must not mask the original outcome.
    await items_module._release_embedding_reservation(USER_ID, Mock(), reserved_on=None)

    release.assert_awaited_once()


def test_normalize_item_images_passes_non_dicts_through():
    assert items_module._normalize_item_images("not-a-dict") == "not-a-dict"
    assert items_module._normalize_item_images(None) is None


def test_normalize_item_images_falls_back_to_the_images_key():
    item = {"id": "i1", "images": [{"image_url": "https://cdn/1.jpg"}]}
    normalized = items_module._normalize_item_images(item)
    assert normalized["images"] == [{"image_url": "https://cdn/1.jpg"}]

    bare = {"id": "i2"}
    assert items_module._normalize_item_images(bare)["images"] == []


def test_calculate_text_similarity_scores_a_full_match():
    request = _duplicate_request(
        name="Blue Blazer", sub_category="jackets", colors=["blue", "black"]
    )
    item = {
        "name": "Blue Blazer",
        "category": "tops",
        "sub_category": "jackets",
        "colors": ["blue", "black"],
        "brand": "Zara",
    }
    assert items_module._calculate_text_similarity(request, item) == 1.0


def test_calculate_text_similarity_scores_a_partial_match():
    request = _duplicate_request(name="tee", colors=["red"])
    item = {
        "name": "white tee",
        "category": "tops",
        "sub_category": None,
        "colors": ["red", "blue"],
        "brand": None,
    }
    # 0.3 name substring + 0.2 category + 0.075 color overlap (1/2).
    assert items_module._calculate_text_similarity(request, item) == pytest.approx(0.575)


def test_calculate_text_similarity_scores_zero_for_unrelated_items():
    request = _duplicate_request(name="Blazer", colors=[])
    item = {
        "name": "Shirt",
        "category": "bottoms",
        "sub_category": None,
        "colors": [],
        "brand": None,
    }
    assert items_module._calculate_text_similarity(request, item) == 0.0


def test_generate_duplicate_reasons_lists_every_match():
    request = _duplicate_request(
        name="Blue Blazer", sub_category="jackets", colors=["blue", "black"]
    )
    item = {
        "name": "Blue Blazer",
        "category": "tops",
        "sub_category": "jackets",
        "colors": ["blue", "black"],
        "brand": "Zara",
    }
    reasons = items_module._generate_duplicate_reasons(request, item, 0.9)

    assert reasons[0] == "Very high similarity"
    assert "Exact name match" in reasons
    assert "Same category (tops)" in reasons
    assert "Same sub-category (jackets)" in reasons
    assert any("Matching colors" in r for r in reasons)
    assert "Same brand (Zara)" in reasons


def test_generate_duplicate_reasons_marks_high_similarity():
    request = _duplicate_request(name="tee")
    item = {"name": "white tee", "category": "tops", "sub_category": None, "colors": [], "brand": None}
    reasons = items_module._generate_duplicate_reasons(request, item, 0.85)

    assert reasons[0] == "High similarity"
    assert "Similar name" in reasons


def test_generate_duplicate_reasons_returns_empty_for_no_matches():
    request = _duplicate_request(name="Blazer")
    item = {"name": "Shirt", "category": "bottoms", "sub_category": None, "colors": [], "brand": None}
    assert items_module._generate_duplicate_reasons(request, item, 0.1) == []
# ============================================================================
# Rollback / ilike-escaping regressions (A2-04, A2-19)
# ============================================================================


@pytest.mark.asyncio
async def test_create_item_rolls_back_promoted_images_when_image_insert_fails(monkeypatch):
    """A failure AFTER promotion (here: the image-row batch insert) must roll
    back the item row AND the objects this attempt promoted, so a client
    retry cannot duplicate the item while partial state is left behind."""
    db = FakeDB(rows={"items": []})
    promoted = []
    deleted = []

    async def fake_promote(*, db, user_id, temp_storage_path, filename_hint="generated.png", source_content=None):
        promoted.append(temp_storage_path)
        return {
            "image_url": "https://cdn/p.jpg",
            "thumbnail_url": "https://cdn/p-t.jpg",
            "storage_path": "u1/items/p.jpg",
        }

    async def fake_delete_image(*, db, storage_path, bucket=None):
        deleted.append(storage_path)
        return True

    monkeypatch.setattr(StorageService, "promote_temp_image_to_item", staticmethod(fake_promote))
    monkeypatch.setattr(StorageService, "delete_image", staticmethod(fake_delete_image))

    real = items_module.execute_with_reconnect
    state = {"calls": 0}

    async def flaky(callable_, db_, **kwargs):
        state["calls"] += 1
        if state["calls"] == 2:  # item insert OK, image batch insert fails
            raise RuntimeError("image insert boom")
        return await real(callable_, db_, **kwargs)

    monkeypatch.setattr(items_module, "execute_with_reconnect", flaky)

    item = ItemCreate(
        name="Tee",
        category="tops",
        images=[
            ItemImageBase(
                image_url="",
                storage_path=f"users/{USER_ID}/tmp/photoshoot/{'a' * 32}.png",
                is_primary=True,
            )
        ],
    )
    with pytest.raises(DatabaseError):
        await items_module.create_item(item=item, user_id=USER_ID, db=db)

    # The item row was deleted...
    assert ("items", None) in db.deletes
    # ...and every object THIS attempt promoted was deleted best-effort.
    assert promoted == [f"users/{USER_ID}/tmp/photoshoot/{'a' * 32}.png"]
    assert deleted == ["u1/items/p.jpg"]


@pytest.mark.asyncio
async def test_search_items_escapes_ilike_wildcards():
    """A search term containing %/_ must match literally: the escape helper
    runs before the term is wrapped in %...% at the search site (A2-19)."""
    calls = []

    class _Builder:
        def select(self, cols):
            calls.append(("select", cols))
            return self

        def eq(self, col, val):
            calls.append(("eq", col, val))
            return self

        def or_(self, expr):
            calls.append(("or", expr))
            return self

        def limit(self, n):
            calls.append(("limit", n))
            return self

        def execute(self):
            return SimpleNamespace(data=[])

    db = Mock()
    db.table.return_value = _Builder()

    result = await items_module.search_items(q="50% off_", user_id=USER_ID, db=db)

    assert result["data"]["items"] == []
    or_expr = next(c for c in calls if c[0] == "or")[1]
    assert "%50\% off\_%" in or_expr
    assert or_expr.startswith("name.ilike.")


@pytest.mark.asyncio
async def test_list_items_escapes_ilike_wildcards(monkeypatch):
    """The list-items search filter escapes the term's own %/_ before the
    or_() pattern is built."""
    seen = []
    real = items_module.escape_ilike_literal

    def spy(value):
        seen.append(value)
        return real(value)

    monkeypatch.setattr(items_module, "escape_ilike_literal", spy)
    db = FakeDB(rows={"items": []})

    # Pass every filter kwarg explicitly: the route's Query(...) defaults are
    # objects, not None, when the handler is called directly.
    result = await items_module.list_items(
        page=1,
        page_size=20,
        category=None,
        color=None,
        occasion=None,
        condition=None,
        brand=None,
        search="50% off",
        is_favorite=None,
        user_id=USER_ID,
        db=db,
    )

    assert result["data"]["items"] == []
    assert "50% off" in seen
    or_filters = [f for f in db.filters if f[1] == "or"]
    assert any("%50\% off%" in f[3] for f in or_filters)


@pytest.mark.asyncio
async def test_check_duplicates_fallback_escapes_ilike_wildcards(monkeypatch):
    """The text fallback duplicate check escapes the name's %/_ so a name
    containing them is not widened into a wildcard pattern."""
    seen = []
    real = items_module.escape_ilike_literal

    def spy(value):
        seen.append(value)
        return real(value)

    monkeypatch.setattr(items_module, "escape_ilike_literal", spy)
    _patch_embedding(monkeypatch, reserved=False)
    # A non-empty wardrobe so the early empty-wardrobe return is not taken.
    db = FakeDB(rows={"items": [_item_row(name="Something else")]})

    result = await items_module.check_duplicates(
        request=_duplicate_request(name="50% tee"),
        threshold=0.75,
        limit=5,
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Fallback text-based duplicate check"
    assert "50% tee" in seen
    ilike_filters = [f for f in db.filters if f[1] == "ilike"]
    assert any("%50\% tee%" in f[3] for f in ilike_filters)
