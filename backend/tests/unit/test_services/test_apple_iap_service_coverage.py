"""Coverage-completing tests for the Apple App Store Server API service.

The sibling ``test_apple_iap_service.py`` covers the happy JWS/transaction
paths with real throwaway certificates. These tests fill the remaining error
and edge branches: base64url helpers, sandbox URL selection, malformed JWS
headers, x5c chain edge cases (missing/empty/broken/three-deep chains),
default trust-root loading, non-JSON payloads, notification guards, HTTP
error branches, missing signed transaction info, and invalid timestamps.
"""

import json
from datetime import datetime, timedelta, timezone
from unittest.mock import Mock, patch

import pytest
from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.asymmetric.utils import decode_dss_signature
from cryptography.x509.oid import NameOID

from app.core.config import settings
from app.services.apple_iap_service import (
    APPLE_PROD_API_URL,
    APPLE_SANDBOX_API_URL,
    _b64url_encode,
    AppleIAPService,
    AppleIAPSignatureError,
    AppleIAPVerificationError,
)
from tests.utils.fake_iap import (
    b64u,
    cert_der,
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


def _make_intermediate_ca(intermediate_key, root_key, root_cert):
    """A CA certificate issued by ``root_cert`` (for three-deep chains)."""
    subject = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, "Test Intermediate CA")])
    return (
        x509.CertificateBuilder()
        .subject_name(subject)
        .issuer_name(root_cert.subject)
        .public_key(intermediate_key.public_key())
        .serial_number(x509.random_serial_number())
        .not_valid_before(datetime.now(timezone.utc) - timedelta(days=1))
        .not_valid_after(datetime.now(timezone.utc) + timedelta(days=365))
        .add_extension(x509.BasicConstraints(ca=True, path_length=None), critical=True)
        .sign(root_key, hashes.SHA256())
    )


def _sign_raw_payload(raw: bytes, leaf_key, chain_certs) -> str:
    """Sign arbitrary payload bytes as an ES256 JWS with an x5c chain."""
    header = {"alg": "ES256", "x5c": [cert_der(cert) for cert in chain_certs]}
    signing_input = f"{b64u(json.dumps(header).encode())}.{b64u(raw)}"
    der_signature = leaf_key.sign(signing_input.encode("ascii"), ec.ECDSA(hashes.SHA256()))
    r, s = decode_dss_signature(der_signature)
    signature = r.to_bytes(32, "big") + s.to_bytes(32, "big")
    return f"{signing_input}.{b64u(signature)}"


class _FakeHttpClient:
    """httpx.AsyncClient double with a canned response per verb."""

    def __init__(self, response=None, get_response=None):
        self.response = response
        self.get_response = get_response

    async def __aenter__(self):
        return self

    async def __aexit__(self, *args):
        return False

    async def get(self, url, **kwargs):
        return self.get_response


def _jws_fixture():
    root_key = make_ec_key()
    root_cert = make_ca_cert(root_key)
    leaf_key = make_ec_key()
    leaf_cert = make_leaf_cert(leaf_key, root_key, root_cert)
    return {
        "root": root_cert,
        "root_key": root_key,
        "leaf_key": leaf_key,
        "chain": [leaf_cert, root_cert],
    }


# ---------------------------------------------------------------------------
# Helpers + configuration
# ---------------------------------------------------------------------------


def test_b64url_encode_round_trips():
    assert _b64url_encode(b"\xfb\xff\x00") == "-_8A"
    assert _b64url_encode(b"") == ""


def test_apple_api_urls_sandbox_env():
    with patch.multiple(settings, APPLE_ENV="sandbox"):
        assert AppleIAPService.apple_api_urls() == (
            APPLE_SANDBOX_API_URL,
            APPLE_PROD_API_URL,
        )
    with patch.multiple(settings, APPLE_ENV="production"):
        assert AppleIAPService.apple_api_urls() == (
            APPLE_PROD_API_URL,
            APPLE_SANDBOX_API_URL,
        )


# ---------------------------------------------------------------------------
# JWS parsing / x5c chain edge cases
# ---------------------------------------------------------------------------


def test_parse_jws_rejects_malformed_header():
    with pytest.raises(AppleIAPSignatureError, match="Malformed JWS header"):
        AppleIAPService.parse_jws("!!!.payload.sig")


def test_load_x5c_chain_missing():
    with pytest.raises(AppleIAPSignatureError, match="no x5c certificate chain"):
        AppleIAPService._load_x5c_chain({"alg": "ES256"})


def test_load_x5c_chain_invalid_certificate():
    with pytest.raises(AppleIAPSignatureError, match="Invalid certificate in x5c chain"):
        AppleIAPService._load_x5c_chain({"x5c": ["bm90LWEtY2VydA=="]})


def test_verify_cert_chain_empty():
    root_key = make_ec_key()
    root_cert = make_ca_cert(root_key)
    with pytest.raises(AppleIAPSignatureError, match="Empty x5c certificate chain"):
        AppleIAPService._verify_cert_chain([], (root_cert,), 0.0)


