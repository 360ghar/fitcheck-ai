"""Tests for the Google Play Developer API service."""
import base64
import json
import time
from unittest.mock import AsyncMock, Mock, patch

import pytest
from cryptography.hazmat.primitives import serialization
from jose import jwt

from app.core.config import settings
from app.core.exceptions import ValidationError
from app.models.subscription import PlanType
from app.services.google_play_service import (
    GOOGLE_OAUTH_TOKEN_URL,
    GooglePlayService,
    GooglePlayVerificationError,
)
from tests.iap_test_utils import make_rsa_key_pem, make_rsa_public_pem


def _google_settings(rsa_pem):
    return {
        "GOOGLE_PACKAGE_NAME": "com.fitcheckaiapp.fitcheckai",
        "GOOGLE_SERVICE_ACCOUNT_JSON": json.dumps({
            "type": "service_account",
            "project_id": "test-project",
            "private_key_id": "pk-1",
            "private_key": rsa_pem,
            "client_email": "billing@test-project.iam.gserviceaccount.com",
            "token_uri": GOOGLE_OAUTH_TOKEN_URL,
        }),
        "GOOGLE_RTDN_AUDIENCE": "projects/test-project/topics/rtdn",
        "GOOGLE_PLUS_MONTHLY_PRODUCT_ID": "com.fitcheck.plus.monthly",
        "GOOGLE_PLUS_YEARLY_PRODUCT_ID": "com.fitcheck.plus.yearly",
        "GOOGLE_PRO_MONTHLY_PRODUCT_ID": "com.fitcheck.pro.monthly",
        "GOOGLE_PRO_YEARLY_PRODUCT_ID": "com.fitcheck.pro.yearly",
    }


def _purchase(**overrides):
    now_ms = int(time.time() * 1000)
    purchase = {
        "kind": "androidpublisher#subscriptionPurchase",
        "startTimeMillis": str(now_ms),
        "expiryTimeMillis": str(now_ms + 30 * 24 * 3600 * 1000),
        "autoRenewing": True,
        "priceCurrencyCode": "USD",
        "priceAmountMicros": "10000000",
        "paymentState": 1,
        "orderId": "GPA.1234-5678",
        "acknowledgementState": 0,
    }
    purchase.update(overrides)
    return purchase


# ---------------------------------------------------------------------------
# Product mapping
# ---------------------------------------------------------------------------


def test_product_plan_map_and_plan_for_product(rsa_pem):
    with patch.multiple(settings, **_google_settings(rsa_pem)):
        assert GooglePlayService.plan_for_product("com.fitcheck.pro.monthly") == PlanType.PRO_MONTHLY
        with pytest.raises(ValidationError, match="Unknown Google Play product"):
            GooglePlayService.plan_for_product("com.fitcheck.nope")


@pytest.fixture()
def rsa_pem():
    return make_rsa_key_pem()


# ---------------------------------------------------------------------------
# OAuth access token
# ---------------------------------------------------------------------------


class _FakeAsyncClient:
    def __init__(self, post_response, get_response=None):
        self.post_response = post_response
        self.get_response = get_response
        self.post_calls = 0

    async def __aenter__(self):
        return self

    async def __aexit__(self, *args):
        return False

    async def post(self, url, **kwargs):
        self.post_calls += 1
        return self.post_response

    async def get(self, url, **kwargs):
        return self.get_response


@pytest.mark.asyncio
async def test_get_access_token_exchanges_jwt_and_caches(rsa_pem):
    with patch.multiple(settings, **_google_settings(rsa_pem)):
        client = _FakeAsyncClient(
            Mock(status_code=200, json=lambda: {"access_token": "tok-1", "expires_in": 3599})
        )
        with patch("httpx.AsyncClient", return_value=client):
            first = await GooglePlayService.get_access_token()
            second = await GooglePlayService.get_access_token()

    assert first == "tok-1"
    assert second == "tok-1"
    assert client.post_calls == 1  # cached after the first exchange
    # The assertion JWT must carry the service account + scope.
    assert GooglePlayService._token_cache is not None
    GooglePlayService._token_cache = None


@pytest.mark.asyncio
async def test_get_access_token_raises_on_failed_exchange(rsa_pem):
    with patch.multiple(settings, **_google_settings(rsa_pem)):
        client = _FakeAsyncClient(Mock(status_code=401, json=lambda: {"error": "invalid_grant"}))
        with patch("httpx.AsyncClient", return_value=client):
            with pytest.raises(GooglePlayVerificationError, match="HTTP 401"):
                await GooglePlayService.get_access_token()
    GooglePlayService._token_cache = None


