"""
Phase 2E hardening regression tests.

Covers, in order:
  1. IP rate limits on the three anonymous write endpoints
     (feedback, waitlist, shared_outfits).
  2. Capped multipart reads + a file-count cap on the upload routes.
  3. feedback.py using the shared token-only optional-auth dependency
     instead of its own event-loop-blocking user lookup.
  4. A bound on the previously unbounded calendar events query.
  5. The referral-stats N+1 collapsed into one batched lookup.
  6. The health check distinguishing "column absent" from "check failed".
"""
import inspect
import logging
from types import SimpleNamespace
from typing import Any, Dict, List, Optional
from unittest.mock import Mock

import pytest
from postgrest.exceptions import APIError as PostgrestAPIError

import app.core.ip_rate_limit as ip_rate_limit
import app.main as main_module
from app.api.v1.calendar import get_calendar_events
from app.api.v1.feedback import submit_feedback
from app.api.v1.items import upload_item_images
from app.api.v1.recommendations import _get_user_birth_profile
from app.api.v1.shared_outfits import ShareFeedbackRequest
from app.api.v1.shared_outfits import submit_feedback as submit_share_feedback
from app.api.v1.users import upload_avatar
from app.api.v1.waitlist import WaitlistJoinRequest, join_waitlist
from app.core.exceptions import FileTooLargeError, RateLimitError, ValidationError
from app.core.security import get_optional_user_id
from app.core.uploads import MAX_UPLOAD_FILES, read_upload_capped
from app.services.referral_service import ReferralService


# ---------------------------------------------------------------------------
# Fakes
# ---------------------------------------------------------------------------


async def _no_sleep(_delay):
    return None


def _request(ip: str):
    """Minimal stand-in for a Starlette Request (get_client_ip reads .client)."""
    return SimpleNamespace(client=SimpleNamespace(host=ip))


@pytest.fixture(autouse=True)
def _reset_ip_usage():
    """_ip_usage is a module-level global; isolate every test from the rest."""
    ip_rate_limit._ip_usage.clear()
    yield
    ip_rate_limit._ip_usage.clear()


class _FakeUpload:
    """UploadFile stand-in that reports how many bytes it actually handed out.

    A read()-then-check caller drains the whole body (bytes_served == size);
    a capped chunked reader must stop shortly after crossing the cap.
    """

    def __init__(self, size: int, filename: str = "big.png", content_type: str = "image/png"):
        self.size = size
        self._remaining = size
        self.filename = filename
        self.content_type = content_type
        self.bytes_served = 0

    async def read(self, size: int = -1) -> bytes:
        n = self._remaining if size is None or size < 0 else min(size, self._remaining)
        self._remaining -= n
        self.bytes_served += n
        return b"\0" * n

    async def seek(self, offset: int) -> None:
        assert offset == 0
        self._remaining = self.size - offset


class _RecordingQuery:
    """Chainable postgrest stub that records the calls made against it."""

    def __init__(self, rows: List[Dict[str, Any]], log: List[Any], table: str):
        self._rows = rows
        self._log = log
        self._table = table
        self.range_args: Optional[tuple] = None
        self._single = False

    def _noop(self, *_a, **_k):
        return self

    select = eq = gte = lte = order = in_ = _noop

    def single(self, *_a, **_k):
        self._single = True
        return self

    maybe_single = single

    def limit(self, *_a, **_k):
        return self

    def range(self, start: int, end: int):
        self.range_args = (start, end)
        self._log.append(("range", self._table, start, end))
        return self

    def execute(self):
        self._log.append(("execute", self._table))
        rows = list(self._rows)
        if self.range_args is not None:
            start, end = self.range_args
            rows = rows[start : end + 1]
        if self._single:
            return SimpleNamespace(data=rows[0] if rows else None)
        return SimpleNamespace(data=rows)


class _RecordingDB:
    def __init__(self, tables: Dict[str, List[Dict[str, Any]]]):
        self._tables = tables
        self.log: List[Any] = []
        self.queries: List[_RecordingQuery] = []

    def table(self, name: str) -> _RecordingQuery:
        self.log.append(("table", name))
        q = _RecordingQuery(self._tables.get(name, []), self.log, name)
        self.queries.append(q)
        return q

    def table_calls(self, name: str) -> int:
        return sum(1 for entry in self.log if entry == ("table", name))


