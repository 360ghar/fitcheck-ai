"""
Route-level coverage for app/api/v1/subscription.py.

Complements tests/integration/test_subscription_checkout.py,
tests/integration/test_stripe_webhook.py and
tests/integration/test_wave_b_hardening.py by covering the branches they
leave open: plans/current-plan/usage routes, the billing fail-closed gates,
price-id fallback, the existing-customer checkout path, portal sessions,
cancel edge cases, and the webhook ledger state machine (processing lease,
CAS claim, failure marking).
"""
from datetime import timedelta
from unittest.mock import AsyncMock, Mock, patch

import pytest
import stripe
from fastapi import HTTPException

from app.api.v1 import subscription as subscription_api
from app.api.v1.subscription import (
    cancel_subscription,
    create_checkout_session,
    create_portal_session,
    get_plans,
    get_subscription,
    get_usage,
    stripe_webhook,
)
from app.core.config import settings
from app.core.exceptions import (
    BillingNotConfiguredError,
    ServiceError,
    ValidationError,
)
from app.models.subscription import CreateCheckoutRequest, PlanType
from app.services.subscription_service import SubscriptionService
from app.utils.datetime_util import utcnow, utcnow_iso


def _stripe_settings():
    return {
        "STRIPE_SECRET_KEY": "sk_test",
        "STRIPE_PLUS_MONTHLY_PRICE_ID": "price_plus_monthly",
        "STRIPE_PLUS_YEARLY_PRICE_ID": "price_plus_yearly",
        "STRIPE_PRO_MONTHLY_PRICE_ID": "price_pro_monthly",
        "STRIPE_PRO_YEARLY_PRICE_ID": "price_pro_yearly",
    }


def _db_with_subscription(row):
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = (
        Mock(data=row)
    )
    return db


def _async_return(value):
    async def _inner(*args, **kwargs):
        return value

    return _inner


class _WebhookDB:
    """Mock db for the stripe webhook ledger with configurable chains.

    The ledger insert/select/claim/final all run through ``db.table()``; this
    helper exposes each chain's ``execute`` so a test can stage results or
    exceptions per call (the eq-eq chain is shared by the claim and the final
    processed update, so multi-call tests use ``side_effect`` lists).
    """

    def __init__(self):
        self.db = Mock()
        tbl = self.db.table.return_value
        self.insert_execute = tbl.insert.return_value.execute
        self.select_execute = tbl.select.return_value.eq.return_value.maybe_single.return_value.execute
        self.is_claim_execute = tbl.update.return_value.eq.return_value.is_.return_value.execute
        self.eq_claim_execute = tbl.update.return_value.eq.return_value.eq.return_value.execute
        self.insert_execute.return_value = Mock(data=[])
        self.is_claim_execute.return_value = Mock(data=[{"claimed": True}])
        self.eq_claim_execute.return_value = Mock(data=[{"done": True}])


def _webhook_request() -> Mock:
    request = Mock()
    request.body = _async_return(b"{}")
    request.headers = {"stripe-signature": "sig_test"}
    return request


# ---------------------------------------------------------------------------
# Current subscription + usage + plans
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_subscription_route_returns_the_envelope():
    with patch.object(
        SubscriptionService,
        "get_subscription_with_usage",
        new=AsyncMock(
            return_value=Mock(model_dump=lambda mode="json": {"plan_type": "pro_monthly"})
        ),
    ) as service:
        result = await get_subscription(user={"id": "user-1"}, db=Mock())

    assert result["message"] == "OK"
    assert result["data"]["plan_type"] == "pro_monthly"
    assert service.await_args.args[0] == "user-1"


@pytest.mark.asyncio
async def test_get_usage_route_returns_the_envelope():
    with patch.object(
        SubscriptionService,
        "get_usage",
        new=AsyncMock(
            return_value=Mock(model_dump=lambda mode="json": {"monthly_extractions": 4})
        ),
    ) as service:
        result = await get_usage(user={"id": "user-1"}, db=Mock())

    assert result["message"] == "OK"
    assert result["data"]["monthly_extractions"] == 4
    assert service.await_args.args[0] == "user-1"