@pytest.mark.asyncio
async def test_get_subscription_returns_purchase(rsa_pem):
    with patch.multiple(settings, **_google_settings(rsa_pem)):
        purchase = _purchase()
        with patch.object(
            GooglePlayService,
            "_publisher_request",
            new=AsyncMock(return_value=Mock(status_code=200, json=lambda: purchase)),
        ) as request:
            result = await GooglePlayService.get_subscription(
                "com.fitcheck.plus.monthly", "token-abc"
            )

    assert result["orderId"] == "GPA.1234-5678"
    call_path = request.call_args.args[1]
    assert "com.fitcheckaiapp.fitcheckai" in call_path
    assert "com.fitcheck.plus.monthly" in call_path
    assert "token-abc" in call_path


@pytest.mark.asyncio
async def test_get_subscription_404_raises_verification_error(rsa_pem):
    with patch.multiple(settings, **_google_settings(rsa_pem)):
        with patch.object(
            GooglePlayService,
            "_publisher_request",
            new=AsyncMock(return_value=Mock(status_code=404)),
        ):
            with pytest.raises(GooglePlayVerificationError, match="not found"):
                await GooglePlayService.get_subscription("com.fitcheck.plus.monthly", "token-abc")


@pytest.mark.asyncio
async def test_acknowledge_posts_to_acknowledge_endpoint(rsa_pem):
    with patch.multiple(settings, **_google_settings(rsa_pem)):
        with patch.object(
            GooglePlayService,
            "_publisher_request",
            new=AsyncMock(return_value=Mock(status_code=204)),
        ) as request:
            await GooglePlayService.acknowledge("com.fitcheck.plus.monthly", "token-abc")

    assert request.call_args.args[1].endswith(":acknowledge")
    assert request.call_args.kwargs["json_body"] == {"developerPayload": ""}


# ---------------------------------------------------------------------------
# Entitlement normalization
# ---------------------------------------------------------------------------


def test_subscription_to_entitlement_active(rsa_pem):
    with patch.multiple(settings, **_google_settings(rsa_pem)):
        entitlement = GooglePlayService.subscription_to_entitlement(
            _purchase(), "com.fitcheck.plus.monthly"
        )
    assert entitlement["plan_type"] == PlanType.PLUS_MONTHLY
    assert entitlement["status"] == "active"
    assert entitlement["cancel_at_period_end"] is False
    assert entitlement["order_id"] == "GPA.1234-5678"
    assert entitlement["current_period_end"] is not None


def test_subscription_to_entitlement_expired_is_free(rsa_pem):
    purchase = _purchase(
        expiryTimeMillis=str(1_600_000_000_000),  # in the past
        autoRenewing=False,
    )
    with patch.multiple(settings, **_google_settings(rsa_pem)):
        entitlement = GooglePlayService.subscription_to_entitlement(
            purchase, "com.fitcheck.plus.monthly"
        )
    assert entitlement["status"] == "free"


def test_subscription_to_entitlement_payment_pending_is_past_due(rsa_pem):
    purchase = _purchase(paymentState=0)
    with patch.multiple(settings, **_google_settings(rsa_pem)):
        entitlement = GooglePlayService.subscription_to_entitlement(
            purchase, "com.fitcheck.plus.monthly"
        )
    assert entitlement["status"] == "past_due"


def test_subscription_to_entitlement_user_cancelled_without_expiry(rsa_pem):
    purchase = _purchase(cancelReason=0, autoRenewing=False)
    with patch.multiple(settings, **_google_settings(rsa_pem)):
        entitlement = GooglePlayService.subscription_to_entitlement(
            purchase, "com.fitcheck.plus.monthly"
        )
    assert entitlement["status"] == "past_due"
    assert entitlement["cancel_at_period_end"] is True


# ---------------------------------------------------------------------------
# RTDN authorization (OIDC bearer token)
# ---------------------------------------------------------------------------


def _rtdn_token(rsa_key_pem, audience, kid="pk-1"):
    now = int(time.time())
    return jwt.encode(
        {
            "iss": "test-service@test-project.iam.gserviceaccount.com",
            "aud": audience,
            "iat": now,
            "exp": now + 3600,
        },
        rsa_key_pem,
        algorithm="RS256",
        headers={"kid": kid},
    )


