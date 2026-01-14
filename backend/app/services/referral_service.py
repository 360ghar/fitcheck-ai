"""
Referral service for managing referral codes and redemptions.
"""
import logging
import re
from datetime import datetime
from typing import Optional

from supabase import Client

from app.core.config import settings
from app.core.exceptions import DatabaseError, ValidationError
from app.models.subscription import (
    ReferralCodeResponse,
    ReferralStats,
    ValidateReferralResponse,
    RedeemReferralResponse,
)
from app.services.subscription_service import SubscriptionService

logger = logging.getLogger(__name__)


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
            # Try to get existing code
            result = (
                db.table("referral_codes")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            )

            if result.data:
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
                    insert_result = db.table("referral_codes").insert({
                        "user_id": user_id,
                        "code": code,
                        "times_used": 0,
                    }).execute()
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
                created_at=inserted_row.get("created_at") if inserted_row else datetime.utcnow(),
            )

        except Exception as e:
            logger.error(f"Error getting referral code for user {user_id}: {e}")
            raise DatabaseError(f"Failed to get referral code: {str(e)}")

    @staticmethod
    async def get_referral_stats(user_id: str, db: Client) -> ReferralStats:
        """Get detailed referral statistics for a user."""
        try:
            # Get user's referral code
            code_result = (
                db.table("referral_codes")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            )

            if not code_result.data:
                # Create one
                user_result = (
                    db.table("users")
                    .select("full_name")
                    .eq("id", user_id)
                    .maybe_single()
                    .execute()
                )
                full_name = user_result.data.get("full_name") if user_result.data else None
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

            redemptions = db.table("referral_redemptions").select(
                "referred_user_id, redeemed_at, referrer_credit_applied"
            ).eq("referrer_user_id", user_id).execute()

            if redemptions.data:
                for redemption in redemptions.data:
                    referred_user = (
                        db.table("users")
                        .select("email, full_name")
                        .eq("id", redemption["referred_user_id"])
                        .maybe_single()
                        .execute()
                    )
                    email = (
                        referred_user.data.get("email")
                        if referred_user.data and referred_user.data.get("email")
                        else "unknown"
                    )

                    credit_applied = redemption.get("referrer_credit_applied", False)
                    referrals.append({
                        "email": email,
                        "full_name": referred_user.data.get("full_name") if referred_user.data else None,
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
            # Case-insensitive lookup
            result = db.table("referral_codes").select(
                "*, users(full_name)"
            ).eq("code", normalized_code).maybe_single().execute()

            if not result.data:
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
                user_result = (
                    db.table("users")
                    .select("full_name")
                    .eq("id", result.data["user_id"])
                    .maybe_single()
                    .execute()
                )
                if user_result.data:
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
            # Validate the code first
            validation = await ReferralService.validate_referral_code(normalized_code, db)
            if not validation.valid:
                return RedeemReferralResponse(
                    success=False,
                    message=validation.message or "Invalid referral code",
                    credit_months=0,
                )

            # Get the referral code record
            code_result = (
                db.table("referral_codes")
                .select("*")
                .eq("code", normalized_code)
                .maybe_single()
                .execute()
            )

            if not code_result.data:
                return RedeemReferralResponse(
                    success=False,
                    message="Referral code not found",
                    credit_months=0,
                )

            referrer_user_id = code_result.data["user_id"]
            referral_code_id = code_result.data["id"]

            # Check if user is trying to use their own code
            if referrer_user_id == referred_user_id:
                return RedeemReferralResponse(
                    success=False,
                    message="You cannot use your own referral code",
                    credit_months=0,
                )

            # Check if this user has already been referred
            existing = db.table("referral_redemptions").select("id").eq("referred_user_id", referred_user_id).execute()

            if existing.data:
                return RedeemReferralResponse(
                    success=False,
                    message="You have already used a referral code",
                    credit_months=0,
                )

            # Create redemption record
            db.table("referral_redemptions").insert({
                "referrer_user_id": referrer_user_id,
                "referred_user_id": referred_user_id,
                "referral_code_id": referral_code_id,
                "referrer_credit_applied": False,
                "referred_credit_applied": False,
                "redeemed_at": datetime.utcnow().isoformat(),
            }).execute()

            # Increment times_used on the referral code atomically to prevent race conditions
            db.rpc("increment_referral_times_used", {
                "p_referral_code_id": referral_code_id,
                "p_count": 1,
            }).execute()

            # Apply credits to both users
            credit_months = settings.REFERRAL_CREDIT_MONTHS

            # Credit the referred user (new user)
            await SubscriptionService.apply_referral_credit(referred_user_id, credit_months, db)
            db.table("referral_redemptions").update({
                "referred_credit_applied": True,
            }).eq("referred_user_id", referred_user_id).execute()

            # Credit the referrer
            await SubscriptionService.apply_referral_credit(referrer_user_id, credit_months, db)
            db.table("referral_redemptions").update({
                "referrer_credit_applied": True,
            }).eq("referred_user_id", referred_user_id).execute()

            # Update the referred_by_code on the user
            db.table("users").update({
                "referred_by_code": normalized_code,
            }).eq("id", referred_user_id).execute()

            logger.info(f"Referral redeemed: {referred_user_id} used code {normalized_code} from {referrer_user_id}")

            return RedeemReferralResponse(
                success=True,
                message=f"Referral code applied! You and your friend both received {credit_months} month(s) of Pro free.",
                credit_months=credit_months,
            )

        except Exception as e:
            logger.error(f"Error redeeming referral code {code} for user {referred_user_id}: {e}")
            raise DatabaseError(f"Failed to redeem referral code: {str(e)}")

    @staticmethod
    async def process_pending_referral(user_id: str, db: Client) -> Optional[RedeemReferralResponse]:
        """Process any pending referral code stored on the user record."""
        try:
            # Check if user has a pending referral code
            result = (
                db.table("users")
                .select("referred_by_code")
                .eq("id", user_id)
                .maybe_single()
                .execute()
            )

            if not result.data or not result.data.get("referred_by_code"):
                return None

            # Check if already redeemed
            existing = db.table("referral_redemptions").select("id").eq("referred_user_id", user_id).execute()

            if existing.data:
                # Already redeemed, clear the field
                db.table("users").update({"referred_by_code": None}).eq("id", user_id).execute()
                return None

            # Redeem the code
            code = result.data["referred_by_code"]
            return await ReferralService.redeem_referral(user_id, code, db)

        except Exception as e:
            logger.error(f"Error processing pending referral for user {user_id}: {e}")
            return None
