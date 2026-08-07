"""
Tests for PromoService.validate_promo and redeem_promo.

Covers the public validation contract (found/not-found/expired/max-uses/
inactive), the atomic-redemption passthrough, the migration-gap (PGRST202)
mapping to a friendly retryable 503, and the dead-pooled-connection retry
(2026-08-03 incident class: "Error validating referral code ...:
<ConnectionTerminated ...>").
"""
from datetime import datetime, timedelta, timezone
from unittest.mock import Mock

import httpx
import pytest

from app.core.config import settings
from app.core.exceptions import ServiceError
from app.services.promo_service import PromoService

NOW = datetime.now(timezone.utc)


def _db_with_promo_row(row):
    db = Mock()
    result = Mock(data=row)
    db.table.return_value.select.return_value.ilike.return_value.maybe_single.return_value.execute.return_value = result
    return db


def _promo_row(**overrides):
    row = {
        "code": "launch30",
        "plan_type": "pro_monthly",
        "months": 1,
        "max_uses": None,
        "used_count": 0,
        "expires_at": None,
        "active": True,
    }
    row.update(overrides)
    return row


# =============================================================================
# validate_promo
# =============================================================================


@pytest.mark.asyncio
async def test_validate_promo_valid_code(monkeypatch):
    monkeypatch.setattr(settings, "FRONTEND_URL", "https://fitcheckaiapp.com")
    db = _db_with_promo_row(_promo_row())

    response = await PromoService.validate_promo("LAUNCH30", db)

    assert response.valid is True
    assert response.plan_type == "pro_monthly"
    assert response.plan_name == "Pro"
    assert response.months == 1
    assert response.share_url == "https://fitcheckaiapp.com/auth/register?promo=launch30"
    assert "Pro free for 1 month" in response.message


@pytest.mark.asyncio
async def test_validate_promo_pluralizes_months():
    db = _db_with_promo_row(_promo_row(months=3, plan_type="plus_yearly"))

    response = await PromoService.validate_promo("code", db)

    assert response.valid is True
    assert response.plan_name == "Plus"
    assert "3 months" in response.message


@pytest.mark.asyncio
async def test_validate_promo_handles_zero_row_result():
    # postgrest-py returns bare None (not a response object) for zero rows.
    db = Mock()
    db.table.return_value.select.return_value.ilike.return_value.maybe_single.return_value.execute.return_value = None

    response = await PromoService.validate_promo("doesnotexist", db)

    assert response.valid is False
    assert response.message == "Invalid promo code"


@pytest.mark.asyncio
async def test_validate_promo_rejects_inactive_code():
    db = _db_with_promo_row(_promo_row(active=False))

    response = await PromoService.validate_promo("launch30", db)

    assert response.valid is False
    assert response.message == "This promo code is no longer active"


@pytest.mark.asyncio
async def test_validate_promo_rejects_expired_code():
    db = _db_with_promo_row(
        _promo_row(expires_at=(NOW - timedelta(days=1)).isoformat())
    )

    response = await PromoService.validate_promo("launch30", db)

    assert response.valid is False
    assert response.message == "This promo code has expired"


@pytest.mark.asyncio
async def test_validate_promo_rejects_max_uses_reached():
    db = _db_with_promo_row(_promo_row(max_uses=5, used_count=5))

    response = await PromoService.validate_promo("launch30", db)

    assert response.valid is False
    assert response.message == "This promo code has reached its usage limit"

# =============================================================================
# redeem_promo
# =============================================================================


def _db_with_rpc_result(row):
    db = Mock()
    result = Mock(data=[row])
    db.rpc.return_value.execute.return_value = result
    return db


