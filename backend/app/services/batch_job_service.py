"""
Batch Job Service.

Manages in-memory batch processing jobs for multi-image AI extraction.
Jobs are stored in memory and auto-expire after 1 hour.
"""

import asyncio
import logging
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from enum import Enum
from typing import Any, Dict, List, Optional, Set
from uuid import uuid4

logger = logging.getLogger(__name__)


class BatchJobStatus(str, Enum):
    """Status of a batch processing job."""
    PENDING = "pending"
    EXTRACTING = "extracting"
    GENERATING = "generating"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    FAILED = "failed"


@dataclass
class BatchImageData:
    """Data for a single image in a batch job."""
    image_id: str
    image_base64: str
    filename: Optional[str] = None


@dataclass
class DetectedItemData:
    """A detected item from extraction."""
    temp_id: str
    image_id: str  # Source image
    category: str
    sub_category: Optional[str] = None
    colors: List[str] = field(default_factory=list)
    material: Optional[str] = None
    pattern: Optional[str] = None
    brand: Optional[str] = None
    confidence: float = 0.0
    bounding_box: Optional[Dict[str, float]] = None
    detailed_description: Optional[str] = None
    status: str = "detected"
    generated_image_base64: Optional[str] = None
    generated_image_url: Optional[str] = None
    generation_error: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            "temp_id": self.temp_id,
            "image_id": self.image_id,
            "category": self.category,
            "sub_category": self.sub_category,
            "colors": self.colors,
            "material": self.material,
            "pattern": self.pattern,
            "brand": self.brand,
            "confidence": self.confidence,
            "bounding_box": self.bounding_box,
            "detailed_description": self.detailed_description,
            "status": self.status,
            "generated_image_base64": self.generated_image_base64,
            "generated_image_url": self.generated_image_url,
            "generation_error": self.generation_error,
        }


@dataclass
class BatchJob:
    """In-memory representation of a batch processing job."""
    job_id: str
    user_id: str
    status: BatchJobStatus
    created_at: datetime
    auto_generate: bool = True
    generation_batch_size: int = 5

    # Images and items
    images: Dict[str, BatchImageData] = field(default_factory=dict)
    detected_items: List[DetectedItemData] = field(default_factory=list)

    # Progress tracking
    extraction_completed: Set[str] = field(default_factory=set)
    extraction_failed: Dict[str, str] = field(default_factory=dict)  # image_id -> error
    generation_completed: Set[str] = field(default_factory=set)
    generation_failed: Dict[str, str] = field(default_factory=dict)  # temp_id -> error

    # Cancellation
    cancelled: bool = False
    cancel_event: asyncio.Event = field(default_factory=asyncio.Event)

    # SSE subscribers (queues for sending events)
    subscribers: List[asyncio.Queue] = field(default_factory=list)

    # Error info
    error_message: Optional[str] = None

    def is_cancelled(self) -> bool:
        """Check if job is cancelled."""
        return self.cancelled or self.cancel_event.is_set()

    @property
    def total_images(self) -> int:
        return len(self.images)

    @property
    def total_items(self) -> int:
        return len(self.detected_items)


