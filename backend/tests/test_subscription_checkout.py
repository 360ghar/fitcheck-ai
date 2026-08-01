from datetime import datetime, timedelta, timezone
from unittest.mock import AsyncMock, Mock, patch

import pytest
import stripe

from app.api.v1.subscription import create_checkout_session
from app.core.config import settings
from app.core.exceptions import ServiceError
from app.models.subscription import CreateCheckoutRequest, PlanType
from app.services.subscription_service import SubscriptionService


def _db_with_subscription(row):
    db = Mock()
    result = Mock(data=row)
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = result
    return db


def _stripe_settings():
    return {
        "STRIPE_SECRET_KEY": "sk_test",
        "STRIPE_PLUS_MONTHLY_PRICE_ID": "price_plus_monthly",
        "STRIPE_PLUS_YEARLY_PRICE_ID": "price_plus_yearly",
        "STRIPE_PRO_MONTHLY_PRICE_ID": "price_pro_monthly",
        "STRIPE_PRO_YEARLY_PRICE_ID": "price_pro_yearly",
    }


@pytest.mark.asyncio
@pytest.mark.parametrize(
    ("plan_type", "price_id"),
    [
        (PlanType.PLUS_MONTHLY, "price_plus_monthly"),
        (PlanType.PLUS_YEARLY, "price_plus_yearly"),
        (PlanType.PRO_MONTHLY, "price_pro_monthly"),
        (PlanType.PRO_YEARLY, "price_pro_yearly"),
    ],
)
async def test_free_user_gets_normal_checkout_session(plan_type, price_id):
    db = _db_with_subscription({"plan_type": "free", "stripe_subscription_id": None})
    request = CreateCheckoutRequest(plan_type=plan_type)

    with patch.multiple(settings, **_stripe_settings(), FRONTEND_URL="https://fitcheckaiapp.com"), \
         patch.object(stripe.Customer, "create") as customer_create, \
         patch.object(stripe.checkout.Session, "create") as session_create, \
         patch.object(stripe.Subscription, "modify") as modify, \
         patch.object(SubscriptionService, "get_subscription", new=AsyncMock()):
        customer_create.return_value = Mock(id="cus_new")
        session_create.return_value = Mock(
            id="cs_new", url="https://checkout.example/cs_new"
        )

        result = await create_checkout_session(request, user={"id": "user-1", "email": "a@example.com"}, db=db)

    assert result["data"] == {
        "checkout_url": "https://checkout.example/cs_new",
        "session_id": "cs_new",
        "updated": False,
    }
    session_create.assert_called_once()
    assert session_create.call_args.kwargs["line_items"] == [
        {"price": price_id, "quantity": 1}
    ]
    assert session_create.call_args.kwargs["success_url"] == "https://fitcheckaiapp.com/settings?checkout=success"
    assert session_create.call_args.kwargs["cancel_url"] == "https://fitcheckaiapp.com/settings?checkout=cancelled"
    modify.assert_not_called()


@pytest.mark.asyncio
async def test_existing_subscription_is_modified_in_place_with_proration():
    db = _db_with_subscription(
        {
            "plan_type": "plus_monthly",
            "stripe_subscription_id": "sub_existing",
            "stripe_customer_id": "cus_existing",
        }
    )
    request = CreateCheckoutRequest(plan_type=PlanType.PRO_YEARLY)

    with patch.multiple(settings, **_stripe_settings()), \
         patch.object(stripe.Subscription, "retrieve") as retrieve, \
         patch.object(stripe.Subscription, "modify") as modify, \
         patch.object(stripe.checkout.Session, "create") as session_create, \
         patch.object(SubscriptionService, "get_subscription", new=AsyncMock()), \
         patch.object(SubscriptionService, "sync_stripe_subscription", new=AsyncMock()):
        retrieve.return_value = {
            "id": "sub_existing",
            "items": {"data": [{"id": "si_existing"}]},
        }
        modify.return_value = {
            "id": "sub_existing",
            "items": {"data": [{"id": "si_existing", "price": {"id": "price_pro_yearly"}}]},
        }

        result = await create_checkout_session(request, user={"id": "user-1"}, db=db)

    assert result["data"] == {
        "checkout_url": None,
        "session_id": None,
        "updated": True,
    }
    modify.assert_called_once_with(
        "sub_existing",
        items=[{"id": "si_existing", "price": "price_pro_yearly"}],
        # A plan switch after scheduling cancellation at period end must
        # resume the subscription, or the user loses access when the period
        # ends despite having paid for the new plan.
        cancel_at_period_end=False,
        proration_behavior="create_prorations",
        metadata={"user_id": "user-1", "plan_type": "pro_yearly"},
    )
    session_create.assert_not_called()


