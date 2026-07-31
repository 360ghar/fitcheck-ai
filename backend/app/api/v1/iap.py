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
from app.utils import maybe_single_data
from app.utils.datetime_util import utcnow_iso

logger = get_context_logger(__name__)

router = APIRouter(prefix="/subscription", tags=["Subscription", "IAP"])

_WEBHOOK_STATUS_PENDING = "pending"
_WEBHOOK_STATUS_PROCESSED = "processed"
_WEBHOOK_STATUS_FAILED = "failed"


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


async def _user_id_for_store_purchase(db: Client, provider: str, identifier: Optional[str]) -> Optional[str]:
    """Resolve the user owning a store purchase, or None when unknown.

    A notification can arrive before the in-app register call completes
    (rare) or for a purchase made on another device. Without a user we
    cannot grant an entitlement, so we log and skip; the app's register call
    always re-syncs the same transaction idempotently.
    """
    if not identifier:
        return None
    column = (
        "apple_original_transaction_id" if provider == "apple" else "google_purchase_token"
    )
    try:
        result = await asyncio.to_thread(
            db.table("subscriptions")
            .select("user_id")
            .eq(column, identifier)
            .maybe_single()
            .execute
        )
        data = maybe_single_data(result)
        return data.get("user_id") if data else None
    except Exception as exc:
        logger.warning(
            "Could not resolve user for store purchase",
            extra={"provider": provider, "identifier": identifier, "error": str(exc)},
        )
        return None


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
    if not notification_id:
        raise HTTPException(status_code=400, detail="Notification has no notificationId")
    if not await _claim_event(db, "apple_iap_events", "notification_id", notification_id, notification_type):
        return {"received": True, "duplicate": True}

    try:
        data = notification.get("data") or {}
        signed_tx = data.get("signedTransactionInfo")
        if signed_tx:
            tx_info = AppleIAPService.verify_jws(signed_tx)
            AppleIAPService.validate_transaction_info(tx_info)
            entitlement = AppleIAPService.transaction_to_entitlement(tx_info)
            user_id = await _user_id_for_store_purchase(
                db, "apple", entitlement["original_transaction_id"]
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
            await _finish_event(db, "apple_iap_events", "notification_id", notification_id, _WEBHOOK_STATUS_PROCESSED)
            return {"received": True}

        # EXPIRED / GRACE_PERIOD_EXPIRED / REFUND / REVOKE without transaction
        # info: the store reports the end of entitlement. Extract the
        # originalTransactionId from the signed renewal info (also a JWS).
        original_transaction_id = None
        signed_renewal = data.get("signedRenewalInfo")
        if signed_renewal:
            try:
                renewal_info = AppleIAPService.verify_jws(signed_renewal)
                original_transaction_id = renewal_info.get("originalTransactionId")
            except AppleIAPSignatureError:
                original_transaction_id = None
        if original_transaction_id:
            user_id = await _user_id_for_store_purchase(db, "apple", original_transaction_id)
            if user_id:
                # The plan_type argument is ignored on the downgrade path.
                await SubscriptionService.sync_iap_subscription(
                    user_id,
                    db,
                    provider="apple",
                    plan_type=PlanType.PRO_MONTHLY,
                    status="free",
                )
        await _finish_event(db, "apple_iap_events", "notification_id", notification_id, _WEBHOOK_STATUS_PROCESSED)
        return {"received": True}

    except HTTPException:
        raise
    except Exception as exc:
        logger.error(f"Error processing App Store notification {notification_type}: {exc}", exc_info=True)
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

    if not await _claim_event(db, "google_rtdn_events", "message_id", message_id, "rtdn"):
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
