"""
Subscription API endpoints for managing user subscriptions and billing.
"""
from datetime import timedelta
from typing import Any, Dict, Optional

import asyncio
import stripe
from fastapi import APIRouter, Depends, Request, HTTPException
from supabase import Client

from app.api.v1.deps import get_current_user, get_db
from app.core.config import settings
from app.core.exceptions import ServiceError, ValidationError
from app.core.logging_config import get_context_logger
from app.models.subscription import (
    PlanType,
    CreateCheckoutRequest,
    CheckoutSessionResponse,
    PortalSessionResponse,
)
from app.services.subscription_service import SubscriptionService
from app.utils import maybe_single_data
from app.utils.datetime_util import parse_utc_datetime, utcnow, utcnow_iso

logger = get_context_logger(__name__)

router = APIRouter()


# Webhook deduplication/processing state machine (migration 027). The route and
# any future reaper share one spelling for each state.
_WEBHOOK_STATUS_PENDING = "pending"
_WEBHOOK_STATUS_PROCESSING = "processing"
_WEBHOOK_STATUS_PROCESSED = "processed"
_WEBHOOK_STATUS_FAILED = "failed"


def _has_expanded_subscription_items(subscription: object) -> bool:
    """Whether a Stripe subscription contains a usable first item."""
    if isinstance(subscription, dict):
        items = subscription.get("items") or {}
        data = items.get("data") if isinstance(items, dict) else None
    else:
        items = getattr(subscription, "items", None)
        data = getattr(items, "data", None) if items is not None else None
    # StripeList subclasses list; requiring a concrete sequence also avoids
    # treating MagicMock / malformed provider payloads as expanded items.
    return isinstance(data, (list, tuple)) and bool(data)


def _first_subscription_item_id(subscription: object) -> Optional[str]:
    """Extract the first Stripe subscription item's ID from either payload shape."""
    if isinstance(subscription, dict):
        items = subscription.get("items") or {}
        data = items.get("data", []) if isinstance(items, dict) else []
    else:
        items = getattr(subscription, "items", None)
        data = getattr(items, "data", []) if items is not None else []
    if not isinstance(data, (list, tuple)) or not data:
        return None
    item = data[0]
    if isinstance(item, dict):
        return item.get("id")
    return getattr(item, "id", None)


def _absolute_checkout_url(url: str) -> str:
    """Convert API-relative checkout defaults into Stripe-compatible URLs."""
    if url.startswith(("http://", "https://")):
        return url
    return f"{settings.FRONTEND_URL.rstrip('/')}/{url.lstrip('/')}"


# =============================================================================
# Subscription Endpoints
# =============================================================================


