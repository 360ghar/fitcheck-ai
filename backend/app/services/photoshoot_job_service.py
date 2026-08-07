"""
Photoshoot Job Service.

Manages in-memory photoshoot generation jobs for SSE streaming.
Jobs are stored in process memory and auto-expire quickly to limit OOM risk.
"""

import asyncio
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from app.utils.datetime_util import utcnow, utcnow_iso
from typing import Any, Dict, List, Optional, Set
from uuid import uuid4

from app.core.exceptions import AIServiceError, DatabaseError, RateLimitError
from app.core.logging_config import get_context_logger
from app.models.photoshoot import PhotoshootJobStatus
from app.services.job_persistence import JobPersistenceStore
from app.utils.process_metrics import estimate_base64_mb, log_memory
from app.utils.sse_queue import (
    EVENT_HISTORY_MAX,
    discard_subscriber,
    fanout,
    strip_history_base64,
)
from app.utils.db import (
    QUOTA_UNAVAILABLE_CLIENT_MESSAGE,
    job_persistence_migration_hint,
    maybe_single_data,
)

logger = get_context_logger(__name__)

MAX_CONCURRENT_PHOTOSHOOT_JOBS = 2
_ACTIVE_JOB_TTL = timedelta(minutes=30)
_FINISHED_JOB_TTL = timedelta(minutes=15)
_CLEANUP_INTERVAL_S = 60

# Terminal statuses are final: a late status write from a pipeline phase that
# is still unwinding (e.g. a consumer flipping to PROCESSING after the user
# cancelled) must not overwrite them. Same guard as BatchJobService.
_TERMINAL_STATUSES = frozenset({
    PhotoshootJobStatus.COMPLETE,
    PhotoshootJobStatus.CANCELLED,
    PhotoshootJobStatus.FAILED,
})


def _build_persisted_payload(
    job: "PhotoshootJob",
    *,
    status: Optional[PhotoshootJobStatus] = None,
    error_message: Optional[str] = None,
) -> Dict[str, Any]:
    """Durable summary row for a photoshoot job.

    Reference photos and generated base64 are process-local; the row carries
    metadata, durable image URLs, and counters only.
    """
    images = []
    for image in job.generated_images:
        if isinstance(image, dict):
            images.append({key: value for key, value in image.items() if key != "image_base64"})
    target_status = status or job.status
    return {
        "id": job.job_id,
        "user_id": job.user_id,
        "status": target_status.value,
        "session_id": job.session_id,
        "use_case": job.use_case,
        "custom_prompt": job.custom_prompt,
        "num_images": job.num_images,
        "batch_size": job.batch_size,
        "aspect_ratio": job.aspect_ratio,
        "total_batches": job.total_batches,
        "current_batch": job.current_batch,
        "generated_images": images,
        "failed_indices": sorted(job.failed_indices),
        # Bounded per-index provider error detail (one entry per requested
        # slot), so a recovered job can still surface WHY images failed.
        "image_failures": [
            {"index": index, "error": error}
            for index, error in sorted(job.image_failures.items())
        ],
        "usage": job.usage,
        "error_message": error_message if error_message is not None else job.error_message,
        "reference_photo_count": len(job.photos),
        "created_at": job.created_at.isoformat(),
        "completed_at": utcnow_iso() if target_status in _TERMINAL_STATUSES else None,
    }


def _first_image_error(job: Optional["PhotoshootJob"]) -> Optional[str]:
    """The first (lowest-index) NON-EMPTY retained per-image failure detail.

    Lock-free on purpose so both readers can share one policy: ``get_first_error``
    takes ``cls._lock`` itself, while ``get_status`` already holds it. Two inline
    copies meant ``/status.first_error`` could disagree with the ``job_failed``
    payload the moment the policy changed.
    """
    if not job or not job.image_failures:
        return None
    return next(
        (job.image_failures[i] for i in sorted(job.image_failures) if job.image_failures[i]),
        None,
    )


