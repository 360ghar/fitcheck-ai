"""Coverage-completing tests for SubscriptionService.

Sibling to test_subscription_service.py and the subscription route/webhook
integration tests. This file covers the remaining error and edge branches:
naive entitlement datetimes, Stripe-object attribute reads, unparseable
timestamps, unknown-price fail-closed, replaced/stale Stripe snapshot guards,
the read-path fallbacks when a write tail returns no rows, store-identity
release with no previous owner, referral-credit creation paths, PGRST116
usage-record creation, get_usage (concurrent, prefetched, error wrap),
check_limit cap messaging for upgradable and top-tier plans, and the
increment_usage failure modes (rate-limit rejection, missing RPC, generic
errors).
"""
import calendar
import time
from datetime import datetime, timedelta, timezone
from types import SimpleNamespace
from unittest.mock import AsyncMock, patch

import pytest

from app.core.config import settings
from app.core.exceptions import AIServiceError, DatabaseError, RateLimitError
from app.models.subscription import PlanType, SubscriptionStatus
from app.services import subscription_service as subscription_module
from app.services.subscription_service import SubscriptionService
from app.utils.db import (
    QUOTA_UNAVAILABLE_CLIENT_MESSAGE,
    execute_with_reconnect as real_execute_with_reconnect,
)
from tests.utils.fake_db import FakeBuilder, FakeDB, FakeResult

USER_ID = "11111111-1111-1111-1111-111111111111"
SUB_ID = "22222222-2222-2222-2222-222222222222"

_STRIPE_PRICE_IDS = {
    "STRIPE_PLUS_MONTHLY_PRICE_ID": "price_plus_monthly",
    "STRIPE_PLUS_YEARLY_PRICE_ID": "price_plus_yearly",
    "STRIPE_PRO_MONTHLY_PRICE_ID": "price_pro_monthly",
    "STRIPE_PRO_YEARLY_PRICE_ID": "price_pro_yearly",
}


def _subscription_row(**overrides):
    row = {
        "id": "22222222-2222-2222-2222-222222222222",
        "user_id": USER_ID,
        "plan_type": "free",
        "status": "active",
        "current_period_start": datetime.now(timezone.utc).isoformat(),
        "current_period_end": None,
        "cancel_at_period_end": False,
        "trial_end": None,
        "referral_credit_months": 0,
        "billing_provider": "stripe",
        "created_at": datetime.now(timezone.utc).isoformat(),
        "updated_at": datetime.now(timezone.utc).isoformat(),
    }
    row.update(overrides)
    return row


def _usage_row(**overrides):
    row = {
        "user_id": USER_ID,
        "period_start": SubscriptionService._get_current_period_start().isoformat(),
        "monthly_extractions": 0,
        "monthly_generations": 0,
        "monthly_embeddings": 0,
    }
    row.update(overrides)
    return row


def _fresh_db(**kwargs) -> FakeDB:
    """FakeDB whose written rows get an id (Postgres would generate one)."""
    return FakeDB(insert_defaults={"id": SUB_ID}, **kwargs)


class _UsageUpsertBuilder(FakeBuilder):
    """FakeBuilder that tolerates the ignore_duplicates upsert kwarg."""

    def upsert(self, row, on_conflict=None, ignore_duplicates=False):
        return super().upsert(row, on_conflict=on_conflict)


class _UsageUpsertDB(FakeDB):
    """FakeDB whose subscription_usage upserts accept ignore_duplicates."""

    def table(self, name: str):
        if name == "subscription_usage":
            return _UsageUpsertBuilder(self, name)
        return super().table(name)


class _NoRowUpsertBuilder(FakeBuilder):
    """FakeBuilder whose insert/upsert executes return no rows.

    Lets the webhook write tails exercise their ``return
    await cls.get_subscription(...)`` fallback (PostgREST normally echoes the
    affected rows back).
    """

    def execute(self):
        if self._mode == "insert":
            return FakeResult(data=[])
        return super().execute()


class _NoRowUpsertDB(FakeDB):
    """FakeDB whose subscriptions inserts/upserts never return the written row."""

    def table(self, name: str):
        if name == "subscriptions":
            return _NoRowUpsertBuilder(self, name)
        return super().table(name)


# =============================================================================
# Plan limit helpers
# =============================================================================


