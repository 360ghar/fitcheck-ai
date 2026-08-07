"""
Route-level coverage for app/api/v1/iap.py.

Complements tests/integration/test_iap_api.py (which owns the happy paths and
the store-identifier resolver) by covering the remaining error branches:
signature/renewal-info failures, ledger insert/finish failures, unknown-store
rejection, entitlement-loss arms without a resolved user, Google decode
failures, and the 500 retry arms of both store webhooks.
"""
import base64
import json
from unittest.mock import AsyncMock, Mock, patch

import pytest
from fastapi import HTTPException

from app.api.v1 import iap
from app.core.config import settings
from app.core.exceptions import ValidationError
from app.models.subscription import RegisterIapTransactionRequest, StoreType
from app.services.apple_iap_service import AppleIAPService, AppleIAPSignatureError
from app.services.google_play_service import (
    GooglePlayService,
    GooglePlayVerificationError,
)
from app.services.subscription_service import SubscriptionService


class _FakeRequest:
    """Minimal FastAPI Request double exposing json() and headers."""

    def __init__(self, body, headers=None):
        self._body = body
        self._headers = headers or {}

    async def json(self):
        if isinstance(self._body, Exception):
            raise self._body
        return self._body

    @property
    def headers(self):
        return self._headers


class _LedgerDB:
    """Chained postgrest-style double with configurable ledger behaviour.

    ``insert_failures``/``update_failures`` let a test make the webhook-event
    ledger raise (duplicate constraints, generic errors, ledger outages).
    """

    def __init__(self, subscriptions_lookup=None, users=None, insert_failures=None, update_failures=None):
        self.seen = {"apple_iap_events": set(), "google_rtdn_events": set()}
        self.subscriptions_lookup = subscriptions_lookup or {}
        self.users = set(users or ())
        self.inserts = []
        self.updates = []
        self.insert_failures = insert_failures or {}
        self.update_failures = update_failures or {}

    def table(self, name):
        return _Table(self, name)


class _Table:
    def __init__(self, db, name):
        self.db = db
        self.name = name
        self._payload = None
        self._method = None
        self._eq_col = None
        self._eq_val = None

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
        return self

    def eq(self, col, val):
        self._eq_col, self._eq_val = col, val
        return self

    def limit(self, n):
        return self

    def order(self, col, desc=False):
        return self

    def maybe_single(self):
        return self

    def execute(self):
        if self._method == "insert":
            pk = "notification_id" if self.name == "apple_iap_events" else "message_id"
            value = self._payload.get(pk)
            if value in self.db.seen[self.name]:
                raise Exception("duplicate key value violates unique constraint")
            failure = self.db.insert_failures.get(self.name)
            if failure:
                raise failure
            self.db.seen[self.name].add(value)
            self.db.inserts.append((self.name, dict(self._payload)))
            return Mock(data=[])
        if self._method == "update":
            failure = self.db.update_failures.get(self.name)
            if failure:
                raise failure
            self.db.updates.append((self.name, self._payload, self._eq_col, self._eq_val))
            return Mock(data=[])
        if self._method == "select":
            if self.name == "users":
                exists = self._eq_val in self.db.users
                return Mock(data=[{"id": self._eq_val}] if exists else [])
            rows = self.db.subscriptions_lookup.get(self._eq_val)
            if isinstance(rows, dict):
                rows = [rows]
            return Mock(data=rows)
        return Mock(data=[])


def _tx_info(**overrides):
    info = {
        "transactionId": "tx-1",
        "originalTransactionId": "orig-1",
        "bundleId": "com.fitcheckaiapp.fitcheckai",
        "productId": "com.fitcheck.plus.monthly",
        "purchaseDate": 1_700_000_000_000,
        "expiresDate": 1_700_300_000_000,
    }
    info.update(overrides)
    return info


def _notification(**overrides):
    notif = {"notificationId": "n-1", "notificationType": "SUBSCRIBED", "data": {}}
    notif.update(overrides)
    return notif