def _hydrate_image_failures(row: Dict[str, Any]) -> Dict[int, str]:
    """Rebuild the per-index failure map from a persisted job row.

    Falls back to the legacy ``failed_indices`` column (with empty error strings)
    when ``image_failures`` is absent: rows written before migration 035 carry only
    the index list, and a job that spans that deploy must not lose its failure
    count. The row keeps both columns for wire compatibility; in memory only the
    map exists (see ``PhotoshootJob.image_failures``).
    """
    failures = {
        int(entry["index"]): str(entry["error"])
        for entry in row.get("image_failures") or []
        if isinstance(entry, dict) and "index" in entry
    }
    if not failures:
        failures = {int(index): "" for index in row.get("failed_indices") or []}
    return failures


_store = JobPersistenceStore(
    table="photoshoot_jobs",
    terminal_statuses=_TERMINAL_STATUSES,
    build_payload=_build_persisted_payload,
    cancelled_member=PhotoshootJobStatus.CANCELLED,
    logger=logger,
)


@dataclass
class PhotoshootJob:
    """In-memory representation of a photoshoot generation job."""
    job_id: str
    user_id: str
    status: PhotoshootJobStatus
    created_at: datetime

    # Configuration
    photos: List[str]  # base64 reference photos
    use_case: str
    custom_prompt: Optional[str] = None
    num_images: int = 10
    batch_size: int = 10
    aspect_ratio: str = "1:1"

    # Progress tracking
    session_id: str = ""
    total_batches: int = 1
    current_batch: int = 0
    generated_images: List[Dict[str, Any]] = field(default_factory=list)
    # Per-index provider error detail, retained so the job_failed payload and
    # /status can tell the client (and the operator) exactly why each slot
    # failed. Bounded: one entry per requested slot. This is the SINGLE record of
    # which slots failed — `failed_indices` below is derived from its keys, not
    # stored alongside it, because `mark_image_failed` is the only writer of
    # either and two independently-rehydrated copies could report a
    # `failed_count` that disagrees with the per-index detail in the same payload.
    image_failures: Dict[int, str] = field(default_factory=dict)

    # Cancellation
    cancelled: bool = False
    cancel_event: asyncio.Event = field(default_factory=asyncio.Event)

    # SSE subscribers
    subscribers: List[asyncio.Queue] = field(default_factory=list)

    # Event history for replay on late subscriber connect
    event_history: List[Dict[str, Any]] = field(default_factory=list)
    next_event_id: int = 1

    # Error info
    error_message: Optional[str] = None
    usage: Optional[Dict[str, Any]] = None
    persistence_db: Any = field(default=None, repr=False, compare=False)
    recovered_from_persistence: bool = field(default=False, repr=False, compare=False)
    # Coalesced persistence state owned by JobPersistenceStore: `persistence_dirty`
    # means an in-memory mutation has not reached the durable row yet, and
    # `_persisted_status` is the status the row currently holds (the CAS anchor).
    persistence_dirty: bool = field(default=False, repr=False, compare=False)
    _persisted_status: Any = field(default=None, repr=False, compare=False)

    def is_cancelled(self) -> bool:
        """Check if job is cancelled."""
        return self.cancelled or self.cancel_event.is_set()

    @property
    def generated_count(self) -> int:
        return len(self.generated_images)

    @property
    def failed_indices(self) -> Set[int]:
        """Slots that failed — derived from ``image_failures``.

        An error string may be empty (a provider that failed without a message),
        but the KEY is always present, so the two are exactly equivalent.
        """
        return set(self.image_failures)

    @property
    def failed_count(self) -> int:
        return len(self.image_failures)


