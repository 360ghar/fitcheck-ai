"""
Batch Processing API routes.

Provides endpoints for multi-image batch extraction with SSE progress updates.
Supports JSON (base64) for Flutter and multipart/form-data for web.
"""

import asyncio
import base64
import json
from datetime import datetime
from typing import Any, Dict, List, Optional
from uuid import uuid4

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from pydantic import BaseModel, Field
from sse_starlette.sse import EventSourceResponse
from supabase import Client

from app.core.exceptions import (
    FileTooLargeError,
    FitCheckException,
    InvalidInputError,
    RateLimitError,
    UnsupportedMediaTypeError,
)
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


# Match photoshoot max (~10MB encoded) so one batch of 50 cannot OOM the process.
_MAX_BATCH_IMAGE_B64 = 10 * 1024 * 1024
# Raw multipart file cap. base64 encoding inflates ~4/3, so 7MB raw ≈ 9.3MB
# encoded — under the 10MB budget the JSON path enforces per image. Worst-case
# batch: 50 x 7MB raw ≈ 467MB base64, comparable to the JSON path's 500MB.
_MAX_BATCH_IMAGE_BYTES = 7 * 1024 * 1024
_MAX_BATCH_IMAGES = 50
# Chunk size for capped multipart reads (reject before buffering past the cap).
_READ_CHUNK_BYTES = 1024 * 1024

# Strong references to in-flight pipeline tasks. The event loop only keeps weak
# references, so a discarded create_task() result can be GC'd mid-run and the
# job silently stalls. Same pattern as SocialImportPipelineService._tasks.
_pipeline_tasks: "set[asyncio.Task]" = set()


def _spawn_pipeline(service: BatchExtractionService, job) -> None:
    """Kick off a pipeline task while holding a strong reference to it."""
    task = asyncio.create_task(service.run_pipeline(job))
    _pipeline_tasks.add(task)
    task.add_done_callback(_pipeline_tasks.discard)


async def _read_upload_capped(upload: UploadFile, max_bytes: int) -> bytes:
    """Read an upload in chunks, rejecting once max_bytes is crossed."""
    chunks: List[bytes] = []
    total = 0
    while True:
        chunk = await upload.read(_READ_CHUNK_BYTES)
        if not chunk:
            break
        total += len(chunk)
        if total > max_bytes:
            raise FileTooLargeError(max_size_mb=_MAX_BATCH_IMAGE_BYTES // (1024 * 1024))
        chunks.append(chunk)
    return b"".join(chunks)


class BatchImageInput(BaseModel):
    """Single image for batch processing."""
    image_id: str = Field(..., description="Client-generated unique ID for tracking")
    image_base64: str = Field(
        ...,
        max_length=_MAX_BATCH_IMAGE_B64,
        description="Base64-encoded image data (max ~10MB encoded)",
    )
    filename: Optional[str] = Field(None, description="Original filename")


class BatchExtractionRequest(BaseModel):
    """Request to start batch extraction (JSON / Flutter)."""
    images: List[BatchImageInput] = Field(
        ...,
        min_length=1,
        max_length=_MAX_BATCH_IMAGES,
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
        description="Max concurrent product-image generations (max 5)",
    )


class SingleExtractionRequest(BaseModel):
    """Request to start single-item extraction."""
    image: str = Field(
        ...,
        max_length=_MAX_BATCH_IMAGE_B64,
        description="Base64-encoded image (max ~10MB encoded)",
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
) -> None:
    """Raise RateLimitError if this batch would exceed the user's daily limits."""
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

    if auto_generate:
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


async def _start_batch_job(
    *,
    user_id: str,
    db: Client,
    images_data: List[Dict[str, Any]],
    auto_generate: bool,
    generation_batch_size: int,
) -> BatchJobResponse:
    """Rate-limit, create job, kick off pipeline, return 202 payload."""
    total_images = len(images_data)
    if total_images < 1:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="At least one image is required",
        )
    if total_images > _MAX_BATCH_IMAGES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Maximum {_MAX_BATCH_IMAGES} images per batch",
        )

    await _check_batch_rate_limits(
        user_id=user_id,
        db=db,
        total_images=total_images,
        auto_generate=auto_generate,
    )

    job = await BatchJobService.create_job(
        user_id=user_id,
        images=images_data,
        auto_generate=auto_generate,
        generation_batch_size=generation_batch_size,
    )

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
    user_id: str = Depends(get_current_user_id),
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
    generation_batch_size: int = Form(5, ge=1, le=5),
    user_id: str = Depends(get_current_user_id),
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
        if len(files) > _MAX_BATCH_IMAGES:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Maximum {_MAX_BATCH_IMAGES} images per batch",
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
        await _check_batch_rate_limits(
            user_id=user_id,
            db=db,
            total_images=len(files),
            auto_generate=auto_generate,
        )

        images_data: List[Dict[str, Any]] = []
        for index, upload in enumerate(files):
            content_type = (upload.content_type or "").lower()
            if not content_type.startswith("image/"):
                raise UnsupportedMediaTypeError(
                    message=(
                        f"Unsupported content type at index {index}: "
                        f"{content_type or '(missing)'}"
                    )
                )
            content = await _read_upload_capped(upload, _MAX_BATCH_IMAGE_BYTES)
            if not content:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Empty file at index {index}",
                )

            image_id = ids[index] if ids else f"img-{uuid4().hex[:12]}"
            images_data.append(
                {
                    "image_id": image_id,
                    "image_base64": base64.b64encode(content).decode("utf-8"),
                    "filename": upload.filename,
                }
            )

        return await _start_batch_job(
            user_id=user_id,
            db=db,
            images_data=images_data,
            auto_generate=auto_generate,
            generation_batch_size=generation_batch_size,
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
    job = await BatchJobService.get_job(job_id, user_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    async def event_generator():
        queue: asyncio.Queue = asyncio.Queue(maxsize=100)

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


@router.post(
    "/single-extract",
    response_model=BatchJobResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
async def start_single_extraction(
    request: SingleExtractionRequest,
    user_id: str = Depends(get_current_user_id),
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
        from datetime import datetime
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
                    "image_id": f"cached_{datetime.utcnow().timestamp()}",
                    "image_base64": request.image,
                    "filename": "uploaded_image.jpg",
                }

                job = await BatchJobService.create_job(
                    user_id=user_id,
                    images=[image_data],
                    auto_generate=request.auto_generate,
                    generation_batch_size=1,
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
        # Check rate limit
        from app.services.ai_settings_service import AISettingsService

        extraction_check = await AISettingsService.check_rate_limit(
            user_id=user_id,
            operation_type="extraction",
            db=db,
            count=1,
        )
        if not extraction_check["allowed"]:
            raise RateLimitError(
                f"Daily extraction limit ({extraction_check['limit']}) exceeded"
            )

        # Create single-image batch job (reuse batch infrastructure)
        image_data = {
            "image_id": f"single_{datetime.utcnow().timestamp()}",
            "image_base64": request.image,
            "filename": "uploaded_image.jpg",
        }

        job = await BatchJobService.create_job(
            user_id=user_id,
            images=[image_data],
            auto_generate=request.auto_generate,
            # ponytail: generate a single photo's ~3 items concurrently, not one-at-a-time.
            # GENERATION_SEMAPHORE(5) still caps process-wide concurrency.
            generation_batch_size=5,
        )

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
