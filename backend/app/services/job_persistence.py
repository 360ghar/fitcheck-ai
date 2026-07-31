"""Shared durable-job persistence for the in-memory batch/photoshoot job services.

Both :class:`BatchJobService` and :class:`PhotoshootJobService` keep jobs in
process memory (large base64 payloads are intentionally never serialized) while
mirroring a durable, payload-free summary row to hosted Supabase for
cross-worker recovery. This module owns the common persistence mechanics so the
two services differ only in their table name, status enum, and payload
builder:

- **CAS writes** - every update is a compare-and-set against the status we last
  successfully wrote, so a late write from an unwinding pipeline phase (or a
  second worker) can never overwrite a terminal row.
- **Coalesced flushing** - progress mutations only mark the job dirty; the
  cleanup-loop tick, terminal transitions, and reads flush the row. This avoids
  the O(n^2) full-row write amplification of persisting on every SSE event.
- **External-terminal adoption** - when a CAS loses to another writer that
  already moved the row to a terminal state, the in-memory job adopts that
  state instead of silently diverging.
"""

import asyncio
from datetime import datetime
from typing import Any, Callable, Dict, FrozenSet, Iterable, Optional

from app.utils.datetime_util import parse_utc_datetime, utcnow


def _payload_ok(result: Any) -> bool:
    """postgrest-py returns falsy data for a zero-row CAS update."""
    data = getattr(result, "data", None)
    return data is None or bool(data)


class JobPersistenceStore:
    """CAS persistence for one in-memory job service's durable row."""

    def __init__(
        self,
        *,
        table: str,
        terminal_statuses: FrozenSet[Any],
        build_payload: Callable[..., Dict[str, Any]],
        cancelled_member: Any = None,
        logger: Any,
    ):
        self._table = table
        self._terminal_statuses = terminal_statuses
        self._build_payload = build_payload
        self._cancelled_member = cancelled_member
        self._logger = logger

    # ------------------------------------------------------------------
    # Parsing
    # ------------------------------------------------------------------

    @staticmethod
    def parse_created_at(value: Any) -> datetime:
        """Parse a persisted ``created_at`` (Z-suffixed or naive) as aware UTC."""
        return parse_utc_datetime(value) or utcnow()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def mark_dirty(self, job: Any) -> None:
        """Flag a job for a coalesced flush. No-op without a persistence db."""
        if job.persistence_db is not None:
            job.persistence_dirty = True

    async def create(self, job: Any) -> bool:
        """Insert the initial row (upsert, on_conflict=id). Called once per job.

        Exceptions propagate: a failed create is a real admission failure that
        routes already compensate for by releasing reserved quota.
        """
        db = job.persistence_db
        if db is None:
            return True
        payload = self._build_payload(job)
        result = await asyncio.to_thread(
            db.table(self._table).upsert(payload, on_conflict="id").execute
        )
        ok = _payload_ok(result)
        if ok:
            job._persisted_status = job.status
            job.persistence_dirty = False
        else:
            self._logger.warning(
                "Persisted job create returned no row",
                extra={"job_id": job.job_id},
            )
        return ok

    async def flush(self, job: Any) -> bool:
        """Best-effort coalesced write of a dirty job.

        Returns True when the durable row reflects the job's in-memory state.
        Callers in read paths wrap this to stay best-effort; the cleanup loop
        calls it via :meth:`flush_all`.
        """
        db = job.persistence_db
        if db is None:
            job.persistence_dirty = False
            return True
        if not job.persistence_dirty:
            return True

        payload = self._build_payload(job)
        expected = job._persisted_status or job.status
        if await self._cas_update(job, payload, expected):
            job._persisted_status = job.status
            job.persistence_dirty = False
            return True

        # CAS lost: another writer moved the row. Re-read the authoritative
        # status and reconcile instead of silently diverging.
        db_status = await self._read_status(job)
        if db_status is None:
            # Row never created (e.g. the initial upsert failed); stop trying.
            job.persistence_dirty = False
            return False
        if db_status in self._terminal_statuses and db_status != job.status:
            self._adopt_external_terminal(job, db_status)
            return True

        job._persisted_status = db_status
        if await self._cas_update(job, payload, db_status):
            job._persisted_status = job.status
            job.persistence_dirty = False
            return True

        # Still losing the race; stay dirty so the next flush tick retries.
        return False

    async def transition(
        self,
        job: Any,
        *,
        status: Any,
        error_message: Optional[str] = None,
    ) -> bool:
        """Synchronous, required write for terminal transitions.

        The caller only mutates in-memory state when this returns True, so a
        lost CAS can never leave memory and the durable row diverged.
        """
        db = job.persistence_db
        if db is None:
            return True
        payload = self._build_payload(job, status=status, error_message=error_message)
        expected = job._persisted_status or job.status
        if await self._cas_update(job, payload, expected):
            job._persisted_status = status
            job.persistence_dirty = False
            return True

        db_status = await self._read_status(job)
        if db_status is None:
            job.persistence_dirty = False
            return False
        if db_status in self._terminal_statuses and db_status != job.status:
            self._adopt_external_terminal(job, db_status)
            return False

        job._persisted_status = db_status
        if await self._cas_update(job, payload, db_status):
            job._persisted_status = status
            job.persistence_dirty = False
            return True
        job.persistence_dirty = False
        return False

    async def flush_all(self, jobs: Iterable[Any]) -> None:
        """Flush every dirty job. Never raises (cleanup-loop tick)."""
        for job in jobs:
            if job.persistence_db is None or not job.persistence_dirty:
                continue
            try:
                await self.flush(job)
            except Exception as exc:
                self._logger.warning(
                    "Failed to flush persisted job",
                    extra={"job_id": job.job_id, "error": str(exc)},
                )

    # ------------------------------------------------------------------
    # Internals
    # ------------------------------------------------------------------

    async def _cas_update(self, job: Any, payload: Dict[str, Any], expected_status: Any) -> bool:
        """Compare-and-set update against the expected row status.

        Exceptions propagate so required writes surface real DB failures.
        """
        result = await asyncio.to_thread(
            job.persistence_db.table(self._table)
            .update(payload)
            .eq("id", job.job_id)
            .eq("user_id", job.user_id)
            .eq("status", _status_value(expected_status))
            .execute
        )
        return _payload_ok(result)

    async def _read_status(self, job: Any) -> Optional[Any]:
        """Read just the status column (never the full payload row)."""
        try:
            result = await asyncio.to_thread(
                job.persistence_db.table(self._table)
                .select("status")
                .eq("id", job.job_id)
                .eq("user_id", job.user_id)
                .maybe_single()
                .execute
            )
        except Exception as exc:
            self._logger.warning(
                "Failed to re-read persisted job status",
                extra={"job_id": job.job_id, "error": str(exc)},
            )
            return None
        row = getattr(result, "data", None) if result else None
        if not row:
            return None
        return row.get("status")

    def _adopt_external_terminal(self, job: Any, db_status: Any) -> None:
        """Adopt a terminal status a second worker already persisted."""
        job.status = db_status
        job._persisted_status = db_status
        job.persistence_dirty = False
        if self._cancelled_member is not None and db_status == self._cancelled_member:
            job.cancelled = True
            job.cancel_event.set()


def _status_value(status: Any) -> str:
    return status.value if hasattr(status, "value") else str(status)
