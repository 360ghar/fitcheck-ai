"""
Referral API endpoints for managing referral codes and redemptions.
"""
import logging
from typing import Any, Dict

from fastapi import APIRouter, Depends
from supabase import Client

from app.api.v1.deps import get_current_user, get_db
from app.models.subscription import (
    ReferralCodeResponse,
    ReferralStats,
    ValidateReferralRequest,
    ValidateReferralResponse,
    RedeemReferralRequest,
    RedeemReferralResponse,
)
from app.services.referral_service import ReferralService

logger = logging.getLogger(__name__)

router = APIRouter()


# =============================================================================
# Referral Code Endpoints
# =============================================================================


@router.get("/code", response_model=Dict[str, Any])
async def get_referral_code(
    user=Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Get the current user's referral code.

    Returns the user's unique referral code and a shareable URL.
    If no code exists, one will be generated.
    """
    result = await ReferralService.get_or_create_referral_code(
        user_id=user["id"],
        full_name=user.get("full_name"),
        db=db,
    )
    return {"data": result.model_dump(mode="json"), "message": "OK"}


@router.get("/stats", response_model=Dict[str, Any])
async def get_referral_stats(
    user=Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Get detailed referral statistics.

    Returns the user's referral code, times used, credits earned,
    and a list of referred users.
    """
    result = await ReferralService.get_referral_stats(user["id"], db)
    return {"data": result.model_dump(mode="json"), "message": "OK"}


# =============================================================================
# Referral Validation and Redemption
# =============================================================================


@router.post("/validate", response_model=Dict[str, Any])
async def validate_referral_code(
    request: ValidateReferralRequest,
    db: Client = Depends(get_db),
):
    """
    Validate a referral code without redeeming it.

    This endpoint is public and can be used during signup
    to verify a referral code before registration.
    """
    result = await ReferralService.validate_referral_code(request.code, db)
    return {"data": result.model_dump(mode="json"), "message": "OK"}


@router.post("/redeem", response_model=Dict[str, Any])
async def redeem_referral_code(
    request: RedeemReferralRequest,
    user=Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Redeem a referral code.

    This applies referral credits to both the current user and the referrer.
    Each user can only redeem one referral code.
    """
    result = await ReferralService.redeem_referral(
        referred_user_id=user["id"],
        code=request.code,
        db=db,
    )
    return {"data": result.model_dump(mode="json"), "message": "OK"}