@pytest.mark.asyncio
async def test_get_plans_reports_billing_unconfigured_and_flattened_limits():
    with patch.multiple(
        settings,
        PLAN_FREE_MONTHLY_EXTRACTIONS=3,
        PLAN_FREE_MONTHLY_GENERATIONS=10,
        PLAN_FREE_MONTHLY_EMBEDDINGS=100,
        PLAN_PLUS_MONTHLY_EXTRACTIONS=30,
        PLAN_PLUS_MONTHLY_GENERATIONS=50,
        PLAN_PLUS_MONTHLY_EMBEDDINGS=500,
        PLAN_PRO_MONTHLY_EXTRACTIONS=100,
        PLAN_PRO_MONTHLY_GENERATIONS=200,
        PLAN_PRO_MONTHLY_EMBEDDINGS=1000,
        PLAN_PLUS_MONTHLY_PRICE=9,
        PLAN_PLUS_YEARLY_PRICE=90,
        PLAN_PRO_MONTHLY_PRICE=19,
        PLAN_PRO_YEARLY_PRICE=190,
        STRIPE_SECRET_KEY=None,
        STRIPE_PLUS_MONTHLY_PRICE_ID=None,
        STRIPE_PLUS_YEARLY_PRICE_ID=None,
        STRIPE_PRO_MONTHLY_PRICE_ID=None,
        STRIPE_PRO_YEARLY_PRICE_ID=None,
        APPLE_PLUS_MONTHLY_PRODUCT_ID=None,
        APPLE_PLUS_YEARLY_PRODUCT_ID=None,
        APPLE_PRO_MONTHLY_PRODUCT_ID=None,
        APPLE_PRO_YEARLY_PRODUCT_ID=None,
        GOOGLE_PLUS_MONTHLY_PRODUCT_ID=None,
        GOOGLE_PLUS_YEARLY_PRODUCT_ID=None,
        GOOGLE_PRO_MONTHLY_PRODUCT_ID=None,
        GOOGLE_PRO_YEARLY_PRODUCT_ID=None,
    ):
        result = await get_plans()

    data = result["data"]
    assert result["message"] == "OK"
    assert data["billing_configured"] is False
    assert [p["id"] for p in data["plans"]] == ["free", "plus", "pro"]
    # Flutter clients expect flattened limit keys next to the nested dict.
    assert data["plans"][0]["monthly_extractions"] == 3
    assert data["plans"][0]["limits"] == {
        "monthly_extractions": 3,
        "monthly_generations": 10,
        "monthly_embeddings": 100,
    }
    plus = data["plans"][1]
    assert plus["savings_yearly"] == 18  # (9 * 12) - 90
    assert plus["price_yearly"] == 90
    assert set(data["store_products"]) == {"apple", "google"}
    assert data["store_products"]["apple"]["plus_monthly"] is None


@pytest.mark.asyncio
async def test_get_plans_reports_billing_configured_when_all_stripe_ids_present():
    with patch.multiple(settings, **_stripe_settings()):
        result = await get_plans()

    assert result["data"]["billing_configured"] is True


# ---------------------------------------------------------------------------
# Checkout: fail-closed gates and error branches
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_checkout_fails_closed_when_billing_not_configured():
    request = CreateCheckoutRequest(plan_type=PlanType.PRO_MONTHLY)

    with patch.object(subscription_api, "_stripe_billing_configured", return_value=False):
        with pytest.raises(BillingNotConfiguredError, match="promo code"):
            await create_checkout_session(request, user={"id": "user-1"}, db=Mock())


@pytest.mark.asyncio
async def test_checkout_rejects_the_free_plan():
    request = CreateCheckoutRequest(plan_type=PlanType.FREE)

    with patch.object(subscription_api, "_stripe_billing_configured", return_value=True):
        with pytest.raises(ValidationError, match="free plan"):
            await create_checkout_session(request, user={"id": "user-1"}, db=Mock())


@pytest.mark.asyncio
async def test_checkout_fails_when_price_id_is_not_configured():
    """A mapped plan whose price ID env var is empty must fail closed instead
    of silently charging a different plan."""
    db = _db_with_subscription({"plan_type": "free", "stripe_subscription_id": None})
    request = CreateCheckoutRequest(plan_type=PlanType.PLUS_MONTHLY)

    with patch.object(subscription_api, "_stripe_billing_configured", return_value=True), patch.object(
        settings, "STRIPE_PLUS_MONTHLY_PRICE_ID", ""
    ), patch.object(
        SubscriptionService, "get_subscription", new=AsyncMock()
    ), patch.object(stripe.checkout.Session, "create") as session_create:
        with pytest.raises(ServiceError, match="price not configured"):
            await create_checkout_session(request, user={"id": "user-1"}, db=db)

    session_create.assert_not_called()


@pytest.mark.asyncio
async def test_checkout_existing_subscription_without_item_fails():
    db = _db_with_subscription(
        {
            "plan_type": "plus_monthly",
            "stripe_subscription_id": "sub_x",
            "stripe_customer_id": "cus_x",
            "billing_provider": "stripe",
        }
    )
    request = CreateCheckoutRequest(plan_type=PlanType.PRO_MONTHLY)

    with patch.multiple(settings, **_stripe_settings()), patch.object(
        SubscriptionService, "get_subscription", new=AsyncMock()
    ), patch.object(
        stripe.Subscription, "retrieve",
        return_value={"id": "sub_x", "items": {"data": []}},
    ), patch.object(stripe.checkout.Session, "create") as session_create:
        with pytest.raises(ServiceError, match="no subscription item"):
            await create_checkout_session(request, user={"id": "user-1"}, db=db)

    session_create.assert_not_called()


