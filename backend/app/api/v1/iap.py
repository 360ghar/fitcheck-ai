"""
Mobile In-App Purchase API endpoints.

- POST /subscription/iap/transaction — register a store-verified purchase
  (called by the app right after StoreKit / Play Billing completes).
- POST /subscription/apple/notifications — App Store Server Notification V2
  (renewals, expirations, refunds).
- POST /subscription/google/notifications — Play Real-time Developer
  Notifications push (Pub/Sub).

Every webhook is signature-verified and deduplicated; a failed handler raises
so the store retries. Entitlements are only written from provider-verified
data.
"""
import asyncio
from typing import Any, Dict, Optional

from fastapi import APIRouter, Depends, HTTPException, Request
from supabase import Client

from app.api.v1.deps import get_current_user, get_db
from app.core.exceptions import ValidationError
from app.core.logging_config import get_context_logger
from app.models.subscription import PlanType, RegisterIapTransactionRequest, StoreType
from app.services.apple_iap_service import AppleIAPService, AppleIAPSignatureError
from app.services.google_play_service import GooglePlayService, GooglePlayVerificationError
from app.services.subscription_service import SubscriptionService
from app.utils.datetime_util import utcnow_iso

logger = get_context_logger(__name__)

router = APIRouter(prefix="/subscription", tags=["Subscription", "IAP"])

# App Store Server Notification V2 types that report the end of entitlement.
# Only these may downgrade a subscription when the payload carries no
# signedTransactionInfo. DID_FAIL_TO_RENEW (billing retry in progress) and
# PRICE_INCREASE (consent pending) leave the entitlement untouched.
_ENTITLEMENT_LOSS_TYPES = frozenset({"EXPIRED", "GRACE_PERIOD_EXPIRED", "REVOKE", "REFUND"})

_WEBHOOK_STATUS_PENDING = "pending"
_WEBHOOK_STATUS_PROCESSED = "processed"
_WEBHOOK_STATUS_FAILED = "failed"


def _verified_renewal_info(data: Dict[str, Any]) -> Dict[str, Any]:
    """Verified ``signedRenewalInfo`` claims, or ``{}`` if absent/unverifiable.

    Returning an empty dict rather than raising keeps the caller's shape simple:
    a missing or bad-signature renewal info means "no claims to act on", and both
    the entitlement-loss arm (needs ``originalTransactionId``) and the billing-retry
    arm (logs ``gracePeriodExpiresDate``) treat it that way. Shared so the
    verify/except pair is not written once per claim they happen to want.
    """
    signed_renewal = data.get("signedRenewalInfo")
    if not signed_renewal:
        return {}
    try:
        return AppleIAPService.verify_jws(signed_renewal) or {}
    except AppleIAPSignatureError:
        return {}


async def _claim_event(db: Client, table: str, pk_column: str, pk_value: str, event_type: str) -> bool:
    """Insert a webhook event row; False when it is a duplicate.

    Mirrors stripe_webhook_events: the primary key is the store's own event
    ID so retried deliveries collapse onto one row. Returns True when this
    caller won the insert and must process the event.
    """
    try:
        await asyncio.to_thread(
            db.table(table)
            .insert({pk_column: pk_value, "event_type": event_type, "status": _WEBHOOK_STATUS_PENDING})
            .execute
        )
        return True
    except Exception as exc:
        if "duplicate" in str(exc).lower() or "unique" in str(exc).lower():
            return False
        raise HTTPException(status_code=500, detail="Failed to record webhook event") from exc


async def _finish_event(db: Client, table: str, pk_column: str, pk_value: str, status: str, error: Optional[str] = None) -> None:
    try:
        await asyncio.to_thread(
            db.table(table)
            .update({
                "status": status,
                "processed_at": utcnow_iso() if status == _WEBHOOK_STATUS_PROCESSED else None,
                "last_error": error,
            })
            .eq(pk_column, pk_value)
            .execute
        )
    except Exception:
        logger.error("Failed to update webhook event ledger", extra={"table": table, "pk": pk_value})


