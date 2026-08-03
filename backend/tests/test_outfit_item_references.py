"""
Tests for item_reference_service.resolve_outfit_item_references: turning the
item_ids on a generate-outfit request into the items' own images, which the
image agent then sends as garment references.

The security property under test is that images are only ever resolved through
the caller's own items rows - item_images has no user_id column, so the
.eq("user_id", ...) filter on the parent table is the entire boundary.
"""

import asyncio
import base64
import io
from typing import Any, Dict, List, Optional

import pytest
from PIL import Image

from app.core.config import settings
from app.services import item_reference_service
from app.services.item_reference_service import (
    REFERENCE_KEY,
    resolve_outfit_item_references,
)


def _make_image_b64(size=(2000, 2000)) -> str:
    img = Image.new("RGB", size, (120, 30, 40))
    buf = io.BytesIO()
    img.save(buf, format="JPEG", quality=90)
    return base64.b64encode(buf.getvalue()).decode("utf-8")


def _longest_edge(image_b64: str) -> int:
    with Image.open(io.BytesIO(base64.b64decode(image_b64))) as img:
        return max(img.size)


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
        # Mimic the real client: the user_id column is a filter, not a result
        # column, so it is not selected back.
        return type(
            "Result", (), {"data": [{k: v for k, v in r.items() if k != "user_id"} for r in rows]}
        )()


class _FakeDb:
    def __init__(self, rows: List[Dict[str, Any]]):
        self._rows = rows
        self.captured: Dict[str, Any] = {}
        self.table_calls: List[str] = []

    def table(self, name: str):
        self.table_calls.append(name)
        return _FakeQuery(self._rows, self.captured)


def _row(item_id: str, images: List[Dict[str, Any]], user_id: str = "user-1"):
    return {"id": item_id, "user_id": user_id, "item_images": images}


def _item(item_id: Optional[str], name: str = "item", category: str = "tops"):
    item: Dict[str, Any] = {"name": name, "category": category, "colors": []}
    if item_id is not None:
        item["item_id"] = item_id
    return item


@pytest.fixture
def stub_download(monkeypatch):
    """Map url -> base64 (or None to simulate a failed download)."""

    def _install(by_url: Dict[str, Optional[str]]):
        from app.utils.image_processing import (
            DEFAULT_MAX_EDGE,
            DEFAULT_QUALITY,
            downscale_base64_image,
        )

        async def fake_download(
            url: str,
            max_edge: int = DEFAULT_MAX_EDGE,
            quality: int = DEFAULT_QUALITY,
            timeout: float = 10.0,
        ):
            payload = by_url.get(url)
            if payload is None:
                return None
            # The production path downsizes during the download (see
            # StorageService.download_and_downscale_to_base64); mirror that so
            # size assertions (test_references_are_downscaled) hold.
            return downscale_base64_image(payload, max_edge=max_edge, quality=quality)

        monkeypatch.setattr(
            item_reference_service.StorageService,
            "download_and_downscale_to_base64",
            staticmethod(fake_download),
        )

    return _install


@pytest.mark.asyncio
async def test_prefers_primary_image_and_full_url_over_thumbnail(stub_download):
    """The primary image wins over a non-primary one, and image_url wins over
    thumbnail_url - thumbnails are sized for grid tiles and are too low-res to
    carry print, weave, and hardware detail."""
    db = _FakeDb([
        _row(
            "item-1",
            [
                {"image_url": "https://x.test/secondary.jpg", "thumbnail_url": None, "is_primary": False},
                {
                    "image_url": "https://x.test/primary.jpg",
                    "thumbnail_url": "https://x.test/primary-thumb.jpg",
                    "is_primary": True,
                },
            ],
        )
    ])
    stub_download({"https://x.test/primary.jpg": _make_image_b64((400, 400))})

    items, stats = await resolve_outfit_item_references(
        db=db, user_id="user-1", items=[_item("item-1")]
    )

    assert items[0][REFERENCE_KEY]
    assert stats["resolved"] == 1
    assert stats["found_images"] == 1


@pytest.mark.asyncio
async def test_scopes_query_to_caller_and_ignores_other_users_items(stub_download):
    """Another user's item_id resolves to nothing: no reference, no error, no
    leak. The user_id filter is asserted directly because it is the only thing
    enforcing ownership."""
    db = _FakeDb([
        _row("mine", [{"image_url": "https://x.test/mine.jpg", "is_primary": True}], user_id="user-1"),
        _row("theirs", [{"image_url": "https://x.test/theirs.jpg", "is_primary": True}], user_id="user-2"),
    ])
    stub_download({
        "https://x.test/mine.jpg": _make_image_b64((400, 400)),
        "https://x.test/theirs.jpg": _make_image_b64((400, 400)),
    })

    items, stats = await resolve_outfit_item_references(
        db=db, user_id="user-1", items=[_item("mine"), _item("theirs")]
    )

    assert db.captured["eq"]["user_id"] == "user-1"
    assert db.captured["in_"]["id"] == ["mine", "theirs"]
    assert items[0][REFERENCE_KEY]
    assert REFERENCE_KEY not in items[1]
    assert stats["resolved"] == 1


@pytest.mark.asyncio
async def test_preserves_order_and_leaves_items_without_item_id_untouched(stub_download):
    """Order is the contract: the agent numbers its "IMAGE n" prompt labels off
    this list."""
    db = _FakeDb([
        _row("a", [{"image_url": "https://x.test/a.jpg", "is_primary": True}]),
        _row("c", [{"image_url": "https://x.test/c.jpg", "is_primary": True}]),
    ])
    stub_download({
        "https://x.test/a.jpg": _make_image_b64((300, 300)),
        "https://x.test/c.jpg": _make_image_b64((300, 300)),
    })

    original = [_item("a", "first"), _item(None, "second"), _item("c", "third")]
    items, stats = await resolve_outfit_item_references(
        db=db, user_id="user-1", items=original
    )

    assert [i["name"] for i in items] == ["first", "second", "third"]
    assert REFERENCE_KEY in items[0]
    assert REFERENCE_KEY not in items[1]
    assert REFERENCE_KEY in items[2]
    assert stats["with_item_id"] == 2
    # Input list is never mutated in place.
    assert all(REFERENCE_KEY not in i for i in original)


