"""Regression tests for the PR-16 admin review findings."""

from datetime import datetime, timedelta, timezone
from pathlib import Path

import pytest

from app.core.exceptions import ValidationError
from app.services import admin_service
from app.services.admin_service import (
    clear_daily_ai_counters,
    dashboard_funnel,
    dashboard_retention,
    extend_user_trial,
    get_user_detail,
)
from app.utils.datetime_util import parse_utc_datetime, utcnow
from tests.utils.fake_db import FakeDB


@pytest.mark.asyncio
async def test_extend_trial_is_atomic_and_revives_an_expired_trial():
    expired = (utcnow() - timedelta(days=30)).isoformat()
    db = FakeDB(
        rows={
            "subscriptions": [
                {"user_id": "u1", "status": "trial", "plan_type": "pro_monthly", "trial_end": expired}
            ]
        }
    )

    result = await extend_user_trial(db, "u1", 7)

    assert db.rpc_calls == [("admin_extend_user_trial", {"p_user_id": "u1", "p_days": 7})]
    assert not db.updates
    assert parse_utc_datetime(result["after"]) > utcnow() + timedelta(days=6)


@pytest.mark.asyncio
async def test_extend_trial_rejects_active_paid_subscriptions():
    db = FakeDB(
        rows={"subscriptions": [{"user_id": "u1", "status": "active", "plan_type": "pro_monthly"}]}
    )

    with pytest.raises(ValidationError):
        await extend_user_trial(db, "u1", 7)


@pytest.mark.asyncio
async def test_extend_trial_rejects_free_plan():
    db = FakeDB(rows={"subscriptions": [{"user_id": "u1", "status": "trial", "plan_type": "free"}]})

    with pytest.raises(ValidationError):
        await extend_user_trial(db, "u1", 7)


@pytest.mark.asyncio
async def test_clear_daily_counters_resets_only_the_active_usage_period():
    today = utcnow().date()
    active_period = today.replace(day=1).isoformat()
    previous_period = (today.replace(day=1) - timedelta(days=1)).replace(day=1).isoformat()
    db = FakeDB(
        rows={
            "users": [{"id": "u1"}],
            "user_ai_settings": [
                {
                    "user_id": "u1",
                    "daily_extraction_count": 4,
                    "daily_generation_count": 3,
                    "daily_embedding_count": 2,
                }
            ],
            "subscription_usage": [
                {
                    "user_id": "u1",
                    "period_start": active_period,
                    "monthly_extractions": 17,
                    "daily_photoshoot_images": 9,
                },
                {
                    "user_id": "u1",
                    "period_start": previous_period,
                    "monthly_extractions": 5,
                    "daily_photoshoot_images": 8,
                },
            ],
        }
    )

    result = await clear_daily_ai_counters(db, "u1")

    assert result["period_start"] == active_period
    assert db.rpc_calls == [("admin_clear_user_daily_ai_counters", {"p_user_id": "u1"})]
    active = next(row for row in db.rows["subscription_usage"] if row["period_start"] == active_period)
    prior = next(row for row in db.rows["subscription_usage"] if row["period_start"] == previous_period)
    assert active["daily_photoshoot_images"] == 0
    assert active["monthly_extractions"] == 17
    assert prior["daily_photoshoot_images"] == 8


@pytest.mark.asyncio
async def test_user_detail_returns_outfit_cover_and_support_ticket_rows():
    db = FakeDB(
        rows={
            "users": [{"id": "u1", "email": "u1@example.com"}],
            "subscriptions": [{"user_id": "u1", "plan_type": "free", "status": "active"}],
            "outfits": [
                {
                    "id": "o1",
                    "user_id": "u1",
                    "name": "Weekend",
                    "created_at": "2026-08-01T00:00:00+00:00",
                    "outfit_images": [
                        {"image_url": "https://example.test/secondary.png", "is_primary": False},
                        {"image_url": "https://example.test/primary.png", "is_primary": True},
                    ],
                }
            ],
            "support_tickets": [
                {
                    "id": "t1",
                    "user_id": "u1",
                    "status": "open",
                    "subject": "Need help",
                    "created_at": "2026-08-02T00:00:00+00:00",
                }
            ],
        }
    )

    result = await get_user_detail(db, "u1")

    assert result["outfits"][0]["cover_image_url"] == "https://example.test/primary.png"
    assert result["support_tickets"] == [{
        "id": "t1",
        "user_id": "u1",
        "status": "open",
        "subject": "Need help",
        "created_at": "2026-08-02T00:00:00+00:00",
    }]


