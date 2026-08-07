"""
Tests for JobPersistenceStore - the shared durable-job CAS persistence used
by the batch/photoshoot in-memory job services.

Covers the compare-and-set write semantics, coalesced flushing, terminal
external-status adoption, and the no-persistence-db no-op paths. Uses FakeDB
for successful writes and Mock chains for CAS-lost / DB-failure paths.
"""
import asyncio
from datetime import datetime, timedelta, timezone
from enum import Enum
from unittest.mock import Mock

import pytest

from app.services.job_persistence import (
    JobPersistenceStore,
    _status_value,
)


class _Status(str, Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    FAILED = "failed"


_TERMINAL = frozenset({_Status.COMPLETED, _Status.CANCELLED, _Status.FAILED})


class _FakeJob:
    """Minimal stand-in for BatchJob/PhotoshootJob: the attributes the store
    reads and mutates (persistence_db, dirty flag, CAS anchor, status,
    cancelled/event for adoption)."""

    def __init__(
        self,
        status,
        *,
        job_id="job-1",
        user_id="user-1",
        persistence_db=None,
        persistence_dirty=False,
        persisted_status=None,
    ):
        self.job_id = job_id
        self.user_id = user_id
        self.status = status
        self.cancelled = False
        self.cancel_event = asyncio.Event()
        self.persistence_db = persistence_db
        self.persistence_dirty = persistence_dirty
        self._persisted_status = persisted_status


def _build_payload(job, *, status=None, error_message=None):
    payload = {
        "id": job.job_id,
        "user_id": job.user_id,
        "status": (status or job.status).value,
    }
    if error_message is not None:
        payload["error_message"] = error_message
    return payload


def _make_store(**overrides):
    kwargs = dict(
        table="extraction_jobs",
        terminal_statuses=_TERMINAL,
        build_payload=_build_payload,
        cancelled_member=_Status.CANCELLED,
        logger=Mock(),
    )
    kwargs.update(overrides)
    return JobPersistenceStore(**kwargs)


# =============================================================================
# Parsing
# =============================================================================


def test_parse_created_at_parses_z_suffixed_iso():
    store = _make_store()
    parsed = store.parse_created_at("2026-08-07T10:00:00Z")
    assert parsed == datetime(2026, 8, 7, 10, 0, tzinfo=timezone.utc)


def test_parse_created_at_parses_naive_iso_as_aware_utc():
    store = _make_store()
    parsed = store.parse_created_at("2026-08-07T10:00:00")
    assert parsed == datetime(2026, 8, 7, 10, 0, tzinfo=timezone.utc)


def test_parse_created_at_normalizes_naive_datetime():
    store = _make_store()
    parsed = store.parse_created_at(datetime(2026, 8, 7, 10, 0))
    assert parsed == datetime(2026, 8, 7, 10, 0, tzinfo=timezone.utc)


def test_parse_created_at_converts_offset_datetime_to_utc():
    store = _make_store()
    parsed = store.parse_created_at(
        datetime(2026, 8, 7, 15, 0, tzinfo=timezone(timedelta(hours=5)))
    )
    assert parsed == datetime(2026, 8, 7, 10, 0, tzinfo=timezone.utc)


def test_parse_created_at_falls_back_to_utcnow_on_garbage(monkeypatch):
    fixed = datetime(2026, 1, 1, 0, 0, tzinfo=timezone.utc)
    monkeypatch.setattr(
        "app.services.job_persistence.utcnow", lambda: fixed
    )
    store = _make_store()
    assert store.parse_created_at("not-a-date") == fixed


# =============================================================================
# mark_dirty / create
# =============================================================================


def test_mark_dirty_sets_flag_only_with_persistence_db():
    store = _make_store()
    job = _FakeJob(_Status.PENDING, persistence_db=object())
    store.mark_dirty(job)
    assert job.persistence_dirty is True

    no_db_job = _FakeJob(_Status.PENDING, persistence_db=None)
    store.mark_dirty(no_db_job)
    assert no_db_job.persistence_dirty is False


@pytest.mark.asyncio
async def test_create_returns_true_without_persistence_db(fake_db):
    store = _make_store()
    job = _FakeJob(_Status.PENDING, persistence_db=None)

    ok = await store.create(job)

    assert ok is True
    assert fake_db.inserts == []


@pytest.mark.asyncio
async def test_create_upserts_row_and_anchors_status(fake_db):
    store = _make_store()
    job = _FakeJob(_Status.PENDING, persistence_db=fake_db, persistence_dirty=True)

    ok = await store.create(job)

    assert ok is True
    assert fake_db.inserts == [
        (
            "extraction_jobs",
            {"id": "job-1", "user_id": "user-1", "status": "pending"},
            "id",
        )
    ]
    assert job._persisted_status == _Status.PENDING
    assert job.persistence_dirty is False


@pytest.mark.asyncio
async def test_create_returns_false_when_upsert_returns_no_row():
    store = _make_store()
    db = Mock()
    db.table.return_value.upsert.return_value.execute.return_value = Mock(data=[])
    job = _FakeJob(_Status.PENDING, persistence_db=db, persistence_dirty=True)

    ok = await store.create(job)

    assert ok is False
    assert job.persistence_dirty is True
    store._logger.warning.assert_called_once()


@pytest.mark.asyncio
async def test_create_accepts_none_data_as_ok():
    """postgrest can echo a null result for an upsert; that must not count
    as a failed create (the row is still written)."""
    store = _make_store()
    db = Mock()
    db.table.return_value.upsert.return_value.execute.return_value = Mock(data=None)
    job = _FakeJob(_Status.PENDING, persistence_db=db)

    ok = await store.create(job)

    assert ok is True
    assert job._persisted_status == _Status.PENDING


# =============================================================================
# flush - coalesced dirty writes
# =============================================================================


@pytest.mark.asyncio
async def test_flush_clears_dirty_and_returns_true_without_db():
    store = _make_store()
    job = _FakeJob(_Status.PENDING, persistence_db=None, persistence_dirty=True)

    ok = await store.flush(job)

    assert ok is True
    assert job.persistence_dirty is False


@pytest.mark.asyncio
async def test_flush_noop_when_not_dirty(fake_db):
    store = _make_store()
    job = _FakeJob(_Status.PENDING, persistence_db=fake_db, persistence_dirty=False)

    ok = await store.flush(job)

    assert ok is True
    assert fake_db.updates == []


@pytest.mark.asyncio
async def test_flush_cas_success_updates_row_and_clears_dirty(fake_db):
    fake_db.rows["extraction_jobs"] = [
        {"id": "job-1", "user_id": "user-1", "status": "pending"}
    ]
    store = _make_store()
    job = _FakeJob(
        _Status.RUNNING,
        persistence_db=fake_db,
        persistence_dirty=True,
        persisted_status=_Status.PENDING,
    )

    ok = await store.flush(job)

    assert ok is True
    assert job._persisted_status == _Status.RUNNING
    assert job.persistence_dirty is False
    fake_db.assert_update("extraction_jobs", status="running")
    assert ("extraction_jobs", "eq", "status", "pending") in fake_db.filters


@pytest.mark.asyncio
async def test_flush_cas_lost_with_missing_row_stops_retrying(fake_db):
    store = _make_store()
    job = _FakeJob(
        _Status.RUNNING,
        persistence_db=fake_db,
        persistence_dirty=True,
        persisted_status=_Status.PENDING,
    )

    ok = await store.flush(job)

    assert ok is False
    assert job.persistence_dirty is False


@pytest.mark.asyncio
async def test_flush_adopts_external_terminal_status(fake_db):
    """A second worker already persisted a terminal status; the in-memory job
    adopts it instead of silently diverging."""
    fake_db.rows["extraction_jobs"] = [
        {"id": "job-1", "user_id": "user-1", "status": "completed"}
    ]
    store = _make_store()
    job = _FakeJob(
        _Status.RUNNING,
        persistence_db=fake_db,
        persistence_dirty=True,
        persisted_status=_Status.PENDING,
    )

    ok = await store.flush(job)

    assert ok is True
    assert job.status == _Status.COMPLETED
    assert job._persisted_status == _Status.COMPLETED
    assert job.persistence_dirty is False
    assert job.cancelled is False


@pytest.mark.asyncio
async def test_flush_adopting_cancelled_sets_event(fake_db):
    fake_db.rows["extraction_jobs"] = [
        {"id": "job-1", "user_id": "user-1", "status": "cancelled"}
    ]
    store = _make_store()
    job = _FakeJob(
        _Status.RUNNING,
        persistence_db=fake_db,
        persistence_dirty=True,
        persisted_status=_Status.PENDING,
    )

    ok = await store.flush(job)

    assert ok is True
    assert job.status == _Status.CANCELLED
    assert job.cancelled is True
    assert job.cancel_event.is_set()


@pytest.mark.asyncio
async def test_flush_retries_cas_with_read_status_and_succeeds(fake_db):
    """CAS lost against our anchor, but the authoritative row is a live
    non-terminal status: re-anchor and retry once."""
    fake_db.rows["extraction_jobs"] = [
        {"id": "job-1", "user_id": "user-1", "status": "running"}
    ]
    store = _make_store()
    job = _FakeJob(
        _Status.RUNNING,
        persistence_db=fake_db,
        persistence_dirty=True,
        persisted_status=_Status.PENDING,
    )

    ok = await store.flush(job)

    assert ok is True
    assert job._persisted_status == _Status.RUNNING
    assert job.persistence_dirty is False


@pytest.mark.asyncio
async def test_flush_retry_cas_lost_keeps_dirty(fake_db, monkeypatch):
    fake_db.rows["extraction_jobs"] = [
        {"id": "job-1", "user_id": "user-1", "status": "running"}
    ]
    store = _make_store()
    job = _FakeJob(
        _Status.RUNNING,
        persistence_db=fake_db,
        persistence_dirty=True,
        persisted_status=_Status.PENDING,
    )

    async def fake_read(job):
        # Authoritative status keeps changing under us - every retry loses.
        return "other"

    monkeypatch.setattr(store, "_read_status", fake_read)

    ok = await store.flush(job)

    assert ok is False
    assert job.persistence_dirty is True


# =============================================================================
# transition - required terminal writes
# =============================================================================


@pytest.mark.asyncio
async def test_transition_returns_true_without_persistence_db():
    store = _make_store()
    job = _FakeJob(_Status.RUNNING, persistence_db=None)

    ok = await store.transition(job, status=_Status.COMPLETED)

    assert ok is True


@pytest.mark.asyncio
async def test_transition_cas_success_writes_terminal_payload(fake_db):
    fake_db.rows["extraction_jobs"] = [
        {"id": "job-1", "user_id": "user-1", "status": "pending"}
    ]
    store = _make_store()
    job = _FakeJob(
        _Status.PENDING,
        persistence_db=fake_db,
        persistence_dirty=True,
        persisted_status=_Status.PENDING,
    )

    ok = await store.transition(
        job, status=_Status.COMPLETED, error_message=None
    )

    assert ok is True
    assert job.status == _Status.PENDING  # memory is the caller's to mutate
    assert job._persisted_status == _Status.COMPLETED
    assert job.persistence_dirty is False
    fake_db.assert_update(
        "extraction_jobs",
        status="completed",
        error_message=None,
    )


@pytest.mark.asyncio
async def test_transition_cas_lost_with_missing_row_returns_false(fake_db):
    store = _make_store()
    job = _FakeJob(
        _Status.PENDING,
        persistence_db=fake_db,
        persistence_dirty=True,
        persisted_status=_Status.PENDING,
    )

    ok = await store.transition(job, status=_Status.COMPLETED)

    assert ok is False
    assert job.persistence_dirty is False


@pytest.mark.asyncio
async def test_transition_adopts_external_terminal_but_returns_false(fake_db):
    """A lost CAS against a row a second worker already terminated: adopt the
    state, but return False so the caller does not mutate memory further."""
    fake_db.rows["extraction_jobs"] = [
        {"id": "job-1", "user_id": "user-1", "status": "completed"}
    ]
    store = _make_store()
    job = _FakeJob(
        _Status.RUNNING,
        persistence_db=fake_db,
        persistence_dirty=True,
        persisted_status=_Status.PENDING,
    )

    ok = await store.transition(job, status=_Status.FAILED)

    assert ok is False
    assert job.status == _Status.COMPLETED
    assert job._persisted_status == _Status.COMPLETED


@pytest.mark.asyncio
async def test_transition_retries_cas_with_read_status_and_succeeds(fake_db):
    fake_db.rows["extraction_jobs"] = [
        {"id": "job-1", "user_id": "user-1", "status": "running"}
    ]
    store = _make_store()
    job = _FakeJob(
        _Status.RUNNING,
        persistence_db=fake_db,
        persistence_dirty=True,
        persisted_status=_Status.PENDING,
    )

    ok = await store.transition(job, status=_Status.COMPLETED, error_message="done")

    assert ok is True
    assert job._persisted_status == _Status.COMPLETED
    fake_db.assert_update("extraction_jobs", status="completed", error_message="done")


@pytest.mark.asyncio
async def test_transition_retry_cas_lost_returns_false(fake_db, monkeypatch):
    fake_db.rows["extraction_jobs"] = [
        {"id": "job-1", "user_id": "user-1", "status": "running"}
    ]
    store = _make_store()
    job = _FakeJob(
        _Status.RUNNING,
        persistence_db=fake_db,
        persistence_dirty=True,
        persisted_status=_Status.PENDING,
    )

    async def fake_read(job):
        return "other"

    monkeypatch.setattr(store, "_read_status", fake_read)

    ok = await store.transition(job, status=_Status.COMPLETED)

    assert ok is False
    assert job.persistence_dirty is False


# =============================================================================
# flush_all
# =============================================================================


@pytest.mark.asyncio
async def test_flush_all_flushes_only_dirty_jobs_with_db(fake_db):
    fake_db.rows["extraction_jobs"] = [
        {"id": "job-1", "user_id": "user-1", "status": "pending"},
        {"id": "job-2", "user_id": "user-1", "status": "pending"},
    ]
    store = _make_store()
    dirty = _FakeJob(
        _Status.RUNNING,
        job_id="job-1",
        persistence_db=fake_db,
        persistence_dirty=True,
        persisted_status=_Status.PENDING,
    )
    not_dirty = _FakeJob(
        _Status.RUNNING, job_id="job-2", persistence_db=fake_db
    )
    no_db = _FakeJob(
        _Status.RUNNING, job_id="job-3", persistence_db=None, persistence_dirty=True
    )

    await store.flush_all([dirty, not_dirty, no_db])

    assert dirty.persistence_dirty is False
    fake_db.assert_update("extraction_jobs", status="running")


@pytest.mark.asyncio
async def test_flush_all_swallows_flush_exceptions():
    store = _make_store()
    db = Mock()
    db.table.return_value.update.return_value.eq.return_value.eq.return_value.eq.return_value.execute.side_effect = (
        RuntimeError("boom")
    )
    job = _FakeJob(
        _Status.RUNNING, persistence_db=db, persistence_dirty=True
    )

    await store.flush_all([job])  # must not raise

    store._logger.warning.assert_called_once()
    warning_kwargs = store._logger.warning.call_args
    assert warning_kwargs.kwargs["extra"]["job_id"] == "job-1"


# =============================================================================
# Internals
# =============================================================================


@pytest.mark.asyncio
async def test_cas_update_matches_expected_status(fake_db):
    fake_db.rows["extraction_jobs"] = [
        {"id": "job-1", "user_id": "user-1", "status": "pending"}
    ]
    store = _make_store()
    job = _FakeJob(_Status.PENDING, persistence_db=fake_db)

    ok = await store._cas_update(job, {"status": "running"}, _Status.PENDING)

    assert ok is True
    assert ("extraction_jobs", "eq", "id", "job-1") in fake_db.filters
    assert ("extraction_jobs", "eq", "user_id", "user-1") in fake_db.filters
    assert ("extraction_jobs", "eq", "status", "pending") in fake_db.filters


@pytest.mark.asyncio
async def test_cas_update_fails_when_status_does_not_match(fake_db):
    fake_db.rows["extraction_jobs"] = [
        {"id": "job-1", "user_id": "user-1", "status": "running"}
    ]
    store = _make_store()
    job = _FakeJob(_Status.RUNNING, persistence_db=fake_db)

    ok = await store._cas_update(job, {"status": "completed"}, _Status.PENDING)

    assert ok is False


@pytest.mark.asyncio
async def test_read_status_returns_persisted_value(fake_db):
    fake_db.rows["extraction_jobs"] = [
        {"id": "job-1", "user_id": "user-1", "status": "running"}
    ]
    store = _make_store()
    job = _FakeJob(_Status.RUNNING, persistence_db=fake_db)

    status = await store._read_status(job)

    assert status == "running"


@pytest.mark.asyncio
async def test_read_status_returns_none_when_row_missing(fake_db):
    store = _make_store()
    job = _FakeJob(_Status.RUNNING, persistence_db=fake_db)

    status = await store._read_status(job)

    assert status is None


@pytest.mark.asyncio
async def test_read_status_returns_none_and_logs_on_db_error():
    store = _make_store()
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.maybe_single.return_value.execute.side_effect = (
        RuntimeError("boom")
    )
    job = _FakeJob(_Status.RUNNING, persistence_db=db)

    status = await store._read_status(job)

    assert status is None
    store._logger.warning.assert_called_once()


def test_adopt_external_terminal_cancelled_sets_event():
    store = _make_store()
    job = _FakeJob(_Status.RUNNING)

    store._adopt_external_terminal(job, "cancelled")

    assert job.status == _Status.CANCELLED
    assert job.cancelled is True
    assert job.cancel_event.is_set()
    assert job.persistence_dirty is False


def test_adopt_external_terminal_non_cancelled_keeps_event_unset():
    store = _make_store()
    job = _FakeJob(_Status.RUNNING)

    store._adopt_external_terminal(job, "failed")

    assert job.status == _Status.FAILED
    assert job.cancelled is False
    assert job.cancel_event.is_set() is False


def test_adopt_external_terminal_without_cancelled_member():
    store = _make_store(cancelled_member=None)
    job = _FakeJob(_Status.RUNNING)

    store._adopt_external_terminal(job, "cancelled")

    assert job.status == _Status.CANCELLED
    assert job.cancelled is False


def test_normalize_adopted_status_passes_through_non_strings():
    store = _make_store()
    job = _FakeJob(_Status.RUNNING)
    # A raw int (not a str-enum subclass) must pass through untouched.
    assert store._normalize_adopted_status(job, 42) == 42


def test_normalize_adopted_status_round_trips_through_enum():
    store = _make_store()
    job = _FakeJob(_Status.RUNNING)
    assert store._normalize_adopted_status(job, "completed") is _Status.COMPLETED


def test_normalize_adopted_status_skips_round_trip_for_plain_string_status():
    store = _make_store()
    job = _FakeJob("running")
    assert store._normalize_adopted_status(job, "completed") is _Status.COMPLETED


def test_normalize_adopted_status_returns_raw_string_when_unknown():
    store = _make_store()
    job = _FakeJob(_Status.RUNNING)
    assert store._normalize_adopted_status(job, "weird") == "weird"


def test_normalize_adopted_status_plain_string_unknown():
    store = _make_store()
    job = _FakeJob("running")
    assert store._normalize_adopted_status(job, "weird") == "weird"


def test_status_value_handles_enums_and_raw_strings():
    assert _status_value(_Status.PENDING) == "pending"
    assert _status_value("raw") == "raw"
