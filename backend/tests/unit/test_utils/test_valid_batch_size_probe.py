"""Boot probe for the extraction_jobs.valid_batch_size CHECK bound.

Regression for the 2026-08-01 production incident: POST /api/v1/ai/single-extract
503'd because the hosted DB still had the 016-era CHECK bound (<=10) while the
API persists generation_batch_size = AI_GENERATION_CONCURRENCY (default 30,
config clamp <=100). The probe is non-mutating: inserts target the nil UUID
user so the users(id) FK always rejects the row.
"""

import pytest

from app.utils.db import (
    _BATCH_SIZE_PROBE_VALUES,
    _NIL_USER_UUID,
    probe_valid_batch_size_bound,
)


class _ProbeError(Exception):
    code = None


class _CheckViolation(_ProbeError):
    code = "23514"

    def __init__(self):
        super().__init__(
            'ERROR: 23514: new row for relation "extraction_jobs" violates '
            'check constraint "valid_batch_size"'
        )


class _ForeignKeyBlocked(_ProbeError):
    code = "23503"

    def __init__(self):
        super().__init__(
            'insert or update on table "extraction_jobs" violates foreign key '
            'constraint "extraction_jobs_user_id_fkey" (SQLSTATE 23503)'
        )


class _MissingTable(_ProbeError):
    code = "PGRST205"

    def __init__(self):
        super().__init__(
            'PGRST205: Could not find the "extraction_jobs" relation in the '
            "schema cache"
        )


class _ConnectionTerminated(_ProbeError):
    def __init__(self):
        super().__init__(
            "ConnectionTerminated error_code:1, last_stream_id:223, "
            "additional_data:None"
        )


class _FakeExtractionJobsDB:
    """Insert-only fake: each execute() raises the next queued outcome."""

    def __init__(self, outcomes):
        self._outcomes = list(outcomes)
        self.inserted = []

    def table(self, name):
        assert name == "extraction_jobs"
        return self

    def insert(self, payload):
        self.inserted.append(dict(payload))
        return self

    def execute(self):
        outcome = self._outcomes.pop(0) if self._outcomes else None
        if isinstance(outcome, Exception):
            raise outcome
        return object()


def test_probe_ok_when_bound_accepts_51():
    db = _FakeExtractionJobsDB([_ForeignKeyBlocked(), _ForeignKeyBlocked()])
    level, message = probe_valid_batch_size_bound(db)
    assert level == "ok"
    assert "029" in message
    # Probes 11 then 51, both against the nil user so nothing persists.
    assert [p["generation_batch_size"] for p in db.inserted] == list(
        _BATCH_SIZE_PROBE_VALUES
    )
    assert all(p["user_id"] == _NIL_USER_UUID for p in db.inserted)


def test_probe_critical_when_bound_is_pre_023():
    db = _FakeExtractionJobsDB([_CheckViolation()])
    level, message = probe_valid_batch_size_bound(db)
    assert level == "critical"
    assert "023" in message and "029" in message
    # Stops after the first probe - no point probing higher values.
    assert len(db.inserted) == 1


def test_probe_warn_when_bound_is_023_era():
    db = _FakeExtractionJobsDB([_ForeignKeyBlocked(), _CheckViolation()])
    level, message = probe_valid_batch_size_bound(db)
    assert level == "warn"
    assert "029" in message
    assert [p["generation_batch_size"] for p in db.inserted] == list(
        _BATCH_SIZE_PROBE_VALUES
    )


def test_probe_missing_when_table_absent():
    db = _FakeExtractionJobsDB([_MissingTable()])
    level, message = probe_valid_batch_size_bound(db)
    assert level == "missing"
    assert "016" in message


def test_probe_unknown_on_connectivity_failure():
    db = _FakeExtractionJobsDB([_ConnectionTerminated()])
    level, message = probe_valid_batch_size_bound(db)
    assert level == "unknown"
    assert "inconclusive" in message


def test_probe_unknown_on_second_probe_connectivity_failure():
    db = _FakeExtractionJobsDB([_ForeignKeyBlocked(), _ConnectionTerminated()])
    level, message = probe_valid_batch_size_bound(db)
    assert level == "unknown"


def test_probe_never_persists_any_row():
    # Even a hypothetical success path must not leave a row: the nil UUID
    # user guarantees the FK rejects; assert every insert used it.
    db = _FakeExtractionJobsDB([None, None])
    level, message = probe_valid_batch_size_bound(db)
    assert level == "ok"
    assert all(p["user_id"] == _NIL_USER_UUID for p in db.inserted)
    assert all(p["status"] == "pending" for p in db.inserted)
    assert all(p["job_type"] == "single" for p in db.inserted)


@pytest.mark.parametrize(
    "outcomes, expected_level",
    [
        ([_CheckViolation()], "critical"),
        ([_ForeignKeyBlocked(), _CheckViolation()], "warn"),
        ([_ForeignKeyBlocked(), _ForeignKeyBlocked()], "ok"),
        ([_MissingTable()], "missing"),
        ([_ConnectionTerminated()], "unknown"),
    ],
)
def test_probe_levels_are_stable(outcomes, expected_level):
    level, _message = probe_valid_batch_size_bound(_FakeExtractionJobsDB(outcomes))
    assert level == expected_level