def test_verify_cert_chain_broken_between_certs():
    fixture = _jws_fixture()
    other_key = make_ec_key()
    other_root = make_ca_cert(other_key)
    # leaf is issued by fixture root, but the next link is an unrelated root.
    with pytest.raises(AppleIAPSignatureError, match="chain broken between certs 0 and 1"):
        AppleIAPService._verify_cert_chain(
            [fixture["chain"][0], other_root], (other_root,), 0.0
        )


def test_verify_jws_accepts_three_deep_chain():
    """leaf -> intermediate -> root: the anchor is issued by the root but is
    not the root itself (the anchor-issued-by-root return path)."""
    root_key = make_ec_key()
    root_cert = make_ca_cert(root_key)
    intermediate_key = make_ec_key()
    intermediate_cert = _make_intermediate_ca(intermediate_key, root_key, root_cert)
    leaf_key = make_ec_key()
    leaf_cert = make_leaf_cert(leaf_key, intermediate_key, intermediate_cert)
    payload = {"notificationType": "SUBSCRIBED"}
    jws = sign_jws(payload, leaf_key, [leaf_cert, intermediate_cert, root_cert])

    decoded = AppleIAPService.verify_jws(jws, trust_roots=(root_cert,))
    assert decoded == payload


def test_verify_cert_chain_anchor_is_directly_issued_by_root():
    """A two-deep chain whose anchor is NOT the root itself must still
    anchor via verify_directly_issued_by(root)."""
    root_key = make_ec_key()
    root_cert = make_ca_cert(root_key)
    intermediate_key = make_ec_key()
    intermediate_cert = _make_intermediate_ca(intermediate_key, root_key, root_cert)
    leaf_key = make_ec_key()
    leaf_cert = make_leaf_cert(leaf_key, intermediate_key, intermediate_cert)
    AppleIAPService._verify_cert_chain(
        [leaf_cert, intermediate_cert], (root_cert,), 0.0
    )


def test_verify_jws_loads_default_trust_root():
    """Without trust_roots the bundled Apple Root CA G3 PEM is loaded and the
    chain anchors to it (patched with our own root so the JWS verifies)."""
    fixture = _jws_fixture()
    jws = sign_jws(
        {"notificationType": "SUBSCRIBED"},
        fixture["leaf_key"],
        fixture["chain"],
    )
    root_pem = fixture["root"].public_bytes(serialization.Encoding.PEM).decode("utf-8")
    with patch("app.services.apple_iap_service.APPLE_ROOT_CA_G3_PEM", root_pem):
        decoded = AppleIAPService.verify_jws(jws)
    assert decoded == {"notificationType": "SUBSCRIBED"}


def test_verify_jws_rejects_non_json_payload():
    fixture = _jws_fixture()
    jws = _sign_raw_payload(b"not json {", fixture["leaf_key"], fixture["chain"])
    with pytest.raises(AppleIAPSignatureError, match="not valid JSON"):
        AppleIAPService.verify_jws(jws, trust_roots=(fixture["root"],))


def test_verify_notification_guards_empty_and_delegates():
    with pytest.raises(AppleIAPSignatureError, match="Missing signed payload"):
        AppleIAPService.verify_notification("")
    with patch.object(
        AppleIAPService, "verify_jws", return_value={"notificationId": "n1"}
    ) as verify:
        assert AppleIAPService.verify_notification("a.b.c") == {"notificationId": "n1"}
        verify.assert_called_once_with("a.b.c")


# ---------------------------------------------------------------------------
# Transaction lookup HTTP branches
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_request_transaction_non_404_http_error():
    client = _FakeHttpClient(get_response=Mock(status_code=500))
    with patch("httpx.AsyncClient", return_value=client):
        with pytest.raises(AppleIAPVerificationError, match="returned HTTP 500"):
            await AppleIAPService._request_transaction("tx-1", "https://api.test", "tok")


@pytest.mark.asyncio
async def test_verify_transaction_response_without_signed_info():
    """A 200 response with no signedTransactionInfo must not grant anything."""
    with patch.multiple(settings, **_apple_settings()):
        client = _FakeHttpClient(get_response=Mock(status_code=200, json=lambda: {}))
        with patch.object(AppleIAPService, "generate_api_token", return_value="tok"), patch(
            "httpx.AsyncClient", return_value=client
        ):
            with pytest.raises(AppleIAPVerificationError, match="no signed transaction info"):
                await AppleIAPService.verify_transaction("tx-1")


# ---------------------------------------------------------------------------
# Entitlement normalization edge cases
# ---------------------------------------------------------------------------


def test_ms_timestamp_none_and_invalid_values():
    assert AppleIAPService._ms_timestamp(None) is None
    assert AppleIAPService._ms_timestamp("not-a-number") is None
    assert AppleIAPService._ms_timestamp(1_700_000_000_000) == "2023-11-14T22:13:20+00:00"
