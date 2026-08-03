"""
Tests for the promo API endpoints (validate + redeem).

Validates the public/auth boundary: validate has no user dependency, redeem
requires an authenticated user and passes the user id through to the service.
"""
from unittest.mock import AsyncMock, Mock, patch

import pytest

from app.api.v1.promo import redeem_promo_code, validate_promo_code
from app.models.subscription import RedeemPromoRequest, ValidatePromoRequest
from app.services.promo_service import PromoService


@pytest.mark.asyncio
async def test_validate_endpoint_is_public_and_returns_envelope():
    request = ValidatePromoRequest(code="LAUNCH30")
    db = Mock()

    with patch.object(
        PromoService, "validate_promo", new=AsyncMock()
    ) as validate:
        validate.return_value = Mock(
            model_dump=lambda mode="json": {
                "valid": True,
                "plan_type": "pro_monthly",
                "months": 1,
                "plan_name": "Pro",
                "share_url": "https://fitcheckaiapp.com/auth/register?promo=launch30",
                "message": "Get Pro free for 1 month!",
            }
        )
        result = await validate_promo_code(request, db=db)

    assert result["data"]["valid"] is True
    assert result["data"]["plan_type"] == "pro_monthly"
    assert result["message"] == "OK"
    validate.assert_awaited_once_with("LAUNCH30", db)


def test_validate_promo_accepts_partial_code():
    """Landing/register pages validate as the user types; a 1-char partial
    code must reach the service (which normalizes + returns valid=False)
    instead of 422ing (observed 2026-08-03: POST /promo/validate | 422)."""
    request = ValidatePromoRequest(code="L")
    assert request.code == "L"


@pytest.mark.asyncio
async def test_redeem_endpoint_passes_user_id_and_code():
    request = RedeemPromoRequest(promo_code="launch30")

    with patch.object(
        PromoService, "redeem_promo", new=AsyncMock()
    ) as redeem:
        redeem.return_value = Mock(
            model_dump=lambda mode="json": {
                "success": True,
                "message": "Promo code applied",
                "plan_type": "pro_monthly",
                "months": 1,
            }
        )
        result = await redeem_promo_code(
            request, user={"id": "user-1"}, db=Mock()
        )

    assert result["data"]["success"] is True
    redeem.assert_awaited_once()
    args = redeem.await_args.args
    assert args[0] == "user-1"
    assert args[1] == "launch30"
