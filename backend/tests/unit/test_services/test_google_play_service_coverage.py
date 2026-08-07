"""Coverage-completing tests for the Google Play Developer API service.

The sibling ``test_google_play_service.py`` covers the happy token/purchase/
RTDN paths. These tests fill the remaining error and edge branches: service
account configuration guards, missing OAuth tokens, the real publisher
request plumbing, missing-argument and HTTP error branches, acknowledge
failure logging, Pub/Sub decode guards, OIDC cert caching/fetch failures,
unknown token kid, invalid timestamps, and notification shape guards.
"""

import base64
import json
import time
from unittest.mock import AsyncMock, Mock, patch

import pytest
from jose import jwt

from app.core.config import settings
from app.services.google_play_service import (
    GOOGLE_OAUTH_TOKEN_URL,
    GooglePlayError,
    GooglePlayService,
    GooglePlayVerificationError,
)
from tests.utils.fake_iap import make_rsa_key_pem


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


class _FakeHttpClient:
    """httpx.AsyncClient double with a canned response per verb."""

    def __init__(self, response=None, get_response=None):
        self.response = response
        self.get_response = get_response
        self.request_kwargs = None

    async def __aenter__(self):
        return self

    async def __aexit__(self, *args):
        return False

    async def get(self, url, **kwargs):
        return self.get_response

    async def post(self, url, **kwargs):
        return self.response

    async def request(self, method, url, **kwargs):
        self.request_kwargs = (method, url, kwargs)
        return self.response


@pytest.fixture(autouse=True)
def _reset_google_caches():
    GooglePlayService._token_cache = None
    GooglePlayService._certs_cache = None
    yield
    GooglePlayService._token_cache = None
    GooglePlayService._certs_cache = None


# ---------------------------------------------------------------------------
# Configuration / service account
# ---------------------------------------------------------------------------


def test_service_account_raises_when_unconfigured():
    with patch.multiple(settings, GOOGLE_SERVICE_ACCOUNT_JSON=None):
        with pytest.raises(GooglePlayError, match="not configured"):
            GooglePlayService._service_account()


def test_service_account_raises_on_invalid_json():
    with patch.multiple(settings, GOOGLE_SERVICE_ACCOUNT_JSON="not-json"):
        with pytest.raises(GooglePlayError, match="not valid JSON"):
            GooglePlayService._service_account()


# ---------------------------------------------------------------------------
# OAuth token / publisher request
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_fetch_access_token_raises_without_access_token():
    rsa_pem = make_rsa_key_pem()
    with patch.multiple(settings, **_google_settings(rsa_pem)):
        client = _FakeHttpClient(
            response=Mock(status_code=200, json=lambda: {"expires_in": 3600})
        )
        with patch("httpx.AsyncClient", return_value=client):
            with pytest.raises(GooglePlayVerificationError, match="no access token"):
                await GooglePlayService._fetch_access_token()


@pytest.mark.asyncio
async def test_publisher_request_sends_bearer_and_json_body():
    rsa_pem = make_rsa_key_pem()
    with patch.multiple(settings, **_google_settings(rsa_pem)):
        client = _FakeHttpClient(response=Mock(status_code=200))
        with patch.object(
            GooglePlayService, "get_access_token", new=AsyncMock(return_value="tok-1")
        ), patch("httpx.AsyncClient", return_value=client):
            response = await GooglePlayService._publisher_request(
                "POST", "some/path", json_body={"developerPayload": ""}
            )
    assert response.status_code == 200
    method, url, kwargs = client.request_kwargs
    assert method == "POST"
    assert url == "https://androidpublisher.googleapis.com/androidpublisher/v3/some/path"
    assert kwargs["headers"] == {"Authorization": "Bearer tok-1"}
    assert kwargs["json"] == {"developerPayload": ""}


# ---------------------------------------------------------------------------
# Subscription lookup / acknowledge branches
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_subscription_requires_args():
    with pytest.raises(GooglePlayVerificationError, match="Missing subscription ID or purchase token"):
        await GooglePlayService.get_subscription("", "token-abc")
    with pytest.raises(GooglePlayVerificationError, match="Missing subscription ID or purchase token"):
        await GooglePlayService.get_subscription("com.fitcheck.plus.monthly", "")