@pytest.mark.asyncio
async def test_redeem_promo_success():
    db = _db_with_rpc_result(
        {
            "success": True,
            "already_redeemed": False,
            "plan_type": "pro_monthly",
            "months": 1,
            "message": "Promo code applied",
        }
    )

    response = await PromoService.redeem_promo("user-1", "LAUNCH30", db)

    assert response.success is True
    assert response.plan_type == "pro_monthly"
    assert response.months == 1
    db.rpc.assert_called_once_with("redeem_promo_atomic", {
        "p_user_id": "user-1",
        "p_code": "launch30",  # normalized: lowercased + trimmed
    })


@pytest.mark.asyncio
async def test_redeem_promo_already_redeemed_is_success():
    # A replay (reconnect retry after a committed-but-lost response) or a
    # genuine repeat redemption returns success=FALSE + already_redeemed=TRUE
    # from the RPC; the user IS entitled by then, so the service must surface
    # it as success instead of reporting a failed redemption.
    db = _db_with_rpc_result(
        {
            "success": False,
            "already_redeemed": True,
            "plan_type": "pro_monthly",
            "months": 1,
            "message": "You have already redeemed a promo code",
        }
    )

    response = await PromoService.redeem_promo("user-1", "launch30", db)

    assert response.success is True
    assert "already applied" in response.message
    assert response.plan_type == "pro_monthly"
    assert response.months == 1


@pytest.mark.asyncio
async def test_redeem_promo_missing_rpc_raises_friendly_503():
    error = Exception('PGRST202 Could not find the function public.redeem_promo_atomic')
    db = Mock()
    db.rpc.return_value.execute.side_effect = error

    with pytest.raises(ServiceError) as exc_info:
        await PromoService.redeem_promo("user-1", "launch30", db)

    assert exc_info.value.status_code == 503
    assert "temporarily unavailable" in exc_info.value.message


@pytest.mark.asyncio
async def test_validate_promo_does_not_count_max_uses_when_unlimited():
    db = _db_with_promo_row(_promo_row(max_uses=None, used_count=99))

    response = await PromoService.validate_promo("launch30", db)

    assert response.valid is True


@pytest.mark.asyncio
async def test_validate_promo_fails_closed_on_broken_config():
    db = _db_with_promo_row(_promo_row(plan_type="gold_monthly"))

    response = await PromoService.validate_promo("launch30", db)

    assert response.valid is False
    assert response.message == "This promo code is not configured correctly"


# =============================================================================
# Dead pooled-connection retry (execute_with_reconnect)
# =============================================================================


def _patch_supabase_db(monkeypatch, fresh_db):
    """Make execute_with_reconnect hand out `fresh_db` after a rebuild."""
    from app.db.connection import SupabaseDB

    monkeypatch.setattr(
        SupabaseDB, "rebuild_service_client", staticmethod(lambda _stale=None: fresh_db)
    )


@pytest.mark.asyncio
async def test_validate_promo_retries_once_on_dead_connection(monkeypatch):
    dead_db = Mock()
    dead_db.table.return_value.select.return_value.ilike.return_value.maybe_single.return_value.execute.side_effect = (
        httpx.RemoteProtocolError("Server disconnected")
    )
    fresh_db = _db_with_promo_row(_promo_row())
    _patch_supabase_db(monkeypatch, fresh_db)

    response = await PromoService.validate_promo("LAUNCH30", dead_db)

    assert response.valid is True
    assert response.plan_type == "pro_monthly"


@pytest.mark.asyncio
async def test_redeem_promo_retries_once_on_dead_connection(monkeypatch):
    dead_db = Mock()
    dead_db.rpc.return_value.execute.side_effect = RuntimeError("11")  # bare h2 error code
    fresh_db = _db_with_rpc_result(
        {
            "success": True,
            "already_redeemed": False,
            "plan_type": "pro_monthly",
            "months": 1,
            "message": "Promo code applied",
        }
    )
    _patch_supabase_db(monkeypatch, fresh_db)

    response = await PromoService.redeem_promo("user-1", "LAUNCH30", dead_db)

    assert response.success is True
    assert response.plan_type == "pro_monthly"