class BatchJobService:
    """Manages batch processing jobs."""

    _jobs: Dict[str, BatchJob] = {}
    _lock: asyncio.Lock = asyncio.Lock()
    _cleanup_task: Optional[asyncio.Task] = None
    _job_ttl: timedelta = timedelta(hours=1)

    @classmethod
    async def create_job(
        cls,
        user_id: str,
        images: List[Dict[str, Any]],
        auto_generate: bool = True,
        generation_batch_size: int = 5,
    ) -> BatchJob:
        """Create a new batch job."""
        job_id = str(uuid4())

        # Convert images to BatchImageData
        image_dict = {}
        for img in images:
            image_data = BatchImageData(
                image_id=img["image_id"],
                image_base64=img["image_base64"],
                filename=img.get("filename"),
            )
            image_dict[img["image_id"]] = image_data

        job = BatchJob(
            job_id=job_id,
            user_id=user_id,
            status=BatchJobStatus.PENDING,
            created_at=datetime.utcnow(),
            auto_generate=auto_generate,
            generation_batch_size=generation_batch_size,
            images=image_dict,
        )

        async with cls._lock:
            cls._jobs[job_id] = job

        # Start cleanup task if not running
        cls._ensure_cleanup_task()

        logger.info(
            "Created batch job",
            extra={
                "job_id": job_id,
                "user_id": user_id,
                "image_count": len(images),
            },
        )

        return job

    @classmethod
    async def get_job(cls, job_id: str, user_id: str) -> Optional[BatchJob]:
        """Get a job by ID, validating user ownership."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job and job.user_id == user_id:
                return job
            return None

    @classmethod
    async def cancel_job(cls, job_id: str, user_id: str) -> bool:
        """Cancel a running job."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if not job or job.user_id != user_id:
                return False

            if job.status in (BatchJobStatus.COMPLETED, BatchJobStatus.CANCELLED, BatchJobStatus.FAILED):
                return False

            job.cancelled = True
            job.cancel_event.set()
            job.status = BatchJobStatus.CANCELLED

        # Broadcast cancellation
        await cls.broadcast_event(job_id, "job_cancelled", {
            "job_id": job_id,
            "timestamp": datetime.utcnow().isoformat(),
        })

        logger.info("Cancelled batch job", extra={"job_id": job_id})
        return True

    @classmethod
    async def update_status(cls, job_id: str, status: BatchJobStatus) -> None:
        """Update job status."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job:
                job.status = status

    @classmethod
    async def add_detected_items(cls, job_id: str, image_id: str, items: List[Dict[str, Any]]) -> None:
        """Add detected items from an image."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job:
                for item in items:
                    item_data = DetectedItemData(
                        temp_id=item.get("temp_id", str(uuid4())),
                        image_id=image_id,
                        category=item.get("category", "other"),
                        sub_category=item.get("sub_category"),
                        colors=item.get("colors", []),
                        material=item.get("material"),
                        pattern=item.get("pattern"),
                        brand=item.get("brand"),
                        confidence=item.get("confidence", 0.5),
                        bounding_box=item.get("bounding_box"),
                        detailed_description=item.get("detailed_description"),
                        status="detected",
                    )
                    job.detected_items.append(item_data)
                job.extraction_completed.add(image_id)

    @classmethod
    async def mark_extraction_failed(cls, job_id: str, image_id: str, error: str) -> None:
        """Mark an image extraction as failed."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job:
                job.extraction_failed[image_id] = error

    @classmethod
    async def update_item_generation(
        cls,
        job_id: str,
        temp_id: str,
        generated_image_base64: Optional[str] = None,
        generated_image_url: Optional[str] = None,
        error: Optional[str] = None,
    ) -> None:
        """Update item with generation result."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job:
                for item in job.detected_items:
                    if item.temp_id == temp_id:
                        if error:
                            item.status = "failed"
                            item.generation_error = error
                            job.generation_failed[temp_id] = error
                        else:
                            item.status = "generated"
                            item.generated_image_base64 = generated_image_base64
                            item.generated_image_url = generated_image_url
                            job.generation_completed.add(temp_id)
                        break

    @classmethod
    async def set_error(cls, job_id: str, error: str) -> None:
        """Set job error and mark as failed."""
        async with cls._lock:
            job = cls._jobs.get(job_id)
            if job:
                job.error_message = error
                job.status = BatchJobStatus.FAILED

    @classmethod
    async def broadcast_event(cls, job_id: str, event_type: str, data: Dict[str, Any]) -> None:
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
                "job_id": job.job_id,
                "status": job.status.value,
                "total_images": job.total_images,
                "extractions_completed": len(job.extraction_completed),
                "extractions_failed": len(job.extraction_failed),
                "total_items": job.total_items,
                "generations_completed": len(job.generation_completed),
                "generations_failed": len(job.generation_failed),
                "items": [item.to_dict() for item in job.detected_items],
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
            logger.info(f"Cleaned up {len(expired_ids)} expired batch jobs")
