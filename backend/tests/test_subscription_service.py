"""
Unit tests for SubscriptionService - the core billing logic controlling
whether a paying user is actually upgraded/downgraded/cancelled.

Previously had zero test coverage despite directly controlling revenue-path
correctness (see architecture review, section 16).
"""
from unittest.mock import Mock, patch
from datetime import datetime

import httpx
import pytest

from app.core.exceptions import DatabaseError
from app.models.subscription import PlanType
from app.services.subscription_service import SubscriptionService

USER_ID = "11111111-1111-1111-1111-111111111111"


def _subscription_row(**overrides):
    row = {
        "id": "22222222-2222-2222-2222-222222222222",
        "user_id": USER_ID,
        "plan_type": "free",
        "status": "active",
        "current_period_start": datetime.utcnow().isoformat(),
        "current_period_end": None,
        "cancel_at_period_end": False,
        "trial_end": None,
        "referral_credit_months": 0,
        "created_at": datetime.utcnow().isoformat(),
        "updated_at": datetime.utcnow().isoformat(),
    }
    row.update(overrides)
    return row


def _mock_maybe_single(db, row_or_none):
    """Wire db.table(...).select(...).eq(...).maybe_single().execute() to return row_or_none."""
    result = Mock()
    result.data = row_or_none
    chain = db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value
    chain.execute.return_value = result if row_or_none is not None else None


@pytest.mark.asyncio
async def test_get_subscription_returns_existing_row():
    db = Mock()
    _mock_maybe_single(db, _subscription_row(plan_type="pro_monthly", status="active"))

    result = await SubscriptionService.get_subscription(USER_ID, db)

    assert result.plan_type == PlanType.PRO_MONTHLY
    assert result.is_pro is True


@pytest.mark.asyncio
async def test_get_subscription_creates_default_when_none_exists():
    db = Mock()
    # First lookup: no row. Upsert happens. Second lookup: row now exists.
    result_missing = None
    result_created = Mock()
    result_created.data = _subscription_row()
    chain = db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value
    chain.execute.side_effect = [result_missing, result_created]

    result = await SubscriptionService.get_subscription(USER_ID, db)

    assert result.plan_type == PlanType.FREE
    db.table.return_value.upsert.assert_called_once()


@pytest.mark.asyncio
async def test_get_subscription_raises_if_still_missing_after_creation():
    db = Mock()
    chain = db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value
    chain.execute.side_effect = [None, None]

    with pytest.raises(DatabaseError):
        await SubscriptionService.get_subscription(USER_ID, db)


@pytest.mark.asyncio
async def test_upgrade_to_pro_upserts_and_returns_pro_subscription():
    db = Mock()
    _mock_maybe_single(db, _subscription_row(plan_type="pro_yearly", status="active"))

    result = await SubscriptionService.upgrade_to_pro(
        user_id=USER_ID,
        plan_type=PlanType.PRO_YEARLY,
        stripe_customer_id="cus_123",
        stripe_subscription_id="sub_123",
        db=db,
    )

    assert result.plan_type == PlanType.PRO_YEARLY
    upsert_call = db.table.return_value.upsert.call_args
    assert upsert_call.args[0]["stripe_customer_id"] == "cus_123"
    assert upsert_call.args[0]["stripe_subscription_id"] == "sub_123"


@pytest.mark.asyncio
async def test_cancel_subscription_sets_cancel_at_period_end():
    db = Mock()
    _mock_maybe_single(db, _subscription_row(cancel_at_period_end=True))

    await SubscriptionService.cancel_subscription(USER_ID, db)

    update_call = db.table.return_value.update.call_args
    assert update_call.args[0]["cancel_at_period_end"] is True


@pytest.mark.asyncio
async def test_apply_referral_credit_upgrades_free_plan_to_trial():
    db = Mock()
    _mock_maybe_single(db, _subscription_row(plan_type="free", referral_credit_months=0))

    await SubscriptionService.apply_referral_credit(USER_ID, months=2, db=db)

    update_call = db.table.return_value.update.call_args
    assert update_call.args[0]["status"] == "trial"
    assert update_call.args[0]["referral_credit_months"] == 2


@pytest.mark.asyncio
async def test_apply_referral_credit_adds_to_existing_pro_credit_balance():
    db = Mock()
    _mock_maybe_single(
        db, _subscription_row(plan_type="pro_monthly", referral_credit_months=3)
    )

    await SubscriptionService.apply_referral_credit(USER_ID, months=1, db=db)

    update_call = db.table.return_value.update.call_args
    assert update_call.args[0]["referral_credit_months"] == 4
    assert "status" not in update_call.args[0]


@pytest.mark.asyncio
async def test_check_limit_retries_once_on_dead_http2_connection():
    """Regression test: retry classification must use isinstance, not
    string-matching str(e), which silently breaks if an exception's repr
    format changes."""
    call_count = {"n": 0}

    async def fake_get_subscription(user_id, db):
        call_count["n"] += 1
        if call_count["n"] == 1:
            raise httpx.RemoteProtocolError("Server disconnected without sending a response.")
        return Mock(plan_type=PlanType.FREE, is_pro=False)

    with patch.object(SubscriptionService, "get_subscription", side_effect=fake_get_subscription), \
         patch.object(SubscriptionService, "get_plan_limits", return_value={"monthly_extractions": 10}), \
         patch.object(SubscriptionService, "get_or_create_usage_record", return_value={"monthly_extractions": 0}), \
         patch("app.db.connection.SupabaseDB") as mock_supabase_db:
        mock_supabase_db.get_service_client.return_value = Mock()
        result = await SubscriptionService.check_limit(USER_ID, "extraction", db=Mock())

    assert result.allowed is True
    assert call_count["n"] == 2
    mock_supabase_db.reset.assert_called_once()


@pytest.mark.asyncio
async def test_check_limit_does_not_retry_on_unrelated_error():
    with patch.object(
        SubscriptionService, "get_subscription", side_effect=ValueError("Unknown operation type: extraction")
    ):
        with pytest.raises(DatabaseError):
            await SubscriptionService.check_limit(USER_ID, "extraction", db=Mock())
