"""Filter handling in GET /items.

An unknown `category`/`condition` value is dropped rather than 422'd so a stale
or typo'd browse filter never hard-fails the page. The trap that behaviour fell
into: when EVERY supplied value was unknown the filter became `None` and the
query ran completely unfiltered, so the endpoint answered 200 with the user's
entire wardrobe while the UI still showed the filter chip as active. Wrong data
that looks authoritative is worse than an error, so an all-invalid filter now
returns an empty page and reports what it ignored.
"""
from unittest.mock import Mock

import pytest

from app.api.v1 import items as items_module

USER_ID = "11111111-1111-1111-1111-111111111111"


def _unusable_db():
    """A db that raises if the handler touches it.

    The all-invalid path must short-circuit BEFORE any query — that is the whole
    point of the fix, and it keeps this test free of postgrest plumbing.
    """
    db = Mock()
    db.table.side_effect = AssertionError(
        "list_items must not query when every filter value is invalid"
    )
    return db


@pytest.mark.asyncio
async def test_all_invalid_categories_return_an_empty_page():
    result = await items_module.list_items(
        page=1,
        page_size=20,
        category="shoez,not-a-category",
        color=None,
        occasion=None,
        condition=None,
        brand=None,
        search=None,
        is_favorite=None,
        user_id=USER_ID,
        db=_unusable_db(),
    )

    data = result["data"]
    assert data["items"] == []
    assert data["total"] == 0
    assert data["has_next"] is False
    # The client can tell "nothing matched" from "your filter was not understood".
    assert data["ignored_filters"]["category"] == ["shoez", "not-a-category"]


@pytest.mark.asyncio
async def test_invalid_condition_returns_an_empty_page():
    result = await items_module.list_items(
        page=1,
        page_size=20,
        category=None,
        color=None,
        occasion=None,
        condition="mint-in-box",
        brand=None,
        search=None,
        is_favorite=None,
        user_id=USER_ID,
        db=_unusable_db(),
    )

    assert result["data"]["items"] == []
    assert result["data"]["ignored_filters"]["condition"] == ["mint-in-box"]


@pytest.mark.asyncio
async def test_page_two_of_an_empty_result_keeps_has_prev():
    result = await items_module.list_items(
        page=3,
        page_size=20,
        category="nope",
        color=None,
        occasion=None,
        condition=None,
        brand=None,
        search=None,
        is_favorite=None,
        user_id=USER_ID,
        db=_unusable_db(),
    )

    assert result["data"]["page"] == 3
    assert result["data"]["has_prev"] is True
    assert result["data"]["has_next"] is False


@pytest.mark.asyncio
async def test_partially_valid_category_filter_still_queries(monkeypatch):
    """A mix of valid and invalid values keeps the valid ones and reports the
    rest — the page is real, not empty."""
    valid = sorted(items_module.VALID_CATEGORIES)[0]
    captured = {}

    async def fake_execute_with_reconnect(fn, db, **kwargs):
        captured["ran"] = True
        return 0, Mock(data=[])

    monkeypatch.setattr(
        items_module, "execute_with_reconnect", fake_execute_with_reconnect
    )

    result = await items_module.list_items(
        page=1,
        page_size=20,
        category=f"{valid},bogus",
        color=None,
        occasion=None,
        condition=None,
        brand=None,
        search=None,
        is_favorite=None,
        user_id=USER_ID,
        db=Mock(),
    )

    assert captured.get("ran") is True
    assert result["data"]["ignored_filters"]["category"] == ["bogus"]


@pytest.mark.asyncio
async def test_no_filter_reports_no_ignored_values(monkeypatch):
    async def fake_execute_with_reconnect(fn, db, **kwargs):
        return 0, Mock(data=[])

    monkeypatch.setattr(
        items_module, "execute_with_reconnect", fake_execute_with_reconnect
    )

    result = await items_module.list_items(
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

    assert result["data"]["ignored_filters"] == {}
