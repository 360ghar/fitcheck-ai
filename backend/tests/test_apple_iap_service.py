"""Tests for the Apple App Store Server API service."""
import base64
import json
from datetime import datetime, timedelta, timezone
from unittest.mock import Mock, patch

import pytest

from app.core.config import settings
from app.core.exceptions import ValidationError
from app.models.subscription import PlanType
from app.services.apple_iap_service import (
    APPLE_PROD_API_URL,
    APPLE_SANDBOX_API_URL,
    AppleIAPError,
    AppleIAPService,
    AppleIAPSignatureError,
    AppleIAPVerificationError,
)
from tests.iap_test_utils import (
    make_ca_cert,
    make_ec_key,
    make_ec_key_pem,
    make_leaf_cert,
    sign_jws,
)


def _apple_settings():
    return {
        "APPLE_BUNDLE_ID": "com.fitcheckaiapp.fitcheckai",
        "APPLE_ISSUER_ID": "issuer-1",
        "APPLE_KEY_ID": "key-1",
        "APPLE_PRIVATE_KEY": make_ec_key_pem(),
        "APPLE_ENV": "production",
        "APPLE_PLUS_MONTHLY_PRODUCT_ID": "com.fitcheck.plus.monthly",
        "APPLE_PLUS_YEARLY_PRODUCT_ID": "com.fitcheck.plus.yearly",
        "APPLE_PRO_MONTHLY_PRODUCT_ID": "com.fitcheck.pro.monthly",
        "APPLE_PRO_YEARLY_PRODUCT_ID": "com.fitcheck.pro.yearly",
    }


def _tx_info(**overrides):
    info = {
        "transactionId": "tx-1",
        "originalTransactionId": "orig-1",
        "bundleId": "com.fitcheckaiapp.fitcheckai",
        "productId": "com.fitcheck.plus.monthly",
        "purchaseDate": 1_700_000_000_000,
        "expiresDate": 1_700_300_000_000,
        "environment": "Sandbox",
        "inAppOwnershipType": "PURCHASED",
    }
    info.update(overrides)
    return info


# ---------------------------------------------------------------------------
# JWS verification (real signatures with throwaway certs)
# ---------------------------------------------------------------------------


@pytest.fixture()
def jws_fixture():
    root_key = make_ec_key()
    root_cert = make_ca_cert(root_key)
    leaf_key = make_ec_key()
    leaf_cert = make_leaf_cert(leaf_key, root_key, root_cert)
    return {
        "root": root_cert,
        "leaf_key": leaf_key,
        "chain": [leaf_cert, root_cert],
    }


def test_verify_jws_accepts_valid_chain(jws_fixture):
    payload = {"notificationType": "SUBSCRIBED", "notificationId": "n1"}
    jws = sign_jws(payload, jws_fixture["leaf_key"], jws_fixture["chain"])

    decoded = AppleIAPService.verify_jws(
        jws, trust_roots=(jws_fixture["root"],)
    )
    assert decoded == payload


def test_verify_jws_rejects_tampered_payload(jws_fixture):
    payload = {"notificationType": "SUBSCRIBED", "notificationId": "n1"}
    jws = sign_jws(payload, jws_fixture["leaf_key"], jws_fixture["chain"])
    # Flip one character inside the payload segment.
    head, _, sig = jws.rpartition(".")
    header_segment, payload_segment = head.split(".")
    tampered = json.loads(base64.urlsafe_b64decode(payload_segment + "=="))
    tampered["notificationId"] = "EVIL"
    tampered_payload_segment = (
        base64.urlsafe_b64encode(json.dumps(tampered).encode())
        .rstrip(b"=")
        .decode()
    )
    tampered_jws = f"{head.split('.')[0]}.{tampered_payload_segment}.{sig}"

    with pytest.raises(AppleIAPSignatureError, match="signature verification failed"):
        AppleIAPService.verify_jws(tampered_jws, trust_roots=(jws_fixture["root"],))


def test_verify_jws_rejects_untrusted_chain(jws_fixture):
    other_root_key = make_ec_key()
    other_root = make_ca_cert(other_root_key)
    payload = {"notificationType": "SUBSCRIBED"}
    jws = sign_jws(payload, jws_fixture["leaf_key"], jws_fixture["chain"])

    with pytest.raises(AppleIAPSignatureError, match="does not anchor to a trusted root"):
        AppleIAPService.verify_jws(jws, trust_roots=(other_root,))


