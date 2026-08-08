"""
Route-level coverage tests for app/api/v1/outfits.py.

Follows the house convention of calling route functions directly with the
in-memory :class:`tests.utils.fake_db.FakeDB` (no TestClient, no network):
auth is asserted at the dependency level, request envelopes are asserted on
``result["data"]`` / ``result["message"]``, and service calls are patched
with ``AsyncMock``.

This file exists to lift line+branch coverage of ``outfits.py`` toward the
suite's 90% gate: it exercises every handler (CRUD, collections, share,
favorites/wear/duplicate, generation tracking, image upload/delete, stats,
batch delete, recently-worn, weather suggestions), the shared helpers, and
the error branches that re-raise custom exceptions or degrade to
``DatabaseError``.

Local fake notes
----------------
``outfits.py`` uses three postgrest features the shared FakeDB does not
model, so a tiny local subclass adds them without touching ``tests/utils``:

* ``contains`` (for ``jsonb_contains`` on the ``tags`` filter);
* ``not_.is_`` (``recently_worn``);
* ``maybe_single`` returning a response object with ``data=None`` on zero
  rows so BOTH branches of ``add_collection_outfit``'s
  ``if not membership.data`` are reachable (the shared fake mirrors real
  postgrest-py, which returns a bare ``None`` there - see the app-bug note
  in ``test_add_collection_outfit_upserts_a_new_member``).
"""

import inspect
from types import SimpleNamespace
from typing import Any, Dict, List, Optional
from unittest.mock import AsyncMock, patch
from uuid import UUID

import pytest

from app.api.v1 import outfits as outfits_module
from app.api.v1.deps import get_active_user_id
from app.core.exceptions import (
    CollectionNotFoundError,
    DatabaseError,
    ImageNotFoundError,
    ItemNotFoundError,
    NotFoundError,
    OutfitNotFoundError,
    SharedOutfitNotFoundError,
    UnsupportedMediaTypeError,
    ValidationError,
)
from app.models.outfit import (
    GenerationRequest,
    OutfitCollectionCreate,
    OutfitCollectionUpdate,
    OutfitCreate,
    OutfitUpdate,
)
from app.services.storage_service import StorageService
from tests.utils.fake_db import FakeBuilder, FakeDB

USER_ID = "11111111-1111-1111-1111-111111111111"
ITEM_ID = "22222222-2222-2222-2222-222222222222"
ITEM_ID_2 = "33333333-3333-3333-3333-333333333333"
OUTFIT_ID = "44444444-4444-4444-4444-444444444444"
OUTFIT_ID_2 = "55555555-5555-5555-5555-555555555555"
OUTFIT_ID_3 = "66666666-6666-6666-6666-666666666666"
COLLECTION_ID = "77777777-7777-7777-7777-777777777777"
COLLECTION_ID_2 = "88888888-8888-8888-8888-888888888888"
IMAGE_ID = "99999999-9999-9999-9999-999999999999"
GENERATION_ID = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
NOW = "2026-01-01T00:00:00"


# ---------------------------------------------------------------------------
# Local fake extras
# ---------------------------------------------------------------------------


class _OutfitsFakeBuilder(FakeBuilder):
    """FakeBuilder whose ``not_`` is a property.

    postgrest-py exposes ``.not_`` as a property chaining into a negation
    builder; the shared FakeDB models it as a method, so routes chaining
    ``.not_.is_(...)`` (recently_worn) need this subclass (same approach as
    ``test_recommendations_routes_coverage.py``).
    """

    @property
    def not_(self):  # noqa: A003 - mirrors the real client attribute name
        return self._not


class _OutfitsFakeDB(FakeDB):
    """FakeDB plus the postgrest features outfits.py needs (see module doc)."""

    def table(self, name):
        builder = _OutfitsFakeBuilder(self, name)

        if not hasattr(builder, "contains"):

            def _contains(column, value):
                builder._add_filter("contains", column, value)
                return builder

            builder.contains = _contains

        not_builder = builder.not_
        if not hasattr(not_builder, "is_"):

            def _is_(column, value):
                not_builder._builder._add_filter("is", column, value)
                return not_builder._builder

            not_builder.is_ = _is_

        def _maybe_single():
            builder._single = True
            builder._bare_none = False
            return builder

        builder.maybe_single = _maybe_single

        # PostgREST's `return=representation` updates echo the merged rows
        # back AND the change is committed; the shared fake persists the
        # merged rows itself (update execute replaces matched rows), so a
        # read-after-update handler sees the new state without extra work
        # here. (A wrapper doing row.clear() + row.update() on top would be
        # self-referential: the persisted row IS the merged dict.)
        return builder


class _EmptyWriteDB(_OutfitsFakeDB):
    """Make every insert/update to one table return no rows.

    Exercises the ``if not row: raise DatabaseError`` guards the shared fake
    can never trigger (its writes always echo the payload back).
    """

    def __init__(self, empty_table: str, rows: Optional[Dict[str, List[Dict[str, Any]]]] = None):
        super().__init__(rows)
        self._empty_table = empty_table

    def table(self, name):
        builder = super().table(name)
        if name == self._empty_table:
            orig_execute = builder.execute

            def _execute():
                result = orig_execute()
                if builder._mode in ("insert", "update") and result.data:
                    return SimpleNamespace(data=[], count=0)
                return result

            builder.execute = _execute
        return builder


class _RawMembersDB(_OutfitsFakeDB):
    """``outfit_collection_items`` selects bypass filtering.

    The shared fake applies the ``in_`` filter, which would drop the
    empty-``collection_id`` row that exercises the ``if not cid: continue``
    guard in ``list_collections``.
    """

    def table(self, name):
        builder = super().table(name)
        if name == "outfit_collection_items":
            def _execute():
                return SimpleNamespace(data=list(self.rows.get("outfit_collection_items", [])))

            builder.execute = _execute
        return builder


class _NoCountAttrDB(_OutfitsFakeDB):
    """The ``count="exact"`` query result carries no ``.count`` attribute.

    Forces the ``getattr(count_res, "count", len(count_res.data or []))``
    fallback in ``list_outfits`` (FakeResult always has ``count``).
    """

    def table(self, name):
        builder = super().table(name)
        orig_select = builder.select
        state = {"count_exact": False}

        def _select(*args, **kwargs):
            state["count_exact"] = kwargs.get("count") == "exact"
            return orig_select(*args, **kwargs)

        orig_execute = builder.execute

        def _execute():
            result = orig_execute()
            if state["count_exact"]:
                return SimpleNamespace(data=result.data)
            return result

        builder.select = _select
        builder.execute = _execute
        return builder


class _RefetchEmptyDB(_OutfitsFakeDB):
    """``outfit_collections`` selects of ``"*"`` return no rows.

    Exercises the ``if not row: raise DatabaseError`` guard after a
    successful ownership check (which selects only ``id``).
    """

    def table(self, name):
        builder = super().table(name)
        if name == "outfit_collections":
            orig_select = builder.select
            orig_execute = builder.execute
            state = {"columns": None}

            def _select(*args, **kwargs):
                state["columns"] = args[0] if args else None
                return orig_select(*args, **kwargs)

            def _execute():
                result = orig_execute()
                if state["columns"] == "*" and result.data:
                    return SimpleNamespace(data=None, count=0)
                return result

            builder.select = _select
            builder.execute = _execute
        return builder


class _RaisingDB(_OutfitsFakeDB):
    """FakeDB whose ``table(name)`` raises for one table (generic 500 path)."""

    def __init__(self, raise_table: str, rows: Optional[Dict[str, List[Dict[str, Any]]]] = None):
        super().__init__(rows)
        self._raise_table = raise_table

    def table(self, name):
        if name == self._raise_table:
            raise RuntimeError("supabase down")
        return super().table(name)


class _FakeUpload:
    def __init__(self, data: bytes = b"png-bytes", filename: str = "outfit.png", content_type: str = "image/png"):
        self._data = data
        self.filename = filename
        self.content_type = content_type

    async def read(self, size: int = -1) -> bytes:
        if size is None or size < 0:
            out, self._data = self._data, b""
            return out
        out, self._data = self._data[:size], self._data[size:]
        return out


@pytest.fixture(autouse=True)
def _presign(monkeypatch):
    """Keep the read-path URL materialization off the network."""

    async def _fake(storage_path, bucket=None):
        return f"https://presigned.example/{storage_path}"

    monkeypatch.setattr(StorageService, "get_public_url", staticmethod(_fake))


# ---------------------------------------------------------------------------
# Row factories
# ---------------------------------------------------------------------------


def _item_row(item_id: str = ITEM_ID, **overrides: Any) -> Dict[str, Any]:
    row: Dict[str, Any] = {
        "id": item_id,
        "user_id": USER_ID,
        "name": "Linen shirt",
        "category": "tops",
        "colors": ["white"],
        "is_deleted": False,
        "item_images": [],
    }
    row.update(overrides)
    return row


def _outfit_row(outfit_id: str = OUTFIT_ID, **overrides: Any) -> Dict[str, Any]:
    row: Dict[str, Any] = {
        "id": outfit_id,
        "user_id": USER_ID,
        "name": "Weekend Casual",
        "description": "desc",
        "item_ids": [ITEM_ID],
        "style": "casual",
        "season": "summer",
        "occasion": "weekend",
        "tags": ["work"],
        "is_favorite": False,
        "is_draft": False,
        "is_public": False,
        "worn_count": 0,
        "last_worn_at": None,
        "created_at": NOW,
        "updated_at": NOW,
        "outfit_images": [],
    }
    row.update(overrides)
    return row


