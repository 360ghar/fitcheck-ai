"""
Regression test for ReferralService.validate_referral_code with a zero-row lookup.

postgrest-py's `.maybe_single().execute()` returns bare `None` (not an object
with `.data = None`) when the query matches no rows - this used to crash with
`AttributeError: 'NoneType' object has no attribute 'data'` for any invalid code.
"""
from unittest.mock import Mock

import pytest

from app.services.referral_service import ReferralService


@pytest.mark.asyncio
async def test_validate_referral_code_handles_zero_row_result():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = None

    response = await ReferralService.validate_referral_code("doesnotexist", db)

    assert response.valid is False
    assert response.message == "Invalid referral code"


# =============================================================================
# Durable retry hook (RCA 2026-08-04)
# =============================================================================
# redeem_referral now persists users.referred_by_code BEFORE the atomic RPC
# so a transient failure (missing RPC from an unapplied migration, dead
# pooled connection) is retried by process_pending_referral on the next
# login instead of being lost forever. The hook is cleared on a definitive
# rejection so an invalid code is not retried.


def _success_db():
    db = Mock()
    db.rpc.return_value.execute.return_value = Mock(data=[{
        "success": True,
        "message": "Referral code applied",
        "credit_months": 1,
    }])
    return db


@pytest.mark.asyncio
async def test_redeem_referral_persists_pending_code_before_rpc():
    """The retry hook is written to users.referred_by_code before the RPC
    and cleared after the grant completes."""
    db = _success_db()

    response = await ReferralService.redeem_referral("u-new", "FIT-ABC123", db)

    assert response.success is True
    # Hook persisted first (normalized), then cleared on success.
    calls = [c.args[0] for c in db.table.return_value.update.call_args_list]
    assert calls == [
        {"referred_by_code": "fit-abc123"},
        {"referred_by_code": None},
    ]
    db.rpc.assert_called_once_with("redeem_referral_atomic", {
        "p_referred_user_id": "u-new",
        "p_code": "fit-abc123",
        "p_credit_months": 1,
    })


@pytest.mark.asyncio
async def test_redeem_referral_clears_hook_on_definitive_rejection():
    """An invalid/own code (success=False) must not be retried later."""
    db = Mock()
    db.rpc.return_value.execute.return_value = Mock(data=[{
        "success": False,
        "message": "Referral code not found",
        "credit_months": 0,
    }])

    response = await ReferralService.redeem_referral("u-new", "NOPE", db)

    assert response.success is False
    # Two user updates: persist before the RPC, clear after the rejection.
    calls = [c.args[0] for c in db.table.return_value.update.call_args_list]
    assert calls == [
        {"referred_by_code": "nope"},
        {"referred_by_code": None},
    ]


@pytest.mark.asyncio
async def test_redeem_referral_keeps_hook_on_rpc_exception():
    """A transient failure leaves the hook in place for a later retry."""
    from app.core.exceptions import DatabaseError

    db = Mock()
    db.rpc.return_value.execute.side_effect = RuntimeError("boom")

    with pytest.raises(DatabaseError):
        await ReferralService.redeem_referral("u-new", "FIT-ABC123", db)

    db.table.return_value.update.assert_called_once_with(
        {"referred_by_code": "fit-abc123"}
    )


def _process_pending_db(user_row, redemptions_data):
    """DB mock with per-table chains for process_pending_referral.

    The SAME chain mock is returned per table name so select/update calls on
    the users table accumulate on one object for assertion.
    """
    db = Mock()
    users_chain = Mock()
    users_chain.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = (
        Mock(data=user_row)
    )
    redemptions_chain = Mock()
    redemptions_chain.select.return_value.eq.return_value.execute.return_value = Mock(
        data=redemptions_data
    )

    def table_side_effect(name):
        return users_chain if name == "users" else redemptions_chain

    db.table.side_effect = table_side_effect
    db.rpc.return_value.execute.return_value = Mock(data=[{
        "success": True,
        "message": "Referral code applied",
        "credit_months": 1,
    }])
    return db, users_chain


@pytest.mark.asyncio
async def test_process_pending_referral_redeems_pending_code():
    db, _users_chain = _process_pending_db({"referred_by_code": "fit-abc123"}, [])

    response = await ReferralService.process_pending_referral("u-new", db)

    assert response is not None
    assert response.success is True
    db.rpc.assert_called_once_with("redeem_referral_atomic", {
        "p_referred_user_id": "u-new",
        "p_code": "fit-abc123",
        "p_credit_months": 1,
    })


@pytest.mark.asyncio
async def test_process_pending_referral_clears_when_already_redeemed():
    db, users_chain = _process_pending_db(
        {"referred_by_code": "fit-abc123"}, [{"id": "r1"}]
    )

    response = await ReferralService.process_pending_referral("u-new", db)

    assert response is None
    # No RPC - the grant already exists; the stale hook is cleared.
    db.rpc.assert_not_called()
    users_chain.update.assert_called_once_with({"referred_by_code": None})


@pytest.mark.asyncio
async def test_process_pending_referral_noop_without_code():
    db, _users_chain = _process_pending_db({"referred_by_code": None}, [])

    response = await ReferralService.process_pending_referral("u-new", db)

    assert response is None
    db.rpc.assert_not_called()
