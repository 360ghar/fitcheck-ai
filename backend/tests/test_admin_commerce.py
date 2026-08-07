"""
Admin commerce tests: subscriptions list/detail/refund, IAP transactions,
quota override, promo code create/update, feedback update.
"""
from unittest.mock import Mock, patch

import pytest
import stripe
from fastapi.testclient import TestClient

import app.main as main_module
from app.api.v1.deps import get_current_user, get_db
from admin_test_utils import FakeDB
from app.core.config import settings

ADMIN = {
    "id": "user-admin",
    "email": "admin@example.com",
    "full_name": "Admin User",
    "is_active": True,
    "is_admin": True,
    "role": "admin",
}

SUB_ROW = {
    "id": "sub-1",
    "user_id": "user-1",
    "plan_type": "pro_monthly",
    "status": "active",
    "billing_provider": "stripe",
    "stripe_customer_id": "cus_123",
    "stripe_subscription_id": "sub_stripe_1",
    "current_period_start": "2026-08-01T00:00:00",
    "current_period_end": "2026-09-01T00:00:00",
    "cancel_at_period_end": False,
    "created_at": "2026-08-01T00:00:00",
    "users": {"email": "target@example.com", "full_name": "Target User"},
}


@pytest.fixture
def client():
    return TestClient(main_module.app)


def _call(client, method, url, user=ADMIN, db=None, **kwargs):
    app = client.app
    app.dependency_overrides[get_current_user] = lambda: user
    app.dependency_overrides[get_db] = lambda: db or FakeDB()
    try:
        return client.request(method, url, **kwargs)
    finally:
        app.dependency_overrides.clear()


# =============================================================================
# Subscriptions
# =============================================================================


def test_subscriptions_list_returns_email_plan_and_amount(client):
    db = FakeDB(rows={"subscriptions": [SUB_ROW]})
    response = _call(client, "GET", "/api/v1/admin/subscriptions", db=db)
    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 1
    item = body["items"][0]
    assert item["user"]["email"] == "target@example.com"
    assert item["plan_type"] == "pro_monthly"
    assert item["amount"] == settings.PLAN_PRO_MONTHLY_PRICE
    assert item["stripe_customer_id"] == "cus_123"


def test_subscriptions_list_filters_plan_and_status(client):
    db = FakeDB(
        rows={
            "subscriptions": [
                SUB_ROW,
                {**SUB_ROW, "id": "sub-2", "user_id": "user-2", "plan_type": "free", "status": "active"},
            ]
        }
    )
    response = _call(client, "GET", "/api/v1/admin/subscriptions?plan=free", db=db)
    assert response.status_code == 200
    assert response.json()["total"] == 1
    assert response.json()["items"][0]["plan_type"] == "free"


def test_subscription_detail_includes_provider_identifiers(client):
    db = FakeDB(rows={"subscriptions": [SUB_ROW], "users": []})
    response = _call(client, "GET", "/api/v1/admin/subscriptions/user/user-1", db=db)
    assert response.status_code == 200
    body = response.json()
    assert body["subscription"]["stripe_customer_id"] == "cus_123"
    assert body["subscription"]["billing_provider"] == "stripe"
    assert body["usage"] == {}


def test_subscription_detail_missing_404(client):
    response = _call(client, "GET", "/api/v1/admin/subscriptions/user/user-ghost", db=FakeDB())
    assert response.status_code == 404


def test_refund_uses_latest_payment_intent_and_audits(client, monkeypatch):
    monkeypatch.setattr(settings, "STRIPE_SECRET_KEY", "sk_test_dummy")
    db = FakeDB(rows={"subscriptions": [SUB_ROW]})

    class _PI:
        id = "pi_123"

    class _Refund:
        id = "re_123"
        amount = 2000
        currency = "usd"
        status = "succeeded"
        charge = "ch_123"

    with patch("stripe.PaymentIntent.list", return_value=type("List", (), {"data": [_PI()]})()):
        with patch("stripe.Refund.list", return_value=type("List", (), {"data": []})()):
            with patch("stripe.Refund.create", return_value=_Refund()) as refund_create:
                response = _call(
                    client,
                    "POST",
                    "/api/v1/admin/subscriptions/user/user-1/refund",
                    db=db,
                )

    assert response.status_code == 200
    body = response.json()
    assert body["refund_id"] == "re_123"
    assert body["payment_intent"] == "pi_123"
    assert body["amount"] == 2000
    refund_create.assert_called_once_with(payment_intent="pi_123")
    db.assert_insert("audit_events", action="subscription.refunded", entity_id="user-1")


