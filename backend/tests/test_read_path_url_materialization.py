"""Read-path URL materialization tests for items/outfits endpoints.

After the Railway S3 bucket migration the DB stores durable ``storage_path``
keys; every read path that surfaces ``image_url``/``thumbnail_url`` must
regenerate a fresh short-lived presigned URL at read time
(``materialize_image_urls`` in app/api/v1/images.py). These tests pin that
contract on the secondary read paths (search, by-category, favorites,
recently-worn, public share, update responses) that the main list/detail
endpoints do not cover.

Follows the house convention of calling route functions directly with a fake
Supabase client; auth is asserted at the dependency level.
"""
from types import SimpleNamespace
from typing import Any, Dict, Optional
from uuid import UUID

import pytest

from app.api.v1 import items as items_module
from app.api.v1 import outfits as outfits_module
from app.services.storage_service import StorageService

USER_ID = "user-a"
OUTFIT_ID = "11111111-1111-1111-1111-111111111111"


class _Query:
    """Chainable postgrest stub: filter calls are accepted and ignored.

    ``single()`` returns the first row as a dict (postgrest contract) and
    ``update()`` merges its payload into the table rows so follow-up reads see
    the updated values.
    """

    def __init__(self, db: "_DB", table: str):
        self._db = db
        self._table = table
        self._op = "select"
        self._payload: Optional[Dict[str, Any]] = None
        self._single = False

    def select(self, _columns: str = "*", count: Optional[str] = None):
        self._op = "select"
        return self

    def update(self, payload):
        self._op = "update"
        self._payload = payload
        return self

    def _noop(self, *_a, **_k):
        return self

    eq = neq = gte = lte = in_ = order = limit = range = or_ = ilike = is_ = _noop

    @property
    def not_(self):
        return self

    def single(self, *_a, **_k):
        self._single = True
        return self

    maybe_single = single

    def execute(self):
        rows = list(self._db.tables.get(self._table, []))
        if self._op == "update" and self._payload is not None:
            rows = [{**row, **self._payload} for row in rows]
            self._db.tables[self._table] = rows
        if self._single:
            return SimpleNamespace(data=rows[0] if rows else None)
        return SimpleNamespace(data=rows)


class _DB:
    def __init__(self, tables):
        self.tables = tables

    def table(self, table_name):
        return _Query(self, table_name)


def _image(storage_path: Optional[str], stale_url: str, is_primary: bool = True) -> Dict[str, Any]:
    img: Dict[str, Any] = {
        "image_url": stale_url,
        "thumbnail_url": stale_url,
        "is_primary": is_primary,
    }
    if storage_path:
        img["storage_path"] = storage_path
    return img


def _fake_presign(monkeypatch):
    async def _presign(key):
        return f"https://presigned.example/{key}"

    monkeypatch.setattr(StorageService, "get_public_url", staticmethod(_presign))


def _item(
    item_id: str,
    name: str = "Item",
    category: str = "tops",
    storage_path: Optional[str] = "u/items/a.jpg",
) -> Dict[str, Any]:
    return {
        "id": item_id,
        "name": name,
        "category": category,
        "colors": ["black"],
        "is_deleted": False,
        "item_images": [_image(storage_path, "https://stale/a.jpg")],
    }


def _outfit(
    outfit_id: str,
    name: str = "Outfit",
    storage_path: Optional[str] = "u/outfits/o.jpg",
    **extra: Any,
) -> Dict[str, Any]:
    return {
        "id": outfit_id,
        "name": name,
        "is_public": True,
        "is_favorite": True,
        "last_worn_at": "2026-01-05T00:00:00",
        "outfit_images": [_image(storage_path, "https://stale/o.jpg")],
        **extra,
    }


@pytest.mark.asyncio
async def test_items_by_category_materializes_urls(monkeypatch):
    _fake_presign(monkeypatch)
    db = _DB({"items": [_item("i1"), _item("i2", storage_path=None)]})

    result = await items_module.get_items_by_category(category="tops", user_id=USER_ID, db=db)
    items = {i["id"]: i for i in result["data"]["items"]}
    assert items["i1"]["images"][0]["thumbnail_url"] == "https://presigned.example/u/items/a.jpg"
    # Legacy row without storage_path keeps its stored URL.
    assert items["i2"]["images"][0]["image_url"] == "https://stale/a.jpg"


@pytest.mark.asyncio
async def test_search_items_materializes_urls(monkeypatch):
    _fake_presign(monkeypatch)
    db = _DB({"items": [_item("i1")]})

    result = await items_module.search_items(q="item", user_id=USER_ID, db=db)
    item = result["data"]["items"][0]
    assert item["images"][0]["image_url"] == "https://presigned.example/u/items/a.jpg"


@pytest.mark.asyncio
async def test_outfits_favorites_materializes_urls(monkeypatch):
    _fake_presign(monkeypatch)
    db = _DB({"outfits": [_outfit(OUTFIT_ID)]})

    result = await outfits_module.favorites(user_id=USER_ID, db=db)
    outfit = result["data"]["outfits"][0]
    assert outfit["images"][0]["thumbnail_url"] == "https://presigned.example/u/outfits/o.jpg"


@pytest.mark.asyncio
async def test_outfits_recently_worn_materializes_urls(monkeypatch):
    _fake_presign(monkeypatch)
    db = _DB({"outfits": [_outfit(OUTFIT_ID)]})

    result = await outfits_module.recently_worn(user_id=USER_ID, db=db)
    outfit = result["data"]["outfits"][0]
    assert outfit["images"][0]["image_url"] == "https://presigned.example/u/outfits/o.jpg"


@pytest.mark.asyncio
async def test_public_outfit_materializes_shared_image_urls(monkeypatch):
    _fake_presign(monkeypatch)
    db = _DB({"outfits": [_outfit(OUTFIT_ID)], "shared_outfits": []})

    result = await outfits_module.get_public_outfit(outfit_id=UUID(OUTFIT_ID), db=db)
    assert result["data"]["images"][0]["image_url"] == "https://presigned.example/u/outfits/o.jpg"


@pytest.mark.asyncio
async def test_update_outfit_response_materializes_urls(monkeypatch):
    _fake_presign(monkeypatch)
    db = _DB({"outfits": [_outfit(OUTFIT_ID)]})

    result = await outfits_module.update_outfit(
        outfit_id=UUID(OUTFIT_ID),
        update=outfits_module.OutfitUpdate(name="Weekend"),
        user_id=USER_ID,
        db=db,
    )
    outfit = result["data"]
    assert outfit["images"][0]["image_url"] == "https://presigned.example/u/outfits/o.jpg"
    assert outfit["name"] == "Weekend"
