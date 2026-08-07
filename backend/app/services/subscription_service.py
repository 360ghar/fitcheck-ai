"""
Subscription service for managing user subscriptions and usage tracking.
"""
from datetime import datetime, date, timedelta
from typing import Any, Dict, Optional, Union
from dateutil.relativedelta import relativedelta

import asyncio
from supabase import Client

from app.core.config import settings
from app.core.exceptions import AIServiceError, DatabaseError, RateLimitError
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
from app.utils.datetime_util import parse_utc_datetime, utcnow, utcnow_iso
from app.utils.db import (
    QUOTA_UNAVAILABLE_CLIENT_MESSAGE,
    execute_with_reconnect,
    is_db_connection_error,
    is_pgrst202_missing_rpc,
    missing_rpc_log_hint,
    unwrap_rpc_bool,
)
from app.utils import maybe_single_data

logger = get_context_logger(__name__)


class SubscriptionService:
    """Service for managing user subscriptions and usage."""

    @staticmethod
    def _parse_datetime(value: Optional[str]) -> Optional[datetime]:
        # Delegates to the shared helper so every module parses ISO timestamps
        # the same way (Z suffix, naive strings, aware non-UTC -> UTC).
        return parse_utc_datetime(value)

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
    def stripe_price_plan_map() -> dict[str, PlanType]:
        # Unset price IDs must not map: with several None keys the last one
        # (PRO_YEARLY) would win and a missing price ID would silently
        # classify as Pro instead of raising the unknown-price error.
        return {
            price_id: plan_type
            for price_id, plan_type in (
                (settings.STRIPE_PLUS_MONTHLY_PRICE_ID, PlanType.PLUS_MONTHLY),
                (settings.STRIPE_PLUS_YEARLY_PRICE_ID, PlanType.PLUS_YEARLY),
                (settings.STRIPE_PRO_MONTHLY_PRICE_ID, PlanType.PRO_MONTHLY),
                (settings.STRIPE_PRO_YEARLY_PRICE_ID, PlanType.PRO_YEARLY),
            )
            if price_id
        }

    @classmethod
    def effective_plan_type(
        cls,
        plan_type: PlanType,
        status: SubscriptionStatus,
        current_period_end: Optional[datetime],
        trial_end: Optional[datetime],
        now: Optional[datetime] = None,
    ) -> PlanType:
        """Return the plan whose entitlements are currently valid."""
        if not cls.is_paid_plan(plan_type):
            return PlanType.FREE

        check_at = now or utcnow()
        if status == SubscriptionStatus.TRIAL:
            entitled_until = trial_end
        elif status == SubscriptionStatus.ACTIVE:
            entitled_until = current_period_end
        else:
            return PlanType.FREE

        if entitled_until is None:
            return PlanType.FREE
        if entitled_until.tzinfo is None:
            entitled_until = entitled_until.replace(tzinfo=check_at.tzinfo)
        return plan_type if entitled_until > check_at else PlanType.FREE

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
    def _response_from_row(data: Dict[str, Any]) -> SubscriptionResponse:
        """Build the API response from a ``subscriptions`` row.

        Shared by the read path (``get_subscription``) and the write paths
        (webhook syncs), which receive the upserted/updated row from
        PostgREST and would otherwise re-fetch it for the same transformation.
        ``effective_plan_type`` applies the entitlement rules (trial/period
        expiry) exactly as the read path does.
        """
        stored_plan_type = PlanType(data.get("plan_type", "free"))
        status = SubscriptionStatus(data.get("status", "active"))
        current_period_end = SubscriptionService._parse_datetime(data.get("current_period_end"))
        trial_end = SubscriptionService._parse_datetime(data.get("trial_end"))
        plan_type = SubscriptionService.effective_plan_type(
            stored_plan_type,
            status,
            current_period_end,
            trial_end,
        )

        return SubscriptionResponse(
            id=data["id"],
            user_id=data["user_id"],
            plan_type=plan_type,
            status=status,
            current_period_start=SubscriptionService._parse_datetime(data.get("current_period_start")) or utcnow(),
            current_period_end=current_period_end,
            cancel_at_period_end=data.get("cancel_at_period_end", False),
            trial_end=trial_end,
            referral_credit_months=data.get("referral_credit_months", 0),
            billing_provider=data.get("billing_provider", "stripe"),
            created_at=SubscriptionService._parse_datetime(data.get("created_at")),
            updated_at=SubscriptionService._parse_datetime(data.get("updated_at")),
            is_pro=SubscriptionService.is_pro_plan(plan_type),
        )

    @staticmethod
    async def get_subscription(user_id: str, db: Client) -> SubscriptionResponse:
        """Get user's current subscription."""
        try:
            result = await execute_with_reconnect(
                lambda d: d.table("subscriptions")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute(),
                db,
                extra={"operation": "get_subscription", "user_id": user_id},
                max_retries=2,
            )

            data = maybe_single_data(result)
            if not data:
                # Create a default free subscription if none exists
                logger.info(f"Creating default subscription for user {user_id}")
                await SubscriptionService.create_default_subscription(user_id, db)
                result = await execute_with_reconnect(
                    lambda d: d.table("subscriptions")
                    .select("*")
                    .eq("user_id", user_id)
                    .maybe_single()
                    .execute(),
                    db,
                    extra={"operation": "get_subscription.after_create", "user_id": user_id},
                    max_retries=2,
                )
                data = maybe_single_data(result)

            if not data:
                raise DatabaseError("Subscription record could not be loaded after creation")

            return SubscriptionService._response_from_row(data)
        except Exception as e:
            logger.error(f"Error getting subscription for user {user_id}: {e}")
            raise DatabaseError(f"Failed to get subscription: {str(e)}")

    @staticmethod
    async def create_default_subscription(user_id: str, db: Client) -> None:
        """Create a default free subscription for a user."""
        try:
            # on_conflict upsert is idempotent, so the reconnect retry is
            # exact-once safe even if the first attempt committed server-side.
            await execute_with_reconnect(
                lambda d: d.table("subscriptions").upsert({
                    "user_id": user_id,
                    "plan_type": "free",
                    "status": "active",
                    "current_period_start": utcnow_iso(),
                }, on_conflict="user_id").execute(),
                db,
                extra={"operation": "create_default_subscription", "user_id": user_id},
            )
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

    @classmethod
    async def sync_stripe_subscription(
        cls,
        user_id: str,
        stripe_subscription: object,
        db: Client,
        *,
        plan_type_hint: Optional[PlanType] = None,
    ) -> SubscriptionResponse:
        """Synchronize the local subscription from one Stripe subscription.

        Stripe is the source of truth for the price, status, period dates, and
        cancellation flag. Webhooks can deliver either StripeObject instances
        or plain dictionaries, so this deliberately uses the common mapping /
        attribute surface.
        """
        def value(obj: object, key: str, default=None):
            if isinstance(obj, dict):
                return obj.get(key, default)
            return getattr(obj, key, default)

        def timestamp(value_to_parse) -> Optional[str]:
            if value_to_parse is None:
                return None
            try:
                return datetime.fromtimestamp(float(value_to_parse), tz=utcnow().tzinfo).isoformat()
            except (TypeError, ValueError, OSError):
                return None

        items = value(value(stripe_subscription, "items", {}), "data", []) or []
        first_item = items[0] if items else None
        price = value(first_item, "price", {}) if first_item else {}
        price_id = price if isinstance(price, str) else value(price, "id")
        # Stripe is authoritative: accept a plan only from the configured
        # price map. A changed/stale price must fail closed (raise below)
        # instead of granting a metadata-based entitlement. The minimal-payload
        # path (upgrade_to_pro) does not pass a hint.
        plan_type = cls.stripe_price_plan_map().get(price_id)
        if plan_type is None:
            raise DatabaseError(
                f"Stripe subscription {value(stripe_subscription, 'id', 'unknown')} has an unknown price; billing sync requires a configured price ID"
            )

        stripe_status = str(value(stripe_subscription, "status", "active")).lower()
        status_map = {
            "active": SubscriptionStatus.ACTIVE,
            "trialing": SubscriptionStatus.TRIAL,
            "past_due": SubscriptionStatus.PAST_DUE,
            "canceled": SubscriptionStatus.CANCELLED,
            "cancelled": SubscriptionStatus.CANCELLED,
            "unpaid": SubscriptionStatus.PAST_DUE,
            "incomplete": SubscriptionStatus.PAST_DUE,
            "incomplete_expired": SubscriptionStatus.CANCELLED,
        }
        status = status_map.get(stripe_status, SubscriptionStatus.PAST_DUE)
        now = utcnow()
        incoming_id = value(stripe_subscription, "id")
        incoming_period_end = cls._parse_datetime(
            timestamp(value(stripe_subscription, "current_period_end"))
        )

        # Stripe retries deliveries and does not guarantee ordering, so a
        # delayed snapshot can arrive after a newer one was already applied.
        # Refuse to regress the local entitlement: a snapshot for a replaced
        # Stripe subscription (different ID) or with an older period end than
        # the row we already recorded is stale and must not overwrite it.
        existing_result = await asyncio.to_thread(
            db.table("subscriptions")
            .select("stripe_subscription_id,current_period_end")
            .eq("user_id", user_id)
            .maybe_single()
            .execute
        )
        existing = maybe_single_data(existing_result)
        if existing:
            existing_sub_id = existing.get("stripe_subscription_id")
            if existing_sub_id and incoming_id and existing_sub_id != incoming_id:
                logger.info(
                    "Skipping Stripe snapshot for replaced subscription",
                    user_id=user_id,
                    incoming_subscription_id=incoming_id,
                    existing_subscription_id=existing_sub_id,
                )
                return await cls.get_subscription(user_id, db)
            existing_period_end = cls._parse_datetime(existing.get("current_period_end"))
            if existing_period_end and incoming_period_end and existing_period_end > incoming_period_end:
                logger.info(
                    "Skipping stale Stripe snapshot with older period end",
                    user_id=user_id,
                    incoming_subscription_id=incoming_id,
                    existing_period_end=existing_period_end.isoformat(),
                    incoming_period_end=incoming_period_end.isoformat(),
                )
                return await cls.get_subscription(user_id, db)

        payload = {
            "user_id": user_id,
            "plan_type": plan_type.value,
            "status": status.value,
            "stripe_customer_id": value(stripe_subscription, "customer"),
            "stripe_subscription_id": value(stripe_subscription, "id"),
            "current_period_start": timestamp(value(stripe_subscription, "current_period_start")) or now.isoformat(),
            "current_period_end": timestamp(value(stripe_subscription, "current_period_end")),
            "trial_end": timestamp(value(stripe_subscription, "trial_end")),
            "cancel_at_period_end": bool(value(stripe_subscription, "cancel_at_period_end", False)),
            "updated_at": now.isoformat(),
        }
        upsert_result = await asyncio.to_thread(
            db.table("subscriptions").upsert(payload, on_conflict="user_id").execute
        )
        logger.info(
            "Synchronized Stripe subscription",
            user_id=user_id,
            stripe_subscription_id=payload["stripe_subscription_id"],
            plan_type=plan_type.value,
            status=status.value,
        )
        # The upsert response already carries the row; building the response
        # from it avoids a re-read SELECT per webhook. Fall back to the read
        # path if the client returned no row (defensive; PostgREST returns the
        # affected rows for on_conflict upserts).
        upserted_rows = getattr(upsert_result, "data", None) or []
        if upserted_rows:
            return cls._response_from_row(upserted_rows[0])
        return await cls.get_subscription(user_id, db)

    @classmethod
    async def sync_iap_subscription(
        cls,
        user_id: str,
        db: Client,
        *,
        provider: str,
        plan_type: PlanType,
        status: str,
        current_period_start: Optional[str] = None,
        current_period_end: Optional[str] = None,
        cancel_at_period_end: Optional[bool] = False,
        product_id: Optional[str] = None,
        apple_original_transaction_id: Optional[str] = None,
        google_purchase_token: Optional[str] = None,
        google_order_id: Optional[str] = None,
        now: Optional[datetime] = None,
    ) -> SubscriptionResponse:
        """Synchronize the local subscription from a store-verified purchase.

        ``provider`` must be "apple" or "google"; the row's billing_provider
        becomes that store, and the other stores' identity columns are cleared
        so a stale Stripe/other-store snapshot can never be applied on top.

        ``status`` accepts the normalized store states: "active" (entitled),
        "past_due" (payment problem, keep plan but flag), or "free" (expired /
        refunded / revoked — downgrade to the free plan). Anything else fails
        closed rather than inventing an entitlement.

        Guards against regressions mirroring sync_stripe_subscription: an
        incoming period end older than the row already records is stale and
        must not overwrite a newer snapshot.
        """
        if provider not in ("apple", "google"):
            raise DatabaseError(f"Unknown billing provider: {provider}")
        if not SubscriptionService.is_paid_plan(plan_type):
            raise DatabaseError(f"Store billing cannot map to plan {plan_type.value}")

        check_at = now or utcnow()

        # Store-verified "free" means the store refunded/expired the purchase.
        # Downgrade to the free plan but KEEP the owning store's transaction
        # identity: later notifications (renewal after resubscribe, refund
        # follow-ups) resolve the user via apple_original_transaction_id /
        # google_purchase_token, and wiping it would orphan the row from the
        # webhook ledger. Only a NEW store purchase (the upsert path below)
        # clears and replaces identity.
        if status == "free":
            # A REFUND/REVOKE/EXPIRED notification can arrive for a SUPERSEDED
            # transaction: the row now carries a NEWER store identifier because
            # the user resubscribed (same App Store / Play account after a
            # refund). The webhook resolves the user via the appAccountToken
            # fallback, so the downgrade below would kill the CURRENT active
            # subscription. When the incoming identifier is known and differs
            # from the one the row owns, this notification is stale — skip the
            # downgrade entirely. A None on either side keeps the legacy
            # behavior (downgrade): the caller had no identifier to compare.
            if apple_original_transaction_id or google_purchase_token:
                identity = maybe_single_data(
                    await asyncio.to_thread(
                        db.table("subscriptions")
                        .select("apple_original_transaction_id,google_purchase_token")
                        .eq("user_id", user_id)
                        .maybe_single()
                        .execute
                    )
                )
                if identity:
                    stale = False
                    if provider == "apple" and apple_original_transaction_id:
                        row_id = identity.get("apple_original_transaction_id")
                        stale = row_id is not None and row_id != apple_original_transaction_id
                    elif provider == "google" and google_purchase_token:
                        row_id = identity.get("google_purchase_token")
                        stale = row_id is not None and row_id != google_purchase_token
                    if stale:
                        logger.info(
                            "Ignoring stale store refund/revocation for superseded transaction",
                            user_id=user_id,
                            provider=provider,
                            incoming_identifier=(
                                apple_original_transaction_id or google_purchase_token
                            ),
                        )
                        return await cls.get_subscription(user_id, db)

            downgrade_payload = {
                "plan_type": "free",
                "status": "active",
                "billing_provider": provider,
                "current_period_end": None,
                "cancel_at_period_end": False,
                "billing_product_id": None,
                "updated_at": check_at.isoformat(),
            }
            if provider == "apple":
                # A replaced rail's identity (if any) is stale; keep only the
                # owning store's.
                downgrade_payload["google_purchase_token"] = None
                downgrade_payload["google_order_id"] = None
            elif provider == "google":  # pragma: no cover - provider validated apple/google at entry, so the elif can never be false
                downgrade_payload["apple_original_transaction_id"] = None
            downgrade_result = await asyncio.to_thread(
                db.table("subscriptions")
                .update(downgrade_payload)
                .eq("user_id", user_id)
                .execute
            )
            logger.info(
                "Store purchase expired/refunded; downgraded to free",
                user_id=user_id,
                provider=provider,
                plan_type=plan_type.value,
            )
            # The update response carries the row (see the sync tail below);
            # fall back to the read path only if it does not.
            downgraded_rows = getattr(downgrade_result, "data", None) or []
            if downgraded_rows:
                return cls._response_from_row(downgraded_rows[0])
            return await cls.get_subscription(user_id, db)

        status_map = {
            "active": SubscriptionStatus.ACTIVE,
            "past_due": SubscriptionStatus.PAST_DUE,
        }
        if status not in status_map:
            raise DatabaseError(
                f"Unknown store entitlement status '{status}'; refusing to grant"
            )
        stored_status = status_map[status]

        existing_result = await asyncio.to_thread(
            db.table("subscriptions")
            .select(
                "current_period_start,current_period_end,"
                "billing_provider,billing_product_id"
            )
            .eq("user_id", user_id)
            .maybe_single()
            .execute
        )
        existing = maybe_single_data(existing_result)
        if existing:
            # Staleness is decided by PURCHASE RECENCY, not by period end.
            #
            # An upgrade can legitimately SHORTEN the period (Plus yearly ->
            # Pro monthly): Apple ends the old subscription immediately and
            # starts a new, shorter one. A period-end comparison reads that as
            # stale and silently drops the upgrade — the exact flow App Review
            # exercises. current_period_start carries the store's purchaseDate,
            # which only ever moves forward, so it is the correct discriminator.
            #
            # It also fixes the mirror hazard the end rule could not: after an
            # upgrade Apple shortens the OLD transaction's expiresDate, and an
            # out-of-order notification for that old transaction still carries
            # signedTransactionInfo. Its later expiresDate would otherwise
            # overwrite the new plan.
            same_provider = existing.get("billing_provider") == provider
            existing_start = cls._parse_datetime(existing.get("current_period_start"))
            incoming_start = (
                cls._parse_datetime(current_period_start) if current_period_start else None
            )
            existing_end = cls._parse_datetime(existing.get("current_period_end"))
            incoming_end = (
                cls._parse_datetime(current_period_end) if current_period_end else None
            )
            stored_product = existing.get("billing_product_id")
            # None means "unknown" (a pre-IAP row): fall back to the
            # conservative period-end rule rather than assuming a plan change.
            same_product = stored_product is None or stored_product == product_id

            # A strictly NEWER purchase date is a different, later transaction:
            # always apply it, whatever it does to the period end.
            is_newer_purchase = (
                existing_start is not None
                and incoming_start is not None
                and incoming_start > existing_start
            )
            # A strictly OLDER one is a late-arriving snapshot of a superseded
            # transaction: never apply it.
            is_older_purchase = (
                existing_start is not None
                and incoming_start is not None
                and incoming_start < existing_start
            )

            if same_provider and is_older_purchase:
                logger.info(
                    "Skipping stale store snapshot with older purchase date",
                    user_id=user_id,
                    provider=provider,
                    existing_period_start=existing_start.isoformat(),
                    incoming_period_start=incoming_start.isoformat(),
                )
                return await cls.get_subscription(user_id, db)

            # Equal or unknown purchase dates mean "same subscription, another
            # snapshot of it", so the period-end rule still decides. This is
            # the normal case on Google, where startTimeMillis is the ORIGINAL
            # subscription start and stays constant across renewals — dropping
            # the end rule there would let a stale renewal snapshot roll
            # current_period_end backwards.
            if (
                same_provider
                and not is_newer_purchase
                and same_product
                and existing_end
                and incoming_end
                and existing_end > incoming_end
            ):
                logger.info(
                    "Skipping stale store snapshot with older period end",
                    user_id=user_id,
                    provider=provider,
                    existing_period_end=existing_end.isoformat(),
                    incoming_period_end=incoming_end.isoformat(),
                )
                return await cls.get_subscription(user_id, db)

        payload = {
            "user_id": user_id,
            "plan_type": plan_type.value,
            "status": stored_status.value,
            "billing_provider": provider,
            "current_period_start": current_period_start or check_at.isoformat(),
            "current_period_end": current_period_end,
            "billing_product_id": product_id,
            # Only the owning store's identity is kept; the others are
            # cleared so a stale snapshot from a replaced rail cannot match.
            "apple_original_transaction_id": (
                apple_original_transaction_id if provider == "apple" else None
            ),
            "google_purchase_token": (
                google_purchase_token if provider == "google" else None
            ),
            "google_order_id": google_order_id if provider == "google" else None,
            "stripe_customer_id": None,
            "stripe_subscription_id": None,
            "updated_at": check_at.isoformat(),
        }

        # None means "this payload does not say" — leave the stored flag alone.
        # Only the App Store Server Notification carries autoRenewStatus, so a
        # Restore Purchases (which re-registers the same transaction with no
        # renewal info) would otherwise clear a cancellation the user really
        # made. Omitting the column from the upsert preserves it on an existing
        # row and falls back to the schema default FALSE on a new one.
        if cancel_at_period_end is not None:
            payload["cancel_at_period_end"] = cancel_at_period_end

        # One store transaction belongs to exactly one account at a time. A
        # downgraded row keeps its store identity on purpose (see the "free"
        # branch above), so the same store account resubscribing under a
        # different FitCheck account would leave TWO rows carrying one
        # identifier — and the webhook's identifier lookup (iap.py
        # `_user_id_for_store_purchase`) would then have to guess. Strip the
        # identifier from every OTHER user's row as this one claims it: the
        # retention intent is preserved for the owning row, and the lookup stays
        # single-valued.
        claimed_identifier = (
            apple_original_transaction_id
            if provider == "apple"
            else google_purchase_token
        )
        identity_column = (
            "apple_original_transaction_id"
            if provider == "apple"
            else "google_purchase_token"
        )
        if claimed_identifier:
            try:
                released = await asyncio.to_thread(
                    db.table("subscriptions")
                    .update({identity_column: None, "updated_at": check_at.isoformat()})
                    .eq(identity_column, claimed_identifier)
                    .neq("user_id", user_id)
                    .execute
                )
                stale_rows = getattr(released, "data", None) or []
                if stale_rows:
                    logger.warning(
                        "Released store identifier from a previous owner",
                        user_id=user_id,
                        provider=provider,
                        previous_user_ids=[r.get("user_id") for r in stale_rows],
                    )
            except Exception as error:  # noqa: BLE001
                # Non-fatal: the entitlement write below is what the user is
                # waiting on. A leftover duplicate is logged and the webhook
                # resolver still picks the most recently updated row.
                logger.warning(
                    "Could not release store identifier from other rows",
                    user_id=user_id,
                    provider=provider,
                    error=str(error)[:200],
                )

        upsert_result = await asyncio.to_thread(
            db.table("subscriptions").upsert(payload, on_conflict="user_id").execute
        )
        logger.info(
            "Synchronized store subscription",
            user_id=user_id,
            provider=provider,
            plan_type=plan_type.value,
            status=stored_status.value,
            product_id=product_id,
        )
        # Same as the Stripe tail: build the response from the upserted row
        # instead of re-reading it (one fewer SELECT per webhook).
        upserted_rows = getattr(upsert_result, "data", None) or []
        if upserted_rows:
            return cls._response_from_row(upserted_rows[0])
        return await cls.get_subscription(user_id, db)

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
            # Store-billed subscriptions are managed in the App Store / Play
            # Store settings, never by the Stripe cancellation path. Refuse so
            # a stale client button cannot silently claim a store cancellation.
            sub_result = await asyncio.to_thread(
                db.table("subscriptions")
                .select("billing_provider")
                .eq("user_id", user_id)
                .maybe_single()
                .execute
            )
            sub_data = maybe_single_data(sub_result)
            provider = (sub_data or {}).get("billing_provider", "stripe")
            if provider in ("apple", "google"):
                raise DatabaseError(
                    "This subscription is billed through the "
                    f"{'App Store' if provider == 'apple' else 'Play Store'}; "
                    "manage it there instead."
                )

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

        def _new_record() -> dict:
            return {
                "user_id": user_id,
                "period_start": period_start.isoformat(),
                "monthly_extractions": 0,
                "monthly_generations": 0,
                "monthly_embeddings": 0,
            }

        async def _insert_record() -> dict:
            # Insert-only upsert on the (user_id, period_start) unique key
            # (migration 007) so the reconnect retry is exact-once safe even
            # if the first attempt committed server-side before the response
            # was lost. `ignore_duplicates` (DO NOTHING) is deliberate: a
            # merge-upsert would re-apply this zeroed payload as an UPDATE,
            # wiping any increments a concurrent caller made between our
            # select-miss and this upsert (TOCTOU on month rollover). We then
            # re-read the authoritative row instead of returning the local
            # zeroed dict.
            await execute_with_reconnect(
                lambda d: d.table("subscription_usage").upsert(
                    _new_record(),
                    on_conflict="user_id,period_start",
                    ignore_duplicates=True,
                ).execute(),
                db,
                extra={"operation": "create_usage_record", "user_id": user_id},
            )
            result = await execute_with_reconnect(
                lambda d: d.table("subscription_usage")
                .select("*")
                .eq("user_id", user_id)
                .eq("period_start", period_start.isoformat())
                .single()
                .execute(),
                db,
                extra={"operation": "get_or_create_usage_record_reload", "user_id": user_id},
            )
            if not result.data:
                raise DatabaseError("Failed to create usage record")
            return result.data

        try:
            result = await execute_with_reconnect(
                lambda d: d.table("subscription_usage")
                .select("*")
                .eq("user_id", user_id)
                .eq("period_start", period_start.isoformat())
                .single()
                .execute(),
                db,
                extra={"operation": "get_or_create_usage_record", "user_id": user_id},
            )

            if result.data:
                return result.data

            # Create new usage record for this period
            return await _insert_record()

        except Exception as e:
            if "PGRST116" in str(e):  # No rows returned
                # Create new usage record
                return await _insert_record()
            raise

    @staticmethod
    async def get_usage(
        user_id: str,
        db: Client,
        subscription: Optional[SubscriptionResponse] = None,
    ) -> UsageLimits:
        """Get user's current monthly usage and limits.

        ``subscription`` may be passed in by callers that already fetched it
        (``get_subscription_with_usage``), avoiding a second row fetch per
        request on the endpoint the mobile app polls.
        """
        try:
            # Subscription and usage record are independent reads; run them
            # concurrently (unless the caller already has the subscription).
            # return_exceptions keeps a failing leg from leaving the other
            # task dangling; the subscription error is re-raised below.
            if subscription is None:
                results = await asyncio.gather(
                    SubscriptionService.get_subscription(user_id, db),
                    SubscriptionService.get_or_create_usage_record(user_id, db),
                    return_exceptions=True,
                )
                if isinstance(results[0], BaseException):
                    raise results[0]
                subscription, usage_record = results
            else:
                usage_record = await SubscriptionService.get_or_create_usage_record(user_id, db)

            limits = SubscriptionService.get_plan_limits(subscription.plan_type)

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
                    # Counters reset on the calendar month
                    # (_get_current_period_start), not on the billing date.
                    message += " Your limit resets at the start of the next month."

            return UsageCheckResult(
                allowed=allowed,
                current_count=current_count,
                limit=limit,
                remaining=remaining,
                plan_type=subscription.plan_type,
                message=message,
            )

        except Exception as e:
            # Retry once on a dead pooled HTTP/2 connection (gateway restart /
            # idle). is_db_connection_error covers httpx transport errors AND
            # the embedded h2 `<ConnectionTerminated ...>` repr, whichever the
            # installed postgrest/httpx version surfaces.
            if _retry and is_db_connection_error(e):
                logger.warning(f"Connection error for user {user_id}, retrying: {e}")
                from app.db.connection import SupabaseDB
                new_db = SupabaseDB.rebuild_service_client(db)
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
        """Atomically reserve usage for an operation.

        The previous check-then-increment sequence allowed concurrent
        requests to pass the same preflight check and overshoot a plan limit.
        The hosted Supabase RPC performs the conditional increment while the
        usage row is locked.
        """
        try:
            op = SubscriptionService._coerce_operation_type(operation_type)
            period_start = SubscriptionService._get_current_period_start()

            # Map operation type to column
            column_map = {
                OperationType.EXTRACTION: "monthly_extractions",
                OperationType.GENERATION: "monthly_generations",
                OperationType.EMBEDDING: "monthly_embeddings",
            }

            column = column_map[op]

            async def _reserve(d):
                """Full reservation against client `d` - rebuilt on retry so a
                dead pooled connection (observed 2026-08-01: ConnectionTerminated
                on this exact path) heals in-request instead of 500ing."""
                # Ensure usage record exists
                await SubscriptionService.get_or_create_usage_record(user_id, d)

                subscription = await SubscriptionService.get_subscription(user_id, d)
                limits = SubscriptionService.get_plan_limits(subscription.plan_type)

                result = await asyncio.to_thread(d.rpc("reserve_usage", {
                    "p_user_id": user_id,
                    "p_period_start": period_start.isoformat(),
                    "p_field": column,
                    "p_count": count,
                    "p_limit": limits[column],
                }).execute)

                # `reserve_usage` returns a scalar BOOLEAN, so PostgREST keys the
                # result by the function name rather than a column name.
                reserved = unwrap_rpc_bool(result, "reserve_usage")
                if reserved is not True:
                    raise RateLimitError(
                        f"You've reached your monthly {op.value} limit ({limits[column]})."
                    )
                return reserved

            await execute_with_reconnect(
                _reserve, db, extra={"operation": "increment_usage", "user_id": user_id}
            )

            logger.debug(f"Incremented {op.value} usage for user {user_id} by {count}")

        except RateLimitError:
            raise
        except Exception as e:
            if is_pgrst202_missing_rpc(e):
                # Fail closed if the reservation migration is unavailable. A
                # best-effort counter is not safe for entitlement enforcement.
                # PostgREST answers a missing RPC with PGRST202 ("Could not
                # find the function ... in the schema cache") - the migrations
                # that create reserve_usage (022/024/026) were not applied to
                # the hosted DB. Log the actionable hint for operators; the
                # client-facing message stays friendly (observed 2026-07-31:
                # every quota admission failed this way).
                logger.error(
                    missing_rpc_log_hint("reserve_usage"),
                    user_id=user_id,
                    function="reserve_usage",
                    migrations="022/024/026",
                    rpc_error=str(e),
                )
            else:
                logger.error(f"Error incrementing usage for user {user_id}: {e}")
            raise AIServiceError(
                QUOTA_UNAVAILABLE_CLIENT_MESSAGE,
                retryable=True,
            ) from e

    # ==========================================================================
    # Combined Methods
    # ==========================================================================

    @staticmethod
    async def get_subscription_with_usage(user_id: str, db: Client) -> SubscriptionWithUsage:
        """Get subscription and usage in one call."""
        subscription = await SubscriptionService.get_subscription(user_id, db)
        usage = await SubscriptionService.get_usage(user_id, db, subscription=subscription)

        return SubscriptionWithUsage(
            subscription=subscription,
            usage=usage,
        )