@pytest.mark.asyncio
async def test_checkout_modifies_without_sync_when_stripe_response_is_compact():
    """A Stripe modify response without expanded items still counts as the
    in-place update; the webhook remains authoritative (no sync yet)."""
    db = _db_with_subscription(
        {
            "plan_type": "plus_monthly",
            "stripe_subscription_id": "sub_x",
            "stripe_customer_id": "cus_x",
            "billing_provider": "stripe",
        }
    )
    request = CreateCheckoutRequest(plan_type=PlanType.PRO_MONTHLY)

    with patch.multiple(settings, **_stripe_settings()), patch.object(
        SubscriptionService, "get_subscription", new=AsyncMock()
    ), patch.object(
        stripe.Subscription, "retrieve",
        return_value={"id": "sub_x", "items": {"data": [{"id": "si1"}]}},
    ), patch.object(
        stripe.Subscription, "modify", return_value={"id": "sub_x"}
    ), patch.object(
        SubscriptionService, "sync_stripe_subscription", new=AsyncMock()
    ) as sync, patch.object(stripe.checkout.Session, "create") as session_create:
        result = await create_checkout_session(request, user={"id": "user-1"}, db=db)

    assert result["data"] == {"checkout_url": None, "session_id": None, "updated": True}
    sync.assert_not_called()
    session_create.assert_not_called()


@pytest.mark.asyncio
async def test_checkout_modify_syncs_immediately_when_stripe_returns_expanded_items():
    db = _db_with_subscription(
        {
            "plan_type": "plus_monthly",
            "stripe_subscription_id": "sub_x",
            "stripe_customer_id": "cus_x",
            "billing_provider": "stripe",
        }
    )
    request = CreateCheckoutRequest(plan_type=PlanType.PRO_MONTHLY)
    updated = {
        "id": "sub_x",
        "items": {"data": [{"id": "si1", "price": {"id": "price_pro_monthly"}}]},
    }

    with patch.multiple(settings, **_stripe_settings()), patch.object(
        SubscriptionService, "get_subscription", new=AsyncMock()
    ), patch.object(
        stripe.Subscription, "retrieve",
        return_value={"id": "sub_x", "items": {"data": [{"id": "si1"}]}},
    ), patch.object(
        stripe.Subscription, "modify", return_value=updated
    ), patch.object(
        SubscriptionService, "sync_stripe_subscription", new=AsyncMock()
    ) as sync, patch.object(stripe.checkout.Session, "create") as session_create:
        result = await create_checkout_session(request, user={"id": "user-1"}, db=db)

    assert result["data"] == {"checkout_url": None, "session_id": None, "updated": True}
    sync.assert_awaited_once_with("user-1", updated, db)
    session_create.assert_not_called()


@pytest.mark.asyncio
async def test_checkout_modify_stripe_error_becomes_payment_update_error():
    db = _db_with_subscription(
        {
            "plan_type": "plus_monthly",
            "stripe_subscription_id": "sub_x",
            "stripe_customer_id": "cus_x",
            "billing_provider": "stripe",
        }
    )
    request = CreateCheckoutRequest(plan_type=PlanType.PRO_MONTHLY)

    with patch.multiple(settings, **_stripe_settings()), patch.object(
        SubscriptionService, "get_subscription", new=AsyncMock()
    ), patch.object(
        stripe.Subscription, "retrieve",
        return_value={"id": "sub_x", "items": {"data": [{"id": "si1"}]}},
    ), patch.object(
        stripe.Subscription, "modify",
        side_effect=stripe.error.StripeError("stripe refused"),
    ), patch.object(stripe.checkout.Session, "create") as session_create:
        with pytest.raises(ServiceError, match="Payment update error"):
            await create_checkout_session(request, user={"id": "user-1"}, db=db)

    session_create.assert_not_called()


@pytest.mark.asyncio
async def test_checkout_reuses_an_existing_stripe_customer():
    """A free user with a leftover stripe_customer_id (previous attempt) must
    reuse it instead of creating a duplicate customer."""
    db = _db_with_subscription(
        {
            "plan_type": "free",
            "stripe_subscription_id": None,
            "stripe_customer_id": "cus_existing",
            "billing_provider": "stripe",
        }
    )
    request = CreateCheckoutRequest(
        plan_type=PlanType.PLUS_MONTHLY,
        success_url="https://example.com/success?tab=billing",
        cancel_url="/settings?checkout=cancelled",
    )

    with patch.multiple(
        settings, **_stripe_settings(), FRONTEND_URL="https://fitcheckaiapp.com"
    ), patch.object(
        SubscriptionService, "get_subscription", new=AsyncMock()
    ), patch.object(stripe.Customer, "create") as customer_create, patch.object(
        stripe.checkout.Session, "create"
    ) as session_create:
        session_create.return_value = Mock(id="cs_1", url="https://checkout.example/cs_1")
        result = await create_checkout_session(request, user={"id": "user-1"}, db=db)

    customer_create.assert_not_called()
    assert session_create.call_args.kwargs["customer"] == "cus_existing"
    # Absolute success URLs pass through untouched; relative cancel URLs are
    # expanded against the frontend origin.
    assert session_create.call_args.kwargs["success_url"] == "https://example.com/success?tab=billing"
    assert session_create.call_args.kwargs["cancel_url"] == "https://fitcheckaiapp.com/settings?checkout=cancelled"
    assert result["data"]["checkout_url"] == "https://checkout.example/cs_1"


