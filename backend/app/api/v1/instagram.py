"""
Instagram API routes.

Provides endpoints for Instagram URL validation, scraping, and batch preparation.
"""

import asyncio
import json
from datetime import datetime
from typing import Any, Dict

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sse_starlette.sse import EventSourceResponse
from supabase import Client

from app.core.logging_config import get_context_logger
from app.core.security import get_current_user_id
from app.db.connection import get_db
from app.models.instagram import (
    InstagramBatchRequest,
    InstagramBatchResponse,
    InstagramCredentialsStatus,
    InstagramLoginRequest,
    InstagramLoginResponse,
    InstagramProfileInfo,
    InstagramProfileRequest,
    InstagramScrapeJobResponse,
    InstagramScrapeRequest,
    InstagramScrapeStatus,
    InstagramURLRequest,
    InstagramURLType,
    InstagramURLValidation,
)
from app.services.instagram_job_service import InstagramJobService
from app.services.instagram_service import get_instagram_service
from app.services.instagram_credential_service import InstagramCredentialService
from app.services.batch_job_service import BatchJobService

logger = get_context_logger(__name__)

router = APIRouter()


# =============================================================================
# URL VALIDATION
# =============================================================================


@router.post(
    "/validate-url",
    response_model=InstagramURLValidation,
)
async def validate_instagram_url(
    request: InstagramURLRequest,
    user_id: str = Depends(get_current_user_id),
):
    """
    Validate an Instagram URL and return its type.

    Quick check - no actual scraping performed.
    Returns whether the URL is valid and its type (profile, post, or reel).
    """
    service = get_instagram_service()
    result = service.validate_url(request.url)

    logger.info(
        "Validated Instagram URL",
        extra={
            "user_id": user_id,
            "valid": result.valid,
            "url_type": result.url_type.value if result.url_type else None,
        },
    )

    return result


# =============================================================================
# PROFILE CHECK
# =============================================================================


@router.post(
    "/check-profile",
    response_model=InstagramProfileInfo,
)
async def check_instagram_profile(
    request: InstagramProfileRequest,
    user_id: str = Depends(get_current_user_id),
):
    """
    Check if an Instagram profile is public and get basic info.

    Returns profile metadata including post count, which helps users
    understand how many images are available before starting a scrape.
    """
    service = get_instagram_service()
    result = await service.check_profile(request.username)

    logger.info(
        "Checked Instagram profile",
        extra={
            "user_id": user_id,
            "username": request.username,
            "is_public": result.is_public,
            "post_count": result.post_count,
        },
    )

    return result


# =============================================================================
# SCRAPING
# =============================================================================


@router.post(
    "/scrape",
    response_model=InstagramScrapeJobResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
async def start_instagram_scrape(
    request: InstagramScrapeRequest,
    user_id: str = Depends(get_current_user_id),
):
    """
    Start scraping images from an Instagram URL.

    For profiles: Scrapes images with SSE progress updates.
    For posts: Returns all images from the post.

    Returns job_id and SSE URL for progress updates.
    """
    service = get_instagram_service()

    # Validate URL
    validation = service.validate_url(request.url)
    if not validation.valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=validation.error or "Invalid Instagram URL",
        )

    # Create job
    job = await InstagramJobService.create_job(
        user_id=user_id,
        url_type=validation.url_type,
        identifier=validation.identifier,
    )

    # Start scraping in background
    asyncio.create_task(
        _run_scraping(
            job_id=job.job_id,
            url_type=validation.url_type,
            identifier=validation.identifier,
            max_posts=request.max_posts,
        )
    )

    logger.info(
        "Started Instagram scrape",
        extra={
            "job_id": job.job_id,
            "user_id": user_id,
            "url_type": validation.url_type.value,
            "identifier": validation.identifier,
        },
    )

    return InstagramScrapeJobResponse(
        job_id=job.job_id,
        status=job.status.value,
        url_type=validation.url_type,
        identifier=validation.identifier,
        sse_url=f"/api/v1/instagram/scrape/{job.job_id}/events",
        message=f"Scraping started for {validation.url_type.value}: {validation.identifier}",
    )


