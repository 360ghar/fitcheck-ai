"""
Subscription and referral models for FitCheck AI.
"""
from datetime import datetime, date
from enum import Enum
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, Field
from pydantic import ConfigDict


class PlanType(str, Enum):
    """Subscription plan types."""
    FREE = "free"
    PLUS_MONTHLY = "plus_monthly"
    PLUS_YEARLY = "plus_yearly"
    PRO_MONTHLY = "pro_monthly"
    PRO_YEARLY = "pro_yearly"


class OperationType(str, Enum):
    """AI operation types used by rate limits and subscription usage tracking.

    Wire/DB values remain the literal strings ("extraction", "generation",
    "embedding"); the enum centralizes them so callers cannot typo a value
    that only surfaces as a runtime ValueError at the service boundary.
    """
    EXTRACTION = "extraction"
    GENERATION = "generation"
    EMBEDDING = "embedding"


class SubscriptionStatus(str, Enum):
    """Subscription status values."""
    ACTIVE = "active"
    CANCELLED = "cancelled"
    PAST_DUE = "past_due"
    TRIAL = "trial"
    # Set by the admin "mark refunded" flow (status-only update for store-
    # billed rows). Never entitled: effective_plan_type falls through its
    # TRIAL/ACTIVE branches and returns FREE for any other status.
    REFUNDED = "refunded"


# =============================================================================
# Subscription Models
# =============================================================================


class SubscriptionBase(BaseModel):
    """Base subscription model."""
    plan_type: PlanType = PlanType.FREE
    status: SubscriptionStatus = SubscriptionStatus.ACTIVE


class SubscriptionResponse(BaseModel):
    """Subscription response model."""
    id: UUID
    user_id: UUID
    plan_type: PlanType
    status: SubscriptionStatus
    current_period_start: datetime
    current_period_end: Optional[datetime] = None
    cancel_at_period_end: bool = False
    trial_end: Optional[datetime] = None
    referral_credit_months: int = 0
    # Which billing rail owns this row: "stripe" (web checkout), "apple"
    # (App Store IAP) or "google" (Play Billing IAP).
    billing_provider: str = "stripe"
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    is_pro: bool = False

    class Config:
        from_attributes = True


class UsageLimits(BaseModel):
    """Monthly usage and limits."""
    # Limits based on plan (use plural 's' to match frontend)
    monthly_extractions_limit: int
    monthly_generations_limit: int
    monthly_embeddings_limit: int

    # Current usage (use same naming as frontend)
    monthly_extractions: int = 0
    monthly_generations: int = 0
    monthly_embeddings: int = 0

    # Remaining
    monthly_extractions_remaining: int = 0
    monthly_generations_remaining: int = 0
    monthly_embeddings_remaining: int = 0

    # Period info
    period_start: date
    period_end: date


class SubscriptionWithUsage(BaseModel):
    """Combined subscription and usage response."""
    subscription: SubscriptionResponse
    usage: UsageLimits


class CreateCheckoutRequest(BaseModel):
    """Request to create a Stripe checkout session."""
    plan_type: PlanType = Field(..., description="Plan to subscribe to (plus_monthly, plus_yearly, pro_monthly or pro_yearly)")
    success_url: str = Field(
        "/settings?checkout=success",
        description="URL to redirect to after successful payment",
    )
    cancel_url: str = Field(
        "/settings?checkout=cancelled",
        description="URL to redirect to if payment is cancelled",
    )


class CheckoutSessionResponse(BaseModel):
    """Response for a new Checkout Session or an in-place update."""
    checkout_url: Optional[str] = None
    session_id: Optional[str] = None
    updated: bool = False


class PortalSessionResponse(BaseModel):
    """Response with Stripe customer portal URL."""
    portal_url: str


# =============================================================================
# Mobile In-App Purchase Models
# =============================================================================


class StoreType(str, Enum):
    """Billing store for mobile in-app purchases."""
    APPLE = "apple"
    GOOGLE = "google"