@pytest.mark.asyncio
async def test_checkout_reads_item_id_from_object_shaped_subscription():
    """Stripe may return the retrieved subscription as a StripeObject rather
    than a dict; the item-id extraction must handle both shapes."""
    db = _db_with_subscription(
        {
            "plan_type": "plus_monthly",
            "stripe_subscription_id": "sub_obj",
            "stripe_customer_id": "cus_x",
            "billing_provider": "stripe",
        }
    )
    request = CreateCheckoutRequest(plan_type=PlanType.PRO_MONTHLY)
    from types import SimpleNamespace

    retrieved = SimpleNamespace(
        items=SimpleNamespace(data=[SimpleNamespace(id="si_obj")])
    )

    with patch.multiple(settings, **_stripe_settings()), patch.object(
        SubscriptionService, "get_subscription", new=AsyncMock()
    ), patch.object(
        stripe.Subscription, "retrieve", return_value=retrieved
    ), patch.object(
        stripe.Subscription, "modify", return_value={"id": "sub_obj"}
    ) as modify, patch.object(
        SubscriptionService, "sync_stripe_subscription", new=AsyncMock()
    ) as sync, patch.object(stripe.checkout.Session, "create") as session_create:
        result = await create_checkout_session(request, user={"id": "user-1"}, db=db)

        assert modify.call_args.args[0] == "sub_obj"
        assert modify.call_args.kwargs["items"] == [
            {"id": "si_obj", "price": "price_pro_monthly"}
        ]
        sync.assert_not_called()
        session_create.assert_not_called()

    assert result["data"] == {"checkout_url": None, "session_id": None, "updated": True}


@pytest.mark.asyncio
async def test_checkout_wraps_top_level_stripe_error():
    db = _db_with_subscription(
        {"plan_type": "free", "stripe_subscription_id": None, "stripe_customer_id": "cus_x"}
    )
    request = CreateCheckoutRequest(plan_type=PlanType.PLUS_MONTHLY)

    with patch.multiple(settings, **_stripe_settings()), patch.object(
        SubscriptionService, "get_subscription", new=AsyncMock()
    ), patch.object(stripe.Customer, "create", return_value=Mock(id="cus_new")), patch.object(
        stripe.checkout.Session, "create",
        side_effect=stripe.error.StripeError("session failed"),
    ):
        with pytest.raises(ServiceError, match="Payment error"):
            await create_checkout_session(request, user={"id": "user-1"}, db=db)


# ---------------------------------------------------------------------------
# Portal
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_portal_fails_closed_when_billing_not_configured():
    with patch.object(subscription_api, "_stripe_billing_configured", return_value=False):
        with pytest.raises(BillingNotConfiguredError, match="promo code"):
            await create_portal_session(user={"id": "user-1"}, db=Mock())


@pytest.mark.asyncio
async def test_portal_requires_an_existing_customer():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = None

    with patch.object(subscription_api, "_stripe_billing_configured", return_value=True):
        with pytest.raises(ValidationError, match="No billing account"):
            await create_portal_session(user={"id": "user-1"}, db=db)


@pytest.mark.asyncio
async def test_portal_creates_a_session_with_the_default_return_url():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = (
        Mock(data={"stripe_customer_id": "cus_1"})
    )

    with patch.multiple(settings, **_stripe_settings(), FRONTEND_URL="https://fitcheckaiapp.com"), patch.object(
        subscription_api, "_stripe_billing_configured", return_value=True
    ), patch.object(
        stripe.billing_portal.Session, "create",
        return_value=Mock(url="https://billing.stripe.com/portal/abc"),
    ) as session_create:
        result = await create_portal_session(user={"id": "user-1"}, db=db)

    assert result["data"]["portal_url"] == "https://billing.stripe.com/portal/abc"
    assert session_create.call_args.kwargs["customer"] == "cus_1"
    assert session_create.call_args.kwargs["return_url"] == "https://fitcheckaiapp.com"


@pytest.mark.asyncio
async def test_portal_honours_an_explicit_return_url():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = (
        Mock(data={"stripe_customer_id": "cus_1"})
    )

    with patch.multiple(settings, **_stripe_settings()), patch.object(
        subscription_api, "_stripe_billing_configured", return_value=True
    ), patch.object(
        stripe.billing_portal.Session, "create",
        return_value=Mock(url="https://billing.stripe.com/portal/def"),
    ) as session_create:
        result = await create_portal_session(
            return_url="https://example.com/billing", user={"id": "user-1"}, db=db
        )

    assert result["data"]["portal_url"] == "https://billing.stripe.com/portal/def"
    assert session_create.call_args.kwargs["return_url"] == "https://example.com/billing"