def _sync_result():
    return Mock(model_dump=lambda mode="json": {"plan_type": "plus_monthly"})


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
# register_iap_transaction
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_register_iap_transaction_apple_without_client_product_id():
    """product_id is optional; when omitted there is no cross-check to fail."""
    request = RegisterIapTransactionRequest(store=StoreType.APPLE, transaction_id="tx-1")

    with patch.multiple(settings, **_iap_settings()), patch.object(
        AppleIAPService, "verify_transaction", new=AsyncMock(return_value=_tx_info())
    ), patch.object(
        SubscriptionService, "sync_iap_subscription", new=AsyncMock(return_value=_sync_result())
    ) as sync:
        result = await iap.register_iap_transaction(request, user={"id": "user-1"}, db=_LedgerDB())

    assert result["message"] == "OK"
    sync.assert_awaited_once()


@pytest.mark.asyncio
async def test_register_iap_transaction_rejects_unknown_store():
    """Defensive fall-through: only APPLE/GOOGLE are valid enum values, but the
    branch must still fail closed if a non-enum value ever reaches the route."""
    request = RegisterIapTransactionRequest(store=StoreType.APPLE, transaction_id="tx-1")
    request.store = "amazon"  # bypass pydantic enum coercion

    with pytest.raises(ValidationError, match="Unknown store"):
        await iap.register_iap_transaction(request, user={"id": "user-1"}, db=_LedgerDB())


# ---------------------------------------------------------------------------
# Apple notifications: request / payload validation
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_apple_notifications_rejects_invalid_json():
    with pytest.raises(HTTPException) as exc_info:
        await iap.apple_notifications(_FakeRequest(ValueError("not json")), _LedgerDB())
    assert exc_info.value.status_code == 400
    assert exc_info.value.detail == "Invalid JSON body"


@pytest.mark.asyncio
async def test_apple_notifications_rejects_missing_signed_payload():
    with pytest.raises(HTTPException) as exc_info:
        await iap.apple_notifications(_FakeRequest({"foo": "bar"}), _LedgerDB())
    assert exc_info.value.status_code == 400
    assert exc_info.value.detail == "Missing signedPayload"


@pytest.mark.asyncio
async def test_apple_notifications_rejects_missing_notification_id():
    with patch.object(
        AppleIAPService, "verify_notification", return_value={"notificationType": "TEST"}
    ):
        with pytest.raises(HTTPException) as exc_info:
            await iap.apple_notifications(_FakeRequest({"signedPayload": "jws"}), _LedgerDB())
    assert exc_info.value.status_code == 400
    assert exc_info.value.detail == "Notification has no notificationId"


# ---------------------------------------------------------------------------
# Apple notifications: renewal-info and entitlement-loss arms
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_apple_notification_unverifiable_renewal_info_is_ignored():
    """A bad-signature signedRenewalInfo means 'no claims to act on': the
    entitlement-loss arm must skip the downgrade and still ack."""
    notification = _notification(
        notificationId="n-bad-renewal",
        notificationType="EXPIRED",
        data={"signedRenewalInfo": "bad.jws"},
    )
    with patch.object(
        AppleIAPService, "verify_notification", return_value=notification
    ), patch.object(
        AppleIAPService,
        "verify_jws",
        side_effect=AppleIAPSignatureError("bad signature"),
    ), patch.object(
        SubscriptionService, "sync_iap_subscription", new=AsyncMock()
    ) as sync:
        result = await iap.apple_notifications(_FakeRequest({"signedPayload": "jws"}), _LedgerDB())

    assert result == {"received": True}
    sync.assert_not_called()