@pytest.mark.asyncio
async def test_funnel_fetches_all_postgrest_pages_for_users_and_items():
    created_at = (utcnow() - timedelta(hours=1)).isoformat()
    users = [{"id": f"u{index:03d}", "created_at": created_at} for index in range(501)]
    # The only conversion belongs to the final user page and its item list
    # also exceeds one PostgREST response page.
    items = [
        {"id": f"i{index:03d}", "user_id": "u500", "created_at": created_at}
        for index in range(501)
    ]
    db = FakeDB(
        rows={
            "users": users,
            "items": items,
            "outfits": [{"id": "o1", "user_id": "u500", "created_at": created_at}],
            "subscriptions": [{"user_id": "u500", "plan_type": "pro_monthly", "status": "active"}],
        }
    )

    result = await dashboard_funnel(db, days=30)

    assert [step["count"] for step in result["steps"]] == [501, 1, 1, 1]
    assert sum(1 for table, _args in db.selects if table == "users") >= 2
    assert sum(1 for table, _args in db.selects if table == "items") >= 2


@pytest.mark.asyncio
async def test_funnel_stages_are_cumulative_and_paid_counts_distinct_users():
    created_at = (utcnow() - timedelta(days=2)).isoformat()
    db = FakeDB(
        rows={
            "users": [
                {"id": "u1", "created_at": created_at},  # outfit only, item outside 24h
                {"id": "u2", "created_at": created_at},  # full path, two subscription rows
                {"id": "u3", "created_at": created_at},  # signup only
            ],
            "items": [{"id": "i1", "user_id": "u2", "created_at": created_at}],
            "outfits": [
                {"id": "o1", "user_id": "u1", "created_at": created_at},
                {"id": "o2", "user_id": "u2", "created_at": created_at},
            ],
            "subscriptions": [
                {"user_id": "u2", "plan_type": "pro_monthly", "status": "active"},
                {"user_id": "u2", "plan_type": "pro_yearly", "status": "trial"},
            ],
        }
    )

    result = await dashboard_funnel(db, days=30)

    # u1's outfit is inside the 7-day window but their item is outside 24h —
    # the outfit stage must be a subset of the item stage, never exceed it.
    # u2 holds two subscription rows but must be counted once.
    assert [step["count"] for step in result["steps"]] == [3, 1, 1, 1]
    assert all(step["pct_of_prev"] <= 100.0 for step in result["steps"])


@pytest.mark.asyncio
async def test_retention_omits_the_current_immature_cohort(monkeypatch):
    now = datetime(2026, 8, 26, 12, tzinfo=timezone.utc)
    monkeypatch.setattr(admin_service, "utcnow", lambda: now)
    db = FakeDB(
        rows={
            "users": [
                {
                    "id": "retained",
                    "created_at": "2026-08-18T12:00:00+00:00",
                    "last_login_at": "2026-08-25T00:00:00+00:00",
                },
                {
                    "id": "current",
                    "created_at": "2026-08-25T12:00:00+00:00",
                    "last_login_at": "2026-08-26T11:00:00+00:00",
                },
            ]
        }
    )

    result = await dashboard_retention(db, weeks=2)

    # The current (immature) cohort is omitted, but requesting one extra
    # Monday keeps the oldest mature cohort — weeks=2 yields exactly 2 rows.
    assert result["cohorts"] == [
        {"week_start": "2026-08-10", "signups": 0, "retained_7d": 0, "retention_pct": 0.0},
        {"week_start": "2026-08-17", "signups": 1, "retained_7d": 1, "retention_pct": 100.0},
    ]


def test_atomic_admin_user_actions_migration_has_transaction_and_locks():
    migration = (
        Path(__file__).resolve().parents[3]
        / "db"
        / "supabase"
        / "migrations"
        / "060_atomic_admin_user_actions.sql"
    ).read_text(encoding="utf-8")

    assert "BEGIN;" in migration and "COMMIT;" in migration
    assert "FOR UPDATE" in migration
    assert "GREATEST(COALESCE(before_trial_end, NOW()), NOW())" in migration
    assert "ON CONFLICT (user_id, period_start) DO UPDATE" in migration