async def _run_scraping(
    job_id: str,
    url_type: InstagramURLType,
    identifier: str,
    max_posts: int,
):
    """Background task to run the scraping pipeline."""
    service = get_instagram_service()
    job = await InstagramJobService.get_job_unsafe(job_id)

    if not job:
        return

    try:
        # Update status to scraping
        await InstagramJobService.update_status(job_id, InstagramScrapeStatus.SCRAPING)
        await InstagramJobService.broadcast_event(job_id, "scrape_started", {
            "job_id": job_id,
            "url_type": url_type.value,
            "identifier": identifier,
            "timestamp": datetime.utcnow().isoformat(),
        })

        if url_type == InstagramURLType.PROFILE:
            # Scrape profile with progress updates
            async for images, scraped, total in service.scrape_profile_images(
                username=identifier,
                max_posts=max_posts,
                cancel_event=job.cancel_event,
            ):
                if job.is_cancelled():
                    break

                # Add images to job
                await InstagramJobService.add_images(job_id, images, scraped, total)

                # Broadcast progress
                await InstagramJobService.broadcast_event(job_id, "scrape_progress", {
                    "scraped": scraped,
                    "total": total,
                    "images": [img.model_dump(mode="json") for img in images],
                    "timestamp": datetime.utcnow().isoformat(),
                })

        else:
            # Scrape single post/reel
            images = await service.scrape_post_images(identifier)
            await InstagramJobService.add_images(job_id, images, 1, 1)

            # Broadcast progress
            await InstagramJobService.broadcast_event(job_id, "scrape_progress", {
                "scraped": 1,
                "total": 1,
                "images": [img.model_dump(mode="json") for img in images],
                "timestamp": datetime.utcnow().isoformat(),
            })

        # Check for cancellation
        if job.is_cancelled():
            return

        # Mark as completed
        await InstagramJobService.set_completed(job_id, has_more=False)

        # Get final status
        final_job = await InstagramJobService.get_job_unsafe(job_id)
        total_images = len(final_job.images) if final_job else 0

        await InstagramJobService.broadcast_event(job_id, "scrape_complete", {
            "job_id": job_id,
            "total_images": total_images,
            "has_more": False,
            "timestamp": datetime.utcnow().isoformat(),
        })

        logger.info(
            "Instagram scrape completed",
            extra={
                "job_id": job_id,
                "total_images": total_images,
            },
        )

    except Exception as e:
        logger.error(
            "Instagram scrape failed",
            extra={"job_id": job_id, "error": str(e)},
        )

        await InstagramJobService.set_error(job_id, str(e))
        await InstagramJobService.broadcast_event(job_id, "scrape_error", {
            "job_id": job_id,
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat(),
        })


