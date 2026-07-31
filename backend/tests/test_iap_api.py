"""Tests for the IAP API router (register endpoint + store webhooks)."""
import base64
import json
from datetime import datetime, timezone
from unittest.mock import AsyncMock, Mock, patch
from uuid import uuid4

import pytest

from app.api.v1 import iap
from app.core.config import settings
from app.core.exceptions import ValidationError
from app.models.subscription import (
    PlanType,
    RegisterIapTransactionRequest,
    StoreType,
    SubscriptionResponse,
    SubscriptionStatus,
)
from app.services.apple_iap_service import AppleIAPService, AppleIAPSignatureError
from app.services.google_play_service import (
    GooglePlayService,
    GooglePlayVerificationError,
)
from app.services.subscription_service import SubscriptionService


class FakeRequest:
    """Minimal FastAPI Request double exposing json() and headers."""

    def __init__(self, body, headers=None):
        self._body = body
        self._headers = headers or {}

    async def json(self):
        return self._body

    @property
    def headers(self):
        return self._headers


class FakeDB:
    """Chained postgrest-style DB double with per-table insert dedupe."""

    def __init__(self, subscriptions_lookup=None):
        self.seen = {"apple_iap_events": set(), "google_rtdn_events": set()}
        self.subscriptions_lookup = subscriptions_lookup or {}
        self.upserts = []
        self.updates = []

    def table(self, name):
        return _Table(self, name)


class _Table:
    def __init__(self, db, name):
        self.db = db
        self.name = name
        self._payload = None
        self._select_cols = None
        self._eq_col = None
        self._eq_val = None
        self._method = None

    def insert(self, payload):
        self._method = "insert"
        self._payload = payload
        return self

    def update(self, payload):
        self._method = "update"
        self._payload = payload
        return self

    def select(self, cols):
        self._method = "select"
        self._cols = cols
        return self

    def eq(self, col, val):
        self._eq_col, self._eq_val = col, val
        return self

    def maybe_single(self):
        return self

    def execute(self):
        if self._method == "insert":
            pk = "notification_id" if self.name == "apple_iap_events" else "message_id"
            value = self._payload.get(pk)
            if value in self.db.seen[self.name]:
                raise Exception("duplicate key value violates unique constraint")
            self.db.seen[self.name].add(value)
            return Mock(data=[])
        if self._method == "update":
            self.db.updates.append((self.name, self._payload, self._eq_col, self._eq_val))
            return Mock(data=[])
        if self._method == "select":
            return Mock(data=self.db.subscriptions_lookup.get(self._eq_val))
        return Mock(data=[])


def _sub_response(**overrides):
    kwargs = {
        "id": uuid4(),
        "user_id": uuid4(),
        "plan_type": PlanType.PRO_MONTHLY,
        "status": SubscriptionStatus.ACTIVE,
        "current_period_start": datetime.now(timezone.utc),
    }
    kwargs.update(overrides)
    return SubscriptionResponse(**kwargs)


def _iap_settings():
    return {
        "APPLE_BUNDLE_ID": "com.fitcheckaiapp.fitcheckai",
        "APPLE_PLUS_MONTHLY_PRODUCT_ID": "com.fitcheck.plus.monthly",
        "APPLE_PLUS_YEARLY_PRODUCT_ID": "com.fitcheck.plus.yearly",
        "APPLE_PRO_MONTHLY_PRODUCT_ID": "com.fitcheck.pro.monthly",
        "APPLE_PRO_YEARLY_PRODUCT_ID": "com.fitcheck.pro.yearly",
        "GOOGLE_PLUS_MONTHLY_PRODUCT_ID": "com.fitcheck.plus.monthly",
        "GOOGLE_PLUS_YEARLY_PRODUCT_ID": "com.fitcheck.plus.yearly",
        "GOOGLE_PRO_MONTHLY_PRODUCT_ID": "com.fitcheck.pro.monthly",
        "GOOGLE_PRO_YEARLY_PRODUCT_ID": "com.fitcheck.pro.yearly",
    }