async def _user_id_for_app_account_token(
    db: Client, app_account_token: Optional[str]
) -> Optional[str]:
    """Resolve a user from Apple's appAccountToken, or None.

    The token is whatever the client passed at purchase time, so it is checked
    against the users table before anything is written: an unknown UUID would
    otherwise violate the subscriptions FK and 500 the webhook, which Apple
    then retries forever.
    """
    if not app_account_token:
        return None
    try:
        result = await asyncio.to_thread(
            db.table("users")
            .select("id")
            .eq("id", app_account_token)
            .limit(1)
            .execute
        )
    except Exception as exc:
        logger.warning(
            "Could not resolve user from appAccountToken (query failed)",
            extra={"app_account_token": app_account_token, "error": str(exc)},
        )
        return None
    rows = getattr(result, "data", None) or []
    return rows[0].get("id") if rows else None


async def _user_id_for_store_purchase(
    db: Client,
    provider: str,
    identifier: Optional[str],
    app_account_token: Optional[str] = None,
) -> Optional[str]:
    """Resolve the user owning a store purchase, or None when unknown.

    A notification can arrive before the in-app register call completes
    (rare) or for a purchase made on another device. Without a user we
    cannot grant an entitlement, so we log and skip; the app's register call
    always re-syncs the same transaction idempotently.

    ``app_account_token`` is Apple's appAccountToken claim — the user id the
    client attached to the purchase (see IapService.startPurchase). It is the
    fallback when no row carries the transaction identifier yet, which is
    exactly the first-purchase-plus-dropped-network case where the register
    call never landed and the identifier lookup can only ever miss.
    """
    if not identifier:
        return await _user_id_for_app_account_token(db, app_account_token)
    column = (
        "apple_original_transaction_id" if provider == "apple" else "google_purchase_token"
    )
    # NOT `.maybe_single()`: a downgraded row deliberately KEEPS its store
    # identity (see SubscriptionService.sync_store_subscription), so the same
    # store account resubscribing under a different FitCheck account leaves two
    # rows matching one identifier. `.maybe_single()` turns that into a
    # PostgREST PGRST116 error, which this handler swallowed into `return None`
    # — the webhook then acked with `{"received": True}` having written nothing,
    # so renewals never advanced current_period_end and refunds never revoked.
    # Order by recency and take the newest claimant. `limit(2)` is enough to
    # detect (and log) a collision without paying for the full set.
    try:
        result = await asyncio.to_thread(
            db.table("subscriptions")
            .select("user_id,updated_at")
            .eq(column, identifier)
            .order("updated_at", desc=True)
            .limit(2)
            .execute
        )
    except Exception as exc:
        logger.warning(
            "Could not resolve user for store purchase (query failed)",
            extra={"provider": provider, "identifier": identifier, "error": str(exc)},
        )
        return None

    rows = getattr(result, "data", None) or []
    if not rows:
        fallback_user_id = await _user_id_for_app_account_token(db, app_account_token)
        if fallback_user_id:
            logger.info(
                "Resolved store purchase from appAccountToken (no row carries "
                "the transaction identifier yet)",
                extra={
                    "provider": provider,
                    "identifier": identifier,
                    "user_id": fallback_user_id,
                },
            )
            return fallback_user_id
        logger.warning(
            "No subscription row matches this store purchase",
            extra={"provider": provider, "identifier": identifier},
        )
        return None
    if len(rows) > 1:
        logger.warning(
            "Multiple subscription rows share one store identifier; "
            "using the most recently updated",
            extra={
                "provider": provider,
                "identifier": identifier,
                "user_ids": [r.get("user_id") for r in rows],
            },
        )
    return rows[0].get("user_id")


# =============================================================================
# Register a store purchase (authenticated)
# =============================================================================