def test_refund_reuses_existing_succeeded_refund(client, monkeypatch):
    """A second refund call must reuse the existing succeeded refund instead of
    calling Refund.create again (Stripe rejects the duplicate and the admin
    endpoint 500'd on the unhandled StripeError)."""
    monkeypatch.setattr(settings, "STRIPE_SECRET_KEY", "sk_test_dummy")
    db = FakeDB(rows={"subscriptions": [SUB_ROW]})

    class _PI:
        id = "pi_123"

    class _Refund:
        id = "re_123"
        amount = 2000
        currency = "usd"
        status = "succeeded"
        charge = "ch_123"

    with patch("stripe.PaymentIntent.list", return_value=type("List", (), {"data": [_PI()]})()):
        with patch("stripe.Refund.list", return_value=type("List", (), {"data": [_Refund()]})()) as refund_list:
            with patch("stripe.Refund.create") as refund_create:
                response = _call(
                    client,
                    "POST",
                    "/api/v1/admin/subscriptions/user/user-1/refund",
                    db=db,
                )

    assert response.status_code == 200
    body = response.json()
    assert body["refund_id"] == "re_123"
    assert body["payment_intent"] == "pi_123"
    assert body["amount"] == 2000
    assert body["status"] == "succeeded"
    refund_list.assert_called_once_with(payment_intent="pi_123", limit=1)
    refund_create.assert_not_called()


def test_refund_maps_stripe_error_to_4xx(client, monkeypatch):
    """stripe.error.StripeError is not a FitCheckException; without mapping it
    the catch-all turns an already-refunded InvalidRequestError into a 500.
    It must surface as a 4xx (ValidationError)."""
    monkeypatch.setattr(settings, "STRIPE_SECRET_KEY", "sk_test_dummy")
    db = FakeDB(rows={"subscriptions": [SUB_ROW]})

    class _PI:
        id = "pi_123"

    with patch("stripe.PaymentIntent.list", return_value=type("List", (), {"data": [_PI()]})()):
        with patch("stripe.Refund.list", return_value=type("List", (), {"data": []})()):
            with patch(
                "stripe.Refund.create",
                side_effect=stripe.error.InvalidRequestError("No such payment_intent: pi_123", "payment_intent"),
            ):
                response = _call(
                    client,
                    "POST",
                    "/api/v1/admin/subscriptions/user/user-1/refund",
                    db=db,
                )

    assert response.status_code == 422
    body = response.json()
    assert body["code"] == "VALIDATION_ERROR"
    assert body["details"]["service"] == "stripe"


def test_refund_falls_back_to_charge(client, monkeypatch):
    monkeypatch.setattr(settings, "STRIPE_SECRET_KEY", "sk_test_dummy")
    db = FakeDB(rows={"subscriptions": [SUB_ROW]})

    class _Charge:
        id = "ch_999"

    class _Refund:
        id = "re_999"
        amount = 1000
        currency = "usd"
        status = "succeeded"
        charge = "ch_999"

    with patch("stripe.PaymentIntent.list", return_value=type("List", (), {"data": []})()):
        with patch("stripe.Charge.list", return_value=type("List", (), {"data": [_Charge()]})()):
            with patch("stripe.Refund.list", return_value=type("List", (), {"data": []})()):
                with patch("stripe.Refund.create", return_value=_Refund()) as refund_create:
                    response = _call(
                        client,
                        "POST",
                        "/api/v1/admin/subscriptions/user/user-1/refund",
                        db=db,
                    )

    assert response.status_code == 200
    assert response.json()["charge_id"] == "ch_999"
    refund_create.assert_called_once_with(charge="ch_999")