def test_effective_plan_type_handles_naive_entitlement_datetimes():
    now = datetime(2026, 6, 15, 12, 0, tzinfo=timezone.utc)
    # A naive entitlement datetime is treated as being in the checker's
    # timezone: a future naive date still entitles the plan.
    future_naive = datetime(2026, 7, 1)
    assert (
        SubscriptionService.effective_plan_type(
            PlanType.PRO_MONTHLY,
            SubscriptionStatus.TRIAL,
            None,
            future_naive,
            now=now,
        )
        == PlanType.PRO_MONTHLY
    )
    past_naive = datetime(2026, 1, 1)
    assert (
        SubscriptionService.effective_plan_type(
            PlanType.PRO_MONTHLY,
            SubscriptionStatus.ACTIVE,
            past_naive,
            None,
            now=now,
        )
        == PlanType.FREE
    )


# =============================================================================
# Subscription CRUD
# =============================================================================


@pytest.mark.asyncio
async def test_create_default_subscription_wraps_db_errors(monkeypatch):
    async def _boom(*args, **kwargs):
        raise RuntimeError("connection lost")

    monkeypatch.setattr(subscription_module, "execute_with_reconnect", _boom)

    with pytest.raises(DatabaseError, match="Failed to create subscription"):
        await SubscriptionService.create_default_subscription(USER_ID, FakeDB())


@pytest.mark.asyncio
async def test_upgrade_to_pro_monthly_sets_one_month_period():
    db = _fresh_db()
    before = datetime.now(timezone.utc)

    result = await SubscriptionService.upgrade_to_pro(
        USER_ID, PlanType.PRO_MONTHLY, "cus_1", "sub_1", db
    )

    inserted = db.inserts[0][1]
    assert inserted["plan_type"] == "pro_monthly"
    period_end = datetime.fromisoformat(inserted["current_period_end"])
    assert before + timedelta(days=27) <= period_end <= before + timedelta(days=32)
    assert result.plan_type == PlanType.PRO_MONTHLY


@pytest.mark.asyncio
async def test_upgrade_to_pro_wraps_followup_read_errors(monkeypatch):
    db = FakeDB()
    monkeypatch.setattr(
        SubscriptionService,
        "get_subscription",
        AsyncMock(side_effect=DatabaseError("read failed")),
    )

    with pytest.raises(DatabaseError, match="Failed to upgrade subscription"):
        await SubscriptionService.upgrade_to_pro(
            USER_ID, PlanType.PRO_MONTHLY, "cus_1", "sub_1", db
        )


@pytest.mark.asyncio
async def test_sync_stripe_subscription_reads_object_shaped_payload():
    now_ts = time.time()
    stripe_subscription = SimpleNamespace(
        id="sub_123",
        status="active",
        customer="cus_123",
        current_period_start=str(int(now_ts) - 86400),
        current_period_end=str(int(now_ts) + 30 * 86400),
        trial_end=None,
        cancel_at_period_end=False,
        items=SimpleNamespace(
            data=[SimpleNamespace(price=SimpleNamespace(id="price_pro_monthly"))]
        ),
    )

    with patch.multiple(settings, **_STRIPE_PRICE_IDS):
        db = _fresh_db()
        result = await SubscriptionService.sync_stripe_subscription(
            USER_ID, stripe_subscription, db
        )

    assert result.plan_type == PlanType.PRO_MONTHLY
    assert result.status == SubscriptionStatus.ACTIVE
    inserted = db.inserts[0][1]
    assert inserted["stripe_subscription_id"] == "sub_123"
    assert inserted["stripe_customer_id"] == "cus_123"


@pytest.mark.asyncio
async def test_sync_stripe_subscription_tolerates_unparseable_period_end():
    stripe_subscription = {
        "id": "sub_456",
        "status": "active",
        "customer": "cus_456",
        "items": {"data": [{"price": {"id": "price_plus_monthly"}}]},
        "current_period_start": str(int(time.time()) - 86400),
        "current_period_end": "not-a-timestamp",
        "trial_end": None,
        "cancel_at_period_end": False,
    }

    with patch.multiple(settings, **_STRIPE_PRICE_IDS):
        db = _fresh_db()
        result = await SubscriptionService.sync_stripe_subscription(
            USER_ID, stripe_subscription, db
        )

    inserted = db.inserts[0][1]
    assert inserted["plan_type"] == "plus_monthly"
    assert inserted["current_period_end"] is None
    # A missing period end means no current entitlement.
    assert result.plan_type == PlanType.FREE


