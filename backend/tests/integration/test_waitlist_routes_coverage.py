"""Residual branch coverage for app.api.v1.waitlist.

Covers the join endpoint's success envelope, the insert-no-row guard, and
every error branch (duplicate email, other PostgREST failures, unexpected
errors).
"""

import asyncio

import pytest
from postgrest.exceptions import APIError as PostgrestAPIError

from app.api.v1.waitlist import (
    EmailAlreadyOnWaitlistError,
    WaitlistJoinRequest,
    _insert_waitlist_entry,
    join_waitlist,
)
from app.core.exceptions import DatabaseError


class _FakeResult:
    def __init__(self, data):
        self.data = data


class _FakeDB:
    def __init__(self, result=None, error=None):
        self._result = result
        self._error = error
        self.calls = []

    def table(self, name):
        self.calls.append(name)
        return self

    def insert(self, payload):
        self.calls.append(payload)
        return self

    def execute(self):
        if self._error is not None:
            raise self._error
        return self._result


def _request(email="new@example.com", full_name="Test User"):
    return WaitlistJoinRequest(email=email, full_name=full_name)


def test_join_waitlist_success():
    db = _FakeDB(
        result=_FakeResult(
            [{"id": "w1", "email": "new@example.com", "full_name": "Test User", "created_at": "now"}]
        )
    )
    result = asyncio.run(_insert_waitlist_entry(_request(), db))
    assert result["data"]["id"] == "w1"
    assert "Successfully joined" in result["message"]
    assert db.calls[0] == "waitlist"


def test_join_waitlist_insert_returns_no_rows():
    db = _FakeDB(result=_FakeResult([]))
    with pytest.raises(DatabaseError, match="Failed to join waitlist"):
        asyncio.run(_insert_waitlist_entry(_request(), db))


def test_join_waitlist_duplicate_email_raises_specific_error():
    err = PostgrestAPIError(
        {"code": "23505", "message": "duplicate key value violates unique constraint", "hint": None, "details": None}
    )
    db = _FakeDB(error=err)
    with pytest.raises(EmailAlreadyOnWaitlistError):
        asyncio.run(_insert_waitlist_entry(_request(), db))


def test_join_waitlist_duplicate_email_via_message_text():
    err = PostgrestAPIError(
        {"code": "23514", "message": "waitlist_email_unique violated", "hint": None, "details": None}
    )
    db = _FakeDB(error=err)
    with pytest.raises(EmailAlreadyOnWaitlistError):
        asyncio.run(_insert_waitlist_entry(_request(), db))


def test_join_waitlist_other_postgrest_error_becomes_database_error():
    err = PostgrestAPIError(
        {"code": "42P01", "message": "relation does not exist", "hint": None, "details": None}
    )
    db = _FakeDB(error=err)
    with pytest.raises(DatabaseError, match="Failed to join waitlist"):
        asyncio.run(_insert_waitlist_entry(_request(), db))


def test_join_waitlist_unexpected_error_becomes_database_error():
    db = _FakeDB(error=RuntimeError("connection refused"))
    with pytest.raises(DatabaseError, match="error occurred"):
        asyncio.run(_insert_waitlist_entry(_request(), db))


def test_join_waitlist_route_is_ip_rate_limited():
    """The route wraps the insert in the IP rate-limited context."""
    import inspect

    src = inspect.getsource(join_waitlist)
    assert "auth_rate_limited_operation" in src
