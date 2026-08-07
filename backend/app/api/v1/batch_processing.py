"""
Batch Processing API routes.

Provides endpoints for multi-image batch extraction with SSE progress updates.
Supports JSON (base64) for Flutter and multipart/form-data for web.
"""

import asyncio
import base64
import json
from app.utils.datetime_util import utcnow, utcnow_iso
from typing import Any, Dict, List, Optional
from uuid import uuid4

from fastapi import APIRouter, Depends, File, Form, Header, HTTPException, UploadFile, status
from pydantic import BaseModel, Field, field_validator
from sse_starlette.sse import EventSourceResponse
from supabase import Client

from app.core.config import settings
from app.core.exceptions import (
    FitCheckException,
    InvalidInputError,
    RateLimitError,
    UnsupportedMediaTypeError,
)
from app.core.logging_config import get_context_logger
from app.api.v1.deps import get_active_user_id
from app.core.uploads import MAX_UPLOAD_FILES, read_upload_capped
from app.db.connection import get_db
from app.models.subscription import OperationType
from app.services.ai_settings_service import AISettingsService
from app.services.batch_job_service import BatchJobService, BatchJobStatus
from app.services.batch_extraction_service import BatchExtractionService
from app.utils.sse_queue import SSE_QUEUE_MAXSIZE, STREAM_OVERFLOW, note_consumed
from app.utils.image_processing import (
    SUPPORTED_UPLOAD_MIME_TYPES,
    make_base64_image_validator,
    validate_image_bytes,
)
from app.utils.db import persistence_db as _persistence_db
from app.utils.tasks import spawn_background_task

logger = get_context_logger(__name__)

router = APIRouter()


# =============================================================================
# PYDANTIC MODELS
# =============================================================================


# Match photoshoot max (~10MB encoded) so one batch of 50 cannot OOM the process.
_MAX_BATCH_IMAGE_B64 = 10 * 1024 * 1024
# Raw multipart file cap. base64 encoding inflates ~4/3, so 7MB raw ≈ 9.3MB
# encoded — under the 10MB budget the JSON path enforces per image. Worst-case
# batch: 50 x 7MB raw ≈ 467MB base64, comparable to the JSON path's 500MB.
_MAX_BATCH_IMAGE_BYTES = 7 * 1024 * 1024
# Chunk size for capped multipart reads (reject before buffering past the cap).
_READ_CHUNK_BYTES = 1024 * 1024

# Strong references to in-flight pipeline tasks. The event loop only keeps weak
# references, so a discarded create_task() result can be GC'd mid-run and the
# job silently stalls. Same pattern as SocialImportPipelineService._tasks.
_pipeline_tasks: "set[asyncio.Task]" = set()

_TERMINAL_SSE_EVENTS = ("job_complete", "job_failed", "job_cancelled", STREAM_OVERFLOW)


def _spawn_pipeline(service: BatchExtractionService, job) -> None:
    """Kick off a pipeline task while holding a strong reference to it."""
    spawn_background_task(service.run_pipeline(job), _pipeline_tasks)


async def _release_usage_best_effort(
    user_id: str,
    operation_type: Any,
    db: Any,
    count: int,
) -> None:
    """Compensate one reservation without masking the original admission error.

    Releasing quota is best-effort cleanup on a path that is already failing
    (a rejected multi-quota admission or a failed job creation). A release
    RPC failure must not replace the original exception, and it must not
    skip the sibling reservation's release.
    """
    try:
        await AISettingsService.release_usage(
            user_id=user_id,
            operation_type=operation_type,
            db=db,
            count=count,
        )
    except Exception as exc:
        logger.warning(
            "Failed to release AI usage reservation",
            user_id=user_id,
            operation_type=getattr(operation_type, "value", operation_type),
            error=str(exc),
        )


class BatchImageInput(BaseModel):
    """Single image for batch processing."""
    image_id: str = Field(..., description="Client-generated unique ID for tracking")
    image_base64: str = Field(
        ...,
        max_length=_MAX_BATCH_IMAGE_B64,
        description="Base64-encoded image data (max ~10MB encoded)",
    )

    validate_image_content = field_validator("image_base64")(
        make_base64_image_validator(_MAX_BATCH_IMAGE_BYTES)
    )
    filename: Optional[str] = Field(None, description="Original filename")


