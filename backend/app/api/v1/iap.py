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
from datetime import timedelta
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
from app.utils.datetime_util import parse_utc_datetime, utcnow, utcnow_iso


def _is_unique_violation(error: Exception) -> bool:
    """True when a postgrest error reports a unique-constraint violation (23505)."""
    error_info = getattr(error, "json", lambda: {})() or {}
    code = error_info.get("code") or getattr(error, "code", None)
    if code == "23505":
        return True
    text = str(error).lower()
    return "duplicate key" in text or "unique constraint" in text


async def _sync_entitlement_claiming_identifier(
    db: Client,
    user_id: str,
    *,
    provider: str,
    sync_kwargs: Dict[str, Any],
    identifier: Optional[str],
) -> Any:
    """Run the entitlement sync, mapping a concurrent-claim collision to 400.

    ``_ensure_identifier_available`` is a fast-path pre-check; the authoritative
    atomic claim is the partial unique index from migration 052 on the store
    identifier column. Two concurrent registrations of the SAME verified
    transaction from different accounts both pass the SELECT, then the loser's
    upsert raises 23505 — surface the same "already used on another account"
    validation error instead of a 500 the client would retry into the same race.
    """
    try:
        return await SubscriptionService.sync_iap_subscription(
            user_id,
            db,
            provider=provider,
            **sync_kwargs,
        )
    except Exception as error:
        if identifier and _is_unique_violation(error):
            raise ValidationError(
                "This purchase has already been used on another account"
            ) from error
        raise

logger = get_context_logger(__name__)

router = APIRouter(prefix="/subscription", tags=["Subscription", "IAP"])

# App Store Server Notification V2 types that report the end of entitlement.
# Only these may downgrade a subscription when the payload carries no
# signedTransactionInfo. DID_FAIL_TO_RENEW (billing retry in progress) and
# PRICE_INCREASE (consent pending) leave the entitlement untouched.
_ENTITLEMENT_LOSS_TYPES = frozenset({"EXPIRED", "GRACE_PERIOD_EXPIRED", "REVOKE", "REFUND"})

_WEBHOOK_STATUS_PENDING = "pending"
_WEBHOOK_STATUS_PROCESSING = "processing"
_WEBHOOK_STATUS_PROCESSED = "processed"
_WEBHOOK_STATUS_FAILED = "failed"

# A webhook ledger row whose processing_started_at is older than this is a
# worker that died mid-processing; a redelivery may reclaim it (A1-06). Same
# lease idea as the Stripe webhook's 15-minute window, shorter because the
# store handlers are quick.
_WEBHOOK_LEASE_STALE_SECONDS = 5 * 60

# Outcome of _claim_event: the caller must process the event.
_CLAIM_CLAIMED = "claimed"
# Outcome of _claim_event: duplicate; the caller must ack without processing.
_CLAIM_ACKED = "acked"


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


async def _claim_event(db: Client, table: str, pk_column: str, pk_value: str, event_type: str) -> str:
    """Claim a webhook event row for processing; returns _CLAIM_CLAIMED or _CLAIM_ACKED.

    Mirrors stripe_webhook_events: the primary key is the store's own event
    ID so retried deliveries collapse onto one row. A duplicate is NOT acked
    blindly (A1-06): only an already-``processed`` row (or one a live worker
    is currently processing) is acked. A ``failed`` row — or a
    ``processing`` row whose lease is stale (> 5 minutes, i.e. a worker died
    mid-handling) — is reclaimed with a compare-and-swap on
    ``processing_started_at`` so the store retry actually reprocesses it
    instead of being acknowledged forever.
    """
    try:
        await asyncio.to_thread(
            db.table(table)
            .insert({
                pk_column: pk_value,
                "event_type": event_type,
                "status": _WEBHOOK_STATUS_PROCESSING,
                "processing_started_at": utcnow_iso(),
                "attempts": 1,
            })
            .execute
        )
        return _CLAIM_CLAIMED
    except Exception as exc:
        if "duplicate" not in str(exc).lower() and "unique" not in str(exc).lower():
            raise HTTPException(status_code=500, detail="Failed to record webhook event") from exc

    # Duplicate: inspect the existing row before deciding.
    try:
        existing = await asyncio.to_thread(
            db.table(table)
            .select("status,processing_started_at,attempts")
            .eq(pk_column, pk_value)
            .maybe_single()
            .execute
        )
    except Exception:
        # Cannot inspect the ledger (missing table / dead connection). A
        # ack here would be final for rows that still need processing: a
        # failed/stale-processing event depends on THIS delivery to reclaim
        # and retry it, so acknowledging a read failure would suppress the
        # store's redelivery and strand the event forever. Raise 500 so the
        # store retries; a truly duplicate PROCESSED event is cheap to
        # re-acknowledge on the next delivery.
        logger.warning(
            "Could not inspect duplicate webhook event; returning 500 so the "
            "store retries",
            extra={"table": table, "pk": pk_value},
        )
        raise HTTPException(status_code=500, detail="Failed to inspect webhook event") from None
    row = maybe_single_data(existing)
    if not row:
        return _CLAIM_ACKED

    status = row.get("status")
    if status == _WEBHOOK_STATUS_PROCESSED:
        return _CLAIM_ACKED
    started_at = parse_utc_datetime(row.get("processing_started_at"))
    if (
        status == _WEBHOOK_STATUS_PROCESSING
        and started_at is not None
        and started_at > utcnow() - timedelta(seconds=_WEBHOOK_LEASE_STALE_SECONDS)
    ):
        # A live worker holds the lease; this delivery is a duplicate.
        return _CLAIM_ACKED

    # failed, pending, or stale-processing: reclaim with a CAS on the lease.
    previous_started = row.get("processing_started_at")
    claim_query = (
        db.table(table)
        .update({
            "status": _WEBHOOK_STATUS_PROCESSING,
            "processing_started_at": utcnow_iso(),
            "attempts": int(row.get("attempts") or 0) + 1,
        })
        .eq(pk_column, pk_value)
    )
    if previous_started is not None:
        claim_query = claim_query.eq("processing_started_at", previous_started)
    else:
        claim_query = claim_query.is_("processing_started_at", "null")
    claim = await asyncio.to_thread(claim_query.execute)
    claim_data = getattr(claim, "data", None)
    if claim_data is not None and not claim_data:
        # Lost the CAS race to a concurrent retry.
        return _CLAIM_ACKED
    logger.info(
        "Reprocessing previously failed/stale webhook event",
        extra={"table": table, "pk": pk_value, "previous_status": status},
    )
    return _CLAIM_CLAIMED


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


