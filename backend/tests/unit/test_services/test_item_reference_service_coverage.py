"""Coverage-completing tests for item_reference_service.

The integration tests (test_outfit_item_references.py /
test_outfit_source_reference.py) cover the happy paths with real downscaled
images. These tests fill the remaining edge branches: duplicate item_id
de-duplication, rows with no usable URL, the reference-count cap log,
download exceptions, and the source-photo winner rules that return None.
"""

import asyncio
import logging
from typing import Any, Dict, List, Optional

import pytest

from app.core.config import settings
from app.services import item_reference_service
from app.services.item_reference_service import (
    REFERENCE_KEY,
    resolve_outfit_item_references,
    resolve_outfit_source_reference,
)


class _FakeQuery:
    """Records the filters applied so tests can assert on the user scoping."""

    def __init__(self, rows: List[Dict[str, Any]], captured: Dict[str, Any]):
        self._rows = rows
        self._captured = captured

    def select(self, columns: str):
        self._captured["select"] = columns
        return self

    def eq(self, column: str, value: Any):
        self._captured.setdefault("eq", {})[column] = value
        return self

    def in_(self, column: str, values: List[Any]):
        self._captured.setdefault("in_", {})[column] = list(values)
        return self

    def execute(self):
        eq = self._captured.get("eq", {})
        requested = set(self._captured.get("in_", {}).get("id", []))
        rows = [
            row
            for row in self._rows
            if row["user_id"] == eq.get("user_id") and row["id"] in requested
        ]
        return type(
            "Result",
            (),
            {"data": [{k: v for k, v in r.items() if k != "user_id"} for r in rows]},
        )()


class _FakeDb:
    def __init__(self, rows: List[Dict[str, Any]]):
        self._rows = rows

    def table(self, name: str):
        return _FakeQuery(self._rows, {})


def _item_row(item_id: str, images: List[Dict[str, Any]], user_id: str = "user-1"):
    return {"id": item_id, "user_id": user_id, "item_images": images}


def _source_row(item_id: str, source_image_url: Optional[str], user_id: str = "user-1"):
    return {"id": item_id, "user_id": user_id, "source_image_url": source_image_url}


def _item(item_id: Optional[str], name: str = "item", category: str = "tops"):
    item: Dict[str, Any] = {"name": name, "category": category, "colors": []}
    if item_id is not None:
        item["item_id"] = item_id
    return item


def _install_download(monkeypatch, fn):
    """Replace StorageService.download_and_downscale_to_base64 with ``fn``."""
    monkeypatch.setattr(
        item_reference_service.StorageService,
        "download_and_downscale_to_base64",
        staticmethod(fn),
    )


# ---------------------------------------------------------------------------
# resolve_outfit_item_references
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_dedupes_duplicate_ids_and_skips_url_less_rows(monkeypatch):
    """A repeated item_id must be fetched once; a row whose images carry no
    usable URL resolves to nothing."""
    db = _FakeDb([
        _item_row("item-1", [{"image_url": "https://x.test/a.jpg", "is_primary": True}]),
        _item_row("item-2", [{"image_url": None, "thumbnail_url": None, "is_primary": True}]),
    ])
    downloads: List[str] = []

    async def fake_download(url, **kwargs):
        downloads.append(url)
        return "base64-payload"

    _install_download(monkeypatch, fake_download)

    items, stats = await resolve_outfit_item_references(
        db=db,
        user_id="user-1",
        items=[_item("item-1"), _item("item-1"), _item("item-2")],
    )

    assert stats["with_item_id"] == 3
    assert stats["found_images"] == 1
    assert downloads == ["https://x.test/a.jpg"]  # de-duped: one fetch
    assert REFERENCE_KEY in items[0]
    assert REFERENCE_KEY in items[1]
    assert REFERENCE_KEY not in items[2]


@pytest.mark.asyncio
async def test_skips_references_above_configured_limit(monkeypatch, caplog):
    caplog.set_level(logging.INFO)
    monkeypatch.setattr(settings, "AI_OUTFIT_ITEM_REFERENCE_MAX_IMAGES", 1)
    db = _FakeDb([
        _item_row("item-1", [{"image_url": "https://x.test/1.jpg", "is_primary": True}]),
        _item_row("item-2", [{"image_url": "https://x.test/2.jpg", "is_primary": True}]),
    ])
    downloads: List[str] = []

    async def fake_download(url, **kwargs):
        downloads.append(url)
        return "base64-payload"

    _install_download(monkeypatch, fake_download)

    items, stats = await resolve_outfit_item_references(
        db=db, user_id="user-1", items=[_item("item-1"), _item("item-2")]
    )

    assert stats["skipped_references"] == 1
    assert stats["resolved"] == 1
    assert len(downloads) == 1
    assert any("Skipped outfit item reference images" in r.message for r in caplog.records)