@pytest.mark.asyncio
async def test_failed_download_degrades_only_that_item(stub_download):
    db = _FakeDb([
        _row("ok", [{"image_url": "https://x.test/ok.jpg", "is_primary": True}]),
        _row("bad", [{"image_url": "https://x.test/bad.jpg", "is_primary": True}]),
    ])
    stub_download({
        "https://x.test/ok.jpg": _make_image_b64((300, 300)),
        "https://x.test/bad.jpg": None,
    })

    items, stats = await resolve_outfit_item_references(
        db=db, user_id="user-1", items=[_item("ok"), _item("bad")]
    )

    assert REFERENCE_KEY in items[0]
    assert REFERENCE_KEY not in items[1]
    assert stats["download_failed"] == 1
    assert stats["resolved"] == 1


@pytest.mark.asyncio
async def test_references_are_downscaled(stub_download):
    db = _FakeDb([_row("item-1", [{"image_url": "https://x.test/big.jpg", "is_primary": True}])])
    stub_download({"https://x.test/big.jpg": _make_image_b64((2000, 1500))})

    items, _ = await resolve_outfit_item_references(
        db=db, user_id="user-1", items=[_item("item-1")], max_edge=768
    )

    assert _longest_edge(items[0][REFERENCE_KEY]) <= 768


@pytest.mark.asyncio
async def test_no_cap_every_item_with_an_image_gets_a_reference(stub_download):
    """Reference count is deliberately uncapped - a 12-item outfit sends 12."""
    ids = [f"item-{n}" for n in range(12)]
    db = _FakeDb([
        _row(item_id, [{"image_url": f"https://x.test/{item_id}.jpg", "is_primary": True}])
        for item_id in ids
    ])
    stub_download({f"https://x.test/{item_id}.jpg": _make_image_b64((300, 300)) for item_id in ids})

    items, stats = await resolve_outfit_item_references(
        db=db, user_id="user-1", items=[_item(item_id) for item_id in ids]
    )

    assert stats["resolved"] == 12
    assert all(REFERENCE_KEY in item for item in items)


@pytest.mark.asyncio
async def test_downloads_are_concurrency_bounded(monkeypatch):
    """Downloads remain bounded independently of the reference count."""
    ids = [f"item-{n}" for n in range(40)]
    monkeypatch.setattr(settings, "AI_OUTFIT_ITEM_REFERENCE_MAX_IMAGES", 40)
    # pytest-asyncio gives each test its own loop; replace the process-wide
    # production semaphore for this isolated loop rather than exercising
    # cross-loop asyncio.Semaphore behavior.
    monkeypatch.setattr(item_reference_service, "REFERENCE_DOWNLOAD_SEMAPHORE", asyncio.Semaphore(8))
    db = _FakeDb([
        _row(item_id, [{"image_url": f"https://x.test/{item_id}.jpg", "is_primary": True}])
        for item_id in ids
    ])
    payload = _make_image_b64((200, 200))

    in_flight = 0
    peak = 0

    async def fake_download(
        url: str,
        max_edge: int = 1568,
        quality: int = 85,
        timeout: float = 10.0,
    ):
        nonlocal in_flight, peak
        in_flight += 1
        peak = max(peak, in_flight)
        try:
            # Yield so every already-admitted coroutine can pile up first.
            await asyncio.sleep(0)
            return payload
        finally:
            in_flight -= 1

    monkeypatch.setattr(
        item_reference_service.StorageService,
        "download_and_downscale_to_base64",
        staticmethod(fake_download),
    )

    _, stats = await resolve_outfit_item_references(
        db=db, user_id="user-1", items=[_item(item_id) for item_id in ids]
    )

    assert stats["resolved"] == 40
    assert peak <= 8


@pytest.mark.asyncio
async def test_no_item_ids_skips_the_database_entirely(stub_download):
    db = _FakeDb([])
    stub_download({})

    items, stats = await resolve_outfit_item_references(
        db=db, user_id="user-1", items=[_item(None), _item(None)]
    )

    assert db.table_calls == []
    assert stats["with_item_id"] == 0
    assert stats["resolved"] == 0
    assert all(REFERENCE_KEY not in item for item in items)


@pytest.mark.asyncio
async def test_items_with_no_stored_image_degrade_quietly(stub_download):
    db = _FakeDb([_row("item-1", [])])
    stub_download({})

    items, stats = await resolve_outfit_item_references(
        db=db, user_id="user-1", items=[_item("item-1")]
    )

    assert REFERENCE_KEY not in items[0]
    assert stats["found_images"] == 0
    assert stats["resolved"] == 0


@pytest.mark.asyncio
async def test_query_failure_falls_back_to_text_only(stub_download, monkeypatch):
    """A DB hiccup must not fail the generation - it degrades to the text-only
    inventory, which is what the endpoint did before references existed."""

    class _ExplodingDb:
        def table(self, name):
            raise RuntimeError("supabase down")

    stub_download({})
    items, stats = await resolve_outfit_item_references(
        db=_ExplodingDb(), user_id="user-1", items=[_item("item-1")]
    )

    assert REFERENCE_KEY not in items[0]
    assert stats["query_failed"] is True
