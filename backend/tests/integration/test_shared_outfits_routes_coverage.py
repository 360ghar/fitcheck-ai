"""
Coverage for the shared outfit feedback route (app/api/v1/shared_outfits.py).

The module exposes a single public write endpoint: POST /{share_id}/feedback.
This file covers every branch of submit_feedback: anonymous + authenticated
success, share-not-found, feedback disabled, expired share link, insert
returning no row, generic DB errors (wrapped as DatabaseError), plus the
ISO-datetime parsing helper and the ShareExpiredError shape.

The route is called DIRECTLY with FakeDB / patched query builders — no HTTP
and no real DB. The real in-memory auth rate limiter runs (no network), with a
distinct client IP per test so the shared usage map never crosses limits.
"""
from datetime import datetime, timezone
from unittest.mock import Mock
from uuid import UUID

import pytest
from pydantic import ValidationError

from app.api.v1.shared_outfits import (
    ShareExpiredError,
    ShareFeedbackRequest,
    _parse_iso_datetime,
    submit_feedback,
)
from app.core.exceptions import DatabaseError, PermissionDeniedError, SharedOutfitNotFoundError
from tests.utils.fake_db import FakeBuilder, FakeDB, FakeResult

SHARE_ID = UUID("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")


def _share_row(share_id=None, allow_feedback=True, expires_at=None):
    return {
        "id": str(share_id or SHARE_ID),
        "allow_feedback": allow_feedback,
        "expires_at": expires_at,
    }


def _http_request(ip="203.0.113.20"):
    request = Mock()
    request.client = Mock()
    request.client.host = ip
    return request


class _EmptyInsertBuilder(FakeBuilder):
    """Insert returns zero rows — the DatabaseError path."""

    def execute(self):
        if self._mode == "insert":
            return FakeResult(data=[])
        return super().execute()


class _EmptyInsertDB(FakeDB):
    def table(self, name):
        return _EmptyInsertBuilder(self, name)


def _failing_db(error=None):
    """A FakeDB whose every execute call raises (generic error branch)."""
    error = error or RuntimeError("db boom")
    db = FakeDB(rows={})
    original_table = db.table

    def table(name):
        builder = original_table(name)
        builder.execute = Mock(side_effect=error)
        return builder

    db.table = table
    return db


@pytest.mark.asyncio
async def test_submit_feedback_success_anonymous():
    db = FakeDB(rows={"shared_outfits": [_share_row()]})
    request = ShareFeedbackRequest(rating=5, comment="Love this outfit")

    result = await submit_feedback(
        share_id=SHARE_ID,
        request=request,
        http_request=_http_request(),
        user_id=None,
        db=db,
    )

    assert result["message"] == "Created"
    assert result["data"]["shared_outfit_id"] == str(SHARE_ID)
    db.assert_insert(
        "share_feedback",
        shared_outfit_id=str(SHARE_ID),
        user_id=None,
        rating=5,
        comment="Love this outfit",
    )


@pytest.mark.asyncio
async def test_submit_feedback_success_authenticated_without_comment():
    db = FakeDB(rows={"shared_outfits": [_share_row()]})
    request = ShareFeedbackRequest(rating=4)

    result = await submit_feedback(
        share_id=SHARE_ID,
        request=request,
        http_request=_http_request(ip="203.0.113.21"),
        user_id="user-1",
        db=db,
    )

    assert result["message"] == "Created"
    assert result["data"]["user_id"] == "user-1"
    db.assert_insert(
        "share_feedback",
        shared_outfit_id=str(SHARE_ID),
        user_id="user-1",
        rating=4,
        comment=None,
    )


@pytest.mark.asyncio
async def test_submit_feedback_share_not_found():
    db = FakeDB(rows={})
    request = ShareFeedbackRequest(rating=5)

    with pytest.raises(SharedOutfitNotFoundError):
        await submit_feedback(
            share_id=SHARE_ID,
            request=request,
            http_request=_http_request(ip="203.0.113.22"),
            user_id=None,
            db=db,
        )


@pytest.mark.asyncio
async def test_submit_feedback_disabled_for_share():
    db = FakeDB(rows={"shared_outfits": [_share_row(allow_feedback=False)]})
    request = ShareFeedbackRequest(rating=5)

    with pytest.raises(PermissionDeniedError):
        await submit_feedback(
            share_id=SHARE_ID,
            request=request,
            http_request=_http_request(ip="203.0.113.23"),
            user_id=None,
            db=db,
        )


@pytest.mark.asyncio
async def test_submit_feedback_expired_share():
    db = FakeDB(
        rows={"shared_outfits": [_share_row(expires_at="2020-01-01T00:00:00Z")]}
    )
    request = ShareFeedbackRequest(rating=5)

    with pytest.raises(ShareExpiredError):
        await submit_feedback(
            share_id=SHARE_ID,
            request=request,
            http_request=_http_request(ip="203.0.113.24"),
            user_id=None,
            db=db,
        )


@pytest.mark.asyncio
async def test_submit_feedback_insert_without_row_raises_database_error():
    db = _EmptyInsertDB(rows={"shared_outfits": [_share_row()]})
    request = ShareFeedbackRequest(rating=5)

    with pytest.raises(DatabaseError) as exc_info:
        await submit_feedback(
            share_id=SHARE_ID,
            request=request,
            http_request=_http_request(ip="203.0.113.25"),
            user_id=None,
            db=db,
        )

    assert exc_info.value.error_code == "DATABASE_ERROR"


@pytest.mark.asyncio
async def test_submit_feedback_generic_db_error_wrapped_as_database_error():
    db = _failing_db()
    request = ShareFeedbackRequest(rating=5)

    with pytest.raises(DatabaseError) as exc_info:
        await submit_feedback(
            share_id=SHARE_ID,
            request=request,
            http_request=_http_request(ip="203.0.113.26"),
            user_id=None,
            db=db,
        )

    assert exc_info.value.error_code == "DATABASE_ERROR"
    assert exc_info.value.details == {"operation": "submit_feedback"}


# =============================================================================
# Request validation + helpers
# =============================================================================


def test_feedback_request_rejects_rating_out_of_range():
    with pytest.raises(ValidationError):
        ShareFeedbackRequest(rating=6)


def test_parse_iso_datetime_none_returns_none():
    assert _parse_iso_datetime(None) is None


def test_parse_iso_datetime_utc_suffix():
    parsed = _parse_iso_datetime("2026-01-01T12:00:00Z")
    assert parsed == datetime(2026, 1, 1, 12, 0, 0, tzinfo=timezone.utc)


def test_parse_iso_datetime_naive_gets_utc():
    parsed = _parse_iso_datetime("2026-01-01T12:00:00")
    assert parsed.tzinfo == timezone.utc
    assert parsed.hour == 12


def test_parse_iso_datetime_invalid_returns_none():
    assert _parse_iso_datetime("not-a-date") is None


def test_share_expired_error_shape():
    error = ShareExpiredError(share_id=str(SHARE_ID))
    assert error.status_code == 410
    assert error.error_code == "SHARE_EXPIRED"
    assert error.to_dict()["details"] == {"share_id": str(SHARE_ID)}
