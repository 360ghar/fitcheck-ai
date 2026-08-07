"""Aggregation behavior of GET /items/stats.

The endpoint pushes the most/least-worn extremes into SQL (ORDER BY + LIMIT)
instead of sorting up to 1000 rows in Python, and reads the total from a
``count="exact"`` query. These tests lock the response shape and the exact
ordering contract (NULL wear counts must rank as "never worn", never first).
"""
from unittest.mock import Mock

import pytest

from app.api.v1 import items as items_module

USER_ID = "11111111-1111-1111-1111-111111111111"


def _stats_mock_db(*, count: int, agg_rows=None, worn_rows=None):
    """Wire the four concurrent stats queries to canned results.

    MagicMock returns the same chain for every call, so the count query
    (select -> eq -> execute), the aggregation query (select -> eq -> limit ->
    execute) and the extremes queries (select -> eq -> order -> limit ->
    execute) are distinguished by which mock attribute they end on.
    """
    db = Mock()
    eq_chain = db.table.return_value.select.return_value.eq.return_value
    eq_chain.execute.return_value = Mock(data=[], count=count)
    eq_chain.limit.return_value.execute.return_value = Mock(data=agg_rows or [])
    eq_chain.order.return_value.limit.return_value.execute.return_value = Mock(
        data=worn_rows or []
    )
    return db


@pytest.mark.asyncio
async def test_stats_aggregates_histograms_and_extremes():
    agg_rows = [
        {"category": "tops", "colors": ["Black", "White"], "condition": "good", "price": 25.5},
        {"category": "Tops", "colors": [], "condition": "good", "price": None},
        {"category": None, "colors": ["Blue"], "condition": None, "price": "10"},
    ]
    worn_rows = [
        {"id": "1", "name": "White tee", "usage_times_worn": 12},
        {"id": "2", "name": "Never worn", "usage_times_worn": None},
    ]
    db = _stats_mock_db(count=3, agg_rows=agg_rows, worn_rows=worn_rows)

    result = await items_module.get_item_stats(user_id=USER_ID, db=db)

    data = result["data"]
    assert data["total_items"] == 3
    # Category/condition names are normalized to lowercase; unknown -> "other".
    assert data["items_by_category"] == {"tops": 2, "other": 1}
    assert data["items_by_condition"] == {"good": 2, "clean": 1}
    assert data["items_by_color"] == {"black": 1, "white": 1, "blue": 1}
    assert data["total_value"] == 35.5
    # A NULL wear count is reported as 0, never as a "most worn" leader.
    assert data["most_worn_items"][0] == {"id": "1", "name": "White tee", "times_worn": 12}
    assert {"id": "2", "name": "Never worn", "times_worn": 0} in data["most_worn_items"]


@pytest.mark.asyncio
async def test_stats_extreme_queries_request_nullslast_ordering():
    """The SQL pushdown must not reintroduce Postgres's NULLs-first DESC trap."""
    db = _stats_mock_db(count=0, worn_rows=[])

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
    # Only the histogram columns are pulled for the aggregation payload.
    assert eq_chain.limit.call_args_list[0].args == (1000,)


@pytest.mark.asyncio
async def test_stats_falls_back_to_fetched_rows_when_count_missing():
    class _NoCountResult:
        data = []
        count = None

    db = _stats_mock_db(count=0, agg_rows=[{"category": "tops", "colors": [], "condition": "good", "price": None}])
    db.table.return_value.select.return_value.eq.return_value.execute.return_value = _NoCountResult()

    result = await items_module.get_item_stats(user_id=USER_ID, db=db)

    # Without a count attribute (unusual; PostgREST always sends one for
    # count="exact") the endpoint falls back to the fetched row count.
    assert result["data"]["total_items"] == 1
