"""
Regression test for ReferralService.validate_referral_code with a zero-row lookup.

postgrest-py's `.maybe_single().execute()` returns bare `None` (not an object
with `.data = None`) when the query matches no rows - this used to crash with
`AttributeError: 'NoneType' object has no attribute 'data'` for any invalid code.
"""
import uuid
from datetime import datetime, timezone
from types import SimpleNamespace
from unittest.mock import Mock

import pytest

from app.core.config import settings
from app.core.exceptions import DatabaseError
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


# =============================================================================
# Code normalization / generation / share URL
# =============================================================================


def test_normalize_code_strips_and_lowercases():
    assert ReferralService._normalize_code("  FiT-aBc123  ") == "fit-abc123"


def test_normalize_code_handles_none():
    assert ReferralService._normalize_code(None) == ""


def test_generate_code_from_name_slugifies_name_and_id():
    assert (
        ReferralService.generate_code_from_name("user-1", "Alice Cooper")
        == "alicecooper-user1"
    )


def test_generate_code_from_name_defaults_missing_name_to_user():
    assert ReferralService.generate_code_from_name("user-1", None) == "user-user1"


def test_generate_code_from_name_defaults_short_or_empty_slug_to_user():
    assert ReferralService.generate_code_from_name("user-1", "Jo") == "user-user1"
    assert ReferralService.generate_code_from_name("user-1", "!!@# 42") == "user-user1"


def test_generate_code_from_name_truncates_long_names_to_20_chars():
    code = ReferralService.generate_code_from_name("user-1", "A" * 30)
    assert code == "a" * 20 + "-user1"
    assert len(code.split("-")[0]) == 20


def test_generate_code_from_name_uses_first_six_id_chars():
    code = ReferralService.generate_code_from_name(
        "11111111-2222-3333-4444-555555555555", "Alice"
    )
    assert code == "alice-111111"


def test_get_share_url_strips_trailing_slash_from_frontend_url(monkeypatch):
    monkeypatch.setattr(settings, "FRONTEND_URL", "https://app.fitcheck.example.com/")

    assert (
        ReferralService.get_share_url("fit-abc123")
        == "https://app.fitcheck.example.com/auth/register?ref=fit-abc123"
    )


# =============================================================================
# get_or_create_referral_code
# =============================================================================


@pytest.mark.asyncio
async def test_get_or_create_referral_code_returns_existing_code(monkeypatch, fake_db):
    monkeypatch.setattr(settings, "FRONTEND_URL", "https://app.fitcheck.example.com/")
    fake_db.rows["referral_codes"] = [{
        "user_id": "u1",
        "code": "alice-abc",
        "times_used": 2,
        "created_at": "2026-08-01T00:00:00Z",
    }]

    response = await ReferralService.get_or_create_referral_code("u1", "Alice", fake_db)

    assert response.code == "alice-abc"
    assert response.times_used == 2
    assert response.created_at == datetime(2026, 8, 1, tzinfo=timezone.utc)
    assert response.share_url == "https://app.fitcheck.example.com/auth/register?ref=alice-abc"
    assert fake_db.inserts == []


@pytest.mark.asyncio
async def test_get_or_create_referral_code_creates_new_code(monkeypatch, fake_db):
    monkeypatch.setattr(settings, "FRONTEND_URL", "https://app.fitcheck.example.com/")

    response = await ReferralService.get_or_create_referral_code(
        "user-1", "Alice Cooper", fake_db
    )

    assert response.code == "alicecooper-user1"
    assert response.times_used == 0
    assert response.share_url == "https://app.fitcheck.example.com/auth/register?ref=alicecooper-user1"
    fake_db.assert_insert(
        "referral_codes",
        user_id="user-1",
        code="alicecooper-user1",
        times_used=0,
    )