def _collection_row(collection_id: str = COLLECTION_ID, **overrides: Any) -> Dict[str, Any]:
    row: Dict[str, Any] = {
        "id": collection_id,
        "user_id": USER_ID,
        "name": "Work",
        "description": None,
        "is_favorite": False,
        "created_at": NOW,
        "updated_at": NOW,
    }
    row.update(overrides)
    return row


# ---------------------------------------------------------------------------
# Auth gate: every route depends on get_active_user_id (public ones excluded)
# ---------------------------------------------------------------------------

_AUTH_HANDLERS = [
    "create_outfit",
    "list_outfits",
    "available_items",
    "get_outfit",
    "update_outfit",
    "share_outfit",
    "delete_outfit",
    "create_collection",
    "list_collections",
    "update_collection",
    "replace_collection_outfits",
    "add_collection_outfit",
    "remove_collection_outfit",
    "delete_collection",
    "toggle_favorite",
    "mark_worn",
    "get_wear_history",
    "duplicate_outfit",
    "add_item_to_outfit",
    "remove_item_from_outfit",
    "start_generation",
    "get_generation_status",
    "upload_outfit_image",
    "delete_outfit_image",
    "get_outfit_stats",
    "batch_delete_outfits",
    "recently_worn",
    "favorites",
    "weather_suggestions",
]


@pytest.mark.parametrize("handler_name", _AUTH_HANDLERS)
def test_every_outfit_route_requires_authentication(handler_name):
    """Direct-call tests bypass auth, so assert the gate at the dependency."""
    param = inspect.signature(getattr(outfits_module, handler_name)).parameters["user_id"]
    assert param.default.dependency is get_active_user_id


# ---------------------------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------------------------


def test_normalize_item_images_handles_all_shapes():
    assert outfits_module._normalize_item_images("not-a-dict") == "not-a-dict"
    assert outfits_module._normalize_item_images({"id": "i", "item_images": [1]})["images"] == [1]
    assert outfits_module._normalize_item_images({"id": "i", "item_images": None, "images": [2]})["images"] == [2]
    assert outfits_module._normalize_item_images({"id": "i"})["images"] == []


def test_normalize_outfit_images_handles_all_shapes():
    assert outfits_module._normalize_outfit_images("not-a-dict") == "not-a-dict"
    assert outfits_module._normalize_outfit_images({"id": "o", "outfit_images": [1]})["images"] == [1]
    assert outfits_module._normalize_outfit_images({"id": "o", "images": [2]})["images"] == [2]
    assert outfits_module._normalize_outfit_images({"id": "o"})["images"] == []


def test_collection_counts_with_no_ids_is_empty():
    assert outfits_module._collection_counts(_OutfitsFakeDB(), []) == {}


def test_collection_counts_skips_rows_without_an_id():
    class _RawQuery:
        def __init__(self, rows):
            self._rows = rows

        def select(self, *_a, **_k):
            return self

        def in_(self, *_a, **_k):
            return self

        def execute(self):
            return SimpleNamespace(data=self._rows)

    class _RawDb:
        def __init__(self, rows):
            self._rows = rows

        def table(self, _name):
            return _RawQuery(self._rows)

    db = _RawDb(
        [
            {"collection_id": COLLECTION_ID},
            {"collection_id": COLLECTION_ID},
            {"collection_id": ""},
            {"collection_id": None},
        ]
    )

    assert outfits_module._collection_counts(db, [COLLECTION_ID, "zz"]) == {COLLECTION_ID: 2}


def test_now_returns_an_iso_string():
    assert isinstance(outfits_module._now(), str)