def test_verify_jws_rejects_expired_leaf(jws_fixture):
    root_key = make_ec_key()
    root_cert = make_ca_cert(root_key)
    leaf_key = make_ec_key()
    expired = make_leaf_cert(
        leaf_key,
        root_key,
        root_cert,
        # 12 hours ago: after not_valid_before (1 day ago) but before now.
        not_valid_after=datetime.now(timezone.utc) - timedelta(hours=12),
    )
    payload = {"notificationType": "SUBSCRIBED"}
    jws = sign_jws(payload, leaf_key, [expired, root_cert])

    with pytest.raises(AppleIAPSignatureError, match="not yet valid or has expired"):
        AppleIAPService.verify_jws(jws, trust_roots=(root_cert,))


def test_verify_jws_rejects_wrong_algorithm(jws_fixture):
    # A JWS header claiming HS256 must be refused before any verification.
    header = {"alg": "HS256", "x5c": []}
    signing_input = f"{base64.urlsafe_b64encode(json.dumps(header).encode()).rstrip(b'=').decode()}.abc"
    jws = f"{signing_input}.sig"

    with pytest.raises(AppleIAPSignatureError, match="Unsupported JWS algorithm"):
        AppleIAPService.verify_jws(jws, trust_roots=(jws_fixture["root"],))


def test_verify_jws_rejects_malformed(jws_fixture):
    with pytest.raises(AppleIAPSignatureError, match="Malformed JWS"):
        AppleIAPService.verify_jws("not-a-jws", trust_roots=(jws_fixture["root"],))


# ---------------------------------------------------------------------------
# API token
# ---------------------------------------------------------------------------


def test_generate_api_token_has_expected_shape():
    with patch.multiple(settings, **_apple_settings()):
        token = AppleIAPService.generate_api_token()
    parts = token.split(".")
    assert len(parts) == 3
    header = json.loads(base64.urlsafe_b64decode(parts[0] + "=="))
    assert header["kid"] == "key-1"
    assert header["alg"] == "ES256"
    claims = json.loads(base64.urlsafe_b64decode(parts[1] + "=="))
    assert claims["iss"] == "issuer-1"
    assert claims["aud"] == "appstoreconnect-v1"
    assert claims["bid"] == "com.fitcheckaiapp.fitcheckai"
    assert claims["exp"] - claims["iat"] <= 20 * 60


def test_generate_api_token_raises_when_unconfigured():
    with patch.multiple(
        settings, APPLE_ISSUER_ID=None, APPLE_KEY_ID=None, APPLE_PRIVATE_KEY=None
    ):
        with pytest.raises(AppleIAPError, match="not configured"):
            AppleIAPService.generate_api_token()


# ---------------------------------------------------------------------------
# Transaction lookup
# ---------------------------------------------------------------------------


class _FakeAsyncClient:
    """Minimal httpx.AsyncClient double with per-URL responses."""

    def __init__(self, responses):
        self.responses = responses

    async def __aenter__(self):
        return self

    async def __aexit__(self, *args):
        return False

    async def get(self, url, **kwargs):
        return self.responses[url]


@pytest.mark.asyncio
async def test_verify_transaction_falls_back_from_production_to_sandbox():
    with patch.multiple(settings, **_apple_settings()):
        tx_jws = "signed.tx.jws"
        prod_url = f"{APPLE_PROD_API_URL}/inApps/v1/transactions/tx-1"
        sandbox_url = f"{APPLE_SANDBOX_API_URL}/inApps/v1/transactions/tx-1"
        client = _FakeAsyncClient({
            prod_url: Mock(status_code=404, json=lambda: {}),
            sandbox_url: Mock(
                status_code=200, json=lambda: {"signedTransactionInfo": tx_jws}
            ),
        })
        with patch.object(AppleIAPService, "generate_api_token", return_value="tok"), \
             patch.object(AppleIAPService, "verify_jws", return_value=_tx_info()) as verify_jws, \
             patch("httpx.AsyncClient", return_value=client):
            result = await AppleIAPService.verify_transaction("tx-1")

    assert result["productId"] == "com.fitcheck.plus.monthly"
    verify_jws.assert_called_once_with(tx_jws)
    assert client.responses[prod_url].status_code == 404


@pytest.mark.asyncio
async def test_verify_transaction_raises_when_not_found_anywhere():
    with patch.multiple(settings, **_apple_settings()):
        client = _FakeAsyncClient({
            f"{APPLE_PROD_API_URL}/inApps/v1/transactions/nope": Mock(status_code=404),
            f"{APPLE_SANDBOX_API_URL}/inApps/v1/transactions/nope": Mock(status_code=404),
        })
        with patch.object(AppleIAPService, "generate_api_token", return_value="tok"), \
             patch("httpx.AsyncClient", return_value=client):
            with pytest.raises(AppleIAPVerificationError, match="not found"):
                await AppleIAPService.verify_transaction("nope")