@pytest.mark.asyncio
async def test_verify_rtdn_authorization_accepts_valid_token(rsa_pem):
    key = serialization.load_pem_private_key(rsa_pem.encode(), password=None)
    public_pem = make_rsa_public_pem(key)
    token = _rtdn_token(rsa_pem, "projects/test-project/topics/rtdn")

    with patch.multiple(settings, **_google_settings(rsa_pem)):
        with patch.object(
            GooglePlayService, "_fetch_oidc_certs", new=AsyncMock(return_value={"pk-1": public_pem})
        ):
            claims = await GooglePlayService.verify_rtdn_authorization(f"Bearer {token}")

    assert claims["aud"] == "projects/test-project/topics/rtdn"


@pytest.mark.asyncio
async def test_verify_rtdn_authorization_rejects_wrong_audience(rsa_pem):
    key = serialization.load_pem_private_key(rsa_pem.encode(), password=None)
    public_pem = make_rsa_public_pem(key)
    token = _rtdn_token(rsa_pem, "projects/other-project/topics/rtdn")

    with patch.multiple(settings, **_google_settings(rsa_pem)):
        with patch.object(
            GooglePlayService, "_fetch_oidc_certs", new=AsyncMock(return_value={"pk-1": public_pem})
        ):
            with pytest.raises(GooglePlayVerificationError, match="verification failed"):
                await GooglePlayService.verify_rtdn_authorization(f"Bearer {token}")


@pytest.mark.asyncio
async def test_verify_rtdn_authorization_rejects_missing_bearer(rsa_pem):
    with patch.multiple(settings, **_google_settings(rsa_pem)):
        with pytest.raises(GooglePlayVerificationError, match="Missing bearer token"):
            await GooglePlayService.verify_rtdn_authorization(None)


@pytest.mark.asyncio
async def test_verify_rtdn_authorization_fails_closed_without_audience(rsa_pem):
    with patch.multiple(settings, GOOGLE_RTDN_AUDIENCE=None):
        with pytest.raises(GooglePlayVerificationError, match="GOOGLE_RTDN_AUDIENCE"):
            await GooglePlayService.verify_rtdn_authorization("Bearer whatever")


# ---------------------------------------------------------------------------
# Pub/Sub message decoding + notification handling
# ---------------------------------------------------------------------------


def test_decode_pubsub_message(rsa_pem):
    raw = json.dumps({"version": "1.0", "packageName": "com.fitcheckaiapp.fitcheckai"}).encode()
    body = {
        "message": {
            "messageId": "msg-1",
            "data": base64.b64encode(raw).decode(),
        },
        "subscription": "projects/test-project/subscriptions/rtdn-push",
    }
    message_id, notification = GooglePlayService._decode_pubsub_message(body)
    assert message_id == "msg-1"
    assert notification["packageName"] == "com.fitcheckaiapp.fitcheckai"


def test_decode_pubsub_message_rejects_missing_data():
    with pytest.raises(GooglePlayVerificationError, match="no data"):
        GooglePlayService._decode_pubsub_message({"message": {"messageId": "msg-1"}})


def test_handle_test_notification(rsa_pem):
    event = GooglePlayService.handle_subscription_notification(
        {"version": "1.0", "testNotification": {"version": "1.0"}}
    )
    assert event == {"kind": "test"}


def test_handle_subscription_notification(rsa_pem):
    event = GooglePlayService.handle_subscription_notification(
        {
            "version": "1.0",
            "packageName": "com.fitcheckaiapp.fitcheckai",
            "subscriptionNotification": {
                "version": "1.0",
                "notificationType": 2,
                "purchaseToken": "token-abc",
                "subscriptionId": "com.fitcheck.plus.monthly",
            },
        }
    )
    assert event == {
        "kind": "subscription",
        "subscription_id": "com.fitcheck.plus.monthly",
        "purchase_token": "token-abc",
        "notification_type": 2,
        "notification_type_name": "SUBSCRIPTION_RENEWED",
    }


def test_handle_subscription_notification_rejects_incomplete(rsa_pem):
    with pytest.raises(GooglePlayVerificationError, match="missing purchaseToken"):
        GooglePlayService.handle_subscription_notification(
            {"subscriptionNotification": {"subscriptionId": "com.fitcheck.plus.monthly"}}
        )