@pytest.mark.asyncio
async def test_apple_notification_entitlement_loss_without_transaction_id_is_acked():
    """EXPIRED with no resolvable originalTransactionId must not downgrade
    anyone, but must still be acknowledged as processed."""
    notification = _notification(
        notificationId="n-no-orig", notificationType="EXPIRED", data={}
    )
    with patch.object(
        AppleIAPService, "verify_notification", return_value=notification
    ), patch.object(
        SubscriptionService, "sync_iap_subscription", new=AsyncMock()
    ) as sync:
        result = await iap.apple_notifications(_FakeRequest({"signedPayload": "jws"}), _LedgerDB())

    assert result == {"received": True}
    sync.assert_not_called()


@pytest.mark.asyncio
async def test_apple_notification_entitlement_loss_without_user_is_acked():
    """The renewal info names a transaction, but no subscription row carries
    it: skip the downgrade rather than inventing an owner."""
    notification = _notification(
        notificationId="n-no-user",
        notificationType="REVOKE",
        data={"signedRenewalInfo": "renewal.jws"},
    )
    db = _LedgerDB(subscriptions_lookup={})
    with patch.object(
        AppleIAPService, "verify_notification", return_value=notification
    ), patch.object(
        AppleIAPService, "verify_jws", return_value={"originalTransactionId": "orig-missing"}
    ), patch.object(
        SubscriptionService, "sync_iap_subscription", new=AsyncMock()
    ) as sync:
        result = await iap.apple_notifications(_FakeRequest({"signedPayload": "jws"}), db)

    assert result == {"received": True}
    sync.assert_not_called()


@pytest.mark.asyncio
async def test_apple_notification_unknown_type_is_acked_without_side_effects():
    """Apple's TEST notification (and any unrecognized type) is a successful
    round trip, never a failure and never an entitlement change."""
    notification = _notification(
        notificationId="n-test", notificationType="TEST", data={}
    )
    with patch.object(
        AppleIAPService, "verify_notification", return_value=notification
    ), patch.object(
        SubscriptionService, "sync_iap_subscription", new=AsyncMock()
    ) as sync:
        result = await iap.apple_notifications(_FakeRequest({"signedPayload": "jws"}), _LedgerDB())

    assert result == {"received": True}
    sync.assert_not_called()


@pytest.mark.asyncio
async def test_apple_notification_processing_failure_returns_500_and_marks_failed():
    """A failed handler must raise so Apple retries, and the ledger row is
    marked failed with the error detail."""
    notification = _notification(data={"signedTransactionInfo": "tx.jws"})
    db = _LedgerDB(subscriptions_lookup={"orig-1": {"user_id": "user-1"}})
    with patch.multiple(settings, **_iap_settings()), patch.object(
        AppleIAPService, "verify_notification", return_value=notification
    ), patch.object(
        AppleIAPService, "verify_jws", return_value=_tx_info()
    ), patch.object(
        SubscriptionService,
        "sync_iap_subscription",
        new=AsyncMock(side_effect=RuntimeError("db unavailable")),
    ):
        with pytest.raises(HTTPException) as exc_info:
            await iap.apple_notifications(_FakeRequest({"signedPayload": "jws"}), db)

    assert exc_info.value.status_code == 500
    assert any(
        name == "apple_iap_events" and payload.get("status") == "failed"
        for name, payload, _col, _val in db.updates
    )


@pytest.mark.asyncio
async def test_apple_notification_ledger_insert_error_returns_500():
    """A non-duplicate ledger failure must surface as 500 so Apple retries
    (a swallowed insert would let the notification be lost)."""
    notification = _notification(data={"signedTransactionInfo": "tx.jws"})
    db = _LedgerDB(insert_failures={"apple_iap_events": RuntimeError("ledger down")})
    with patch.multiple(settings, **_iap_settings()), patch.object(
        AppleIAPService, "verify_notification", return_value=notification
    ), patch.object(
        AppleIAPService, "verify_jws", return_value=_tx_info()
    ):
        with pytest.raises(HTTPException) as exc_info:
            await iap.apple_notifications(_FakeRequest({"signedPayload": "jws"}), db)

    assert exc_info.value.status_code == 500
    assert exc_info.value.detail == "Failed to record webhook event"


