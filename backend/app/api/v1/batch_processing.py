"""
Batch Processing API routes.

Provides endpoints for multi-image batch extraction with SSE progress updates.
"""

import asyncio
import json
from datetime import datetime
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sse_starlette.sse import EventSourceResponse
from supabase import Client

from app.core.config import settings
from app.core.exceptions import RateLimitError
from app.core.logging_config import get_context_logger
from app.core.security import get_current_user_id
from app.db.connection import get_db
from app.services.ai_settings_service import AISettingsService
from app.services.batch_job_service import BatchJobService, BatchJobStatus
from app.services.batch_extraction_service import BatchExtractionService

logger = get_context_logger(__name__)

router = APIRouter()


# =============================================================================
# PYDANTIC MODELS
# =============================================================================


class BatchImageInput(BaseModel):
    """Single image for batch processing."""
    image_id: str = Field(..., description="Client-generated unique ID for tracking")
    image_base64: str = Field(..., description="Base64-encoded image data")
    filename: Optional[str] = Field(None, description="Original filename")


class BatchExtractionRequest(BaseModel):
    """Request to start batch extraction."""
    images: List[BatchImageInput] = Field(
        ...,
        min_length=1,
        max_length=50,
        description="List of images to process (max 50)",
    )
    auto_generate: bool = Field(
        True,
        description="Automatically start generation after extraction",
    )
    generation_batch_size: int = Field(
        5,
        ge=1,
        le=5,
        description="Number of items to generate in parallel per batch (max 5)",
    )


class BatchJobResponse(BaseModel):
    """Response with job information."""
    job_id: str
    status: str
    total_images: int
    sse_url: str
    message: str


class BatchJobStatusResponse(BaseModel):
    """Full job status response."""
    job_id: str
    status: str
    total_images: int
    extractions_completed: int
    extractions_failed: int
    total_items: int
    generations_completed: int
    generations_failed: int
    items: List[Dict[str, Any]]
    error: Optional[str] = None


# =============================================================================
# ENDPOINTS
# =============================================================================