@pytest.mark.asyncio
async def test_sync_stripe_subscription_unknown_price_fails_closed():
    stripe_subscription = {
        "id": "sub_999",
        "status": "active",
        "items": {"data": [{"price": {"id": "price_unknown"}}]},
    }

    with patch.multiple(settings, **_STRIPE_PRICE_IDS):
        with pytest.raises(DatabaseError, match="unknown price"):
            await SubscriptionService.sync_stripe_subscription(
                USER_ID, stripe_subscription, FakeDB()
            )


@pytest.mark.asyncio
async def test_sync_stripe_subscription_skips_snapshot_for_replaced_subscription():
    db = FakeDB(
        rows={
            "subscriptions": [
                _subscription_row(
                    plan_type="plus_monthly",
                    stripe_subscription_id="sub_old",
                    current_period_end=(
                        datetime.now(timezone.utc) + timedelta(days=30)
                    ).isoformat(),
                )
            ]
        }
    )
    stripe_subscription = {
        "id": "sub_new",
        "status": "active",
        "customer": "cus_new",
        "items": {"data": [{"price": {"id": "price_pro_monthly"}}]},
        "current_period_start": str(int(time.time()) - 86400),
        "current_period_end": str(int(time.time()) + 30 * 86400),
        "trial_end": None,
        "cancel_at_period_end": False,
    }

    with patch.multiple(settings, **_STRIPE_PRICE_IDS):
        result = await SubscriptionService.sync_stripe_subscription(
            USER_ID, stripe_subscription, db
        )

    assert result.plan_type == PlanType.PLUS_MONTHLY
    assert db.inserts == []


@pytest.mark.asyncio
async def test_sync_stripe_subscription_skips_stale_snapshot_with_older_period_end():
    db = FakeDB(
        rows={
            "subscriptions": [
                _subscription_row(
                    plan_type="plus_monthly",
                    stripe_subscription_id="sub_same",
                    current_period_end=(
                        datetime.now(timezone.utc) + timedelta(days=90)
                    ).isoformat(),
                )
            ]
        }
    )
    stripe_subscription = {
        "id": "sub_same",
        "status": "active",
        "customer": "cus_x",
        "items": {"data": [{"price": {"id": "price_pro_monthly"}}]},
        "current_period_start": str(int(time.time()) - 86400),
        "current_period_end": str(int(time.time()) + 10 * 86400),
        "trial_end": None,
        "cancel_at_period_end": False,
    }

    with patch.multiple(settings, **_STRIPE_PRICE_IDS):
        result = await SubscriptionService.sync_stripe_subscription(
            USER_ID, stripe_subscription, db
        )

    assert result.plan_type == PlanType.PLUS_MONTHLY
    assert db.inserts == []


@pytest.mark.asyncio
async def test_sync_stripe_subscription_falls_back_to_read_when_upsert_returns_no_row():
    db = _NoRowUpsertDB(
        rows={
            "subscriptions": [
                _subscription_row(
                    plan_type="pro_monthly",
                    stripe_subscription_id="sub_777",
                    current_period_end=(
                        datetime.now(timezone.utc) + timedelta(days=30)
                    ).isoformat(),
                )
            ]
        }
    )
    stripe_subscription = {
        "id": "sub_777",
        "status": "active",
        "customer": "cus_777",
        "items": {"data": [{"price": {"id": "price_pro_monthly"}}]},
        "current_period_start": str(int(time.time()) - 86400),
        # Newer than the stored row's period end so the staleness guard passes.
        "current_period_end": str(int(time.time()) + 40 * 86400),
        "trial_end": None,
        "cancel_at_period_end": False,
    }

    with patch.multiple(settings, **_STRIPE_PRICE_IDS):
        result = await SubscriptionService.sync_stripe_subscription(
            USER_ID, stripe_subscription, db
        )

    assert result.plan_type == PlanType.PRO_MONTHLY


@pytest.mark.asyncio
async def test_sync_iap_subscription_rejects_non_paid_plan():
    with pytest.raises(DatabaseError, match="Store billing cannot map"):
        await SubscriptionService.sync_iap_subscription(
            USER_ID, FakeDB(), provider="apple", plan_type=PlanType.FREE, status="active"
        )