def test_refund_billing_not_configured(client, monkeypatch):
    monkeypatch.setattr(settings, "STRIPE_SECRET_KEY", None)
    db = FakeDB(rows={"subscriptions": [SUB_ROW]})
    response = _call(
        client,
        "POST",
        "/api/v1/admin/subscriptions/user/user-1/refund",
        db=db,
    )
    assert response.status_code == 503
    assert response.json()["code"] == "BILLING_NOT_CONFIGURED"


def test_refund_no_charge_found_404(client, monkeypatch):
    monkeypatch.setattr(settings, "STRIPE_SECRET_KEY", "sk_test_dummy")
    db = FakeDB(rows={"subscriptions": [SUB_ROW]})
    with patch("stripe.PaymentIntent.list", return_value=type("List", (), {"data": []})()):
        with patch("stripe.Charge.list", return_value=type("List", (), {"data": []})()):
            response = _call(
                client,
                "POST",
                "/api/v1/admin/subscriptions/user/user-1/refund",
                db=db,
            )
    assert response.status_code == 404


# =============================================================================
# IAP transactions
# =============================================================================

APPLE_TXN = {
    "id": "sub-apple",
    "user_id": "user-1",
    "plan_type": "plus_monthly",
    "status": "active",
    "billing_provider": "apple",
    "apple_original_transaction_id": "txn-1",
    "billing_product_id": "com.fitcheckaiapp.fitcheckai.plus.monthly",
    "created_at": "2026-08-01T00:00:00",
    "users": {"email": "target@example.com"},
}


def test_iap_transactions_list(client):
    db = FakeDB(
        rows={
            "subscriptions": [
                APPLE_TXN,
                {**APPLE_TXN, "id": "sub-google", "billing_provider": "google", "google_order_id": "GPA.123"},
                {**SUB_ROW, "id": "sub-stripe", "billing_provider": "stripe"},  # excluded by filter
            ]
        }
    )
    response = _call(client, "GET", "/api/v1/admin/iap/transactions", db=db)
    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 2
    assert {item["platform"] for item in body["items"]} == {"apple", "google"}


def test_iap_transactions_platform_filter(client):
    db = FakeDB(
        rows={
            "subscriptions": [
                APPLE_TXN,
                {**APPLE_TXN, "id": "sub-google", "billing_provider": "google", "google_order_id": "GPA.123"},
            ]
        }
    )
    response = _call(client, "GET", "/api/v1/admin/iap/transactions?platform=apple", db=db)
    assert response.status_code == 200
    assert response.json()["total"] == 1
    assert response.json()["items"][0]["platform"] == "apple"


def test_iap_transaction_detail(client):
    db = FakeDB(rows={"subscriptions": [APPLE_TXN]})
    response = _call(client, "GET", "/api/v1/admin/iap/transactions/txn-1", db=db)
    assert response.status_code == 200
    body = response.json()
    assert body["transaction_id"] == "txn-1"
    assert body["platform"] == "apple"
    assert body["user_email"] == "target@example.com"


def test_iap_transaction_detail_missing_404(client):
    response = _call(client, "GET", "/api/v1/admin/iap/transactions/nope", db=FakeDB())
    assert response.status_code == 404


def test_iap_transaction_detail_preserves_dots_in_google_order_id(client):
    """Google order ids are 'GPA.1234-5678-9012-34567'. safe_search_term
    stripped the dots, so the eq value never matched and admin
    detail/mark-refunded 404'd on every Google transaction."""
    db = FakeDB(
        rows={
            "subscriptions": [
                {
                    "id": "sub-google",
                    "user_id": "user-1",
                    "plan_type": "plus_monthly",
                    "status": "active",
                    "billing_provider": "google",
                    "google_order_id": "GPA.1234-5678-9012-34567",
                    "created_at": "2026-08-01T00:00:00",
                    "users": {"email": "target@example.com"},
                }
            ]
        }
    )
    response = _call(
        client,
        "GET",
        "/api/v1/admin/iap/transactions/GPA.1234-5678-9012-34567",
        db=db,
    )
    assert response.status_code == 200
    assert response.json()["transaction_id"] == "GPA.1234-5678-9012-34567"