@router.post("/iap/transaction", response_model=Dict[str, Any])
async def register_iap_transaction(
    request: RegisterIapTransactionRequest,
    user=Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Register a purchase made through Apple In-App Purchase or Play Billing.

    The backend verifies the transaction with the store's server API before
    granting any entitlement, so a spoofed client payload alone can never
    upgrade an account.
    """
    if request.store == StoreType.APPLE:
        tx_info = await AppleIAPService.verify_transaction(request.transaction_id)
        # Cross-check the client-reported product against the verified one.
        if request.product_id and request.product_id != tx_info.get("productId"):
            raise ValidationError(
                "Product ID does not match the verified App Store transaction"
            )
        entitlement = AppleIAPService.transaction_to_entitlement(tx_info)
        result = await SubscriptionService.sync_iap_subscription(
            user["id"],
            db,
            provider="apple",
            plan_type=entitlement["plan_type"],
            status=entitlement["status"],
            current_period_start=entitlement["current_period_start"],
            current_period_end=entitlement["current_period_end"],
            cancel_at_period_end=entitlement["cancel_at_period_end"],
            product_id=entitlement["product_id"],
            apple_original_transaction_id=entitlement["original_transaction_id"],
        )
        return {"data": result.model_dump(mode="json"), "message": "OK"}

    if request.store == StoreType.GOOGLE:
        # The Play API needs the product's subscription ID: the client reports
        # the product it bought; the purchase token identifies the purchase.
        product_id = request.product_id or ""
        GooglePlayService.plan_for_product(product_id)
        purchase = await GooglePlayService.get_subscription(product_id, request.transaction_id)
        entitlement = GooglePlayService.subscription_to_entitlement(purchase, product_id)
        # Acknowledge so Play does not refund the purchase after 3 days.
        await GooglePlayService.acknowledge(product_id, request.transaction_id)
        result = await SubscriptionService.sync_iap_subscription(
            user["id"],
            db,
            provider="google",
            plan_type=entitlement["plan_type"],
            status=entitlement["status"],
            current_period_start=entitlement["current_period_start"],
            current_period_end=entitlement["current_period_end"],
            cancel_at_period_end=entitlement["cancel_at_period_end"],
            product_id=entitlement["product_id"],
            google_purchase_token=request.transaction_id,
            google_order_id=entitlement.get("order_id"),
        )
        return {"data": result.model_dump(mode="json"), "message": "OK"}

    raise ValidationError("Unknown store")


# =============================================================================
# App Store Server Notification V2 webhook
# =============================================================================


@router.post("/apple/notifications")
async def apple_notifications(request: Request, db: Client = Depends(get_db)):
    """
    Receive App Store Server Notifications V2 (renewals, expirations, refunds).

    The JWS signedPayload is verified against the Apple certificate chain.
    Entitlements are written only from provider-verified data: notifications
    carrying signedTransactionInfo sync it (REFUND/REVOKE transactions carry
    revocationDate -> status "free"); entitlement-loss types without
    transaction info downgrade from the signed renewal info; billing-state
    types (DID_FAIL_TO_RENEW, PRICE_INCREASE) and unknown types are acked
    without touching the subscription.
    Returns 500 on processing failure so Apple retries with backoff.
    """
    try:
        body = await request.json()
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid JSON body")
    signed_payload = body.get("signedPayload") if isinstance(body, dict) else None
    if not signed_payload:
        raise HTTPException(status_code=400, detail="Missing signedPayload")

    try:
        notification = AppleIAPService.verify_notification(signed_payload)
    except AppleIAPSignatureError as exc:
        # Signature failures must not be retried: acknowledge with 200 so
        # Apple stops redelivering an unprocessable payload.
        logger.warning("Rejected App Store notification with bad signature", extra={"error": str(exc)})
        return {"received": True}

    notification_id = notification.get("notificationId")
    notification_type = notification.get("notificationType", "UNKNOWN")
    # The subtype is what distinguishes an UPGRADE from a DOWNGRADE on
    # DID_CHANGE_RENEWAL_PREF, and the environment tells Sandbox (our testing
    # and App Review) from Production. Both were previously invisible.
    notification_subtype = notification.get("subtype")
    notification_env = (notification.get("data") or {}).get("environment")
    if not notification_id:
        raise HTTPException(status_code=400, detail="Notification has no notificationId")
    logger.info(
        "App Store notification received",
        extra={
            "notification_id": notification_id,
            "notification_type": notification_type,
            "subtype": notification_subtype,
            "environment": notification_env,
        },
    )
    if not await _claim_event(db, "apple_iap_events", "notification_id", notification_id, notification_type):
        return {"received": True, "duplicate": True}

    try:
        data = notification.get("data") or {}
        signed_tx = data.get("signedTransactionInfo")

        # Any notification carrying a verified signedTransactionInfo is
        # provider-verified entitlement data (grant / renew / refund / revoke
        # all attach the transaction; REFUND/REVOKE transactions carry
        # revocationDate, which transaction_to_entitlement maps to
        # status="free"). Sync from it.
        # One arm per notification class, then a SINGLE ack at the end. Each arm
        # used to repeat the same _finish_event + return pair, so a change to how
        # events are finalized had five edit sites and the cost of missing one is
        # Apple redelivering that notification forever.
        if signed_tx:
            tx_info = AppleIAPService.verify_jws(signed_tx)
            AppleIAPService.validate_transaction_info(tx_info)
            # The renewal info carries autoRenewStatus: a DID_CHANGE_RENEWAL_STATUS
            # for a cancellation re-delivers the SAME transaction, and only this
            # claim distinguishes "still renewing" from "ends at period end".
            entitlement = AppleIAPService.transaction_to_entitlement(
                tx_info, renewal_info=_verified_renewal_info(data)
            )
            user_id = await _user_id_for_store_purchase(
                db,
                "apple",
                entitlement["original_transaction_id"],
                app_account_token=tx_info.get("appAccountToken"),
            )
            if user_id:
                await SubscriptionService.sync_iap_subscription(
                    user_id,
                    db,
                    provider="apple",
                    plan_type=entitlement["plan_type"],
                    status=entitlement["status"],
                    current_period_start=entitlement["current_period_start"],
                    current_period_end=entitlement["current_period_end"],
                    cancel_at_period_end=entitlement["cancel_at_period_end"],
                    product_id=entitlement["product_id"],
                    apple_original_transaction_id=entitlement["original_transaction_id"],
                )

        # No transaction info: only actual entitlement-loss types may
        # downgrade. EXPIRED / GRACE_PERIOD_EXPIRED / REFUND / REVOKE report
        # the end of entitlement; resolve the originalTransactionId from the
        # signed renewal info (also a JWS).
        elif notification_type in _ENTITLEMENT_LOSS_TYPES:
            original_transaction_id = _verified_renewal_info(data).get("originalTransactionId")
            if original_transaction_id:
                user_id = await _user_id_for_store_purchase(db, "apple", original_transaction_id)
                if user_id:
                    # The plan_type argument is ignored on the downgrade path.
                    # Pass the identifier so sync_iap_subscription can tell a
                    # refund for a SUPERSEDED transaction (row now carries a
                    # newer id) apart from one for the current transaction and
                    # skip the downgrade in the stale case.
                    await SubscriptionService.sync_iap_subscription(
                        user_id,
                        db,
                        provider="apple",
                        plan_type=PlanType.PRO_MONTHLY,
                        status="free",
                        apple_original_transaction_id=original_transaction_id,
                    )

        elif notification_type == "DID_FAIL_TO_RENEW":
            # Billing retry in progress: Apple keeps retrying the renewal and
            # the subscription stays entitled until the grace period ends.
            # Do NOT downgrade — regression: this used to revoke a
            # still-active subscription via the renewal-info path.
            logger.info(
                "App Store subscription entered billing retry; entitlement continues",
                extra={
                    "notification_id": notification_id,
                    "grace_period_expires": _verified_renewal_info(data).get(
                        "gracePeriodExpiresDate"
                    ),
                },
            )

        elif notification_type == "PRICE_INCREASE":
            # Consent to a price change is pending; the subscription
            # continues at the current price until the user acts. No
            # entitlement change.
            logger.info(
                "App Store price increase consent pending; entitlement continues",
                extra={"notification_id": notification_id},
            )

        else:
            # UNKNOWN notification type (or a grant type without transaction
            # info): ack without writing any entitlement — never downgrade on a
            # payload we do not understand. Apple's "Request a Test
            # Notification" (type TEST) lands here by design; that is a
            # successful round trip, not a failure.
            logger.warning(
                "Ignoring App Store notification with unrecognized type",
                extra={"notification_id": notification_id, "notification_type": notification_type},
            )

        await _finish_event(db, "apple_iap_events", "notification_id", notification_id, _WEBHOOK_STATUS_PROCESSED)
        return {"received": True}

    except HTTPException:
        raise
    except Exception as exc:
        logger.error(
            f"Error processing App Store notification {notification_type}: {exc}",
            exc_info=True,
            extra={
                "notification_id": notification_id,
                "subtype": notification_subtype,
                "environment": notification_env,
            },
        )
        await _finish_event(db, "apple_iap_events", "notification_id", notification_id, _WEBHOOK_STATUS_FAILED, str(exc)[:1000])
        raise HTTPException(status_code=500, detail="Failed to process App Store notification")


# =============================================================================
# Google Play Real-time Developer Notifications webhook
# =============================================================================


@router.post("/google/notifications")
async def google_notifications(request: Request, db: Client = Depends(get_db)):
    """
    Receive Google Play Real-time Developer Notifications (Pub/Sub push).

    Verifies the OIDC bearer token (audience = GOOGLE_RTDN_AUDIENCE) and the
    Pub/Sub envelope, then reconciles the subscription against the Play
    Developer API. Returns 500 on processing failure so Pub/Sub retries.
    """
    try:
        body = await request.json()
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid JSON body")

    try:
        await GooglePlayService.verify_rtdn_authorization(request.headers.get("Authorization"))
    except GooglePlayVerificationError as exc:
        logger.warning("Rejected RTDN push", extra={"error": str(exc)})
        raise HTTPException(status_code=401, detail="RTDN verification failed")

    try:
        message_id, notification = GooglePlayService._decode_pubsub_message(body)
    except GooglePlayVerificationError as exc:
        raise HTTPException(status_code=400, detail=str(exc))

    # Persist the real RTDN notification type name (not a blanket 'rtdn'
    # label): the admin revenue endpoint counts Google churn from these
    # names, so 'SUBSCRIPTION_EXPIRED'/'CANCELED'/'REVOKED' rows must be
    # distinguishable from renewals and purchases.
    if not await _claim_event(
        db,
        "google_rtdn_events",
        "message_id",
        message_id,
        GooglePlayService.notification_type_name(notification),
    ):
        return {"received": True, "duplicate": True}

    try:
        event = GooglePlayService.handle_subscription_notification(notification)
        if event["kind"] == "test":
            await _finish_event(db, "google_rtdn_events", "message_id", message_id, _WEBHOOK_STATUS_PROCESSED)
            return {"received": True}

        purchase = await GooglePlayService.get_subscription(
            event["subscription_id"], event["purchase_token"]
        )
        entitlement = GooglePlayService.subscription_to_entitlement(
            purchase, event["subscription_id"]
        )
        user_id = await _user_id_for_store_purchase(db, "google", event["purchase_token"])
        if user_id:
            await SubscriptionService.sync_iap_subscription(
                user_id,
                db,
                provider="google",
                plan_type=entitlement["plan_type"],
                status=entitlement["status"],
                current_period_start=entitlement["current_period_start"],
                current_period_end=entitlement["current_period_end"],
                cancel_at_period_end=entitlement["cancel_at_period_end"],
                product_id=entitlement["product_id"],
                google_purchase_token=event["purchase_token"],
                google_order_id=entitlement.get("order_id"),
            )
        await GooglePlayService.acknowledge(event["subscription_id"], event["purchase_token"])
        await _finish_event(db, "google_rtdn_events", "message_id", message_id, _WEBHOOK_STATUS_PROCESSED)
        return {"received": True}

    except HTTPException:
        raise
    except Exception as exc:
        logger.error(f"Error processing RTDN push: {exc}", exc_info=True)
        await _finish_event(db, "google_rtdn_events", "message_id", message_id, _WEBHOOK_STATUS_FAILED, str(exc)[:1000])
        raise HTTPException(status_code=500, detail="Failed to process RTDN push")
