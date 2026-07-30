"""
Subscription service for managing user subscriptions and usage tracking.
"""
from datetime import datetime, date, timedelta
from typing import Optional, Union
from dateutil.relativedelta import relativedelta

import asyncio
import httpx
from supabase import Client

from app.core.config import settings
from app.core.exceptions import DatabaseError
from app.core.logging_config import get_context_logger
from app.models.subscription import (
    PlanType,
    OperationType,
    SubscriptionStatus,
    SubscriptionResponse,
    UsageLimits,
    SubscriptionWithUsage,
    UsageCheckResult,
)
from app.utils.datetime_util import utcnow, utcnow_iso
from app.utils import maybe_single_data

logger = get_context_logger(__name__)


class SubscriptionService:
    """Service for managing user subscriptions and usage."""

    @staticmethod
    def _parse_datetime(value: Optional[str]) -> Optional[datetime]:
        if not value:
            return None
        if isinstance(value, datetime):
            return value
        return datetime.fromisoformat(str(value).replace("Z", "+00:00"))

    # ==========================================================================
    # Plan Limit Helpers
    # ==========================================================================

    @staticmethod
    def get_plan_limits(plan_type: PlanType) -> dict:
        """Get the monthly limits for a given plan type."""
        if plan_type in (PlanType.PRO_MONTHLY, PlanType.PRO_YEARLY):
            return {
                "monthly_extractions": settings.PLAN_PRO_MONTHLY_EXTRACTIONS,
                "monthly_generations": settings.PLAN_PRO_MONTHLY_GENERATIONS,
                "monthly_embeddings": settings.PLAN_PRO_MONTHLY_EMBEDDINGS,
            }
        if plan_type in (PlanType.PLUS_MONTHLY, PlanType.PLUS_YEARLY):
            return {
                "monthly_extractions": settings.PLAN_PLUS_MONTHLY_EXTRACTIONS,
                "monthly_generations": settings.PLAN_PLUS_MONTHLY_GENERATIONS,
                "monthly_embeddings": settings.PLAN_PLUS_MONTHLY_EMBEDDINGS,
            }
        return {
            "monthly_extractions": settings.PLAN_FREE_MONTHLY_EXTRACTIONS,
            "monthly_generations": settings.PLAN_FREE_MONTHLY_GENERATIONS,
            "monthly_embeddings": settings.PLAN_FREE_MONTHLY_EMBEDDINGS,
        }

    # All plans that unlock Pro-level features. Plus has lower usage limits
    # than Pro (see get_plan_limits) but the SAME feature entitlement, so it
    # is treated as a paid/entitled plan everywhere features are gated.
    PAID_PLAN_TYPES = (
        PlanType.PLUS_MONTHLY,
        PlanType.PLUS_YEARLY,
        PlanType.PRO_MONTHLY,
        PlanType.PRO_YEARLY,
    )

    # Highest tier — nothing left to upsell. Distinct from PAID_PLAN_TYPES:
    # "has paid features" and "is on the top tier" are different questions now
    # that a middle tier exists, and conflating them either hides an upsell
    # from Plus users or offers Pro users an upgrade to the plan they're on.
    TOP_TIER_PLAN_TYPES = (PlanType.PRO_MONTHLY, PlanType.PRO_YEARLY)

    @staticmethod
    def is_paid_plan(plan_type: PlanType) -> bool:
        """True for any paid plan (Plus or Pro) — Pro-level features unlocked."""
        return plan_type in SubscriptionService.PAID_PLAN_TYPES

    @staticmethod
    def can_upgrade(plan_type: PlanType) -> bool:
        """True when a higher tier exists to upsell (Free and Plus)."""
        return plan_type not in SubscriptionService.TOP_TIER_PLAN_TYPES

    @staticmethod
    def is_pro_plan(plan_type: PlanType) -> bool:
        """Backward-compatible entitlement check.

        Plus unlocks the same features as Pro (only the usage limits differ),
        so it counts as entitled here. ``SubscriptionResponse.is_pro`` is
        derived from this and means "paid / Pro-feature-entitled".
        """
        return SubscriptionService.is_paid_plan(plan_type)

    @staticmethod
    def plan_display_name(plan_type: PlanType) -> str:
        """Human-readable plan name for messages/UI ("Free" / "Plus" / "Pro")."""
        value = plan_type.value if isinstance(plan_type, PlanType) else str(plan_type)
        if value.startswith("plus"):
            return "Plus"
        if value.startswith("pro"):
            return "Pro"
        return "Free"

    # ==========================================================================
    # Subscription CRUD
    # ==========================================================================

    @staticmethod
    async def get_subscription(user_id: str, db: Client) -> SubscriptionResponse:
        """Get user's current subscription."""
        try:
            result = await asyncio.to_thread(
                db.table("subscriptions")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute
            )

            data = maybe_single_data(result)
            if not data:
                # Create a default free subscription if none exists
                logger.info(f"Creating default subscription for user {user_id}")
                await SubscriptionService.create_default_subscription(user_id, db)
                result = await asyncio.to_thread(
                    db.table("subscriptions")
                    .select("*")
                    .eq("user_id", user_id)
                    .maybe_single()
                    .execute
                )
                data = maybe_single_data(result)

            if not data:
                raise DatabaseError("Subscription record could not be loaded after creation")

            plan_type = PlanType(data.get("plan_type", "free"))

            return SubscriptionResponse(
                id=data["id"],
                user_id=data["user_id"],
                plan_type=plan_type,
                status=SubscriptionStatus(data.get("status", "active")),
                current_period_start=SubscriptionService._parse_datetime(data.get("current_period_start")) or utcnow(),
                current_period_end=SubscriptionService._parse_datetime(data.get("current_period_end")),
                cancel_at_period_end=data.get("cancel_at_period_end", False),
                trial_end=SubscriptionService._parse_datetime(data.get("trial_end")),
                referral_credit_months=data.get("referral_credit_months", 0),
                created_at=SubscriptionService._parse_datetime(data.get("created_at")),
                updated_at=SubscriptionService._parse_datetime(data.get("updated_at")),
                is_pro=SubscriptionService.is_pro_plan(plan_type),
            )
        except Exception as e:
            logger.error(f"Error getting subscription for user {user_id}: {e}")
            raise DatabaseError(f"Failed to get subscription: {str(e)}")

    @staticmethod
    async def create_default_subscription(user_id: str, db: Client) -> None:
        """Create a default free subscription for a user."""
        try:
            await asyncio.to_thread(db.table("subscriptions").upsert({
                "user_id": user_id,
                "plan_type": "free",
                "status": "active",
                "current_period_start": utcnow_iso(),
            }, on_conflict="user_id").execute)
        except Exception as e:
            logger.error(f"Error creating default subscription for user {user_id}: {e}")
            raise DatabaseError(f"Failed to create subscription: {str(e)}")

    @staticmethod
    async def upgrade_to_pro(
        user_id: str,
        plan_type: PlanType,
        stripe_customer_id: str,
        stripe_subscription_id: str,
        db: Client,
    ) -> SubscriptionResponse:
        """Upgrade user to Pro plan after successful Stripe payment."""
        try:
            now = utcnow()

            # Calculate period end based on plan type (any *_yearly plan = 1 year)
            if plan_type.value.endswith("_yearly"):
                period_end = now + relativedelta(years=1)
            else:
                period_end = now + relativedelta(months=1)

            await asyncio.to_thread(db.table("subscriptions").upsert({
                "user_id": user_id,
                "plan_type": plan_type.value,
                "status": "active",
                "current_period_start": now.isoformat(),
                "current_period_end": period_end.isoformat(),
                "stripe_customer_id": stripe_customer_id,
                "stripe_subscription_id": stripe_subscription_id,
                "cancel_at_period_end": False,
                "updated_at": now.isoformat(),
            }, on_conflict="user_id").execute)

            logger.info(f"User {user_id} upgraded to {plan_type.value}")
            return await SubscriptionService.get_subscription(user_id, db)

        except Exception as e:
            logger.error(f"Error upgrading subscription for user {user_id}: {e}")
            raise DatabaseError(f"Failed to upgrade subscription: {str(e)}")

    @staticmethod
    async def apply_referral_credit(user_id: str, months: int, db: Client) -> None:
        """Apply referral credit months to a user's subscription."""
        try:
            # Get current subscription
            result = await asyncio.to_thread(
                db.table("subscriptions")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute
            )

            current_data = maybe_single_data(result)
            if not current_data:
                await SubscriptionService.create_default_subscription(user_id, db)
                result = await asyncio.to_thread(
                    db.table("subscriptions")
                    .select("*")
                    .eq("user_id", user_id)
                    .maybe_single()
                    .execute
                )
                current_data = maybe_single_data(result)

            if not current_data:
                raise DatabaseError("Subscription record could not be loaded after creation")

            current_credits = current_data.get("referral_credit_months", 0)

            # If user is on free plan, upgrade them to trial Pro
            if current_data.get("plan_type") == "free":
                now = utcnow()
                trial_end = now + relativedelta(months=months)

                await asyncio.to_thread(db.table("subscriptions").update({
                    "plan_type": "pro_monthly",  # Give them Pro benefits
                    "status": "trial",
                    "trial_end": trial_end.isoformat(),
                    "referral_credit_months": current_credits + months,
                    "updated_at": now.isoformat(),
                }).eq("user_id", user_id).execute)
            else:
                # Just add to their credit balance
                await asyncio.to_thread(db.table("subscriptions").update({
                    "referral_credit_months": current_credits + months,
                    "updated_at": utcnow_iso(),
                }).eq("user_id", user_id).execute)

            logger.info(f"Applied {months} referral credit months to user {user_id}")

        except Exception as e:
            logger.error(f"Error applying referral credit for user {user_id}: {e}")
            raise DatabaseError(f"Failed to apply referral credit: {str(e)}")

    @staticmethod
    async def cancel_subscription(user_id: str, db: Client) -> SubscriptionResponse:
        """Cancel subscription at period end."""
        try:
            await asyncio.to_thread(db.table("subscriptions").update({
                "cancel_at_period_end": True,
                "updated_at": utcnow_iso(),
            }).eq("user_id", user_id).execute)

            logger.info(f"Subscription cancelled for user {user_id}")
            return await SubscriptionService.get_subscription(user_id, db)

        except Exception as e:
            logger.error(f"Error cancelling subscription for user {user_id}: {e}")
            raise DatabaseError(f"Failed to cancel subscription: {str(e)}")

    # ==========================================================================
    # Usage Tracking
    # ==========================================================================

    @staticmethod
    def _get_current_period_start() -> date:
        """Get the start of the current billing period (first of the month)."""
        today = date.today()
        return date(today.year, today.month, 1)

    @staticmethod
    def _get_current_period_end() -> date:
        """Get the end of the current billing period (last day of the month)."""
        today = date.today()
        next_month = today + relativedelta(months=1)
        return date(next_month.year, next_month.month, 1) - timedelta(days=1)

    @staticmethod
    async def get_or_create_usage_record(user_id: str, db: Client) -> dict:
        """Get or create the usage record for the current billing period."""
        period_start = SubscriptionService._get_current_period_start()

        try:
            result = await asyncio.to_thread(db.table("subscription_usage").select("*").eq("user_id", user_id).eq("period_start", period_start.isoformat()).single().execute)

            if result.data:
                return result.data

            # Create new usage record for this period
            new_record = {
                "user_id": user_id,
                "period_start": period_start.isoformat(),
                "monthly_extractions": 0,
                "monthly_generations": 0,
                "monthly_embeddings": 0,
            }

            await asyncio.to_thread(db.table("subscription_usage").insert(new_record).execute)
            return new_record

        except Exception as e:
            if "PGRST116" in str(e):  # No rows returned
                # Create new usage record
                new_record = {
                    "user_id": user_id,
                    "period_start": period_start.isoformat(),
                    "monthly_extractions": 0,
                    "monthly_generations": 0,
                    "monthly_embeddings": 0,
                }
                await asyncio.to_thread(db.table("subscription_usage").insert(new_record).execute)
                return new_record
            raise

    @staticmethod
    async def get_usage(user_id: str, db: Client) -> UsageLimits:
        """Get user's current monthly usage and limits."""
        try:
            # Get subscription to determine plan limits
            subscription = await SubscriptionService.get_subscription(user_id, db)
            limits = SubscriptionService.get_plan_limits(subscription.plan_type)

            # Get current usage
            usage_record = await SubscriptionService.get_or_create_usage_record(user_id, db)

            used_extractions = usage_record.get("monthly_extractions", 0)
            used_generations = usage_record.get("monthly_generations", 0)
            used_embeddings = usage_record.get("monthly_embeddings", 0)

            return UsageLimits(
                monthly_extractions_limit=limits["monthly_extractions"],
                monthly_generations_limit=limits["monthly_generations"],
                monthly_embeddings_limit=limits["monthly_embeddings"],
                monthly_extractions=used_extractions,
                monthly_generations=used_generations,
                monthly_embeddings=used_embeddings,
                monthly_extractions_remaining=max(0, limits["monthly_extractions"] - used_extractions),
                monthly_generations_remaining=max(0, limits["monthly_generations"] - used_generations),
                monthly_embeddings_remaining=max(0, limits["monthly_embeddings"] - used_embeddings),
                period_start=SubscriptionService._get_current_period_start(),
                period_end=SubscriptionService._get_current_period_end(),
            )

        except Exception as e:
            logger.error(f"Error getting usage for user {user_id}: {e}")
            raise DatabaseError(f"Failed to get usage: {str(e)}")

    @staticmethod
    def _coerce_operation_type(operation_type: Union[OperationType, str]) -> OperationType:
        """Normalize an operation type to OperationType.

        Strings and OperationType members are both accepted at the boundary so
        existing callers (which pass bare literals like "extraction") keep
        working. Unknown values raise ValueError instead of silently branching
        into a fallback.
        """
        try:
            return OperationType(operation_type)
        except ValueError as exc:
            raise ValueError(f"Unknown operation type: {operation_type}") from exc

    @staticmethod
    async def check_limit(
        user_id: str,
        operation_type: Union[OperationType, str],
        db: Client,
        count: int = 1,
        _retry: bool = True,
    ) -> UsageCheckResult:
        """Check if user can perform an operation based on their plan limits."""
        try:
            op = SubscriptionService._coerce_operation_type(operation_type)
            subscription = await SubscriptionService.get_subscription(user_id, db)
            limits = SubscriptionService.get_plan_limits(subscription.plan_type)
            usage_record = await SubscriptionService.get_or_create_usage_record(user_id, db)

            # Map operation type to usage field
            field_map = {
                OperationType.EXTRACTION: ("monthly_extractions", "monthly_extractions"),
                OperationType.GENERATION: ("monthly_generations", "monthly_generations"),
                OperationType.EMBEDDING: ("monthly_embeddings", "monthly_embeddings"),
            }

            usage_field, limit_field = field_map[op]
            current_count = usage_record.get(usage_field, 0)
            limit = limits.get(limit_field, 0)
            remaining = max(0, limit - current_count)

            allowed = (current_count + count) <= limit

            message = None
            if not allowed:
                plan_name = SubscriptionService.plan_display_name(subscription.plan_type)
                message = (
                    f"You've reached your monthly {op.value} limit ({limit}) "
                    f"on the {plan_name} plan."
                )
                # Only upsell when a higher tier actually exists - a Pro user
                # at their cap must not be told to "upgrade to Pro".
                if SubscriptionService.can_upgrade(subscription.plan_type):
                    message += " Upgrade to Pro for more!"
                else:
                    message += " Your limit resets at the start of the next billing period."

            return UsageCheckResult(
                allowed=allowed,
                current_count=current_count,
                limit=limit,
                remaining=remaining,
                plan_type=subscription.plan_type,
                message=message,
            )

        except Exception as e:
            # Retry once on a dead pooled HTTP/2 connection - matches
            # ai_provider_service.py's isinstance-based check for the same
            # error class, instead of fragile string-matching on str(e)
            # (which silently stops working if the wrapped exception's
            # repr format ever changes).
            if _retry and isinstance(e, httpx.RemoteProtocolError):
                logger.warning(f"Connection error for user {user_id}, retrying: {e}")
                from app.db.connection import SupabaseDB
                SupabaseDB.reset()
                new_db = SupabaseDB.get_service_client()
                return await SubscriptionService.check_limit(
                    user_id, operation_type, new_db, count, _retry=False
                )
            logger.error(f"Error checking limit for user {user_id}: {e}")
            raise DatabaseError(f"Failed to check limit: {str(e)}")

    @staticmethod
    async def increment_usage(
        user_id: str,
        operation_type: Union[OperationType, str],
        db: Client,
        count: int = 1,
    ) -> None:
        """Increment usage counter for an operation."""
        try:
            op = SubscriptionService._coerce_operation_type(operation_type)
            period_start = SubscriptionService._get_current_period_start()

            # Ensure usage record exists
            await SubscriptionService.get_or_create_usage_record(user_id, db)

            # Map operation type to column
            column_map = {
                OperationType.EXTRACTION: "monthly_extractions",
                OperationType.GENERATION: "monthly_generations",
                OperationType.EMBEDDING: "monthly_embeddings",
            }

            column = column_map[op]

            # Use atomic increment via RPC to prevent race conditions
            await asyncio.to_thread(db.rpc("increment_usage", {
                "p_user_id": user_id,
                "p_period_start": period_start.isoformat(),
                "p_field": column,
                "p_count": count,
            }).execute)

            logger.debug(f"Incremented {op.value} usage for user {user_id} by {count}")

        except Exception as e:
            logger.error(f"Error incrementing usage for user {user_id}: {e}")
            # Don't raise - usage tracking failure shouldn't block the operation

    # ==========================================================================
    # Combined Methods
    # ==========================================================================

    @staticmethod
    async def get_subscription_with_usage(user_id: str, db: Client) -> SubscriptionWithUsage:
        """Get subscription and usage in one call."""
        subscription = await SubscriptionService.get_subscription(user_id, db)
        usage = await SubscriptionService.get_usage(user_id, db)

        return SubscriptionWithUsage(
            subscription=subscription,
            usage=usage,
        )
