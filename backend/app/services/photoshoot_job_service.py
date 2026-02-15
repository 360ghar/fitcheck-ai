"""
Photoshoot Job Service.

Manages in-memory photoshoot generation jobs for SSE streaming.
Jobs are stored in memory and auto-expire after 1 hour.
"""

import asyncio
import logging
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from typing import Any, Dict, List, Optional, Set
from uuid import uuid4

from app.models.photoshoot import PhotoshootJobStatus

logger = logging.getLogger(__name__)


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
    failed_indices: Set[int] = field(default_factory=set)

    # Cancellation
    cancelled: bool = False
    cancel_event: asyncio.Event = field(default_factory=asyncio.Event)

    # SSE subscribers
    subscribers: List[asyncio.Queue] = field(default_factory=list)

    # Event history for replay on late subscriber connect
    event_history: List[Dict[str, Any]] = field(default_factory=list)

    # Error info
    error_message: Optional[str] = None
    usage: Optional[Dict[str, Any]] = None

    def is_cancelled(self) -> bool:
        """Check if job is cancelled."""
        return self.cancelled or self.cancel_event.is_set()

    @property
    def generated_count(self) -> int:
        return len(self.generated_images)

    @property
    def failed_count(self) -> int:
        return len(self.failed_indices)


class PhotoshootJobService:
    """Manages photoshoot generation jobs."""

    _jobs: Dict[str, PhotoshootJob] = {}
    _lock: asyncio.Lock = asyncio.Lock()
    _cleanup_task: Optional[asyncio.Task] = None
    _job_ttl: timedelta = timedelta(hours=1)

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
    ) -> PhotoshootJob:
        """Create a new photoshoot job."""
        job_id = str(uuid4())
        session_id = f"ps_{uuid4().hex[:12]}"
        total_batches = max(1, (num_images + batch_size - 1) // batch_size)

        job = PhotoshootJob(
            job_id=job_id,
            user_id=user_id,
            status=PhotoshootJobStatus.PENDING,
            created_at=datetime.utcnow(),
            photos=photos,
            use_case=use_case,
            custom_prompt=custom_prompt,
            num_images=num_images,
            batch_size=batch_size,
            aspect_ratio=aspect_ratio,
            session_id=session_id,
            total_batches=total_batches,
        )

        async with cls._lock:
            cls._jobs[job_id] = job

        # Start cleanup task if not running
        cls._ensure_cleanup_task()

        logger.info(
            "Created photoshoot job",
            extra={
                "job_id": job_id,
                "user_id": user_id,
                "num_images": num_images,
            },
        )

        return job

    @classmethod
    async def get_job(cls, job_id: str, user_id: str) -> Optional[PhotoshootJob]:
        """Get a job by ID, validating user ownership."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job and job.user_id == user_id:
                return job
            return None

    @classmethod
    async def get_job_by_id(cls, job_id: str) -> Optional[PhotoshootJob]:
        """Get a job by ID without user validation (for internal use)."""
        async with cls._lock:
            return cls._jobs.get(job_id)

    @classmethod
    async def cancel_job(cls, job_id: str, user_id: str) -> bool:
        """Cancel a running job."""
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

            job.cancelled = True
            job.cancel_event.set()
            job.status = PhotoshootJobStatus.CANCELLED

        # Broadcast cancellation
        await cls.broadcast_event(job_id, "job_cancelled", {
            "job_id": job_id,
            "timestamp": datetime.utcnow().isoformat(),
        })

        logger.info("Cancelled photoshoot job", extra={"job_id": job_id})
        return True

    @classmethod
    async def update_status(cls, job_id: str, status: PhotoshootJobStatus) -> None:
        """Update job status."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job:
                job.status = status

    @classmethod
    async def update_current_batch(cls, job_id: str, batch_num: int) -> None:
        """Update the current batch number."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job:
                job.current_batch = batch_num

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
            if job:
                job.generated_images.append({
                    "id": image_id,
                    "index": index,
                    "image_base64": image_base64,
                    "image_url": image_url,
                })

    @classmethod
    async def mark_image_failed(cls, job_id: str, index: int, error: str) -> None:
        """Mark an image generation as failed."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job:
                job.failed_indices.add(index)

    @classmethod
    async def set_usage(cls, job_id: str, usage: Dict[str, Any]) -> None:
        """Set usage info on job completion."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job:
                job.usage = usage

    @classmethod
    async def set_error(cls, job_id: str, error: str) -> None:
        """Set job error and mark as failed."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job:
                job.error_message = error
                job.status = PhotoshootJobStatus.FAILED

    @classmethod
    async def broadcast_event(cls, job_id: str, event_type: str, data: Dict[str, Any]) -> None:
        """Send SSE event to all subscribers and store in history for late subscribers."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if not job:
                return

            event = {"type": event_type, "data": data}

            # Always store in event history for late-connecting subscribers
            job.event_history.append(event)

            subscribers = list(job.subscribers)

        for queue in subscribers:
            try:
                await queue.put(event)
            except Exception as e:
                logger.warning(f"Failed to send event to subscriber: {e}")

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
        """Remove an SSE subscriber from a job."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job and queue in job.subscribers:
                job.subscribers.remove(queue)

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
        """Get current status of a job for reconnection/polling."""
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
                await asyncio.sleep(300)  # Check every 5 minutes
                await cls._cleanup_expired_jobs()
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Cleanup loop error: {e}")

    @classmethod
    async def _cleanup_expired_jobs(cls) -> None:
        """Remove jobs older than TTL."""
        now = datetime.utcnow()
        expired_ids = []

        async with cls._lock:
            for job_id, job in cls._jobs.items():
                if now - job.created_at > cls._job_ttl:
                    expired_ids.append(job_id)

            for job_id in expired_ids:
                del cls._jobs[job_id]

        if expired_ids:
            logger.info(f"Cleaned up {len(expired_ids)} expired photoshoot jobs")
