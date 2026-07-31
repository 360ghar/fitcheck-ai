"""
Google Play Developer API client for verifying Play Billing subscriptions.

Verifies subscription purchases with the Play Developer API v3
(https://developers.google.com/android-publisher/api-ref/rest/v3):

- ``get_subscription`` fetches a purchase token's subscription state
  (authenticated with a service-account JWT exchanged for an OAuth token).
- ``acknowledge`` acknowledges a purchase (Play refunds unacknowledged
  purchases within 3 days).
- ``verify_rtdn_authorization`` verifies the OIDC bearer token Google Pub/Sub
  attaches to Real-time Developer Notification pushes (audience = the push
  subscription's topic), so a public endpoint cannot be spammed into
  granting entitlements.
- ``handle_subscription_notification`` normalizes an RTDN payload into the
  persistence shape.

Entitlement is only granted from data returned by the Play API for a token
whose signature/audience checks passed, and whose product maps to a
configured subscription.
"""
from __future__ import annotations

import base64
import json
import time
from typing import Any, Dict, Optional, Tuple

import httpx
from jose import jwt
from jose.exceptions import JWTError

from app.core.config import settings
from app.core.exceptions import ServiceError, ValidationError
from app.core.logging_config import get_context_logger
from app.models.subscription import PlanType

logger = get_context_logger(__name__)

GOOGLE_OAUTH_TOKEN_URL = "https://oauth2.googleapis.com/token"
GOOGLE_OAUTH_SCOPE = "https://www.googleapis.com/auth/androidpublisher"
GOOGLE_PUBLISHER_API_URL = "https://androidpublisher.googleapis.com/androidpublisher/v3"
GOOGLE_OIDC_CERTS_URL = "https://www.googleapis.com/oauth2/v1/certs"

# RTDN notificationType values (subscriptionNotification.notificationType).
_GOOGLE_NOTIFICATION_TYPES = {
    1: "SUBSCRIPTION_RECOVERED",
    2: "SUBSCRIPTION_RENEWED",
    3: "SUBSCRIPTION_CANCELED",
    4: "SUBSCRIPTION_PURCHASED",
    5: "SUBSCRIPTION_ON_HOLD",
    6: "SUBSCRIPTION_IN_GRACE_PERIOD",
    7: "SUBSCRIPTION_RESTARTED",
    8: "SUBSCRIPTION_PRICE_CHANGE_CONFIRMED",
    9: "SUBSCRIPTION_DEFERRED",
    10: "SUBSCRIPTION_PAUSED",
    11: "SUBSCRIPTION_PAUSE_SCHEDULED",
    12: "SUBSCRIPTION_REVOKED",
    13: "SUBSCRIPTION_EXPIRED",
}


class GooglePlayError(ServiceError):
    """Base error for Google Play failures."""

    error_code = "GOOGLE_PLAY_ERROR"

    def __init__(self, message: str, service_name: str = "google_play"):
        super().__init__(message, service_name)


class GooglePlayVerificationError(GooglePlayError):
    """Raised when a purchase could not be verified with Google."""

    error_code = "GOOGLE_PLAY_VERIFICATION_ERROR"


