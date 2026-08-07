"""
Tests for ExtractionCacheService (in-memory extraction-result cache).

The process-local ``_cache`` dict is cleared per test. Time is frozen by
monkeypatching the module-level ``utcnow``/``utcnow_iso`` imports so
expiry/hit/miss behavior is deterministic.
"""

import hashlib
from datetime import datetime, timedelta, timezone
from unittest.mock import AsyncMock

import pytest

from app.services import extraction_cache_service as svc
from app.services.extraction_cache_service import ExtractionCacheService

FROZEN_NOW = datetime(2026, 1, 15, 12, 0, 0, tzinfo=timezone.utc)


@pytest.fixture(autouse=True)
def _reset_cache():
    """Each test starts (and ends) with an empty process-local cache."""
    svc._cache.clear()
    yield
    svc._cache.clear()


def _cache_key(user_id: str, image: str) -> str:
    digest = hashlib.sha256(image.encode("utf-8")).hexdigest()
    return f"{user_id}:{digest}"


# ---------------------------------------------------------------------------
# Hashing
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_hash_image_strips_data_url_prefix():
    content = "aGVsbG8="
    digest = await ExtractionCacheService._hash_image(f"data:image/png;base64,{content}")

    assert digest == hashlib.sha256(content.encode("utf-8")).hexdigest()


@pytest.mark.asyncio
async def test_hash_image_without_prefix_hashes_full_string():
    content = "raw-base64-no-prefix"
    digest = await ExtractionCacheService._hash_image(content)

    assert digest == hashlib.sha256(content.encode("utf-8")).hexdigest()


@pytest.mark.asyncio
async def test_hash_image_large_payload_hashes_incrementally():
    # > 65536 chars forces the incremental 64KB-window loop to iterate twice.
    content = "x" * 200_000
    digest = await ExtractionCacheService._hash_image(content)

    assert digest == hashlib.sha256(content.encode("utf-8")).hexdigest()


# ---------------------------------------------------------------------------
# Reads
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_cached_result_miss_returns_none(monkeypatch):
    monkeypatch.setattr(svc, "utcnow", lambda: FROZEN_NOW)

    assert await ExtractionCacheService.get_cached_result("img", "u1") is None


@pytest.mark.asyncio
async def test_get_cached_result_hit_returns_stored_result(monkeypatch):
    monkeypatch.setattr(svc, "utcnow", lambda: FROZEN_NOW)
    key = _cache_key("u1", "img")
    svc._cache[key] = {
        "result": {"items": [{"id": 1}]},
        "expiry": (FROZEN_NOW + timedelta(hours=1)).isoformat(),
        "cached_at": FROZEN_NOW.isoformat(),
    }

    result = await ExtractionCacheService.get_cached_result("img", "u1")

    assert result == {"items": [{"id": 1}]}


@pytest.mark.asyncio
async def test_get_cached_result_hit_without_items_field(monkeypatch):
    monkeypatch.setattr(svc, "utcnow", lambda: FROZEN_NOW)
    key = _cache_key("u1", "img")
    svc._cache[key] = {
        "result": {"note": "no items"},
        "expiry": (FROZEN_NOW + timedelta(hours=1)).isoformat(),
        "cached_at": FROZEN_NOW.isoformat(),
    }

    assert await ExtractionCacheService.get_cached_result("img", "u1") == {
        "note": "no items"
    }


@pytest.mark.asyncio
async def test_get_cached_result_coerces_naive_expiry(monkeypatch):
    """Pre-UTC-migration entries store naive ISO expiry; they must be
    coerced to aware so the expiry comparison does not raise."""
    monkeypatch.setattr(svc, "utcnow", lambda: FROZEN_NOW)
    key = _cache_key("u1", "img")
    svc._cache[key] = {
        "result": {"items": []},
        "expiry": (FROZEN_NOW + timedelta(hours=2)).replace(tzinfo=None).isoformat(),
        "cached_at": "2026-01-15T10:00:00",
    }

    assert await ExtractionCacheService.get_cached_result("img", "u1") == {"items": []}


