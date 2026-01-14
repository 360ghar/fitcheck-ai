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
    PRO_MONTHLY = "pro_monthly"
    PRO_YEARLY = "pro_yearly"


class SubscriptionStatus(str, Enum):
    """Subscription status values."""
    ACTIVE = "active"
    CANCELLED = "cancelled"
    PAST_DUE = "past_due"
    TRIAL = "trial"


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
    plan_type: PlanType = Field(..., description="Plan to subscribe to (pro_monthly or pro_yearly)")
    success_url: str = Field(..., description="URL to redirect to after successful payment")
    cancel_url: str = Field(..., description="URL to redirect to if payment is cancelled")


class CheckoutSessionResponse(BaseModel):
    """Response with Stripe checkout URL."""
    checkout_url: str
    session_id: str


class PortalSessionResponse(BaseModel):
    """Response with Stripe customer portal URL."""
    portal_url: str


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
    code: str = Field(..., min_length=3, max_length=50)


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