@pytest.mark.asyncio
async def test_verify_transaction_raises_when_unconfigured():
    with patch.multiple(
        settings, APPLE_ISSUER_ID=None, APPLE_KEY_ID=None, APPLE_PRIVATE_KEY=None
    ):
        with pytest.raises(AppleIAPError, match="not configured"):
            await AppleIAPService.verify_transaction("tx-1")


# ---------------------------------------------------------------------------
# Transaction info validation / entitlement normalization
# ---------------------------------------------------------------------------


def test_validate_transaction_info_rejects_wrong_bundle():
    with patch.multiple(settings, **_apple_settings()):
        with pytest.raises(AppleIAPVerificationError, match="does not match"):
            AppleIAPService.validate_transaction_info(
                _tx_info(bundleId="com.someone.else")
            )


def test_validate_transaction_info_rejects_unknown_product():
    with patch.multiple(settings, **_apple_settings()):
        with pytest.raises(ValidationError, match="Unknown App Store product"):
            AppleIAPService.validate_transaction_info(
                _tx_info(productId="com.fitcheck.unknown")
            )


def test_validate_transaction_info_rejects_missing_product():
    with patch.multiple(settings, **_apple_settings()):
        with pytest.raises(AppleIAPVerificationError, match="no product ID"):
            AppleIAPService.validate_transaction_info(_tx_info(productId=None))


def test_transaction_to_entitlement_maps_product_and_dates():
    with patch.multiple(settings, **_apple_settings()):
        entitlement = AppleIAPService.transaction_to_entitlement(
            _tx_info(productId="com.fitcheck.pro.yearly")
        )
    assert entitlement["plan_type"] == PlanType.PRO_YEARLY
    assert entitlement["status"] == "active"
    assert entitlement["current_period_end"] is not None
    assert entitlement["revoked"] is False
    assert entitlement["original_transaction_id"] == "orig-1"


def test_transaction_to_entitlement_revoked_is_free():
    with patch.multiple(settings, **_apple_settings()):
        entitlement = AppleIAPService.transaction_to_entitlement(
            _tx_info(revocationDate=1_700_100_000_000)
        )
    assert entitlement["status"] == "free"
    assert entitlement["revoked"] is True


def test_transaction_to_entitlement_honors_auto_renew_off():
    """autoRenewStatus 0 is the only signal that a subscriber cancelled; a
    reviewer who cancels in Settings must see the access-until state."""
    with patch.multiple(settings, **_apple_settings()):
        entitlement = AppleIAPService.transaction_to_entitlement(
            _tx_info(),
            renewal_info={"originalTransactionId": "orig-1", "autoRenewStatus": 0},
        )
    assert entitlement["cancel_at_period_end"] is True
    # Entitlement continues until the period ends.
    assert entitlement["status"] == "active"


def test_transaction_to_entitlement_auto_renew_on_keeps_cancel_false():
    with patch.multiple(settings, **_apple_settings()):
        entitlement = AppleIAPService.transaction_to_entitlement(
            _tx_info(),
            renewal_info={"originalTransactionId": "orig-1", "autoRenewStatus": 1},
        )
    assert entitlement["cancel_at_period_end"] is False


def test_transaction_to_entitlement_leaves_cancel_unknown_without_renewal_info():
    """No renewal info means UNKNOWN, not "auto-renew is on".

    The register path (including Restore Purchases) never has renewal info. If
    this returned False, restoring a cancelled subscription would clear the
    cancellation the user really made.
    """
    with patch.multiple(settings, **_apple_settings()):
        entitlement = AppleIAPService.transaction_to_entitlement(_tx_info())
    assert entitlement["cancel_at_period_end"] is None


def test_transaction_to_entitlement_ignores_renewal_info_for_another_subscription():
    with patch.multiple(settings, **_apple_settings()):
        entitlement = AppleIAPService.transaction_to_entitlement(
            _tx_info(),
            renewal_info={"originalTransactionId": "orig-other", "autoRenewStatus": 0},
        )
    assert entitlement["cancel_at_period_end"] is None


def test_transaction_to_entitlement_survives_a_malformed_auto_renew_status():
    """A webhook must never 500 over an unexpected claim shape — Apple would
    then redeliver it forever."""
    with patch.multiple(settings, **_apple_settings()):
        entitlement = AppleIAPService.transaction_to_entitlement(
            _tx_info(), renewal_info={"autoRenewStatus": "nope"}
        )
    assert entitlement["cancel_at_period_end"] is None


def test_product_plan_map_skips_unset():
    with patch.multiple(
        settings,
        APPLE_PLUS_MONTHLY_PRODUCT_ID=None,
        APPLE_PLUS_YEARLY_PRODUCT_ID=None,
        APPLE_PRO_MONTHLY_PRODUCT_ID=None,
        APPLE_PRO_YEARLY_PRODUCT_ID=None,
    ):
        assert AppleIAPService.product_plan_map() == {}
