"""
Tests for the dead pooled-connection retry on referral read/redemption paths.

2026-08-03 incident class: a dead pooled Supabase HTTP/2 connection made
GET /referral/code, /referral/stats, POST /referral/validate and
POST /referral/redeem 500 (``<ConnectionTerminated ...>``, bare error codes,
"Server disconnected"). These tests pin the retry-once-through-a-fresh-client
behavior on the paths that were still unwrapped: validate_referral_code and
redeem_referral.
"""
from unittest.mock import Mock

import httpx
import pytest

from app.services.referral_service import ReferralService


def _patch_supabase_db(monkeypatch, fresh_db):
    """Make execute_with_reconnect hand out `fresh_db` after a rebuild."""
    from app.db.connection import SupabaseDB

    monkeypatch.setattr(
        SupabaseDB, "rebuild_service_client", staticmethod(lambda _stale=None: fresh_db)
    )


def _db_with_code_row(row):
    db = Mock()
    result = Mock(data=row)
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = result
    return db


@pytest.mark.asyncio
async def test_validate_referral_code_retries_once_on_dead_connection(monkeypatch):
    dead_db = Mock()
    dead_db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.side_effect = (
        httpx.RemoteProtocolError("Server disconnected")
    )
    fresh_db = _db_with_code_row(
        {"code": "fit-abc123", "user_id": "u-1", "users": {"full_name": "Alex"}}
    )
    _patch_supabase_db(monkeypatch, fresh_db)

    response = await ReferralService.validate_referral_code("FIT-ABC123", dead_db)

    assert response.valid is True
    assert response.referrer_name == "Alex"


@pytest.mark.asyncio
async def test_redeem_referral_retries_once_on_dead_connection(monkeypatch):
    dead_db = Mock()
    dead_db.rpc.return_value.execute.side_effect = RuntimeError("41")  # bare h2 error code
    fresh_db = Mock()
    fresh_db.rpc.return_value.execute.return_value = Mock(
        data=[{
            "success": True,
            "message": "Referral code applied",
            "credit_months": 1,
        }]
    )
    _patch_supabase_db(monkeypatch, fresh_db)

    response = await ReferralService.redeem_referral("u-new", "FIT-ABC123", dead_db)

    assert response.success is True
    assert response.credit_months == 1
    # The retried call went to the atomic RPC (one transaction - safe to replay).
    fresh_db.rpc.assert_called_once_with("redeem_referral_atomic", {
        "p_referred_user_id": "u-new",
        "p_code": "fit-abc123",
        "p_credit_months": 1,
    })