@pytest.mark.asyncio
async def test_portal_wraps_stripe_errors():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = (
        Mock(data={"stripe_customer_id": "cus_1"})
    )

    with patch.multiple(settings, **_stripe_settings()), patch.object(
        subscription_api, "_stripe_billing_configured", return_value=True
    ), patch.object(
        stripe.billing_portal.Session, "create",
        side_effect=stripe.error.StripeError("portal failed"),
    ):
        with pytest.raises(ServiceError, match="billing portal"):
            await create_portal_session(user={"id": "user-1"}, db=db)


# ---------------------------------------------------------------------------
# Cancel
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_cancel_rejects_play_store_billed_rows():
    with patch.object(
        SubscriptionService,
        "get_subscription",
        new=AsyncMock(
            return_value=Mock(billing_provider="google", plan_type=PlanType.PLUS_MONTHLY)
        ),
    ), patch.object(SubscriptionService, "cancel_subscription", new=AsyncMock()) as service_cancel:
        with pytest.raises(ServiceError, match="Play Store"):
            await cancel_subscription(user={"id": "user-1"}, db=Mock())

    service_cancel.assert_not_called()


@pytest.mark.asyncio
async def test_cancel_rejects_free_plan():
    with patch.object(
        SubscriptionService,
        "get_subscription",
        new=AsyncMock(return_value=Mock(billing_provider="stripe", plan_type=PlanType.FREE)),
    ), patch.object(SubscriptionService, "cancel_subscription", new=AsyncMock()) as service_cancel:
        with pytest.raises(ValidationError, match="paid subscription"):
            await cancel_subscription(user={"id": "user-1"}, db=Mock())

    service_cancel.assert_not_called()


@pytest.mark.asyncio
async def test_cancel_without_stripe_subscription_only_updates_locally():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = (
        Mock(data={"stripe_subscription_id": None})
    )
    with patch.object(
        SubscriptionService,
        "get_subscription",
        new=AsyncMock(
            return_value=Mock(billing_provider="stripe", plan_type=PlanType.PRO_MONTHLY)
        ),
    ), patch("app.api.v1.subscription.settings.STRIPE_SECRET_KEY", "sk_test"), patch.object(
        stripe.Subscription, "modify"
    ) as modify, patch.object(
        SubscriptionService,
        "cancel_subscription",
        new=AsyncMock(return_value=Mock(model_dump=lambda mode="json": {"plan_type": "free"})),
    ) as service_cancel:
        result = await cancel_subscription(user={"id": "user-1"}, db=db)

    assert result["data"]["plan_type"] == "free"
    modify.assert_not_called()
    service_cancel.assert_awaited_once()


@pytest.mark.asyncio
async def test_cancel_schedules_stripe_cancellation_when_subscription_exists():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = (
        Mock(data={"stripe_subscription_id": "sub_1"})
    )
    with patch.object(
        SubscriptionService,
        "get_subscription",
        new=AsyncMock(
            return_value=Mock(billing_provider="stripe", plan_type=PlanType.PRO_MONTHLY)
        ),
    ), patch("app.api.v1.subscription.settings.STRIPE_SECRET_KEY", "sk_test"), patch.object(
        stripe.Subscription, "modify"
    ) as modify, patch.object(
        SubscriptionService,
        "cancel_subscription",
        new=AsyncMock(return_value=Mock(model_dump=lambda mode="json": {"plan_type": "free"})),
    ):
        result = await cancel_subscription(user={"id": "user-1"}, db=db)

    assert result["message"] == "OK"
    modify.assert_called_once_with("sub_1", cancel_at_period_end=True)


# ---------------------------------------------------------------------------
# Webhook: configuration gates and signature errors
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_webhook_501_when_not_configured():
    with patch.multiple(settings, STRIPE_SECRET_KEY=None, STRIPE_WEBHOOK_SECRET="whsec_test"):
        with pytest.raises(HTTPException) as exc_info:
            await stripe_webhook(_webhook_request(), Mock())

    assert exc_info.value.status_code == 501


@pytest.mark.asyncio
async def test_webhook_400_on_unparseable_payload():
    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", side_effect=ValueError("not json")):
        with pytest.raises(HTTPException) as exc_info:
            await stripe_webhook(_webhook_request(), Mock())

    assert exc_info.value.status_code == 400
    assert exc_info.value.detail == "Invalid payload"


@pytest.mark.asyncio
async def test_webhook_400_on_bad_signature():
    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(
        stripe.Webhook, "construct_event",
        side_effect=stripe.error.SignatureVerificationError(
            "bad sig", sig_header="sig_test"
        ),
    ):
        with pytest.raises(HTTPException) as exc_info:
            await stripe_webhook(_webhook_request(), Mock())

    assert exc_info.value.status_code == 400
    assert exc_info.value.detail == "Invalid signature"


