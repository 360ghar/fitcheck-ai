"""
Subscription service for managing user subscriptions and usage tracking.
"""
import logging
from datetime import datetime, date, timedelta
from typing import Optional
from dateutil.relativedelta import relativedelta

from supabase import Client

from app.core.config import settings
from app.core.exceptions import DatabaseError, NotFoundError, ServiceError
from app.models.subscription import (
    PlanType,
    SubscriptionStatus,
    SubscriptionResponse,
    UsageLimits,
    SubscriptionWithUsage,
    UsageCheckResult,
)

logger = logging.getLogger(__name__)


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
        else:
            return {
                "monthly_extractions": settings.PLAN_FREE_MONTHLY_EXTRACTIONS,
                "monthly_generations": settings.PLAN_FREE_MONTHLY_GENERATIONS,
                "monthly_embeddings": settings.PLAN_FREE_MONTHLY_EMBEDDINGS,
            }

    @staticmethod
    def is_pro_plan(plan_type: PlanType) -> bool:
        """Check if the plan type is a Pro plan."""
        return plan_type in (PlanType.PRO_MONTHLY, PlanType.PRO_YEARLY)

    # ==========================================================================
    # Subscription CRUD
    # ==========================================================================

    @staticmethod
    async def get_subscription(user_id: str, db: Client) -> SubscriptionResponse:
        """Get user's current subscription."""
        try:
            result = (
                db.table("subscriptions")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            )

            if not result.data:
                # Create a default free subscription if none exists
                logger.info(f"Creating default subscription for user {user_id}")
                await SubscriptionService.create_default_subscription(user_id, db)
                result = (
                    db.table("subscriptions")
                    .select("*")
                    .eq("user_id", user_id)
                    .maybe_single()
                    .execute()
                )

            if not result.data:
                raise DatabaseError("Subscription record could not be loaded after creation")

            data = result.data
            plan_type = PlanType(data.get("plan_type", "free"))

            return SubscriptionResponse(
                id=data["id"],
                user_id=data["user_id"],
                plan_type=plan_type,
                status=SubscriptionStatus(data.get("status", "active")),
                current_period_start=SubscriptionService._parse_datetime(data.get("current_period_start")) or datetime.utcnow(),
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
            db.table("subscriptions").upsert({
                "user_id": user_id,
                "plan_type": "free",
                "status": "active",
                "current_period_start": datetime.utcnow().isoformat(),
            }, on_conflict="user_id").execute()
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
            now = datetime.utcnow()

            # Calculate period end based on plan type
            if plan_type == PlanType.PRO_YEARLY:
                period_end = now + relativedelta(years=1)
            else:
                period_end = now + relativedelta(months=1)

            result = db.table("subscriptions").upsert({
                "user_id": user_id,
                "plan_type": plan_type.value,
                "status": "active",
                "current_period_start": now.isoformat(),
                "current_period_end": period_end.isoformat(),
                "stripe_customer_id": stripe_customer_id,
                "stripe_subscription_id": stripe_subscription_id,
                "cancel_at_period_end": False,
                "updated_at": now.isoformat(),
            }, on_conflict="user_id").execute()

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
            result = (
                db.table("subscriptions")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            )

            if not result.data:
                await SubscriptionService.create_default_subscription(user_id, db)
                result = (
                    db.table("subscriptions")
                    .select("*")
                    .eq("user_id", user_id)
                    .maybe_single()
                    .execute()
                )

            if not result.data:
                raise DatabaseError("Subscription record could not be loaded after creation")

            current_data = result.data
            current_credits = current_data.get("referral_credit_months", 0)

            # If user is on free plan, upgrade them to trial Pro
            if current_data.get("plan_type") == "free":
                now = datetime.utcnow()
                trial_end = now + relativedelta(months=months)

                db.table("subscriptions").update({
                    "plan_type": "pro_monthly",  # Give them Pro benefits
                    "status": "trial",
                    "trial_end": trial_end.isoformat(),
                    "referral_credit_months": current_credits + months,
                    "updated_at": now.isoformat(),
                }).eq("user_id", user_id).execute()
            else:
                # Just add to their credit balance
                db.table("subscriptions").update({
                    "referral_credit_months": current_credits + months,
                    "updated_at": datetime.utcnow().isoformat(),
                }).eq("user_id", user_id).execute()

            logger.info(f"Applied {months} referral credit months to user {user_id}")

        except Exception as e:
            logger.error(f"Error applying referral credit for user {user_id}: {e}")
            raise DatabaseError(f"Failed to apply referral credit: {str(e)}")

    @staticmethod
    async def cancel_subscription(user_id: str, db: Client) -> SubscriptionResponse:
        """Cancel subscription at period end."""
        try:
            db.table("subscriptions").update({
                "cancel_at_period_end": True,
                "updated_at": datetime.utcnow().isoformat(),
            }).eq("user_id", user_id).execute()

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
            result = db.table("subscription_usage").select("*").eq("user_id", user_id).eq("period_start", period_start.isoformat()).single().execute()

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

            db.table("subscription_usage").insert(new_record).execute()
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
                db.table("subscription_usage").insert(new_record).execute()
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
    async def check_limit(
        user_id: str,
        operation_type: str,
        db: Client,
        count: int = 1,
        _retry: bool = True,
    ) -> UsageCheckResult:
        """Check if user can perform an operation based on their plan limits."""
        try:
            subscription = await SubscriptionService.get_subscription(user_id, db)
            limits = SubscriptionService.get_plan_limits(subscription.plan_type)
            usage_record = await SubscriptionService.get_or_create_usage_record(user_id, db)

            # Map operation type to usage field
            field_map = {
                "extraction": ("monthly_extractions", "monthly_extractions"),
                "generation": ("monthly_generations", "monthly_generations"),
                "embedding": ("monthly_embeddings", "monthly_embeddings"),
            }

            if operation_type not in field_map:
                raise ValueError(f"Unknown operation type: {operation_type}")

            usage_field, limit_field = field_map[operation_type]
            current_count = usage_record.get(usage_field, 0)
            limit = limits.get(limit_field, 0)
            remaining = max(0, limit - current_count)

            allowed = (current_count + count) <= limit

            message = None
            if not allowed:
                plan_name = "Pro" if subscription.is_pro else "Free"
                message = f"You've reached your monthly {operation_type} limit ({limit}) on the {plan_name} plan. Upgrade to Pro for more!"

            return UsageCheckResult(
                allowed=allowed,
                current_count=current_count,
                limit=limit,
                remaining=remaining,
                plan_type=subscription.plan_type,
                message=message,
            )

        except Exception as e:
            error_str = str(e)
            # Retry once on connection errors (HTTP/2 connection terminated)
            if _retry and ("ConnectionTerminated" in error_str or "RemoteProtocolError" in error_str):
                logger.warning(f"Connection error for user {user_id}, retrying: {e}")
                from app.db.connection import SupabaseDB
                SupabaseDB._service_instance = None
                new_db = SupabaseDB.get_service_client()
                return await SubscriptionService.check_limit(
                    user_id, operation_type, new_db, count, _retry=False
                )
            logger.error(f"Error checking limit for user {user_id}: {e}")
            raise DatabaseError(f"Failed to check limit: {str(e)}")

    @staticmethod
    async def increment_usage(
        user_id: str,
        operation_type: str,
        db: Client,
        count: int = 1,
    ) -> None:
        """Increment usage counter for an operation."""
        try:
            period_start = SubscriptionService._get_current_period_start()

            # Ensure usage record exists
            await SubscriptionService.get_or_create_usage_record(user_id, db)

            # Map operation type to column
            column_map = {
                "extraction": "monthly_extractions",
                "generation": "monthly_generations",
                "embedding": "monthly_embeddings",
            }

            if operation_type not in column_map:
                raise ValueError(f"Unknown operation type: {operation_type}")

            column = column_map[operation_type]

            # Use atomic increment via RPC to prevent race conditions
            db.rpc("increment_usage", {
                "p_user_id": user_id,
                "p_period_start": period_start.isoformat(),
                "p_field": column,
                "p_count": count,
            }).execute()

            logger.debug(f"Incremented {operation_type} usage for user {user_id} by {count}")

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
