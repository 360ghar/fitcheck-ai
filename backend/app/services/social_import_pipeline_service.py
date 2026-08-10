"""
Orchestration for social URL import queue.
"""

from __future__ import annotations

import asyncio
import base64
import httpx
import uuid
from app.utils.datetime_util import parse_utc_datetime, utcnow_iso, utcnow
from typing import Any, Dict, List, Optional

from app.agents.image_generation_agent import get_image_generation_agent
from app.agents.item_extraction_agent import get_item_extraction_agent
from app.core.exceptions import (
    SocialImportAuthRequiredError,
    SocialImportError,
    SocialImportJobNotFoundError,
    SocialImportPhotoNotFoundError,
    SocialImportPhotoStateError,
)
from app.core.logging_config import get_context_logger
from app.models.social_import import (
    SocialImportItemStatus,
    SocialImportJobStatus,
    SocialImportPhotoStatus,
    SocialPlatform,
)
from app.models.subscription import OperationType
from app.services.ai_service import AIService
from app.services.ai_settings_service import AISettingsService
from app.services.social_auth_service import SocialAuthService
from app.services.social_import_event_service import SocialImportEventService
from app.services.social_import_job_store import SocialImportJobStore
from app.services.social_scraper_service import SocialScraperService
from app.services.storage_service import StorageService
from app.services.vector_service import get_vector_service
from app.utils.image_processing import resolve_product_reference_image
from app.utils.retry import with_retry
from app.utils.tasks import spawn_background_task

logger = get_context_logger(__name__)