@pytest.mark.asyncio
async def test_apple_notification_ledger_finish_error_is_swallowed():
    """The processing result is authoritative; a failure to record the
    'processed' marker must not turn a successful ack into a retry storm."""
    notification = _notification(data={"signedTransactionInfo": "tx.jws"})
    db = _LedgerDB(
        subscriptions_lookup={"orig-1": {"user_id": "user-1"}},
        update_failures={"apple_iap_events": RuntimeError("ledger down")},
    )
    with patch.multiple(settings, **_iap_settings()), patch.object(
        AppleIAPService, "verify_notification", return_value=notification
    ), patch.object(
        AppleIAPService, "verify_jws", return_value=_tx_info()
    ), patch.object(
        SubscriptionService, "sync_iap_subscription", new=AsyncMock()
    ):
        result = await iap.apple_notifications(_FakeRequest({"signedPayload": "jws"}), db)

    assert result == {"received": True}


def _rtdn_push_body(payload, message_id="msg-1"):
    return {
        "message": {
            "messageId": message_id,
            "data": base64.b64encode(json.dumps(payload).encode()).decode(),
        },
        "subscription": "projects/test/subscriptions/push",
    }


# ---------------------------------------------------------------------------
# Google RTDN webhook
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_google_notifications_rejects_invalid_json():
    with pytest.raises(HTTPException) as exc_info:
        await iap.google_notifications(_FakeRequest(ValueError("not json")), _LedgerDB())
    assert exc_info.value.status_code == 400
    assert exc_info.value.detail == "Invalid JSON body"


@pytest.mark.asyncio
async def test_google_notifications_rejects_bad_pubsub_envelope():
    with patch.object(
        GooglePlayService, "verify_rtdn_authorization", new=AsyncMock(return_value={"aud": "x"})
    ), patch.object(
        GooglePlayService,
        "_decode_pubsub_message",
        side_effect=GooglePlayVerificationError("malformed envelope"),
    ):
        with pytest.raises(HTTPException) as exc_info:
            await iap.google_notifications(
                _FakeRequest({"message": {}}, headers={"Authorization": "Bearer tok"}),
                _LedgerDB(),
            )
    assert exc_info.value.status_code == 400


@pytest.mark.asyncio
async def test_google_notification_without_a_matching_user_still_acks_and_acknowledges():
    """An unknown purchase token cannot grant an entitlement, but the push is
    still acked (the app's register call re-syncs the same token idempotently)
    and the purchase is acknowledged so Play stops retrying."""
    notification = {
        "version": "1.0",
        "subscriptionNotification": {
            "notificationType": 2,
            "purchaseToken": "token-unknown",
            "subscriptionId": "com.fitcheck.plus.monthly",
        },
    }
    db = _LedgerDB(subscriptions_lookup={})
    with patch.multiple(settings, **_iap_settings()), patch.object(
        GooglePlayService, "verify_rtdn_authorization", new=AsyncMock(return_value={"aud": "x"})
    ), patch.object(
        GooglePlayService, "get_subscription", new=AsyncMock(return_value={"autoRenewing": True})
    ), patch.object(
        GooglePlayService, "acknowledge", new=AsyncMock()
    ) as ack, patch.object(
        SubscriptionService, "sync_iap_subscription", new=AsyncMock()
    ) as sync:
        result = await iap.google_notifications(
            _FakeRequest(_rtdn_push_body(notification, message_id="msg-9")), db
        )

    assert result == {"received": True}
    sync.assert_not_called()
    ack.assert_awaited_once()


@pytest.mark.asyncio
async def test_google_notification_processing_failure_returns_500():
    notification = {
        "version": "1.0",
        "subscriptionNotification": {
            "notificationType": 2,
            "purchaseToken": "token-abc",
            "subscriptionId": "com.fitcheck.plus.monthly",
        },
    }
    with patch.object(
        GooglePlayService, "verify_rtdn_authorization", new=AsyncMock(return_value={"aud": "x"})
    ), patch.object(
        GooglePlayService, "get_subscription",
        new=AsyncMock(side_effect=RuntimeError("play api down")),
    ):
        with pytest.raises(HTTPException) as exc_info:
            await iap.google_notifications(
                _FakeRequest(_rtdn_push_body(notification, message_id="msg-10")),
                _LedgerDB(),
            )
    assert exc_info.value.status_code == 500
    assert exc_info.value.detail == "Failed to process RTDN push"