# ---------------------------------------------------------------------------
# CRUD
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_create_outfit_persists_and_returns_the_row():
    db = _OutfitsFakeDB({"items": [_item_row()]})

    result = await outfits_module.create_outfit(
        OutfitCreate(name="Weekend", item_ids=[UUID(ITEM_ID)]),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Created"
    assert result["data"]["name"] == "Weekend"
    assert result["data"]["item_ids"] == [ITEM_ID]
    assert result["data"]["images"] == []
    assert result["data"]["worn_count"] == 0
    assert db.rows["outfits"][0]["user_id"] == USER_ID


@pytest.mark.asyncio
async def test_create_outfit_rejects_unknown_items():
    db = _OutfitsFakeDB({"items": [_item_row()]})

    with pytest.raises(ValidationError) as exc:
        await outfits_module.create_outfit(
            OutfitCreate(name="Weekend", item_ids=[UUID(ITEM_ID), UUID(ITEM_ID_2)]),
            user_id=USER_ID,
            db=db,
        )
    assert exc.value.details["missing_item_ids"] == [ITEM_ID_2]


@pytest.mark.asyncio
async def test_create_outfit_raises_database_error_when_insert_returns_nothing():
    db = _EmptyWriteDB("outfits", {"items": [_item_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.create_outfit(
            OutfitCreate(name="Weekend", item_ids=[UUID(ITEM_ID)]),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_create_outfit_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("items", {"items": [_item_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.create_outfit(
            OutfitCreate(name="Weekend", item_ids=[UUID(ITEM_ID)]),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_list_outfits_applies_filters_and_attaches_items():
    db = _OutfitsFakeDB(
        {
            "items": [
                _item_row(ITEM_ID, item_images=[{"image_url": "https://cdn/1.jpg", "thumbnail_url": None}]),
            ],
            "outfits": [
                _outfit_row(OUTFIT_ID, name="Denim Day", style="casual", is_favorite=True, tags=["work"]),
                _outfit_row(OUTFIT_ID_2, name="Evening", style="formal", is_favorite=True, tags=["work"]),
                _outfit_row(OUTFIT_ID_3, name="Third", style="streetwear", season="fall", is_favorite=False, tags=[]),
            ],
        }
    )

    result = await outfits_module.list_outfits(
        page=1,
        page_size=2,
        is_favorite=None,
        style=None,
        season=None,
        styles="casual,formal",
        seasons="summer",
        favorites_only=True,
        drafts_only=False,
        search="denim",
        tags="work",
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "OK"
    assert result["data"]["total"] == 1
    assert [o["name"] for o in result["data"]["outfits"]] == ["Denim Day"]
    outfit = result["data"]["outfits"][0]
    assert outfit["items"][0]["id"] == ITEM_ID
    assert outfit["items"][0]["item_images"][0]["url"] == "https://cdn/1.jpg"
    assert result["data"]["page"] == 1
    assert result["data"]["total_pages"] == 1
    assert result["data"]["has_next"] is False
    assert result["data"]["has_prev"] is False


@pytest.mark.asyncio
async def test_list_outfits_paginates_and_reports_next_and_prev():
    db = _OutfitsFakeDB(
        {
            "items": [
                _item_row(ITEM_ID, item_images=[{"image_url": "https://cdn/1.jpg"}]),
                _item_row(ITEM_ID_2, item_images=[{"image_url": None, "thumbnail_url": None}]),
            ],
            "outfits": [
                _outfit_row(OUTFIT_ID, name="One"),
                _outfit_row(OUTFIT_ID_2, name="Two", item_ids=[ITEM_ID, ITEM_ID_2]),
                _outfit_row(OUTFIT_ID_3, name="Three"),
            ],
        }
    )

    first = await outfits_module.list_outfits(
        page=1,
        page_size=2,
        is_favorite=None,
        style=None,
        season=None,
        styles=None,
        seasons=None,
        favorites_only=None,
        drafts_only=None,
        search=None,
        tags=None,
        user_id=USER_ID,
        db=db,
    )
    assert first["data"]["total"] == 3
    assert [o["name"] for o in first["data"]["outfits"]] == ["One", "Two"]
    assert first["data"]["total_pages"] == 2
    assert first["data"]["has_next"] is True
    assert first["data"]["has_prev"] is False

    # Both referenced items are fetched in one batch and their Flutter-compat
    # `url` field is filled (empty image dict degrades to "").
    items = first["data"]["outfits"][1]["items"]
    assert {i["id"]: i["item_images"][0]["url"] for i in items} == {
        ITEM_ID: "https://cdn/1.jpg",
        ITEM_ID_2: "",
    }

    second = await outfits_module.list_outfits(
        page=2,
        page_size=2,
        is_favorite=None,
        style=None,
        season=None,
        styles=None,
        seasons=None,
        favorites_only=None,
        drafts_only=None,
        search=None,
        tags=None,
        user_id=USER_ID,
        db=db,
    )
    assert [o["name"] for o in second["data"]["outfits"]] == ["Three"]
    assert second["data"]["has_next"] is False
    assert second["data"]["has_prev"] is True


@pytest.mark.asyncio
async def test_list_outfits_falls_back_to_row_count_when_count_missing():
    """A count response without a ``.count`` attribute (some postgrest
    versions) degrades to len(data) instead of crashing."""
    db = _NoCountAttrDB(
        {
            "outfits": [_outfit_row(OUTFIT_ID, name="One"), _outfit_row(OUTFIT_ID_2, name="Two")],
        }
    )

    result = await outfits_module.list_outfits(
        page=1,
        page_size=20,
        is_favorite=None,
        style=None,
        season=None,
        styles=None,
        seasons=None,
        favorites_only=None,
        drafts_only=None,
        search=None,
        tags=None,
        user_id=USER_ID,
        db=db,
    )

    assert result["data"]["total"] == 2
    assert len(result["data"]["outfits"]) == 2


@pytest.mark.asyncio
async def test_list_outfits_without_item_ids_skips_the_items_batch():
    db = _OutfitsFakeDB(
        {"outfits": [_outfit_row(OUTFIT_ID, name="One", item_ids=[])]}
    )

    result = await outfits_module.list_outfits(
        page=1,
        page_size=20,
        is_favorite=None,
        style=None,
        season=None,
        styles=None,
        seasons=None,
        favorites_only=None,
        drafts_only=None,
        search=None,
        tags=None,
        user_id=USER_ID,
        db=db,
    )

    assert result["data"]["outfits"][0]["items"] == []


@pytest.mark.asyncio
async def test_list_outfits_single_style_and_season_params_override_comma_lists():
    db = _OutfitsFakeDB(
        {
            "outfits": [
                _outfit_row(OUTFIT_ID, style="casual", season="summer", is_favorite=True),
                _outfit_row(OUTFIT_ID_2, style="formal", season="fall", is_favorite=True),
            ]
        }
    )

    result = await outfits_module.list_outfits(
        page=1,
        page_size=20,
        is_favorite=True,
        style="casual",
        season="summer",
        styles="formal",
        seasons="fall",
        favorites_only=None,
        drafts_only=None,
        search=None,
        tags=None,
        user_id=USER_ID,
        db=db,
    )

    assert result["data"]["total"] == 1
    assert result["data"]["outfits"][0]["id"] == OUTFIT_ID
    assert ("outfits", "in", "style", ["casual"]) in db.filters
    assert ("outfits", "in", "season", ["summer"]) in db.filters


@pytest.mark.asyncio
async def test_list_outfits_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("items", {"outfits": [_outfit_row()], "items": [_item_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.list_outfits(
            page=1,
            page_size=20,
            is_favorite=None,
            style=None,
            season=None,
            styles=None,
            seasons=None,
            favorites_only=None,
            drafts_only=None,
            search=None,
            tags=None,
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_available_items_returns_simplified_picker_rows():
    db = _OutfitsFakeDB(
        {
            "items": [
                _item_row(
                    ITEM_ID,
                    item_images=[
                        {"image_url": "https://cdn/a.jpg", "thumbnail_url": "https://cdn/a-t.jpg", "is_primary": True}
                    ],
                ),
                _item_row(
                    ITEM_ID_2,
                    name="Denim jacket",
                    category="outerwear",
                    colors=["blue"],
                    item_images=[{"image_url": "https://cdn/b.jpg", "thumbnail_url": "https://cdn/b-t.jpg"}],
                ),
                _item_row(
                    "cccccccc-cccc-cccc-cccc-cccccccccccc",
                    name="No image",
                    item_images=[],
                ),
            ]
        }
    )

    result = await outfits_module.available_items(user_id=USER_ID, db=db)

    rows = {i["id"]: i for i in result["data"]}
    assert rows[ITEM_ID]["image_url"] == "https://cdn/a-t.jpg"
    assert rows[ITEM_ID_2]["image_url"] == "https://cdn/b-t.jpg"
    assert rows["cccccccc-cccc-cccc-cccc-cccccccccccc"]["image_url"] is None


@pytest.mark.asyncio
async def test_available_items_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("items")

    with pytest.raises(DatabaseError):
        await outfits_module.available_items(user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_get_outfit_returns_outfit_with_items():
    db = _OutfitsFakeDB(
        {
            "outfits": [_outfit_row()],
            "items": [_item_row()],
        }
    )

    result = await outfits_module.get_outfit(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    assert result["data"]["id"] == OUTFIT_ID
    assert result["data"]["items"][0]["id"] == ITEM_ID


@pytest.mark.asyncio
async def test_get_outfit_with_no_items_attaches_empty_list():
    db = _OutfitsFakeDB({"outfits": [_outfit_row(item_ids=[])]})

    result = await outfits_module.get_outfit(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)

    assert result["data"]["items"] == []


@pytest.mark.asyncio
async def test_get_outfit_raises_when_missing():
    db = _OutfitsFakeDB({"outfits": []})

    with pytest.raises(OutfitNotFoundError):
        await outfits_module.get_outfit(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_get_outfit_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("items", {"outfits": [_outfit_row()], "items": [_item_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.get_outfit(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_get_public_outfit_returns_public_view_and_increments_views():
    db = _OutfitsFakeDB(
        {
            "outfits": [
                _outfit_row(is_public=True, item_ids=[ITEM_ID], outfit_images=[{"image_url": "https://cdn/o.jpg"}])
            ],
            "shared_outfits": [
                {"id": "s1", "outfit_id": OUTFIT_ID, "expires_at": None, "view_count": 3, "created_at": NOW}
            ],
            "items": [_item_row()],
        }
    )

    result = await outfits_module.get_public_outfit(outfit_id=UUID(OUTFIT_ID), db=db)

    assert result["message"] == "OK"
    assert result["data"]["name"] == "Weekend Casual"
    assert result["data"]["images"] == [{"image_url": "https://cdn/o.jpg"}]
    assert result["data"]["items"][0]["id"] == ITEM_ID
    update = [u for u in db.updates if u[0] == "shared_outfits"][0]
    assert update[1]["view_count"] == 4


@pytest.mark.asyncio
async def test_get_public_outfit_without_items_returns_empty_summary():
    db = _OutfitsFakeDB({"outfits": [_outfit_row(is_public=True, item_ids=[])], "shared_outfits": []})

    result = await outfits_module.get_public_outfit(outfit_id=UUID(OUTFIT_ID), db=db)

    assert result["data"]["items"] == []


@pytest.mark.asyncio
async def test_get_public_outfit_raises_not_found_when_missing_or_private():
    db = _OutfitsFakeDB({"outfits": [_outfit_row(is_public=False)]})

    with pytest.raises(NotFoundError):
        await outfits_module.get_public_outfit(outfit_id=UUID(OUTFIT_ID), db=db)


@pytest.mark.asyncio
async def test_get_public_outfit_raises_shared_not_found_when_expired():
    db = _OutfitsFakeDB(
        {
            "outfits": [_outfit_row(is_public=True)],
            "shared_outfits": [
                {"id": "s1", "outfit_id": OUTFIT_ID, "expires_at": "2020-01-01T00:00:00Z", "view_count": 0}
            ],
        }
    )

    with pytest.raises(SharedOutfitNotFoundError):
        await outfits_module.get_public_outfit(outfit_id=UUID(OUTFIT_ID), db=db)


@pytest.mark.asyncio
async def test_get_public_outfit_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfits")

    with pytest.raises(DatabaseError):
        await outfits_module.get_public_outfit(outfit_id=UUID(OUTFIT_ID), db=db)


@pytest.mark.asyncio
async def test_update_outfit_applies_the_patch():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()]})

    result = await outfits_module.update_outfit(
        outfit_id=UUID(OUTFIT_ID),
        update=OutfitUpdate(name="Weekend"),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Updated"
    assert result["data"]["name"] == "Weekend"
    assert db.rows["outfits"][0]["name"] == "Weekend"


@pytest.mark.asyncio
async def test_update_outfit_validates_replacement_items():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()], "items": [_item_row()]})

    result = await outfits_module.update_outfit(
        outfit_id=UUID(OUTFIT_ID),
        update=OutfitUpdate(item_ids=[UUID(ITEM_ID)]),
        user_id=USER_ID,
        db=db,
    )

    assert result["data"]["item_ids"] == [ITEM_ID]


@pytest.mark.asyncio
async def test_update_outfit_rejects_unknown_items():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()], "items": [_item_row()]})

    with pytest.raises(ValidationError):
        await outfits_module.update_outfit(
            outfit_id=UUID(OUTFIT_ID),
            update=OutfitUpdate(item_ids=[UUID(ITEM_ID_2)]),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_update_outfit_raises_when_missing():
    db = _OutfitsFakeDB({"outfits": []})

    with pytest.raises(OutfitNotFoundError):
        await outfits_module.update_outfit(
            outfit_id=UUID(OUTFIT_ID),
            update=OutfitUpdate(name="Weekend"),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_update_outfit_raises_database_error_when_update_returns_nothing():
    db = _EmptyWriteDB("outfits", {"outfits": [_outfit_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.update_outfit(
            outfit_id=UUID(OUTFIT_ID),
            update=OutfitUpdate(name="Weekend"),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_update_outfit_raises_database_error_when_refetch_misses():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()]})

    with patch.object(outfits_module, "_fetch_outfit", return_value=None):
        with pytest.raises(DatabaseError):
            await outfits_module.update_outfit(
                outfit_id=UUID(OUTFIT_ID),
                update=OutfitUpdate(name="Weekend"),
                user_id=USER_ID,
                db=db,
            )


@pytest.mark.asyncio
async def test_update_outfit_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfits", {"outfits": [_outfit_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.update_outfit(
            outfit_id=UUID(OUTFIT_ID),
            update=OutfitUpdate(name="Weekend"),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_share_outfit_public_visibility_upserts_share_row():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()]})

    result = await outfits_module.share_outfit(
        outfit_id=UUID(OUTFIT_ID),
        request=outfits_module.ShareOutfitRequest(visibility="public", expires_at=None, allow_feedback=True),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Created"
    assert result["data"]["share_link"]["url"] == f"http://localhost:3000/shared/outfits/{OUTFIT_ID}"
    assert db.rows["outfits"][0]["is_public"] is True
    assert db.inserts[0][0] == "shared_outfits"
    assert db.inserts[0][1]["visibility"] == "public"


@pytest.mark.asyncio
async def test_share_outfit_non_public_visibility_keeps_outfit_private():
    db = _OutfitsFakeDB({"outfits": [_outfit_row(is_public=True)]})

    result = await outfits_module.share_outfit(
        outfit_id=UUID(OUTFIT_ID),
        request=outfits_module.ShareOutfitRequest(visibility="friends"),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Created"
    assert db.rows["outfits"][0]["is_public"] is False
    assert result["data"]["share_link"]["expires_at"] is None
    assert result["data"]["share_link"]["views"] == 0


@pytest.mark.asyncio
async def test_share_outfit_raises_when_missing():
    db = _OutfitsFakeDB({"outfits": []})

    with pytest.raises(OutfitNotFoundError):
        await outfits_module.share_outfit(
            outfit_id=UUID(OUTFIT_ID),
            request=outfits_module.ShareOutfitRequest(),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_share_outfit_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfits", {"outfits": [_outfit_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.share_outfit(
            outfit_id=UUID(OUTFIT_ID),
            request=outfits_module.ShareOutfitRequest(),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_delete_outfit_delegates_to_service():
    db = _OutfitsFakeDB()

    with patch.object(outfits_module, "delete_outfit_service", new=AsyncMock()) as service:
        result = await outfits_module.delete_outfit(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)

    assert result is None
    service.assert_awaited_once_with(db, user_id=USER_ID, outfit_id=OUTFIT_ID)


@pytest.mark.asyncio
async def test_delete_outfit_re_raises_not_found():
    db = _OutfitsFakeDB()

    with patch.object(outfits_module, "delete_outfit_service", new=AsyncMock(side_effect=OutfitNotFoundError())):
        with pytest.raises(OutfitNotFoundError):
            await outfits_module.delete_outfit(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_delete_outfit_degrades_unexpected_errors_to_database_error():
    db = _OutfitsFakeDB()

    with patch.object(outfits_module, "delete_outfit_service", new=AsyncMock(side_effect=RuntimeError("boom"))):
        with pytest.raises(DatabaseError):
            await outfits_module.delete_outfit(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)


# ---------------------------------------------------------------------------
# Collections
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_create_collection_with_outfits_syncs_members():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()]})

    result = await outfits_module.create_collection(
        OutfitCollectionCreate(name="Work", outfit_ids=[UUID(OUTFIT_ID)]),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Created"
    assert result["data"]["outfit_count"] == 1
    assert result["data"]["outfit_ids"] == [OUTFIT_ID]
    assert any(i[0] == "outfit_collection_items" for i in db.inserts)


@pytest.mark.asyncio
async def test_create_collection_without_outfits():
    db = _OutfitsFakeDB()

    result = await outfits_module.create_collection(
        OutfitCollectionCreate(name="Work"),
        user_id=USER_ID,
        db=db,
    )

    assert result["data"]["outfit_count"] == 0
    assert result["data"]["outfit_ids"] == []
    assert all(i[0] != "outfit_collection_items" for i in db.inserts)


@pytest.mark.asyncio
async def test_create_collection_rejects_unknown_outfits():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()]})

    with pytest.raises(ValidationError):
        await outfits_module.create_collection(
            OutfitCollectionCreate(name="Work", outfit_ids=[UUID(OUTFIT_ID_2)]),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_create_collection_raises_database_error_when_insert_returns_nothing():
    db = _EmptyWriteDB("outfit_collections", {"outfits": [_outfit_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.create_collection(
            OutfitCollectionCreate(name="Work"),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_create_collection_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfit_collections")

    with pytest.raises(DatabaseError):
        await outfits_module.create_collection(
            OutfitCollectionCreate(name="Work"),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_list_collections_derives_counts_and_member_ids():
    db = _RawMembersDB(
        {
            "outfit_collections": [_collection_row(), _collection_row(COLLECTION_ID_2, name="Night")],
            "outfit_collection_items": [
                {"collection_id": COLLECTION_ID, "outfit_id": OUTFIT_ID},
                {"collection_id": COLLECTION_ID, "outfit_id": OUTFIT_ID_2},
                {"collection_id": COLLECTION_ID_2, "outfit_id": None},
                {"collection_id": "", "outfit_id": OUTFIT_ID_3},
            ],
        }
    )

    result = await outfits_module.list_collections(user_id=USER_ID, db=db)

    by_id = {c["id"]: c for c in result["data"]["collections"]}
    assert by_id[COLLECTION_ID]["outfit_count"] == 2
    assert by_id[COLLECTION_ID]["outfit_ids"] == [OUTFIT_ID, OUTFIT_ID_2]
    assert by_id[COLLECTION_ID_2]["outfit_count"] == 1
    assert by_id[COLLECTION_ID_2]["outfit_ids"] == []


@pytest.mark.asyncio
async def test_list_collections_with_none_returns_empty_list():
    db = _OutfitsFakeDB({"outfit_collections": []})

    result = await outfits_module.list_collections(user_id=USER_ID, db=db)

    assert result["data"]["collections"] == []


@pytest.mark.asyncio
async def test_list_collections_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfit_collections")

    with pytest.raises(DatabaseError):
        await outfits_module.list_collections(user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_update_collection_updates_fields_and_syncs_outfits():
    db = _OutfitsFakeDB(
        {"outfit_collections": [_collection_row()], "outfits": [_outfit_row()]}
    )

    result = await outfits_module.update_collection(
        collection_id=UUID(COLLECTION_ID),
        update=OutfitCollectionUpdate(name="Evening", outfit_ids=[UUID(OUTFIT_ID)]),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Updated"
    assert result["data"]["name"] == "Evening"
    assert result["data"]["outfit_count"] == 1
    assert result["data"]["outfit_ids"] == [OUTFIT_ID]
    assert any(u[0] == "outfit_collections" for u in db.updates)


@pytest.mark.asyncio
async def test_update_collection_with_only_outfits_skips_field_update():
    db = _OutfitsFakeDB({"outfit_collections": [_collection_row()], "outfits": [_outfit_row()]})

    result = await outfits_module.update_collection(
        collection_id=UUID(COLLECTION_ID),
        update=OutfitCollectionUpdate(outfit_ids=[UUID(OUTFIT_ID)]),
        user_id=USER_ID,
        db=db,
    )

    assert result["data"]["outfit_ids"] == [OUTFIT_ID]
    assert all(u[0] != "outfit_collections" for u in db.updates)


@pytest.mark.asyncio
async def test_update_collection_without_outfits_reads_member_ids():
    db = _OutfitsFakeDB(
        {
            "outfit_collections": [_collection_row()],
            "outfit_collection_items": [{"collection_id": COLLECTION_ID, "outfit_id": OUTFIT_ID}],
        }
    )

    result = await outfits_module.update_collection(
        collection_id=UUID(COLLECTION_ID),
        update=OutfitCollectionUpdate(name="Evening"),
        user_id=USER_ID,
        db=db,
    )

    assert result["data"]["outfit_count"] == 1
    assert result["data"]["outfit_ids"] == [OUTFIT_ID]


@pytest.mark.asyncio
async def test_update_collection_raises_when_missing():
    db = _OutfitsFakeDB({"outfit_collections": []})

    with pytest.raises(CollectionNotFoundError):
        await outfits_module.update_collection(
            collection_id=UUID(COLLECTION_ID),
            update=OutfitCollectionUpdate(name="Evening"),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_update_collection_raises_database_error_when_refetch_misses():
    db = _RefetchEmptyDB(
        {"outfit_collections": [_collection_row()], "outfits": [_outfit_row()]}
    )

    with pytest.raises(DatabaseError):
        await outfits_module.update_collection(
            collection_id=UUID(COLLECTION_ID),
            update=OutfitCollectionUpdate(name="Evening"),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_update_collection_rejects_unknown_outfits():
    db = _OutfitsFakeDB({"outfit_collections": [_collection_row()], "outfits": [_outfit_row()]})

    with pytest.raises(ValidationError):
        await outfits_module.update_collection(
            collection_id=UUID(COLLECTION_ID),
            update=OutfitCollectionUpdate(outfit_ids=[UUID(OUTFIT_ID_2)]),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_update_collection_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfit_collections", {"outfit_collections": [_collection_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.update_collection(
            collection_id=UUID(COLLECTION_ID),
            update=OutfitCollectionUpdate(name="Evening"),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_replace_collection_outfits_syncs_and_reads_back():
    db = _OutfitsFakeDB({"outfit_collections": [_collection_row()], "outfits": [_outfit_row()]})

    result = await outfits_module.replace_collection_outfits(
        collection_id=UUID(COLLECTION_ID),
        request=outfits_module.UpdateCollectionOutfitsRequest(outfit_ids=[OUTFIT_ID]),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Updated"
    assert result["data"]["outfit_count"] == 1
    assert result["data"]["outfit_ids"] == [OUTFIT_ID]


@pytest.mark.asyncio
async def test_replace_collection_outfits_with_empty_list():
    db = _OutfitsFakeDB({"outfit_collections": [_collection_row()]})

    result = await outfits_module.replace_collection_outfits(
        collection_id=UUID(COLLECTION_ID),
        request=outfits_module.UpdateCollectionOutfitsRequest(outfit_ids=[]),
        user_id=USER_ID,
        db=db,
    )

    assert result["data"]["outfit_count"] == 0
    assert result["data"]["outfit_ids"] == []


@pytest.mark.asyncio
async def test_replace_collection_outfits_raises_when_missing():
    db = _OutfitsFakeDB({"outfit_collections": []})

    with pytest.raises(CollectionNotFoundError):
        await outfits_module.replace_collection_outfits(
            collection_id=UUID(COLLECTION_ID),
            request=outfits_module.UpdateCollectionOutfitsRequest(outfit_ids=[]),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_replace_collection_outfits_rejects_unknown_outfits():
    db = _OutfitsFakeDB({"outfit_collections": [_collection_row()], "outfits": [_outfit_row()]})

    with pytest.raises(ValidationError):
        await outfits_module.replace_collection_outfits(
            collection_id=UUID(COLLECTION_ID),
            request=outfits_module.UpdateCollectionOutfitsRequest(outfit_ids=[OUTFIT_ID_2]),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_replace_collection_outfits_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfit_collections", {"outfit_collections": [_collection_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.replace_collection_outfits(
            collection_id=UUID(COLLECTION_ID),
            request=outfits_module.UpdateCollectionOutfitsRequest(outfit_ids=[]),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_add_collection_outfit_upserts_a_new_member():
    """New membership: the membership read finds no row and the idempotent
    upsert inserts the junction row (then the count reflects it).

    NOTE (app bug, reported in the task notes): real postgrest-py
    ``maybe_single().execute()`` returns a bare ``None`` on zero rows, so
    ``membership.data`` raises AttributeError and this branch 500s as a
    DatabaseError in production - only the already-a-member path works. The
    local fake normalizes the zero-row response to a response object so the
    intended branch stays executable in tests.
    """
    db = _OutfitsFakeDB(
        {"outfit_collections": [_collection_row()], "outfits": [_outfit_row()]}
    )

    result = await outfits_module.add_collection_outfit(
        collection_id=UUID(COLLECTION_ID),
        request=outfits_module.AddCollectionOutfitRequest(outfit_id=OUTFIT_ID),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Added"
    assert result["data"]["outfit_count"] == 1
    assert db.inserts[-1][0] == "outfit_collection_items"
    assert db.inserts[-1][2] == "collection_id,outfit_id"


@pytest.mark.asyncio
async def test_add_collection_outfit_skips_upsert_when_already_a_member():
    db = _OutfitsFakeDB(
        {
            "outfit_collections": [_collection_row()],
            "outfits": [_outfit_row()],
            "outfit_collection_items": [{"collection_id": COLLECTION_ID, "outfit_id": OUTFIT_ID}],
        }
    )

    result = await outfits_module.add_collection_outfit(
        collection_id=UUID(COLLECTION_ID),
        request=outfits_module.AddCollectionOutfitRequest(outfit_id=OUTFIT_ID),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Added"
    assert result["data"]["outfit_count"] == 1
    assert all(i[0] != "outfit_collection_items" for i in db.inserts)


@pytest.mark.asyncio
async def test_add_collection_outfit_rejects_unknown_outfit():
    db = _OutfitsFakeDB({"outfit_collections": [_collection_row()]})

    with pytest.raises(ValidationError):
        await outfits_module.add_collection_outfit(
            collection_id=UUID(COLLECTION_ID),
            request=outfits_module.AddCollectionOutfitRequest(outfit_id=OUTFIT_ID),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_add_collection_outfit_raises_when_collection_missing():
    db = _OutfitsFakeDB({"outfit_collections": []})

    with pytest.raises(CollectionNotFoundError):
        await outfits_module.add_collection_outfit(
            collection_id=UUID(COLLECTION_ID),
            request=outfits_module.AddCollectionOutfitRequest(outfit_id=OUTFIT_ID),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_add_collection_outfit_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfit_collections", {"outfit_collections": [_collection_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.add_collection_outfit(
            collection_id=UUID(COLLECTION_ID),
            request=outfits_module.AddCollectionOutfitRequest(outfit_id=OUTFIT_ID),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_remove_collection_outfit_deletes_the_junction_row():
    db = _OutfitsFakeDB(
        {
            "outfit_collections": [_collection_row()],
            "outfit_collection_items": [{"collection_id": COLLECTION_ID, "outfit_id": OUTFIT_ID}],
        }
    )

    result = await outfits_module.remove_collection_outfit(
        collection_id=UUID(COLLECTION_ID),
        outfit_id=UUID(OUTFIT_ID),
        user_id=USER_ID,
        db=db,
    )

    assert result is None
    assert db.rows["outfit_collection_items"] == []


@pytest.mark.asyncio
async def test_remove_collection_outfit_raises_when_collection_missing():
    db = _OutfitsFakeDB({"outfit_collections": []})

    with pytest.raises(CollectionNotFoundError):
        await outfits_module.remove_collection_outfit(
            collection_id=UUID(COLLECTION_ID),
            outfit_id=UUID(OUTFIT_ID),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_remove_collection_outfit_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfit_collections", {"outfit_collections": [_collection_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.remove_collection_outfit(
            collection_id=UUID(COLLECTION_ID),
            outfit_id=UUID(OUTFIT_ID),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_delete_collection_deletes_the_row():
    db = _OutfitsFakeDB({"outfit_collections": [_collection_row()]})

    result = await outfits_module.delete_collection(
        collection_id=UUID(COLLECTION_ID), user_id=USER_ID, db=db
    )

    assert result is None
    assert db.rows["outfit_collections"] == []


@pytest.mark.asyncio
async def test_delete_collection_raises_when_missing():
    db = _OutfitsFakeDB({"outfit_collections": []})

    with pytest.raises(CollectionNotFoundError):
        await outfits_module.delete_collection(collection_id=UUID(COLLECTION_ID), user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_delete_collection_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfit_collections", {"outfit_collections": [_collection_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.delete_collection(collection_id=UUID(COLLECTION_ID), user_id=USER_ID, db=db)


# ---------------------------------------------------------------------------
# Favorites, wear, duplicate, composition
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_toggle_favorite_turns_a_favorite_on():
    db = _OutfitsFakeDB({"outfits": [_outfit_row(is_favorite=False)]})

    result = await outfits_module.toggle_favorite(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)

    assert result["data"]["is_favorite"] is True
    assert db.rows["outfits"][0]["is_favorite"] is True


@pytest.mark.asyncio
async def test_toggle_favorite_turns_a_favorite_off():
    db = _OutfitsFakeDB({"outfits": [_outfit_row(is_favorite=True)]})

    result = await outfits_module.toggle_favorite(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)

    assert result["data"]["is_favorite"] is False


@pytest.mark.asyncio
async def test_toggle_favorite_raises_when_missing():
    db = _OutfitsFakeDB({"outfits": []})

    with pytest.raises(OutfitNotFoundError):
        await outfits_module.toggle_favorite(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_toggle_favorite_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfits", {"outfits": [_outfit_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.toggle_favorite(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_mark_worn_increments_count_and_records_history():
    db = _OutfitsFakeDB({"outfits": [_outfit_row(worn_count=2)]})

    result = await outfits_module.mark_worn(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    assert result["data"]["worn_count"] == 3
    assert result["data"]["last_worn_at"] is not None
    assert db.rows["outfits"][0]["worn_count"] == 3
    assert any(i[0] == "outfit_wear_history" for i in db.inserts)


@pytest.mark.asyncio
async def test_mark_worn_survives_wear_history_insert_failure():
    db = _RaisingDB("outfit_wear_history", {"outfits": [_outfit_row(worn_count=0)]})

    result = await outfits_module.mark_worn(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)

    assert result["data"]["worn_count"] == 1
    assert all(i[0] != "outfit_wear_history" for i in db.inserts)


@pytest.mark.asyncio
async def test_mark_worn_raises_when_missing():
    db = _OutfitsFakeDB({"outfits": []})

    with pytest.raises(OutfitNotFoundError):
        await outfits_module.mark_worn(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_mark_worn_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfits", {"outfits": [_outfit_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.mark_worn(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_get_wear_history_returns_records():
    db = _OutfitsFakeDB(
        {
            "outfits": [_outfit_row()],
            "outfit_wear_history": [
                {"id": "w1", "outfit_id": OUTFIT_ID, "worn_at": NOW},
                {"id": "w2", "outfit_id": OUTFIT_ID, "worn_at": "2025-12-01T00:00:00"},
            ],
        }
    )

    result = await outfits_module.get_wear_history(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    assert [w["id"] for w in result["data"]["wear_history"]] == ["w1", "w2"]


@pytest.mark.asyncio
async def test_get_wear_history_degrades_to_empty_when_table_errors():
    db = _RaisingDB("outfit_wear_history", {"outfits": [_outfit_row()]})

    result = await outfits_module.get_wear_history(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)

    assert result["data"]["wear_history"] == []


@pytest.mark.asyncio
async def test_get_wear_history_raises_when_outfit_missing():
    db = _OutfitsFakeDB({"outfits": []})

    with pytest.raises(OutfitNotFoundError):
        await outfits_module.get_wear_history(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_get_wear_history_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfits", {"outfits": [_outfit_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.get_wear_history(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_duplicate_outfit_creates_a_draft_copy():
    db = _OutfitsFakeDB(
        {"outfits": [_outfit_row(name="Weekend", description="d", style="casual", season="summer")]}
    )

    result = await outfits_module.duplicate_outfit(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)

    assert result["message"] == "Created"
    assert result["data"]["name"] == "Copy of Weekend"
    assert result["data"]["is_draft"] is True
    assert result["data"]["is_public"] is False
    assert result["data"]["item_ids"] == [ITEM_ID]
    assert result["data"]["images"] == []


@pytest.mark.asyncio
async def test_duplicate_outfit_raises_when_missing():
    db = _OutfitsFakeDB({"outfits": []})

    with pytest.raises(OutfitNotFoundError):
        await outfits_module.duplicate_outfit(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_duplicate_outfit_raises_database_error_when_insert_returns_nothing():
    db = _EmptyWriteDB("outfits", {"outfits": [_outfit_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.duplicate_outfit(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_duplicate_outfit_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfits", {"outfits": [_outfit_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.duplicate_outfit(outfit_id=UUID(OUTFIT_ID), user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_add_item_to_outfit_appends_and_persists():
    db = _OutfitsFakeDB({"outfits": [_outfit_row(item_ids=[ITEM_ID])], "items": [_item_row(), _item_row(ITEM_ID_2)]})

    result = await outfits_module.add_item_to_outfit(
        outfit_id=UUID(OUTFIT_ID),
        request=outfits_module.AddItemToOutfitRequest(item_id=ITEM_ID_2),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Updated"
    assert result["data"]["item_ids"] == [ITEM_ID, ITEM_ID_2]
    assert db.rows["outfits"][0]["item_ids"] == [ITEM_ID, ITEM_ID_2]


@pytest.mark.asyncio
async def test_add_item_to_outfit_returns_current_when_item_present():
    db = _OutfitsFakeDB({"outfits": [_outfit_row(item_ids=[ITEM_ID])], "items": [_item_row()]})

    result = await outfits_module.add_item_to_outfit(
        outfit_id=UUID(OUTFIT_ID),
        request=outfits_module.AddItemToOutfitRequest(item_id=ITEM_ID),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "OK"
    assert result["data"]["id"] == OUTFIT_ID
    assert db.rows["outfits"][0]["item_ids"] == [ITEM_ID]


@pytest.mark.asyncio
async def test_add_item_to_outfit_falls_back_to_minimal_dict_when_fetch_misses():
    db = _OutfitsFakeDB({"outfits": [_outfit_row(item_ids=[ITEM_ID])], "items": [_item_row()]})

    with patch.object(outfits_module, "_fetch_outfit", return_value=None):
        result = await outfits_module.add_item_to_outfit(
            outfit_id=UUID(OUTFIT_ID),
            request=outfits_module.AddItemToOutfitRequest(item_id=ITEM_ID),
            user_id=USER_ID,
            db=db,
        )

    assert result["data"] == {"id": OUTFIT_ID, "item_ids": [ITEM_ID], "images": []}


@pytest.mark.asyncio
async def test_add_item_to_outfit_raises_when_outfit_missing():
    db = _OutfitsFakeDB({"outfits": [], "items": [_item_row()]})

    with pytest.raises(OutfitNotFoundError):
        await outfits_module.add_item_to_outfit(
            outfit_id=UUID(OUTFIT_ID),
            request=outfits_module.AddItemToOutfitRequest(item_id=ITEM_ID),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_add_item_to_outfit_raises_when_item_missing():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()], "items": []})

    with pytest.raises(ItemNotFoundError):
        await outfits_module.add_item_to_outfit(
            outfit_id=UUID(OUTFIT_ID),
            request=outfits_module.AddItemToOutfitRequest(item_id=ITEM_ID),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_add_item_to_outfit_raises_database_error_when_refetch_misses():
    db = _OutfitsFakeDB(
        {"outfits": [_outfit_row(item_ids=[ITEM_ID])], "items": [_item_row(), _item_row(ITEM_ID_2)]}
    )

    with patch.object(outfits_module, "_fetch_outfit", return_value=None):
        with pytest.raises(DatabaseError):
            await outfits_module.add_item_to_outfit(
                outfit_id=UUID(OUTFIT_ID),
                request=outfits_module.AddItemToOutfitRequest(item_id=ITEM_ID_2),
                user_id=USER_ID,
                db=db,
            )


@pytest.mark.asyncio
async def test_add_item_to_outfit_raises_database_error_when_update_returns_nothing():
    db = _EmptyWriteDB("outfits", {"outfits": [_outfit_row(item_ids=[ITEM_ID])], "items": [_item_row(), _item_row(ITEM_ID_2)]})

    with pytest.raises(DatabaseError):
        await outfits_module.add_item_to_outfit(
            outfit_id=UUID(OUTFIT_ID),
            request=outfits_module.AddItemToOutfitRequest(item_id=ITEM_ID_2),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_add_item_to_outfit_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("items", {"outfits": [_outfit_row()], "items": [_item_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.add_item_to_outfit(
            outfit_id=UUID(OUTFIT_ID),
            request=outfits_module.AddItemToOutfitRequest(item_id=ITEM_ID),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_remove_item_from_outfit_removes_and_persists():
    db = _OutfitsFakeDB({"outfits": [_outfit_row(item_ids=[ITEM_ID, ITEM_ID_2])], "items": [_item_row(), _item_row(ITEM_ID_2)]})

    result = await outfits_module.remove_item_from_outfit(
        outfit_id=UUID(OUTFIT_ID),
        item_id=UUID(ITEM_ID),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Updated"
    assert result["data"]["item_ids"] == [ITEM_ID_2]
    assert db.rows["outfits"][0]["item_ids"] == [ITEM_ID_2]


@pytest.mark.asyncio
async def test_remove_item_from_outfit_returns_current_when_item_absent():
    db = _OutfitsFakeDB({"outfits": [_outfit_row(item_ids=[ITEM_ID])], "items": [_item_row()]})

    result = await outfits_module.remove_item_from_outfit(
        outfit_id=UUID(OUTFIT_ID),
        item_id=UUID(ITEM_ID_2),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "OK"
    assert result["data"]["id"] == OUTFIT_ID


@pytest.mark.asyncio
async def test_remove_item_from_outfit_falls_back_to_minimal_dict_when_fetch_misses():
    db = _OutfitsFakeDB({"outfits": [_outfit_row(item_ids=[ITEM_ID])], "items": [_item_row()]})

    with patch.object(outfits_module, "_fetch_outfit", return_value=None):
        result = await outfits_module.remove_item_from_outfit(
            outfit_id=UUID(OUTFIT_ID),
            item_id=UUID(ITEM_ID_2),
            user_id=USER_ID,
            db=db,
        )

    assert result["data"] == {"id": OUTFIT_ID, "item_ids": [ITEM_ID], "images": []}


@pytest.mark.asyncio
async def test_remove_item_from_outfit_rejects_removing_the_last_item():
    db = _OutfitsFakeDB({"outfits": [_outfit_row(item_ids=[ITEM_ID])], "items": [_item_row()]})

    with pytest.raises(ValidationError):
        await outfits_module.remove_item_from_outfit(
            outfit_id=UUID(OUTFIT_ID),
            item_id=UUID(ITEM_ID),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_remove_item_from_outfit_raises_when_outfit_missing():
    db = _OutfitsFakeDB({"outfits": []})

    with pytest.raises(OutfitNotFoundError):
        await outfits_module.remove_item_from_outfit(
            outfit_id=UUID(OUTFIT_ID),
            item_id=UUID(ITEM_ID),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_remove_item_from_outfit_raises_database_error_when_refetch_misses():
    db = _OutfitsFakeDB(
        {"outfits": [_outfit_row(item_ids=[ITEM_ID, ITEM_ID_2])], "items": [_item_row(), _item_row(ITEM_ID_2)]}
    )

    with patch.object(outfits_module, "_fetch_outfit", return_value=None):
        with pytest.raises(DatabaseError):
            await outfits_module.remove_item_from_outfit(
                outfit_id=UUID(OUTFIT_ID),
                item_id=UUID(ITEM_ID),
                user_id=USER_ID,
                db=db,
            )


@pytest.mark.asyncio
async def test_remove_item_from_outfit_raises_database_error_when_update_returns_nothing():
    db = _EmptyWriteDB(
        "outfits", {"outfits": [_outfit_row(item_ids=[ITEM_ID, ITEM_ID_2])], "items": [_item_row(), _item_row(ITEM_ID_2)]}
    )

    with pytest.raises(DatabaseError):
        await outfits_module.remove_item_from_outfit(
            outfit_id=UUID(OUTFIT_ID),
            item_id=UUID(ITEM_ID),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_remove_item_from_outfit_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfits", {"outfits": [_outfit_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.remove_item_from_outfit(
            outfit_id=UUID(OUTFIT_ID),
            item_id=UUID(ITEM_ID),
            user_id=USER_ID,
            db=db,
        )


# ---------------------------------------------------------------------------
# Generation tracking
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_start_generation_creates_a_processing_record():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()]})

    result = await outfits_module.start_generation(
        outfit_id=UUID(OUTFIT_ID),
        request=GenerationRequest(pose="front", variations=2, lighting="natural", body_profile_id=UUID(IMAGE_ID)),
        user_id=USER_ID,
        db=db,
    )

    assert result["message"] == "Accepted"
    assert result["data"]["status"] == "processing"
    assert result["data"]["estimated_time"] == 30
    row = db.rows["outfit_generations"][0]
    assert row["status"] == "processing"
    assert row["body_profile_id"] == IMAGE_ID


@pytest.mark.asyncio
async def test_start_generation_without_body_profile():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()]})

    result = await outfits_module.start_generation(
        outfit_id=UUID(OUTFIT_ID),
        request=GenerationRequest(),
        user_id=USER_ID,
        db=db,
    )

    assert db.rows["outfit_generations"][0]["body_profile_id"] is None
    assert result["data"]["generation_id"]


@pytest.mark.asyncio
async def test_start_generation_raises_when_outfit_missing():
    db = _OutfitsFakeDB({"outfits": []})

    with pytest.raises(OutfitNotFoundError):
        await outfits_module.start_generation(
            outfit_id=UUID(OUTFIT_ID),
            request=GenerationRequest(),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_start_generation_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfits", {"outfits": [_outfit_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.start_generation(
            outfit_id=UUID(OUTFIT_ID),
            request=GenerationRequest(),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_get_generation_status_returns_the_row():
    db = _OutfitsFakeDB(
        {
            "outfit_generations": [
                {
                    "id": GENERATION_ID,
                    "user_id": USER_ID,
                    "status": "completed",
                    "progress": 100,
                    "image_urls": ["https://cdn/gen.jpg"],
                    "error": None,
                }
            ]
        }
    )

    result = await outfits_module.get_generation_status(
        generation_id=UUID(GENERATION_ID), user_id=USER_ID, db=db
    )

    assert result["message"] == "OK"
    assert result["data"]["status"] == "completed"
    assert result["data"]["progress"] == 100
    assert result["data"]["images"] == ["https://cdn/gen.jpg"]
    assert result["data"]["error"] is None


@pytest.mark.asyncio
async def test_get_generation_status_raises_when_missing():
    db = _OutfitsFakeDB({"outfit_generations": []})

    with pytest.raises(NotFoundError):
        await outfits_module.get_generation_status(generation_id=UUID(GENERATION_ID), user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_get_generation_status_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfit_generations")

    with pytest.raises(DatabaseError):
        await outfits_module.get_generation_status(generation_id=UUID(GENERATION_ID), user_id=USER_ID, db=db)


# ---------------------------------------------------------------------------
# Outfit images
# ---------------------------------------------------------------------------


_UPLOAD_RESPONSE = {
    "image_url": "https://cdn/uploaded.jpg",
    "thumbnail_url": "https://cdn/uploaded-t.jpg",
    "storage_path": "u/outfits/x.jpg",
    "generation_type": "ai",
    "width": 1024,
    "height": 768,
    "metadata": {"model": "m1"},
}


@pytest.mark.asyncio
async def test_upload_outfit_image_marks_generation_complete_when_primary():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()]})

    with patch.object(StorageService, "upload_outfit_image", new=AsyncMock(return_value=_UPLOAD_RESPONSE)):
        result = await outfits_module.upload_outfit_image(
            outfit_id=UUID(OUTFIT_ID),
            file=_FakeUpload(),
            pose="front",
            lighting="natural",
            body_profile_id=None,
            generation_id=GENERATION_ID,
            is_primary=True,
            user_id=USER_ID,
            db=db,
        )

    assert result["message"] == "Created"
    assert result["data"]["image_url"] == "https://cdn/uploaded.jpg"
    assert result["data"]["generation_metadata"] == {"model": "m1"}
    assert db.rows["outfit_images"][0]["id"] == result["data"]["id"]
    # Primary flag is cleared on other images and the generation is completed.
    assert any(u[0] == "outfit_images" for u in db.updates)
    generation_update = [u for u in db.updates if u[0] == "outfit_generations"][0]
    assert generation_update[1]["status"] == "completed"
    assert generation_update[1]["progress"] == 100


@pytest.mark.asyncio
async def test_upload_outfit_image_non_primary_skips_primary_and_generation_updates():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()]})

    with patch.object(StorageService, "upload_outfit_image", new=AsyncMock(return_value={})):
        result = await outfits_module.upload_outfit_image(
            outfit_id=UUID(OUTFIT_ID),
            file=_FakeUpload(),
            is_primary=False,
            generation_id=None,
            user_id=USER_ID,
            db=db,
        )

    assert result["data"]["image_url"] is None
    assert result["data"]["generation_type"] == "ai"
    assert result["data"]["is_primary"] is False
    assert all(u[0] != "outfit_generations" for u in db.updates)
    assert all(u[0] != "outfit_images" for u in db.updates)


@pytest.mark.asyncio
async def test_upload_outfit_image_rejects_non_image_content_type():
    upload = _FakeUpload(content_type="text/plain")

    with pytest.raises(UnsupportedMediaTypeError):
        await outfits_module.upload_outfit_image(
            outfit_id=UUID(OUTFIT_ID),
            file=upload,
            user_id=USER_ID,
            db=_OutfitsFakeDB({"outfits": [_outfit_row()]}),
        )


@pytest.mark.asyncio
async def test_upload_outfit_image_rejects_empty_content_type():
    upload = _FakeUpload(content_type="")

    with pytest.raises(UnsupportedMediaTypeError):
        await outfits_module.upload_outfit_image(
            outfit_id=UUID(OUTFIT_ID),
            file=upload,
            user_id=USER_ID,
            db=_OutfitsFakeDB({"outfits": [_outfit_row()]}),
        )


@pytest.mark.asyncio
async def test_upload_outfit_image_raises_when_outfit_missing():
    db = _OutfitsFakeDB({"outfits": []})

    with pytest.raises(OutfitNotFoundError):
        await outfits_module.upload_outfit_image(
            outfit_id=UUID(OUTFIT_ID),
            file=_FakeUpload(),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_upload_outfit_image_tolerates_insert_returning_no_rows():
    db = _EmptyWriteDB("outfit_images", {"outfits": [_outfit_row()]})

    with patch.object(StorageService, "upload_outfit_image", new=AsyncMock(return_value=_UPLOAD_RESPONSE)):
        result = await outfits_module.upload_outfit_image(
            outfit_id=UUID(OUTFIT_ID),
            file=_FakeUpload(),
            is_primary=True,
            user_id=USER_ID,
            db=db,
        )

    assert result["message"] == "Created"
    assert all(u[0] != "outfit_images" for u in db.updates)


@pytest.mark.asyncio
async def test_upload_outfit_image_degrades_unexpected_errors_to_database_error():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()]})

    with patch.object(StorageService, "upload_outfit_image", new=AsyncMock(side_effect=RuntimeError("boom"))):
        with pytest.raises(DatabaseError):
            await outfits_module.upload_outfit_image(
                outfit_id=UUID(OUTFIT_ID),
                file=_FakeUpload(),
                user_id=USER_ID,
                db=db,
            )


@pytest.mark.asyncio
async def test_delete_outfit_image_deletes_storage_and_row():
    db = _OutfitsFakeDB(
        {
            "outfits": [_outfit_row()],
            "outfit_images": [{"id": IMAGE_ID, "outfit_id": OUTFIT_ID, "storage_path": "u/outfits/x.jpg"}],
        }
    )

    with patch.object(StorageService, "delete_image", new=AsyncMock()) as delete_image:
        result = await outfits_module.delete_outfit_image(
            outfit_id=UUID(OUTFIT_ID), image_id=UUID(IMAGE_ID), user_id=USER_ID, db=db
        )

    assert result["data"] == {"deleted": True}
    delete_image.assert_awaited_once_with(db=db, storage_path="u/outfits/x.jpg")
    assert db.rows["outfit_images"] == []


@pytest.mark.asyncio
async def test_delete_outfit_image_skips_storage_when_no_path():
    db = _OutfitsFakeDB(
        {
            "outfits": [_outfit_row()],
            "outfit_images": [{"id": IMAGE_ID, "outfit_id": OUTFIT_ID, "storage_path": None}],
        }
    )

    with patch.object(StorageService, "delete_image", new=AsyncMock()) as delete_image:
        result = await outfits_module.delete_outfit_image(
            outfit_id=UUID(OUTFIT_ID), image_id=UUID(IMAGE_ID), user_id=USER_ID, db=db
        )

    assert result["message"] == "OK"
    delete_image.assert_not_awaited()


@pytest.mark.asyncio
async def test_delete_outfit_image_survives_storage_delete_failure():
    db = _OutfitsFakeDB(
        {
            "outfits": [_outfit_row()],
            "outfit_images": [{"id": IMAGE_ID, "outfit_id": OUTFIT_ID, "storage_path": "u/outfits/x.jpg"}],
        }
    )

    with patch.object(StorageService, "delete_image", new=AsyncMock(side_effect=RuntimeError("boom"))):
        result = await outfits_module.delete_outfit_image(
            outfit_id=UUID(OUTFIT_ID), image_id=UUID(IMAGE_ID), user_id=USER_ID, db=db
        )

    assert result["data"] == {"deleted": True}
    assert db.rows["outfit_images"] == []


@pytest.mark.asyncio
async def test_delete_outfit_image_raises_when_outfit_missing():
    db = _OutfitsFakeDB({"outfits": []})

    with pytest.raises(OutfitNotFoundError):
        await outfits_module.delete_outfit_image(
            outfit_id=UUID(OUTFIT_ID), image_id=UUID(IMAGE_ID), user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_delete_outfit_image_raises_when_image_missing():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()], "outfit_images": []})

    with pytest.raises(ImageNotFoundError):
        await outfits_module.delete_outfit_image(
            outfit_id=UUID(OUTFIT_ID), image_id=UUID(IMAGE_ID), user_id=USER_ID, db=db
        )


@pytest.mark.asyncio
async def test_delete_outfit_image_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfits", {"outfits": [_outfit_row()]})

    with pytest.raises(DatabaseError):
        await outfits_module.delete_outfit_image(
            outfit_id=UUID(OUTFIT_ID), image_id=UUID(IMAGE_ID), user_id=USER_ID, db=db
        )


# ---------------------------------------------------------------------------
# Stats, batch delete, recently-worn, favorites, weather
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_outfit_stats_aggregates_style_season_and_wear():
    db = _OutfitsFakeDB(
        {
            "outfits": [
                _outfit_row(OUTFIT_ID, name="A", style=None, season=None, worn_count=3, created_at="2026-01-03T00:00:00"),
                _outfit_row(OUTFIT_ID_2, name="B", style="casual", season="summer", worn_count=5, created_at="2026-01-01T00:00:00"),
                _outfit_row(OUTFIT_ID_3, name="C", style="CASUAL", season="WINTER", worn_count=0, created_at="2026-01-02T00:00:00"),
            ]
        }
    )

    result = await outfits_module.get_outfit_stats(user_id=USER_ID, db=db)

    data = result["data"]
    assert data["total_outfits"] == 3
    assert data["outfits_by_style"] == {"other": 1, "casual": 2}
    assert data["outfits_by_season"] == {"unknown": 1, "summer": 1, "winter": 1}
    assert data["most_worn_outfits"][0]["id"] == OUTFIT_ID_2
    assert data["recent_outfits"][0]["id"] == OUTFIT_ID


@pytest.mark.asyncio
async def test_get_outfit_stats_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfits")

    with pytest.raises(DatabaseError):
        await outfits_module.get_outfit_stats(user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_batch_delete_outfits_requires_ids():
    db = _OutfitsFakeDB()

    with pytest.raises(ValidationError):
        await outfits_module.batch_delete_outfits(
            outfits_module.BatchDeleteOutfitsRequest(outfit_ids=[""]),
            user_id=USER_ID,
            db=db,
        )


@pytest.mark.asyncio
async def test_batch_delete_outfits_deletes_rows_and_images():
    db = _OutfitsFakeDB({"outfits": [_outfit_row(), _outfit_row(OUTFIT_ID_2)]})

    with (
        patch.object(
            StorageService, "resolve_owned_storage_paths", new=AsyncMock(return_value={"storage_paths": ["p1", "p2"]})
        ) as resolve,
        patch.object(StorageService, "delete_multiple_images", new=AsyncMock(return_value=2)) as delete_many,
    ):
        result = await outfits_module.batch_delete_outfits(
            outfits_module.BatchDeleteOutfitsRequest(outfit_ids=[OUTFIT_ID, OUTFIT_ID_2, OUTFIT_ID]),
            user_id=USER_ID,
            db=db,
        )

    assert result["data"] == {"deleted_count": 2}
    resolve.assert_awaited_once()
    delete_many.assert_awaited_once_with(db=db, storage_paths=["p1", "p2"])
    assert db.rows["outfits"] == []


@pytest.mark.asyncio
async def test_batch_delete_outfits_skips_storage_when_no_paths():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()]})

    with (
        patch.object(
            StorageService, "resolve_owned_storage_paths", new=AsyncMock(return_value={"storage_paths": []})
        ),
        patch.object(StorageService, "delete_multiple_images", new=AsyncMock()) as delete_many,
    ):
        result = await outfits_module.batch_delete_outfits(
            outfits_module.BatchDeleteOutfitsRequest(outfit_ids=[OUTFIT_ID]),
            user_id=USER_ID,
            db=db,
        )

    assert result["data"]["deleted_count"] == 1
    delete_many.assert_not_awaited()


@pytest.mark.asyncio
async def test_batch_delete_outfits_survives_storage_delete_failure():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()]})

    with (
        patch.object(
            StorageService, "resolve_owned_storage_paths", new=AsyncMock(return_value={"storage_paths": ["p1"]})
        ),
        patch.object(StorageService, "delete_multiple_images", new=AsyncMock(side_effect=RuntimeError("boom"))),
    ):
        result = await outfits_module.batch_delete_outfits(
            outfits_module.BatchDeleteOutfitsRequest(outfit_ids=[OUTFIT_ID]),
            user_id=USER_ID,
            db=db,
        )

    assert result["data"]["deleted_count"] == 1


@pytest.mark.asyncio
async def test_batch_delete_outfits_re_raises_validation_error_from_resolver():
    db = _OutfitsFakeDB({"outfits": [_outfit_row()]})

    with patch.object(
        StorageService,
        "resolve_owned_storage_paths",
        new=AsyncMock(side_effect=ValidationError("bad")),
    ):
        with pytest.raises(ValidationError):
            await outfits_module.batch_delete_outfits(
                outfits_module.BatchDeleteOutfitsRequest(outfit_ids=[OUTFIT_ID]),
                user_id=USER_ID,
                db=db,
            )


@pytest.mark.asyncio
async def test_batch_delete_outfits_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfits", {"outfits": [_outfit_row()]})

    with patch.object(StorageService, "resolve_owned_storage_paths", new=AsyncMock(return_value={"storage_paths": []})):
        with pytest.raises(DatabaseError):
            await outfits_module.batch_delete_outfits(
                outfits_module.BatchDeleteOutfitsRequest(outfit_ids=[OUTFIT_ID]),
                user_id=USER_ID,
                db=db,
            )


@pytest.mark.asyncio
async def test_recently_worn_returns_worn_outfits():
    db = _OutfitsFakeDB(
        {
            "outfits": [
                _outfit_row(OUTFIT_ID, last_worn_at="2026-01-05T00:00:00"),
                _outfit_row(OUTFIT_ID_2, last_worn_at="2026-01-02T00:00:00"),
            ]
        }
    )

    result = await outfits_module.recently_worn(limit=2, user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    assert len(result["data"]["outfits"]) == 2


@pytest.mark.asyncio
async def test_recently_worn_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfits")

    with pytest.raises(DatabaseError):
        await outfits_module.recently_worn(user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_favorites_returns_favorite_outfits():
    db = _OutfitsFakeDB({"outfits": [_outfit_row(is_favorite=True), _outfit_row(OUTFIT_ID_2, is_favorite=False)]})

    result = await outfits_module.favorites(user_id=USER_ID, db=db)

    assert result["message"] == "OK"
    assert [o["id"] for o in result["data"]["outfits"]] == [OUTFIT_ID]


@pytest.mark.asyncio
async def test_favorites_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfits")

    with pytest.raises(DatabaseError):
        await outfits_module.favorites(user_id=USER_ID, db=db)


@pytest.mark.asyncio
async def test_weather_suggestions_winter_season_matches_tagged_outfits():
    db = _OutfitsFakeDB(
        {
            "outfits": [
                _outfit_row(OUTFIT_ID, name="Winter coat", tags=["winter"], season="winter"),
                _outfit_row(OUTFIT_ID_2, name="Summer dress", tags=["summer"], season="summer"),
            ]
        }
    )

    result = await outfits_module.weather_suggestions(
        temperature=4.0, weather_condition="Snow", user_id=USER_ID, db=db
    )

    data = result["data"]
    assert [o["name"] for o in data["suggestions"]["outfits"]] == ["Winter coat"]
    assert "winter" in data["suggestions"]["reasoning"]
    assert "Snow" in data["suggestions"]["reasoning"]


@pytest.mark.asyncio
async def test_weather_suggestions_summer_season_without_condition():
    db = _OutfitsFakeDB(
        {
            "outfits": [
                _outfit_row(OUTFIT_ID, name="Summer dress", season="summer"),
                _outfit_row(OUTFIT_ID_2, name="Winter coat", season="winter"),
            ]
        }
    )

    result = await outfits_module.weather_suggestions(
        temperature=30.0, weather_condition=None, user_id=USER_ID, db=db
    )

    data = result["data"]
    assert [o["name"] for o in data["suggestions"]["outfits"]] == ["Summer dress"]
    assert "summer" in data["suggestions"]["reasoning"]
    assert "Condition:" not in data["suggestions"]["reasoning"]


@pytest.mark.asyncio
async def test_weather_suggestions_mild_weather_falls_back_to_all_outfits():
    db = _OutfitsFakeDB(
        {
            "outfits": [
                _outfit_row(OUTFIT_ID, name="Neutral", season="all-season"),
                _outfit_row(OUTFIT_ID_2, name="Spring", season="spring"),
            ]
        }
    )

    result = await outfits_module.weather_suggestions(
        temperature=15.0, weather_condition="Clear", user_id=USER_ID, db=db
    )

    data = result["data"]
    assert [o["name"] for o in data["suggestions"]["outfits"]] == ["Neutral"]
    assert "all-season" in data["suggestions"]["reasoning"]


@pytest.mark.asyncio
async def test_weather_suggestions_with_no_tags_match_returns_any_outfit():
    db = _OutfitsFakeDB(
        {
            "outfits": [
                _outfit_row(OUTFIT_ID, name="Anything", tags=[], season=None),
            ]
        }
    )

    result = await outfits_module.weather_suggestions(
        temperature=2.0, weather_condition=None, user_id=USER_ID, db=db
    )

    assert [o["name"] for o in result["data"]["suggestions"]["outfits"]] == ["Anything"]


@pytest.mark.asyncio
async def test_weather_suggestions_degrades_unexpected_errors_to_database_error():
    db = _RaisingDB("outfits")

    with pytest.raises(DatabaseError):
        await outfits_module.weather_suggestions(temperature=15.0, user_id=USER_ID, db=db)