@router.post(
    "/batch-extract",
    response_model=BatchJobResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
async def start_batch_extraction(
    request: BatchExtractionRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Start a batch extraction job.

    Uploads multiple images for AI extraction and optional product image generation.
    Returns a job_id and SSE URL for real-time progress updates.

    The processing happens in two phases:
    1. Extraction: All images processed in parallel
    2. Generation: Items processed in batches of N (default 5)
    """
    try:
        total_images = len(request.images)

        # Check extraction rate limit
        extraction_check = await AISettingsService.check_rate_limit(
            user_id=user_id,
            operation_type="extraction",
            db=db,
            count=total_images,
        )
        if not extraction_check["allowed"]:
            raise RateLimitError(
                f"Daily extraction limit ({extraction_check['limit']}) would be exceeded. "
                f"You have {extraction_check['remaining']} remaining."
            )

        # Estimate generation operations (assume ~3 items per image on average)
        if request.auto_generate:
            estimated_generations = total_images * 3
            generation_check = await AISettingsService.check_rate_limit(
                user_id=user_id,
                operation_type="generation",
                db=db,
                count=estimated_generations,
            )
            if not generation_check["allowed"]:
                raise RateLimitError(
                    f"Daily generation limit ({generation_check['limit']}) may be exceeded. "
                    f"You have {generation_check['remaining']} remaining. "
                    f"Consider disabling auto_generate."
                )

        # Create job
        images_data = [img.model_dump() for img in request.images]
        job = await BatchJobService.create_job(
            user_id=user_id,
            images=images_data,
            auto_generate=request.auto_generate,
            generation_batch_size=request.generation_batch_size,
        )

        # Start processing in background
        service = BatchExtractionService(user_id=user_id, db=db)
        asyncio.create_task(service.run_pipeline(job))

        logger.info(
            "Started batch extraction",
            extra={
                "job_id": job.job_id,
                "user_id": user_id,
                "image_count": total_images,
            },
        )

        return BatchJobResponse(
            job_id=job.job_id,
            status=job.status.value,
            total_images=total_images,
            sse_url=f"/api/v1/ai/batch-extract/{job.job_id}/events",
            message=f"Batch extraction started for {total_images} images",
        )

    except RateLimitError:
        raise
    except Exception as e:
        logger.error("Failed to start batch extraction", extra={"error": str(e)})
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to start batch extraction: {str(e)}",
        )


@router.get("/batch-extract/{job_id}/events")
async def batch_job_events(
    job_id: str,
    user_id: str = Depends(get_current_user_id),
):
    """
    SSE endpoint for real-time batch job progress.

    Connect to this endpoint to receive real-time updates as images are processed.

    Event types:
    - connected: Initial connection established
    - heartbeat: Keep-alive (every 30s)
    - extraction_started: Extraction phase begins
    - image_extraction_complete: Single image processed
    - image_extraction_failed: Single image failed
    - all_extractions_complete: All images processed
    - generation_started: Generation phase begins
    - batch_generation_started: New batch starting
    - item_generation_complete: Single item image generated
    - item_generation_failed: Single item generation failed
    - batch_generation_complete: Batch complete
    - all_generations_complete: All items generated
    - job_complete: Full pipeline complete
    - job_failed: Pipeline failed
    - job_cancelled: User cancelled job
    """
    job = await BatchJobService.get_job(job_id, user_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    async def event_generator():
        queue: asyncio.Queue = asyncio.Queue()

        # Add subscriber
        if not await BatchJobService.add_subscriber(job_id, queue):
            yield {
                "event": "error",
                "data": json.dumps({"error": "Job not found"}),
            }
            return

        try:
            # Send connected event with current status
            yield {
                "event": "connected",
                "data": json.dumps({
                    "job_id": job_id,
                    "status": job.status.value,
                    "total_images": job.total_images,
                    "timestamp": datetime.utcnow().isoformat(),
                }),
            }

            # If job already completed, send final status
            if job.status in (BatchJobStatus.COMPLETED, BatchJobStatus.FAILED, BatchJobStatus.CANCELLED):
                status_data = await BatchJobService.get_job_status(job_id)
                if status_data:
                    status_event_map = {
                        BatchJobStatus.COMPLETED: "job_complete",
                        BatchJobStatus.FAILED: "job_failed",
                        BatchJobStatus.CANCELLED: "job_cancelled",
                    }
                    yield {
                        "event": status_event_map.get(job.status, f"job_{job.status.value}"),
                        "data": json.dumps(status_data),
                    }
                return

            # Stream events from queue
            while True:
                try:
                    event = await asyncio.wait_for(queue.get(), timeout=30)
                    yield {
                        "event": event["type"],
                        "data": json.dumps(event["data"]),
                    }

                    # Check for terminal events
                    if event["type"] in ("job_complete", "job_failed", "job_cancelled"):
                        break

                except asyncio.TimeoutError:
                    # Send heartbeat
                    yield {
                        "event": "heartbeat",
                        "data": json.dumps({
                            "timestamp": datetime.utcnow().isoformat(),
                        }),
                    }

        except asyncio.CancelledError:
            pass
        finally:
            await BatchJobService.remove_subscriber(job_id, queue)

    return EventSourceResponse(event_generator())


@router.post(
    "/batch-extract/{job_id}/cancel",
    response_model=Dict[str, str],
)
async def cancel_batch_job(
    job_id: str,
    user_id: str = Depends(get_current_user_id),
):
    """
    Cancel a running batch job.

    Cancellation is best-effort - currently running operations may complete.
    """
    success = await BatchJobService.cancel_job(job_id, user_id)
    if not success:
        raise HTTPException(
            status_code=404,
            detail="Job not found or already complete",
        )

    logger.info("Cancelled batch job", extra={"job_id": job_id, "user_id": user_id})
    return {"message": "Job cancelled"}


@router.get(
    "/batch-extract/{job_id}/status",
    response_model=BatchJobStatusResponse,
)
async def get_batch_job_status(
    job_id: str,
    user_id: str = Depends(get_current_user_id),
):
    """
    Get current status of a batch job.

    Useful for reconnection scenarios or checking progress without SSE.
    """
    status_data = await BatchJobService.get_job_status(job_id)

    if not status_data:
        raise HTTPException(status_code=404, detail="Job not found")

    # Verify user ownership
    job = await BatchJobService.get_job(job_id, user_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    return BatchJobStatusResponse(**status_data)