# ---------------------------------------------------------------------------
# Store-identifier helpers (remaining branches)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_app_account_token_resolver_returns_none_when_query_fails():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.limit.return_value.execute.side_effect = (
        RuntimeError("users table unavailable")
    )
    assert await iap._user_id_for_app_account_token(db, "user-1") is None


@pytest.mark.asyncio
async def test_app_account_token_resolver_returns_the_matching_user():
    db = _LedgerDB(users={"user-1"})
    assert await iap._user_id_for_app_account_token(db, "user-1") == "user-1"


@pytest.mark.asyncio
async def test_store_purchase_resolver_without_identifier_uses_app_account_token():
    db = _LedgerDB(users={"user-42"})
    resolved = await iap._user_id_for_store_purchase(
        db, "apple", None, app_account_token="user-42"
    )
    assert resolved == "user-42"


@pytest.mark.asyncio
async def test_store_purchase_resolver_without_identifier_or_token_returns_none():
    assert await iap._user_id_for_store_purchase(_LedgerDB(), "apple", None) is None


@pytest.mark.asyncio
async def test_store_purchase_resolver_returns_none_when_query_fails():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.order.return_value.limit.return_value.execute.side_effect = (
        RuntimeError("subscriptions unavailable")
    )
    assert await iap._user_id_for_store_purchase(db, "apple", "orig-1") is None


@pytest.mark.asyncio
async def test_store_purchase_resolver_without_identifier_and_bad_token_query_returns_none():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.limit.return_value.execute.side_effect = (
        RuntimeError("users unavailable")
    )
    assert await iap._user_id_for_store_purchase(db, "apple", None, "user-1") is None


# ---------------------------------------------------------------------------
# HTTPException passthrough arms (both webhooks)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_apple_notification_http_exception_is_reraising():
    """A client-level HTTPException raised inside the handler body must
    propagate unchanged — never be converted into a 500 retry payload."""
    notification = _notification(data={"signedTransactionInfo": "tx.jws"})
    with patch.multiple(settings, **_iap_settings()), patch.object(
        AppleIAPService, "verify_notification", return_value=notification
    ), patch.object(
        AppleIAPService,
        "verify_jws",
        side_effect=HTTPException(status_code=418, detail="teapot"),
    ):
        with pytest.raises(HTTPException) as exc_info:
            await iap.apple_notifications(
                _FakeRequest({"signedPayload": "jws"}), _LedgerDB()
            )
    assert exc_info.value.status_code == 418


@pytest.mark.asyncio
async def test_google_notification_http_exception_is_reraising():
    """Same passthrough contract on the Play RTDN side: an HTTPException from
    the notification handler is re-raised, not wrapped as a 500."""
    with patch.multiple(settings, **_iap_settings()), patch.object(
        GooglePlayService, "verify_rtdn_authorization", new=AsyncMock(return_value={"aud": "x"})
    ), patch.object(
        GooglePlayService,
        "_decode_pubsub_message",
        return_value=(
            "msg-1",
            {"subscriptionNotification": {"notificationType": 2, "purchaseToken": "tok"}},
        ),
    ), patch.object(
        GooglePlayService,
        "handle_subscription_notification",
        side_effect=HTTPException(status_code=418, detail="teapot"),
    ):
        with pytest.raises(HTTPException) as exc_info:
            await iap.google_notifications(
                _FakeRequest({"message": {}}, headers={"Authorization": "Bearer tok"}),
                _LedgerDB(),
            )
    assert exc_info.value.status_code == 418