@pytest.mark.asyncio
async def test_get_iap_transaction_lookup_keeps_dots_in_or_expression():
    """Unit-level guarantee: the or_ predicate value for a Google order id must
    keep its dots (only commas/parens are stripped)."""
    from app.services.admin_service import get_iap_transaction

    db = Mock()
    result = Mock()
    result.data = [{"id": "sub-google", "google_order_id": "GPA.1234-5678-9012-34567"}]
    chain = db.table.return_value.select.return_value
    chain.or_.return_value.neq.return_value.limit.return_value.execute.return_value = result
    await get_iap_transaction(db, "GPA.1234-5678-9012-34567")
    or_expr = chain.or_.call_args.args[0]
    assert "google_order_id.eq.GPA.1234-5678-9012-34567" in or_expr


def test_iap_mark_refunded_updates_status_and_audits(client):
    db = FakeDB(rows={"subscriptions": [APPLE_TXN]})
    response = _call(
        client,
        "POST",
        "/api/v1/admin/iap/transactions/txn-1/mark-refunded",
        db=db,
    )
    assert response.status_code == 200
    body = response.json()
    assert body["before_status"] == "active"
    assert body["after_status"] == "refunded"
    db.assert_update("subscriptions", status="refunded")
    db.assert_insert("audit_events", action="iap.refund_marked", entity_id="txn-1")


# =============================================================================
# Quota override
# =============================================================================


def test_quota_override_set_and_audit(client):
    db = FakeDB(rows={"users": [{"id": "user-1", "email": "t@example.com"}]})
    response = _call(
        client,
        "PATCH",
        "/api/v1/admin/users/user-1/quota-override",
        db=db,
        json={"daily_limit": 500},
    )
    assert response.status_code == 200
    assert response.json()["custom_daily_quota"] == 500
    db.assert_update("users", custom_daily_quota=500)
    db.assert_insert("audit_events", action="quota.override", entity_id="user-1")


def test_quota_override_clear_with_null(client):
    db = FakeDB(rows={"users": [{"id": "user-1", "custom_daily_quota": 500}]})
    response = _call(
        client,
        "PATCH",
        "/api/v1/admin/users/user-1/quota-override",
        db=db,
        json={"daily_limit": None},
    )
    assert response.status_code == 200
    assert response.json()["custom_daily_quota"] is None
    db.assert_update("users", custom_daily_quota=None)


def test_quota_override_missing_user_404(client):
    response = _call(
        client,
        "PATCH",
        "/api/v1/admin/users/user-ghost/quota-override",
        db=FakeDB(),
        json={"daily_limit": 10},
    )
    assert response.status_code == 404


def test_quotas_list_returns_usage_rows(client):
    db = FakeDB(
        rows={
            "user_ai_settings": [
                {
                    "user_id": "user-1",
                    "daily_extraction_count": 9,
                    "daily_generation_count": 2,
                    "daily_embedding_count": 1,
                    "last_reset_date": "2026-08-06",
                    "users": {"email": "t@example.com", "full_name": "T", "custom_daily_quota": None},
                    "subscriptions": {"plan_type": "free", "status": "active"},
                }
            ]
        }
    )
    response = _call(client, "GET", "/api/v1/admin/quotas", db=db)
    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 1
    item = body["items"][0]
    assert item["email"] == "t@example.com"
    assert item["daily_extraction_count"] == 9
    assert item["plan_type"] == "free"


# =============================================================================
# Promo codes
# =============================================================================

PROMO_ROW = {
    "id": "p1",
    "code": "LAUNCH30",
    "plan_type": "pro_monthly",
    "months": 1,
    "max_uses": 100,
    "used_count": 5,
    "expires_at": None,
    "active": True,
    "created_at": "2026-08-01T00:00:00",
}


