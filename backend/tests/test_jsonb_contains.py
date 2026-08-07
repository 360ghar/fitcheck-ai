"""JSONB containment (`@>` / `cs`) encoding for the items/outfits filters.

Regression for 2026-08-07: `GET /items?occasion=informal` 500ed on every poll.
`contains(column, [x])` with a LIST argument makes postgrest-py emit a
Postgres ARRAY literal (`{x}`), which is only valid for native array columns.
The `occasion_tags` / `colors` / `tags` columns are JSONB, so PostgREST casts
the literal to jsonb and answers 22P02 "invalid input syntax for type jsonb".
The retry wrapper then misclassified that deterministic query error as a dead
pooled connection (the error text contains the `invalid input` marker) and
burned 2 client rebuilds + 3 attempts before 500ing. `jsonb_contains` encodes
the value as a JSON array literal (`["x"]`) so `@> '["x"]'::jsonb` is valid.
"""
import asyncio
from unittest.mock import Mock

import pytest
from supabase import create_client

from app.api.v1 import items as items_module
from app.utils.db import jsonb_contains

USER_ID = "11111111-1111-1111-1111-111111111111"


def _query_params(builder):
    """The raw URL query string of a built (never executed) postgrest query."""
    from urllib.parse import unquote_plus

    return unquote_plus(str(builder.request.params))


def _dummy_client():
    return create_client("https://example.supabase.co", "dummy-key")


def test_jsonb_contains_emits_json_array_literal():
    """The helper must produce `cs.["informal"]` (JSON array literal), never
    `cs.{informal}` (Postgres array literal) - for every JSONB column the
    routes filter on."""
    db = _dummy_client()

    q = jsonb_contains(db.table("items").select("*"), "occasion_tags", ["informal"])
    assert "occasion_tags=cs.[\"informal\"]" in _query_params(q)

    q = jsonb_contains(db.table("items").select("*"), "colors", ["red"])
    assert "colors=cs.[\"red\"]" in _query_params(q)

    q = jsonb_contains(db.table("outfits").select("*"), "tags", ["work", "smart"])
    # json.dumps inserts a space after the comma; valid JSON either way.
    assert "tags=cs.[\"work\", \"smart\"]" in _query_params(q)


def test_plain_contains_list_emits_array_literal():
    """Document the hazard the helper exists to avoid: postgrest-py's list
    branch emits `{informal}`, which a JSONB column cannot cast."""
    db = _dummy_client()
    q = db.table("items").select("*").contains("occasion_tags", ["informal"])
    assert "occasion_tags=cs.{informal}" in _query_params(q)


@pytest.mark.asyncio
async def test_list_items_occasion_and_color_filters_build_valid_contains(monkeypatch):
    """Full route wiring: with `occasion=informal&color=red`, BOTH the count
    and the page query carry valid JSONB containment literals.

    The built (never executed) query chains are captured by faking
    `asyncio.to_thread`; the bound `.execute` method's `__self__` exposes the
    request builder so we can assert the exact URL params the filter applied.
    """
    captured = []

    async def fake_to_thread(fn, *args, **kwargs):
        captured.append(fn)
        return Mock(data=[], count=0)

    async def fake_execute_with_reconnect(fn, db, **kwargs):
        # Run the real _list_and_count builder so the filter chain executes.
        return await fn(db)

    class _ScopedAsyncio:
        """Fake `asyncio.to_thread` ONLY for items.py's lookups.

        Patching `items_module.asyncio.to_thread` directly would mutate the
        shared `asyncio` module for the whole test process; delegating every
        other attribute keeps the fake scoped to this module under test."""

        def __getattr__(self, name):
            if name == "to_thread":
                return fake_to_thread
            return getattr(asyncio, name)

    monkeypatch.setattr(items_module, "asyncio", _ScopedAsyncio())
    monkeypatch.setattr(items_module, "execute_with_reconnect", fake_execute_with_reconnect)

    await items_module.list_items(
        page=1,
        page_size=24,
        category=None,
        color="red",
        occasion="informal",
        condition=None,
        brand=None,
        search=None,
        is_favorite=None,
        user_id=USER_ID,
        db=_dummy_client(),
    )

    # Two queries per request: count (index 0) and page (index 1).
    assert len(captured) == 2
    for fn in captured:
        params = _query_params(fn.__self__)
        assert "occasion_tags=cs.[\"informal\"]" in params, params
        assert "colors=cs.[\"red\"]" in params, params
        assert "cs.{informal}" not in params, params
        assert "cs.{red}" not in params, params
