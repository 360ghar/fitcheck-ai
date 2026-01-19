"""
API routes for AI Photoshoot Generator feature.

Provides endpoints for:
- Generating photoshoots for authenticated users (async with SSE or sync)
- Demo photoshoot for anonymous users (landing page trial)
- Usage statistics
- Available use cases
- SSE streaming for real-time progress
- Job cancellation and status polling
"""

import asyncio
import json
import logging
import uuid
from datetime import datetime
from typing import Any, Dict

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sse_starlette.sse import EventSourceResponse
from supabase import Client

from app.api.v1.deps import get_current_user, get_db
from app.core.exceptions import AIServiceError, FitCheckException, RateLimitError, ValidationError
from app.core.ip_rate_limit import ip_rate_limited_operation
from app.models.photoshoot import (
    StartPhotoshootRequest,
    DemoPhotoshootRequest,
    PhotoshootResultResponse,
    DemoPhotoshootResponse,
    PhotoshootUsage,
    UseCasesResponse,
    PhotoshootUseCase,
    PhotoshootStatus,
    PhotoshootJobStatus,
    PhotoshootJobResponse,
    PhotoshootJobStatusResponse,
)
from app.services.photoshoot_service import PhotoshootService, PhotoshootStreamingService
from app.services.photoshoot_job_service import PhotoshootJobService

logger = logging.getLogger(__name__)

router = APIRouter()


# =============================================================================
# Public Endpoints
# =============================================================================


@router.get("/use-cases", response_model=Dict[str, Any], status_code=status.HTTP_200_OK)
async def get_use_cases():
    """
    Get all available photoshoot use cases.

    Returns list of use cases with names, descriptions, and example prompts.
    No authentication required.
    """
    use_cases = PhotoshootService.get_use_cases()
    return {
        "data": UseCasesResponse(use_cases=use_cases).model_dump(mode="json"),
        "message": "OK",
    }


@router.post("/demo", response_model=Dict[str, Any], status_code=status.HTTP_200_OK)
async def demo_photoshoot(
    request: Request,
    body: DemoPhotoshootRequest,
):
    """
    Generate a demo photoshoot for anonymous users.

    Rate limited to 1 demo per IP per day (generates 2 images).
    Used for landing page trial experience.
    Custom prompts are not allowed in demo mode.
    """
    # Validate no custom use case in demo
    if body.use_case == PhotoshootUseCase.CUSTOM:
        body.use_case = PhotoshootUseCase.AESTHETIC

    try:
        async with ip_rate_limited_operation(request, "photoshoot") as rate_check:
            # Generate prompts for 2 images
            prompts = await PhotoshootService.generate_prompts(
                use_case=body.use_case,
                num_prompts=2,
                reference_photo=body.photo,
            )

            # Generate images
            images = await PhotoshootService.generate_images(
                reference_photos=[body.photo],
                prompts=prompts,
            )

            session_id = f"demo_{uuid.uuid4().hex[:8]}"

            response = DemoPhotoshootResponse(
                session_id=session_id,
                status=PhotoshootStatus.COMPLETE,
                images=images,
                remaining_today=max(0, rate_check["remaining"] - 1),
                signup_cta="Sign up for 10 free images per day!",
            )

            return {"data": response.model_dump(mode="json"), "message": "OK"}
    except FitCheckException:
        raise
    except Exception as e:
        logger.exception(f"Demo photoshoot failed: {e}")
        raise AIServiceError(f"Failed to generate demo photoshoot: {str(e)}")


# =============================================================================
# Authenticated Endpoints
# =============================================================================


@router.post("/generate", response_model=Dict[str, Any], status_code=status.HTTP_202_ACCEPTED)
async def generate_photoshoot(
    body: StartPhotoshootRequest,
    sync: bool = Query(default=False, description="If true, wait for completion (sync mode)"),
    db: Client = Depends(get_db),
    user = Depends(get_current_user),
):
    """
    Start a photoshoot generation job.

    By default (sync=False), returns job_id immediately and processes in background.
    Connect to /{job_id}/events for real-time SSE progress updates.

    With sync=True, waits for completion and returns all images (legacy behavior).

    - Upload 1-4 reference photos
    - Select a use case or provide custom prompt
    - Choose number of images (1-10, default 10)
    - Optional batch_size for SSE progress granularity
    - Optional aspect_ratio (1:1, 9:16, 16:9, 3:4, 4:3)

    Daily limits:
    - Free: 10 images/day
    - Pro: 50 images/day
    """
    user_id = user["id"]

    # Validate custom prompt requirement
    if body.use_case == PhotoshootUseCase.CUSTOM and not body.custom_prompt:
        raise ValidationError("Custom prompt is required when use case is 'custom'")

    if sync:
        # Synchronous mode - wait for completion (React frontend compatibility)
        result = await PhotoshootService.generate_photoshoot(
            user_id=user_id,
            photos=body.photos,
            use_case=body.use_case,
            num_images=body.num_images,
            db=db,
            custom_prompt=body.custom_prompt,
        )
        return {"data": result.model_dump(mode="json"), "message": "OK"}

    # Async mode - return job_id immediately (Flutter app)
    # Check rate limit before creating job
    allowed, usage = await PhotoshootService.check_daily_limit(user_id, body.num_images, db)
    if not allowed:
        raise RateLimitError(
            message=f"Daily limit exceeded. You have {usage.remaining} images remaining today.",
            retry_after=86400,
        )

    # Create job
    job = await PhotoshootJobService.create_job(
        user_id=user_id,
        photos=body.photos,
        use_case=body.use_case.value,
        num_images=body.num_images,
        batch_size=body.batch_size,
        aspect_ratio=body.aspect_ratio,
        custom_prompt=body.custom_prompt,
    )

    # Start processing in background
    service = PhotoshootStreamingService(user_id=user_id, db=db)
    asyncio.create_task(service.run_pipeline(job))

    logger.info("Started photoshoot job", extra={
        "job_id": job.job_id,
        "user_id": user_id,
        "num_images": body.num_images,
    })

    response = PhotoshootJobResponse(
        job_id=job.job_id,
        status=job.status.value,
        message=f"Photoshoot generation started for {body.num_images} images",
    )

    return {"data": response.model_dump(mode="json"), "message": "OK"}


