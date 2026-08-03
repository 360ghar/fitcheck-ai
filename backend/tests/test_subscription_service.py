"""
Unit tests for SubscriptionService - the core billing logic controlling
whether a paying user is actually upgraded/downgraded/cancelled.

Previously had zero test coverage despite directly controlling revenue-path
correctness (see architecture review, section 16).
"""
from unittest.mock import AsyncMock, Mock, patch
from datetime import datetime, timezone, timedelta

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
        "current_period_start": datetime.now(timezone.utc).isoformat(),
        "current_period_end": None,
        "cancel_at_period_end": False,
        "trial_end": None,
        "referral_credit_months": 0,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "updated_at": datetime.now(timezone.utc).isoformat(),
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
    _mock_maybe_single(db, _subscription_row(
        plan_type="pro_monthly",
        status="active",
        current_period_end=(datetime.now(timezone.utc) + timedelta(days=30)).isoformat(),
    ))

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
    upsert_call = db.table.return_value.upsert.call_args
    assert upsert_call.args[0]["user_id"] == USER_ID
    assert upsert_call.args[0]["plan_type"] == "free"
    assert upsert_call.args[0]["status"] == "active"


@pytest.mark.asyncio
async def test_get_subscription_raises_if_still_missing_after_creation():
    db = Mock()
    chain = db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value
    chain.execute.side_effect = [None, None]

    with pytest.raises(DatabaseError):
        await SubscriptionService.get_subscription(USER_ID, db)


@pytest.mark.asyncio
async def test_get_or_create_usage_record_uses_insert_only_upsert_and_reloads():
    """The usage-record create must use an insert-only upsert (DO NOTHING) so a
    concurrent caller's increments are never wiped, and must re-select the
    authoritative row instead of returning the local zeroed dict."""
    db = Mock()
    row = {
        "user_id": USER_ID,
        "period_start": "2026-08-01",
        "monthly_extractions": 4,
        "monthly_generations": 2,
        "monthly_embeddings": 0,
    }
    result = Mock()
    result.data = row
    # First select: no row. Upsert: no-op. Re-select: the (already
    # incremented) authoritative row.
    chain = (
        db.table.return_value.select.return_value.eq.return_value.eq.return_value.single.return_value
    )
    chain.execute.side_effect = [Mock(data=None), result]

    usage = await SubscriptionService.get_or_create_usage_record(USER_ID, db)

    assert usage["monthly_extractions"] == 4
    upsert_call = db.table.return_value.upsert.call_args
    assert upsert_call.kwargs["on_conflict"] == "user_id,period_start"
    assert upsert_call.kwargs["ignore_duplicates"] is True


@pytest.mark.asyncio
async def test_upgrade_to_pro_upserts_and_returns_pro_subscription():
    db = Mock()
    _mock_maybe_single(db, _subscription_row(
        plan_type="pro_yearly",
        status="active",
        current_period_end=(datetime.now(timezone.utc) + timedelta(days=30)).isoformat(),
    ))

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
async def test_upgrade_to_plus_yearly_sets_one_year_period_end():
    """A *_yearly plan must get a 1-year period, not the monthly fallback.

    The period math previously special-cased PRO_YEARLY only, so a Plus yearly
    subscriber would have been billed for a year but granted one month.
    """
    db = Mock()
    _mock_maybe_single(db, _subscription_row(
        plan_type="plus_yearly",
        status="active",
        current_period_end=(datetime.now(timezone.utc) + timedelta(days=30)).isoformat(),
    ))

    result = await SubscriptionService.upgrade_to_pro(
        user_id=USER_ID,
        plan_type=PlanType.PLUS_YEARLY,
        stripe_customer_id="cus_plus",
        stripe_subscription_id="sub_plus",
        db=db,
    )

    assert result.plan_type == PlanType.PLUS_YEARLY
    payload = db.table.return_value.upsert.call_args.args[0]
    assert payload["plan_type"] == "plus_yearly"
    start = datetime.fromisoformat(payload["current_period_start"])
    end = datetime.fromisoformat(payload["current_period_end"])
    assert (end - start).days >= 365


@pytest.mark.parametrize(
    "plan_type,expected",
    [
        (PlanType.FREE, False),
        (PlanType.PLUS_MONTHLY, True),
        (PlanType.PLUS_YEARLY, True),
        (PlanType.PRO_MONTHLY, True),
        (PlanType.PRO_YEARLY, True),
    ],
)
def test_is_paid_plan_treats_plus_as_entitled(plan_type, expected):
    """Plus unlocks the same features as Pro; only usage limits differ."""
    assert SubscriptionService.is_paid_plan(plan_type) is expected
    # is_pro_plan is the legacy alias feeding SubscriptionResponse.is_pro
    assert SubscriptionService.is_pro_plan(plan_type) is expected