@router.get("/scrape/{job_id}/events")
async def instagram_scrape_events(
    job_id: str,
    user_id: str = Depends(get_current_user_id),
):
    """
    SSE endpoint for scraping progress.

    Event types:
    - connected: Connection established
    - heartbeat: Keep-alive (every 30s)
    - scrape_started: Scraping begins
    - scrape_progress: Progress update with images
    - scrape_complete: All images scraped
    - scrape_error: Error occurred
    - scrape_cancelled: User cancelled
    """
    job = await InstagramJobService.get_job(job_id, user_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    async def event_generator():
        queue: asyncio.Queue = asyncio.Queue()

        # Add subscriber
        if not await InstagramJobService.add_subscriber(job_id, queue):
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
                    "timestamp": datetime.utcnow().isoformat(),
                }),
            }

            # If job already completed, send final status
            if job.status in (
                InstagramScrapeStatus.COMPLETED,
                InstagramScrapeStatus.FAILED,
                InstagramScrapeStatus.CANCELLED,
            ):
                status_data = await InstagramJobService.get_job_status(job_id)
                if status_data:
                    event_map = {
                        InstagramScrapeStatus.COMPLETED: "scrape_complete",
                        InstagramScrapeStatus.FAILED: "scrape_error",
                        InstagramScrapeStatus.CANCELLED: "scrape_cancelled",
                    }
                    yield {
                        "event": event_map.get(job.status, f"scrape_{job.status.value}"),
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
                    if event["type"] in ("scrape_complete", "scrape_error", "scrape_cancelled"):
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
            await InstagramJobService.remove_subscriber(job_id, queue)

    return EventSourceResponse(event_generator())


@router.post("/scrape/{job_id}/cancel")
async def cancel_instagram_scrape(
    job_id: str,
    user_id: str = Depends(get_current_user_id),
):
    """Cancel a running scrape job."""
    success = await InstagramJobService.cancel_job(job_id, user_id)
    if not success:
        raise HTTPException(
            status_code=404,
            detail="Job not found or already complete",
        )

    logger.info("Cancelled Instagram scrape", extra={"job_id": job_id, "user_id": user_id})
    return {"message": "Job cancelled"}


@router.get("/scrape/{job_id}/images")
async def get_scraped_images(
    job_id: str,
    user_id: str = Depends(get_current_user_id),
    offset: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
):
    """
    Get paginated list of scraped images.

    Useful for reconnection or viewing more images.
    """
    job = await InstagramJobService.get_job(job_id, user_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    result = await InstagramJobService.get_job_images(job_id, offset, limit)
    if not result:
        raise HTTPException(status_code=404, detail="Job not found")

    return result


# =============================================================================
# BATCH PREPARATION
# =============================================================================


@router.post(
    "/prepare-batch",
    response_model=InstagramBatchResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
async def prepare_instagram_batch(
    request: InstagramBatchRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Prepare selected Instagram images for batch extraction.

    Downloads selected images, converts to base64, and starts
    a standard batch extraction job.

    Returns the batch job ID and SSE URL for extraction progress.
    """
    instagram_service = get_instagram_service()

    # Get the scrape job
    scrape_job = await InstagramJobService.get_job(request.job_id, user_id)
    if not scrape_job:
        raise HTTPException(status_code=404, detail="Instagram job not found")

    if scrape_job.status != InstagramScrapeStatus.COMPLETED:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Instagram job is not completed yet",
        )

    # Get selected images
    selected_images = [
        img for img in scrape_job.images
        if img.image_id in request.selected_image_ids
    ]

    if not selected_images:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No valid images selected",
        )

    # Limit to 50 images
    selected_images = selected_images[:50]

    logger.info(
        "Preparing Instagram batch",
        extra={
            "user_id": user_id,
            "scrape_job_id": request.job_id,
            "image_count": len(selected_images),
        },
    )

    # Download images and convert to base64
    image_data = await instagram_service.fetch_images_as_base64(selected_images)

    # Prepare batch images
    batch_images = []
    for img in selected_images:
        if img.image_id in image_data:
            batch_images.append({
                "image_id": img.image_id,
                "image_base64": image_data[img.image_id],
                "filename": f"instagram_{img.image_id}.jpg",
            })

    if not batch_images:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to download any images",
        )

    # Create batch extraction job
    batch_job = await BatchJobService.create_job(
        user_id=user_id,
        images=batch_images,
        auto_generate=True,
        generation_batch_size=5,
    )

    # Import and start extraction service
    from app.services.batch_extraction_service import BatchExtractionService

    service = BatchExtractionService(user_id=user_id, db=db)
    asyncio.create_task(service.run_pipeline(batch_job))

    logger.info(
        "Started batch extraction from Instagram",
        extra={
            "batch_job_id": batch_job.job_id,
            "user_id": user_id,
            "image_count": len(batch_images),
        },
    )

    return InstagramBatchResponse(
        batch_job_id=batch_job.job_id,
        sse_url=f"/api/v1/ai/batch-extract/{batch_job.job_id}/events",
        image_count=len(batch_images),
        message=f"Started extraction for {len(batch_images)} images from Instagram",
    )


# =============================================================================
# AUTHENTICATION
# =============================================================================


@router.post(
    "/login",
    response_model=InstagramLoginResponse,
)
async def login_instagram(
    request: InstagramLoginRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Login to Instagram with username and password.

    Credentials are encrypted and stored for future use.
    Session is persisted to avoid repeated logins.
    """
    service = get_instagram_service()

    # Attempt login
    result = await service.login(request.username, request.password)

    if not result["success"]:
        logger.warning(
            "Instagram login failed",
            extra={"user_id": user_id, "error": result.get("error")},
        )
        return InstagramLoginResponse(
            success=False,
            error=result.get("error", "Login failed"),
        )

    # Save credentials
    saved = await InstagramCredentialService.save_credentials(
        user_id=user_id,
        username=request.username,
        password=request.password,
        db=db,
    )

    if not saved:
        logger.error("Failed to save Instagram credentials", extra={"user_id": user_id})

    # Save session data
    session_data = service.get_session_data()
    if session_data:
        await InstagramCredentialService.update_session(user_id, session_data, db)

    logger.info("Instagram login successful", extra={"user_id": user_id, "username": request.username})

    return InstagramLoginResponse(
        success=True,
        username=request.username,
    )


@router.post("/logout")
async def logout_instagram(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Logout from Instagram and delete stored credentials.
    """
    service = get_instagram_service()
    service.logout()

    await InstagramCredentialService.delete_credentials(user_id, db)

    logger.info("Instagram logout", extra={"user_id": user_id})

    return {"message": "Logged out successfully"}


@router.get(
    "/credentials-status",
    response_model=InstagramCredentialsStatus,
)
async def get_instagram_credentials_status(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Check if the user has stored Instagram credentials.
    """
    status = await InstagramCredentialService.get_credentials_status(user_id, db)

    return InstagramCredentialsStatus(
        has_credentials=status["has_credentials"],
        is_valid=status["is_valid"],
        username=status["username"],
        last_used=status["last_used"],
    )


@router.post("/ensure-session")
async def ensure_instagram_session(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Ensure Instagram session is active using stored credentials.

    If session is expired, attempts to re-login using stored credentials.
    """
    service = get_instagram_service()

    # Check if already logged in
    if service.is_logged_in():
        return {"success": True, "message": "Already logged in"}

    # Try to load stored session first
    session_data = await InstagramCredentialService.get_session(user_id, db)
    if session_data:
        loaded = await service.load_session(session_data)
        if loaded:
            logger.info("Loaded stored Instagram session", extra={"user_id": user_id})
            return {"success": True, "message": "Session restored"}

    # Session invalid, try to re-login with stored credentials
    credentials = await InstagramCredentialService.get_credentials(user_id, db)
    if not credentials:
        return {"success": False, "error": "No stored credentials. Please login first."}

    result = await service.login(credentials["username"], credentials["password"])

    if not result["success"]:
        await InstagramCredentialService.mark_invalid(user_id, db)
        return {"success": False, "error": result.get("error", "Re-login failed")}

    # Update session
    new_session = service.get_session_data()
    if new_session:
        await InstagramCredentialService.update_session(user_id, new_session, db)

    logger.info("Re-logged into Instagram", extra={"user_id": user_id})
    return {"success": True, "message": "Re-logged in successfully"}
