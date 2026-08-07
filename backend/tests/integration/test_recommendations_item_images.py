"""Unit tests for recommendation item image normalization helpers.

Imports production helpers so tests fail if implementation drifts.
"""
from types import SimpleNamespace
from typing import Any, Dict, List

import pytest

from app.api.v1.recommendations import (
    MatchRequest,
    _materialize_item_images,
    _prepare_item_for_response,
    match_items,
)
from app.services.storage_service import StorageService


def test_prepare_item_maps_item_images_to_images_and_image_url():
    raw = {
        "id": "item-1",
        "name": "Blue Tee",
        "category": "tops",
        "item_images": [
            {
                "id": "img-1",
                "image_url": "https://cdn.example/full.jpg",
                "thumbnail_url": "https://cdn.example/thumb.jpg",
                "is_primary": True,
            }
        ],
    }
    out = _prepare_item_for_response(raw)
    assert "images" in out
    assert len(out["images"]) == 1
    assert out["images"][0]["image_url"] == "https://cdn.example/full.jpg"
    assert out["image_url"] == "https://cdn.example/thumb.jpg"
    assert "item_images" not in out


def test_prepare_item_handles_missing_images():
    out = _prepare_item_for_response({"id": "item-2", "name": "No Photo", "category": "bottoms"})
    assert out["images"] == []
    assert "image_url" not in out


def test_prepare_item_prefers_existing_images_over_empty_item_images():
    raw = {
        "id": "item-3",
        "name": "Jacket",
        "category": "outerwear",
        "images": [
            {
                "id": "img-2",
                "image_url": "https://cdn.example/jacket.jpg",
                "is_primary": True,
            }
        ],
        "item_images": [],
    }
    # pop empty item_images leaves images list from existing field
    out = _prepare_item_for_response(raw)
    assert len(out["images"]) == 1
    assert out["image_url"] == "https://cdn.example/jacket.jpg"


class _Query:
    """Chainable postgrest stub for the match endpoint's read shape."""

    def __init__(self, db: "_DB", table: str):
        self._db = db
        self._table = table

    def select(self, *_a, **_k):
        return self

    def eq(self, *_a, **_k):
        return self

    def in_(self, *_a, **_k):
        return self

    @property
    def not_(self):
        return self

    def limit(self, _n):
        return self

    def execute(self):
        return SimpleNamespace(data=self._db.tables.get(self._table, []))


class _DB:
    def __init__(self, tables):
        self.tables = tables

    def table(self, name):
        return _Query(self, name)


def _item(
    item_id: str,
    name: str,
    category: str,
    images: List[Dict[str, Any]],
) -> Dict[str, Any]:
    return {
        "id": item_id,
        "name": name,
        "category": category,
        "colors": ["black"],
        "item_images": images,
    }


@pytest.mark.asyncio
async def test_match_items_materializes_presigned_image_urls(monkeypatch):
    """Match results must carry fresh presigned URLs from storage_path, never
    the stale stored values (same contract as the items list endpoints)."""
    async def _fake_presign(key):
        return f"https://presigned.example/{key}"

    monkeypatch.setattr(StorageService, "get_public_url", staticmethod(_fake_presign))

    db = _DB(
        {
            "items": [
                _item(
                    "src-1",
                    "Black tee",
                    "tops",
                    [{"storage_path": "u/src-1.jpg", "image_url": "https://stale/1.jpg", "thumbnail_url": "https://stale/1-t.jpg", "is_primary": True}],
                ),
                _item(
                    "cand-1",
                    "Black jeans",
                    "bottoms",
                    [{"storage_path": "u/cand-1.jpg", "image_url": "https://stale/2.jpg", "thumbnail_url": "https://stale/2-t.jpg", "is_primary": True}],
                ),
            ]
        }
    )

    result = await match_items(
        MatchRequest(item_ids=["src-1"]),
        user_id="user-a",
        db=db,
        # Direct route-function call: FastAPI Query() defaults are not
        # evaluated, so pass concrete values explicitly.
        limit=10,
        min_score=0,
    )
    matches = result["data"]["matches"]
    assert matches, "expected at least one scored match"
    matched = matches[0]["item"]
    assert matched["image_url"] == "https://presigned.example/u/cand-1.jpg"


@pytest.mark.asyncio
async def test_materialize_item_images_keeps_legacy_rows_unchanged(monkeypatch):
    """Rows without storage_path must keep their stored URL untouched."""
    async def _fail_presign(key):
        pytest.fail(f"must not presign legacy row {key}")

    monkeypatch.setattr(StorageService, "get_public_url", staticmethod(_fail_presign))

    legacy = [{"item_images": [{"image_url": "https://cdn/legacy.jpg", "thumbnail_url": "https://cdn/legacy-t.jpg", "is_primary": True}]}]
    out = await _materialize_item_images(legacy)
    assert out[0]["item_images"][0]["image_url"] == "https://cdn/legacy.jpg"
    assert out[0]["item_images"][0]["thumbnail_url"] == "https://cdn/legacy-t.jpg"