# ---------------------------------------------------------------------------
# 1. IP rate limits on anonymous write endpoints
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_waitlist_join_is_ip_rate_limited():
    limit = ip_rate_limit.AUTH_RATE_LIMITS["waitlist signup"]
    db = Mock()
    db.table.return_value.insert.return_value.execute.return_value = SimpleNamespace(
        data=[{"id": "w1", "email": "a@b.com", "full_name": None, "created_at": "now"}]
    )
    req = _request("203.0.113.9")

    for i in range(limit):
        await join_waitlist(WaitlistJoinRequest(email=f"a{i}@b.com"), req, db=db)

    with pytest.raises(RateLimitError):
        await join_waitlist(WaitlistJoinRequest(email="over@b.com"), req, db=db)


@pytest.mark.asyncio
async def test_waitlist_rate_limit_is_per_ip():
    """One IP hitting its cap must not lock out a different IP."""
    limit = ip_rate_limit.AUTH_RATE_LIMITS["waitlist signup"]
    db = Mock()
    db.table.return_value.insert.return_value.execute.return_value = SimpleNamespace(
        data=[{"id": "w1", "email": "a@b.com", "full_name": None, "created_at": "now"}]
    )

    for i in range(limit):
        await join_waitlist(WaitlistJoinRequest(email=f"a{i}@b.com"), _request("198.51.100.1"), db=db)

    # Different IP, still under its own quota.
    await join_waitlist(WaitlistJoinRequest(email="other@b.com"), _request("198.51.100.2"), db=db)


@pytest.mark.asyncio
async def test_shared_outfit_feedback_is_ip_rate_limited():
    limit = ip_rate_limit.AUTH_RATE_LIMITS["shared outfit feedback"]
    share_id = "11111111-1111-1111-1111-111111111111"
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value = (
        SimpleNamespace(data={"id": share_id, "allow_feedback": True, "expires_at": None})
    )
    db.table.return_value.insert.return_value.execute.return_value = SimpleNamespace(
        data=[{"id": "f1", "rating": 5}]
    )
    req = _request("203.0.113.10")
    body = ShareFeedbackRequest(rating=5)

    for _ in range(limit):
        await submit_share_feedback(share_id, body, req, user_id=None, db=db)

    with pytest.raises(RateLimitError):
        await submit_share_feedback(share_id, body, req, user_id=None, db=db)


@pytest.mark.asyncio
async def test_feedback_submission_is_ip_rate_limited(monkeypatch):
    limit = ip_rate_limit.AUTH_RATE_LIMITS["feedback submission"]

    async def fake_create_ticket(**_kwargs):
        return SimpleNamespace(model_dump=lambda **_: {"id": "t1"})

    monkeypatch.setattr(
        "app.services.feedback_service.FeedbackService.create_ticket",
        staticmethod(fake_create_ticket),
    )
    req = _request("203.0.113.11")
    kwargs = dict(
        category="bug_report",
        subject="Broken button",
        description="The save button does nothing at all.",
        contact_email=None,
        device_info=None,
        app_version=None,
        app_platform=None,
        attachments=[],
        user_id=None,
        db=Mock(),
    )

    for _ in range(limit):
        await submit_feedback(req, **kwargs)

    with pytest.raises(RateLimitError):
        await submit_feedback(req, **kwargs)


def test_anonymous_write_limits_are_registered():
    """.get(op, 10) would silently apply a default if a key were missing."""
    for op in ("waitlist signup", "feedback submission", "shared outfit feedback"):
        assert op in ip_rate_limit.AUTH_RATE_LIMITS


# ---------------------------------------------------------------------------
# 2. Upload safety
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_read_upload_capped_rejects_before_buffering_whole_body():
    cap = 10 * 1024 * 1024
    upload = _FakeUpload(size=25 * 1024 * 1024)

    with pytest.raises(FileTooLargeError):
        await read_upload_capped(upload, cap)

    # A plain `await file.read()` would have served all 25MB before any check.
    assert upload.bytes_served <= cap + 1024 * 1024