class GooglePlayService:
    """Google Play Developer API verification helpers."""

    # Cached OAuth access token: (token, expires_at_epoch).
    _token_cache: Optional[Tuple[str, float]] = None
    # Cached OIDC verification certs: {kid: pem}.
    _certs_cache: Optional[Tuple[Dict[str, str], float]] = None

    # ------------------------------------------------------------------
    # Configuration
    # ------------------------------------------------------------------

    @staticmethod
    def _config_available() -> bool:
        return bool(settings.GOOGLE_SERVICE_ACCOUNT_JSON)

    @classmethod
    def _service_account(cls) -> Dict[str, Any]:
        if not cls._config_available():
            raise GooglePlayError(
                "Google Play IAP is not configured "
                "(GOOGLE_SERVICE_ACCOUNT_JSON is required)."
            )
        try:
            return json.loads(settings.GOOGLE_SERVICE_ACCOUNT_JSON)
        except ValueError as exc:
            raise GooglePlayError(
                "GOOGLE_SERVICE_ACCOUNT_JSON is not valid JSON"
            ) from exc

    @classmethod
    def product_plan_map(cls) -> Dict[str, PlanType]:
        """Map configured Play product IDs to plan types (unset excluded)."""
        return {
            product_id: plan_type
            for product_id, plan_type in (
                (settings.GOOGLE_PLUS_MONTHLY_PRODUCT_ID, PlanType.PLUS_MONTHLY),
                (settings.GOOGLE_PLUS_YEARLY_PRODUCT_ID, PlanType.PLUS_YEARLY),
                (settings.GOOGLE_PRO_MONTHLY_PRODUCT_ID, PlanType.PRO_MONTHLY),
                (settings.GOOGLE_PRO_YEARLY_PRODUCT_ID, PlanType.PRO_YEARLY),
            )
            if product_id
        }

    @classmethod
    def plan_for_product(cls, product_id: str) -> PlanType:
        plan = cls.product_plan_map().get(product_id)
        if plan is None:
            raise ValidationError(f"Unknown Google Play product: {product_id}")
        return plan

    # ------------------------------------------------------------------
    # OAuth token (service-account JWT -> access token)
    # ------------------------------------------------------------------

    @classmethod
    def _build_assertion(cls, account: Dict[str, Any]) -> str:
        now = int(time.time())
        claims = {
            "iss": account["client_email"],
            "scope": GOOGLE_OAUTH_SCOPE,
            "aud": GOOGLE_OAUTH_TOKEN_URL,
            "iat": now,
            "exp": now + 3600,  # Google caps service-account JWTs at 1 hour
        }
        return jwt.encode(
            claims,
            account["private_key"],
            algorithm="RS256",
            headers={"kid": account.get("private_key_id")},
        )

    @classmethod
    async def _fetch_access_token(cls) -> Tuple[str, float]:
        account = cls._service_account()
        assertion = cls._build_assertion(account)
        token_url = account.get("token_uri", GOOGLE_OAUTH_TOKEN_URL)
        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.post(
                token_url,
                data={
                    "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                    "assertion": assertion,
                },
            )
        if response.status_code != 200:
            raise GooglePlayVerificationError(
                f"Google OAuth token exchange failed: HTTP {response.status_code}"
            )
        payload = response.json()
        token = payload.get("access_token")
        if not token:
            raise GooglePlayVerificationError("Google OAuth response has no access token")
        # Expire slightly early so a token is never used past its window.
        expires_in = int(payload.get("expires_in", 3600))
        return token, time.time() + max(0, expires_in - 60)

    @classmethod
    async def get_access_token(cls) -> str:
        """Return a cached (or freshly minted) OAuth access token."""
        cached = cls._token_cache
        if cached and cached[1] > time.time():
            return cached[0]
        token, expires_at = await cls._fetch_access_token()
        cls._token_cache = (token, expires_at)
        return token

    # ------------------------------------------------------------------
    # Play Developer API
    # ------------------------------------------------------------------

    @classmethod
    async def _publisher_request(
        cls, method: str, path: str, *, json_body: Optional[Dict[str, Any]] = None
    ) -> httpx.Response:
        token = await cls.get_access_token()
        url = f"{GOOGLE_PUBLISHER_API_URL}/{path}"
        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.request(
                method,
                url,
                headers={"Authorization": f"Bearer {token}"},
                json=json_body,
            )
        return response

    @classmethod
    async def get_subscription(cls, subscription_id: str, purchase_token: str) -> Dict[str, Any]:
        """Fetch the current state of a Play subscription purchase."""
        if not subscription_id or not purchase_token:
            raise GooglePlayVerificationError("Missing subscription ID or purchase token")
        response = await cls._publisher_request(
            "GET",
            f"applications/{settings.GOOGLE_PACKAGE_NAME}/purchases/"
            f"subscriptions/{subscription_id}/tokens/{purchase_token}",
        )
        if response.status_code == 200:
            return response.json()
        if response.status_code == 404:
            raise GooglePlayVerificationError(
                "Purchase token was not found by the Play Developer API"
            )
        raise GooglePlayVerificationError(
            f"Play Developer API returned HTTP {response.status_code}"
        )

    @classmethod
    async def acknowledge(cls, subscription_id: str, purchase_token: str) -> None:
        """Acknowledge a purchase; Play refunds unacknowledged ones after 3 days."""
        response = await cls._publisher_request(
            "POST",
            f"applications/{settings.GOOGLE_PACKAGE_NAME}/purchases/"
            f"subscriptions/{subscription_id}/tokens/{purchase_token}:acknowledge",
            json_body={"developerPayload": ""},
        )
        if response.status_code not in (200, 204):
            # Acknowledging is best-effort: the purchase is already verified,
            # and a failed ack only risks the 3-day refund window. Log it.
            logger.error(
                "Failed to acknowledge Play purchase",
                extra={"subscription_id": subscription_id, "status": response.status_code},
            )

    # ------------------------------------------------------------------
    # RTDN push verification (OIDC bearer token)
    # ------------------------------------------------------------------

    @staticmethod
    def _decode_pubsub_message(body: Dict[str, Any]) -> Tuple[str, Dict[str, Any]]:
        """Extract (message_id, decoded_notification) from a Pub/Sub push body."""
        message = body.get("message") or {}
        message_id = message.get("messageId")
        if not message_id:
            raise GooglePlayVerificationError("Pub/Sub push has no messageId")
        raw = message.get("data")
        if not raw:
            raise GooglePlayVerificationError("Pub/Sub push has no data")
        try:
            notification = json.loads(base64.b64decode(raw).decode("utf-8"))
        except (ValueError, UnicodeDecodeError) as exc:
            raise GooglePlayVerificationError("Pub/Sub push data is not valid JSON") from exc
        return message_id, notification

    @classmethod
    async def _fetch_oidc_certs(cls) -> Dict[str, str]:
        cached = cls._certs_cache
        if cached and cached[1] > time.time():
            return cached[0]
        async with httpx.AsyncClient(timeout=15) as client:
            response = await client.get(GOOGLE_OIDC_CERTS_URL)
        if response.status_code != 200:
            raise GooglePlayVerificationError("Could not fetch Google OIDC certificates")
        certs = response.json()
        cls._certs_cache = (certs, time.time() + 3600)
        return certs

    @classmethod
    async def verify_rtdn_authorization(cls, authorization: Optional[str]) -> Dict[str, Any]:
        """Verify the OIDC bearer token on a Pub/Sub push and return its claims.

        The audience must match GOOGLE_RTDN_AUDIENCE (the push subscription's
        topic resource name). When the audience is not configured the endpoint
        fails closed (the operator opted out of verification, which is not a
        safe default for an entitlement-granting webhook).
        """
        audience = settings.GOOGLE_RTDN_AUDIENCE
        if not audience:
            raise GooglePlayVerificationError(
                "GOOGLE_RTDN_AUDIENCE is not configured; refusing unverified RTDN push"
            )
        if not authorization or not authorization.lower().startswith("bearer "):
            raise GooglePlayVerificationError("Missing bearer token on RTDN push")
        token = authorization.split(" ", 1)[1].strip()
        certs = await cls._fetch_oidc_certs()

        # Pub/Sub signs with the publisher service account's key; the kid in
        # the token header selects the matching cert.
        header = jwt.get_unverified_header(token)
        pem = certs.get(header.get("kid"))
        if not pem:
            raise GooglePlayVerificationError("No Google OIDC cert matches the token kid")
        try:
            claims = jwt.decode(
                token, pem, algorithms=["RS256"], audience=audience
            )
        except JWTError as exc:
            raise GooglePlayVerificationError(
                f"RTDN bearer token verification failed: {exc}"
            ) from exc
        return claims

    # ------------------------------------------------------------------
    # Notification normalization
    # ------------------------------------------------------------------

    @staticmethod
    def _ms_timestamp(value: Any) -> Optional[str]:
        """Convert an epoch-ms value to ISO8601, or None."""
        if value is None:
            return None
        try:
            return time.strftime(
                "%Y-%m-%dT%H:%M:%S+00:00", time.gmtime(int(value) / 1000)
            )
        except (TypeError, ValueError, OSError):
            return None

    @classmethod
    def subscription_to_entitlement(
        cls, purchase: Dict[str, Any], product_id: str
    ) -> Dict[str, Any]:
        """Normalize a Play subscription purchase into persistable state.

        Keys: plan_type (PlanType), status (SubscriptionStatus), period
        dates, cancel_at_period_end, order_id, purchase_token, product_id.
        """
        plan_type = cls.plan_for_product(product_id)
        expiry_ms = purchase.get("expiryTimeMillis")
        expired = bool(expiry_ms) and int(expiry_ms) <= int(time.time() * 1000)
        cancel_reason = purchase.get("cancelReason")
        auto_renewing = bool(purchase.get("autoRenewing"))

        if expired or cancel_reason in (0, 1, 3):
            # 0 = user canceled, 1 = system, 3 = developer; 2 = replaced
            # (a new purchase token supersedes it, entitlement handled by the
            # newer token's sync).
            status = "free" if expired else "past_due"
        elif purchase.get("paymentState") == 0:
            status = "past_due"  # payment declined / pending
        else:
            status = "active"

        return {
            "plan_type": plan_type,
            "status": status,
            "current_period_start": cls._ms_timestamp(purchase.get("startTimeMillis")),
            "current_period_end": cls._ms_timestamp(expiry_ms),
            "cancel_at_period_end": not auto_renewing and not expired,
            "order_id": purchase.get("orderId"),
            "linked_purchase_token": purchase.get("linkedPurchaseToken"),
            "purchase_token": None,  # caller supplies the token used for lookup
            "product_id": product_id,
        }

    @staticmethod
    def handle_subscription_notification(
        notification: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Extract the state change from an RTDN notification (no I/O).

        Returns either a subscription sync request
        ({kind: "subscription", subscription_id, purchase_token, notification_type})
        or a test notification marker ({kind: "test"}).
        """
        if "testNotification" in notification:
            return {"kind": "test"}
        sub_notification = notification.get("subscriptionNotification")
        if not sub_notification:
            raise GooglePlayVerificationError(
                "RTDN notification has no subscriptionNotification"
            )
        purchase_token = sub_notification.get("purchaseToken")
        subscription_id = sub_notification.get("subscriptionId")
        if not purchase_token or not subscription_id:
            raise GooglePlayVerificationError(
                "RTDN subscriptionNotification is missing purchaseToken/subscriptionId"
            )
        return {
            "kind": "subscription",
            "subscription_id": subscription_id,
            "purchase_token": purchase_token,
            "notification_type": sub_notification.get("notificationType"),
            "notification_type_name": _GOOGLE_NOTIFICATION_TYPES.get(
                sub_notification.get("notificationType"), "UNKNOWN"
            ),
        }
