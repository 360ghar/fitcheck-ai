"""
Admin quota usage tests (2026-08-07 prod-log RCA).

``GET /api/v1/admin/quotas`` lists today's per-user AI counters from
``user_ai_settings`` with the user's email and plan. The subscription embed
must go THROUGH users (``users(...,subscriptions(...))``): ``user_ai_settings``
has no FK to ``subscriptions`` (both are 1:1 with ``users``, migrations
003/007), so a top-level ``subscriptions(...)`` embed raises PostgREST
PGRST200 "Could not find a relationship between 'user_ai_settings' and
'subscriptions'" (observed 2026-08-07 on the live admin console). These
tests pin the embed shape, the nested plan-filter path, and the
single-object/list-tolerant row merging.
"""

import pytest

from admin_test_utils import FakeDB
from app.services.admin_service import list_quota_usage


def _settings_row(
    user_id: str,
    *,
    email: str = "user@example.com",
    full_name: str = "Test User",
    custom_daily_quota: int | None = None,
    plan_type: str | None = None,
    subscriptions_as_list: bool = False,
) -> dict:
    users: dict = {
        "email": email,
        "full_name": full_name,
        "custom_daily_quota": custom_daily_quota,
    }
    if plan_type is not None:
        sub = {"plan_type": plan_type, "status": "active"}
        users["subscriptions"] = [sub] if subscriptions_as_list else sub
    return {
        "user_id": user_id,
        "daily_extraction_count": 3,
        "daily_generation_count": 1,
        "daily_embedding_count": 0,
        "last_reset_date": "2026-08-07",
        "total_extractions": 12,
        "total_generations": 4,
        "users": users,
    }


def _quota_selects(db: FakeDB) -> list[tuple[str, ...]]:
    return [args for table, args in db.selects if table == "user_ai_settings"]


@pytest.mark.asyncio
async def test_quota_usage_embeds_subscriptions_through_users():
    """The builder must nest subscriptions inside the users embed - a top-level
    subscriptions(...) embed fails PGRST200 on the repo schema (no FK)."""
    db = FakeDB(rows={"user_ai_settings": [_settings_row("u1")]})
    await list_quota_usage(db)
    selects = _quota_selects(db)
    assert selects, "expected a user_ai_settings select"
    for args in selects:
        assert "users(email,full_name,custom_daily_quota,subscriptions(plan_type,status))" in args
        assert not any(arg == "subscriptions(plan_type,status)" for arg in args)


@pytest.mark.asyncio
async def test_quota_usage_plan_filter_uses_nested_path():
    db = FakeDB(
        rows={
            "user_ai_settings": [
                _settings_row("u-paid", plan_type="pro_monthly"),
                _settings_row("u-free", plan_type="free"),
            ]
        }
    )
    result = await list_quota_usage(db, plan="pro_monthly")
    assert [item["user_id"] for item in result["items"]] == ["u-paid"]
    assert result["total"] == 1
    # The plan filter must use `!inner` on BOTH embed levels: a bare embed
    # is a LEFT join, so `users.subscriptions.plan_type` would only filter
    # the EMBEDDED rows and `count` would report every plan's users (with
    # subscriptions=null for the non-matching rows).
    selects = _quota_selects(db)
    assert selects, "expected a user_ai_settings select"
    for args in selects:
        assert (
            "users!inner(email,full_name,custom_daily_quota,subscriptions!inner(plan_type,status))"
            in args
        )


@pytest.mark.asyncio
async def test_quota_usage_merges_nested_single_object_subscription():
    """PostgREST returns a single object (not an array) for an embed through a
    UNIQUE FK - subscriptions.user_id is UNIQUE (migration 007)."""
    db = FakeDB(rows={"user_ai_settings": [_settings_row("u1", plan_type="plus_monthly")]})
    result = await list_quota_usage(db)
    item = result["items"][0]
    assert item["email"] == "user@example.com"
    assert item["full_name"] == "Test User"
    assert item["plan_type"] == "plus_monthly"
    assert item["daily_extraction_count"] == 3


@pytest.mark.asyncio
async def test_quota_usage_tolerates_list_shaped_subscription():
    """Defensive: tolerate an array-shaped embed from older PostgREST behavior."""
    db = FakeDB(
        rows={
            "user_ai_settings": [
                _settings_row("u1", plan_type="free", subscriptions_as_list=True)
            ]
        }
    )
    result = await list_quota_usage(db)
    assert result["items"][0]["plan_type"] == "free"


@pytest.mark.asyncio
async def test_quota_usage_defaults_missing_subscription_and_user():
    db = FakeDB(
        rows={
            "user_ai_settings": [
                {**_settings_row("u1")},  # users embed without subscriptions
                {**_settings_row("u2"), "users": None},
            ]
        }
    )
    result = await list_quota_usage(db)
    by_id = {item["user_id"]: item for item in result["items"]}
    assert by_id["u1"]["plan_type"] is None
    assert by_id["u2"]["email"] is None
    assert by_id["u2"]["plan_type"] is None


@pytest.mark.asyncio
async def test_quota_usage_empty_state():
    db = FakeDB(rows={})
    result = await list_quota_usage(db)
    assert result == {"items": [], "total": 0, "page": 1, "page_size": 20}
