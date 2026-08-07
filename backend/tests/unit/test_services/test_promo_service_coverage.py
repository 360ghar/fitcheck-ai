"""Coverage-completing tests for PromoService.

Sibling to test_promo_service.py: this file pins the remaining untested
branches — the plan-name fallback when SubscriptionService.plan_display_name
raises, the validate_promo generic-error response, the redeem_promo
non-dict-result and generic-failure DatabaseErrors, and the _is_expired
datetime/naive/unparseable variants.
"""

from datetime import datetime, timedelta, timezone
from unittest.mock import Mock

import pytest

from app.core.exceptions import DatabaseError
from app.services.promo_service import PromoService, _is_expired
from app.services.subscription_service import SubscriptionService

NOW = datetime.now(timezone.utc)


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


def _db_with_promo_row(row):
    db = Mock()
    result = Mock(data=row)
    maybe_single = (
        db.table.return_value.select.return_value.ilike.return_value
        .maybe_single.return_value
    )
    maybe_single.execute.return_value = result
    return db


# =============================================================================
# validate_promo
# =============================================================================


@pytest.mark.asyncio
async def test_plan_name_falls_back_when_display_name_raises(monkeypatch):
    def _raise(_plan_type):
        raise RuntimeError("boom")

    monkeypatch.setattr(
        SubscriptionService, "plan_display_name", staticmethod(_raise)
    )
    db = _db_with_promo_row(_promo_row())

    response = await PromoService.validate_promo("launch30", db)

    assert response.valid is True
    assert response.plan_name == "pro_monthly"  # raw plan_type fallback


@pytest.mark.asyncio
async def test_validate_promo_fails_closed_on_query_error():
    db = Mock()
    maybe_single = (
        db.table.return_value.select.return_value.ilike.return_value
        .maybe_single.return_value
    )
    maybe_single.execute.side_effect = RuntimeError("boom")

    response = await PromoService.validate_promo("launch30", db)

    assert response.valid is False
    assert response.message == "Error validating promo code"


@pytest.mark.asyncio
async def test_validate_promo_accepts_aware_datetime_expiry():
    db = _db_with_promo_row(_promo_row(expires_at=NOW + timedelta(days=1)))

    response = await PromoService.validate_promo("launch30", db)

    assert response.valid is True


@pytest.mark.asyncio
async def test_validate_promo_accepts_naive_datetime_expiry():
    naive_future = NOW.replace(tzinfo=None) + timedelta(days=1)
    db = _db_with_promo_row(_promo_row(expires_at=naive_future))

    response = await PromoService.validate_promo("launch30", db)

    assert response.valid is True


def test_is_expired_fails_closed_on_unparseable_expiry():
    assert _is_expired("not-a-date") is True


# =============================================================================
# redeem_promo
# =============================================================================


@pytest.mark.asyncio
async def test_redeem_promo_raises_database_error_on_non_dict_result():
    db = Mock()
    db.rpc.return_value.execute.return_value = Mock(data=[42])

    with pytest.raises(DatabaseError) as exc_info:
        await PromoService.redeem_promo("user-1", "launch30", db)

    assert "no result" in exc_info.value.message


@pytest.mark.asyncio
async def test_redeem_promo_raises_database_error_on_generic_failure():
    db = Mock()
    db.rpc.return_value.execute.side_effect = RuntimeError("boom")

    with pytest.raises(DatabaseError) as exc_info:
        await PromoService.redeem_promo("user-1", "launch30", db)

    assert "Failed to redeem promo code" in exc_info.value.message
