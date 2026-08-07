"""
Apple App Store Server API client for verifying in-app purchases.

Verifies auto-renewable subscription transactions with the modern App Store
Server API (https://developer.apple.com/documentation/appstoreserverapi),
replacing the deprecated receipt verification endpoint:

- ``verify_transaction`` looks up a transaction by ID (Bearer JWT signed with
  the App Store Connect API key) and returns the verified transaction info.
- ``verify_notification`` verifies an App Store Server Notification V2 JWS
  (x5c certificate chain rooted at Apple Root CA - G3) and returns the
  notification payload with the signed transaction info inside.
- ``transaction_to_entitlement`` normalizes a transaction info payload into
  the plan/status/period shape the subscription service persists.

Entitlement is only ever granted from a payload that passed JWS signature
verification (notifications) or came back over TLS from the Apple API and
matched the configured bundle ID + product map.
"""
from __future__ import annotations

import base64
import json
import time
from typing import Any, Dict, Optional, Tuple

import httpx
from cryptography import x509
from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.asymmetric.utils import encode_dss_signature
from jose import jwt

from app.core.config import settings
from app.core.exceptions import ServiceError, ValidationError
from app.core.logging_config import get_context_logger
from app.models.subscription import PlanType

logger = get_context_logger(__name__)

# App Store Server API base URLs.
# Production: https://api.storekit.itunes.apple.com
# Sandbox:    https://api.storekit-sandbox.itunes.apple.com
APPLE_PROD_API_URL = "https://api.storekit.itunes.apple.com"
APPLE_SANDBOX_API_URL = "https://api.storekit-sandbox.itunes.apple.com"

# The issuer of every App Store Server API / notification certificate chain.
# Bundled so JWS verification works without an external fetch; Apple rotates
# roots extremely rarely and ships the chain in every x5c header.
APPLE_ROOT_CA_G3_PEM = """-----BEGIN CERTIFICATE-----
MIICQzCCAcmgAwIBAgIILcX8iNLFS5UwCgYIKoZIzj0EAwMwZzEbMBkGA1UEAwwS
QXBwbGUgUm9vdCBDQSAtIEczMSYwJAYDVQQLDB1BcHBsZSBDZXJ0aWZpY2F0aW9u
IEF1dGhvcml0eTETMBEGA1UECgwKQXBwbGUgSW5jLjELMAkGA1UEBhMCVVMwHhcN
MTQwNDMwMTgxOTA2WhcNMzkwNDMwMTgxOTA2WjBnMRswGQYDVQQDDBJBcHBsZSBS
b290IENBIC0gRzMxJjAkBgNVBAsMHUFwcGxlIENlcnRpZmljYXRpb24gQXV0aG9y
aXR5MRMwEQYDVQQKDApBcHBsZSBJbmMuMQswCQYDVQQGEwJVUzB2MBAGByqGSM49
AgEGBSuBBAAiA2IABJjpLz1AcqTtkyJygRMc3RCV8cWjTnHcFBbZDuWmBSp3ZHtf
TjjTuxxEtX/1H7YyYl3J6YRbTzBPEVoA/VhYDKX1DyxNB0cTddqXl5dvMVztK517
IDvYuVTZXpmkOlEKMaNCMEAwHQYDVR0OBBYEFLuw3qFYM4iapIqZ3r6966/ayySr
MA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMAoGCCqGSM49BAMDA2gA
MGUCMQCD6cHEFl4aXTQY2e3v9GwOAEZLuN+yRhHFD/3meoyhpmvOwgPUnPWTxnS4
at+qIxUCMG1mihDK1A3UT82NQz60imOlM27jbdoXt2QfyFMm+YhidDkLF1vLUagM
6BgD56KyKA==
-----END CERTIFICATE-----"""


class AppleIAPError(ServiceError):
    """Base error for Apple IAP failures."""

    error_code = "APPLE_IAP_ERROR"

    def __init__(self, message: str, service_name: str = "apple_iap"):
        super().__init__(message, service_name)