class SocialImportPipelineService:
    """Coordinates discovery, processing, and per-photo approval queueing."""

    _tasks: Dict[str, asyncio.Task] = {}
    _locks: Dict[str, asyncio.Lock] = {}
    _task_lock: asyncio.Lock = asyncio.Lock()
    # Strong references to one-shot background tasks (the capacity-exhaustion
    # retry sleep). The event loop only keeps weak references, so a discarded
    # create_task() result can be GC'd mid-sleep and the retry never fires,
    # leaving a capacity-paused job stuck in `processing` with queued photos.
    # Same pattern as batch_processing._pipeline_tasks / photoshoot._pipeline_tasks.
    _background_tasks: "set[asyncio.Task]" = set()

    # Pagination safeguards to prevent infinite loops
    MAX_DISCOVERY_ITERATIONS = 100  # Max pages to fetch per job
    MAX_DISCOVERY_PHOTOS = 2000     # Hard limit on photos per job
    DISCOVERY_RETRY_ATTEMPTS = 3
    DISCOVERY_RETRY_BASE_DELAY_SECONDS = 1.0
    # Automatic re-attempts after upstream AI capacity exhaustion. Capped
    # exponential backoff (A4-01): each retry probes the provider once, and
    # after CAPACITY_RETRY_MAX_ATTEMPTS failures the job is paused (FAILED
    # with a clear, retryable message) instead of grinding through every
    # remaining photo in an unbounded 5-minute loop.
    CAPACITY_RETRY_DELAYS_SECONDS = (60, 120, 240, 480)
    CAPACITY_RETRY_MAX_ATTEMPTS = 5
    # A4-04: a job left in `processing`/`discovering` by a crashed or
    # restarted process never resumes on its own (only PAUSED_RATE_LIMITED
    # auto-resumes today). Any job stuck in those states for longer than this
    # is recovered by the get_status sweep: stuck photos are requeued and the
    # job is re-scheduled from its pre-run state.
    STALE_JOB_THRESHOLD_SECONDS = 600

    def __init__(self, *, user_id: str, db):
        self.user_id = user_id
        self.db = db
        # Set when upstream AI capacity is exhausted (Gemini free-tier quota +
        # Agnes fallback both failed). Stops _run_queue from grinding through
        # every remaining photo. Per-instance == per-job run.
        self._capacity_exhausted = False

    @classmethod
    def _job_lock(cls, job_id: str) -> asyncio.Lock:
        lock = cls._locks.get(job_id)
        if not lock:
            lock = asyncio.Lock()
            cls._locks[job_id] = lock
        return lock

    @classmethod
    async def schedule_job(
        cls, service: "SocialImportPipelineService", job_id: str
    ) -> None:
        async with cls._task_lock:
            existing = cls._tasks.get(job_id)
            if existing and not existing.done():
                return
            cls._tasks[job_id] = asyncio.create_task(service.run(job_id))

    @classmethod
    async def cancel_scheduled_job(cls, job_id: str) -> None:
        async with cls._task_lock:
            task = cls._tasks.pop(job_id, None)
            if task and not task.done():
                task.cancel()

    async def _schedule_capacity_retry(self, job_id: str, delay_seconds: float) -> None:
        """Re-run a capacity-exhausted job after ``delay_seconds``.

        Provider 429/5xx capacity is transient; the backoff keeps retry
        intensity bounded while still letting the job resume automatically
        instead of sitting in ``processing`` forever. The attempt budget is
        enforced by ``_handle_capacity_exhaustion`` before this is spawned.
        """
        try:
            await asyncio.sleep(delay_seconds)
        except asyncio.CancelledError:
            return
        await self.schedule_job(self, job_id)

    async def _handle_capacity_exhaustion(self, job_id: str) -> None:
        """Apply the capped-backoff policy after upstream capacity exhaustion.

        - Increments the persistent ``capacity_retry_attempts`` counter in
          the job metadata (survives process restarts and retry runs, which
          create a fresh service instance).
        - Re-schedules the job with the next backoff delay (60/120/240/480s).
        - After CAPACITY_RETRY_MAX_ATTEMPTS failures the job is paused with a
          clear status/error instead of looping forever; photos stay queued so
          a fresh job (or future resume path) can reprocess them.
        """
        job = await SocialImportJobStore.get_job(
            self.db, job_id=job_id, user_id=self.user_id
        )
        if not job:
            return

        metadata = dict(job.get("metadata") or {})
        try:
            attempts = int(metadata.get("capacity_retry_attempts") or 0)
        except (TypeError, ValueError):
            attempts = 0

        if attempts >= self.CAPACITY_RETRY_MAX_ATTEMPTS:
            message = (
                "AI service capacity exhausted after repeated retries; the "
                "import is paused. Please retry the import later."
            )
            await SocialImportJobStore.set_job_status(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                status=SocialImportJobStatus.FAILED,
                error_message=message,
            )
            await self._sync_job_counters(job_id)
            await self._publish_event(
                job_id,
                "job_failed",
                {"job_id": job_id, "error": message, "retryable": True},
            )
            return

        metadata["capacity_retry_attempts"] = attempts + 1
        delays = self.CAPACITY_RETRY_DELAYS_SECONDS or (0,)
        delay = delays[min(attempts, len(delays) - 1)]
        await SocialImportJobStore.update_job(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            updates={"metadata": metadata},
        )
        await self._sync_job_counters(job_id)
        await self._publish_event(
            job_id,
            "job_updated",
            {
                "job_id": job_id,
                "status": SocialImportJobStatus.PROCESSING.value,
                "message": "AI service capacity exhausted; retrying in a few minutes",
                "retry_after_seconds": delay,
            },
        )
        # The task is strongly referenced (see _background_tasks) so it cannot
        # be GC'd mid-sleep before the retry fires.
        self._spawn_background(self._schedule_capacity_retry(job_id, delay))

    async def _clear_capacity_retry_state(self, job_id: str) -> None:
        """Reset the capacity retry counter once the pipeline makes real
        progress, so a later capacity outage starts a fresh backoff budget."""
        # Best-effort like the job counters (A4-05): a failure here must not
        # fail the photo/job that just made progress - only the stale counter
        # is lost, and the next exhaustion re-initializes it anyway.
        try:
            job = await SocialImportJobStore.get_job(
                self.db, job_id=job_id, user_id=self.user_id
            )
            if not job:
                return
            metadata = dict(job.get("metadata") or {})
            if "capacity_retry_attempts" not in metadata:
                return
            metadata.pop("capacity_retry_attempts", None)
            await SocialImportJobStore.update_job(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                updates={"metadata": metadata},
            )
        except Exception as reset_err:  # noqa: BLE001 - reset must not fail the photo
            logger.warning(
                "Failed to reset capacity retry state; continuing",
                extra={"job_id": job_id, "error": str(reset_err)[:300]},
            )

    @classmethod
    async def _cleanup_job_resources(cls, job_id: str) -> None:
        """Clean up task and lock resources for a job."""
        async with cls._task_lock:
            cls._tasks.pop(job_id, None)
            cls._locks.pop(job_id, None)

    @classmethod
    def _spawn_background(cls, coro: "Any") -> asyncio.Task:
        """Kick off a one-shot background task while holding a strong reference."""
        return spawn_background_task(coro, cls._background_tasks)

    @classmethod
    def _cleanup_all_finished_tasks(cls) -> None:
        """Periodic cleanup of completed task references to prevent memory growth."""
        done_tasks = [job_id for job_id, task in cls._tasks.items() if task.done()]
        for job_id in done_tasks:
            cls._tasks.pop(job_id, None)
            cls._locks.pop(job_id, None)

    async def _publish_event(
        self, job_id: str, event_type: str, payload: Dict[str, Any]
    ) -> None:
        """Publish an event to the social import event stream."""
        await SocialImportEventService.publish(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            event_type=event_type,
            payload=payload,
        )

    async def run(self, job_id: str) -> None:
        # Each run is a fresh attempt: a retry scheduled after capacity
        # exhaustion must not inherit the previous run's exhausted flag.
        self._capacity_exhausted = False
        logger.info(
            "Social import job started",
            job_id=job_id,
            user_id=self.user_id,
        )
        lock = self._job_lock(job_id)
        async with lock:
            job = await SocialImportJobStore.get_job(
                self.db, job_id=job_id, user_id=self.user_id
            )
            if not job:
                logger.warning(
                    "Job not found during run",
                    job_id=job_id,
                    user_id=self.user_id,
                )
                await self._cleanup_job_resources(job_id)
                return

            status = job.get("status")
            if status in {
                SocialImportJobStatus.COMPLETED.value,
                SocialImportJobStatus.CANCELLED.value,
                SocialImportJobStatus.FAILED.value,
            }:
                logger.debug(
                    "Job already in terminal state",
                    job_id=job_id,
                    status=status,
                )
                await self._cleanup_job_resources(job_id)
                return

            try:
                if not job.get("discovery_completed"):
                    logger.info(
                        "Starting photo discovery",
                        job_id=job_id,
                        platform=job.get("platform"),
                    )
                    await self._discover_all_photos(job_id)
                    job = await SocialImportJobStore.get_job(
                        self.db, job_id=job_id, user_id=self.user_id
                    )
                    if not job:
                        logger.warning(
                            "Job disappeared after discovery",
                            job_id=job_id,
                        )
                        await self._cleanup_job_resources(job_id)
                        return

                    if job.get("status") == SocialImportJobStatus.FAILED.value:
                        return

                if job.get("status") == SocialImportJobStatus.AWAITING_AUTH.value:
                    logger.info(
                        "Job awaiting authentication",
                        job_id=job_id,
                    )
                    return

                await self._run_queue(job_id)
            except SocialImportAuthRequiredError:
                logger.info(
                    "Authentication required for job",
                    job_id=job_id,
                )
                # Job already moved to awaiting_auth and should resume after auth submission.
                return
            except asyncio.CancelledError:
                logger.info(
                    "Job cancelled",
                    job_id=job_id,
                )
                raise
            except Exception as e:
                logger.exception(
                    "Job failed with error",
                    job_id=job_id,
                    error=str(e),
                )
                await SocialImportJobStore.set_job_status(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    status=SocialImportJobStatus.FAILED,
                    error_message=str(e),
                )
                await self._publish_event(
                    job_id,
                    "job_failed",
                    {"job_id": job_id, "error": str(e)},
                )
            finally:
                # Clean up task and lock references after job finishes
                await self._cleanup_job_resources(job_id)
                logger.info(
                    "Job run completed",
                    job_id=job_id,
                    status="cleaned_up",
                )

    async def _discover_all_photos(self, job_id: str) -> None:
        job = await SocialImportJobStore.get_job(
            self.db, job_id=job_id, user_id=self.user_id
        )
        if not job:
            raise SocialImportJobNotFoundError(job_id)

        job_metadata = dict(job.get("metadata") or {})

        await SocialImportJobStore.set_job_status(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            status=SocialImportJobStatus.DISCOVERING,
            error_message=None,
        )
        await self._publish_event(
            job_id,
            "job_updated",
            {
                "job_id": job_id,
                "status": SocialImportJobStatus.DISCOVERING.value,
            },
        )

        stored_cursor = job_metadata.get("discovery_cursor")
        cursor: Optional[str] = stored_cursor if isinstance(stored_cursor, str) and stored_cursor else None
        ordinal = int(job.get("discovered_photos") or 0) + 1
        try:
            iteration_count = int(job_metadata.get("discovery_iteration") or 0)
        except (TypeError, ValueError):
            iteration_count = 0

        while iteration_count < self.MAX_DISCOVERY_ITERATIONS:
            iteration_count += 1
            auth_session = await SocialAuthService.get_active_session(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
            )
            async def _discover() -> Any:
                discovered = await SocialScraperService.discover_profile_photos(
                    normalized_url=job["normalized_url"],
                    platform=SocialPlatform(job["platform"]),
                    auth_session=auth_session,
                    cursor=cursor,
                )
                if discovered is None:
                    raise RuntimeError("Photo discovery returned no result")
                discovery_metadata = discovered.metadata or {}
                if (
                    discovery_metadata.get("error_type")
                    in {"discovery_failure", "fetch_failure"}
                    or discovery_metadata.get("error")
                ):
                    # Transient network/HTTP failures are returned as a result
                    # by the scraper, not raised; surface them as exceptions
                    # so with_retry applies DISCOVERY_RETRY_ATTEMPTS instead
                    # of entering the FAILED path immediately.
                    raise RuntimeError(
                        discovery_metadata.get("message")
                        or discovery_metadata.get("error")
                        or "Photo discovery failed"
                    )
                return discovered

            def _log_discovery_retry(attempt: int, error: Exception, delay: float) -> None:
                logger.warning(
                    "Retrying photo discovery",
                    job_id=job_id,
                    user_id=self.user_id,
                    attempt=attempt,
                    max_attempts=self.DISCOVERY_RETRY_ATTEMPTS,
                    error=str(error),
                    retry_delay_seconds=round(delay, 2),
                )

            try:
                result = await with_retry(
                    _discover,
                    max_retries=self.DISCOVERY_RETRY_ATTEMPTS - 1,
                    initial_delay=self.DISCOVERY_RETRY_BASE_DELAY_SECONDS,
                    backoff_factor=1.5,
                    max_delay=10.0,
                    on_retry=_log_discovery_retry,
                )
            except Exception as discovery_error:
                raise RuntimeError(
                    f"Photo discovery failed after retries: {discovery_error}"
                )

            await self._persist_scraper_session_from_payload(
                job_id=job_id,
                auth_session=auth_session,
            )

            if result.requires_auth:
                # Build auth required event with metadata
                auth_metadata = result.metadata or {}
                reason = auth_metadata.get("reason", "auth_required")
                error_message = auth_metadata.get("message")
                two_factor_identifier = auth_metadata.get("two_factor_identifier")

                # Persist two-factor challenge state so OTP retries can resume login.
                session_payload = (auth_session or {}).get("session_payload") or {}
                if (
                    two_factor_identifier
                    and session_payload.get("username")
                    and session_payload.get("password")
                ):
                    try:
                        await SocialAuthService.store_scraper_session(
                            self.db,
                            job_id=job_id,
                            user_id=self.user_id,
                            username=session_payload["username"],
                            password=session_payload["password"],
                            otp_code=session_payload.get("otp_code"),
                            two_factor_identifier=two_factor_identifier,
                            sessionid=session_payload.get("sessionid"),
                            csrftoken=session_payload.get("csrftoken"),
                            ds_user_id=session_payload.get("ds_user_id"),
                        )
                    except Exception as persist_error:
                        logger.warning(
                            "Failed to persist two-factor identifier",
                            job_id=job_id,
                            user_id=self.user_id,
                            error=str(persist_error),
                        )

                existing_metadata = dict(job_metadata)
                existing_metadata["discovery_iteration"] = iteration_count
                if cursor:
                    existing_metadata["discovery_cursor"] = cursor
                else:
                    existing_metadata.pop("discovery_cursor", None)
                existing_metadata.update(
                    {
                        "auth_reason": reason,
                        "auth_message": error_message,
                    }
                )
                if "two_factor_identifier" in auth_metadata:
                    existing_metadata["two_factor_identifier"] = auth_metadata["two_factor_identifier"]
                else:
                    existing_metadata.pop("two_factor_identifier", None)
                if "checkpoint_url" in auth_metadata:
                    existing_metadata["checkpoint_url"] = auth_metadata["checkpoint_url"]
                else:
                    existing_metadata.pop("checkpoint_url", None)

                await SocialImportJobStore.update_job(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    updates={
                        "status": SocialImportJobStatus.AWAITING_AUTH.value,
                        "auth_required": True,
                        "error_message": error_message,
                        "metadata": existing_metadata,
                    },
                )

                event_payload = {
                    "job_id": job_id,
                    "status": SocialImportJobStatus.AWAITING_AUTH.value,
                    "reason": reason,
                    "message": error_message or "Login required to continue importing this profile",
                }

                # Include additional metadata for specific auth flows
                if "two_factor_identifier" in auth_metadata:
                    event_payload["two_factor_identifier"] = auth_metadata["two_factor_identifier"]
                if "checkpoint_url" in auth_metadata:
                    event_payload["checkpoint_url"] = auth_metadata["checkpoint_url"]

                await self._publish_event(
                    job_id,
                    "auth_required",
                    event_payload,
                )
                raise SocialImportAuthRequiredError()

            discovery_metadata = result.metadata or {}
            if discovery_metadata.get("error_type") in {
                "discovery_failure",
                "fetch_failure",
            } or discovery_metadata.get("error"):
                failure_message = discovery_metadata.get("message") or discovery_metadata.get("error") or "Photo discovery failed"
                failure_metadata = dict(job_metadata)
                failure_metadata.update({
                    "discovery_failure": True,
                    "discovery_error": failure_message,
                    "discovery_iteration": iteration_count,
                })
                await SocialImportJobStore.update_job(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    updates={
                        "status": SocialImportJobStatus.FAILED.value,
                        "error_message": failure_message,
                        "metadata": failure_metadata,
                    },
                )
                await self._publish_event(
                    job_id,
                    "job_failed",
                    {"job_id": job_id, "error": failure_message, "retryable": True},
                )
                return

            # Check if adding these photos would exceed the max limit
            current_count = ordinal - 1
            photos_to_add = result.photos
            if current_count + len(photos_to_add) > self.MAX_DISCOVERY_PHOTOS:
                allowed_count = self.MAX_DISCOVERY_PHOTOS - current_count
                photos_to_add = photos_to_add[:allowed_count]

            inserted = await SocialImportJobStore.add_discovered_photos(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                start_ordinal=ordinal,
                photos=[photo.model_dump() for photo in photos_to_add],
            )
            ordinal += len(inserted)

            # If we've hit the max photos limit, stop discovery
            if ordinal > self.MAX_DISCOVERY_PHOTOS:
                break

            if inserted:
                await self._publish_event(
                    job_id,
                    "photo_discovered",
                    {
                        "job_id": job_id,
                        "count": len(inserted),
                        "discovered_photos": ordinal - 1,
                    },
                )

            if result.exhausted:
                break

            cursor = result.next_cursor
            if not cursor:
                break

            job_metadata["discovery_cursor"] = cursor
            job_metadata["discovery_iteration"] = iteration_count
            await SocialImportJobStore.update_job(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                updates={"metadata": job_metadata},
            )

        job_metadata.pop("discovery_cursor", None)
        job_metadata.pop("discovery_iteration", None)

        await SocialImportJobStore.update_job(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            updates={
                "discovery_completed": True,
                "auth_required": False,
                "status": SocialImportJobStatus.PROCESSING.value,
                "metadata": job_metadata,
            },
        )
        await self._publish_event(
            job_id,
            "job_updated",
            {
                "job_id": job_id,
                "status": SocialImportJobStatus.PROCESSING.value,
                "discovery_completed": True,
            },
        )

    async def _run_queue(self, job_id: str) -> None:
        await SocialImportJobStore.set_job_status(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            status=SocialImportJobStatus.PROCESSING,
            error_message=None,
        )

        # Keep pumping until we are blocked on user review/auth or completed.
        while True:
            if self._capacity_exhausted:
                # Upstream AI capacity exhausted mid-run; don't claim more
                # photos (each would just fail the same way). Apply the
                # capped-backoff policy: bounded retries, then a clear pause.
                await self._handle_capacity_exhaustion(job_id)
                return
            job = await SocialImportJobStore.get_job(
                self.db, job_id=job_id, user_id=self.user_id
            )
            if not job:
                return

            if job.get("status") in {
                SocialImportJobStatus.CANCELLED.value,
                SocialImportJobStatus.FAILED.value,
                SocialImportJobStatus.AWAITING_AUTH.value,
                SocialImportJobStatus.PAUSED_RATE_LIMITED.value,
            }:
                return

            slots = await SocialImportJobStore.get_slots(
                self.db, job_id=job_id, user_id=self.user_id
            )
            awaiting = slots["awaiting"]
            buffered = slots["buffered"]
            processing = slots["processing"]

            if processing:
                await self._process_single_photo(job_id, processing)
                continue

            if awaiting and buffered:
                # Queue full: one awaiting, one preprocessed. Wait for user decision.
                await self._sync_job_counters(job_id)
                return

            if not awaiting and buffered:
                promoted = await SocialImportJobStore.update_photo(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    photo_id=buffered["id"],
                    updates={
                        "status": SocialImportPhotoStatus.AWAITING_REVIEW.value,
                    },
                )
                promoted_full = await SocialImportJobStore.get_photo_with_items(
                    self.db,
                    job_id=job_id,
                    photo=promoted,
                    user_id=self.user_id,
                )
                await self._publish_event(
                    job_id,
                    "photo_ready_for_review",
                    {"job_id": job_id, "photo": promoted_full},
                )
                awaiting = promoted

            if not awaiting:
                claimed = await SocialImportJobStore.claim_next_queued_photo(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                )
                if claimed:
                    await self._process_single_photo(job_id, claimed)
                    continue

            if awaiting and not buffered:
                # We can process one photo in background while user reviews current one.
                claimed = await SocialImportJobStore.claim_next_queued_photo(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                )
                if claimed:
                    await self._process_single_photo(job_id, claimed)
                    continue

            done = await self._is_job_complete(job_id)
            if done:
                await self._complete_job(job_id)
                return

            await self._sync_job_counters(job_id)
            return

    async def _check_rate_limit_with_pause(
        self, job_id: str, operation_type: str, count: int = 1
    ) -> bool:
        """Atomically reserve quota; if unavailable, pause job and return False."""
        reserved = await AISettingsService.reserve_usage(
            user_id=self.user_id,
            operation_type=operation_type,
            db=self.db,
            count=count,
        )
        if not reserved:
            await self._pause_for_rate_limit(job_id, operation_type)
            return False
        return True

    def _build_item_dict(
        self,
        item: Dict[str, Any],
        temp_id: str,
        status: SocialImportItemStatus,
        generated_urls: Optional[Dict[str, str]] = None,
        generation_error: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Build an item dictionary with common fields and optional generation results."""
        result: Dict[str, Any] = {
            "temp_id": temp_id,
            "name": self._suggest_item_name(item),
            "category": item.get("category") or "other",
            "sub_category": item.get("sub_category"),
            "colors": item.get("colors") or [],
            "material": item.get("material"),
            "pattern": item.get("pattern"),
            "brand": item.get("brand"),
            "confidence": item.get("confidence") or 0,
            "bounding_box": item.get("bounding_box"),
            "detailed_description": item.get("detailed_description"),
            "source_image_url": item.get("source_image_url"),
            "source_image_storage_path": item.get("source_image_storage_path"),
            "status": status.value,
        }
        if generated_urls:
            result["generated_image_url"] = generated_urls.get("image_url")
            result["generated_thumbnail_url"] = generated_urls.get("thumbnail_url")
            result["generated_storage_path"] = generated_urls.get("storage_path")
        if generation_error:
            result["generation_error"] = generation_error
        return result

    # Sentinel stored in photo.metadata when a photo was extracted but paused
    # before generation (plan limit or provider capacity). The retry reuses
    # the stored extraction instead of burning a second extraction slot; the
    # source-image reference rides along so re-generation keeps the product
    # reference image (social_import_items has no source-image columns).
    _PENDING_EXTRACTION_KEY = "pending_extraction"

    async def _store_pending_extraction(
        self,
        *,
        job_id: str,
        photo_id: str,
        items: List[Dict[str, Any]],
        source_image_url: Optional[str],
        source_image_storage_path: Optional[str],
    ) -> None:
        """Persist the extraction result of a photo paused before generation."""
        photo = await SocialImportJobStore.get_photo(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            photo_id=photo_id,
        )
        if not photo:
            return
        metadata = dict(photo.get("metadata") or {})
        metadata[self._PENDING_EXTRACTION_KEY] = {
            "items": items,
            "source_image_url": source_image_url,
            "source_image_storage_path": source_image_storage_path,
        }
        await SocialImportJobStore.update_photo(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            photo_id=photo_id,
            updates={"metadata": metadata},
        )

    async def _process_single_photo(self, job_id: str, photo: Dict[str, Any]) -> None:
        photo_id = photo["id"]
        # Set before the try so the except handler can safely test them: the
        # extraction reservation is only released when it was made but never
        # consumed by an actual provider call.
        extraction_reserved = False
        extraction_attempted = False
        await self._publish_event(
            job_id,
            "photo_processing_started",
            {
                "job_id": job_id,
                "photo_id": photo_id,
                "ordinal": photo.get("ordinal"),
            },
        )

        try:
            # ---- extraction phase ----
            # A4-03: a photo paused before generation carries its extraction
            # result in metadata; reuse it so the retry does not re-extract
            # (and does not reserve a second extraction slot).
            photo_metadata = dict(photo.get("metadata") or {})
            pending = photo_metadata.get(self._PENDING_EXTRACTION_KEY)
            raw_items: Optional[List[Dict[str, Any]]] = None
            source_image_url: Optional[str] = None
            source_image_storage_path: Optional[str] = None
            if isinstance(pending, dict) and pending.get("items"):
                raw_items = [dict(item) for item in pending["items"]]
                source_image_url = pending.get("source_image_url")
                source_image_storage_path = pending.get("source_image_storage_path")
                logger.info(
                    "Reusing stored extraction for paused photo",
                    job_id=job_id,
                    photo_id=photo_id,
                )
            else:
                if not await self._check_rate_limit_with_pause(
                    job_id, OperationType.EXTRACTION
                ):
                    await SocialImportJobStore.update_photo(
                        self.db,
                        job_id=job_id,
                        user_id=self.user_id,
                        photo_id=photo_id,
                        updates={"status": SocialImportPhotoStatus.QUEUED.value},
                    )
                    return
                # The reservation above is only consumed by an actual provider
                # call. If the pre-extraction fetch/setup fails, the outer
                # handler releases it again so the daily slot is not burned on
                # a photo that never reached the VLM.
                extraction_reserved = True
                extraction_attempted = False

                image_base64 = await SocialScraperService.fetch_photo_as_base64(
                    photo["source_photo_url"]
                )
                extraction_agent = await get_item_extraction_agent(
                    user_id=self.user_id, db=self.db
                )
                extraction_attempted = True
                extraction_result = await extraction_agent.extract_multiple_items(
                    image_base64=image_base64
                )
                raw_items = extraction_result.get("items") or []
                if not raw_items:
                    await SocialImportJobStore.update_photo(
                        self.db,
                        job_id=job_id,
                        user_id=self.user_id,
                        photo_id=photo_id,
                        updates={
                            "status": SocialImportPhotoStatus.FAILED.value,
                            "error_message": "No clothing items detected in photo",
                            "processing_completed_at": utcnow_iso(),
                        },
                    )
                    await self._publish_event(
                        job_id,
                        "photo_failed",
                        {
                            "job_id": job_id,
                            "photo_id": photo_id,
                            "error": "No items detected",
                        },
                    )
                    await self._sync_job_counters(job_id)
                    return

                # Persist the source photo once and attach to every item
                # extracted from it, so the image generator can reproduce the
                # exact garment. Best-effort: missing source image degrades to
                # text-only gen.
                try:
                    raw_b64 = (
                        image_base64.split("base64,", 1)[-1]
                        if "base64," in image_base64
                        else image_base64
                    )
                    source_upload = await StorageService.upload_source_image(
                        db=self.db,
                        user_id=self.user_id,
                        file_data=base64.b64decode(raw_b64),
                        extension=".jpg",
                    )
                    source_image_url = source_upload.get("image_url")
                    source_image_storage_path = source_upload.get("storage_path")
                except Exception as upload_err:
                    logger.warning(
                        "Source image upload failed in social import; continuing",
                        extra={
                            "job_id": job_id,
                            "photo_id": photo_id,
                            "error": str(upload_err),
                        },
                    )

            if raw_items is None:
                raw_items = []

            # Attach the source-image reference to items that lack one (both
            # the fresh and the reused-extraction paths).
            for item in raw_items:
                if not item.get("source_image_url"):
                    item["source_image_url"] = source_image_url
                    item["source_image_storage_path"] = source_image_storage_path

            # ---- generation quota reservation ----
            # A4-03: reserve generation BEFORE any generation work. When the
            # user's plan limit is reached the extraction slot is released and
            # the extraction result is stored, so the paused photo does not
            # re-extract (and double-burn slots) after the daily reset.
            if not await self._check_rate_limit_with_pause(
                job_id, OperationType.GENERATION, count=len(raw_items)
            ):
                if extraction_reserved:
                    try:
                        await AISettingsService.release_usage(
                            user_id=self.user_id,
                            operation_type=OperationType.EXTRACTION,
                            db=self.db,
                        )
                    except Exception as release_err:
                        logger.warning(
                            "Failed to release extraction reservation after generation decline",
                            extra={
                                "job_id": job_id,
                                "photo_id": photo_id,
                                "error": str(release_err),
                            },
                        )
                await self._store_pending_extraction(
                    job_id=job_id,
                    photo_id=photo_id,
                    items=raw_items,
                    source_image_url=source_image_url,
                    source_image_storage_path=source_image_storage_path,
                )
                await SocialImportJobStore.update_photo(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    photo_id=photo_id,
                    updates={"status": SocialImportPhotoStatus.QUEUED.value},
                )
                return

            generation_agent = await get_image_generation_agent(
                user_id=self.user_id, db=self.db
            )
            processed_items: List[Dict[str, Any]] = []
            generation_success_count = 0
            # provider_billed_count tracks items that actually consumed the
            # AI generation provider's quota (generate_product_image returned
            # successfully). generation_success_count only counts items that
            # additionally decoded + uploaded. A provider-billed item whose
            # decode/upload then fails has already consumed quota and must NOT
            # be refunded on a later capacity pause - that would give back a
            # slot the provider already used. (backend #15)
            provider_billed_count = 0

            # Cache the source-photo download by URL: every item on a photo
            # shares the same source_image_url, so fetch it once instead of
            # re-GETting the multi-MB JPEG per item. (Items carrying their own
            # distinct URL are still fetched once each.)
            source_photo_cache: Dict[str, Optional[str]] = {}
            capacity_hit = False
            for item in raw_items:
                if self._capacity_exhausted:
                    capacity_hit = True
                    break
                temp_id = item.get("temp_id") or f"item-{uuid.uuid4().hex[:8]}"
                item_description = (
                    item.get("detailed_description")
                    or f"{(item.get('colors') or [''])[0]} {item.get('sub_category') or item.get('category') or 'clothing'}".strip()
                )

                # Resolve this item's source photo via the cache so siblings
                # share one download. The bytes never hit DB storage (kept
                # in-memory only for this call); resolve_product_reference_image
                # then decides whether to use this full photo as-is, crop it to
                # the item's bbox, or drop it entirely - see that function for why.
                src_url = item.get("source_image_url")
                if src_url and src_url not in source_photo_cache:
                    try:
                        source_photo_cache[src_url] = await SocialScraperService.fetch_photo_as_base64(src_url)
                    except (SocialImportError, httpx.HTTPStatusError, httpx.RequestError):
                        # A failed optional reference download (4xx/5xx,
                        # timeout, network error) degrades to text-only
                        # generation; it must not fail the whole photo.
                        source_photo_cache[src_url] = None
                reference_image_base64: Optional[str] = (
                    source_photo_cache.get(src_url) if src_url else None
                )

                reference_image_base64, reference_strategy = resolve_product_reference_image(
                    reference_image_base64,
                    item.get("bounding_box"),
                    float(item.get("confidence") or 0.0),
                    len(raw_items),
                )
                logger.info(
                    "Resolved product-image reference strategy",
                    extra={
                        "job_id": job_id,
                        "photo_id": photo_id,
                        "temp_id": temp_id,
                        "strategy": reference_strategy,
                        "sibling_count": len(raw_items),
                        "confidence": item.get("confidence"),
                        "has_bounding_box": item.get("bounding_box") is not None,
                    },
                )

                try:
                    generated = await generation_agent.generate_product_image(
                        item_description=item_description,
                        category=item.get("category") or "other",
                        sub_category=item.get("sub_category"),
                        colors=item.get("colors") or [],
                        material=item.get("material"),
                        # "transparent" -> flat white prompt + server-side
                        # matte (app/utils/background_removal.py).
                        background="transparent",
                        view_angle="front",
                        include_shadows=False,
                        reference_image=reference_image_base64,
                    )
                    # The provider call succeeded: quota for this item is
                    # consumed regardless of whether decode/upload then
                    # fails. Count it as billed NOW so a later capacity
                    # pause never refunds this slot (backend #15).
                    provider_billed_count += 1

                    image_bytes = base64.b64decode(generated.image_base64)
                    uploaded = await StorageService.upload_temp_generated_image(
                        db=self.db,
                        user_id=self.user_id,
                        file_data=image_bytes,
                        source="social-import",
                    )
                    generation_success_count += 1
                    processed_items.append(
                        self._build_item_dict(
                            item,
                            temp_id,
                            SocialImportItemStatus.GENERATED,
                            generated_urls={
                                "image_url": uploaded.get("image_url"),
                                "thumbnail_url": uploaded.get("thumbnail_url"),
                                "storage_path": uploaded.get("storage_path"),
                            },
                        )
                    )
                except Exception as generation_error:
                    # A provider quota failure on one item must stop the queue
                    # grinding every remaining photo through the same doomed
                    # generation call: set the capacity flag, break out of the
                    # item loop, and requeue the whole photo (its extraction
                    # result is stored so the retry does not re-extract).
                    if (
                        getattr(generation_error, "error_kind", None) == "upstream_quota"
                        and not self._capacity_exhausted
                    ):
                        self._capacity_exhausted = True
                        await self._publish_event(
                            job_id,
                            "capacity_exhausted",
                            {
                                "job_id": job_id,
                                "photo_id": photo_id,
                                "error": "AI service capacity exhausted; remaining photos will retry later",
                                "code": "AI_SERVICE_ERROR",
                                "error_kind": "upstream_quota",
                                "retry_after_seconds": getattr(generation_error, "retry_after_seconds", None),
                            },
                        )
                    if self._capacity_exhausted:
                        capacity_hit = True
                        break
                    processed_items.append(
                        self._build_item_dict(
                            item,
                            temp_id,
                            SocialImportItemStatus.FAILED,
                            generation_error=str(generation_error),
                        )
                    )

            if capacity_hit:
                # A4-01: the photo is NOT delivered as failed - store the
                # extraction result and requeue it so the retry re-generates
                # instead of burning a fresh extraction slot on a photo that
                # was already extracted.
                #
                # A4-03: the generation reservation at the top of this photo
                # covered ALL items, but capacity stopped the loop early —
                # items never attempted must hand their reserved slots back
                # NOW, before the retry re-reserves the full photo. Without
                # this, a first-item outage on a multi-item photo burns the
                # user's daily generation allowance without delivering any
                # reviewable result (and every retry cycle double-reserves).
                #
                # The whole photo is requeued below and the retry RE-RESERVES
                # the full reservation and re-bills every item — so the full
                # reservation is returned here (the retry bills each item
                # exactly once, not twice). Refunding only
                # len(raw_items) - provider_billed_count would keep the
                # already-billed slots held AND re-bill them on the retry,
                # double-charging one item for a single delivered result. The
                # provider_billed_count distinction (backend #15) belongs to
                # the delivered-photo path where a billed-but-not-uploaded
                # item is NOT refunded because the photo proceeds to review.
                unused_generation = len(raw_items)
                if unused_generation > 0:
                    try:
                        await AISettingsService.release_usage(
                            user_id=self.user_id,
                            operation_type=OperationType.GENERATION,
                            db=self.db,
                            count=unused_generation,
                        )
                    except Exception as release_err:
                        logger.warning(
                            "Failed to release generation reservation after capacity pause",
                            extra={
                                "job_id": job_id,
                                "photo_id": photo_id,
                                "unused": unused_generation,
                                "error": str(release_err),
                            },
                        )
                await self._store_pending_extraction(
                    job_id=job_id,
                    photo_id=photo_id,
                    items=raw_items,
                    source_image_url=source_image_url,
                    source_image_storage_path=source_image_storage_path,
                )
                await SocialImportJobStore.update_photo(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    photo_id=photo_id,
                    updates={"status": SocialImportPhotoStatus.QUEUED.value},
                )
                await self._sync_job_counters(job_id)
                return

            await SocialImportJobStore.upsert_photo_items(
                self.db,
                job_id=job_id,
                photo_id=photo_id,
                user_id=self.user_id,
                items=processed_items,
            )

            slots = await SocialImportJobStore.get_slots(
                self.db, job_id=job_id, user_id=self.user_id
            )
            target_status = (
                SocialImportPhotoStatus.BUFFERED_READY
                if slots["awaiting"]
                else SocialImportPhotoStatus.AWAITING_REVIEW
            )

            # Drop the pending-extraction marker: the photo is delivered.
            photo_metadata.pop(self._PENDING_EXTRACTION_KEY, None)
            updated_photo = await SocialImportJobStore.update_photo(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                photo_id=photo_id,
                updates={
                    "status": target_status.value,
                    "processing_completed_at": utcnow_iso(),
                    "error_message": None,
                    "metadata": photo_metadata,
                },
            )
            updated_photo = await SocialImportJobStore.get_photo_with_items(
                self.db,
                job_id=job_id,
                photo=updated_photo,
                user_id=self.user_id,
            )

            event_type = (
                "photo_buffered_ready"
                if target_status == SocialImportPhotoStatus.BUFFERED_READY
                else "photo_ready_for_review"
            )
            await self._publish_event(
                job_id,
                event_type,
                {"job_id": job_id, "photo": updated_photo},
            )
            await self._sync_job_counters(job_id)
            # A4-01: real progress resets the capacity backoff budget so a
            # later outage starts fresh instead of inheriting old attempts.
            await self._clear_capacity_retry_state(job_id)

        except Exception as e:
            error_kind = getattr(e, "error_kind", None)
            retry_after = getattr(e, "retry_after_seconds", None)
            # Upstream capacity/quota exhaustion is the server's problem ("on
            # us"), not the user's plan limit (which is raised pre-flight as
            # PAUSED_RATE_LIMITED). Stop grinding the remaining photos and tag
            # the event so the UI can say "try again shortly" - never an
            # upgrade. A4-01: do NOT mark the photo FAILED - requeue it so the
            # capped-backoff retry processes it, and release the extraction
            # reservation (this attempt's results are lost, so each retry
            # cycle must not double-burn the daily extraction budget).
            if error_kind == "upstream_quota":
                self._capacity_exhausted = True
                await self._publish_event(
                    job_id,
                    "capacity_exhausted",
                    {
                        "job_id": job_id,
                        "photo_id": photo_id,
                        "error": "AI service capacity exhausted; remaining photos will retry later",
                        "code": "AI_SERVICE_ERROR",
                        "error_kind": error_kind,
                        "retry_after_seconds": retry_after,
                    },
                )
                if extraction_reserved:
                    try:
                        await AISettingsService.release_usage(
                            user_id=self.user_id,
                            operation_type=OperationType.EXTRACTION,
                            db=self.db,
                        )
                    except Exception as release_err:
                        logger.warning(
                            "Failed to release extraction reservation after capacity exhaustion",
                            extra={
                                "job_id": job_id,
                                "photo_id": photo_id,
                                "error": str(release_err),
                            },
                        )
                await SocialImportJobStore.update_photo(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    photo_id=photo_id,
                    updates={
                        "status": SocialImportPhotoStatus.QUEUED.value,
                        "error_message": str(e),
                    },
                )
                await self._sync_job_counters(job_id)
                return
            # The extraction reservation was never consumed by a provider
            # call (fetch/setup failed before the VLM ran): give the slot back
            # so the failure cannot silently consume the daily extraction
            # budget. Best-effort: a failed release must not mask the original
            # error.
            if extraction_reserved and not extraction_attempted:
                try:
                    await AISettingsService.release_usage(
                        user_id=self.user_id,
                        operation_type=OperationType.EXTRACTION,
                        db=self.db,
                    )
                except Exception as release_err:
                    logger.warning(
                        "Failed to release un-consumed extraction reservation",
                        extra={
                            "job_id": job_id,
                            "photo_id": photo_id,
                            "error": str(release_err),
                        },
                    )
            await SocialImportJobStore.update_photo(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                photo_id=photo_id,
                updates={
                    "status": SocialImportPhotoStatus.FAILED.value,
                    "error_message": str(e),
                    "processing_completed_at": utcnow_iso(),
                },
            )
            await self._publish_event(
                job_id,
                "photo_failed",
                {
                    "job_id": job_id,
                    "photo_id": photo_id,
                    "error": str(e),
                    "code": "AI_SERVICE_ERROR",
                    "error_kind": error_kind,
                    "retry_after_seconds": retry_after,
                },
            )
            await self._sync_job_counters(job_id)

    async def approve_photo(self, job_id: str, photo_id: str) -> Dict[str, Any]:
        lock = self._job_lock(job_id)
        async with lock:
            photo = await SocialImportJobStore.get_photo(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                photo_id=photo_id,
            )
            if not photo:
                # A4-07: photo-scoped body — a bad photo id must not read as
                # "job not found".
                raise SocialImportPhotoNotFoundError(photo_id)

            # A4-01: approve is only valid for photos still awaiting review —
            # mirror reject's guard. Approving a photo still `processing`
            # would save 0 items, flip APPROVED, and then the running
            # `_process_single_photo` overwrites the status back to
            # awaiting_review/buffered_ready (reverted approval) or FAILED.
            if photo.get("status") not in {
                SocialImportPhotoStatus.AWAITING_REVIEW.value,
                SocialImportPhotoStatus.BUFFERED_READY.value,
            }:
                raise SocialImportPhotoStateError(
                    "Only photos awaiting review can be approved"
                )

            items = await SocialImportJobStore.list_items_for_photo(
                self.db,
                job_id=job_id,
                photo_id=photo_id,
                user_id=self.user_id,
            )
            saved_count = 0
            saved_items: List[Dict[str, Any]] = []
            for item in items:
                if item.get("status") in {
                    SocialImportItemStatus.FAILED.value,
                    SocialImportItemStatus.DISCARDED.value,
                    SocialImportItemStatus.SAVED.value,
                }:
                    continue
                try:
                    saved_item_id = await self._save_item_from_social_item(item)
                except Exception as save_error:
                    logger.warning(
                        "Failed to save approved social import item",
                        job_id=job_id,
                        photo_id=photo_id,
                        item_id=item.get("id"),
                        user_id=self.user_id,
                        error=str(save_error),
                    )
                    await SocialImportJobStore.update_item(
                        self.db,
                        job_id=job_id,
                        photo_id=photo_id,
                        item_id=item["id"],
                        user_id=self.user_id,
                        updates={
                            "status": SocialImportItemStatus.FAILED.value,
                            "generation_error": f"Save failed: {save_error}",
                        },
                    )
                    continue
                if saved_item_id:
                    saved_count += 1
                    saved_items.append(
                        {
                            "id": saved_item_id,
                            "category": item.get("category"),
                        }
                    )
                    await SocialImportJobStore.update_item(
                        self.db,
                        job_id=job_id,
                        photo_id=photo_id,
                        item_id=item["id"],
                        user_id=self.user_id,
                        updates={
                            "status": SocialImportItemStatus.SAVED.value,
                            "saved_item_id": saved_item_id,
                        },
                    )

            await SocialImportJobStore.update_photo(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                photo_id=photo_id,
                updates={
                    "status": SocialImportPhotoStatus.APPROVED.value,
                    "reviewed_at": utcnow_iso(),
                },
            )

            await self._publish_event(
                job_id,
                "photo_approved",
                {
                    "job_id": job_id,
                    "photo_id": photo_id,
                    "saved_count": saved_count,
                },
            )

            await self._promote_buffered_if_available(job_id)
            await self._sync_job_counters(job_id)

        await self.schedule_job(self, job_id)
        return {"saved_count": saved_count, "saved_items": saved_items}

    async def reject_photo(self, job_id: str, photo_id: str) -> Dict[str, Any]:
        lock = self._job_lock(job_id)
        async with lock:
            photo = await SocialImportJobStore.get_photo(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                photo_id=photo_id,
            )
            if not photo:
                raise SocialImportPhotoNotFoundError(photo_id)

            # A4-09: reject is only valid for photos still awaiting review.
            # Rejecting an APPROVED photo would flip its saved items to
            # DISCARDED and desync the wardrobe state (the items live in
            # `items`, not here). Rejecting an already-rejected photo is a
            # no-op the client should not issue.
            if photo.get("status") not in {
                SocialImportPhotoStatus.AWAITING_REVIEW.value,
                SocialImportPhotoStatus.BUFFERED_READY.value,
            }:
                raise SocialImportPhotoStateError(
                    "Only photos awaiting review can be rejected"
                )

            items = await SocialImportJobStore.list_items_for_photo(
                self.db,
                job_id=job_id,
                photo_id=photo_id,
                user_id=self.user_id,
            )
            temp_paths = [
                item.get("generated_storage_path")
                for item in items
                if item.get("generated_storage_path")
            ]
            await StorageService.cleanup_temp_images(self.db, temp_paths)

            await SocialImportJobStore.set_items_status_for_photo(
                self.db,
                job_id=job_id,
                photo_id=photo_id,
                user_id=self.user_id,
                status=SocialImportItemStatus.DISCARDED,
            )

            await SocialImportJobStore.update_photo(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                photo_id=photo_id,
                updates={
                    "status": SocialImportPhotoStatus.REJECTED.value,
                    "reviewed_at": utcnow_iso(),
                },
            )

            await self._publish_event(
                job_id,
                "photo_rejected",
                {"job_id": job_id, "photo_id": photo_id},
            )

            await self._promote_buffered_if_available(job_id)
            await self._sync_job_counters(job_id)

        await self.schedule_job(self, job_id)
        return {"rejected": True}

    async def patch_item(
        self,
        job_id: str,
        photo_id: str,
        item_id: str,
        updates: Dict[str, Any],
    ) -> Optional[Dict[str, Any]]:
        payload = dict(updates)
        payload["status"] = SocialImportItemStatus.EDITED.value
        return await SocialImportJobStore.update_item(
            self.db,
            job_id=job_id,
            photo_id=photo_id,
            item_id=item_id,
            user_id=self.user_id,
            updates=payload,
        )

    async def cancel_job(self, job_id: str) -> None:
        lock = self._job_lock(job_id)
        async with lock:
            await SocialImportJobStore.set_job_status(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                status=SocialImportJobStatus.CANCELLED,
                completed=True,
            )
            await self._cleanup_unsaved_temp_assets(job_id)
            await SocialImportJobStore.delete_job_artifacts(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
            )
            await self._publish_event(
                job_id,
                "job_cancelled",
                {"job_id": job_id},
            )
        await self.cancel_scheduled_job(job_id)

    async def accept_auth(
        self,
        job_id: str,
        auth_type: str,
        payload: Dict[str, Any],
    ) -> None:
        """Accept OAuth or scraper authentication and resume the job."""
        resume_job = False
        lock = self._job_lock(job_id)
        async with lock:
            job = await SocialImportJobStore.get_job(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
            )
            if not job:
                raise SocialImportJobNotFoundError(job_id)

            job_status = job.get("status")
            terminal_statuses = {
                SocialImportJobStatus.COMPLETED.value,
                SocialImportJobStatus.CANCELLED.value,
                SocialImportJobStatus.FAILED.value,
            }
            if job_status in terminal_statuses:
                raise SocialImportError(
                    "Cannot accept authentication for a job in terminal state"
                )

            if auth_type == "oauth":
                await SocialAuthService.store_oauth_session(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    provider_access_token=payload["provider_access_token"],
                    provider_refresh_token=payload.get("provider_refresh_token"),
                    provider_user_id=payload.get("provider_user_id"),
                    provider_page_access_token=payload.get("provider_page_access_token"),
                    provider_page_id=payload.get("provider_page_id"),
                    provider_username=payload.get("provider_username"),
                    expires_at=payload.get("expires_at"),
                )
            else:  # scraper
                existing_session = await SocialAuthService.get_active_session(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                )
                existing_payload = (existing_session or {}).get("session_payload") or {}
                await SocialAuthService.store_scraper_session(
                    self.db,
                    job_id=job_id,
                    user_id=self.user_id,
                    username=payload["username"],
                    password=payload["password"],
                    otp_code=payload.get("otp_code"),
                    two_factor_identifier=payload.get("two_factor_identifier")
                    or existing_payload.get("two_factor_identifier"),
                    sessionid=existing_payload.get("sessionid"),
                    csrftoken=existing_payload.get("csrftoken"),
                    ds_user_id=existing_payload.get("ds_user_id"),
                )

            if job_status != SocialImportJobStatus.AWAITING_AUTH.value:
                await self._publish_event(
                    job_id,
                    "auth_accepted",
                    {"job_id": job_id, "auth_type": auth_type, "resumed": False},
                )
                return

            cleared_metadata = dict(job.get("metadata") or {})
            for key in (
                "auth_reason",
                "auth_message",
                "two_factor_identifier",
                "checkpoint_url",
            ):
                cleared_metadata.pop(key, None)

            updated = await SocialImportJobStore.update_job(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                updates={
                    "status": SocialImportJobStatus.PROCESSING.value,
                    "auth_required": False,
                    "metadata": cleared_metadata,
                },
            )
            if not updated:
                raise SocialImportJobNotFoundError(job_id)

            resume_job = True
            await self._publish_event(
                job_id,
                "auth_accepted",
                {"job_id": job_id, "auth_type": auth_type},
            )
        if resume_job:  # pragma: no cover - unconditionally True here; all earlier paths return or raise
            await self.schedule_job(self, job_id)

    async def _recover_stale_job_if_needed(self, job: Dict[str, Any]) -> bool:
        """Recover a job left in `processing`/`discovering` by a dead process.

        Least-destructive option (documented): the job is NOT failed. Stuck
        photos are requeued to `queued` (they will be claimed and processed
        again), and the job is reset to its pre-run state -- discovery not
        completed -> `created`, so run() re-enters discovery and resumes from
        the persisted ``discovery_cursor`` metadata; discovery completed ->
        stays `processing`, so run() re-drives the queue. Returns True when a
        recovery was applied and the job was re-scheduled.
        """
        status = job.get("status")
        if status not in {
            SocialImportJobStatus.PROCESSING.value,
            SocialImportJobStatus.DISCOVERING.value,
        }:
            return False

        updated_at = job.get("updated_at")
        parsed = parse_utc_datetime(updated_at)
        if parsed is None:
            return False
        try:
            age = (utcnow() - parsed).total_seconds()
        except (TypeError, ValueError):
            return False
        if age < self.STALE_JOB_THRESHOLD_SECONDS:
            return False

        job_id = job["id"]
        # Requeue photos stuck in `processing` so the next run claims them
        # again instead of treating them as an in-flight slot forever.
        stuck_photos = await SocialImportJobStore.list_photos(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            statuses=[SocialImportPhotoStatus.PROCESSING],
        )
        for photo in stuck_photos:
            await SocialImportJobStore.update_photo(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                photo_id=photo["id"],
                updates={
                    "status": SocialImportPhotoStatus.QUEUED.value,
                    "error_message": "Interrupted by a service restart; queued for retry",
                    "processing_started_at": None,
                },
            )
        if stuck_photos:
            logger.info(
                "Recovered photos stuck in processing",
                job_id=job_id,
                user_id=self.user_id,
                count=len(stuck_photos),
            )

        if not job.get("discovery_completed"):
            await SocialImportJobStore.update_job(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                updates={"status": SocialImportJobStatus.CREATED.value},
            )
        await self._publish_event(
            job_id,
            "job_updated",
            {
                "job_id": job_id,
                "status": SocialImportJobStatus.CREATED.value
                if not job.get("discovery_completed")
                else SocialImportJobStatus.PROCESSING.value,
                "message": "Import was interrupted; resuming from where it stopped",
            },
        )
        logger.warning(
            "Recovering stale social import job",
            job_id=job_id,
            user_id=self.user_id,
            status=status,
            stuck_photos=len(stuck_photos),
        )
        await self.schedule_job(self, job_id)
        return True

    async def get_status(self, job_id: str) -> Dict[str, Any]:
        job = await SocialImportJobStore.get_job(
            self.db, job_id=job_id, user_id=self.user_id
        )
        if not job:
            raise SocialImportJobNotFoundError(job_id)

        # A4-04: jobs stuck in `processing`/`discovering` by a crashed or
        # restarted process never resume on their own. get_status is the
        # recovery trigger (every SSE connect and poll lands here): stale
        # jobs get their stuck photos requeued and are re-scheduled from
        # their pre-run state. run() itself re-drives whatever state it
        # finds, so once a run is scheduled the job recovers naturally.
        if await self._recover_stale_job_if_needed(job):
            job = await SocialImportJobStore.get_job(
                self.db, job_id=job_id, user_id=self.user_id
            )
            if not job:
                raise SocialImportJobNotFoundError(job_id)

        if job.get("status") == SocialImportJobStatus.PAUSED_RATE_LIMITED.value:
            resumed = await self._try_resume_rate_limited_job(job_id)
            if resumed:
                job = await SocialImportJobStore.get_job(
                    self.db, job_id=job_id, user_id=self.user_id
                )
                if not job:
                    raise SocialImportJobNotFoundError(job_id)

        slots = await SocialImportJobStore.get_slots(
            self.db, job_id=job_id, user_id=self.user_id
        )
        awaiting = await SocialImportJobStore.get_photo_with_items(
            self.db,
            job_id=job_id,
            photo=slots["awaiting"],
            user_id=self.user_id,
        )
        buffered = await SocialImportJobStore.get_photo_with_items(
            self.db,
            job_id=job_id,
            photo=slots["buffered"],
            user_id=self.user_id,
        )
        processing = await SocialImportJobStore.get_photo_with_items(
            self.db,
            job_id=job_id,
            photo=slots["processing"],
            user_id=self.user_id,
        )
        counts = await SocialImportJobStore.count_by_status(
            self.db, job_id=job_id, user_id=self.user_id
        )
        metadata = dict(job.get("metadata") or {})

        return {
            "id": job["id"],
            "status": job["status"],
            "platform": job["platform"],
            "source_url": job["source_url"],
            "normalized_url": job["normalized_url"],
            "total_photos": job.get("total_photos") or 0,
            "discovered_photos": job.get("discovered_photos") or 0,
            "processed_photos": job.get("processed_photos") or 0,
            "approved_photos": job.get("approved_photos") or 0,
            "rejected_photos": job.get("rejected_photos") or 0,
            "failed_photos": job.get("failed_photos") or 0,
            "auth_required": bool(job.get("auth_required")),
            "discovery_completed": bool(job.get("discovery_completed")),
            "error_message": job.get("error_message"),
            "auth_reason": metadata.get("auth_reason"),
            "two_factor_identifier": metadata.get("two_factor_identifier"),
            "checkpoint_url": metadata.get("checkpoint_url"),
            "awaiting_review_photo": awaiting,
            "buffered_photo": buffered,
            "processing_photo": processing,
            "queued_count": counts.get(SocialImportPhotoStatus.QUEUED.value, 0),
        }

    async def _persist_scraper_session_from_payload(
        self,
        *,
        job_id: str,
        auth_session: Optional[Dict[str, Any]],
    ) -> None:
        """Persist newly acquired scraper cookies/ids so discovery can resume without relogin."""
        if not auth_session:
            return
        payload = (auth_session or {}).get("session_payload") or {}
        username = payload.get("username")
        password = payload.get("password")
        if not username or not password:
            return

        # Persist only when we have auth-session artifacts worth keeping.
        if not any(payload.get(key) for key in ("sessionid", "csrftoken", "ds_user_id", "two_factor_identifier")):
            return

        try:
            await SocialAuthService.store_scraper_session(
                self.db,
                job_id=job_id,
                user_id=self.user_id,
                username=username,
                password=password,
                otp_code=payload.get("otp_code"),
                two_factor_identifier=payload.get("two_factor_identifier"),
                sessionid=payload.get("sessionid"),
                csrftoken=payload.get("csrftoken"),
                ds_user_id=payload.get("ds_user_id"),
            )
        except Exception as persist_error:
            logger.warning(
                "Failed to persist refreshed scraper session payload",
                job_id=job_id,
                user_id=self.user_id,
                error=str(persist_error),
            )

    async def _promote_buffered_if_available(self, job_id: str) -> None:
        slots = await SocialImportJobStore.get_slots(
            self.db, job_id=job_id, user_id=self.user_id
        )
        if slots["awaiting"] or not slots["buffered"]:
            return

        promoted = await SocialImportJobStore.update_photo(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            photo_id=slots["buffered"]["id"],
            updates={"status": SocialImportPhotoStatus.AWAITING_REVIEW.value},
        )
        promoted = await SocialImportJobStore.get_photo_with_items(
            self.db,
            job_id=job_id,
            photo=promoted,
            user_id=self.user_id,
        )
        await self._publish_event(
            job_id,
            "photo_ready_for_review",
            {"job_id": job_id, "photo": promoted},
        )

    async def _sync_job_counters(self, job_id: str) -> None:
        counts = await SocialImportJobStore.count_by_status(
            self.db, job_id=job_id, user_id=self.user_id
        )
        total_processed = (
            counts.get(SocialImportPhotoStatus.AWAITING_REVIEW.value, 0)
            + counts.get(SocialImportPhotoStatus.BUFFERED_READY.value, 0)
            + counts.get(SocialImportPhotoStatus.APPROVED.value, 0)
            + counts.get(SocialImportPhotoStatus.REJECTED.value, 0)
            + counts.get(SocialImportPhotoStatus.FAILED.value, 0)
            + counts.get(SocialImportPhotoStatus.PROCESSING.value, 0)
        )

        await SocialImportJobStore.update_job(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            updates={
                "processed_photos": total_processed,
                "approved_photos": counts.get(
                    SocialImportPhotoStatus.APPROVED.value, 0
                ),
                "rejected_photos": counts.get(
                    SocialImportPhotoStatus.REJECTED.value, 0
                ),
                "failed_photos": counts.get(SocialImportPhotoStatus.FAILED.value, 0),
                "total_photos": sum(counts.values()),
            },
        )

        await self._publish_event(
            job_id,
            "job_updated",
            {
                "job_id": job_id,
                "processed_photos": total_processed,
                "approved_photos": counts.get(
                    SocialImportPhotoStatus.APPROVED.value, 0
                ),
                "rejected_photos": counts.get(
                    SocialImportPhotoStatus.REJECTED.value, 0
                ),
                "failed_photos": counts.get(SocialImportPhotoStatus.FAILED.value, 0),
                "queued_count": counts.get(SocialImportPhotoStatus.QUEUED.value, 0),
            },
        )

    async def _pause_for_rate_limit(self, job_id: str, operation_type: str) -> None:
        message = self._build_rate_limit_pause_message(operation_type)
        await SocialImportJobStore.set_job_status(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            status=SocialImportJobStatus.PAUSED_RATE_LIMITED,
            error_message=message,
        )
        await self._publish_event(
            job_id,
            "rate_limit_paused",
            {
                "job_id": job_id,
                "status": SocialImportJobStatus.PAUSED_RATE_LIMITED.value,
                "operation_type": operation_type,
                "message": message,
            },
        )

    async def _try_resume_rate_limited_job(self, job_id: str) -> bool:
        extraction_check = await AISettingsService.check_rate_limit(
            user_id=self.user_id,
            operation_type=OperationType.EXTRACTION,
            db=self.db,
            count=1,
        )
        generation_check = await AISettingsService.check_rate_limit(
            user_id=self.user_id,
            operation_type=OperationType.GENERATION,
            db=self.db,
            count=1,
        )

        if not extraction_check.get("allowed") or not generation_check.get("allowed"):
            return False

        updated = await SocialImportJobStore.update_job(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            updates={
                "status": SocialImportJobStatus.PROCESSING.value,
                "error_message": None,
            },
        )
        if not updated:
            return False

        await self._publish_event(
            job_id,
            "job_updated",
            {
                "job_id": job_id,
                "status": SocialImportJobStatus.PROCESSING.value,
                "message": "Daily limit reset detected. Resuming queued social import photos.",
            },
        )
        await self.schedule_job(self, job_id)
        return True

    @staticmethod
    def _build_rate_limit_pause_message(operation_type: str) -> str:
        op = operation_type.replace("_", " ")
        return (
            f"Daily {op} limit reached. Remaining photos stay queued and will auto-resume "
            "after the next daily reset. Refer friends to get Pro for free or upgrade to Pro "
            "for higher limits."
        )

    async def _is_job_complete(self, job_id: str) -> bool:
        job = await SocialImportJobStore.get_job(
            self.db, job_id=job_id, user_id=self.user_id
        )
        if not job:
            return False
        if not job.get("discovery_completed"):
            return False

        counts = await SocialImportJobStore.count_by_status(
            self.db, job_id=job_id, user_id=self.user_id
        )
        return (
            counts.get(SocialImportPhotoStatus.QUEUED.value, 0) == 0
            and counts.get(SocialImportPhotoStatus.PROCESSING.value, 0) == 0
            and counts.get(SocialImportPhotoStatus.AWAITING_REVIEW.value, 0) == 0
            and counts.get(SocialImportPhotoStatus.BUFFERED_READY.value, 0) == 0
        )

    async def _complete_job(self, job_id: str) -> None:
        await self._sync_job_counters(job_id)
        await self._clear_capacity_retry_state(job_id)
        await SocialImportJobStore.set_job_status(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
            status=SocialImportJobStatus.COMPLETED,
            completed=True,
        )
        await self._cleanup_unsaved_temp_assets(job_id)
        await SocialImportJobStore.delete_job_artifacts(
            self.db,
            job_id=job_id,
            user_id=self.user_id,
        )
        await self._publish_event(
            job_id,
            "job_completed",
            {"job_id": job_id, "status": SocialImportJobStatus.COMPLETED.value},
        )

    async def _cleanup_unsaved_temp_assets(self, job_id: str) -> None:
        photos = await SocialImportJobStore.list_photos(
            self.db, job_id=job_id, user_id=self.user_id
        )
        temp_paths: List[str] = []
        for photo in photos:
            items = await SocialImportJobStore.list_items_for_photo(
                self.db,
                job_id=job_id,
                photo_id=photo["id"],
                user_id=self.user_id,
            )
            for item in items:
                if item.get("status") != SocialImportItemStatus.SAVED.value:
                    storage_path = item.get("generated_storage_path")
                    if storage_path:
                        temp_paths.append(storage_path)
        if temp_paths:
            await StorageService.cleanup_temp_images(self.db, temp_paths)

    async def _save_item_from_social_item(
        self, social_item: Dict[str, Any]
    ) -> Optional[str]:
        storage_path = social_item.get("generated_storage_path")
        if not storage_path:
            return None

        promoted = await StorageService.promote_temp_image_to_item(
            db=self.db,
            user_id=self.user_id,
            temp_storage_path=storage_path,
            filename_hint=f"{social_item.get('temp_id') or 'generated'}.png",
        )

        item_id = str(uuid.uuid4())
        now_iso = utcnow_iso()
        item_data = {
            "id": item_id,
            "user_id": self.user_id,
            "name": social_item.get("name") or "Imported Item",
            "category": social_item.get("category") or "other",
            "sub_category": social_item.get("sub_category"),
            "brand": social_item.get("brand"),
            "colors": social_item.get("colors") or [],
            "style": None,
            "material": social_item.get("material"),
            "materials": [],
            "pattern": social_item.get("pattern"),
            "seasonal_tags": [],
            "occasion_tags": [],
            "size": None,
            "price": None,
            "purchase_date": None,
            "purchase_location": None,
            "tags": ["social-import"],
            "notes": "Imported from social profile",
            "condition": "clean",
            "is_favorite": False,
            "usage_times_worn": 0,
            "usage_last_worn": None,
            "cost_per_wear": None,
            # Persist the source photo reference so re-generation, audit, and
            # UI can fetch the original garment photo later.
            "source_image_url": social_item.get("source_image_url"),
            "source_image_storage_path": social_item.get("source_image_storage_path"),
            "created_at": now_iso,
            "updated_at": now_iso,
            "is_deleted": False,
        }

        await asyncio.to_thread(self.db.table("items").insert(item_data).execute)

        image_data = {
            "id": str(uuid.uuid4()),
            "item_id": item_id,
            "image_url": promoted["image_url"],
            "thumbnail_url": promoted["thumbnail_url"],
            "storage_path": promoted["storage_path"],
            "is_primary": True,
            "width": None,
            "height": None,
            "created_at": now_iso,
        }
        await asyncio.to_thread(self.db.table("item_images").insert(image_data).execute)

        try:
            reserved = await AISettingsService.reserve_usage(
                user_id=self.user_id,
                operation_type=OperationType.EMBEDDING,
                db=self.db,
            )
            if reserved:
                embedding = await AIService.generate_item_embedding(
                    {**item_data, "images": [image_data]}
                )
                if embedding:
                    vector_service = get_vector_service()
                    await vector_service.upsert_item(
                        item_id=item_id,
                        embedding=embedding,
                        metadata={
                            "user_id": self.user_id,
                            "category": item_data["category"],
                            "colors": item_data["colors"],
                            "brand": item_data.get("brand") or "",
                            "name": item_data["name"],
                        },
                    )
        except Exception as e:
            logger.debug(
                "Failed to generate or store embedding for imported item (best-effort, continuing)",
                user_id=self.user_id,
                item_id=item_id,
                error=str(e)[:300],
            )

        return item_id

    @staticmethod
    def _suggest_item_name(item: Dict[str, Any]) -> str:
        parts: List[str] = []
        colors = item.get("colors") or []
        if colors:
            parts.append(str(colors[0]).capitalize())
        sub_category = item.get("sub_category")
        category = item.get("category")
        if sub_category:
            parts.append(str(sub_category).replace("_", " ").title())
        elif category:
            parts.append(str(category).replace("_", " ").title())
        return " ".join(parts) or "Imported Item"
