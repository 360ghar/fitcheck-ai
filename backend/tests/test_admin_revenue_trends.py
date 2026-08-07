"""
Admin revenue + trends tests (2026-08-07 revenue/trends wave).

``GET /api/v1/admin/dashboards/revenue`` aggregates active paid subscription
rows against the configured plan prices (MRR estimate) plus lifecycle churn
events from the webhook dedupe tables and refund audit actions.
``GET /api/v1/admin/dashboards/trends`` calls the migration-041 service-role
RPCs (``admin_trend_*``) and zero-fills the daily series.

The RPCs themselves are exercised via ``FakeDB.rpc_results`` (same pattern as
``test_admin_dashboards.py``); their SQL lives in
``backend/db/supabase/migrations/041_admin_trends.sql``.
"""

import pytest

from admin_test_utils import FakeDB
from app.core.exceptions import ValidationError
from app.services.admin_service import (
    _monthly_mrr_amount,
    dashboard_revenue,
    dashboard_trends,
    _trend_days_axis,
)
from app.utils.datetime_util import utc_today, utcnow

TREND_RPC_NAMES = (
    "admin_trend_signups",
    "admin_trend_jobs",
    "admin_trend_paid",
    "admin_trend_active",
)


def _sub(plan_type: str, provider: str | None = None, status: str = "active") -> dict:
    row = {"plan_type": plan_type, "status": status}
    if provider is not None:
        row["billing_provider"] = provider
    return row


# =============================================================================
# MRR helper
# =============================================================================


def test_monthly_mrr_amount_amortizes_yearly_plans():
    assert _monthly_mrr_amount("plus_monthly") == 10.00
    assert _monthly_mrr_amount("pro_monthly") == 20.00
    # Yearly plans amortize: 100/12 and 200/12, rounded to cents.
    assert _monthly_mrr_amount("plus_yearly") == round(100 / 12, 2)
    assert _monthly_mrr_amount("pro_yearly") == round(200 / 12, 2)
    assert _monthly_mrr_amount("free") == 0.0
    assert _monthly_mrr_amount("not-a-plan") == 0.0


# =============================================================================
# Revenue
# =============================================================================


@pytest.mark.asyncio
async def test_revenue_mrr_split_and_counts():
    now_iso = utcnow().isoformat()
    db = FakeDB(
        rows={
            "subscriptions": [
                _sub("pro_monthly", "stripe"),
                _sub("pro_monthly", "stripe"),
                _sub("plus_monthly", "apple"),
                _sub("plus_yearly", "google"),
                _sub("free"),  # excluded
                _sub("pro_monthly", "stripe", status="trial"),  # not counted as paid
            ],
            "stripe_webhook_events": [
                {"event_type": "customer.subscription.deleted", "received_at": now_iso},
                {"event_type": "customer.subscription.updated", "received_at": now_iso},
                {"event_type": "checkout.session.completed", "received_at": now_iso},
            ],
            "apple_iap_events": [
                {"event_type": "EXPIRED", "received_at": now_iso},
                {"event_type": "DID_RENEW", "received_at": now_iso},
            ],
            "google_rtdn_events": [
                {"event_type": "SUBSCRIPTION_CANCELED", "received_at": now_iso},
                {"event_type": "SUBSCRIPTION_RESTARTED", "received_at": now_iso},
            ],
            "audit_events": [
                {"action": "subscription.refunded", "created_at": now_iso},
                {"action": "iap.refund_marked", "created_at": now_iso},
                {"action": "user.role_changed", "created_at": now_iso},
            ],
        },
    )

    result = await dashboard_revenue(db)

    # MRR: 2x pro_monthly (20) + plus_monthly (10) + plus_yearly/12 ≈ 38.33
    assert result["mrr"]["total"] == round(20 + 20 + 10 + 100 / 12, 2)
    assert result["mrr"]["stripe"] == 40.0
    assert result["mrr"]["iap"] == round(10 + 100 / 12, 2)
    assert result["paid_subscriptions"] == 4
    assert result["trial_subscriptions"] == 1
    assert result["churn_events_30d"] == {
        "total": 3,
        "stripe": 1,
        "apple": 1,
        "google": 1,
    }
    assert result["refunds_30d"] == 2
    assert result["as_of"]  # ISO timestamp present


@pytest.mark.asyncio
async def test_revenue_empty_state_is_zero():
    db = FakeDB(rows={})

    result = await dashboard_revenue(db)

    assert result["mrr"] == {"total": 0.0, "stripe": 0.0, "iap": 0.0}
    assert result["paid_subscriptions"] == 0
    assert result["trial_subscriptions"] == 0
    assert result["churn_events_30d"] == {"total": 0, "stripe": 0, "apple": 0, "google": 0}
    assert result["refunds_30d"] == 0


@pytest.mark.asyncio
async def test_revenue_excludes_rows_without_active_status():
    db = FakeDB(
        rows={
            "subscriptions": [
                _sub("pro_monthly", "stripe", status="cancelled"),
                _sub("pro_monthly", status="active"),  # no provider -> paid row, no split
            ],
        },
    )

    result = await dashboard_revenue(db)

    assert result["paid_subscriptions"] == 1
    assert result["mrr"] == {"total": 20.0, "stripe": 0.0, "iap": 0.0}


