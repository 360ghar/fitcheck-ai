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
import hashlib
import json
from app.utils.datetime_util import utcnow_iso
from typing import Any, Dict

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from fastapi.responses import JSONResponse
from sse_starlette.sse import EventSourceResponse
from supabase import Client

from app.api.v1.deps import get_current_user, get_db
from app.core.exceptions import AIServiceError, FitCheckException, RateLimitError, ServiceError, ValidationError
from app.core.ip_rate_limit import get_client_ip, ip_rate_limited_operation
from app.core.logging_config import get_context_logger
from app.models.photoshoot import (
    StartPhotoshootRequest,
    DemoPhotoshootRequest,
    UseCasesResponse,
    PhotoshootUseCase,
    PhotoshootJobStatus,
    PhotoshootJobResponse,
)
from app.services.photoshoot_service import PhotoshootService, PhotoshootStreamingService
from app.services.photoshoot_job_service import PhotoshootJobService
from app.utils.sse_queue import SSE_QUEUE_MAXSIZE, STREAM_OVERFLOW, note_consumed
from app.utils.db import persistence_db as _persistence_db
from app.utils.tasks import spawn_background_task

logger = get_context_logger(__name__)

router = APIRouter()

# Strong references to in-flight pipeline tasks. The event loop only keeps weak
# references, so a discarded create_task() result can be GC'd mid-run: the job
# then sits in PROCESSING until the 30-minute TTL evicts it, /status starts
# 404ing, and the user's daily quota was already spent. Same pattern as
# batch_processing._pipeline_tasks and SocialImportPipelineService._tasks.
_pipeline_tasks: "set[asyncio.Task]" = set()

_TERMINAL_SSE_EVENTS = ("job_complete", "job_failed", "job_cancelled", STREAM_OVERFLOW)


def _spawn_pipeline(service: PhotoshootStreamingService, job) -> None:
    """Kick off a pipeline task while holding a strong reference to it."""
    spawn_background_task(service.run_pipeline(job), _pipeline_tasks)


def _client_ip(request: Request) -> str:
    """Client IP for demo job ownership.

    Delegates to app.core.ip_rate_limit.get_client_ip (request.client.host,
    resolved by uvicorn's ProxyHeadersMiddleware) so the demo pseudo-user is
    derived from the SAME value the demo rate limiter keys on. Deliberately
    NOT hand-parsing X-Forwarded-For here: that header is client-supplied and
    spoofable, so parsing it would let a caller mint a fresh pseudo-user per
    request and bypass the per-IP demo limit (see get_client_ip's docstring).
    """
    return get_client_ip(request)


def _demo_user_id(request: Request) -> str:
    """Stable pseudo-user id for a demo client, derived from their IP.

    Demo jobs are stored in the shared photoshoot_jobs table; the pseudo-user
    keeps them out of any real user's rows and lets the status endpoint
    authorize by re-deriving the same id from the request IP. IPs are hashed
    so raw client IPs never land in the DB.
    """
    return f"demo_{hashlib.sha256(_client_ip(request).encode('utf-8')).hexdigest()[:24]}"


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


