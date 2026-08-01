"""
Promo code service for validating and redeeming shareable promo codes.

Promo codes grant Plus/Pro plans for free for a fixed number of months. The
grant itself happens inside the `redeem_promo_atomic` SECURITY DEFINER RPC
(migration 031) so validation, usage caps, and the subscription write are one
transaction; this service only marshals requests and maps errors.
"""
import asyncio

from supabase import Client

from app.core.config import settings
from app.core.exceptions import DatabaseError, ServiceError
from app.core.logging_config import get_context_logger
from app.models.subscription import (
    RedeemPromoResponse,
    ValidatePromoResponse,
)
from app.services.subscription_service import SubscriptionService
from app.utils import maybe_single_data
from app.utils.db import (
    is_pgrst202_missing_rpc,
    unwrap_rpc_result,
)

logger = get_context_logger(__name__)


class PromoService:
    """Service for managing promo code validation and redemption."""

    @staticmethod
    def _normalize_code(code: str) -> str:
        return (code or "").strip().lower()

    @staticmethod
    def get_share_url(code: str) -> str:
        """Get the shareable campaign URL for a promo code."""
        frontend_url = settings.FRONTEND_URL.rstrip("/")
        return f"{frontend_url}/auth/register?promo={code.strip()}"

    @staticmethod
    def _plan_name(plan_type: str) -> str:
        """Human-readable plan name from a plan variant ("pro_monthly" -> "Pro")."""
        try:
            return SubscriptionService.plan_display_name(plan_type)
        except Exception:
            return plan_type

    # ==========================================================================
    # Validation (public, non-mutating)
    # ==========================================================================

    @staticmethod
    async def validate_promo(code: str, db: Client) -> ValidatePromoResponse:
        """Validate a promo code without redeeming it.

        Used by public pages (landing/register) before signup to tell the
        visitor what the code grants. Mirrors referral validation: failures
        return a friendly ``valid=False`` response instead of raising.
        """
        normalized = PromoService._normalize_code(code)
        try:
            result = await asyncio.to_thread(
                db.table("promo_codes")
                .select("*")
                .ilike("code", normalized)
                .maybe_single()
                .execute
            )
            data = maybe_single_data(result)
            if not data:
                return ValidatePromoResponse(
                    valid=False,
                    message="Invalid promo code",
                    share_url=PromoService.get_share_url(normalized),
                )

            plan_type = str(data.get("plan_type") or "")
            months = int(data.get("months") or 0)

            if not data.get("active", True):
                return ValidatePromoResponse(
                    valid=False,
                    plan_type=plan_type,
                    months=months,
                    plan_name=PromoService._plan_name(plan_type),
                    share_url=PromoService.get_share_url(data.get("code") or normalized),
                    message="This promo code is no longer active",
                )

            if months < 1 or plan_type not in (
                "plus_monthly", "plus_yearly", "pro_monthly", "pro_yearly",
            ):
                logger.error(f"Promo code {normalized} has invalid grant config")
                return ValidatePromoResponse(
                    valid=False,
                    message="This promo code is not configured correctly",
                    share_url=PromoService.get_share_url(data.get("code") or normalized),
                )

            if data.get("expires_at") and _is_expired(data["expires_at"]):
                return ValidatePromoResponse(
                    valid=False,
                    plan_type=plan_type,
                    months=months,
                    plan_name=PromoService._plan_name(plan_type),
                    share_url=PromoService.get_share_url(data.get("code") or normalized),
                    message="This promo code has expired",
                )

            max_uses = data.get("max_uses")
            used_count = int(data.get("used_count") or 0)
            if max_uses is not None and used_count >= int(max_uses):
                return ValidatePromoResponse(
                    valid=False,
                    plan_type=plan_type,
                    months=months,
                    plan_name=PromoService._plan_name(plan_type),
                    share_url=PromoService.get_share_url(data.get("code") or normalized),
                    message="This promo code has reached its usage limit",
                )

            month_label = "month" if months == 1 else "months"
            return ValidatePromoResponse(
                valid=True,
                plan_type=plan_type,
                months=months,
                plan_name=PromoService._plan_name(plan_type),
                share_url=PromoService.get_share_url(data.get("code") or normalized),
                message=(
                    f"Get {PromoService._plan_name(plan_type)} free for "
                    f"{months} {month_label}!"
                ),
            )

        except Exception as e:
            logger.error(f"Error validating promo code {normalized}: {e}")
            return ValidatePromoResponse(
                valid=False,
                message="Error validating promo code",
                share_url=PromoService.get_share_url(normalized),
            )

    # ==========================================================================
    # Redemption (authenticated)
    # ==========================================================================

    @staticmethod
    async def redeem_promo(user_id: str, code: str, db: Client) -> RedeemPromoResponse:
        """Redeem a promo code for the current user.

        Delegates the atomic grant to `redeem_promo_atomic`; the RPC enforces
        code state, per-user uniqueness, and the free-plan-only rule.
        """
        normalized = PromoService._normalize_code(code)
        try:
            result = await asyncio.to_thread(
                db.rpc("redeem_promo_atomic", {
                    "p_user_id": user_id,
                    "p_code": normalized,
                }).execute
            )
            data = unwrap_rpc_result(result)
            if not isinstance(data, dict):
                raise DatabaseError("Promo redemption returned no result")

            return RedeemPromoResponse(
                success=bool(data.get("success")),
                message=data.get("message") or "Promo code applied",
                plan_type=data.get("plan_type") or None,
                months=int(data.get("months") or 0),
            )

        except Exception as e:
            if is_pgrst202_missing_rpc(e):
                # Migration 031 not applied to the hosted DB. Log the runbook
                # hint for operators; the client gets a friendly retryable 503.
                logger.error(
                    "Promo redemption is unavailable: the 'redeem_promo_atomic' "
                    "database function is missing (hosted Supabase migration "
                    "031_promo_codes.sql not applied). Apply it to restore "
                    "promo code redemption.",
                    user_id=user_id,
                    function="redeem_promo_atomic",
                    migrations="031_promo_codes.sql",
                    rpc_error=str(e),
                )
                raise ServiceError(
                    "Promo codes are temporarily unavailable. Please try again in a few moments."
                ) from e
            logger.error(f"Error redeeming promo code {normalized} for user {user_id}: {e}")
            raise DatabaseError(f"Failed to redeem promo code: {str(e)}")


def _is_expired(expires_at) -> bool:
    """True when an ISO/timestamp expiry is in the past."""
    try:
        from datetime import datetime, timezone

        if isinstance(expires_at, str):
            parsed = datetime.fromisoformat(expires_at.replace("Z", "+00:00"))
        else:
            parsed = expires_at
        if parsed.tzinfo is None:
            parsed = parsed.replace(tzinfo=timezone.utc)
        return parsed <= datetime.now(timezone.utc)
    except Exception:
        # Unparseable expiry: treat as expired (fail closed) and let operators
        # notice via the DB value rather than granting on a broken config.
        return True