@router.get("/usage", response_model=Dict[str, Any], status_code=status.HTTP_200_OK)
async def get_usage(
    db: Client = Depends(get_db),
    user = Depends(get_current_user),
):
    """
    Get the current user's photoshoot usage for today.

    Returns:
    - used_today: Images generated today
    - limit_today: Daily limit based on plan
    - remaining: Images remaining today
    - plan_type: Current subscription plan
    - resets_at: When the daily limit resets (midnight UTC)
    """
    user_id = user["id"]
    usage = await PhotoshootService.get_usage(user_id, db)
    return {"data": usage.model_dump(mode="json"), "message": "OK"}


# =============================================================================
# SSE and Job Management Endpoints
# =============================================================================


@router.get("/{job_id}/events")
async def photoshoot_job_events(
    job_id: str,
    user = Depends(get_current_user),
):
    """
    SSE endpoint for real-time photoshoot job progress.

    Connect to this endpoint after calling /generate to receive real-time updates
    as images are generated.

    Event types:
    - connected: Initial connection established
    - heartbeat: Keep-alive (every 30s)
    - generation_started: Job started, includes total_batches
    - batch_started: Batch started, includes batch_index
    - image_complete: Single image generated, includes image data
    - image_failed: Single image failed, includes error
    - batch_complete: Batch finished
    - job_complete: All done, includes session_id and usage
    - job_failed: Job failed, includes error
    - job_cancelled: Job was cancelled
    """
    user_id = user["id"]
    job = await PhotoshootJobService.get_job(job_id, user_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    async def event_generator():
        queue: asyncio.Queue = asyncio.Queue()

        # Add subscriber and get replay index to avoid duplicate events
        success, replay_up_to = await PhotoshootJobService.add_subscriber(job_id, queue)
        if not success:
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
                    "total_images": job.num_images,
                    "timestamp": datetime.utcnow().isoformat(),
                }),
            }

            # If job already completed, send final status
            if job.status in (PhotoshootJobStatus.COMPLETE, PhotoshootJobStatus.FAILED, PhotoshootJobStatus.CANCELLED):
                status_data = await PhotoshootJobService.get_job_status(job_id)
                if status_data:
                    event_map = {
                        PhotoshootJobStatus.COMPLETE: "job_complete",
                        PhotoshootJobStatus.FAILED: "job_failed",
                        PhotoshootJobStatus.CANCELLED: "job_cancelled",
                    }
                    yield {
                        "event": event_map.get(job.status, "job_complete"),
                        "data": json.dumps(status_data),
                    }
                return

            # Replay buffered events for late-connecting subscribers
            # This ensures no events are missed due to race condition between
            # job start and SSE connection
            # Only replay up to replay_up_to index to avoid duplicates with live queue
            event_history = await PhotoshootJobService.get_event_history(job_id, up_to_index=replay_up_to)
            for event in event_history:
                yield {
                    "event": event["type"],
                    "data": json.dumps(event["data"]),
                }

                # If we replayed a terminal event, we're done
                if event["type"] in ("job_complete", "job_failed", "job_cancelled"):
                    return

            # Stream live events from queue
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
            await PhotoshootJobService.remove_subscriber(job_id, queue)

    return EventSourceResponse(event_generator())


@router.post("/{job_id}/cancel", response_model=Dict[str, str])
async def cancel_photoshoot_job(
    job_id: str,
    user = Depends(get_current_user),
):
    """
    Cancel a running photoshoot job.

    Cancellation is best-effort - currently running image generations may complete.
    """
    user_id = user["id"]
    success = await PhotoshootJobService.cancel_job(job_id, user_id)
    if not success:
        raise HTTPException(
            status_code=404,
            detail="Job not found or already complete",
        )

    logger.info("Cancelled photoshoot job", extra={"job_id": job_id, "user_id": user_id})
    return {"message": "Job cancelled"}


@router.get("/{job_id}/status", response_model=Dict[str, Any])
async def get_photoshoot_job_status(
    job_id: str,
    user = Depends(get_current_user),
):
    """
    Get current status of a photoshoot job.

    Useful for reconnection scenarios or checking progress without SSE.
    Returns the same data format as SSE job_complete event.
    """
    user_id = user["id"]

    # Verify ownership
    job = await PhotoshootJobService.get_job(job_id, user_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    status_data = await PhotoshootJobService.get_job_status(job_id)
    if not status_data:
        raise HTTPException(status_code=404, detail="Job not found")

    return {"data": status_data, "message": "OK"}