@router.post("/demo", response_model=Dict[str, Any], status_code=status.HTTP_202_ACCEPTED)
async def demo_photoshoot(
    request: Request,
    body: DemoPhotoshootRequest,
):
    """
    Start a demo photoshoot for anonymous users (job-based, polling status).

    Rate limited to 1 demo per IP per day (generates 2 images).
    Used for landing page trial experience.
    Custom prompts are not allowed in demo mode.

    Returns a job_id immediately; poll GET /demo/{job_id}/status for progress
    and results. Demo jobs skip daily-quota reservation (the IP rate limit is
    enforced here at creation time).
    """
    # Validate no custom use case in demo
    if body.use_case == PhotoshootUseCase.CUSTOM:
        body.use_case = PhotoshootUseCase.AESTHETIC

    try:
        async with ip_rate_limited_operation(request, "photoshoot") as rate_check:
            demo_user_id = _demo_user_id(request)
            job = await PhotoshootJobService.create_job(
                user_id=demo_user_id,
                photos=[body.photo],
                use_case=body.use_case.value,
                num_images=2,
                batch_size=2,
                aspect_ratio="1:1",
                db=_persistence_db(None),
            )

            # Start processing in background (demo pipeline skips quota)
            service = PhotoshootStreamingService(user_id=demo_user_id, db=None, is_demo=True)
            _spawn_pipeline(service, job)

            logger.info("Started demo photoshoot job", extra={
                "job_id": job.job_id,
                "demo": True,
                "remaining": rate_check["remaining"],
            })

            response = {
                "job_id": job.job_id,
                "status": job.status.value,
                "message": "Demo photoshoot generation started",
                "remaining_today": max(0, rate_check["remaining"] - 1),
                "signup_cta": "Sign up for 10 free images per day!",
            }
            return JSONResponse(
                status_code=status.HTTP_202_ACCEPTED,
                content={"data": response, "message": "OK"},
            )
    except FitCheckException:
        raise
    except Exception as e:
        logger.exception(f"Demo photoshoot failed: {e}")
        raise AIServiceError(f"Failed to start demo photoshoot: {str(e)}")