@pytest.mark.asyncio
async def test_read_upload_capped_reports_the_callers_cap():
    """The batch copy hardcoded 7MB in the error regardless of max_bytes."""
    with pytest.raises(FileTooLargeError) as exc:
        await read_upload_capped(_FakeUpload(size=12 * 1024 * 1024), 10 * 1024 * 1024)

    assert exc.value.details["max_size_mb"] == 10


@pytest.mark.asyncio
async def test_upload_avatar_rejects_oversized_file_without_buffering_it():
    upload = _FakeUpload(size=30 * 1024 * 1024, filename="avatar.png")

    with pytest.raises(FileTooLargeError):
        await upload_avatar(file=upload, user_id="user-1", db=Mock())

    assert upload.bytes_served <= 11 * 1024 * 1024


@pytest.mark.asyncio
async def test_upload_item_images_caps_the_file_count():
    files = [_FakeUpload(size=1024) for _ in range(MAX_UPLOAD_FILES + 1)]

    with pytest.raises(ValidationError):
        await upload_item_images(files=files, user_id="user-1", db=Mock())

    # Rejected before any file was touched.
    assert all(f.bytes_served == 0 for f in files)


@pytest.mark.asyncio
async def test_upload_item_images_rejects_an_oversized_file_across_all_retries(monkeypatch):
    """parallel_with_retry re-invokes the uploader without rewinding the stream.

    Without an explicit seek(0), attempt 1 consumes ~11MB and raises, attempt 2
    consumes the next ~11MB and raises, and attempt 3 reads only the 3MB tail -
    which is under the cap, so a truncated image would be stored as a success.
    """
    uploaded = []

    async def fake_upload_item_image(**kwargs):
        uploaded.append(len(kwargs["file_data"]))
        return {"image_url": "u", "thumbnail_url": "t", "storage_path": "p"}

    monkeypatch.setattr(
        "app.services.storage_service.StorageService.upload_item_image",
        staticmethod(fake_upload_item_image),
    )
    # Keep the retry backoff out of the test's wall clock.
    monkeypatch.setattr("app.utils.retry.asyncio.sleep", _no_sleep)

    oversized = _FakeUpload(size=25 * 1024 * 1024, filename="huge.png")
    result = await upload_item_images(files=[oversized], user_id="user-1", db=Mock())

    assert result["data"]["uploaded_count"] == 0
    assert result["data"]["failed_count"] == 1
    assert uploaded == [], "an oversized file must never reach storage, even truncated"


# ---------------------------------------------------------------------------
# 3. feedback.py optional auth
# ---------------------------------------------------------------------------


def test_feedback_uses_shared_optional_auth_dependency():
    """The removed local get_optional_user ran a blocking DB query on the
    event loop; the shared dependency is token-only and hits no DB at all."""
    import app.api.v1.feedback as feedback_module

    assert not hasattr(feedback_module, "get_optional_user")

    param = inspect.signature(submit_feedback).parameters["user_id"]
    assert param.default.dependency is get_optional_user_id


@pytest.mark.asyncio
async def test_feedback_accepts_anonymous_submission(monkeypatch):
    seen = {}

    async def fake_create_ticket(*, request, user_id, attachment_urls, attachment_storage_paths, db):
        seen["user_id"] = user_id
        return SimpleNamespace(model_dump=lambda **_: {"id": "t1"})

    monkeypatch.setattr(
        "app.services.feedback_service.FeedbackService.create_ticket",
        staticmethod(fake_create_ticket),
    )
    db = _RecordingDB({})

    result = await submit_feedback(
        _request("203.0.113.12"),
        category="bug_report",
        subject="Anon report",
        description="Submitted with no Authorization header at all.",
        contact_email="anon@example.com",
        device_info=None,
        app_version=None,
        app_platform=None,
        attachments=[],
        user_id=None,
        db=db,
    )

    assert result["message"] == "OK"
    assert seen["user_id"] is None
    # No users lookup: the old dependency issued one on every request.
    assert db.table_calls("users") == 0