@pytest.mark.asyncio
async def test_get_subscription_other_http_error():
    rsa_pem = make_rsa_key_pem()
    with patch.multiple(settings, **_google_settings(rsa_pem)):
        with patch.object(
            GooglePlayService,
            "_publisher_request",
            new=AsyncMock(return_value=Mock(status_code=500)),
        ):
            with pytest.raises(GooglePlayVerificationError, match="HTTP 500"):
                await GooglePlayService.get_subscription("com.fitcheck.plus.monthly", "token-abc")


@pytest.mark.asyncio
async def test_acknowledge_logs_failed_ack(caplog):
    rsa_pem = make_rsa_key_pem()
    with patch.multiple(settings, **_google_settings(rsa_pem)):
        with patch.object(
            GooglePlayService,
            "_publisher_request",
            new=AsyncMock(return_value=Mock(status_code=500)),
        ):
            await GooglePlayService.acknowledge("com.fitcheck.plus.monthly", "token-abc")
    assert any(
        "Failed to acknowledge Play purchase" in record.message for record in caplog.records
    )


# ---------------------------------------------------------------------------
# Pub/Sub message decoding
# ---------------------------------------------------------------------------


def test_decode_pubsub_message_rejects_missing_message_id():
    with pytest.raises(GooglePlayVerificationError, match="no messageId"):
        GooglePlayService._decode_pubsub_message({"message": {"data": "e30="}})


def test_decode_pubsub_message_rejects_invalid_json():
    body = {
        "message": {
            "messageId": "msg-1",
            "data": base64.b64encode(b"not json").decode(),
        }
    }
    with pytest.raises(GooglePlayVerificationError, match="not valid JSON"):
        GooglePlayService._decode_pubsub_message(body)


# ---------------------------------------------------------------------------
# OIDC certificate fetch
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_fetch_oidc_certs_fetches_and_caches():
    client = _FakeHttpClient(
        get_response=Mock(status_code=200, json=lambda: {"k1": "pem1"})
    )
    with patch("httpx.AsyncClient", return_value=client):
        certs = await GooglePlayService._fetch_oidc_certs()
    assert certs == {"k1": "pem1"}
    assert GooglePlayService._certs_cache is not None

    # Cache hit: no HTTP round trip.
    with patch("httpx.AsyncClient", side_effect=AssertionError("network must not be hit")):
        assert await GooglePlayService._fetch_oidc_certs() == {"k1": "pem1"}


@pytest.mark.asyncio
async def test_fetch_oidc_certs_http_error():
    client = _FakeHttpClient(get_response=Mock(status_code=503))
    with patch("httpx.AsyncClient", return_value=client):
        with pytest.raises(GooglePlayVerificationError, match="Could not fetch Google OIDC certificates"):
            await GooglePlayService._fetch_oidc_certs()


@pytest.mark.asyncio
async def test_verify_rtdn_authorization_unknown_kid():
    rsa_pem = make_rsa_key_pem()
    token = _rtdn_token(rsa_pem, "projects/test-project/topics/rtdn", kid="unknown-kid")
    with patch.multiple(settings, **_google_settings(rsa_pem)):
        with patch.object(
            GooglePlayService,
            "_fetch_oidc_certs",
            new=AsyncMock(return_value={"pk-1": "pem"}),
        ):
            with pytest.raises(GooglePlayVerificationError, match="No Google OIDC cert matches"):
                await GooglePlayService.verify_rtdn_authorization(f"Bearer {token}")


# ---------------------------------------------------------------------------
# Entitlement / notification normalization edge cases
# ---------------------------------------------------------------------------


def test_ms_timestamp_none_and_invalid_values():
    assert GooglePlayService._ms_timestamp(None) is None
    assert GooglePlayService._ms_timestamp("not-a-number") is None
    assert GooglePlayService._ms_timestamp(1_700_000_000_000) == "2023-11-14T22:13:20+00:00"


def test_handle_subscription_notification_rejects_missing_section():
    with pytest.raises(GooglePlayVerificationError, match="no subscriptionNotification"):
        GooglePlayService.handle_subscription_notification({"version": "1.0"})


def test_notification_type_name_variants():
    assert GooglePlayService.notification_type_name({"testNotification": {"version": "1.0"}}) == "TEST"
    assert (
        GooglePlayService.notification_type_name(
            {"subscriptionNotification": {"notificationType": 12}}
        )
        == "SUBSCRIPTION_REVOKED"
    )
    assert (
        GooglePlayService.notification_type_name(
            {"subscriptionNotification": {"notificationType": 999}}
        )
        == "UNKNOWN"
    )
    assert GooglePlayService.notification_type_name({}) == "UNKNOWN"