@pytest.mark.asyncio
async def test_get_or_create_referral_code_retries_on_collision(monkeypatch):
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = (
        Mock(data=[])
    )
    db.table.return_value.insert.return_value.execute.side_effect = [
        Exception('duplicate key value violates unique constraint "referral_codes_code_key"'),
        Mock(data=[{"code": "alice-user1-dead", "created_at": "2026-08-01T00:00:00Z"}]),
    ]
    monkeypatch.setattr(uuid, "uuid4", lambda: SimpleNamespace(hex="deadbeef"))

    response = await ReferralService.get_or_create_referral_code("user-1", "Alice", db)

    assert response.code == "alice-user1-dead"
    assert db.table.return_value.insert.call_count == 2


@pytest.mark.asyncio
async def test_get_or_create_referral_code_raises_when_collisions_exhausted():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = (
        Mock(data=[])
    )
    db.table.return_value.insert.return_value.execute.side_effect = Exception(
        'duplicate key value violates unique constraint "referral_codes_code_key"'
    )

    with pytest.raises(DatabaseError, match="Failed to create a unique referral code"):
        await ReferralService.get_or_create_referral_code("user-1", "Alice", db)

    # Five entropy retries, then give up.
    assert db.table.return_value.insert.call_count == 5


@pytest.mark.asyncio
async def test_get_or_create_referral_code_re_raises_non_collision_insert_errors():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = (
        Mock(data=[])
    )
    db.table.return_value.insert.return_value.execute.side_effect = RuntimeError("boom")

    with pytest.raises(DatabaseError, match="Failed to get referral code: boom"):
        await ReferralService.get_or_create_referral_code("user-1", "Alice", db)


@pytest.mark.asyncio
async def test_get_or_create_referral_code_raises_when_insert_echoes_no_row():
    """An insert that succeeds but echoes no row must not fabricate a code."""
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = (
        Mock(data=[])
    )
    db.table.return_value.insert.return_value.execute.return_value = Mock(data=[])

    with pytest.raises(DatabaseError, match="Failed to create a unique referral code"):
        await ReferralService.get_or_create_referral_code("user-1", "Alice", db)


@pytest.mark.asyncio
async def test_get_or_create_referral_code_wraps_read_errors():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.side_effect = (
        RuntimeError("boom")
    )

    with pytest.raises(DatabaseError, match="Failed to get referral code: boom"):
        await ReferralService.get_or_create_referral_code("user-1", "Alice", db)


# =============================================================================
# get_referral_stats
# =============================================================================


@pytest.mark.asyncio
async def test_get_referral_stats_with_redemptions_and_credits(fake_db):
    fake_db.rows["referral_codes"] = [{
        "user_id": "u1",
        "code": "alice-abc",
        "times_used": 3,
        "created_at": "2026-08-01T00:00:00Z",
    }]
    fake_db.rows["referral_redemptions"] = [
        {"referrer_user_id": "u1", "referred_user_id": "u2", "redeemed_at": "2026-08-02T00:00:00Z", "referrer_credit_applied": True},
        {"referrer_user_id": "u1", "referred_user_id": "u3", "redeemed_at": "2026-08-03T00:00:00Z", "referrer_credit_applied": False},
        {"referrer_user_id": "u1", "referred_user_id": "u9", "redeemed_at": "2026-08-05T00:00:00Z", "referrer_credit_applied": False},
    ]
    fake_db.rows["users"] = [
        {"id": "u2", "email": "bob@example.com", "full_name": "Bob"},
        {"id": "u3", "email": "carol@example.com", "full_name": "Carol"},
    ]

    stats = await ReferralService.get_referral_stats("u1", fake_db)

    assert stats.code == "alice-abc"
    assert stats.times_used == 3
    assert stats.total_referrals == 3
    assert stats.successful_referrals == 1
    assert stats.pending_referrals == 2
    assert stats.credits_earned == settings.REFERRAL_CREDIT_MONTHS
    assert stats.months_earned == settings.REFERRAL_CREDIT_MONTHS
    assert [r.email for r in stats.referred_users] == [
        "bob@example.com", "carol@example.com", "unknown"
    ]
    assert stats.referred_users[0].full_name == "Bob"
    assert stats.referred_users[0].credit_applied is True
    assert stats.referred_users[2].full_name is None
    assert stats.share_url.endswith("/auth/register?ref=alice-abc")