@pytest.mark.asyncio
async def test_sync_iap_subscription_free_without_row_falls_back_to_read():
    db = _fresh_db()

    result = await SubscriptionService.sync_iap_subscription(
        USER_ID,
        db,
        provider="apple",
        plan_type=PlanType.PRO_MONTHLY,
        status="free",
        apple_original_transaction_id="orig-1",
    )

    assert result.plan_type == PlanType.FREE
    assert db.updates[0][1]["plan_type"] == "free"
    # The fallback read created the default free row.
    assert any(row["plan_type"] == "free" for row in db.rows["subscriptions"])


@pytest.mark.asyncio
async def test_sync_iap_subscription_free_apple_keeps_legacy_downgrade_without_apple_id():
    db = FakeDB(
        rows={
            "subscriptions": [
                _subscription_row(
                    plan_type="pro_monthly",
                    billing_provider="apple",
                    apple_original_transaction_id="orig-1",
                )
            ]
        }
    )
    # A google identifier on an apple-provider call: no apple id to compare,
    # so the downgrade is not treated as stale (legacy behavior).
    result = await SubscriptionService.sync_iap_subscription(
        USER_ID,
        db,
        provider="apple",
        plan_type=PlanType.PRO_MONTHLY,
        status="free",
        google_purchase_token="gp-1",
    )

    assert result.plan_type == PlanType.FREE
    assert db.updates[0][1]["plan_type"] == "free"


@pytest.mark.asyncio
async def test_sync_iap_subscription_active_without_existing_row_creates_row():
    db = _fresh_db()
    start = (datetime.now(timezone.utc) - timedelta(days=10)).isoformat()
    end = (datetime.now(timezone.utc) + timedelta(days=20)).isoformat()

    result = await SubscriptionService.sync_iap_subscription(
        USER_ID,
        db,
        provider="google",
        plan_type=PlanType.PRO_MONTHLY,
        status="active",
        current_period_start=start,
        current_period_end=end,
        product_id="com.fitcheck.pro.monthly",
        google_purchase_token="gp-2",
        google_order_id="GPA.1234",
        cancel_at_period_end=True,
    )

    assert result.plan_type == PlanType.PRO_MONTHLY
    assert result.status == SubscriptionStatus.ACTIVE
    inserted = db.inserts[0][1]
    assert inserted["billing_provider"] == "google"
    assert inserted["google_purchase_token"] == "gp-2"
    assert inserted["google_order_id"] == "GPA.1234"
    assert inserted["apple_original_transaction_id"] is None
    assert inserted["stripe_subscription_id"] is None
    assert inserted["cancel_at_period_end"] is True


@pytest.mark.asyncio
async def test_sync_iap_subscription_release_without_previous_owner_is_silent():
    db = _fresh_db(
        rows={
            "subscriptions": [
                _subscription_row(
                    plan_type="pro_monthly",
                    billing_provider="apple",
                    apple_original_transaction_id="orig-9",
                    current_period_start=(
                        datetime.now(timezone.utc) - timedelta(days=10)
                    ).isoformat(),
                    current_period_end=(
                        datetime.now(timezone.utc) + timedelta(days=20)
                    ).isoformat(),
                )
            ]
        }
    )
    start = (datetime.now(timezone.utc) - timedelta(days=5)).isoformat()
    end = (datetime.now(timezone.utc) + timedelta(days=20)).isoformat()

    result = await SubscriptionService.sync_iap_subscription(
        USER_ID,
        db,
        provider="apple",
        plan_type=PlanType.PRO_MONTHLY,
        status="active",
        current_period_start=start,
        current_period_end=end,
        product_id="com.fitcheck.pro.monthly",
        apple_original_transaction_id="orig-9",
    )

    assert result.plan_type == PlanType.PRO_MONTHLY


@pytest.mark.asyncio
async def test_sync_iap_subscription_falls_back_to_read_when_upsert_returns_no_row():
    db = _NoRowUpsertDB(
        rows={
            "subscriptions": [
                _subscription_row(
                    plan_type="plus_monthly",
                    billing_provider="google",
                    current_period_start=(
                        datetime.now(timezone.utc) - timedelta(days=10)
                    ).isoformat(),
                    current_period_end=(
                        datetime.now(timezone.utc) + timedelta(days=20)
                    ).isoformat(),
                )
            ]
        }
    )
    start = (datetime.now(timezone.utc) - timedelta(days=5)).isoformat()
    end = (datetime.now(timezone.utc) + timedelta(days=20)).isoformat()

    result = await SubscriptionService.sync_iap_subscription(
        USER_ID,
        db,
        provider="google",
        plan_type=PlanType.PLUS_MONTHLY,
        status="active",
        current_period_start=start,
        current_period_end=end,
        product_id="com.fitcheck.plus.monthly",
    )

    assert result.plan_type == PlanType.PLUS_MONTHLY