@pytest.mark.asyncio
async def test_get_cached_result_expired_removes_entry(monkeypatch):
    monkeypatch.setattr(svc, "utcnow", lambda: FROZEN_NOW)
    key = _cache_key("u1", "img")
    svc._cache[key] = {
        "result": {"items": []},
        "expiry": (FROZEN_NOW - timedelta(seconds=1)).isoformat(),
        "cached_at": "2026-01-14T00:00:00+00:00",
    }

    assert await ExtractionCacheService.get_cached_result("img", "u1") is None
    assert key not in svc._cache


@pytest.mark.asyncio
async def test_get_cached_result_corrupt_expiry_returns_none(monkeypatch):
    monkeypatch.setattr(svc, "utcnow", lambda: FROZEN_NOW)
    key = _cache_key("u1", "img")
    svc._cache[key] = {
        "result": {"items": []},
        "expiry": "not-a-date",
        "cached_at": "2026-01-14T00:00:00+00:00",
    }

    assert await ExtractionCacheService.get_cached_result("img", "u1") is None
    # The corrupt entry is left in place: only real expiry evicts.
    assert key in svc._cache


@pytest.mark.asyncio
async def test_get_cached_result_hash_error_returns_none(monkeypatch):
    monkeypatch.setattr(
        ExtractionCacheService,
        "_hash_image",
        AsyncMock(side_effect=RuntimeError("boom")),
    )

    assert await ExtractionCacheService.get_cached_result("img", "u1") is None


# ---------------------------------------------------------------------------
# Writes
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_set_cached_result_stores_entry_with_ttl(monkeypatch):
    monkeypatch.setattr(svc, "utcnow", lambda: FROZEN_NOW)
    monkeypatch.setattr(svc, "utcnow_iso", lambda: FROZEN_NOW.isoformat())

    await ExtractionCacheService.set_cached_result("img", "u1", {"items": [1, 2]})

    entry = svc._cache[_cache_key("u1", "img")]
    assert entry["result"] == {"items": [1, 2]}
    assert entry["expiry"] == (FROZEN_NOW + timedelta(hours=24)).isoformat()
    assert entry["cached_at"] == FROZEN_NOW.isoformat()


@pytest.mark.asyncio
async def test_set_cached_result_evicts_oldest_when_over_cap(monkeypatch):
    monkeypatch.setattr(ExtractionCacheService, "MAX_ENTRIES", 3)
    monkeypatch.setattr(svc, "utcnow", lambda: FROZEN_NOW)
    monkeypatch.setattr(svc, "utcnow_iso", lambda: FROZEN_NOW.isoformat())
    svc._cache.update(
        {
            "oldest": {
                "result": {},
                "expiry": "2026-01-15T13:00:00+00:00",
                "cached_at": "2026-01-15T09:00:00+00:00",
            },
            "middle": {
                "result": {},
                "expiry": "2026-01-15T13:00:00+00:00",
                "cached_at": "2026-01-15T10:00:00+00:00",
            },
            "newest": {
                "result": {},
                "expiry": "2026-01-15T13:00:00+00:00",
                "cached_at": "2026-01-15T11:00:00+00:00",
            },
        }
    )

    await ExtractionCacheService.set_cached_result("img", "u1", {"items": []})

    assert len(svc._cache) == 3
    assert "oldest" not in svc._cache  # LRU-by-age eviction dropped it
    assert _cache_key("u1", "img") in svc._cache


@pytest.mark.asyncio
async def test_set_cached_result_error_is_swallowed(monkeypatch):
    monkeypatch.setattr(
        ExtractionCacheService,
        "_hash_image",
        AsyncMock(side_effect=RuntimeError("boom")),
    )

    await ExtractionCacheService.set_cached_result("img", "u1", {"items": []})

    assert svc._cache == {}
