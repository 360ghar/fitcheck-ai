"""Aggregation behavior of GET /items/stats.

The endpoint pushes the most/least-worn extremes into SQL (ORDER BY + LIMIT)
instead of sorting up to 1000 rows in Python, reads the total from a
``count="exact"`` query, and reads the category/condition/color/value rollup
from the ``get_item_stats_aggregate`` RPC (migration 064) instead of a
1000-row Python loop. These tests lock the response shape and the exact
ordering contract (NULL wear counts must rank as "never worn", never first).
"""
from unittest.mock import Mock

import pytest

from app.api.v1 import items as items_module

USER_ID = "11111111-1111-1111-1111-111111111111"


def _stats_mock_db(*, count=3, agg_payload=None, worn_rows=None, rpc_missing=False):
    """Wire the stats reads to canned results.

    MagicMock returns the same chain for every call, so the count query
    (select -> eq -> execute) and the extremes queries (select -> eq ->
    order -> limit -> execute) are distinguished by which mock attribute
    they end on. The aggregate arrives via db.rpc(...).execute.
    """
    db = Mock()
    eq_chain = db.table.return_value.select.return_value.eq.return_value
    eq_chain.execute.return_value = Mock(data=[], count=count)
    eq_chain.order.return_value.limit.return_value.execute.return_value = Mock(
        data=worn_rows or []
    )
    if rpc_missing:
        db.rpc.return_value.execute.side_effect = RuntimeError(
            "PGRST202 could not find the function "
            "public.get_item_stats_aggregate in the schema cache"
        )
    else:
        db.rpc.return_value.execute.return_value = Mock(
            data=[{"get_item_stats_aggregate": agg_payload or {}}]
        )
    return db


@pytest.mark.asyncio
async def test_stats_aggregates_histograms_and_extremes():
    agg_payload = {
        "total_items": 3,
        "items_by_category": {"tops": 2, "other": 1},
        "items_by_condition": {"good": 2, "clean": 1},
        "items_by_color": {"black": 1, "white": 1, "blue": 1},
        "total_value": 35.5,
    }
    worn_rows = [
        {"id": "1", "name": "White tee", "usage_times_worn": 12},
        {"id": "2", "name": "Never worn", "usage_times_worn": None},
    ]
    db = _stats_mock_db(count=3, agg_payload=agg_payload, worn_rows=worn_rows)

    result = await items_module.get_item_stats(user_id=USER_ID, db=db)

    data = result["data"]
    assert data["total_items"] == 3
    assert data["items_by_category"] == {"tops": 2, "other": 1}
    assert data["items_by_condition"] == {"good": 2, "clean": 1}
    assert data["items_by_color"] == {"black": 1, "white": 1, "blue": 1}
    assert data["total_value"] == 35.5
    # A NULL wear count is reported as 0, never as a "most worn" leader.
    assert data["most_worn_items"][0] == {"id": "1", "name": "White tee", "times_worn": 12}
    assert {"id": "2", "name": "Never worn", "times_worn": 0} in data["most_worn_items"]
    # The rollup goes through the RPC, not a 1000-row table fetch.
    assert db.rpc.call_args[0][0] == "get_item_stats_aggregate"


@pytest.mark.asyncio
async def test_stats_falls_back_to_python_rollup_when_rpc_missing():
    """Migration-gap fallback: without migration 064 the endpoint degrades to
    the legacy Python rollup instead of 500ing (mirrors the mark_worn PGRST202
    fallback policy)."""
    agg_rows = [
        {"category": "tops", "colors": ["Black", "White"], "condition": "good", "price": 25.5},
        {"category": "Tops", "colors": [], "condition": "good", "price": None},
        {"category": None, "colors": ["Blue"], "condition": None, "price": "10"},
    ]
    db = _stats_mock_db(count=3, rpc_missing=True)
    eq_chain = db.table.return_value.select.return_value.eq.return_value
    eq_chain.limit.return_value.execute.return_value = Mock(data=agg_rows)

    result = await items_module.get_item_stats(user_id=USER_ID, db=db)

    data = result["data"]
    assert data["total_items"] == 3
    # Category/condition names are normalized to lowercase; unknown -> "other".
    assert data["items_by_category"] == {"tops": 2, "other": 1}
    assert data["items_by_condition"] == {"good": 2, "clean": 1}
    assert data["items_by_color"] == {"black": 1, "white": 1, "blue": 1}
    assert data["total_value"] == 35.5


@pytest.mark.asyncio
async def test_stats_extreme_queries_request_nullslast_ordering():
    """The SQL pushdown must not reintroduce Postgres's NULLs-first DESC trap."""
    db = _stats_mock_db(
        count=0,
        worn_rows=[],
        agg_payload={
            "total_items": 0,
            "items_by_category": {},
            "items_by_condition": {},
            "items_by_color": {},
            "total_value": 0,
        },
    )

    await items_module.get_item_stats(user_id=USER_ID, db=db)

    eq_chain = db.table.return_value.select.return_value.eq.return_value
    order_calls = eq_chain.order.call_args_list
    assert len(order_calls) == 2
    # Most worn: descending, NULLs last.
    assert order_calls[0].args == ("usage_times_worn",)
    assert order_calls[0].kwargs == {"desc": True, "nullsfirst": False}
    # Least worn: ascending (desc omitted -> default), NULLs last so
    # never-worn items rank first.
    assert order_calls[1].args == ("usage_times_worn",)
    assert order_calls[1].kwargs == {"nullsfirst": False}


@pytest.mark.asyncio
async def test_stats_falls_back_to_fetched_rows_when_count_missing():
    class _NoCountResult:
        data = []
        count = None

    db = _stats_mock_db(
        count=0,
        agg_payload={
            "total_items": 1,
            "items_by_category": {"tops": 1},
            "items_by_condition": {"good": 1},
            "items_by_color": {},
            "total_value": 0,
        },
    )
    db.table.return_value.select.return_value.eq.return_value.execute.return_value = _NoCountResult()

    result = await items_module.get_item_stats(user_id=USER_ID, db=db)

    # Without a count attribute (unusual; PostgREST always sends one for
    # count="exact") the endpoint falls back to the RPC's total.
    assert result["data"]["total_items"] == 1