# ---------------------------------------------------------------------------
# 4. Bounded calendar events query
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_calendar_events_bounds_the_query_with_no_date_filters():
    rows = [
        {
            "id": f"e{i}",
            "title": f"Event {i}",
            "start_time": "2026-01-01T00:00:00",
            "end_time": "2026-01-01T01:00:00",
        }
        for i in range(50)
    ]
    db = _RecordingDB({"calendar_events": rows})

    result = await get_calendar_events(
        start_date=None, end_date=None, limit=10, offset=0, user_id="user-1", db=db
    )

    # Bounded: previously executed with no .range()/.limit() at all.
    assert db.queries[0].range_args == (0, 10)
    assert len(result["data"]["events"]) == 10
    assert result["data"]["has_more"] is True
    assert result["data"]["limit"] == 10


@pytest.mark.asyncio
async def test_calendar_events_reports_no_more_when_under_the_limit():
    rows = [{
            "id": "e1",
            "title": "Only",
            "start_time": "2026-01-01T00:00:00",
            "end_time": "2026-01-01T01:00:00",
        }]
    db = _RecordingDB({"calendar_events": rows})

    result = await get_calendar_events(
        start_date=None, end_date=None, limit=10, offset=0, user_id="user-1", db=db
    )

    assert len(result["data"]["events"]) == 1
    assert result["data"]["has_more"] is False


# ---------------------------------------------------------------------------
# 5b. recommendations.py birth-profile probe (3 round-trips -> 1)
# ---------------------------------------------------------------------------


class _BirthProfileQuery:
    def __init__(self, db: "_BirthProfileDB", columns: str):
        self._db = db
        self._columns = [c.strip() for c in columns.split(",")]

    def eq(self, *_a, **_k):
        return self

    def single(self, *_a, **_k):
        return self

    def execute(self):
        self._db.selects.append(tuple(self._columns))
        err = self._db.errors.get(tuple(self._columns))
        if err is None and len(self._columns) > 1:
            # A combined select fails wholesale if any one column is absent.
            for col in self._columns:
                err = err or self._db.errors.get((col,))
        if err is not None:
            raise err
        return SimpleNamespace(data={c: self._db.values[c] for c in self._columns})


class _BirthProfileDB:
    def __init__(self, values, errors=None):
        self.values = values
        self.errors = errors or {}
        self.selects = []

    def table(self, _name):
        return self

    def select(self, columns):
        return _BirthProfileQuery(self, columns)


def test_birth_profile_uses_one_round_trip_when_the_schema_is_current():
    db = _BirthProfileDB(
        {"birth_date": "1990-01-01", "birth_time": "12:00", "birth_place": "Delhi"}
    )

    profile, missing = _get_user_birth_profile(db, "user-1")

    # Was three selects, one per column.
    assert db.selects == [("birth_date", "birth_time", "birth_place")]
    assert profile == {
        "birth_date": "1990-01-01",
        "birth_time": "12:00",
        "birth_place": "Delhi",
    }
    assert missing is False


def test_birth_profile_falls_back_per_column_on_a_partial_schema():
    """The combined select fails wholesale if any single column is absent, so
    the per-column loop has to survive as the migration-tolerant fallback."""
    db = _BirthProfileDB(
        {"birth_date": "1990-01-01", "birth_time": None, "birth_place": "Delhi"},
        errors={
            ("birth_time",): _postgrest_error(
                "42703", "column users.birth_time does not exist"
            )
        },
    )

    profile, missing = _get_user_birth_profile(db, "user-1")

    assert db.selects[0] == ("birth_date", "birth_time", "birth_place")
    assert db.selects[1:] == [("birth_date",), ("birth_time",), ("birth_place",)]
    assert profile == {"birth_date": "1990-01-01", "birth_place": "Delhi"}
    assert missing is True


def test_birth_profile_propagates_a_non_schema_error():
    """A connectivity/permissions failure must not be swallowed as
    "columns absent" and retried three more times."""
    db = _BirthProfileDB(
        {"birth_date": None, "birth_time": None, "birth_place": None},
        errors={
            ("birth_date", "birth_time", "birth_place"): _postgrest_error(
                "42501", "permission denied for table users"
            )
        },
    )

    with pytest.raises(PostgrestAPIError):
        _get_user_birth_profile(db, "user-1")

    assert db.selects == [("birth_date", "birth_time", "birth_place")]