class BatchExtractionRequest(BaseModel):
    """Request to start batch extraction (JSON / Flutter)."""
    images: List[BatchImageInput] = Field(
        ...,
        min_length=1,
        max_length=MAX_UPLOAD_FILES,
        description="List of images to process (max 50)",
    )
    auto_generate: bool = Field(
        True,
        description="Automatically start generation after extraction",
    )
    generation_batch_size: int = Field(
        min(settings.AI_GENERATION_CONCURRENCY, 50),
        ge=1,
        le=min(settings.AI_GENERATION_CONCURRENCY, 50),
        description=(
            "Max concurrent product-image generations for this job "
            f"(1-{min(settings.AI_GENERATION_CONCURRENCY, 50)}). The process-wide "
            "GENERATION_SEMAPHORE (same cap) is the hard ceiling regardless. "
            "Capped at 50 to match the DB CHECK valid_batch_size."
        ),
    )


class SingleExtractionRequest(BaseModel):
    """Request to start single-item extraction."""
    image: str = Field(
        ...,
        max_length=_MAX_BATCH_IMAGE_B64,
        description="Base64-encoded image (max ~10MB encoded)",
    )

    validate_image_content = field_validator("image")(
        make_base64_image_validator(_MAX_BATCH_IMAGE_BYTES)
    )
    auto_generate: bool = Field(
        True,
        description="Auto-generate product images",
    )
    skip_cache: bool = Field(
        False,
        description="Skip cache lookup (force fresh extraction)",
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
# SHARED START HELPER
# =============================================================================


async def _check_batch_rate_limits(
    *,
    user_id: str,
    db: Client,
    total_images: int,
    auto_generate: bool,
) -> Dict[str, int]:
    """Atomically reserve this batch's daily AI quota before buffering work."""
    reservations: Dict[str, int] = {"extraction": total_images}

    if not auto_generate:
        extraction_reserved = await AISettingsService.reserve_usage(
            user_id=user_id,
            operation_type=OperationType.EXTRACTION,
            db=db,
            count=total_images,
        )
        if not extraction_reserved:
            raise RateLimitError(
                f"Daily extraction limit would be exceeded for {total_images} images."
            )
        return reservations

    # Extraction and generation reservations are independent RPCs; run them
    # concurrently and compensate any reservation that won the race when the
    # other one fails, so a rejected batch never leaks quota.
    estimated_generations = total_images * 3
    extraction_res, generation_res = await asyncio.gather(
        AISettingsService.reserve_usage(
            user_id=user_id,
            operation_type=OperationType.EXTRACTION,
            db=db,
            count=total_images,
        ),
        AISettingsService.reserve_usage(
            user_id=user_id,
            operation_type=OperationType.GENERATION,
            db=db,
            count=estimated_generations,
        ),
        return_exceptions=True,
    )

    extraction_ok = extraction_res is True
    generation_ok = generation_res is True

    if not extraction_ok or not generation_ok:
        # Compensation is best-effort and concurrent; a failing release must
        # not mask the original error or skip the sibling reservation.
        release_tasks = []
        if extraction_ok:
            release_tasks.append(
                _release_usage_best_effort(
                    user_id=user_id,
                    operation_type=OperationType.EXTRACTION,
                    db=db,
                    count=total_images,
                )
            )
        if generation_ok:
            release_tasks.append(
                _release_usage_best_effort(
                    user_id=user_id,
                    operation_type=OperationType.GENERATION,
                    db=db,
                    count=estimated_generations,
                )
            )
        if release_tasks:
            await asyncio.gather(*release_tasks)
        if isinstance(extraction_res, BaseException):
            raise extraction_res
        if not extraction_ok:
            raise RateLimitError(
                f"Daily extraction limit would be exceeded for {total_images} images."
            )
        if isinstance(generation_res, BaseException):
            raise generation_res
        # Developer hint stays in the logs; the client only ever sees the
        # user-facing copy (the old message leaked implementation detail
        # - "auto_generate" - into the API response; observed 2026-08-03).
        logger.warning(
            "Batch rejected: daily generation limit would be exceeded",
            user_id=user_id,
            estimated_generations=estimated_generations,
            total_images=total_images,
            hint="Consider disabling auto_generate",
        )
        raise RateLimitError(
            "This batch needs more AI generations than you have left today. "
            "Upload fewer photos or try again tomorrow."
        )

    reservations["generation"] = estimated_generations
    return reservations


async def _start_batch_job(
    *,
    user_id: str,
    db: Client,
    images_data: List[Dict[str, Any]],
    auto_generate: bool,
    generation_batch_size: int,
    reservations: Optional[Dict[str, int]] = None,
) -> BatchJobResponse:
    """Rate-limit, create job, kick off pipeline, return 202 payload.

    ``reservations`` carries quota already reserved by the caller (the
    multipart route reserves before buffering uploads so over-quota requests
    fail fast). When omitted, the reservation is made here so JSON callers
    keep the single-reservation contract.
    """
    # Production uses the hosted Supabase client. Keeping the guard here also
    # preserves direct-call tests and non-HTTP callers that use a sentinel DB
    # object; those paths remain explicitly in-memory rather than failing
    # while trying to persist through an invalid client.
    persistence_db = _persistence_db(db)
    total_images = len(images_data)
    if total_images < 1:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="At least one image is required",
        )
    if total_images > MAX_UPLOAD_FILES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Maximum {MAX_UPLOAD_FILES} images per batch",
        )

    if reservations is None:
        reservations = await _check_batch_rate_limits(
            user_id=user_id,
            db=db,
            total_images=total_images,
            auto_generate=auto_generate,
        ) or {}

    try:
        job = await BatchJobService.create_job(
            user_id=user_id,
            images=images_data,
            auto_generate=auto_generate,
            generation_batch_size=generation_batch_size,
            db=persistence_db,
        )
    except Exception:
        # Admission succeeded but job creation did not. Return the reserved
        # daily capacity before surfacing the failure to the caller.
        if reservations:  # pragma: no cover - admission always reserves before this
            await asyncio.gather(*[
                _release_usage_best_effort(
                    user_id=user_id,
                    operation_type=operation_type,
                    db=db,
                    count=count,
                )
                for operation_type, count in reservations.items()
            ])
        raise

    service = BatchExtractionService(user_id=user_id, db=db)
    _spawn_pipeline(service, job)

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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """
    Start a batch extraction job (JSON body with base64 images).

    Prefer multipart ``POST /batch-extract-multipart`` from web clients for
    smaller uploads. Extraction runs in parallel; product-image generation
    starts as soon as each image's items are detected (overlapped).
    """
    try:
        images_data = [img.model_dump() for img in request.images]
        return await _start_batch_job(
            user_id=user_id,
            db=db,
            images_data=images_data,
            auto_generate=request.auto_generate,
            generation_batch_size=request.generation_batch_size,
        )
    except FitCheckException:
        raise
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to start batch extraction", extra={"error": str(e)})
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to start batch extraction",
        )