@router.get("/demo/{job_id}/status", response_model=Dict[str, Any], status_code=status.HTTP_200_OK)
async def demo_photoshoot_status(
    job_id: str,
    request: Request,
):
    """
    Poll status of a demo photoshoot job (no auth).

    Ownership is validated by re-deriving the demo pseudo-user from the
    request IP, so one visitor cannot read another visitor's demo job.
    """
    demo_user_id = _demo_user_id(request)
    job = await PhotoshootJobService.get_job(job_id, demo_user_id, db=None)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    status_data = await PhotoshootJobService.get_job_status(job_id)
    if not status_data:
        raise HTTPException(status_code=404, detail="Job not found")

    # Demo response shape: job status + images, no usage.
    status_data.pop("usage", None)
    return {"data": status_data, "message": "OK"}


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
        # Synchronous mode - wait for completion (React frontend compatibility).
        # Bound the wait below the upstream (Railway) proxy's ~300s request
        # deadline so a runaway batch returns a clean 503 instead of the
        # proxy's opaque 400. (RCA 2026-08-05: POST /photoshoot/generate 400 @ ~300s.)
        try:
            result = await asyncio.wait_for(
                PhotoshootService.generate_photoshoot(
                    user_id=user_id,
                    photos=body.photos,
                    use_case=body.use_case,
                    num_images=body.num_images,
                    db=db,
                    custom_prompt=body.custom_prompt,
                ),
                timeout=270,
            )
        except asyncio.TimeoutError:
            raise ServiceError(
                "Photoshoot generation is taking longer than expected. "
                "Please try again or use background mode.",
                service_name="photoshoot",
            )
        status_code = (
            status.HTTP_207_MULTI_STATUS
            if result.partial_success
            else status.HTTP_200_OK
        )
        return JSONResponse(
            status_code=status_code,
            content={"data": result.model_dump(mode="json"), "message": "OK"},
        )

    # Async mode - return job_id immediately (Flutter app)
    # Check rate limit before creating job
    allowed, usage = await PhotoshootService.check_daily_limit(user_id, body.num_images, db)
    if not allowed:
        raise RateLimitError(
            message=f"Daily limit exceeded. You have {usage.remaining} images remaining today.",
            retry_after=86400,
        )

    # Create job. The API dependency is a hosted Supabase Client in production;
    # direct-call tests may pass a sentinel object and should exercise the
    # documented in-memory compatibility path instead.
    persistence_db = _persistence_db(db)
    job = await PhotoshootJobService.create_job(
        user_id=user_id,
        photos=body.photos,
        use_case=body.use_case.value,
        num_images=body.num_images,
        batch_size=body.batch_size,
        aspect_ratio=body.aspect_ratio,
        custom_prompt=body.custom_prompt,
        db=persistence_db,
    )

    # Start processing in background
    service = PhotoshootStreamingService(user_id=user_id, db=db)
    _spawn_pipeline(service, job)

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
    db: Client = Depends(get_db),
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
    persistence_db = _persistence_db(db)
    job = await PhotoshootJobService.get_job(job_id, user_id, db=persistence_db)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    async def event_generator():
        queue: asyncio.Queue = asyncio.Queue(maxsize=SSE_QUEUE_MAXSIZE)

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
                    "timestamp": utcnow_iso(),
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

            if job.recovered_from_persistence:
                status_data = await PhotoshootJobService.get_job_status(job_id)
                if status_data:
                    yield {
                        "event": "job_recovered",
                        "data": json.dumps(status_data),
                    }
                return

            # Replay buffered events for late-connecting subscribers
            # This ensures no events are missed due to race condition between
            # job start and SSE connection
            # Only replay up to replay_up_to index to avoid duplicates with live queue
            event_history = await PhotoshootJobService.get_event_history(job_id, up_to_index=replay_up_to)
            for event in event_history:
                payload = {
                    "event": event["type"],
                    "data": json.dumps(event["data"]),
                }
                if event.get("id") is not None:  # pragma: no cover - events always carry ids
                    payload["id"] = str(event["id"])
                yield payload

                # If we replayed a terminal event, we're done
                if event["type"] in _TERMINAL_SSE_EVENTS:
                    return

            # Stream live events from queue (items are (event, size) tuples;
            # report consumption so the byte budget tracks only buffered data)
            while True:
                try:
                    event, event_size = await asyncio.wait_for(queue.get(), timeout=30)
                    note_consumed(queue, event_size)
                    payload = {
                        "event": event["type"],
                        "data": json.dumps(event["data"]),
                    }
                    if event.get("id") is not None:  # pragma: no cover - events always carry ids
                        payload["id"] = str(event["id"])
                    yield payload

                    # Check for terminal events
                    if event["type"] in _TERMINAL_SSE_EVENTS:
                        break

                except asyncio.TimeoutError:
                    # Send heartbeat
                    yield {
                        "event": "heartbeat",
                        "data": json.dumps({
                            "timestamp": utcnow_iso(),
                        }),
                    }

        except asyncio.CancelledError:
            # Client disconnected; no one left to receive a terminal event.
            pass
        except Exception:
            # Guarantee a terminal SSE event so clients never hang on a
            # silently-closed stream when an unexpected error occurs.
            logger.exception(
                "Unexpected error in photoshoot SSE generator",
                extra={"job_id": job_id},
            )
            yield {
                "event": "job_failed",
                "data": json.dumps({
                    "error": "Internal error while streaming photoshoot events",
                    "timestamp": utcnow_iso(),
                }),
            }
        finally:
            await PhotoshootJobService.remove_subscriber(job_id, queue)

    return EventSourceResponse(
        event_generator(),
        headers={
            "X-Accel-Buffering": "no",
            "Cache-Control": "no-cache, no-transform",
        },
        ping=15,  # SSE comment keep-alive; the app-level heartbeat is every 30s,
                  # longer than many proxy idle timeouts.
    )


@router.post("/{job_id}/cancel", response_model=Dict[str, str])
async def cancel_photoshoot_job(
    job_id: str,
    user = Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Cancel a running photoshoot job.

    Cancellation is best-effort - currently running image generations may complete.
    """
    user_id = user["id"]
    persistence_db = _persistence_db(db)
    success = await PhotoshootJobService.cancel_job(job_id, user_id, db=persistence_db)
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
    db: Client = Depends(get_db),
):
    """
    Get current status of a photoshoot job.

    Useful for reconnection scenarios or checking progress without SSE.
    Returns the same data format as SSE job_complete event.
    """
    user_id = user["id"]

    # Verify ownership
    persistence_db = _persistence_db(db)
    job = await PhotoshootJobService.get_job(job_id, user_id, db=persistence_db)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    status_data = await PhotoshootJobService.get_job_status(job_id)
    if not status_data:
        raise HTTPException(status_code=404, detail="Job not found")

    return {"data": status_data, "message": "OK"}
