"""
Subscription API endpoints for managing user subscriptions and billing.
"""
import logging
from typing import Any, Dict, Optional

import stripe
from fastapi import APIRouter, Depends, Request, HTTPException, status
from supabase import Client

from app.api.v1.deps import get_current_user, get_db
from app.core.config import settings
from app.core.exceptions import ServiceError, ValidationError
from app.models.subscription import (
    PlanType,
    SubscriptionResponse,
    SubscriptionWithUsage,
    UsageLimits,
    CreateCheckoutRequest,
    CheckoutSessionResponse,
    PortalSessionResponse,
)
from app.services.subscription_service import SubscriptionService

logger = logging.getLogger(__name__)

router = APIRouter()


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

    Returns plan details for display on pricing pages.
    """
    free_limits = {
        "monthly_extractions": settings.PLAN_FREE_MONTHLY_EXTRACTIONS,
        "monthly_generations": settings.PLAN_FREE_MONTHLY_GENERATIONS,
        "monthly_embeddings": settings.PLAN_FREE_MONTHLY_EMBEDDINGS,
    }
    pro_limits = {
        "monthly_extractions": settings.PLAN_PRO_MONTHLY_EXTRACTIONS,
        "monthly_generations": settings.PLAN_PRO_MONTHLY_GENERATIONS,
        "monthly_embeddings": settings.PLAN_PRO_MONTHLY_EMBEDDINGS,
    }

    return {
        "data": {
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

    # Get the appropriate price ID
    if request.plan_type == PlanType.PRO_YEARLY:
        price_id = settings.STRIPE_PRO_YEARLY_PRICE_ID
    else:
        price_id = settings.STRIPE_PRO_MONTHLY_PRICE_ID

    if not price_id:
        raise ServiceError("Stripe price not configured. Please contact support.")

    try:
        # Get or create Stripe customer
        subscription = await SubscriptionService.get_subscription(user["id"], db)

        # Check existing stripe customer
        customer_id = None
        sub_result = (
            db.table("subscriptions")
            .select("stripe_customer_id")
            .eq("user_id", user["id"])
            .maybe_single()
            .execute()
        )

        if sub_result.data and sub_result.data.get("stripe_customer_id"):
            customer_id = sub_result.data["stripe_customer_id"]
        else:
            # Create new customer
            customer = stripe.Customer.create(
                email=user.get("email"),
                name=user.get("full_name"),
                metadata={"user_id": user["id"]},
            )
            customer_id = customer.id

            # Save customer ID
            db.table("subscriptions").update({
                "stripe_customer_id": customer_id,
            }).eq("user_id", user["id"]).execute()

        # Create checkout session
        checkout_session = stripe.checkout.Session.create(
            customer=customer_id,
            payment_method_types=["card"],
            line_items=[{"price": price_id, "quantity": 1}],
            mode="subscription",
            success_url=request.success_url,
            cancel_url=request.cancel_url,
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
    sub_result = (
        db.table("subscriptions")
        .select("stripe_customer_id")
        .eq("user_id", user["id"])
        .maybe_single()
        .execute()
    )

    if not sub_result.data or not sub_result.data.get("stripe_customer_id"):
        raise ValidationError("No billing account found. Please upgrade to Pro first.")

    try:
        portal_session = stripe.billing_portal.Session.create(
            customer=sub_result.data["stripe_customer_id"],
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
    sub_result = (
        db.table("subscriptions")
        .select("stripe_subscription_id")
        .eq("user_id", user["id"])
        .maybe_single()
        .execute()
    )

    if sub_result.data and sub_result.data.get("stripe_subscription_id") and settings.STRIPE_SECRET_KEY:
        try:
            stripe.api_key = settings.STRIPE_SECRET_KEY
            stripe.Subscription.modify(
                sub_result.data["stripe_subscription_id"],
                cancel_at_period_end=True,
            )
        except stripe.error.StripeError as e:
            logger.error(f"Error cancelling Stripe subscription: {e}")

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

    logger.info(f"Received Stripe event: {event['type']}")

    try:
        if event["type"] == "checkout.session.completed":
            session = event["data"]["object"]
            user_id = session.get("metadata", {}).get("user_id")
            plan_type = session.get("metadata", {}).get("plan_type", "pro_monthly")

            if user_id:
                stripe_customer_id = session.get("customer")
                stripe_subscription_id = session.get("subscription")

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

            if user_id:
                if subscription.get("cancel_at_period_end"):
                    await SubscriptionService.cancel_subscription(user_id, db)
                    logger.info(f"Subscription set to cancel for user {user_id}")

        elif event["type"] == "customer.subscription.deleted":
            subscription = event["data"]["object"]
            user_id = subscription.get("metadata", {}).get("user_id")

            if user_id:
                # Downgrade to free
                db.table("subscriptions").update({
                    "plan_type": "free",
                    "status": "active",
                    "stripe_subscription_id": None,
                    "current_period_end": None,
                    "cancel_at_period_end": False,
                }).eq("user_id", user_id).execute()
                logger.info(f"Downgraded user {user_id} to free plan")

        elif event["type"] == "invoice.payment_failed":
            subscription_id = event["data"]["object"].get("subscription")

            if subscription_id:
                # Find user by subscription ID
                result = db.table("subscriptions").select("user_id").eq(
                    "stripe_subscription_id", subscription_id
                ).maybe_single().execute()

                if result.data:
                    db.table("subscriptions").update({
                        "status": "past_due",
                    }).eq("user_id", result.data["user_id"]).execute()
                    logger.info(f"Marked subscription as past_due for subscription {subscription_id}")

    except Exception as e:
        logger.error(f"Error processing webhook event {event['type']}: {e}")
        # Don't raise - return 200 to acknowledge receipt

    return {"received": True}