class PhotoshootJobService:
    """Manages photoshoot generation jobs."""

    _jobs: Dict[str, PhotoshootJob] = {}
    _lock: asyncio.Lock = asyncio.Lock()
    _cleanup_task: Optional[asyncio.Task] = None
    _job_ttl: timedelta = _ACTIVE_JOB_TTL

    _ACTIVE_STATUSES = {
        PhotoshootJobStatus.PENDING,
        PhotoshootJobStatus.PROCESSING,
    }

    @classmethod
    def count_active_jobs(cls) -> int:
        return sum(1 for j in cls._jobs.values() if j.status in cls._ACTIVE_STATUSES)

    @classmethod
    def _hydrate(cls, row: Dict[str, Any], db: Any) -> Optional[PhotoshootJob]:
        try:
            status = PhotoshootJobStatus(row.get("status", PhotoshootJobStatus.PENDING.value))
            generated_images = []
            for image in row.get("generated_images") or []:
                if isinstance(image, dict):
                    generated_images.append({key: value for key, value in image.items() if key != "image_base64"})
            job = PhotoshootJob(
                job_id=str(row["id"]),
                user_id=str(row["user_id"]),
                status=status,
                created_at=_store.parse_created_at(row.get("created_at")),
                photos=[],
                use_case=str(row.get("use_case") or "aesthetic"),
                custom_prompt=row.get("custom_prompt"),
                num_images=int(row.get("num_images") or 0),
                batch_size=int(row.get("batch_size") or 1),
                aspect_ratio=str(row.get("aspect_ratio") or "1:1"),
                session_id=str(row.get("session_id") or ""),
                total_batches=int(row.get("total_batches") or 1),
                current_batch=int(row.get("current_batch") or 0),
                generated_images=generated_images,
                image_failures=_hydrate_image_failures(row),
                error_message=row.get("error_message"),
                usage=row.get("usage"),
                persistence_db=db,
                recovered_from_persistence=True,
                _persisted_status=status,
            )
            return job
        except (KeyError, TypeError, ValueError) as exc:
            logger.warning("Could not hydrate persisted photoshoot job", extra={"error": str(exc)})
            return None

    @classmethod
    async def create_job(
        cls,
        user_id: str,
        photos: List[str],
        use_case: str,
        num_images: int,
        batch_size: int = 10,
        aspect_ratio: str = "1:1",
        custom_prompt: Optional[str] = None,
        db: Any = None,
    ) -> PhotoshootJob:
        """Create a new photoshoot job.

        Raises:
            RateLimitError: If process-wide concurrent photoshoot cap is hit.
        """
        # Cap check first so busy servers fail fast without holding work.
        async with cls._lock:
            active = sum(
                1 for j in cls._jobs.values() if j.status in cls._ACTIVE_STATUSES
            )
            if active >= MAX_CONCURRENT_PHOTOSHOOT_JOBS:
                raise RateLimitError(
                    message=(
                        f"Server is busy processing {active} photoshoot jobs. "
                        "Please retry in a minute."
                    ),
                    retry_after=60,
                )

        job_id = str(uuid4())
        session_id = f"ps_{uuid4().hex[:12]}"
        total_batches = max(1, (num_images + batch_size - 1) // batch_size)
        payload_mb = estimate_base64_mb(photos)

        job = PhotoshootJob(
            job_id=job_id,
            user_id=user_id,
            status=PhotoshootJobStatus.PENDING,
            created_at=utcnow(),
            photos=photos,
            use_case=use_case,
            custom_prompt=custom_prompt,
            num_images=num_images,
            batch_size=batch_size,
            aspect_ratio=aspect_ratio,
            session_id=session_id,
            total_batches=total_batches,
            persistence_db=db,
        )

        async with cls._lock:
            # Re-check under lock; another request may have taken the slot.
            active = sum(
                1 for j in cls._jobs.values() if j.status in cls._ACTIVE_STATUSES
            )
            if active >= MAX_CONCURRENT_PHOTOSHOOT_JOBS:
                raise RateLimitError(
                    message=(
                        f"Server is busy processing {active} photoshoot jobs. "
                        "Please retry in a minute."
                    ),
                    retry_after=60,
                )
            cls._jobs[job_id] = job

        # Persist only after admission so a job that loses the cap race never
        # leaves an orphaned durable row; if the write fails or returns no
        # row, drop the in-memory job (so it cannot occupy a concurrency
        # slot) and let the caller's reservation compensation surface it.
        #
        # A raw postgrest APIError (missing photoshoot_jobs table/columns -
        # migration 023 not applied) must never surface as an opaque 500: log
        # the actionable hint (LOGS ONLY, exception type in the message text
        # because Railway's plain-text drain does not render structured extra
        # fields) and raise the friendly retryable 503, matching the
        # quota-RPC error policy.
        if db is not None:
            try:
                if not await _store.create(job):
                    raise DatabaseError("Failed to persist photoshoot job")
            except AIServiceError:
                async with cls._lock:
                    cls._jobs.pop(job_id, None)
                raise
            except Exception as exc:
                async with cls._lock:
                    cls._jobs.pop(job_id, None)
                hint = job_persistence_migration_hint("photoshoot_jobs", exc)
                if hint:
                    logger.error(
                        f"{type(exc).__name__}: {hint}",
                        job_id=job_id,
                        user_id=user_id,
                        error=str(exc),
                    )
                else:
                    logger.error(
                        f"Failed to persist photoshoot job ({type(exc).__name__}): {exc}",
                        job_id=job_id,
                        user_id=user_id,
                        error=str(exc),
                    )
                raise AIServiceError(
                    QUOTA_UNAVAILABLE_CLIENT_MESSAGE,
                    retryable=True,
                ) from exc

        # Start cleanup task if not running
        cls._ensure_cleanup_task()

        log_memory(
            "photoshoot_job_created",
            force=True,
            extra={
                "job_id": job_id,
                "num_images": num_images,
                "payload_mb": payload_mb,
                "active_photoshoot_jobs": active + 1,
                "total_photoshoot_jobs": len(cls._jobs),
            },
        )

        logger.info(
            "Created photoshoot job",
            extra={
                "job_id": job_id,
                "user_id": user_id,
                "num_images": num_images,
                "payload_mb": payload_mb,
            },
        )

        return job

    @classmethod
    async def release_reference_photos(cls, job_id: str) -> None:
        """Drop reference photo base64 once generation no longer needs them."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if not job:
                return
            job.photos = []
        log_memory(
            "photoshoot_refs_released",
            force=True,
            extra={"job_id": job_id},
        )

    @classmethod
    async def clear_event_history(cls, job_id: str) -> None:
        """Drop SSE event history after the pipeline ends.

        History duplicates base64 image events. Final images remain on the
        job for GET status / Flutter poll fallback until job TTL cleanup.
        """
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if not job:
                return
            job.event_history.clear()
        log_memory(
            "photoshoot_event_history_cleared",
            force=True,
            extra={"job_id": job_id},
        )

    @classmethod
    async def release_generated_payloads(cls, job_id: str) -> None:
        """Free generated-image base64 once the pipeline ends.

        Every generated image is also persisted to a durable storage URL at
        generation time (photoshoot_service uploads via
        upload_temp_generated_image); images WITH a URL drop their base64 so
        a finished job no longer pins multi-MB payloads for the whole
        finished TTL. Images whose upload failed keep base64 — memory is the
        price of delivering their image. Status polls return the URL.
        """
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if not job:
                return
            for image in job.generated_images:
                if isinstance(image, dict) and image.get("image_url"):
                    image.pop("image_base64", None)
        log_memory(
            "photoshoot_generated_payloads_released",
            force=True,
            extra={"job_id": job_id},
        )

    @classmethod
    async def get_job(cls, job_id: str, user_id: str, db: Any = None) -> Optional[PhotoshootJob]:
        """Get a job by ID, validating user ownership.

        In-memory jobs are authoritative; the durable row only matters for
        cross-worker recovery (memory miss). Durable progress for a live job
        is coalesced onto the 60s cleanup tick and the synchronous terminal
        transitions, so reads never trigger a full-row write.
        """
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job and job.user_id == user_id:
                if db is not None:
                    job.persistence_db = db
                return job
        if db is not None:
            result = await asyncio.to_thread(
                db.table("photoshoot_jobs")
                .select("*")
                .eq("id", job_id)
                .eq("user_id", user_id)
                .maybe_single()
                .execute
            )
            row = maybe_single_data(result)
            if not row:
                return None
            async with cls._lock:
                job = cls._jobs.get(job_id)
                if job and job.user_id == user_id:
                    job.persistence_db = db
                    return job
                job = cls._hydrate(row, db)
                if job:
                    cls._jobs[job_id] = job
                    # Hydrated jobs live in `_jobs` until cleanup evicts them;
                    # make sure the eviction loop is running so two stale rows
                    # can never permanently exhaust the concurrency limit.
                    cls._ensure_cleanup_task()
                return job
        return None

    @classmethod
    async def get_job_by_id(cls, job_id: str) -> Optional[PhotoshootJob]:
        """Get a job by ID without user validation (for internal use)."""
        async with cls._lock:
            return cls._jobs.get(job_id)

    @classmethod
    async def cancel_job(cls, job_id: str, user_id: str, db: Any = None) -> bool:
        """Cancel a running job."""
        if db is not None and job_id not in cls._jobs:
            await cls.get_job(job_id, user_id, db=db)
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if not job or job.user_id != user_id:
                return False

            if job.status in (
                PhotoshootJobStatus.COMPLETE,
                PhotoshootJobStatus.CANCELLED,
                PhotoshootJobStatus.FAILED,
            ):
                return False

            if job.persistence_db is not None and not await _store.transition(
                job,
                status=PhotoshootJobStatus.CANCELLED,
            ):
                # The CAS lost to a writer that already persisted CANCELLED;
                # adoption moved this job to the terminal state, so report
                # success instead of a 404.
                if job.status != PhotoshootJobStatus.CANCELLED:
                    return False

            job.cancelled = True
            job.cancel_event.set()
            job.status = PhotoshootJobStatus.CANCELLED

        # Broadcast cancellation
        await cls.broadcast_event(job_id, "job_cancelled", {
            "job_id": job_id,
            "timestamp": utcnow_iso(),
        })

        logger.info("Cancelled photoshoot job", extra={"job_id": job_id})
        return True

    @classmethod
    async def update_status(cls, job_id: str, status: PhotoshootJobStatus) -> None:
        """Update job status. Terminal statuses are final and never overwritten.

        Terminal transitions are written synchronously (required CAS) so a
        crash right after the transition still leaves a durable final row;
        non-terminal progress is coalesced via the dirty flag.
        """
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if not job:
                return
            if job.status in _TERMINAL_STATUSES:
                return
            if status in _TERMINAL_STATUSES:
                if not await _store.transition(job, status=status):
                    return
            else:
                _store.mark_dirty(job)
            job.status = status

    @classmethod
    async def update_current_batch(cls, job_id: str, batch_num: int) -> None:
        """Update the current batch number."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job and job.status not in _TERMINAL_STATUSES:
                job.current_batch = batch_num
                _store.mark_dirty(job)

    @classmethod
    async def add_generated_image(
        cls,
        job_id: str,
        image_id: str,
        index: int,
        image_base64: Optional[str] = None,
        image_url: Optional[str] = None,
    ) -> None:
        """Add a successfully generated image to the job."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job and job.status not in _TERMINAL_STATUSES:
                job.generated_images.append({
                    "id": image_id,
                    "index": index,
                    "image_base64": image_base64,
                    "image_url": image_url,
                })
                _store.mark_dirty(job)

    @classmethod
    async def mark_image_failed(cls, job_id: str, index: int, error: str) -> None:
        """Mark an image generation as failed, retaining the error detail.

        The error text is bounded (500 chars) so a provider stack trace can
        never inflate the durable row; the first (lowest-index) entry is
        surfaced on the job_failed payload and /status.
        """
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job and job.status not in _TERMINAL_STATUSES:
                job.image_failures[index] = (error or "")[:500]
                _store.mark_dirty(job)

    @classmethod
    async def get_first_error(cls, job_id: str) -> Optional[str]:
        """Return the first (lowest-index) retained per-image failure detail."""
        async with cls._lock:
            return _first_image_error(cls._jobs.get(job_id))

    @classmethod
    async def set_usage(cls, job_id: str, usage: Dict[str, Any]) -> None:
        """Set usage info on job completion."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job and job.status not in _TERMINAL_STATUSES:
                job.usage = usage
                _store.mark_dirty(job)

    @classmethod
    async def set_error(cls, job_id: str, error: str) -> None:
        """Set job error and mark as failed."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job and job.status not in _TERMINAL_STATUSES:
                if (
                    job.persistence_db is not None
                    and not await _store.transition(
                        job,
                        status=PhotoshootJobStatus.FAILED,
                        error_message=error,
                    )
                    and job.status != PhotoshootJobStatus.FAILED
                ):
                    return
                job.error_message = error
                job.status = PhotoshootJobStatus.FAILED

    @classmethod
    async def broadcast_event(cls, job_id: str, event_type: str, data: Dict[str, Any]) -> None:
        """Send SSE event to all subscribers and store in history for late subscribers."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if not job:
                return

            event = {"type": event_type, "data": data, "id": job.next_event_id}
            job.next_event_id += 1

            # Always store in event history for late-connecting subscribers.
            # History is STRIPPED of base64 payloads (see strip_history_base64)
            # and length-bounded, so a finished job never pins multi-MB copies
            # of every generated image; live subscribers still get the full
            # event.
            job.event_history.append(strip_history_base64(event))
            if len(job.event_history) > EVENT_HISTORY_MAX:
                del job.event_history[:-EVENT_HISTORY_MAX]

            subscribers = list(job.subscribers)

            # Coalesce the durable write via the dirty flag instead of rewriting
            # the whole row per event (the row grows with every generated image,
            # so per-event writes are O(n^2)).
            _store.mark_dirty(job)

        # Same policy as BatchJobService: never block the pipeline, never let a
        # stalled client grow the queue (these events carry base64 images).
        dropped = fanout(event, subscribers)
        if dropped:
            async with cls._lock:
                job = cls._jobs.get(job_id)
                if job:
                    for queue in dropped:
                        if queue in job.subscribers:
                            job.subscribers.remove(queue)
            logger.warning(
                "Dropped slow SSE subscriber(s)",
                extra={"job_id": job_id, "dropped": len(dropped)},
            )

    @classmethod
    async def add_subscriber(cls, job_id: str, queue: asyncio.Queue) -> tuple[bool, int]:
        """Add an SSE subscriber to a job.

        Returns:
            Tuple of (success, replay_from_index) where replay_from_index is the
            number of events in history at subscription time. Events should be
            replayed only up to this index to avoid duplicates with live queue.
        """
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if not job:
                return False, 0
            # Capture history length before adding subscriber to avoid duplicate events
            history_length = len(job.event_history)
            job.subscribers.append(queue)
            return True, history_length

    @classmethod
    async def remove_subscriber(cls, job_id: str, queue: asyncio.Queue) -> None:
        """Remove an SSE subscriber from a job.

        The queue is drained and its byte-ledger entry dropped (see
        sse_queue.discard_subscriber): a disconnected client's buffered
        events — potentially multi-MB generated base64 — must not stay
        pinned by the ledger's strong reference until job TTL.
        """
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job and queue in job.subscribers:
                job.subscribers.remove(queue)
            discard_subscriber(queue)

    @classmethod
    async def get_event_history(cls, job_id: str, up_to_index: int | None = None) -> List[Dict[str, Any]]:
        """Get event history for replay to late-connecting subscribers.

        Args:
            job_id: The job ID
            up_to_index: If provided, only return events up to this index (exclusive)
                        to avoid duplicates with events already in the subscriber's queue.
        """
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if not job:
                return []
            if up_to_index is not None:
                return list(job.event_history[:up_to_index])
            return list(job.event_history)

    @classmethod
    async def get_job_status(cls, job_id: str) -> Optional[Dict[str, Any]]:
        """Get current status of a job for reconnection/polling.

        Callers resolve the job first via ``get_job`` (which handles durable
        recovery); this only reads in-memory state. Durable progress is
        coalesced on the cleanup tick and terminal transitions, so a status
        poll never triggers a full-row write.
        """
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if not job:
                return None

            return {
                "job_id": job.job_id,
                "status": job.status.value,
                "generated_count": job.generated_count,
                "failed_count": job.failed_count,
                "failed_indices": sorted(job.failed_indices),
                "partial_success": job.failed_count > 0,
                "total_count": job.num_images,
                "current_batch": job.current_batch,
                "total_batches": job.total_batches,
                "images": job.generated_images,
                "usage": job.usage,
                "error": job.error_message,
                # First per-image failure detail (provider status/message) so
                # a polled client can tell the user WHY images failed. Same
                # selection policy as get_first_error — called directly rather
                # than through it because this reader already holds cls._lock.
                "first_error": _first_image_error(job),
            }

    @classmethod
    def _ensure_cleanup_task(cls) -> None:
        """Ensure cleanup task is running."""
        if cls._cleanup_task is None or cls._cleanup_task.done():
            cls._cleanup_task = asyncio.create_task(cls._cleanup_loop())

    @classmethod
    async def _cleanup_loop(cls) -> None:
        """Periodically cleanup expired jobs."""
        while True:
            try:
                await asyncio.sleep(_CLEANUP_INTERVAL_S)
                await cls._cleanup_expired_jobs()
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Cleanup loop error: {e}")

    @classmethod
    async def _cleanup_expired_jobs(cls) -> None:
        """Remove jobs past active/finished TTLs and free base64 early."""
        async with cls._lock:
            # Coalesced writes may still be pending; flush them before evicting
            # so the durable row is never silently dropped with the job.
            # Snapshot the dirty jobs under the lock and write outside it so a
            # slow Supabase roundtrip never blocks job-service operations.
            dirty_jobs = [
                job
                for job in cls._jobs.values()
                if job.persistence_db is not None and job.persistence_dirty
            ]

        await _store.flush_all(dirty_jobs)

        now = utcnow()
        expired_ids = []
        finished = {
            PhotoshootJobStatus.COMPLETE,
            PhotoshootJobStatus.FAILED,
            PhotoshootJobStatus.CANCELLED,
        }

        async with cls._lock:
            for job_id, job in list(cls._jobs.items()):
                age = now - job.created_at
                if job.status in finished:
                    job.photos = []
                    if job.event_history:
                        job.event_history.clear()
                    # Keep generated image_base64 until eviction so poll
                    # fallback still returns images during the finished TTL.
                    if age > _FINISHED_JOB_TTL:
                        for image in job.generated_images:
                            if isinstance(image, dict):
                                image.pop("image_base64", None)
                        expired_ids.append(job_id)
                elif age > _ACTIVE_JOB_TTL:
                    expired_ids.append(job_id)

            for job_id in expired_ids:
                del cls._jobs[job_id]

        if expired_ids:
            log_memory(
                "photoshoot_jobs_cleaned",
                force=True,
                extra={"cleaned": len(expired_ids), "remaining": len(cls._jobs)},
            )
            logger.info(f"Cleaned up {len(expired_ids)} expired photoshoot jobs")