@pytest.mark.parametrize(
    "status,end_field,expected",
    [
        ("active", "current_period_end", PlanType.PRO_MONTHLY),
        ("active", "current_period_end", PlanType.FREE),
        ("past_due", "current_period_end", PlanType.FREE),
        ("cancelled", "current_period_end", PlanType.FREE),
        ("trial", "trial_end", PlanType.PRO_MONTHLY),
        ("trial", "trial_end", PlanType.FREE),
    ],
)
def test_effective_plan_requires_valid_status_and_expiry(status, end_field, expected):
    from datetime import timedelta

    now = datetime.now(timezone.utc)
    end = now + timedelta(days=7) if expected != PlanType.FREE else now - timedelta(seconds=1)
    current_end = end if end_field == "current_period_end" else None
    trial_end = end if end_field == "trial_end" else None
    assert SubscriptionService.effective_plan_type(
        PlanType.PRO_MONTHLY,
        status,
        current_end,
        trial_end,
        now=now,
    ) == expected


@pytest.mark.parametrize(
    "plan_type,expected",
    [
        (PlanType.FREE, True),
        (PlanType.PLUS_MONTHLY, True),
        (PlanType.PLUS_YEARLY, True),
        (PlanType.PRO_MONTHLY, False),
        (PlanType.PRO_YEARLY, False),
    ],
)
def test_can_upgrade_offers_pro_to_plus_users(plan_type, expected):
    """Plus is paid but NOT the top tier - it must still get an upsell.

    Gating upgrade CTAs on is_paid_plan would strand Plus subscribers with no
    route to Pro; gating them on `not is_paid_plan` is the same bug.
    """
    assert SubscriptionService.can_upgrade(plan_type) is expected


@pytest.mark.parametrize(
    "plan_type,expected",
    [
        (PlanType.FREE, "Free"),
        (PlanType.PLUS_MONTHLY, "Plus"),
        (PlanType.PLUS_YEARLY, "Plus"),
        (PlanType.PRO_MONTHLY, "Pro"),
        (PlanType.PRO_YEARLY, "Pro"),
    ],
)
def test_plan_display_name(plan_type, expected):
    assert SubscriptionService.plan_display_name(plan_type) == expected


def test_get_plan_limits_returns_distinct_tier_for_plus():
    """Plus limits must sit strictly between Free and Pro."""
    free = SubscriptionService.get_plan_limits(PlanType.FREE)
    plus = SubscriptionService.get_plan_limits(PlanType.PLUS_MONTHLY)
    pro = SubscriptionService.get_plan_limits(PlanType.PRO_MONTHLY)

    assert plus == SubscriptionService.get_plan_limits(PlanType.PLUS_YEARLY)
    for field in ("monthly_extractions", "monthly_generations", "monthly_embeddings"):
        assert free[field] < plus[field] < pro[field], field


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



@pytest.mark.asyncio
async def test_increment_usage_retries_once_on_dead_http2_connection():
    """increment_usage (observed 2026-08-01: ConnectionTerminated on this exact
    path) rebuilds the Supabase singleton and retries the whole reservation
    once through the fresh client instead of failing the request."""
    call_count = {"n": 0}

    def fake_rpc():
        call_count["n"] += 1
        if call_count["n"] == 1:
            raise httpx.RemoteProtocolError("<ConnectionTerminated error_code:1>")
        return Mock(data=[{"reserve_usage": True}])

    fake_db = Mock()
    fake_db.rpc.return_value.execute = fake_rpc

    with patch.object(SubscriptionService, "get_or_create_usage_record", new=AsyncMock()),          patch.object(
             SubscriptionService, "get_subscription",
             return_value=Mock(plan_type=PlanType.FREE),
         ),          patch.object(SubscriptionService, "get_plan_limits", return_value={"monthly_extractions": 10}),          patch("app.db.connection.SupabaseDB") as mock_supabase_db:
        mock_supabase_db.get_service_client.return_value = fake_db
        await SubscriptionService.increment_usage(USER_ID, "extraction", db=fake_db)

    assert call_count["n"] == 2
    mock_supabase_db.reset.assert_called_once()


# =============================================================================
# Store-billed (IAP) subscription sync
# =============================================================================