# ---------------------------------------------------------------------------
# Register transaction
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_register_apple_transaction_syncs_entitlement():
    db = FakeDB()
    request = RegisterIapTransactionRequest(
        store=StoreType.APPLE,
        transaction_id="tx-1",
        product_id="com.fitcheck.plus.monthly",
    )
    tx_info = {
        "transactionId": "tx-1",
        "originalTransactionId": "orig-1",
        "bundleId": "com.fitcheckaiapp.fitcheckai",
        "productId": "com.fitcheck.plus.monthly",
        "purchaseDate": 1_700_000_000_000,
        "expiresDate": 1_700_300_000_000,
    }
    synced = _sub_response(plan_type=PlanType.PLUS_MONTHLY, billing_provider="apple")

    with patch.multiple(settings, **_iap_settings()), patch.object(
        AppleIAPService, "verify_transaction", new=AsyncMock(return_value=tx_info)
    ), patch.object(
        SubscriptionService, "sync_iap_subscription", new=AsyncMock(return_value=synced)
    ) as sync:
        result = await iap.register_iap_transaction(request, user={"id": "user-1"}, db=db)

    assert result["data"]["billing_provider"] == "apple"
    sync.assert_called_once()
    assert sync.call_args.kwargs["provider"] == "apple"
    assert sync.call_args.kwargs["apple_original_transaction_id"] == "orig-1"


@pytest.mark.asyncio
async def test_register_apple_transaction_rejects_product_mismatch():
    db = FakeDB()
    request = RegisterIapTransactionRequest(
        store=StoreType.APPLE,
        transaction_id="tx-1",
        product_id="com.fitcheck.plus.monthly",
    )
    tx_info = {
        "productId": "com.fitcheck.pro.monthly",  # verified product differs
    }
    with patch.object(
        AppleIAPService, "verify_transaction", new=AsyncMock(return_value=tx_info)
    ), patch.object(
        SubscriptionService, "sync_iap_subscription", new=AsyncMock()
    ) as sync:
        with pytest.raises(ValidationError, match="does not match"):
            await iap.register_iap_transaction(request, user={"id": "user-1"}, db=db)
    sync.assert_not_called()


@pytest.mark.asyncio
async def test_register_google_transaction_syncs_and_acknowledges():
    db = FakeDB()
    request = RegisterIapTransactionRequest(
        store=StoreType.GOOGLE,
        transaction_id="token-abc",
        product_id="com.fitcheck.plus.monthly",
    )
    purchase = {
        "startTimeMillis": "1700000000000",
        "expiryTimeMillis": "1700300000000",
        "autoRenewing": True,
        "paymentState": 1,
        "orderId": "GPA.1234",
    }
    synced = _sub_response(plan_type=PlanType.PLUS_MONTHLY, billing_provider="google")

    with patch.multiple(settings, **_iap_settings()), patch.object(
        GooglePlayService, "get_subscription", new=AsyncMock(return_value=purchase)
    ), patch.object(
        GooglePlayService, "acknowledge", new=AsyncMock()
    ) as ack, patch.object(
        SubscriptionService, "sync_iap_subscription", new=AsyncMock(return_value=synced)
    ) as sync:
        result = await iap.register_iap_transaction(request, user={"id": "user-1"}, db=db)

    assert result["data"]["billing_provider"] == "google"
    ack.assert_awaited_once_with("com.fitcheck.plus.monthly", "token-abc")
    assert sync.call_args.kwargs["google_purchase_token"] == "token-abc"
    assert sync.call_args.kwargs["google_order_id"] == "GPA.1234"


@pytest.mark.asyncio
async def test_register_google_transaction_rejects_unknown_product():
    db = FakeDB()
    request = RegisterIapTransactionRequest(
        store=StoreType.GOOGLE,
        transaction_id="token-abc",
        product_id="com.fitcheck.nope",
    )
    with patch.object(
        GooglePlayService, "get_subscription", new=AsyncMock()
    ), patch.object(SubscriptionService, "sync_iap_subscription", new=AsyncMock()) as sync:
        with pytest.raises(ValidationError, match="Unknown Google Play product"):
            await iap.register_iap_transaction(request, user={"id": "user-1"}, db=db)
    sync.assert_not_called()


