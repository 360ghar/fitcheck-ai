"""
Admin dashboard top-users tests.

The grouped counts for ``GET /api/v1/admin/dashboards/top-users`` come from
the service-role RPCs added in migration 040_admin_dashboard_top_users.sql
(``admin_top_users_outfits`` / ``_items`` / ``_referrals``): PostgREST
select-side aggregates are disabled on this project and the legacy bare-
``count`` shorthand emits SQL without GROUP BY (Postgres 42803), so the old
``select("user_id,count")`` table queries could never work.
"""

import pytest

from tests.utils.fake_db import FakeDB
from app.services.admin_service import dashboard_top_users

RPC_NAMES = [
    "admin_top_users_outfits",
    "admin_top_users_items",
    "admin_top_users_referrals",
]


def _user(uid: str, name: str) -> dict:
    return {"id": uid, "email": f"{name}@example.com", "full_name": name}


def _count_row(uid: str, count: int) -> dict:
    return {"user_id": uid, "count": count}


@pytest.mark.asyncio
async def test_top_users_calls_the_three_service_rpcs():
    db = FakeDB(
        rows={"users": [_user("u1", "Alice"), _user("u2", "Bob")]},
        rpc_results={
            "admin_top_users_outfits": [_count_row("u1", 3)],
            "admin_top_users_items": [_count_row("u2", 5)],
            "admin_top_users_referrals": [_count_row("u1", 1), _count_row("u2", 2)],
        },
    )

    result = await dashboard_top_users(db)

    assert [name for name, _ in db.rpc_calls] == RPC_NAMES
    assert result == {
        "top_outfits": [
            {
                "id": "u1",
                "email": "Alice@example.com",
                "full_name": "Alice",
                "user_id": "u1",
                "count": 3,
            }
        ],
        "top_items": [
            {
                "id": "u2",
                "email": "Bob@example.com",
                "full_name": "Bob",
                "user_id": "u2",
                "count": 5,
            }
        ],
        "top_referrers": [
            {
                "id": "u2",
                "email": "Bob@example.com",
                "full_name": "Bob",
                "user_id": "u2",
                "count": 2,
            },
            {
                "id": "u1",
                "email": "Alice@example.com",
                "full_name": "Alice",
                "user_id": "u1",
                "count": 1,
            },
        ],
    }


@pytest.mark.asyncio
async def test_top_users_keeps_unknown_user_ids_without_join():
    db = FakeDB(
        rows={"users": [_user("u1", "Alice")]},
        rpc_results={
            "admin_top_users_outfits": [_count_row("u1", 2), _count_row("ghost", 1)],
            "admin_top_users_items": [],
            "admin_top_users_referrals": [],
        },
    )

    result = await dashboard_top_users(db)

    assert result["top_outfits"] == [
        {
            "id": "u1",
            "email": "Alice@example.com",
            "full_name": "Alice",
            "user_id": "u1",
            "count": 2,
        },
        {"user_id": "ghost", "count": 1},
    ]


@pytest.mark.asyncio
async def test_top_users_sorts_by_count_desc_then_user_id_and_caps_at_ten():
    rows = [_count_row(f"u{i:02d}", i) for i in range(1, 13)]
    rows[3] = _count_row("u04", 5)  # tie with u05 (count 5) -> u04 first
    db = FakeDB(
        rows={},
        rpc_results={
            "admin_top_users_outfits": rows,
            "admin_top_users_items": [],
            "admin_top_users_referrals": [],
        },
    )

    result = await dashboard_top_users(db)

    # u04 (count 4) was bumped to 5, so no row has count 4: the 10th slot is u03 (3).
    assert [r["count"] for r in result["top_outfits"]] == [12, 11, 10, 9, 8, 7, 6, 5, 5, 3]
    assert [r["user_id"] for r in result["top_outfits"][7:9]] == ["u04", "u05"]
    assert len(result["top_outfits"]) == 10
    assert result["top_items"] == []
    assert result["top_referrers"] == []


@pytest.mark.asyncio
async def test_top_users_empty_results_are_safe():
    db = FakeDB(rows={}, rpc_results={})

    result = await dashboard_top_users(db)

    assert result == {"top_outfits": [], "top_items": [], "top_referrers": []}
    assert [name for name, _ in db.rpc_calls] == RPC_NAMES