@pytest.mark.asyncio
async def test_paid_local_state_without_stripe_subscription_fails_before_checkout():
    db = _db_with_subscription({"plan_type": "pro_monthly", "stripe_subscription_id": None})
    request = CreateCheckoutRequest(plan_type=PlanType.PRO_YEARLY)

    with patch.multiple(settings, **_stripe_settings()), \
         patch.object(stripe.checkout.Session, "create") as session_create, \
         patch.object(SubscriptionService, "get_subscription", new=AsyncMock()):
        with pytest.raises(ServiceError, match="paid billing state.*Stripe subscription ID"):
            await create_checkout_session(request, user={"id": "user-1"}, db=db)

    session_create.assert_not_called()


@pytest.mark.asyncio
@pytest.mark.parametrize("provider", ["apple", "google"])
async def test_store_billed_subscription_refuses_stripe_checkout(provider):
    """Fail closed: an App Store / Play-billed account must never be steered
    to Stripe checkout (App Store Guideline 3.1.1 / Play policy), and a web
    Stripe purchase must not double-bill alongside a store subscription."""
    db = _db_with_subscription(
        {
            "plan_type": "plus_monthly",
            "stripe_subscription_id": None,
            "stripe_customer_id": None,
            "billing_provider": provider,
        }
    )
    request = CreateCheckoutRequest(plan_type=PlanType.PLUS_MONTHLY)

    with patch.multiple(settings, **_stripe_settings()), \
         patch.object(stripe.checkout.Session, "create") as session_create, \
         patch.object(SubscriptionService, "get_subscription", new=AsyncMock()):
        with pytest.raises(ServiceError, match="billed through"):
            await create_checkout_session(request, user={"id": "user-1"}, db=db)

    session_create.assert_not_called()


@pytest.mark.asyncio
async def test_sync_stripe_subscription_persists_price_status_period_and_cancel_flag():
    db = Mock()
    row = {
        "id": "22222222-2222-2222-2222-222222222222",
        "user_id": "11111111-1111-1111-1111-111111111111",
        "plan_type": "pro_yearly",
        "status": "active",
        "current_period_start": datetime.now(timezone.utc).isoformat(),
        "current_period_end": datetime.now(timezone.utc).replace(microsecond=0) + timedelta(days=30),
        "cancel_at_period_end": True,
        "trial_end": None,
    }
    result = Mock(data=row)
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = result

    with patch.multiple(settings, **_stripe_settings()):
        synced = await SubscriptionService.sync_stripe_subscription(
            "11111111-1111-1111-1111-111111111111",
            {
                "id": "sub_stripe",
                "customer": "cus_1",
                "status": "active",
                "current_period_start": 1_700_000_000,
                "current_period_end": 1_800_000_000,
                "trial_end": None,
                "cancel_at_period_end": True,
                "items": {"data": [{"price": {"id": settings.STRIPE_PRO_YEARLY_PRICE_ID}}]},
            },
            db,
        )

    payload = db.table.return_value.upsert.call_args.args[0]
    assert payload["plan_type"] == "pro_yearly"
    assert payload["status"] == "active"
    assert payload["stripe_subscription_id"] == "sub_stripe"
    assert payload["cancel_at_period_end"] is True
    assert payload["current_period_end"] is not None
    assert synced.plan_type == PlanType.PRO_YEARLY