@router.post(
    "/batch-extract-multipart",
    response_model=BatchJobResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
async def start_batch_extraction_multipart(
    files: List[UploadFile] = File(..., description="Image files (1–50)"),
    image_ids: Optional[str] = Form(
        None,
        description="Optional JSON array of client image IDs, parallel to files",
    ),
    auto_generate: bool = Form(True),
    generation_batch_size: int = Form(
        min(settings.AI_GENERATION_CONCURRENCY, 50),
        ge=1,
        le=min(settings.AI_GENERATION_CONCURRENCY, 50),
    ),
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """
    Start batch extraction via multipart file upload (preferred for web).

    Smaller on the wire than base64 JSON. Same SSE progress contract as
    ``POST /batch-extract``.
    """
    try:
        if not files:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="At least one file is required",
            )
        if len(files) > MAX_UPLOAD_FILES:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Maximum {MAX_UPLOAD_FILES} images per batch",
            )

        ids: List[str] = []
        if image_ids:
            try:
                parsed = json.loads(image_ids)
            except json.JSONDecodeError:
                # Comma-separated fallback for non-JSON clients
                ids = [s.strip() for s in image_ids.split(",") if s.strip()]
            else:
                if not isinstance(parsed, list):
                    raise InvalidInputError(
                        field="image_ids",
                        message="image_ids must be a JSON array of strings",
                    )
                ids = [str(x) for x in parsed]
            if len(ids) != len(files):
                raise InvalidInputError(
                    field="image_ids",
                    message=(
                        f"image_ids length ({len(ids)}) must match "
                        f"file count ({len(files)})"
                    ),
                )
            if len(set(ids)) != len(ids):
                raise InvalidInputError(
                    field="image_ids",
                    message="image_ids must be unique per file",
                )

        # Reject rate-limited / over-quota requests BEFORE buffering payloads.
        reservations = await _check_batch_rate_limits(
            user_id=user_id,
            db=db,
            total_images=len(files),
            auto_generate=auto_generate,
        )

        images_data: List[Dict[str, Any]] = []
        try:
            for index, upload in enumerate(files):
                content_type = (upload.content_type or "").lower()
                if not content_type.startswith("image/"):
                    raise UnsupportedMediaTypeError(
                        message=(
                            f"Unsupported content type at index {index}: "
                            f"{content_type or '(missing)'}"
                        )
                    )
                content = await read_upload_capped(upload, _MAX_BATCH_IMAGE_BYTES)
                if not content:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Empty file at index {index}",
                    )
                try:
                    validate_image_bytes(content, max_bytes=_MAX_BATCH_IMAGE_BYTES)
                except ValueError as error:
                    raise UnsupportedMediaTypeError(
                        allowed_types=sorted(SUPPORTED_UPLOAD_MIME_TYPES),
                        message=f"Invalid image at index {index}: {error}",
                    ) from error

                image_id = ids[index] if ids else f"img-{uuid4().hex[:12]}"
                images_data.append(
                    {
                        "image_id": image_id,
                        "image_base64": base64.b64encode(content).decode("utf-8"),
                        "filename": upload.filename,
                    }
                )
        except Exception:
            # Validation/buffering failed after the pre-buffer reservation, so
            # no job will consume it. Release now to avoid leaking quota.
            await asyncio.gather(*[
                _release_usage_best_effort(
                    user_id=user_id,
                    operation_type=operation_type,
                    db=db,
                    count=count,
                )
                for operation_type, count in reservations.items()
            ])
            raise

        return await _start_batch_job(
            user_id=user_id,
            db=db,
            images_data=images_data,
            auto_generate=auto_generate,
            generation_batch_size=generation_batch_size,
            reservations=reservations,
        )
    except FitCheckException:
        raise
    except HTTPException:
        raise
    except Exception as e:
        logger.error(
            "Failed to start multipart batch extraction",
            extra={"error": str(e)},
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to start batch extraction",
        )


