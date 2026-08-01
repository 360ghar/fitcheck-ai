"""
Promo code API endpoints.

Promo codes are shareable campaign codes (`/auth/register?promo=CODE`) that
grant Plus/Pro plans for free for a fixed number of months.
"""
from typing import Any, Dict

from fastapi import APIRouter, Depends
from supabase import Client

from app.api.v1.deps import get_current_user, get_db
from app.core.logging_config import get_context_logger
from app.models.subscription import (
    RedeemPromoRequest,
    ValidatePromoRequest,
)
from app.services.promo_service import PromoService

logger = get_context_logger(__name__)

router = APIRouter()


# =============================================================================
# Promo Code Endpoints
# =============================================================================


@router.post("/validate", response_model=Dict[str, Any])
async def validate_promo_code(
    request: ValidatePromoRequest,
    db: Client = Depends(get_db),
):
    """
    Validate a promo code without redeeming it.

    Public endpoint: used by landing/register pages before signup to show the
    visitor what the code grants. Never mutates state.
    """
    result = await PromoService.validate_promo(request.code, db)
    return {"data": result.model_dump(mode="json"), "message": "OK"}


@router.post("/redeem", response_model=Dict[str, Any])
async def redeem_promo_code(
    request: RedeemPromoRequest,
    user=Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Redeem a promo code for the current user.

    Grants the code's plan for free for its configured number of months
    (one redemption per user; paid subscribers are never overwritten).
    """
    result = await PromoService.redeem_promo(user["id"], request.code, db)
    return {"data": result.model_dump(mode="json"), "message": "OK"}