# ---------------------------------------------------------------------------
# Apple notifications webhook
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_apple_notification_syncs_subscription():
    db = FakeDB(
        subscriptions_lookup={"orig-1": {"user_id": "user-1"}}
    )
    notification = {
        "notificationId": "n1",
        "notificationType": "SUBSCRIBED",
        "data": {"signedTransactionInfo": "tx.jws"},
    }
    tx_info = {
        "transactionId": "tx-1",
        "originalTransactionId": "orig-1",
        "bundleId": "com.fitcheckaiapp.fitcheckai",
        "productId": "com.fitcheck.plus.monthly",
        "purchaseDate": 1_700_000_000_000,
        "expiresDate": 1_700_300_000_000,
    }
    synced = _sub_response(plan_type=PlanType.PLUS_MONTHLY, billing_provider="apple")

    with patch.multiple(settings, **_iap_settings()), patch.object(
        AppleIAPService, "verify_notification", return_value=notification
    ), patch.object(
        AppleIAPService, "verify_jws", return_value=tx_info
    ), patch.object(
        SubscriptionService, "sync_iap_subscription", new=AsyncMock(return_value=synced)
    ) as sync:
        result = await iap.apple_notifications(
            FakeRequest({"signedPayload": "signed.payload.jws"}), db
        )

    assert result == {"received": True}
    assert "n1" in db.seen["apple_iap_events"]
    assert sync.call_args.kwargs["provider"] == "apple"
    assert sync.call_args.kwargs["apple_original_transaction_id"] == "orig-1"


@pytest.mark.asyncio
async def test_apple_notification_duplicate_is_acked_once():
    db = FakeDB(subscriptions_lookup={"orig-1": {"user_id": "user-1"}})
    notification = {
        "notificationId": "dup-1",
        "notificationType": "SUBSCRIBED",
        "data": {"signedTransactionInfo": "tx.jws"},
    }
    tx_info = {
        "originalTransactionId": "orig-1",
        "bundleId": "com.fitcheckaiapp.fitcheckai",
        "productId": "com.fitcheck.plus.monthly",
    }
    with patch.multiple(settings, **_iap_settings()), patch.object(
        AppleIAPService, "verify_notification", return_value=notification
    ), patch.object(
        AppleIAPService, "verify_jws", return_value=tx_info
    ), patch.object(
        SubscriptionService, "sync_iap_subscription", new=AsyncMock()
    ) as sync:
        first = await iap.apple_notifications(FakeRequest({"signedPayload": "jws"}), db)
        second = await iap.apple_notifications(FakeRequest({"signedPayload": "jws"}), db)

    assert first == {"received": True}
    assert second == {"received": True, "duplicate": True}
    assert sync.await_count == 1


@pytest.mark.asyncio
async def test_apple_notification_bad_signature_is_acked_without_processing():
    db = FakeDB()
    with patch.object(
        AppleIAPService, "verify_notification",
        side_effect=AppleIAPSignatureError("bad signature"),
    ), patch.object(
        SubscriptionService, "sync_iap_subscription", new=AsyncMock()
    ) as sync:
        result = await iap.apple_notifications(FakeRequest({"signedPayload": "jws"}), db)

    assert result == {"received": True}
    sync.assert_not_called()


@pytest.mark.asyncio
async def test_apple_notification_expired_downgrades_user():
    db = FakeDB(
        subscriptions_lookup={"orig-1": {"user_id": "user-1"}}
    )
    notification = {
        "notificationId": "exp-1",
        "notificationType": "EXPIRED",
        "data": {"signedRenewalInfo": "renewal.jws"},
    }
    with patch.object(
        AppleIAPService, "verify_notification", return_value=notification
    ), patch.object(
        AppleIAPService, "verify_jws", return_value={"originalTransactionId": "orig-1"}
    ), patch.object(
        SubscriptionService, "sync_iap_subscription", new=AsyncMock()
    ) as sync:
        result = await iap.apple_notifications(FakeRequest({"signedPayload": "jws"}), db)

    assert result == {"received": True}
    assert sync.await_count == 1
    assert sync.call_args.kwargs["status"] == "free"


# ---------------------------------------------------------------------------
# Google RTDN webhook
# ---------------------------------------------------------------------------


def _rtdn_push_body(payload, message_id="msg-1"):
    return {
        "message": {
            "messageId": message_id,
            "data": base64.b64encode(json.dumps(payload).encode()).decode(),
        },
        "subscription": "projects/test/subscriptions/push",
    }