async def _ensure_identifier_available(
    db: Client,
    provider: str,
    identifier: Optional[str],
    user_id: str,
    app_account_token: Optional[str] = None,
) -> None:
    """Reject a store-verified purchase already claimed by another account.

    A verified transaction belongs to exactly one account (A1-01): Apple's
    ``appAccountToken`` is the user id the client attached at purchase time,
    and a Play purchase token is single-use. Without this check, one
    verified transaction id could be re-registered under N accounts, each
    getting a paid entitlement from the same store purchase.

    Two gates:
    - Apple: when the verified transaction carries an appAccountToken, it
      must equal the registering user's id.
    - Both stores: when the transaction identifier is already bound to a
      DIFFERENT user's subscription row, reject the registration.

    Fails closed: a lookup error raises instead of granting.
    """
    if not identifier:
        return
    if provider == "apple" and app_account_token:
        if str(app_account_token) != str(user_id):
            raise ValidationError(
                "This App Store purchase belongs to a different account"
            )
    column = (
        "apple_original_transaction_id" if provider == "apple" else "google_purchase_token"
    )
    try:
        result = await asyncio.to_thread(
            db.table("subscriptions")
            .select("user_id")
            .eq(column, identifier)
            .neq("user_id", user_id)
            .limit(1)
            .execute
        )
    except Exception as exc:
        logger.warning(
            "Could not verify store purchase ownership (fail closed)",
            extra={"provider": provider, "identifier": identifier, "error": str(exc)},
        )
        raise ValidationError(
            "Could not verify purchase ownership. Please try again."
        ) from exc
    rows = getattr(result, "data", None) or []
    if rows:
        logger.warning(
            "Rejected store purchase already claimed by another account",
            extra={
                "provider": provider,
                "identifier": identifier,
                "claimant_user_id": rows[0].get("user_id"),
                "requesting_user_id": user_id,
            },
        )
        raise ValidationError("This purchase has already been used on another account")


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
        # One verified transaction -> one account (A1-01): reject when the
        # purchase already belongs to a different user. The unique index from
        # migration 052 is the atomic claim; the SELECT above is the fast path.
        await _ensure_identifier_available(
            db,
            "apple",
            entitlement["original_transaction_id"],
            user["id"],
            app_account_token=tx_info.get("appAccountToken"),
        )
        result = await _sync_entitlement_claiming_identifier(
            db,
            user["id"],
            provider="apple",
            identifier=entitlement["original_transaction_id"],
            sync_kwargs={
                "plan_type": entitlement["plan_type"],
                "status": entitlement["status"],
                "current_period_start": entitlement["current_period_start"],
                "current_period_end": entitlement["current_period_end"],
                "cancel_at_period_end": entitlement["cancel_at_period_end"],
                "product_id": entitlement["product_id"],
                "apple_original_transaction_id": entitlement["original_transaction_id"],
            },
        )
        return {"data": result.model_dump(mode="json"), "message": "OK"}

    if request.store == StoreType.GOOGLE:
        # The Play API needs the product's subscription ID: the client reports
        # the product it bought; the purchase token identifies the purchase.
        product_id = request.product_id or ""
        GooglePlayService.plan_for_product(product_id)
        purchase = await GooglePlayService.get_subscription(product_id, request.transaction_id)
        entitlement = GooglePlayService.subscription_to_entitlement(purchase, product_id)
        # One verified purchase token -> one account (A1-01); the migration 052
        # unique index makes the claim atomic under concurrency.
        await _ensure_identifier_available(
            db, "google", request.transaction_id, user["id"]
        )
        # Acknowledge so Play does not refund the purchase after 3 days.
        await GooglePlayService.acknowledge(product_id, request.transaction_id)
        result = await _sync_entitlement_claiming_identifier(
            db,
            user["id"],
            provider="google",
            identifier=request.transaction_id,
            sync_kwargs={
                "plan_type": entitlement["plan_type"],
                "status": entitlement["status"],
                "current_period_start": entitlement["current_period_start"],
                "current_period_end": entitlement["current_period_end"],
                "cancel_at_period_end": entitlement["cancel_at_period_end"],
                "product_id": entitlement["product_id"],
                "google_purchase_token": request.transaction_id,
                "google_order_id": entitlement.get("order_id"),
            },
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
    if await _claim_event(db, "apple_iap_events", "notification_id", notification_id, notification_type) != _CLAIM_CLAIMED:
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
    if await _claim_event(
        db,
        "google_rtdn_events",
        "message_id",
        message_id,
        GooglePlayService.notification_type_name(notification),
    ) != _CLAIM_CLAIMED:
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