@pytest.mark.asyncio
async def test_apply_referral_credit_creates_default_then_upgrades_free_plan():
    db = FakeDB()

    await SubscriptionService.apply_referral_credit(USER_ID, 3, db)

    assert db.inserts[0][1]["plan_type"] == "free"
    upgrade = db.updates[0][1]
    assert upgrade["plan_type"] == "pro_monthly"
    assert upgrade["status"] == "trial"
    assert upgrade["referral_credit_months"] == 3
    assert upgrade["trial_end"] is not None


@pytest.mark.asyncio
async def test_apply_referral_credit_raises_when_row_still_missing_after_creation(monkeypatch):
    db = FakeDB()
    monkeypatch.setattr(SubscriptionService, "create_default_subscription", AsyncMock())

    with pytest.raises(DatabaseError, match="Failed to apply referral credit"):
        await SubscriptionService.apply_referral_credit(USER_ID, 3, db)


# =============================================================================
# Usage tracking
# =============================================================================


def test_get_current_period_end_returns_last_day_of_current_month():
    period_end = SubscriptionService._get_current_period_end()
    assert period_end.day == calendar.monthrange(period_end.year, period_end.month)[1]


@pytest.mark.asyncio
async def test_get_or_create_usage_record_raises_when_reload_returns_nothing(monkeypatch):
    async def _empty(*args, **kwargs):
        return FakeResult(data=None)

    monkeypatch.setattr(subscription_module, "execute_with_reconnect", _empty)

    with pytest.raises(DatabaseError, match="Failed to create usage record"):
        await SubscriptionService.get_or_create_usage_record(USER_ID, FakeDB())


@pytest.mark.asyncio
async def test_get_or_create_usage_record_creates_row_when_single_raises_pgrst116(monkeypatch):
    db = _UsageUpsertDB()
    calls = {"n": 0}

    async def _flaky(builder, d, **kwargs):
        calls["n"] += 1
        if calls["n"] == 1:
            raise Exception(
                "PGRST116: JSON object requested, multiple (or no) rows returned"
            )
        return await real_execute_with_reconnect(builder, d, **kwargs)

    monkeypatch.setattr(subscription_module, "execute_with_reconnect", _flaky)

    record = await SubscriptionService.get_or_create_usage_record(USER_ID, db)

    assert record["user_id"] == USER_ID
    assert record["monthly_extractions"] == 0
    assert record["monthly_generations"] == 0


@pytest.mark.asyncio
async def test_get_usage_fetches_subscription_and_usage_concurrently():
    db = FakeDB(
        rows={
            "subscriptions": [_subscription_row()],
            "subscription_usage": [
                _usage_row(
                    monthly_extractions=10,
                    monthly_generations=5,
                    monthly_embeddings=3,
                )
            ],
        }
    )

    usage = await SubscriptionService.get_usage(USER_ID, db)

    assert usage.monthly_extractions_limit == settings.PLAN_FREE_MONTHLY_EXTRACTIONS
    assert usage.monthly_extractions == 10
    assert (
        usage.monthly_extractions_remaining
        == settings.PLAN_FREE_MONTHLY_EXTRACTIONS - 10
    )
    assert (
        usage.monthly_generations_remaining
        == settings.PLAN_FREE_MONTHLY_GENERATIONS - 5
    )
    assert (
        usage.monthly_embeddings_remaining
        == settings.PLAN_FREE_MONTHLY_EMBEDDINGS - 3
    )
    assert usage.period_start is not None
    assert usage.period_end is not None


@pytest.mark.asyncio
async def test_get_usage_accepts_prefetched_subscription():
    db = FakeDB(
        rows={
            "subscriptions": [_subscription_row()],
            "subscription_usage": [_usage_row()],
        }
    )
    subscription = await SubscriptionService.get_subscription(USER_ID, db)

    usage = await SubscriptionService.get_usage(USER_ID, db, subscription=subscription)

    assert usage.monthly_extractions_limit == settings.PLAN_FREE_MONTHLY_EXTRACTIONS
    assert usage.monthly_extractions == 0