@pytest.mark.asyncio
async def test_webhook_without_event_id_skips_the_ledger():
    """Minimal payloads without an event id keep the backwards-compatible
    acknowledgement path (no ledger reads or writes)."""
    event = {"type": "invoice.payment_failed", "data": {"object": {}}}
    ledger = _WebhookDB()
    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event):
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True}
    ledger.insert_execute.assert_not_called()


# ---------------------------------------------------------------------------
# Webhook: ledger state machine
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_webhook_duplicate_with_processed_row_is_acked():
    ledger = _WebhookDB()
    ledger.insert_execute.side_effect = [RuntimeError("duplicate key value violates unique constraint")]
    ledger.select_execute.return_value = Mock(data={"event_id": "evt_1", "status": "processed"})
    event = {"id": "evt_1", "type": "invoice.payment_failed", "data": {"object": {}}}

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event):
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True, "duplicate": True}


@pytest.mark.asyncio
async def test_webhook_500_when_ledger_insert_fails_for_other_reasons():
    ledger = _WebhookDB()
    ledger.insert_execute.side_effect = [RuntimeError("ledger down")]
    event = {"id": "evt_1", "type": "invoice.payment_failed", "data": {"object": {}}}

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event):
        with pytest.raises(HTTPException) as exc_info:
            await stripe_webhook(_webhook_request(), ledger.db)

    assert exc_info.value.status_code == 500
    assert exc_info.value.detail == "Failed to record webhook event"


@pytest.mark.asyncio
async def test_webhook_recent_processing_lease_is_acked_as_duplicate():
    ledger = _WebhookDB()
    ledger.insert_execute.side_effect = [RuntimeError("duplicate key value violates unique constraint")]
    ledger.select_execute.return_value = Mock(
        data={
            "event_id": "evt_1",
            "status": "processing",
            "processing_started_at": utcnow_iso(),
        }
    )
    event = {"id": "evt_1", "type": "invoice.payment_failed", "data": {"object": {}}}

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event):
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True, "duplicate": True}


@pytest.mark.asyncio
async def test_webhook_reclaims_a_stale_processing_lease():
    """A worker died while processing: the stale lease (older than 15 min) is
    reclaimed with a compare-and-swap on processing_started_at, then the
    event is processed and marked done."""
    ledger = _WebhookDB()
    ledger.insert_execute.side_effect = [RuntimeError("duplicate key value violates unique constraint")]
    stale = (utcnow() - timedelta(minutes=30)).isoformat()
    ledger.select_execute.side_effect = [
        Mock(data={"event_id": "evt_1", "status": "processing", "processing_started_at": stale, "attempts": 1}),
        Mock(data=None),  # invoice.payment_failed lookup: no subscription row
    ]
    ledger.eq_claim_execute.side_effect = [
        Mock(data=[{"claimed": True}]),
        Mock(data=[{"done": True}]),
    ]
    event = {
        "id": "evt_1",
        "type": "invoice.payment_failed",
        "data": {"object": {"subscription": "sub_missing"}},
    }

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event):
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True}
    # The claim was predicated on the observed processing_started_at.
    assert ledger.db.table.return_value.update.return_value.eq.return_value.eq.called


@pytest.mark.asyncio
async def test_webhook_losing_the_claim_race_is_acked_as_duplicate():
    ledger = _WebhookDB()
    ledger.is_claim_execute.return_value = Mock(data=[])
    event = {"id": "evt_1", "type": "invoice.payment_failed", "data": {"object": {}}}

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event):
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True, "duplicate": True}


# ---------------------------------------------------------------------------
# Webhook: event processing arms
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_webhook_checkout_completed_syncs_expanded_subscription():
    ledger = _WebhookDB()
    event = {
        "id": "evt_checkout_expanded",
        "type": "checkout.session.completed",
        "data": {
            "object": {
                "metadata": {"user_id": "user-1", "plan_type": "plus_monthly"},
                "customer": "cus_1",
                "subscription": {"id": "sub_1", "items": {"data": [{"id": "si1"}]}},
            }
        },
    }

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event), patch.object(
        stripe.Subscription, "retrieve"
    ) as retrieve, patch.object(
        SubscriptionService, "sync_stripe_subscription", new=AsyncMock()
    ) as sync, patch.object(
        SubscriptionService, "upgrade_to_pro", new=AsyncMock()
    ) as upgrade:
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True}
    # An already-expanded session.subscription is never re-retrieved.
    retrieve.assert_not_called()
    sync.assert_awaited_once()
    assert sync.call_args.kwargs["plan_type_hint"] == PlanType.PLUS_MONTHLY
    upgrade.assert_not_called()