@pytest.mark.asyncio
async def test_google_notification_syncs_and_acknowledges():
    db = FakeDB(
        subscriptions_lookup={"token-abc": {"user_id": "user-1"}}
    )
    purchase = {
        "startTimeMillis": "1700000000000",
        "expiryTimeMillis": "1700300000000",
        "autoRenewing": True,
        "paymentState": 1,
        "orderId": "GPA.1234",
    }
    synced = _sub_response(plan_type=PlanType.PLUS_MONTHLY, billing_provider="google")
    notification = {
        "version": "1.0",
        "subscriptionNotification": {
            "notificationType": 2,
            "purchaseToken": "token-abc",
            "subscriptionId": "com.fitcheck.plus.monthly",
        },
    }
    body = _rtdn_push_body(notification)

    with patch.multiple(settings, **_iap_settings()), patch.object(
        GooglePlayService, "verify_rtdn_authorization", new=AsyncMock(return_value={"aud": "x"})
    ), patch.object(
        GooglePlayService, "get_subscription", new=AsyncMock(return_value=purchase)
    ), patch.object(
        GooglePlayService, "acknowledge", new=AsyncMock()
    ) as ack, patch.object(
        SubscriptionService, "sync_iap_subscription", new=AsyncMock(return_value=synced)
    ) as sync:
        result = await iap.google_notifications(
            FakeRequest(body, headers={"Authorization": "Bearer tok"}), db
        )

    assert result == {"received": True}
    assert "msg-1" in db.seen["google_rtdn_events"]
    assert sync.call_args.kwargs["google_purchase_token"] == "token-abc"
    ack.assert_awaited_once_with("com.fitcheck.plus.monthly", "token-abc")


@pytest.mark.asyncio
async def test_google_notification_rejects_bad_authorization():
    db = FakeDB()
    body = _rtdn_push_body({"version": "1.0", "testNotification": {"version": "1.0"}})
    with patch.object(
        GooglePlayService, "verify_rtdn_authorization",
        new=AsyncMock(side_effect=GooglePlayVerificationError("nope")),
    ):
        with pytest.raises(Exception, match="RTDN verification failed"):
            await iap.google_notifications(
                FakeRequest(body, headers={"Authorization": "Bearer bad"}), db
            )


@pytest.mark.asyncio
async def test_google_notification_test_message_is_acked():
    db = FakeDB()
    body = _rtdn_push_body({"version": "1.0", "testNotification": {"version": "1.0"}})
    with patch.object(
        GooglePlayService, "verify_rtdn_authorization", new=AsyncMock(return_value={"aud": "x"})
    ), patch.object(
        GooglePlayService, "get_subscription", new=AsyncMock()
    ) as get_sub:
        result = await iap.google_notifications(
            FakeRequest(body, headers={"Authorization": "Bearer tok"}), db
        )

    assert result == {"received": True}
    get_sub.assert_not_called()


@pytest.mark.asyncio
async def test_google_notification_duplicate_is_acked_once():
    db = FakeDB(
        subscriptions_lookup={"token-abc": {"user_id": "user-1"}}
    )
    purchase = {"autoRenewing": True, "paymentState": 1}
    notification = {
        "subscriptionNotification": {
            "notificationType": 4,
            "purchaseToken": "token-abc",
            "subscriptionId": "com.fitcheck.plus.monthly",
        },
    }
    body = _rtdn_push_body(notification)
    with patch.multiple(settings, **_iap_settings()), patch.object(
        GooglePlayService, "verify_rtdn_authorization", new=AsyncMock(return_value={"aud": "x"})
    ), patch.object(
        GooglePlayService, "get_subscription", new=AsyncMock(return_value=purchase)
    ), patch.object(
        GooglePlayService, "acknowledge", new=AsyncMock()
    ), patch.object(
        SubscriptionService, "sync_iap_subscription", new=AsyncMock()
    ) as sync:
        first = await iap.google_notifications(
            FakeRequest(body, headers={"Authorization": "Bearer tok"}), db
        )
        second = await iap.google_notifications(
            FakeRequest(body, headers={"Authorization": "Bearer tok"}), db
        )

    assert first == {"received": True}
    assert second == {"received": True, "duplicate": True}
    assert sync.await_count == 1