@router.get("", response_model=Dict[str, Any])
async def get_subscription(
    user=Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Get current user's subscription status and usage.

    Returns the subscription plan details, current period, and monthly usage stats.
    """
    result = await SubscriptionService.get_subscription_with_usage(user["id"], db)
    return {"data": result.model_dump(mode="json"), "message": "OK"}


@router.get("/usage", response_model=Dict[str, Any])
async def get_usage(
    user=Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Get detailed monthly usage statistics.

    Returns current usage vs limits for extractions, generations, and embeddings.
    """
    result = await SubscriptionService.get_usage(user["id"], db)
    return {"data": result.model_dump(mode="json"), "message": "OK"}


@router.get("/plans")
async def get_plans():
    """
    Get available subscription plans and pricing.

    Returns plan details for display on pricing pages. Each paid plan also
    carries the store product IDs used by the mobile apps (null when the
    store billing rail is not configured server-side).
    """
    free_limits = {
        "monthly_extractions": settings.PLAN_FREE_MONTHLY_EXTRACTIONS,
        "monthly_generations": settings.PLAN_FREE_MONTHLY_GENERATIONS,
        "monthly_embeddings": settings.PLAN_FREE_MONTHLY_EMBEDDINGS,
    }
    plus_limits = {
        "monthly_extractions": settings.PLAN_PLUS_MONTHLY_EXTRACTIONS,
        "monthly_generations": settings.PLAN_PLUS_MONTHLY_GENERATIONS,
        "monthly_embeddings": settings.PLAN_PLUS_MONTHLY_EMBEDDINGS,
    }
    pro_limits = {
        "monthly_extractions": settings.PLAN_PRO_MONTHLY_EXTRACTIONS,
        "monthly_generations": settings.PLAN_PRO_MONTHLY_GENERATIONS,
        "monthly_embeddings": settings.PLAN_PRO_MONTHLY_EMBEDDINGS,
    }

    return {
        "data": {
            # Per-variant store product IDs (null when the store rail is not
            # configured). The mobile clients use these to query/purchase via
            # StoreKit / Play Billing; values are never hardcoded client-side.
            "store_products": {
                "apple": {
                    "plus_monthly": settings.APPLE_PLUS_MONTHLY_PRODUCT_ID,
                    "plus_yearly": settings.APPLE_PLUS_YEARLY_PRODUCT_ID,
                    "pro_monthly": settings.APPLE_PRO_MONTHLY_PRODUCT_ID,
                    "pro_yearly": settings.APPLE_PRO_YEARLY_PRODUCT_ID,
                },
                "google": {
                    "plus_monthly": settings.GOOGLE_PLUS_MONTHLY_PRODUCT_ID,
                    "plus_yearly": settings.GOOGLE_PLUS_YEARLY_PRODUCT_ID,
                    "pro_monthly": settings.GOOGLE_PRO_MONTHLY_PRODUCT_ID,
                    "pro_yearly": settings.GOOGLE_PRO_YEARLY_PRODUCT_ID,
                },
            },
            "plans": [
            {
                "id": "free",
                "name": "Free",
                "price_monthly": 0,
                "price_yearly": 0,
                # Flutter client expects flattened limit keys
                **free_limits,
                "limits": {
                    **free_limits,
                },
                "features": [
                    f"{settings.PLAN_FREE_MONTHLY_EXTRACTIONS} item extractions per month",
                    f"{settings.PLAN_FREE_MONTHLY_GENERATIONS} outfit visualizations per month",
                    "Basic wardrobe management",
                    "Calendar integration",
                ],
            },
            {
                "id": "plus",
                "name": "Plus",
                "price_monthly": settings.PLAN_PLUS_MONTHLY_PRICE,
                "price_yearly": settings.PLAN_PLUS_YEARLY_PRICE,
                "savings_yearly": (settings.PLAN_PLUS_MONTHLY_PRICE * 12) - settings.PLAN_PLUS_YEARLY_PRICE,
                # Flutter client expects flattened limit keys
                **plus_limits,
                "limits": {
                    **plus_limits,
                },
                "features": [
                    f"{settings.PLAN_PLUS_MONTHLY_EXTRACTIONS} item extractions per month",
                    f"{settings.PLAN_PLUS_MONTHLY_GENERATIONS} outfit visualizations per month",
                    "Virtual try-on visualization",
                    "Advanced AI styling recommendations",
                    "Calendar planning",
                    # Plus is feature-equivalent to Pro (only limits differ);
                    # the /plans contract must advertise the same paid entries.
                    "Priority support",
                    "Early access to new features",
                ],
            },
            {
                "id": "pro",
                "name": "Pro",
                "price_monthly": settings.PLAN_PRO_MONTHLY_PRICE,
                "price_yearly": settings.PLAN_PRO_YEARLY_PRICE,
                "savings_yearly": (settings.PLAN_PRO_MONTHLY_PRICE * 12) - settings.PLAN_PRO_YEARLY_PRICE,
                # Flutter client expects flattened limit keys
                **pro_limits,
                "limits": {
                    **pro_limits,
                },
                "features": [
                    f"{settings.PLAN_PRO_MONTHLY_EXTRACTIONS} item extractions per month",
                    f"{settings.PLAN_PRO_MONTHLY_GENERATIONS} outfit visualizations per month",
                    "Advanced AI styling recommendations",
                    "Priority support",
                    "Early access to new features",
                ],
            },
            ],
        },
        "message": "OK",
    }


# =============================================================================
# Stripe Checkout Endpoints
# =============================================================================


@router.post("/checkout", response_model=Dict[str, Any])
async def create_checkout_session(
    request: CreateCheckoutRequest,
    user=Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Create a Stripe Checkout session for upgrading to Pro.

    Returns a checkout URL to redirect the user to.
    """
    if not settings.STRIPE_SECRET_KEY:
        raise ServiceError("Stripe is not configured. Please contact support.")

    # Validate plan type
    if request.plan_type == PlanType.FREE:
        raise ValidationError("Cannot checkout for free plan")

    # Set Stripe API key
    stripe.api_key = settings.STRIPE_SECRET_KEY

    # Map each paid plan type to its Stripe price ID explicitly. No silent
    # fallback: an unmapped plan raises so a new tier can never accidentally
    # charge the monthly Pro price.
    plan_price_ids = {
        PlanType.PLUS_MONTHLY: settings.STRIPE_PLUS_MONTHLY_PRICE_ID,
        PlanType.PLUS_YEARLY: settings.STRIPE_PLUS_YEARLY_PRICE_ID,
        PlanType.PRO_MONTHLY: settings.STRIPE_PRO_MONTHLY_PRICE_ID,
        PlanType.PRO_YEARLY: settings.STRIPE_PRO_YEARLY_PRICE_ID,
    }
    price_id = plan_price_ids.get(request.plan_type)

    if not price_id:
        raise ServiceError("Stripe price not configured. Please contact support.")

    try:
        # Get or create Stripe customer (side effect: creates a default
        # subscription row if the user doesn't have one yet)
        await SubscriptionService.get_subscription(user["id"], db)

        # Read the raw billing state as well as the effective entitlement. A
        # stale paid row without a Stripe subscription ID is unsafe to treat
        # as a new checkout: it can create a second subscription for one user.
        sub_result = await asyncio.to_thread(
            db.table("subscriptions")
            .select("stripe_customer_id,stripe_subscription_id,plan_type,status,billing_provider")
            .eq("user_id", user["id"])
            .maybe_single()
            .execute
        )
        sub_data = maybe_single_data(sub_result) or {}
        billing_provider = sub_data.get("billing_provider", "stripe")
        if billing_provider in ("apple", "google"):
            # App Store Guideline 3.1.1 / Play policy: a store-billed account
            # must not be steered to Stripe checkout from the mobile apps, and
            # a web Stripe purchase would silently double-bill alongside the
            # store subscription. Fail closed.
            raise ServiceError(
                "This account is billed through the "
                f"{'App Store' if billing_provider == 'apple' else 'Play Store'}; "
                "web checkout is not available for store-billed subscriptions."
            )
        stored_plan = PlanType(sub_data.get("plan_type", "free"))
        existing_subscription_id = sub_data.get("stripe_subscription_id")

        if SubscriptionService.is_paid_plan(stored_plan) and not existing_subscription_id:
            raise ServiceError(
                "Your account has a paid billing state but no Stripe subscription ID. "
                "Please contact support before starting another checkout."
            )

        # Existing Stripe subscriptions are modified in place. This is used
        # for tier changes and monthly/yearly changes and prevents duplicate
        # subscriptions for one customer.
        if existing_subscription_id:
            try:
                current_subscription = stripe.Subscription.retrieve(existing_subscription_id)
                item_id = _first_subscription_item_id(current_subscription)
                if not item_id:
                    raise ServiceError(
                        "Stripe subscription has no subscription item to update. Please contact support."
                    )

                updated_subscription = stripe.Subscription.modify(
                    existing_subscription_id,
                    items=[{"id": item_id, "price": price_id}],
                    cancel_at_period_end=False,
                    proration_behavior="create_prorations",
                    metadata={
                        "user_id": user["id"],
                        "plan_type": request.plan_type.value,
                    },
                )
                # The webhook remains authoritative. When Stripe returns the
                # expanded subscription, synchronize immediately as well so
                # clients can refresh their entitlement without waiting for
                # webhook delivery.
                if _has_expanded_subscription_items(updated_subscription):
                    await SubscriptionService.sync_stripe_subscription(
                        user["id"], updated_subscription, db
                    )
                logger.info(
                    "Updated existing Stripe subscription",
                    user_id=user["id"],
                    stripe_subscription_id=existing_subscription_id,
                    plan_type=request.plan_type.value,
                )
                result = CheckoutSessionResponse(
                    checkout_url=None,
                    session_id=None,
                    updated=True,
                )
                return {"data": result.model_dump(mode="json"), "message": "OK"}
            except ServiceError:
                raise
            except stripe.error.StripeError as e:
                logger.error(f"Stripe error updating subscription: {e}")
                raise ServiceError(f"Payment update error: {str(e)}")

        # Check existing Stripe customer
        customer_id = None
        if sub_data and sub_data.get("stripe_customer_id"):
            customer_id = sub_data["stripe_customer_id"]
        else:
            # Create new customer
            customer = stripe.Customer.create(
                email=user.get("email"),
                name=user.get("full_name"),
                metadata={"user_id": user["id"]},
            )
            customer_id = customer.id

            # Save customer ID
            await asyncio.to_thread(db.table("subscriptions").update({
                "stripe_customer_id": customer_id,
            }).eq("user_id", user["id"]).execute)

        # Create checkout session
        checkout_session = stripe.checkout.Session.create(
            customer=customer_id,
            payment_method_types=["card"],
            line_items=[{"price": price_id, "quantity": 1}],
            mode="subscription",
            success_url=_absolute_checkout_url(request.success_url),
            cancel_url=_absolute_checkout_url(request.cancel_url),
            metadata={
                "user_id": user["id"],
                "plan_type": request.plan_type.value,
            },
            subscription_data={
                "metadata": {
                    "user_id": user["id"],
                    "plan_type": request.plan_type.value,
                },
            },
        )

        logger.info(f"Created checkout session for user {user['id']}: {checkout_session.id}")

        result = CheckoutSessionResponse(
            checkout_url=checkout_session.url,
            session_id=checkout_session.id,
        )
        return {"data": result.model_dump(mode="json"), "message": "OK"}

    except stripe.error.StripeError as e:
        logger.error(f"Stripe error creating checkout: {e}")
        raise ServiceError(f"Payment error: {str(e)}")


@router.post("/portal", response_model=Dict[str, Any])
async def create_portal_session(
    return_url: Optional[str] = None,
    user=Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Create a Stripe Customer Portal session for managing subscription.

    Allows users to update payment method, view invoices, and cancel subscription.
    """
    if not settings.STRIPE_SECRET_KEY:
        raise ServiceError("Stripe is not configured")

    stripe.api_key = settings.STRIPE_SECRET_KEY

    # Get customer ID
    sub_result = await asyncio.to_thread(
        db.table("subscriptions")
        .select("stripe_customer_id")
        .eq("user_id", user["id"])
        .maybe_single()
        .execute
    )

    sub_data = maybe_single_data(sub_result)
    if not sub_data or not sub_data.get("stripe_customer_id"):
        raise ValidationError("No billing account found. Please upgrade to Pro first.")

    try:
        portal_session = stripe.billing_portal.Session.create(
            customer=sub_data["stripe_customer_id"],
            return_url=return_url or settings.FRONTEND_URL,
        )

        result = PortalSessionResponse(portal_url=portal_session.url)
        return {"data": result.model_dump(mode="json"), "message": "OK"}

    except stripe.error.StripeError as e:
        logger.error(f"Stripe error creating portal: {e}")
        raise ServiceError(f"Error accessing billing portal: {str(e)}")


@router.post("/cancel", response_model=Dict[str, Any])
async def cancel_subscription(
    user=Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Cancel subscription at the end of the current billing period.

    The user will retain access until the period ends.
    """
    subscription = await SubscriptionService.get_subscription(user["id"], db)

    if subscription.plan_type == PlanType.FREE:
        raise ValidationError("You don't have an active paid subscription")

    # If Stripe subscription exists, cancel it there too
    sub_result = await asyncio.to_thread(
        db.table("subscriptions")
        .select("stripe_subscription_id")
        .eq("user_id", user["id"])
        .maybe_single()
        .execute
    )

    sub_data = maybe_single_data(sub_result)
    if sub_data and sub_data.get("stripe_subscription_id") and settings.STRIPE_SECRET_KEY:
        try:
            stripe.api_key = settings.STRIPE_SECRET_KEY
            stripe.Subscription.modify(
                sub_data["stripe_subscription_id"],
                cancel_at_period_end=True,
            )
        except stripe.error.StripeError as e:
            logger.error(f"Error cancelling Stripe subscription: {e}")
            raise ServiceError(
                "Stripe could not schedule cancellation; your local subscription was not changed."
            ) from e

    result = await SubscriptionService.cancel_subscription(user["id"], db)
    return {"data": result.model_dump(mode="json"), "message": "OK"}


# =============================================================================
# Stripe Webhook
# =============================================================================


@router.post("/webhook")
async def stripe_webhook(request: Request, db: Client = Depends(get_db)):
    """
    Handle Stripe webhook events.

    Events handled:
    - checkout.session.completed: Activate subscription after payment
    - customer.subscription.updated: Handle plan changes
    - customer.subscription.deleted: Handle cancellation
    - invoice.payment_failed: Mark subscription as past_due
    """
    if not settings.STRIPE_SECRET_KEY or not settings.STRIPE_WEBHOOK_SECRET:
        raise HTTPException(status_code=501, detail="Webhooks not configured")

    stripe.api_key = settings.STRIPE_SECRET_KEY

    payload = await request.body()
    sig_header = request.headers.get("stripe-signature")

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
        )
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid payload")
    except stripe.error.SignatureVerificationError:
        raise HTTPException(status_code=400, detail="Invalid signature")

    # Stripe retries deliveries. Keep an explicit processing state so an
    # event is only acknowledged after side effects succeed. Events without an
    # ID are retained for backwards-compatible test/minimal payload handling.
    event_id = event.get("id") if isinstance(event, dict) else getattr(event, "id", None)
    if event_id:
        event_row = None
        try:
            await asyncio.to_thread(
                db.table("stripe_webhook_events")
                .insert({"event_id": event_id, "event_type": event["type"], "status": _WEBHOOK_STATUS_PENDING})
                .execute
            )
        except Exception as exc:
            if "duplicate" in str(exc).lower() or "unique" in str(exc).lower():
                existing = await asyncio.to_thread(
                    db.table("stripe_webhook_events")
                    .select("event_id,event_type,status,processing_started_at,attempts")
                    .eq("event_id", event_id)
                    .maybe_single()
                    .execute
                )
                event_row = maybe_single_data(existing)
                # Preserve the old safe acknowledgement when a legacy table
                # or a minimal test double cannot return the row.
                if not event_row:
                    logger.info("Ignoring duplicate Stripe webhook", extra={"event_id": event_id})
                    return {"received": True, "duplicate": True}
                if event_row.get("status") == _WEBHOOK_STATUS_PROCESSED:
                    return {"received": True, "duplicate": True}
            else:
                raise HTTPException(status_code=500, detail="Failed to record webhook event") from exc

        current_status = (event_row or {}).get("status", _WEBHOOK_STATUS_PENDING)
        previous_started = (event_row or {}).get("processing_started_at")
        if current_status == _WEBHOOK_STATUS_PROCESSING:
            started = previous_started
            started_at = parse_utc_datetime(started)
            if started_at and started_at > utcnow() - timedelta(minutes=15):
                return {"received": True, "duplicate": True}
            # A worker died while processing. Reclaim the stale row below.

        previous_attempts = int((event_row or {}).get("attempts") or 0)
        # Claim with a compare-and-swap on the observed lease: two concurrent
        # retries of the same stale `processing` row both match a bare
        # status predicate (the value never changes), so both would claim and
        # apply side effects twice. Predicating on `processing_started_at`
        # makes the update atomic — the loser re-checks the predicate against
        # the freshly claimed row and matches nothing.
        claim_started = utcnow_iso()
        claim_query = (
            db.table("stripe_webhook_events")
            .update({
                "status": _WEBHOOK_STATUS_PROCESSING,
                "processing_started_at": claim_started,
                "attempts": previous_attempts + 1,
            })
            .eq("event_id", event_id)
        )
        if previous_started is not None:
            claim_query = claim_query.eq("processing_started_at", previous_started)
        else:
            claim_query = claim_query.is_("processing_started_at", "null")
        claim = await asyncio.to_thread(claim_query.execute)
        claim_data = getattr(claim, "data", None)
        if claim_data is not None and not claim_data:
            return {"received": True, "duplicate": True}

    logger.info(f"Received Stripe event: {event['type']}")

    try:
        if event["type"] == "checkout.session.completed":
            session = event["data"]["object"]
            user_id = session.get("metadata", {}).get("user_id")
            plan_type = session.get("metadata", {}).get("plan_type", "pro_monthly")

            if user_id:
                stripe_customer_id = session.get("customer")
                stripe_subscription_id = session.get("subscription")

                # Checkout completion usually contains only the subscription
                # ID. Hydrate the Stripe subscription so price, status, dates,
                # and cancellation state are synchronized from Stripe. Keep a
                # metadata-based fallback for minimal historical/test payloads
                # that cannot provide subscription items. Only a string ID
                # needs retrieval: an already-expanded session.subscription
                # (StripeObject) flows to the sync path unchanged.
                expanded_subscription = session.get("subscription")
                if isinstance(stripe_subscription_id, str):
                    expanded_subscription = stripe.Subscription.retrieve(stripe_subscription_id)
                if _has_expanded_subscription_items(expanded_subscription):
                    await SubscriptionService.sync_stripe_subscription(
                        user_id,
                        expanded_subscription,
                        db,
                        plan_type_hint=PlanType(plan_type),
                    )
                else:
                    await SubscriptionService.upgrade_to_pro(
                        user_id=user_id,
                        plan_type=PlanType(plan_type),
                        stripe_customer_id=stripe_customer_id,
                        stripe_subscription_id=stripe_subscription_id,
                        db=db,
                    )
                logger.info(f"Activated {plan_type} subscription for user {user_id}")

        elif event["type"] == "customer.subscription.updated":
            subscription = event["data"]["object"]
            user_id = subscription.get("metadata", {}).get("user_id")

            if not user_id and subscription.get("id"):
                lookup = await asyncio.to_thread(
                    db.table("subscriptions")
                    .select("user_id")
                    .eq("stripe_subscription_id", subscription.get("id"))
                    .maybe_single()
                    .execute
                )
                lookup_data = maybe_single_data(lookup)
                user_id = lookup_data.get("user_id") if lookup_data else None

            if user_id:
                if _has_expanded_subscription_items(subscription):
                    await SubscriptionService.sync_stripe_subscription(
                        user_id, subscription, db
                    )
                elif subscription.get("cancel_at_period_end"):
                    # Backward-compatible handling for minimal webhook
                    # payloads that omit expanded subscription items.
                    await SubscriptionService.cancel_subscription(user_id, db)
                    logger.info(f"Subscription set to cancel for user {user_id}")

        elif event["type"] == "customer.subscription.deleted":
            subscription = event["data"]["object"]
            user_id = subscription.get("metadata", {}).get("user_id")

            if not user_id and subscription.get("id"):
                lookup = await asyncio.to_thread(
                    db.table("subscriptions")
                    .select("user_id")
                    .eq("stripe_subscription_id", subscription.get("id"))
                    .maybe_single()
                    .execute
                )
                lookup_data = maybe_single_data(lookup)
                user_id = lookup_data.get("user_id") if lookup_data else None

            if user_id:
                # Downgrade to free
                await asyncio.to_thread(db.table("subscriptions").update({
                    "plan_type": "free",
                    "status": "active",
                    "stripe_subscription_id": None,
                    "current_period_end": None,
                    "cancel_at_period_end": False,
                }).eq("user_id", user_id).execute)
                logger.info(f"Downgraded user {user_id} to free plan")

        elif event["type"] == "invoice.payment_failed":
            subscription_id = event["data"]["object"].get("subscription")

            if subscription_id:
                # Find user by subscription ID
                result = await asyncio.to_thread(db.table("subscriptions").select("user_id").eq(
                    "stripe_subscription_id", subscription_id
                ).maybe_single().execute)

                result_data = maybe_single_data(result)
                if result_data:
                    await asyncio.to_thread(db.table("subscriptions").update({
                        "status": "past_due",
                    }).eq("user_id", result_data["user_id"]).execute)
                    logger.info(f"Marked subscription as past_due for subscription {subscription_id}")

    except Exception as e:
        # Re-raise as a 500 so Stripe retries the event (per its exponential
        # backoff schedule) instead of treating a failed activation/cancellation
        # as delivered. Swallowing this and returning 200 previously meant a
        # customer could be charged without their subscription ever upgrading.
        logger.error(
            f"Error processing webhook event {event['type']}: {e}", exc_info=True
        )
        if event_id:
            try:
                await asyncio.to_thread(
                    db.table("stripe_webhook_events")
                    .update({"status": _WEBHOOK_STATUS_FAILED, "last_error": str(e)[:1000]})
                    .eq("event_id", event_id)
                    .eq("processing_started_at", claim_started)
                    .execute
                )
            except Exception:
                logger.error("Failed to record Stripe webhook failure", extra={"event_id": event_id})
        raise HTTPException(
            status_code=500,
            detail=f"Failed to process webhook event {event['type']}",
        )

    if event_id:
        await asyncio.to_thread(
            db.table("stripe_webhook_events")
            .update({"status": _WEBHOOK_STATUS_PROCESSED, "processed_at": utcnow_iso(), "last_error": None})
            .eq("event_id", event_id)
            .eq("processing_started_at", claim_started)
            .execute
        )
    return {"received": True}