@pytest.mark.asyncio
async def test_webhook_checkout_completed_retrieves_then_syncs():
    ledger = _WebhookDB()
    event = {
        "id": "evt_checkout_str",
        "type": "checkout.session.completed",
        "data": {
            "object": {
                "metadata": {"user_id": "user-1", "plan_type": "pro_monthly"},
                "customer": "cus_1",
                "subscription": "sub_1",
            }
        },
    }
    expanded = {"id": "sub_1", "items": {"data": [{"id": "si1", "price": {"id": "price_pro_monthly"}}]}}

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event), patch.object(
        stripe.Subscription, "retrieve", return_value=expanded
    ) as retrieve, patch.object(
        SubscriptionService, "sync_stripe_subscription", new=AsyncMock()
    ) as sync, patch.object(
        SubscriptionService, "upgrade_to_pro", new=AsyncMock()
    ) as upgrade:
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True}
    retrieve.assert_called_once_with("sub_1")
    sync.assert_awaited_once()
    upgrade.assert_not_called()


@pytest.mark.asyncio
async def test_webhook_checkout_completed_without_user_id_is_skipped():
    ledger = _WebhookDB()
    event = {
        "id": "evt_no_user",
        "type": "checkout.session.completed",
        "data": {"object": {"metadata": {}, "customer": "cus_1", "subscription": "sub_1"}},
    }

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event), patch.object(
        SubscriptionService, "sync_stripe_subscription", new=AsyncMock()
    ) as sync, patch.object(
        SubscriptionService, "upgrade_to_pro", new=AsyncMock()
    ) as upgrade:
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True}
    sync.assert_not_called()
    upgrade.assert_not_called()


@pytest.mark.asyncio
async def test_webhook_subscription_updated_syncs_expanded_items():
    ledger = _WebhookDB()
    event = {
        "id": "evt_updated_expanded",
        "type": "customer.subscription.updated",
        "data": {
            "object": {
                "metadata": {"user_id": "user-1"},
                "items": {"data": [{"id": "si1"}]},
            }
        },
    }

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event), patch.object(
        SubscriptionService, "sync_stripe_subscription", new=AsyncMock()
    ) as sync, patch.object(
        SubscriptionService, "cancel_subscription", new=AsyncMock()
    ) as cancel:
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True}
    sync.assert_awaited_once()
    cancel.assert_not_called()


@pytest.mark.asyncio
async def test_webhook_subscription_updated_minimal_payload_cancels_at_period_end():
    ledger = _WebhookDB()
    event = {
        "id": "evt_updated_cancel",
        "type": "customer.subscription.updated",
        "data": {
            "object": {"metadata": {"user_id": "user-1"}, "cancel_at_period_end": True}
        },
    }

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event), patch.object(
        SubscriptionService, "sync_stripe_subscription", new=AsyncMock()
    ), patch.object(
        SubscriptionService, "cancel_subscription", new=AsyncMock()
    ) as cancel:
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True}
    cancel.assert_awaited_once_with("user-1", ledger.db)


@pytest.mark.asyncio
async def test_webhook_subscription_updated_resolves_user_from_lookup():
    ledger = _WebhookDB()
    ledger.select_execute.return_value = Mock(data={"user_id": "user-9"})
    event = {
        "id": "evt_updated_lookup",
        "type": "customer.subscription.updated",
        "data": {"object": {"id": "sub_lookup", "metadata": {}, "cancel_at_period_end": True}},
    }

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event), patch.object(
        SubscriptionService, "cancel_subscription", new=AsyncMock()
    ) as cancel:
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True}
    cancel.assert_awaited_once_with("user-9", ledger.db)


@pytest.mark.asyncio
async def test_webhook_subscription_updated_minimal_payload_without_cancel_flag_is_skipped():
    """A minimal updated payload (no items, no cancel flag) has nothing to
    act on: ack without touching the subscription."""
    ledger = _WebhookDB()
    event = {
        "id": "evt_updated_noop",
        "type": "customer.subscription.updated",
        "data": {"object": {"metadata": {"user_id": "user-1"}}},
    }

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event), patch.object(
        SubscriptionService, "sync_stripe_subscription", new=AsyncMock()
    ) as sync, patch.object(
        SubscriptionService, "cancel_subscription", new=AsyncMock()
    ) as cancel:
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True}
    sync.assert_not_called()
    cancel.assert_not_called()


@pytest.mark.asyncio
async def test_webhook_subscription_updated_without_resolvable_user_is_skipped():
    ledger = _WebhookDB()
    ledger.select_execute.return_value = None
    event = {
        "id": "evt_updated_unknown",
        "type": "customer.subscription.updated",
        "data": {"object": {"id": "sub_ghost", "metadata": {}}},
    }

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event), patch.object(
        SubscriptionService, "cancel_subscription", new=AsyncMock()
    ) as cancel:
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True}
    cancel.assert_not_called()


@pytest.mark.asyncio
async def test_webhook_unknown_event_type_is_acked_without_side_effects():
    """Unhandled Stripe event types are acknowledged after the ledger bookkeeping,
    never treated as a failure."""
    ledger = _WebhookDB()
    event = {
        "id": "evt_unknown",
        "type": "customer.subscription.created",
        "data": {"object": {"metadata": {"user_id": "user-1"}}},
    }

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event), patch.object(
        SubscriptionService, "sync_stripe_subscription", new=AsyncMock()
    ) as sync, patch.object(
        SubscriptionService, "upgrade_to_pro", new=AsyncMock()
    ) as upgrade:
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True}
    sync.assert_not_called()
    upgrade.assert_not_called()