@pytest.mark.asyncio
async def test_download_exception_degrades_only_that_item(monkeypatch, caplog):
    """A raising download is settled as a failure: the item degrades to
    text-only and the failure is logged with the item id."""
    db = _FakeDb([
        _item_row("ok", [{"image_url": "https://x.test/ok.jpg", "is_primary": True}]),
        _item_row("bad", [{"image_url": "https://x.test/bad.jpg", "is_primary": True}]),
    ])

    async def fake_download(url, **kwargs):
        if url.endswith("bad.jpg"):
            raise RuntimeError("net down")
        return "base64-payload"

    _install_download(monkeypatch, fake_download)

    items, stats = await resolve_outfit_item_references(
        db=db, user_id="user-1", items=[_item("ok"), _item("bad")]
    )

    assert stats["download_failed"] == 1
    assert stats["resolved"] == 1
    assert REFERENCE_KEY in items[0]
    assert REFERENCE_KEY not in items[1]
    assert any("failed to load" in r.message for r in caplog.records)


# ---------------------------------------------------------------------------
# resolve_outfit_source_reference
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_source_reference_dedupes_ids_and_resolves_winner(monkeypatch):
    db = _FakeDb([_source_row("item-1", "https://x.test/photo.jpg")])
    downloads: List[str] = []

    async def fake_download(url, **kwargs):
        downloads.append(url)
        return "photo-b64"

    _install_download(monkeypatch, fake_download)

    base64_result, stats = await resolve_outfit_source_reference(
        db=db, user_id="user-1", items=[_item("item-1"), _item("item-1")]
    )

    assert base64_result == "photo-b64"
    assert stats["with_item_id"] == 2
    assert stats["distinct_source_urls"] == 1
    assert stats["resolved"] is True
    assert downloads == ["https://x.test/photo.jpg"]


@pytest.mark.asyncio
async def test_source_reference_no_urls_returns_none(monkeypatch):
    db = _FakeDb([_source_row("item-1", None)])

    base64_result, stats = await resolve_outfit_source_reference(
        db=db, user_id="user-1", items=[_item("item-1")]
    )

    assert base64_result is None
    assert stats["distinct_source_urls"] == 0


@pytest.mark.asyncio
async def test_source_reference_below_min_shared_returns_none(monkeypatch):
    monkeypatch.setattr(settings, "AI_OUTFIT_SOURCE_REFERENCE_MIN_SHARED_ITEMS", 2)
    db = _FakeDb([
        _source_row("item-1", "https://x.test/a.jpg"),
        _source_row("item-2", "https://x.test/b.jpg"),
    ])

    base64_result, stats = await resolve_outfit_source_reference(
        db=db, user_id="user-1", items=[_item("item-1"), _item("item-2")]
    )

    assert base64_result is None
    assert stats["below_min_shared"] is True
    assert stats["candidate_selected"] is False


@pytest.mark.asyncio
async def test_source_reference_max_images_zero_returns_none(monkeypatch):
    monkeypatch.setattr(settings, "AI_OUTFIT_SOURCE_REFERENCE_MAX_IMAGES", 0)
    db = _FakeDb([_source_row("item-1", "https://x.test/photo.jpg")])

    base64_result, stats = await resolve_outfit_source_reference(
        db=db, user_id="user-1", items=[_item("item-1")]
    )

    assert base64_result is None
    assert stats["candidate_selected"] is False


@pytest.mark.asyncio
async def test_source_reference_download_returns_none_payload(monkeypatch):
    db = _FakeDb([_source_row("item-1", "https://x.test/photo.jpg")])

    async def fake_download(url, **kwargs):
        return None

    _install_download(monkeypatch, fake_download)

    base64_result, stats = await resolve_outfit_source_reference(
        db=db, user_id="user-1", items=[_item("item-1")]
    )

    assert base64_result is None
    assert stats["candidate_selected"] is True
    assert stats["download_failed"] is True


@pytest.mark.asyncio
async def test_source_reference_download_exception_returns_none(monkeypatch):
    db = _FakeDb([_source_row("item-1", "https://x.test/photo.jpg")])

    async def fake_download(url, **kwargs):
        raise RuntimeError("storage down")

    _install_download(monkeypatch, fake_download)

    base64_result, stats = await resolve_outfit_source_reference(
        db=db, user_id="user-1", items=[_item("item-1")]
    )

    assert base64_result is None
    assert stats["download_failed"] is True
    assert stats["resolved"] is False


@pytest.mark.asyncio
async def test_source_reference_semaphore_is_shared_module_gate(monkeypatch):
    """The download runs under REFERENCE_DOWNLOAD_SEMAPHORE; replacing the
    module semaphore with a local one must not change the result contract."""
    from app.services.item_reference_service import REFERENCE_DOWNLOAD_SEMAPHORE

    monkeypatch.setattr(
        item_reference_service,
        "REFERENCE_DOWNLOAD_SEMAPHORE",
        asyncio.Semaphore(2),
    )
    db = _FakeDb([_source_row("item-1", "https://x.test/photo.jpg")])

    async def fake_download(url, **kwargs):
        return "photo-b64"

    _install_download(monkeypatch, fake_download)

    base64_result, stats = await resolve_outfit_source_reference(
        db=db, user_id="user-1", items=[_item("item-1")]
    )

    assert base64_result == "photo-b64"
    assert stats["resolved"] is True
    assert REFERENCE_DOWNLOAD_SEMAPHORE.locked() is False