@pytest.mark.asyncio
async def test_get_referral_stats_skips_users_lookup_without_ids(fake_db):
    fake_db.rows["referral_codes"] = [{"user_id": "u1", "code": "alice-abc", "times_used": 1}]
    fake_db.rows["referral_redemptions"] = [
        {"referrer_user_id": "u1", "referred_user_id": None, "redeemed_at": "2026-08-04T00:00:00Z", "referrer_credit_applied": False},
    ]

    stats = await ReferralService.get_referral_stats("u1", fake_db)

    assert stats.total_referrals == 1
    assert stats.successful_referrals == 0
    assert stats.referred_users[0].email == "unknown"
    # No batched users select ran (no referred ids to resolve).
    assert ("users", "in") not in [f[:2] for f in fake_db.filters]


@pytest.mark.asyncio
async def test_get_referral_stats_without_redemptions(fake_db):
    fake_db.rows["referral_codes"] = [{"user_id": "u1", "code": "alice-abc", "times_used": 1}]

    stats = await ReferralService.get_referral_stats("u1", fake_db)

    assert stats.code == "alice-abc"
    assert stats.total_referrals == 0
    assert stats.successful_referrals == 0
    assert stats.pending_referrals == 0
    assert stats.referred_users == []
    assert stats.credits_earned == 0


@pytest.mark.asyncio
async def test_get_referral_stats_creates_code_when_missing(fake_db):
    fake_db.rows["users"] = [{"id": "u1", "full_name": "Alice Wonder"}]

    stats = await ReferralService.get_referral_stats("u1", fake_db)

    assert stats.code == "alicewonder-u1"
    assert stats.times_used == 0
    assert stats.total_referrals == 0
    fake_db.assert_insert("referral_codes", user_id="u1", code="alicewonder-u1")


@pytest.mark.asyncio
async def test_get_referral_stats_wraps_errors():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.side_effect = (
        RuntimeError("boom")
    )

    with pytest.raises(DatabaseError, match="Failed to get referral stats: boom"):
        await ReferralService.get_referral_stats("u1", db)


# =============================================================================
# validate_referral_code
# =============================================================================


@pytest.mark.asyncio
async def test_validate_referral_code_uses_embedded_referrer_name(fake_db):
    fake_db.rows["referral_codes"] = [{
        "code": "fit-abc123",
        "user_id": "u1",
        "users": {"full_name": "Alex"},
    }]

    response = await ReferralService.validate_referral_code("FIT-ABC123", fake_db)

    assert response.valid is True
    assert response.referrer_name == "Alex"
    assert "Referred by Alex" in response.message
    assert "1 month" in response.message


@pytest.mark.asyncio
async def test_validate_referral_code_falls_back_to_users_lookup(fake_db):
    fake_db.rows["referral_codes"] = [{"code": "fit-abc123", "user_id": "u1"}]
    fake_db.rows["users"] = [{"id": "u1", "full_name": "Alex"}]

    response = await ReferralService.validate_referral_code("fit-abc123", fake_db)

    assert response.valid is True
    assert response.referrer_name == "Alex"


@pytest.mark.asyncio
async def test_validate_referral_code_defaults_name_when_lookup_empty(fake_db):
    fake_db.rows["referral_codes"] = [{"code": "fit-abc123", "user_id": "u1"}]

    response = await ReferralService.validate_referral_code("fit-abc123", fake_db)

    assert response.valid is True
    assert response.referrer_name == "A friend"
    assert "Referred by a friend" in response.message


