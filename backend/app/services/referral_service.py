"""
Referral service for managing referral codes and redemptions.
"""
import asyncio
import re
from app.utils.datetime_util import utcnow
from app.utils.db import unwrap_rpc_result, execute_with_reconnect
from typing import Any, Dict, Optional

from supabase import Client

from app.core.config import settings
from app.core.exceptions import DatabaseError
from app.core.logging_config import get_context_logger
from app.models.subscription import (
    ReferralCodeResponse,
    ReferralStats,
    ValidateReferralResponse,
    RedeemReferralResponse,
)

logger = get_context_logger(__name__)


class ReferralService:
    """Service for managing referral codes and redemptions."""

    @staticmethod
    def _normalize_code(code: str) -> str:
        return (code or "").strip().lower()

    @staticmethod
    def generate_code_from_name(user_id: str, full_name: Optional[str]) -> str:
        """Generate a unique referral code from user's name and ID."""
        # Clean the name - lowercase, alphanumeric only
        name = full_name or "user"
        base_slug = re.sub(r'[^a-z0-9]', '', name.lower())

        # Ensure minimum length
        if len(base_slug) < 3:
            base_slug = "user"

        # Truncate to max 20 chars
        base_slug = base_slug[:20]

        # Generate short unique ID from user_id (6 chars)
        short_id = user_id.replace("-", "")[:6].lower()

        return f"{base_slug}-{short_id}"

    @staticmethod
    def get_share_url(code: str) -> str:
        """Get the shareable URL for a referral code."""
        frontend_url = settings.FRONTEND_URL.rstrip("/")
        return f"{frontend_url}/auth/register?ref={code}"

    # ==========================================================================
    # Referral Code Management
    # ==========================================================================

    @staticmethod
    async def get_or_create_referral_code(
        user_id: str,
        full_name: Optional[str],
        db: Client,
    ) -> ReferralCodeResponse:
        """Get user's referral code, creating one if it doesn't exist."""
        try:
            # Try to get existing code (read-only; safe to rebuild the client
            # and retry once when the pooled connection is dead)
            result = await execute_with_reconnect(
                lambda d: d.table("referral_codes")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute(),
                db,
                extra={"operation": "get_referral_code", "user_id": user_id},
            )

            if result and result.data:
                return ReferralCodeResponse(
                    code=result.data["code"],
                    times_used=result.data.get("times_used", 0),
                    share_url=ReferralService.get_share_url(result.data["code"]),
                    created_at=result.data.get("created_at"),
                )

            # Generate new code
            code = ReferralService.generate_code_from_name(user_id, full_name)

            # Handle potential collision by appending more characters
            attempts = 0
            inserted_row = None
            while attempts < 5:
                try:
                    insert_result = await asyncio.to_thread(db.table("referral_codes").insert({
                        "user_id": user_id,
                        "code": code,
                        "times_used": 0,
                    }).execute)
                    if insert_result.data:
                        inserted_row = insert_result.data[0]
                    break
                except Exception as e:
                    if "duplicate" in str(e).lower() or "unique" in str(e).lower():
                        # Collision - add more entropy
                        import uuid
                        extra = uuid.uuid4().hex[:4]
                        code = f"{code[:20]}-{extra}"
                        attempts += 1
                    else:
                        raise

            if not inserted_row:
                raise DatabaseError("Failed to create a unique referral code")

            logger.info(f"Created referral code {code} for user {user_id}")

            return ReferralCodeResponse(
                code=code,
                times_used=0,
                share_url=ReferralService.get_share_url(code),
                created_at=inserted_row.get("created_at") if inserted_row else utcnow(),
            )

        except Exception as e:
            logger.error(f"Error getting referral code for user {user_id}: {e}")
            raise DatabaseError(f"Failed to get referral code: {str(e)}")

    @staticmethod
    async def get_referral_stats(user_id: str, db: Client) -> ReferralStats:
        """Get detailed referral statistics for a user."""
        try:
            # Get user's referral code (reads rebuild + retry on a dead
            # pooled connection - ConnectionTerminated 500s observed on
            # /referral/code and /referral/stats 2026-08-03)
            code_result = await execute_with_reconnect(
                lambda d: d.table("referral_codes")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute(),
                db,
                extra={"operation": "get_referral_stats_code", "user_id": user_id},
            )

            if not code_result or not code_result.data:
                # Create one
                user_result = await execute_with_reconnect(
                    lambda d: d.table("users")
                    .select("full_name")
                    .eq("id", user_id)
                    .maybe_single()
                    .execute(),
                    db,
                    extra={"operation": "get_referral_stats_user", "user_id": user_id},
                )
                full_name = user_result.data.get("full_name") if user_result and user_result.data else None
                code_response = await ReferralService.get_or_create_referral_code(user_id, full_name, db)
                code = code_response.code
                times_used = 0
            else:
                code = code_result.data["code"]
                times_used = code_result.data.get("times_used", 0)

            # Get referral redemptions (who this user has referred)
            referrals = []
            total_credits = 0
            successful_referrals = 0

            redemptions = await execute_with_reconnect(
                lambda d: d.table("referral_redemptions").select(
                    "referred_user_id, redeemed_at, referrer_credit_applied"
                ).eq("referrer_user_id", user_id).execute(),
                db,
                extra={"operation": "get_referral_stats_redemptions", "user_id": user_id},
            )

            if redemptions.data:
                # One batched lookup instead of a query per redemption
                # (same pattern as gamification.py's leaderboard profiles).
                referred_ids = [
                    r["referred_user_id"] for r in redemptions.data if r.get("referred_user_id")
                ]
                referred_users: Dict[str, Dict[str, Any]] = {}
                if referred_ids:
                    users_result = await execute_with_reconnect(
                        lambda d: d.table("users")
                        .select("id, email, full_name")
                        .in_("id", referred_ids)
                        .execute(),
                        db,
                        extra={"operation": "get_referral_stats_users", "user_id": user_id},
                    )
                    referred_users = {
                        str(u["id"]): u
                        for u in (users_result.data or [])
                        if u and u.get("id")
                    }

                for redemption in redemptions.data:
                    referred_user = referred_users.get(str(redemption.get("referred_user_id")))
                    email = (referred_user or {}).get("email") or "unknown"

                    credit_applied = redemption.get("referrer_credit_applied", False)
                    referrals.append({
                        "email": email,
                        "full_name": (referred_user or {}).get("full_name"),
                        "redeemed_at": redemption["redeemed_at"],
                        "credit_applied": credit_applied,
                    })

                    if credit_applied:
                        successful_referrals += 1
                        total_credits += settings.REFERRAL_CREDIT_MONTHS

            total_referrals = len(referrals)
            pending_referrals = max(0, total_referrals - successful_referrals)

            return ReferralStats(
                code=code,
                share_url=ReferralService.get_share_url(code),
                times_used=times_used,
                credits_earned=total_credits,
                referred_users=referrals,
                total_referrals=total_referrals,
                successful_referrals=successful_referrals,
                pending_referrals=pending_referrals,
                months_earned=total_credits,
            )

        except Exception as e:
            logger.error(f"Error getting referral stats for user {user_id}: {e}")
            raise DatabaseError(f"Failed to get referral stats: {str(e)}")

    # ==========================================================================
    # Referral Validation and Redemption
    # ==========================================================================

    @staticmethod
    async def validate_referral_code(code: str, db: Client) -> ValidateReferralResponse:
        """Validate a referral code without redeeming it."""
        normalized_code = ReferralService._normalize_code(code)
        try:
            # Case-insensitive lookup (read-only; rebuild + retry once on a
            # dead pooled connection - observed 2026-08-03: "Error validating
            # referral code ony-77ee88: <ConnectionTerminated ...>").
            result = await execute_with_reconnect(
                lambda d: d.table("referral_codes").select(
                    "*, users(full_name)"
                ).eq("code", normalized_code).maybe_single().execute(),
                db,
                extra={"operation": "validate_referral_code", "code": normalized_code},
            )

            if not result or not result.data:
                return ValidateReferralResponse(
                    valid=False,
                    message="Invalid referral code",
                )

            # Get referrer's name
            referrer_name = None
            if result.data.get("users"):
                referrer_name = result.data["users"].get("full_name", "A friend")
            else:
                # Fallback: query user separately
                user_result = await execute_with_reconnect(
                    lambda d: d.table("users")
                    .select("full_name")
                    .eq("id", result.data["user_id"])
                    .maybe_single()
                    .execute(),
                    db,
                    extra={"operation": "validate_referral_code_user", "user_id": result.data["user_id"]},
                )
                if user_result and user_result.data:
                    referrer_name = user_result.data.get("full_name", "A friend")

            credit_months = settings.REFERRAL_CREDIT_MONTHS
            month_label = "month" if credit_months == 1 else "months"

            return ValidateReferralResponse(
                valid=True,
                referrer_name=referrer_name or "A friend",
                message=f"Referred by {referrer_name or 'a friend'}! You'll both get {credit_months} {month_label} of Pro free.",
            )

        except Exception as e:
            logger.error(f"Error validating referral code {code}: {e}")
            return ValidateReferralResponse(
                valid=False,
                message="Error validating referral code",
            )

    @staticmethod
    async def redeem_referral(
        referred_user_id: str,
        code: str,
        db: Client,
    ) -> RedeemReferralResponse:
        """Redeem a referral code for a new user."""
        normalized_code = ReferralService._normalize_code(code)
        try:
            credit_months = settings.REFERRAL_CREDIT_MONTHS
            # The RPC is one transaction (row locks + writes), so a reconnect
            # retry after a lost response cannot double-grant: the second
            # attempt simply reports the already-redeemed state.
            result = await execute_with_reconnect(
                lambda d: d.rpc("redeem_referral_atomic", {
                    "p_referred_user_id": referred_user_id,
                    "p_code": normalized_code,
                    "p_credit_months": credit_months,
                }).execute(),
                db,
                extra={"operation": "redeem_referral", "referred_user_id": referred_user_id},
            )
            data = unwrap_rpc_result(result)
            if not isinstance(data, dict):
                raise DatabaseError("Referral redemption returned no result")

            return RedeemReferralResponse(
                success=bool(data.get("success")),
                message=data.get("message") or "Referral code applied",
                credit_months=int(data.get("credit_months") or 0),
            )

        except Exception as e:
            logger.error(f"Error redeeming referral code {code} for user {referred_user_id}: {e}")
            raise DatabaseError(f"Failed to redeem referral code: {str(e)}")

    @staticmethod
    async def process_pending_referral(user_id: str, db: Client) -> Optional[RedeemReferralResponse]:
        """Process any pending referral code stored on the user record."""
        try:
            # Check if user has a pending referral code
            result = await asyncio.to_thread(
                db.table("users")
                .select("referred_by_code")
                .eq("id", user_id)
                .maybe_single()
                .execute
            )

            if not result or not result.data or not result.data.get("referred_by_code"):
                return None

            # Check if already redeemed
            existing = await asyncio.to_thread(db.table("referral_redemptions").select("id").eq("referred_user_id", user_id).execute)

            if existing.data:
                # Already redeemed, clear the field
                await asyncio.to_thread(db.table("users").update({"referred_by_code": None}).eq("id", user_id).execute)
                return None

            # Redeem the code
            code = result.data["referred_by_code"]
            return await ReferralService.redeem_referral(user_id, code, db)

        except Exception as e:
            logger.error(f"Error processing pending referral for user {user_id}: {e}")
            return None
