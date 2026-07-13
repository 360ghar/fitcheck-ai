"""
Unit tests for the Stripe webhook handler.

Regression coverage for two bugs fixed alongside this test:
1. The handler used to catch every exception and always return 200, so a
   failed activation/cancellation was silently lost with no Stripe retry.
2. invoice.payment_failed did `.maybe_single().execute().data` without
   checking for a bare-None result (zero rows), same class of bug fixed
   elsewhere in this file (see app/utils/db.py).
"""
from unittest.mock import Mock, patch

import pytest
from fastapi import HTTPException

from app.api.v1.subscription import stripe_webhook


def _fake_request(body: bytes = b"{}") -> Mock:
    request = Mock()
    request.body = _async_return(body)
    request.headers = {"stripe-signature": "sig_test"}
    return request


def _async_return(value):
    async def _inner():
        return value
    return _inner


@pytest.mark.asyncio
async def test_webhook_activates_subscription_on_checkout_completed():
    db = Mock()
    event = {
        "type": "checkout.session.completed",
        "data": {
            "object": {
                "metadata": {"user_id": "user-1", "plan_type": "pro_monthly"},
                "customer": "cus_123",
                "subscription": "sub_123",
            }
        },
    }

    with patch("app.api.v1.subscription.settings") as mock_settings, \
         patch("app.api.v1.subscription.stripe") as mock_stripe, \
         patch("app.api.v1.subscription.SubscriptionService") as mock_service:
        mock_settings.STRIPE_SECRET_KEY = "sk_test"
        mock_settings.STRIPE_WEBHOOK_SECRET = "whsec_test"
        mock_stripe.Webhook.construct_event.return_value = event
        mock_service.upgrade_to_pro = _async_noop()

        result = await stripe_webhook(_fake_request(), db)

    assert result == {"received": True}


@pytest.mark.asyncio
async def test_webhook_marks_past_due_when_subscription_row_missing():
    """invoice.payment_failed for a subscription with no matching row must
    not crash - postgrest returns bare None on zero rows for .maybe_single()."""
    db = Mock()
    chain = db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value
    chain.execute.return_value = None

    event = {
        "type": "invoice.payment_failed",
        "data": {"object": {"subscription": "sub_missing"}},
    }

    with patch("app.api.v1.subscription.settings") as mock_settings, \
         patch("app.api.v1.subscription.stripe") as mock_stripe:
        mock_settings.STRIPE_SECRET_KEY = "sk_test"
        mock_settings.STRIPE_WEBHOOK_SECRET = "whsec_test"
        mock_stripe.Webhook.construct_event.return_value = event

        result = await stripe_webhook(_fake_request(), db)

    assert result == {"received": True}
    db.table.return_value.update.assert_not_called()


@pytest.mark.asyncio
async def test_webhook_returns_500_instead_of_swallowing_processing_error():
    """A failure while activating a subscription must surface as a 5xx so
    Stripe retries the event, not a silently-swallowed 200."""
    db = Mock()
    event = {
        "type": "checkout.session.completed",
        "data": {
            "object": {
                "metadata": {"user_id": "user-1", "plan_type": "pro_monthly"},
                "customer": "cus_123",
                "subscription": "sub_123",
            }
        },
    }

    with patch("app.api.v1.subscription.settings") as mock_settings, \
         patch("app.api.v1.subscription.stripe") as mock_stripe, \
         patch("app.api.v1.subscription.SubscriptionService") as mock_service:
        mock_settings.STRIPE_SECRET_KEY = "sk_test"
        mock_settings.STRIPE_WEBHOOK_SECRET = "whsec_test"
        mock_stripe.Webhook.construct_event.return_value = event
        mock_service.upgrade_to_pro = _async_raise(RuntimeError("db unavailable"))

        with pytest.raises(HTTPException) as exc_info:
            await stripe_webhook(_fake_request(), db)

    assert exc_info.value.status_code == 500


def _async_noop():
    async def _inner(*args, **kwargs):
        return None
    return _inner


def _async_raise(exc):
    async def _inner(*args, **kwargs):
        raise exc
    return _inner