class AppleIAPVerificationError(AppleIAPError):
    """Raised when a purchase could not be verified with Apple."""

    error_code = "APPLE_IAP_VERIFICATION_ERROR"


class AppleIAPSignatureError(AppleIAPError):
    """Raised when a signed notification JWS fails verification."""

    error_code = "APPLE_IAP_SIGNATURE_ERROR"


def _b64url_decode(data: str) -> bytes:
    """Decode a base64url (possibly unpadded) JWS segment."""
    padding = "=" * (-len(data) % 4)
    return base64.urlsafe_b64decode(data + padding)


def _b64url_encode(data: bytes) -> str:
    """Encode bytes as unpadded base64url."""
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


class AppleIAPService:
    """App Store Server API verification helpers."""

    # ------------------------------------------------------------------
    # Configuration
    # ------------------------------------------------------------------

    @staticmethod
    def _config_available() -> bool:
        return bool(
            settings.APPLE_ISSUER_ID
            and settings.APPLE_KEY_ID
            and settings.APPLE_PRIVATE_KEY
        )

    @staticmethod
    def apple_api_urls() -> Tuple[str, str]:
        """Return (primary, fallback) base URLs for the current env."""
        if (settings.APPLE_ENV or "").lower() == "sandbox":
            return APPLE_SANDBOX_API_URL, APPLE_PROD_API_URL
        return APPLE_PROD_API_URL, APPLE_SANDBOX_API_URL

    # ------------------------------------------------------------------
    # App Store Server API token (ES256 JWT)
    # ------------------------------------------------------------------

    @classmethod
    def generate_api_token(cls) -> str:
        """Sign a short-lived App Store Server API token.

        Claims per Apple's documentation: iss (issuer ID), iat, exp (max 20
        minutes), aud ("appstoreconnect-v1"), bid (bundle ID). The JWT header
        carries the key ID so Apple can select the matching .p8 key.
        """
        if not cls._config_available():
            raise AppleIAPError(
                "Apple IAP is not configured (APPLE_ISSUER_ID, APPLE_KEY_ID, "
                "APPLE_PRIVATE_KEY are required)."
            )
        now = int(time.time())
        claims = {
            "iss": settings.APPLE_ISSUER_ID,
            "iat": now,
            "exp": now + 20 * 60,  # Apple caps token lifetime at 20 minutes
            "aud": "appstoreconnect-v1",
            "bid": settings.APPLE_BUNDLE_ID,
        }
        return jwt.encode(
            claims,
            settings.APPLE_PRIVATE_KEY,
            algorithm="ES256",
            headers={"kid": settings.APPLE_KEY_ID, "typ": "JWT"},
        )

    # ------------------------------------------------------------------
    # JWS parsing / verification
    # ------------------------------------------------------------------

    @staticmethod
    def parse_jws(jws: str) -> Tuple[Dict[str, Any], bytes, bytes]:
        """Split a JWS into (header, payload_bytes, signature)."""
        parts = jws.split(".")
        if len(parts) != 3:
            raise AppleIAPSignatureError("Malformed JWS: expected 3 segments")
        try:
            header = json.loads(_b64url_decode(parts[0]).decode("utf-8"))
        except (ValueError, UnicodeDecodeError) as exc:
            raise AppleIAPSignatureError("Malformed JWS header") from exc
        return header, _b64url_decode(parts[1]), _b64url_decode(parts[2])

    @classmethod
    def _load_x5c_chain(cls, header: Dict[str, Any]) -> list:
        raw_certs = header.get("x5c")
        if not isinstance(raw_certs, list) or not raw_certs:
            raise AppleIAPSignatureError("JWS header has no x5c certificate chain")
        certs = []
        for der_b64 in raw_certs:
            try:
                certs.append(x509.load_der_x509_certificate(base64.b64decode(der_b64)))
            except ValueError as exc:
                raise AppleIAPSignatureError("Invalid certificate in x5c chain") from exc
        return certs

    @classmethod
    def _verify_cert_chain(
        cls,
        certs: list,
        trust_roots: Tuple[x509.Certificate, ...],
        now: float,
    ) -> None:
        """Validate the x5c chain: leaf-issued-by-next, anchored in trust_roots.

        Apple's x5c array is ordered leaf-first. Each certificate must be
        issued by the next one, and the final certificate must either be one
        of the trust roots or be directly issued by one.
        """
        if not certs:
            raise AppleIAPSignatureError("Empty x5c certificate chain")
        for i in range(len(certs) - 1):
            try:
                certs[i].verify_directly_issued_by(certs[i + 1])
            except InvalidSignature as exc:
                raise AppleIAPSignatureError(
                    f"x5c chain broken between certs {i} and {i + 1}"
                ) from exc
        anchor = certs[-1]
        for root in trust_roots:
            if anchor.public_bytes(serialization.Encoding.DER) == root.public_bytes(
                serialization.Encoding.DER
            ):
                return
            try:
                anchor.verify_directly_issued_by(root)
                return
            except InvalidSignature:
                continue
        raise AppleIAPSignatureError("x5c chain does not anchor to a trusted root")

    @classmethod
    def verify_jws(
        cls,
        jws: str,
        *,
        trust_roots: Optional[Tuple[x509.Certificate, ...]] = None,
        now: Optional[float] = None,
    ) -> Dict[str, Any]:
        """Verify a JWS signed by an Apple certificate and return its payload.

        Checks: ES256 signature over the signing input (header.payload) using
        the leaf certificate's public key, the leaf's validity window, and the
        x5c chain anchored at Apple Root CA - G3.
        """
        check_at = now if now is not None else time.time()
        header, payload, signature = cls.parse_jws(jws)
        if header.get("alg") != "ES256":
            raise AppleIAPSignatureError(f"Unsupported JWS algorithm: {header.get('alg')}")

        signing_input = jws.rsplit(".", 1)[0].encode("ascii")
        certs = cls._load_x5c_chain(header)
        leaf = certs[0]

        if check_at < leaf.not_valid_before_utc.timestamp() or check_at > leaf.not_valid_after_utc.timestamp():
            raise AppleIAPSignatureError("JWS leaf certificate is not yet valid or has expired")

        # Convert the raw R||S JWS signature to DER for cryptography's ECDSA
        # API, then verify SHA-256(signing input) per the ES256 algorithm.
        half = len(signature) // 2
        try:
            r = int.from_bytes(signature[:half], "big")
            s = int.from_bytes(signature[half:], "big")
            der_signature = encode_dss_signature(r, s)
            leaf.public_key().verify(der_signature, signing_input, ec.ECDSA(hashes.SHA256()))
        except (ValueError, InvalidSignature) as exc:
            raise AppleIAPSignatureError("JWS signature verification failed") from exc

        if trust_roots is None:
            trust_roots = (
                x509.load_pem_x509_certificate(APPLE_ROOT_CA_G3_PEM.encode("utf-8")),
            )
        cls._verify_cert_chain(certs, trust_roots, check_at)

        try:
            return json.loads(payload.decode("utf-8"))
        except (ValueError, UnicodeDecodeError) as exc:
            raise AppleIAPSignatureError("JWS payload is not valid JSON") from exc

    @classmethod
    def verify_notification(cls, signed_payload: str) -> Dict[str, Any]:
        """Verify an App Store Server Notification V2 ``signedPayload``."""
        if not signed_payload:
            raise AppleIAPSignatureError("Missing signed payload")
        return cls.verify_jws(signed_payload)

    # ------------------------------------------------------------------
    # Transaction verification (App Store Server API)
    # ------------------------------------------------------------------

    @classmethod
    def product_plan_map(cls) -> Dict[str, PlanType]:
        """Map configured App Store product IDs to plan types (unset excluded)."""
        return {
            product_id: plan_type
            for product_id, plan_type in (
                (settings.APPLE_PLUS_MONTHLY_PRODUCT_ID, PlanType.PLUS_MONTHLY),
                (settings.APPLE_PLUS_YEARLY_PRODUCT_ID, PlanType.PLUS_YEARLY),
                (settings.APPLE_PRO_MONTHLY_PRODUCT_ID, PlanType.PRO_MONTHLY),
                (settings.APPLE_PRO_YEARLY_PRODUCT_ID, PlanType.PRO_YEARLY),
            )
            if product_id
        }

    @classmethod
    def plan_for_product(cls, product_id: str) -> PlanType:
        plan = cls.product_plan_map().get(product_id)
        if plan is None:
            raise ValidationError(f"Unknown App Store product: {product_id}")
        return plan

    @classmethod
    async def _request_transaction(cls, transaction_id: str, base_url: str, token: str) -> Dict[str, Any]:
        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.get(
                f"{base_url}/inApps/v1/transactions/{transaction_id}",
                headers={
                    "Authorization": f"Bearer {token}",
                    "Accept": "application/json",
                },
            )
        if response.status_code == 200:
            return response.json()
        # Both messages name the base URL: verify_transaction tries production
        # and sandbox in turn, and without it a bad .p8 produces the same
        # opaque "HTTP 401" twice with no way to tell which environment failed.
        if response.status_code == 404:
            raise AppleIAPVerificationError(
                f"Transaction {transaction_id} was not found by the App Store "
                f"at {base_url}"
            )
        raise AppleIAPVerificationError(
            f"App Store Server API at {base_url} returned HTTP {response.status_code}"
        )

    @classmethod
    async def verify_transaction(cls, transaction_id: str) -> Dict[str, Any]:
        """Look up and verify a transaction, returning its transaction info.

        Tries the configured environment first, then the other (sandbox
        fallback): TestFlight/sandbox purchases 404 on the production API.
        The returned signed transaction info is JWS-verified and checked
        against the configured bundle ID and product map.
        """
        if not cls._config_available():
            raise AppleIAPError(
                "Apple IAP is not configured (APPLE_ISSUER_ID, APPLE_KEY_ID, "
                "APPLE_PRIVATE_KEY are required)."
            )
        token = cls.generate_api_token()
        primary, fallback = cls.apple_api_urls()
        last_error: Optional[Exception] = None
        for base_url in (primary, fallback):
            try:
                response = await cls._request_transaction(transaction_id, base_url, token)
                signed = response.get("signedTransactionInfo")
                if not signed:
                    raise AppleIAPVerificationError("App Store response has no signed transaction info")
                tx_info = cls.verify_jws(signed)
                cls.validate_transaction_info(tx_info)
                # A Sandbox transaction verifying against a production backend
                # is EXPECTED during App Review and our own sandbox testing —
                # it is never rejected. Logged so reviewer/tester activity is
                # greppable and distinguishable from real revenue.
                logger.info(
                    "Apple transaction verified",
                    extra={
                        "environment": tx_info.get("environment"),
                        "api_base_url": base_url,
                        "transaction_id": transaction_id,
                        "original_transaction_id": tx_info.get("originalTransactionId"),
                        "product_id": tx_info.get("productId"),
                    },
                )
                return tx_info
            except AppleIAPVerificationError as exc:
                # 404/401/403 on the primary URL just means "wrong
                # environment" for sandbox purchases; try the fallback.
                last_error = exc
                logger.info(
                    "App Store transaction lookup failed on fallback candidate",
                    extra={
                        "base_url": base_url,
                        "transaction_id": transaction_id,
                        "error": str(exc),
                    },
                )
        raise AppleIAPVerificationError(
            f"Transaction could not be verified: {last_error}"
        ) from last_error

    @staticmethod
    def validate_transaction_info(tx_info: Dict[str, Any]) -> None:
        """Fail closed unless the transaction belongs to this app and plan set."""
        bundle_id = tx_info.get("bundleId")
        if bundle_id and bundle_id != settings.APPLE_BUNDLE_ID:
            raise AppleIAPVerificationError(
                f"Transaction bundle ID {bundle_id} does not match {settings.APPLE_BUNDLE_ID}"
            )
        product_id = tx_info.get("productId")
        if not product_id:
            raise AppleIAPVerificationError("Transaction has no product ID")
        # Raises ValidationError for unknown products.
        AppleIAPService.plan_for_product(product_id)

    # ------------------------------------------------------------------
    # Entitlement normalization
    # ------------------------------------------------------------------

    @staticmethod
    def _ms_timestamp(value: Any) -> Optional[str]:
        """Convert an Apple epoch-ms value to ISO8601, or None."""
        if value is None:
            return None
        try:
            return time.strftime(
                "%Y-%m-%dT%H:%M:%S+00:00", time.gmtime(int(value) / 1000)
            )
        except (TypeError, ValueError, OSError):
            return None

    @staticmethod
    def _auto_renew_disabled(
        tx_info: Dict[str, Any], renewal_info: Optional[Dict[str, Any]]
    ) -> Optional[bool]:
        """Whether verified renewal info says auto-renew is off, or None if unknown.

        Only the renewal info carries autoRenewStatus; a transaction alone never
        does. ``None`` therefore means "this payload does not say", which callers
        must treat as "leave the stored flag alone" rather than "auto-renew is
        on". Returning False here instead would make Restore Purchases clear a
        cancellation the user really made: the restore re-registers the same
        transaction with no renewal info attached.

        The originalTransactionId must match when both payloads state one — a
        notification's renewal info always describes the same subscription, but
        refusing a mismatch keeps a malformed payload from cancelling an
        unrelated plan.
        """
        if not renewal_info:
            return None
        renewal_original = renewal_info.get("originalTransactionId")
        tx_original = tx_info.get("originalTransactionId") or tx_info.get("transactionId")
        if renewal_original and tx_original and renewal_original != tx_original:
            return None
        try:
            # Apple sends an int (0 = off, 1 = on); tolerate a string.
            return int(renewal_info.get("autoRenewStatus", 1)) == 0
        except (TypeError, ValueError):
            # Never 500 a webhook over an unexpected claim shape.
            return None

    @classmethod
    def transaction_to_entitlement(
        cls,
        tx_info: Dict[str, Any],
        renewal_info: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """Normalize verified transaction info into persistable entitlement state.

        Returns a dict with keys: plan_type (PlanType), status
        (SubscriptionStatus), current_period_start, current_period_end,
        cancel_at_period_end, revoked (bool).

        ``renewal_info`` is the verified ``signedRenewalInfo`` claims from an
        App Store Server Notification, when the caller has them. Without it
        ``cancel_at_period_end`` is ``None`` — "unknown", which
        sync_iap_subscription leaves untouched. Apple sends
        DID_CHANGE_RENEWAL_STATUS (which does carry renewal info) whenever the
        user toggles auto-renew, so the webhook is the authority on that flag
        and the register path must never overwrite it.
        """
        plan_type = cls.plan_for_product(tx_info.get("productId", ""))
        revoked = bool(tx_info.get("revocationDate"))
        return {
            "plan_type": plan_type,
            "status": "free" if revoked else "active",
            "current_period_start": cls._ms_timestamp(tx_info.get("purchaseDate")),
            "current_period_end": cls._ms_timestamp(tx_info.get("expiresDate")),
            "cancel_at_period_end": cls._auto_renew_disabled(tx_info, renewal_info),
            "revoked": revoked,
            "product_id": tx_info.get("productId"),
            "original_transaction_id": tx_info.get("originalTransactionId")
            or tx_info.get("transactionId"),
        }