@router.get("/batch-extract/{job_id}/events")
async def batch_job_events(
    job_id: str,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
    last_event_id: Optional[str] = Header(default=None, alias="Last-Event-ID"),
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
    - generation_started: First generation batch started (overlaps extraction;
      total_items is only a partial count until all_extractions_complete)
    - item_generation_complete: Single item image generated (total_items grows
      as later images finish extracting)
    - item_generation_failed: Single item generation failed
    - all_generations_complete: All items generated
    - job_complete: Full pipeline complete
    - job_failed: Pipeline failed
    - job_cancelled: User cancelled job
    """
    persistence_db = _persistence_db(db)
    try:
        replay_after = max(0, int(last_event_id or 0))
    except (TypeError, ValueError):
        replay_after = 0
    job = await BatchJobService.get_job(job_id, user_id, db=persistence_db)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    async def event_generator():
        queue: asyncio.Queue = asyncio.Queue(maxsize=SSE_QUEUE_MAXSIZE)

        # Add subscriber
        if not await BatchJobService.add_subscriber(job_id, queue, replay_after):
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
                    "timestamp": utcnow_iso(),
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

            if job.recovered_from_persistence:
                status_data = await BatchJobService.get_job_status(job_id)
                if status_data:  # pragma: no cover - job row exists if recovered
                    # Recovered jobs are pollable but never resumed by a
                    # worker, so a client-unsupported `job_recovered` event
                    # would leave clients polling an unchanged snapshot.
                    # Emit the terminal event clients understand.
                    status_data["error"] = (
                        "This job was interrupted by a server restart and cannot resume. "
                        "Please start a new batch."
                    )
                    yield {
                        "event": "job_failed",
                        "data": json.dumps(status_data),
                    }
                return

            # Stream events from queue (items are (event, size) tuples;
            # report consumption so the byte budget tracks only buffered data)
            while True:
                try:
                    event, event_size = await asyncio.wait_for(queue.get(), timeout=30)
                    note_consumed(queue, event_size)
                    payload = {
                        "event": event["type"],
                        "data": json.dumps(event["data"]),
                    }
                    # Preserve the monotonic ID so browsers send it back as
                    # Last-Event-ID if the stream reconnects.
                    if event.get("id") is not None:
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
                "Unexpected error in batch SSE generator",
                extra={"job_id": job_id},
            )
            yield {
                "event": "job_failed",
                "data": json.dumps({
                    "error": "Internal error while streaming batch events",
                    "timestamp": utcnow_iso(),
                }),
            }
        finally:
            await BatchJobService.remove_subscriber(job_id, queue)

    return EventSourceResponse(
        event_generator(),
        headers={
            "X-Accel-Buffering": "no",
            "Cache-Control": "no-cache, no-transform",
        },
        ping=15,  # SSE comment keep-alive; keeps HTTP/2 streams alive through proxies
    )


@router.post(
    "/batch-extract/{job_id}/cancel",
    response_model=Dict[str, str],
)
async def cancel_batch_job(
    job_id: str,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """
    Cancel a running batch job.

    Cancellation is best-effort - currently running operations may complete.
    """
    persistence_db = _persistence_db(db)
    success = await BatchJobService.cancel_job(job_id, user_id, db=persistence_db)
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """
    Get current status of a batch job.

    Useful for reconnection scenarios or checking progress without SSE.
    """
    persistence_db = _persistence_db(db)
    job = await BatchJobService.get_job(job_id, user_id, db=persistence_db)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    status_data = await BatchJobService.get_job_status(job_id)
    if not status_data:
        raise HTTPException(status_code=404, detail="Job not found")

    return BatchJobStatusResponse(**status_data)


@router.post(
    "/single-extract",
    response_model=BatchJobResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
async def start_single_extraction(
    request: SingleExtractionRequest,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """
    Start a single-item extraction job with async processing.

    Uses the same infrastructure as batch processing but optimized for single images.
    Returns a job_id and SSE URL for real-time progress updates.

    Includes intelligent caching - if the same image was extracted within the last 24 hours,
    returns cached results immediately (indicated by 'cached: true' in response).

    This provides feature parity with batch extraction - users get real-time updates
    via SSE as items are detected and product images are generated.
    """
    try:
        from app.services.extraction_cache_service import ExtractionCacheService

        # Check cache first (unless skip_cache is True)
        if not request.skip_cache:
            cached_result = await ExtractionCacheService.get_cached_result(
                image_base64=request.image,
                user_id=user_id,
            )

            if cached_result:
                # Cache hit! Create a completed job with cached results
                image_data = {
                    "image_id": f"cached_{utcnow().timestamp()}",
                    "image_base64": request.image,
                    "filename": "uploaded_image.jpg",
                }

                job = await BatchJobService.create_job(
                    user_id=user_id,
                    images=[image_data],
                    auto_generate=request.auto_generate,
                    generation_batch_size=1,
                    db=_persistence_db(db),
                )

                # Hydrate cached items into the in-memory job and mark it complete
                cached_items = cached_result.get("items", [])
                if isinstance(cached_items, list):
                    await BatchJobService.restore_cached_items(job.job_id, cached_items)
                await BatchJobService.update_status(job.job_id, BatchJobStatus.COMPLETED)

                logger.info(
                    "Cache hit - returning cached extraction",
                    extra={"job_id": job.job_id, "user_id": user_id, "item_count": len(cached_items) if isinstance(cached_items, list) else 0},
                )

                return BatchJobResponse(
                    job_id=job.job_id,
                    status=BatchJobStatus.COMPLETED.value,
                    total_images=1,
                    sse_url=f"/api/v1/ai/batch-extract/{job.job_id}/events",
                    message="Items detected (cached)",
                )

        # Cache miss or skip_cache - proceed with normal extraction
        # Reserve admission through the same atomic path as multi-image jobs.
        # The cache-hit path above does not call a provider and intentionally
        # does not consume quota.
        reservations = await _check_batch_rate_limits(
            user_id=user_id,
            db=db,
            total_images=1,
            auto_generate=request.auto_generate,
        )

        # Create single-image batch job (reuse batch infrastructure)
        image_data = {
            "image_id": f"single_{utcnow().timestamp()}",
            "image_base64": request.image,
            "filename": "uploaded_image.jpg",
        }

        try:
            job = await BatchJobService.create_job(
                user_id=user_id,
                images=[image_data],
                auto_generate=request.auto_generate,
                # Generate one photo's items concurrently rather than one-at-a-time.
                # The process-wide GENERATION_SEMAPHORE (AI_GENERATION_CONCURRENCY,
                # default 30) is the real ceiling; this only tightens below it.
                generation_batch_size=settings.AI_GENERATION_CONCURRENCY,
                db=_persistence_db(db),
            )
        except Exception:
            if reservations:  # pragma: no cover - admission always reserves before this
                await asyncio.gather(*[
                    _release_usage_best_effort(
                        user_id=user_id,
                        operation_type=operation_type,
                        db=db,
                        count=count,
                    )
                    for operation_type, count in reservations.items()
                ])
            raise

        # Start processing in background
        from app.services.batch_extraction_service import BatchExtractionService

        service = BatchExtractionService(user_id=user_id, db=db)
        _spawn_pipeline(service, job)

        logger.info(
            "Started single-item extraction",
            extra={"job_id": job.job_id, "user_id": user_id},
        )

        return BatchJobResponse(
            job_id=job.job_id,
            status=job.status.value,
            total_images=1,
            sse_url=f"/api/v1/ai/batch-extract/{job.job_id}/events",
            message="Single-item extraction started",
        )

    except RateLimitError:
        raise
    except FitCheckException:
        raise
    except Exception as e:
        logger.error("Failed to start single extraction", extra={"error": str(e)})
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to start extraction",
        )