class RegisterIapTransactionRequest(BaseModel):
    """Request to register a store-verified purchase."""
    store: StoreType = Field(..., description="Billing store (apple or google)")
    transaction_id: str = Field(..., description="App Store transaction ID or Play purchase token")
    # Client-reported product ID, cross-checked against the verified one.
    product_id: Optional[str] = Field(
        None, description="Store product ID the client intended to purchase"
    )


# =============================================================================
# Referral Models
# =============================================================================


class ReferralCodeResponse(BaseModel):
    """Referral code response."""
    code: str
    times_used: int = 0
    share_url: str
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class ReferredUser(BaseModel):
    """A user referred by the current user."""
    email: str
    full_name: Optional[str] = None
    redeemed_at: datetime
    credit_applied: bool = False


class ReferralStats(BaseModel):
    """Referral statistics for a user."""
    code: str  # Changed from referral_code to match frontend
    share_url: str
    times_used: int = 0
    credits_earned: int = 0  # Changed from total_credits_earned to match frontend
    referred_users: list[ReferredUser] = Field(default_factory=list)  # Changed from referrals to match frontend

    # Backwards-compatible stats fields used by the Flutter client
    total_referrals: int = 0
    successful_referrals: int = 0
    pending_referrals: int = 0
    months_earned: int = 0


class ValidateReferralRequest(BaseModel):
    """Request to validate a referral code."""
    # min_length=1 (not 3): the public /referral/validate endpoint is used by
    # the register page which validates as the user types, and the service
    # returns a friendly valid=False for short/unknown codes. A min_length of 3
    # turned partial input into a 422 - the same bug already fixed for promo
    # codes (see ValidatePromoRequest). (RCA 2026-08-05.)
    code: str = Field(..., min_length=1, max_length=50)


class ValidateReferralResponse(BaseModel):
    """Response from referral code validation."""
    valid: bool
    referrer_name: Optional[str] = None
    message: str


class RedeemReferralRequest(BaseModel):
    """Request to redeem a referral code."""
    model_config = ConfigDict(populate_by_name=True)

    code: str = Field(..., min_length=3, max_length=50, alias="referral_code")


class RedeemReferralResponse(BaseModel):
    """Response from redeeming a referral code."""
    success: bool
    message: str
    credit_months: int = 0


# =============================================================================
# Promo Code Models
# =============================================================================


class ValidatePromoRequest(BaseModel):
    """Request to validate a promo code without redeeming it."""
    # min_length=1 (not 3): the public /promo/validate endpoint is used by
    # landing/register pages that validate as the user types, and the service
    # already normalizes + returns a friendly valid=False for short/unknown
    # codes. A min_length of 3 turned partial input into a 422 (observed
    # 2026-08-03).
    code: str = Field(..., min_length=1, max_length=50)


class ValidatePromoResponse(BaseModel):
    """Response from promo code validation (public, non-mutating)."""
    valid: bool
    # Plan variant the code grants (e.g. "pro_monthly"); null when invalid.
    plan_type: Optional[str] = None
    # Free-access duration in months; 0 when invalid.
    months: int = 0
    # Human-readable plan name ("Plus" / "Pro").
    plan_name: Optional[str] = None
    # Shareable campaign URL for this code (present even when valid is False
    # so clients can show "ask the sender for a valid link").
    share_url: Optional[str] = None
    message: str


class RedeemPromoRequest(BaseModel):
    """Request to redeem a promo code."""
    model_config = ConfigDict(populate_by_name=True)

    code: str = Field(..., min_length=3, max_length=50, alias="promo_code")


class RedeemPromoResponse(BaseModel):
    """Response from redeeming a promo code."""
    success: bool
    message: str
    plan_type: Optional[str] = None
    months: int = 0



# =============================================================================
# Usage Check Models
# =============================================================================


class UsageCheckResult(BaseModel):
    """Result of checking if user can perform an operation."""
    allowed: bool
    current_count: int
    limit: int
    remaining: int
    plan_type: PlanType
    message: Optional[str] = None