@pytest.mark.asyncio
async def test_get_usage_wraps_subscription_failure(monkeypatch):
    db = FakeDB()
    monkeypatch.setattr(
        SubscriptionService,
        "get_subscription",
        AsyncMock(side_effect=DatabaseError("boom")),
    )

    with pytest.raises(DatabaseError, match="Failed to get usage"):
        await SubscriptionService.get_usage(USER_ID, db)


def test_coerce_operation_type_rejects_unknown_values():
    with pytest.raises(ValueError, match="Unknown operation type: bogus"):
        SubscriptionService._coerce_operation_type("bogus")


@pytest.mark.asyncio
async def test_check_limit_at_cap_upsells_free_users():
    db = FakeDB(
        rows={
            "subscriptions": [_subscription_row()],
            "subscription_usage": [
                _usage_row(monthly_extractions=settings.PLAN_FREE_MONTHLY_EXTRACTIONS)
            ],
        }
    )

    result = await SubscriptionService.check_limit(USER_ID, "extraction", db)

    assert result.allowed is False
    assert result.remaining == 0
    assert result.plan_type == PlanType.FREE
    assert "Upgrade to Pro for more!" in result.message


@pytest.mark.asyncio
async def test_check_limit_at_cap_does_not_upsell_pro_users():
    db = FakeDB(
        rows={
            "subscriptions": [
                _subscription_row(
                    plan_type="pro_monthly",
                    current_period_end=(
                        datetime.now(timezone.utc) + timedelta(days=30)
                    ).isoformat(),
                )
            ],
            "subscription_usage": [
                _usage_row(monthly_extractions=settings.PLAN_PRO_MONTHLY_EXTRACTIONS)
            ],
        }
    )

    result = await SubscriptionService.check_limit(USER_ID, "extraction", db)

    assert result.allowed is False
    assert result.plan_type == PlanType.PRO_MONTHLY
    assert "Your limit resets at the start of the next month." in result.message
    assert "Upgrade to Pro" not in result.message


@pytest.mark.asyncio
async def test_increment_usage_raises_rate_limit_when_reservation_rejected():
    db = FakeDB(
        rows={
            "subscriptions": [_subscription_row()],
            "subscription_usage": [_usage_row()],
        },
        rpc_results={"reserve_usage": [{"reserve_usage": False}]},
    )

    with pytest.raises(RateLimitError, match="monthly extraction limit"):
        await SubscriptionService.increment_usage(USER_ID, "extraction", db)


@pytest.mark.asyncio
async def test_increment_usage_fails_closed_when_reservation_rpc_missing(monkeypatch):
    async def _missing_rpc(*args, **kwargs):
        raise Exception(
            "PGRST202: Could not find the function reserve_usage in the schema cache"
        )

    monkeypatch.setattr(subscription_module, "execute_with_reconnect", _missing_rpc)

    with pytest.raises(AIServiceError) as excinfo:
        await SubscriptionService.increment_usage(USER_ID, "extraction", FakeDB())

    assert excinfo.value.retryable is True
    assert str(excinfo.value) == QUOTA_UNAVAILABLE_CLIENT_MESSAGE


@pytest.mark.asyncio
async def test_increment_usage_wraps_unexpected_errors(monkeypatch):
    async def _boom(*args, **kwargs):
        raise RuntimeError("reservation exploded")

    monkeypatch.setattr(subscription_module, "execute_with_reconnect", _boom)

    with pytest.raises(AIServiceError) as excinfo:
        await SubscriptionService.increment_usage(USER_ID, "extraction", FakeDB())

    assert excinfo.value.retryable is True


# =============================================================================
# Combined methods
# =============================================================================


@pytest.mark.asyncio
async def test_get_subscription_with_usage_combines_both():
    db = FakeDB(
        rows={
            "subscriptions": [_subscription_row()],
            "subscription_usage": [_usage_row(monthly_extractions=4)],
        }
    )

    combined = await SubscriptionService.get_subscription_with_usage(USER_ID, db)

    assert combined.subscription.plan_type == PlanType.FREE
    assert combined.usage.monthly_extractions == 4
    assert combined.usage.monthly_extractions_remaining == (
        settings.PLAN_FREE_MONTHLY_EXTRACTIONS - 4
    )