# ---------------------------------------------------------------------------
# 5. Referral stats N+1
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_referral_stats_batches_the_referred_user_lookup():
    redemptions = [
        {"referred_user_id": f"u{i}", "redeemed_at": "2026-01-01", "referrer_credit_applied": True}
        for i in range(5)
    ]
    users = [{"id": f"u{i}", "email": f"u{i}@example.com", "full_name": f"User {i}"} for i in range(5)]
    db = _RecordingDB(
        {
            "referral_codes": [{"code": "ABC123", "times_used": 5}],
            "referral_redemptions": redemptions,
            "users": users,
        }
    )

    stats = await ReferralService.get_referral_stats("referrer-1", db)

    # One batched lookup, not one per redemption (was 5).
    assert db.table_calls("users") == 1
    assert stats.total_referrals == 5
    assert sorted(r.email for r in stats.referred_users) == [
        f"u{i}@example.com" for i in range(5)
    ]


@pytest.mark.asyncio
async def test_referral_stats_falls_back_to_unknown_for_missing_user_rows():
    db = _RecordingDB(
        {
            "referral_codes": [{"code": "ABC123", "times_used": 1}],
            "referral_redemptions": [
                {"referred_user_id": "ghost", "redeemed_at": "2026-01-01", "referrer_credit_applied": False}
            ],
            "users": [],
        }
    )

    stats = await ReferralService.get_referral_stats("referrer-1", db)

    assert stats.referred_users[0].email == "unknown"
    assert stats.referred_users[0].full_name is None


# ---------------------------------------------------------------------------
# 6. Health check reports the real cause
# ---------------------------------------------------------------------------


def _postgrest_error(code: str, message: str) -> PostgrestAPIError:
    return PostgrestAPIError({"code": code, "message": message, "hint": None, "details": None})


def _db_raising(err: Exception):
    db = Mock()
    db.table.return_value.select.return_value.limit.return_value.execute.side_effect = err
    return db


def test_column_check_logs_absence_as_absence(caplog):
    db = _db_raising(_postgrest_error("42703", "column users.birth_date does not exist"))

    with caplog.at_level(logging.INFO, logger="app.main"):
        assert main_module._column_exists(db, "users", "birth_date") is False

    assert any("absent from the schema" in r.getMessage() for r in caplog.records)
    assert not any(r.levelno >= logging.WARNING for r in caplog.records)


def test_column_check_flags_a_permissions_failure_as_not_a_missing_column(caplog):
    db = _db_raising(_postgrest_error("42501", "permission denied for table users"))

    with caplog.at_level(logging.INFO, logger="app.main"):
        assert main_module._column_exists(db, "users", "birth_date") is False

    warnings = [r for r in caplog.records if r.levelno >= logging.WARNING]
    assert warnings, "a non-schema failure must not be reported as a missing column"
    assert "not a missing column" in warnings[0].getMessage()


def test_column_check_flags_a_connection_failure_as_not_a_missing_column(caplog):
    db = _db_raising(ConnectionError("connection refused"))

    with caplog.at_level(logging.INFO, logger="app.main"):
        assert main_module._column_exists(db, "users", "birth_date") is False

    warnings = [r for r in caplog.records if r.levelno >= logging.WARNING]
    assert warnings
    assert "not a missing column" in warnings[0].getMessage()


def test_table_check_flags_a_non_schema_failure(caplog, monkeypatch):
    monkeypatch.setattr(main_module, "REQUIRED_TABLES", ("items",))
    monkeypatch.setattr(main_module, "REQUIRED_COLUMNS", ())
    monkeypatch.setattr(main_module.settings, "ENABLE_SOCIAL_IMPORT", False)
    db = _db_raising(_postgrest_error("42501", "permission denied for table items"))

    with caplog.at_level(logging.INFO, logger="app.main"):
        missing = main_module._schema_missing(db)

    # Readiness still fails closed...
    assert missing == ["items"]
    # ...but the log says why, instead of implying the table is not there.
    warnings = [r for r in caplog.records if r.levelno >= logging.WARNING]
    assert warnings
    assert "not a missing table" in warnings[0].getMessage()