def test_promo_codes_list_with_redemptions(client):
    db = FakeDB(rows={"promo_codes": [{**PROMO_ROW, "promo_redemptions": [{"count": 5}]}]})
    response = _call(client, "GET", "/api/v1/admin/promo-codes", db=db)
    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 1
    assert body["items"][0]["redemptions_count"] == 5


def test_promo_code_create_and_audit(client):
    db = FakeDB(rows={"promo_codes": []})
    response = _call(
        client,
        "POST",
        "/api/v1/admin/promo-codes",
        db=db,
        json={"code": "SUMMER25", "plan_type": "plus_monthly", "months": 3},
    )
    assert response.status_code == 201
    body = response.json()
    assert body["code"] == "SUMMER25"
    db.assert_insert("promo_codes", code="SUMMER25")
    db.assert_insert("audit_events", action="promo.created", entity_type="promo_code")


def test_promo_code_create_rejects_duplicate(client):
    db = FakeDB(rows={"promo_codes": [PROMO_ROW]})
    response = _call(
        client,
        "POST",
        "/api/v1/admin/promo-codes",
        db=db,
        json={"code": "launch30", "plan_type": "pro_monthly", "months": 1},
    )
    assert response.status_code == 422


def test_promo_code_create_rejects_bad_format(client):
    response = _call(
        client,
        "POST",
        "/api/v1/admin/promo-codes",
        db=FakeDB(),
        json={"code": "x", "plan_type": "pro_monthly", "months": 1},
    )
    assert response.status_code == 422


def test_promo_code_update_and_audit(client):
    db = FakeDB(rows={"promo_codes": [PROMO_ROW]})
    response = _call(
        client,
        "PATCH",
        "/api/v1/admin/promo-codes/p1",
        db=db,
        json={"active": False},
    )
    assert response.status_code == 200
    assert response.json()["active"] is False
    db.assert_update("promo_codes", active=False)
    db.assert_insert("audit_events", action="promo.updated", entity_id="p1")


def test_promo_code_update_missing_404(client):
    response = _call(
        client,
        "PATCH",
        "/api/v1/admin/promo-codes/nope",
        db=FakeDB(),
        json={"active": False},
    )
    assert response.status_code == 404


# =============================================================================
# Feedback
# =============================================================================

TICKET_ROW = {
    "id": "t1",
    "user_id": "user-1",
    "category": "bug_report",
    "subject": "Something broke",
    "description": "Details",
    "status": "open",
    "created_at": "2026-08-01T00:00:00",
    "users": {"email": "target@example.com", "full_name": "Target User"},
}


def test_feedback_list(client):
    db = FakeDB(rows={"support_tickets": [TICKET_ROW]})
    response = _call(client, "GET", "/api/v1/admin/feedback", db=db)
    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 1
    assert body["items"][0]["user"]["email"] == "target@example.com"


def test_feedback_status_filter(client):
    db = FakeDB(
        rows={
            "support_tickets": [
                TICKET_ROW,
                {**TICKET_ROW, "id": "t2", "status": "resolved"},
            ]
        }
    )
    response = _call(client, "GET", "/api/v1/admin/feedback?status=open", db=db)
    assert response.status_code == 200
    assert response.json()["total"] == 1


def test_feedback_update_status_and_notes_audited(client):
    db = FakeDB(rows={"support_tickets": [TICKET_ROW]})
    response = _call(
        client,
        "PATCH",
        "/api/v1/admin/feedback/t1",
        db=db,
        json={"status": "resolved", "internal_notes": "Fixed in v1.2"},
    )
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "resolved"
    assert body["internal_notes"] == "Fixed in v1.2"
    db.assert_update("support_tickets", status="resolved", internal_notes="Fixed in v1.2")
    db.assert_insert("audit_events", action="feedback.updated", entity_id="t1")


def test_feedback_update_missing_404(client):
    response = _call(
        client,
        "PATCH",
        "/api/v1/admin/feedback/nope",
        db=FakeDB(),
        json={"status": "resolved"},
    )
    assert response.status_code == 404