@pytest.mark.asyncio
async def test_validate_referral_code_pluralizes_months(fake_db, monkeypatch):
    monkeypatch.setattr(settings, "REFERRAL_CREDIT_MONTHS", 2)
    fake_db.rows["referral_codes"] = [{
        "code": "fit-abc123",
        "user_id": "u1",
        "users": {"full_name": "Alex"},
    }]

    response = await ReferralService.validate_referral_code("fit-abc123", fake_db)

    assert response.valid is True
    assert "2 months" in response.message


@pytest.mark.asyncio
async def test_validate_referral_code_returns_invalid_on_error():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.side_effect = (
        RuntimeError("boom")
    )

    response = await ReferralService.validate_referral_code("fit-abc123", db)

    assert response.valid is False
    assert response.message == "Error validating referral code"


# =============================================================================
# redeem_referral - durable retry hook edge cases
# =============================================================================


@pytest.mark.asyncio
async def test_redeem_referral_tolerates_persist_hook_failure():
    """A failure writing the pending-code hook must not fail the redemption."""
    db = Mock()
    db.table.return_value.update.return_value.eq.return_value.execute.side_effect = [
        RuntimeError("boom"),  # persist hook write fails
        Mock(data=[]),  # post-RPC clear
    ]
    db.rpc.return_value.execute.return_value = Mock(data=[{
        "success": True,
        "message": "Referral code applied",
        "credit_months": 1,
    }])

    response = await ReferralService.redeem_referral("u-new", "FIT-ABC123", db)

    assert response.success is True
    db.rpc.assert_called_once()


@pytest.mark.asyncio
async def test_redeem_referral_raises_when_rpc_result_is_not_a_dict():
    db = Mock()
    db.rpc.return_value.execute.return_value = Mock(data=[])

    with pytest.raises(DatabaseError, match="no result"):
        await ReferralService.redeem_referral("u-new", "FIT-ABC123", db)


@pytest.mark.asyncio
async def test_redeem_referral_tolerates_rejection_clear_failure():
    """The post-rejection hook clear is best-effort; the definitive rejection
    still reaches the caller."""
    db = Mock()
    db.table.return_value.update.return_value.eq.return_value.execute.side_effect = [
        Mock(data=[]),
        RuntimeError("boom"),  # clear after rejection fails
    ]
    db.rpc.return_value.execute.return_value = Mock(data=[{
        "success": False,
        "message": "Referral code not found",
        "credit_months": 0,
    }])

    response = await ReferralService.redeem_referral("u-new", "NOPE", db)

    assert response.success is False
    assert response.message == "Referral code not found"


@pytest.mark.asyncio
async def test_redeem_referral_tolerates_success_clear_failure():
    db = Mock()
    db.table.return_value.update.return_value.eq.return_value.execute.side_effect = [
        Mock(data=[]),
        RuntimeError("boom"),  # clear after the grant fails
    ]
    db.rpc.return_value.execute.return_value = Mock(data=[{
        "success": True,
        "message": "Referral code applied",
        "credit_months": 1,
    }])

    response = await ReferralService.redeem_referral("u-new", "FIT-ABC123", db)

    assert response.success is True
    assert response.credit_months == 1


@pytest.mark.asyncio
async def test_redeem_referral_handles_unspecified_success_field():
    """A dict payload without a boolean success key skips both clear hooks;
    the response still reports the payload's (falsy) success."""
    db = Mock()
    db.rpc.return_value.execute.return_value = Mock(data=[{
        "success": None,
        "message": "no verdict",
        "credit_months": 0,
    }])

    response = await ReferralService.redeem_referral("u-new", "FIT-ABC123", db)

    assert response.success is False
    assert response.message == "no verdict"
    assert response.credit_months == 0
    # Only the pre-RPC persist hook was written; no post-RPC clear ran.
    assert db.table.return_value.update.call_count == 1


# =============================================================================
# process_pending_referral
# =============================================================================


@pytest.mark.asyncio
async def test_process_pending_referral_returns_none_on_error():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.side_effect = (
        RuntimeError("boom")
    )

    response = await ReferralService.process_pending_referral("u-new", db)

    assert response is None
    db.rpc.assert_not_called()