@pytest.mark.asyncio
async def test_revenue_google_churn_requires_mapped_type_names():
    """Google churn counts only real RTDN type names.

    Rows written before the webhook stored the mapped name (blanket 'rtdn'
    label) never match and stay invisible — their type is not recoverable
    from the ledger, so this documents that they must not inflate counts
    either (a naive "count all rtdn rows" change would regress this).
    """
    now_iso = utcnow().isoformat()
    db = FakeDB(
        rows={
            "google_rtdn_events": [
                {"event_type": "rtdn", "received_at": now_iso},  # legacy label
                {"event_type": "SUBSCRIPTION_PURCHASED", "received_at": now_iso},
                {"event_type": "SUBSCRIPTION_CANCELED", "received_at": now_iso},
                {"event_type": "SUBSCRIPTION_EXPIRED", "received_at": now_iso},
            ],
        },
    )

    result = await dashboard_revenue(db)

    assert result["churn_events_30d"] == {
        "total": 2,
        "stripe": 0,
        "apple": 0,
        "google": 2,
    }


# =============================================================================
# Trends
# =============================================================================


def _day(offset: int) -> str:
    """ISO date `offset` days before today (UTC)."""
    from datetime import timedelta

    return (utc_today() - timedelta(days=offset)).isoformat()


@pytest.mark.asyncio
async def test_trends_calls_the_four_rpcs_with_days_and_zero_fills():
    today = _day(0)
    yesterday = _day(1)
    db = FakeDB(
        rows={},
        rpc_results={
            "admin_trend_signups": [{"day": today, "count": 3}],
            "admin_trend_jobs": [
                {"day": yesterday, "kind": "photoshoot", "total": 4, "succeeded": 3, "failed": 1},
                {"day": yesterday, "kind": "extraction", "total": 2, "succeeded": 2, "failed": 0},
            ],
            "admin_trend_paid": [
                {"day": today, "provider": "stripe", "count": 2},
                {"day": today, "provider": "apple", "count": 1},
            ],
            "admin_trend_active": [{"day": yesterday, "count": 5}],
        },
    )

    result = await dashboard_trends(db, days=30)

    assert [name for name, _ in db.rpc_calls] == list(TREND_RPC_NAMES)
    # PostgREST resolves RPC args by parameter name: the migration-041
    # functions declare `p_days`, so the call site must pass `p_days` (a
    # `days` key here is exactly the PGRST202 the live endpoint hit).
    assert all(params == {"p_days": 30} for _, params in db.rpc_calls)
    assert result["days"] == 30
    assert len(result["signups"]) == 30
    assert result["signups"][-1] == {"day": today, "count": 3}
    assert result["signups"][0]["count"] == 0  # oldest day zero-filled
    # Jobs merged across kinds for the same day.
    by_day = {row["day"]: row for row in result["jobs"]}
    assert by_day[yesterday] == {"day": yesterday, "total": 6, "succeeded": 5, "failed": 1}
    assert by_day[today]["total"] == 0
    # Paid: providers normalized (apple -> iap) and zero-filled per day.
    paid_by_day = {row["day"]: row for row in result["paid"]}
    assert result["paid"][-2] == {"day": today, "provider": "stripe", "count": 2}
    assert result["paid"][-1] == {"day": today, "provider": "iap", "count": 1}
    assert paid_by_day[yesterday]["count"] == 0
    assert len(result["active"]) == 30
    assert result["active"][-2] == {"day": yesterday, "count": 5}
    assert result["active"][-1] == {"day": today, "count": 0}


@pytest.mark.asyncio
async def test_trends_supports_90_day_window():
    db = FakeDB(rows={}, rpc_results={})

    result = await dashboard_trends(db, days=90)

    assert result["days"] == 90
    assert len(result["signups"]) == 90
    assert len(result["jobs"]) == 90
    assert len(result["active"]) == 90
    assert len(result["paid"]) == 180  # two providers per day
    assert all(params == {"p_days": 90} for _, params in db.rpc_calls)


@pytest.mark.asyncio
@pytest.mark.parametrize("days", [7, 15])
async def test_trends_supports_7_and_15_day_windows(days):
    db = FakeDB(rows={}, rpc_results={})

    result = await dashboard_trends(db, days=days)

    assert result["days"] == days
    assert len(result["signups"]) == days
    assert len(result["jobs"]) == days
    assert len(result["active"]) == days
    assert len(result["paid"]) == days * 2  # two providers per day
    assert all(params == {"p_days": days} for _, params in db.rpc_calls)


@pytest.mark.asyncio
async def test_trends_rejects_unsupported_windows():
    db = FakeDB(rows={})

    with pytest.raises(ValidationError):
        await dashboard_trends(db, days=45)


def test_trend_days_axis_is_ordered_oldest_first():
    axis = _trend_days_axis(3)
    assert len(axis) == 3
    assert axis[-1] == _day(0)
    assert axis[0] == _day(2)