@pytest.mark.asyncio
async def test_webhook_subscription_deleted_with_metadata_downgrades_to_free():
    ledger = _WebhookDB()
    event = {
        "id": "evt_deleted_meta",
        "type": "customer.subscription.deleted",
        "data": {"object": {"id": "sub_1", "metadata": {"user_id": "user-1"}}},
    }

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event):
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True}
    tbl = ledger.db.table.return_value
    assert any(
        call.args[0].get("plan_type") == "free"
        for call in tbl.update.call_args_list
        if call.args
    ), "the downgrade update must set plan_type=free"


@pytest.mark.asyncio
async def test_webhook_subscription_deleted_without_identity_is_skipped():
    ledger = _WebhookDB()
    event = {
        "id": "evt_deleted_anon",
        "type": "customer.subscription.deleted",
        "data": {"object": {"metadata": {}}},
    }

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event):
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True}
    # Only the final processed-ledger update ran; no subscriptions write.
    tbl = ledger.db.table.return_value
    assert not any(
        call.args[0].get("plan_type") == "free"
        for call in tbl.update.call_args_list
    )


@pytest.mark.asyncio
async def test_webhook_invoice_payment_failed_marks_row_past_due():
    ledger = _WebhookDB()
    ledger.select_execute.return_value = Mock(data={"user_id": "user-1"})
    event = {
        "id": "evt_past_due",
        "type": "invoice.payment_failed",
        "data": {"object": {"subscription": "sub_1"}},
    }

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event):
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True}
    tbl = ledger.db.table.return_value
    assert any(
        call.args[0].get("status") == "past_due" for call in tbl.update.call_args_list
    )


@pytest.mark.asyncio
async def test_webhook_invoice_payment_failed_without_subscription_is_skipped():
    ledger = _WebhookDB()
    event = {
        "id": "evt_no_sub",
        "type": "invoice.payment_failed",
        "data": {"object": {}},
    }

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event):
        result = await stripe_webhook(_webhook_request(), ledger.db)

    assert result == {"received": True}


# ---------------------------------------------------------------------------
# Webhook: processing failure -> 500 with failed-ledger marking
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_webhook_processing_failure_marks_ledger_failed_and_returns_500():
    ledger = _WebhookDB()
    ledger.eq_claim_execute.side_effect = [
        Mock(data=[{"status": "failed", "last_error": "boom"}]),
    ]
    event = {
        "id": "evt_fail",
        "type": "checkout.session.completed",
        "data": {
            "object": {
                "metadata": {"user_id": "user-1", "plan_type": "pro_monthly"},
                "customer": "cus_1",
                "subscription": "sub_1",
            }
        },
    }

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event), patch.object(
        stripe.Subscription, "retrieve",
        return_value={"id": "sub_1", "items": {"data": [{"id": "si1"}]}},
    ), patch.object(
        SubscriptionService, "sync_stripe_subscription",
        new=AsyncMock(side_effect=RuntimeError("db unavailable")),
    ):
        with pytest.raises(HTTPException) as exc_info:
            await stripe_webhook(_webhook_request(), ledger.db)

    assert exc_info.value.status_code == 500
    assert "Failed to process webhook event" in exc_info.value.detail
    assert any(
        call.args[0].get("status") == "failed" for call in ledger.db.table.return_value.update.call_args_list
    )


@pytest.mark.asyncio
async def test_webhook_processing_failure_survives_failed_marking_error():
    """Even when recording the failure itself fails, the handler must still
    surface a 500 so Stripe retries the event."""
    ledger = _WebhookDB()
    ledger.eq_claim_execute.side_effect = [RuntimeError("ledger down")]
    event = {
        "id": "evt_fail2",
        "type": "checkout.session.completed",
        "data": {
            "object": {
                "metadata": {"user_id": "user-1", "plan_type": "pro_monthly"},
                "customer": "cus_1",
                "subscription": "sub_1",
            }
        },
    }

    with patch.multiple(
        settings, STRIPE_SECRET_KEY="sk_test", STRIPE_WEBHOOK_SECRET="whsec_test"
    ), patch.object(stripe.Webhook, "construct_event", return_value=event), patch.object(
        stripe.Subscription, "retrieve",
        return_value={"id": "sub_1", "items": {"data": [{"id": "si1"}]}},
    ), patch.object(
        SubscriptionService, "sync_stripe_subscription",
        new=AsyncMock(side_effect=RuntimeError("db unavailable")),
    ):
        with pytest.raises(HTTPException) as exc_info:
            await stripe_webhook(_webhook_request(), ledger.db)

    assert exc_info.value.status_code == 500