@pytest.mark.asyncio
async def test_sync_iap_subscription_persists_apple_fields():
    db = Mock()
    existing = _subscription_row(plan_type="free")
    updated = _subscription_row(
        plan_type="plus_monthly",
        status="active",
        billing_provider="apple",
        current_period_end=(datetime.now(timezone.utc) + timedelta(days=30)).isoformat(),
    )
    chain = db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value
    chain.execute.side_effect = [Mock(data=existing), Mock(data=updated)]

    result = await SubscriptionService.sync_iap_subscription(
        USER_ID,
        db,
        provider="apple",
        plan_type=PlanType.PLUS_MONTHLY,
        status="active",
        current_period_end=(datetime.now(timezone.utc) + timedelta(days=30)).isoformat(),
        product_id="com.fitcheck.plus.monthly",
        apple_original_transaction_id="orig-1",
    )

    assert result.plan_type == PlanType.PLUS_MONTHLY
    payload = db.table.return_value.upsert.call_args.args[0]
    assert payload["billing_provider"] == "apple"
    assert payload["apple_original_transaction_id"] == "orig-1"
    assert payload["google_purchase_token"] is None
    assert payload["stripe_subscription_id"] is None
    assert payload["billing_product_id"] == "com.fitcheck.plus.monthly"


@pytest.mark.asyncio
async def test_sync_iap_subscription_google_clears_apple_identity():
    db = Mock()
    existing = _subscription_row(plan_type="free")
    updated = _subscription_row(
        plan_type="pro_yearly",
        status="active",
        billing_provider="google",
    )
    chain = db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value
    chain.execute.side_effect = [Mock(data=existing), Mock(data=updated)]

    await SubscriptionService.sync_iap_subscription(
        USER_ID,
        db,
        provider="google",
        plan_type=PlanType.PRO_YEARLY,
        status="active",
        product_id="com.fitcheck.pro.yearly",
        google_purchase_token="token-abc",
        google_order_id="GPA.1",
    )

    payload = db.table.return_value.upsert.call_args.args[0]
    assert payload["billing_provider"] == "google"
    assert payload["google_purchase_token"] == "token-abc"
    assert payload["google_order_id"] == "GPA.1"
    assert payload["apple_original_transaction_id"] is None


@pytest.mark.asyncio
async def test_sync_iap_subscription_free_status_downgrades():
    db = Mock()
    existing = _subscription_row(plan_type="plus_monthly", billing_provider="apple")
    updated = _subscription_row(plan_type="free", status="active", billing_provider="apple")
    chain = db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value
    chain.execute.side_effect = [Mock(data=existing), Mock(data=updated)]

    result = await SubscriptionService.sync_iap_subscription(
        USER_ID,
        db,
        provider="apple",
        plan_type=PlanType.PRO_MONTHLY,  # ignored on the downgrade path
        status="free",
    )

    assert result.plan_type == PlanType.FREE
    update_call = db.table.return_value.update.call_args
    assert update_call.args[0]["plan_type"] == "free"
    assert update_call.args[0]["apple_original_transaction_id"] is None
    assert db.table.return_value.upsert.called is False


@pytest.mark.asyncio
async def test_sync_iap_subscription_skips_stale_snapshot():
    db = Mock()
    newer_end = (datetime.now(timezone.utc) + timedelta(days=30)).isoformat()
    existing = _subscription_row(
        plan_type="plus_monthly",
        billing_provider="apple",
        current_period_end=newer_end,
    )
    chain = db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value
    chain.execute.side_effect = [Mock(data=existing), Mock(data=existing)]

    result = await SubscriptionService.sync_iap_subscription(
        USER_ID,
        db,
        provider="apple",
        plan_type=PlanType.PLUS_MONTHLY,
        status="active",
        current_period_end=(datetime.now(timezone.utc) + timedelta(days=5)).isoformat(),
        product_id="com.fitcheck.plus.monthly",
        apple_original_transaction_id="orig-1",
    )

    assert result.plan_type == PlanType.PLUS_MONTHLY
    assert db.table.return_value.upsert.called is False


@pytest.mark.asyncio
async def test_sync_iap_subscription_rejects_unknown_status():
    db = Mock()
    _mock_maybe_single(db, _subscription_row())

    with pytest.raises(DatabaseError, match="refusing to grant"):
        await SubscriptionService.sync_iap_subscription(
            USER_ID, db, provider="apple", plan_type=PlanType.PLUS_MONTHLY, status="entitled"
        )


@pytest.mark.asyncio
async def test_sync_iap_subscription_rejects_unknown_provider():
    db = Mock()
    with pytest.raises(DatabaseError, match="Unknown billing provider"):
        await SubscriptionService.sync_iap_subscription(
            USER_ID, db, provider="amazon", plan_type=PlanType.PLUS_MONTHLY, status="active"
        )


@pytest.mark.asyncio
async def test_cancel_subscription_refuses_store_billed_rows():
    db = Mock()
    _mock_maybe_single(db, _subscription_row(plan_type="plus_monthly", billing_provider="apple"))

    with pytest.raises(DatabaseError, match="App Store"):
        await SubscriptionService.cancel_subscription(USER_ID, db)

    assert db.table.return_value.update.called is False
