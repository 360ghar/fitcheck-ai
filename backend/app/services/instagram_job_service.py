"""
Instagram Job Service.

Manages in-memory Instagram scraping jobs with SSE support.
Jobs are stored in memory and auto-expire after 30 minutes.
"""

import asyncio
import logging
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from typing import Any, Dict, List, Optional
from uuid import uuid4

from app.models.instagram import (
    InstagramImageMeta,
    InstagramScrapeStatus,
    InstagramURLType,
)

logger = logging.getLogger(__name__)


@dataclass
class InstagramScrapeJob:
    """In-memory representation of an Instagram scrape job."""
    job_id: str
    user_id: str
    url_type: InstagramURLType
    identifier: str  # Username or shortcode
    status: InstagramScrapeStatus
    created_at: datetime

    # Scraped data
    images: List[InstagramImageMeta] = field(default_factory=list)
    scraped_count: int = 0
    total_count: Optional[int] = None
    has_more: bool = False

    # Error handling
    error_message: Optional[str] = None

    # SSE subscribers (queues for sending events)
    subscribers: List[asyncio.Queue] = field(default_factory=list)

    # Cancellation
    cancelled: bool = False
    cancel_event: asyncio.Event = field(default_factory=asyncio.Event)

    def is_cancelled(self) -> bool:
        """Check if job is cancelled."""
        return self.cancelled or self.cancel_event.is_set()

    def to_dict(self) -> Dict[str, Any]:
        """Convert job to dictionary for API responses."""
        return {
            "job_id": self.job_id,
            "status": self.status.value,
            "url_type": self.url_type.value,
            "identifier": self.identifier,
            "scraped_count": self.scraped_count,
            "total_count": self.total_count,
            "image_count": len(self.images),
            "has_more": self.has_more,
            "error": self.error_message,
        }


class InstagramJobService:
    """Manages Instagram scraping jobs."""

    _jobs: Dict[str, InstagramScrapeJob] = {}
    _lock: asyncio.Lock = asyncio.Lock()
    _cleanup_task: Optional[asyncio.Task] = None
    _job_ttl: timedelta = timedelta(minutes=30)

    @classmethod
    async def create_job(
        cls,
        user_id: str,
        url_type: InstagramURLType,
        identifier: str,
    ) -> InstagramScrapeJob:
        """Create a new Instagram scrape job."""
        job_id = str(uuid4())

        job = InstagramScrapeJob(
            job_id=job_id,
            user_id=user_id,
            url_type=url_type,
            identifier=identifier,
            status=InstagramScrapeStatus.PENDING,
            created_at=datetime.utcnow(),
        )

        async with cls._lock:
            cls._jobs[job_id] = job

        # Start cleanup task if not running
        cls._ensure_cleanup_task()

        logger.info(
            "Created Instagram scrape job",
            extra={
                "job_id": job_id,
                "user_id": user_id,
                "url_type": url_type.value,
                "identifier": identifier,
            },
        )

        return job

    @classmethod
    async def get_job(cls, job_id: str, user_id: str) -> Optional[InstagramScrapeJob]:
        """Get a job by ID, validating user ownership."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job and job.user_id == user_id:
                return job
            return None

    @classmethod
    async def get_job_unsafe(cls, job_id: str) -> Optional[InstagramScrapeJob]:
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
                InstagramScrapeStatus.COMPLETED,
                InstagramScrapeStatus.CANCELLED,
                InstagramScrapeStatus.FAILED,
            ):
                return False

            job.cancelled = True
            job.cancel_event.set()
            job.status = InstagramScrapeStatus.CANCELLED

        # Broadcast cancellation
        await cls.broadcast_event(job_id, "scrape_cancelled", {
            "job_id": job_id,
            "timestamp": datetime.utcnow().isoformat(),
        })

        logger.info("Cancelled Instagram scrape job", extra={"job_id": job_id})
        return True

    @classmethod
    async def update_status(
        cls,
        job_id: str,
        status: InstagramScrapeStatus,
    ) -> None:
        """Update job status."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job:
                job.status = status

    @classmethod
    async def add_images(
        cls,
        job_id: str,
        images: List[InstagramImageMeta],
        scraped_count: int,
        total_count: int,
    ) -> None:
        """Add scraped images to job."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job:
                job.images.extend(images)
                job.scraped_count = scraped_count
                job.total_count = total_count

    @classmethod
    async def set_completed(
        cls,
        job_id: str,
        has_more: bool = False,
    ) -> None:
        """Mark job as completed."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job:
                job.status = InstagramScrapeStatus.COMPLETED
                job.has_more = has_more

    @classmethod
    async def set_error(cls, job_id: str, error: str) -> None:
        """Set job error and mark as failed."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job:
                job.error_message = error
                job.status = InstagramScrapeStatus.FAILED

    @classmethod
    async def broadcast_event(
        cls,
        job_id: str,
        event_type: str,
        data: Dict[str, Any],
    ) -> None:
        """Send SSE event to all subscribers of a job."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if not job:
                return

            subscribers = list(job.subscribers)

        event = {"type": event_type, "data": data}

        for queue in subscribers:
            try:
                await queue.put(event)
            except Exception as e:
                logger.warning(f"Failed to send event to subscriber: {e}")

    @classmethod
    async def add_subscriber(cls, job_id: str, queue: asyncio.Queue) -> bool:
        """Add an SSE subscriber to a job."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if not job:
                return False
            job.subscribers.append(queue)
            return True

    @classmethod
    async def remove_subscriber(cls, job_id: str, queue: asyncio.Queue) -> None:
        """Remove an SSE subscriber from a job."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job and queue in job.subscribers:
                job.subscribers.remove(queue)

    @classmethod
    async def get_job_status(cls, job_id: str) -> Optional[Dict[str, Any]]:
        """Get current status of a job for reconnection."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if not job:
                return None

            return {
                **job.to_dict(),
                "images": [
                    img.model_dump() for img in job.images
                ],
            }

    @classmethod
    async def get_job_images(
        cls,
        job_id: str,
        offset: int = 0,
        limit: int = 50,
    ) -> Optional[Dict[str, Any]]:
        """Get paginated images from a job."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if not job:
                return None

            images = job.images[offset:offset + limit]
            return {
                "images": [img.model_dump() for img in images],
                "total": len(job.images),
                "offset": offset,
                "limit": limit,
                "has_more": offset + limit < len(job.images),
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
            logger.info(f"Cleaned up {len(expired_ids)} expired Instagram jobs")
