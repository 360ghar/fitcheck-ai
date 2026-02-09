"""
API routes for social profile import queue.
"""

from __future__ import annotations

import asyncio
import json
from datetime import datetime, timezone
from typing import Any, Dict, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sse_starlette.sse import EventSourceResponse
from supabase import Client

from app.core.config import settings
from app.core.exceptions import SocialImportJobNotFoundError
from app.core.security import get_current_user_id
from app.db.connection import get_db
from app.models.social_import import (
    SocialImportActionResponse,
    SocialImportAuthResponse,
    SocialImportItemPatchRequest,
    SocialImportJobResponse,
    SocialImportJobStatusResponse,
    SocialImportOAuthAuthRequest,
    SocialImportScraperAuthRequest,
    SocialImportStartRequest,
)
from app.services.social_import_event_service import SocialImportEventService
from app.services.social_import_job_store import SocialImportJobStore
from app.services.social_import_pipeline_service import SocialImportPipelineService
from app.services.social_url_service import SocialURLService

router = APIRouter()


def _service(user_id: str, db: Client) -> SocialImportPipelineService:
    return SocialImportPipelineService(user_id=user_id, db=db)


@router.post(
    "/social-import/jobs",
    response_model=Dict[str, Any],
    status_code=status.HTTP_202_ACCEPTED,
)
async def create_social_import_job(
    body: SocialImportStartRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    if not settings.ENABLE_SOCIAL_IMPORT:
        raise HTTPException(status_code=404, detail="Social import is disabled")

    normalized = SocialURLService.normalize_profile_url(body.source_url)
    job = await SocialImportJobStore.create_job(
        db,
        user_id=user_id,
        platform=normalized.platform.value,
        source_url=normalized.source_url,
        normalized_url=normalized.normalized_url,
    )

    service = _service(user_id, db)
    await SocialImportPipelineService.schedule_job(service, job["id"])

    response = SocialImportJobResponse(
        job_id=job["id"],
        status=job["status"],
        platform=job["platform"],
        source_url=job["source_url"],
        normalized_url=job["normalized_url"],
        message="Social import job started",
    )
    return {"data": response.model_dump(), "message": "Started"}


@router.get("/social-import/jobs/{job_id}/status", response_model=Dict[str, Any])
async def get_social_import_status(
    job_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    if not settings.ENABLE_SOCIAL_IMPORT:
        raise HTTPException(status_code=404, detail="Social import is disabled")

    service = _service(user_id, db)
    payload = await service.get_status(job_id)
    response = SocialImportJobStatusResponse(**payload)
    return {"data": response.model_dump(mode="json"), "message": "OK"}


@router.get("/social-import/jobs/{job_id}/events")
async def social_import_events(
    job_id: str,
    last_event_id: Optional[int] = Query(default=None),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    if not settings.ENABLE_SOCIAL_IMPORT:
        raise HTTPException(status_code=404, detail="Social import is disabled")

    job = await SocialImportJobStore.get_job(db, job_id=job_id, user_id=user_id)
    if not job:
        raise SocialImportJobNotFoundError(job_id)

    async def event_generator():
        queue: asyncio.Queue = asyncio.Queue()
        await SocialImportEventService.add_subscriber(job_id, queue)

        try:
            status_payload = await _service(user_id, db).get_status(job_id)
            connected_payload = {
                "job_id": job_id,
                "status": status_payload["status"],
                "timestamp": datetime.now(timezone.utc).isoformat(),
            }
            yield {"event": "connected", "data": json.dumps(connected_payload)}

            history = await SocialImportEventService.replay(
                db,
                job_id=job_id,
                user_id=user_id,
                after_id=last_event_id,
            )
            max_replayed_id = last_event_id
            for event in history:
                max_replayed_id = event.get("id") or max_replayed_id
                yield {
                    "event": event["type"],
                    "id": str(event.get("id")),
                    "data": json.dumps(event["data"]),
                }
                if event["type"] in {"job_completed", "job_failed", "job_cancelled"}:
                    return

            while True:
                try:
                    event = await asyncio.wait_for(queue.get(), timeout=30)
                    max_replayed_id = event.get("id") or max_replayed_id
                    yield {
                        "event": event["type"],
                        "id": str(event.get("id")),
                        "data": json.dumps(event["data"]),
                    }
                    if event["type"] in {
                        "job_completed",
                        "job_failed",
                        "job_cancelled",
                    }:
                        break
                except asyncio.TimeoutError:
                    status_payload = await _service(user_id, db).get_status(job_id)
                    heartbeat = {
                        "job_id": job_id,
                        "timestamp": datetime.now(timezone.utc).isoformat(),
                        "last_event_id": max_replayed_id,
                        "status": status_payload.get("status"),
                    }
                    yield {"event": "heartbeat", "data": json.dumps(heartbeat)}
        finally:
            await SocialImportEventService.remove_subscriber(job_id, queue)

    return EventSourceResponse(event_generator())


@router.post("/social-import/jobs/{job_id}/auth/oauth", response_model=Dict[str, Any])
async def submit_oauth_auth(
    job_id: str,
    body: SocialImportOAuthAuthRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    service = _service(user_id, db)
    await service.accept_oauth_auth(job_id, body.model_dump())
    return {
        "data": SocialImportAuthResponse(
            success=True,
            status="processing",
            message="OAuth auth accepted. Import resumed.",
        ).model_dump(),
        "message": "OK",
    }


@router.post(
    "/social-import/jobs/{job_id}/auth/scraper-login", response_model=Dict[str, Any]
)
async def submit_scraper_login(
    job_id: str,
    body: SocialImportScraperAuthRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    service = _service(user_id, db)
    await service.accept_scraper_auth(job_id, body.model_dump())
    return {
        "data": SocialImportAuthResponse(
            success=True,
            status="processing",
            message="Scraper auth accepted. Import resumed.",
        ).model_dump(),
        "message": "OK",
    }


@router.patch(
    "/social-import/jobs/{job_id}/photos/{photo_id}/items/{item_id}",
    response_model=Dict[str, Any],
)
async def patch_social_item(
    job_id: str,
    photo_id: str,
    item_id: str,
    body: SocialImportItemPatchRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    service = _service(user_id, db)
    updated = await service.patch_item(
        job_id=job_id,
        photo_id=photo_id,
        item_id=item_id,
        updates=body.model_dump(exclude_none=True),
    )
    if not updated:
        raise HTTPException(status_code=404, detail="Item not found")
    return {"data": updated, "message": "Updated"}


@router.post(
    "/social-import/jobs/{job_id}/photos/{photo_id}/approve",
    response_model=Dict[str, Any],
)
async def approve_social_photo(
    job_id: str,
    photo_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    service = _service(user_id, db)
    result = await service.approve_photo(job_id, photo_id)
    payload = SocialImportActionResponse(
        success=True,
        job_id=job_id,
        photo_id=photo_id,
        status="approved",
        message=f"Photo approved and saved ({result.get('saved_count', 0)} items)",
    )
    return {"data": payload.model_dump(), "message": "Approved"}


@router.post(
    "/social-import/jobs/{job_id}/photos/{photo_id}/reject",
    response_model=Dict[str, Any],
)
async def reject_social_photo(
    job_id: str,
    photo_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    service = _service(user_id, db)
    await service.reject_photo(job_id, photo_id)
    payload = SocialImportActionResponse(
        success=True,
        job_id=job_id,
        photo_id=photo_id,
        status="rejected",
        message="Photo rejected",
    )
    return {"data": payload.model_dump(), "message": "Rejected"}


@router.post("/social-import/jobs/{job_id}/cancel", response_model=Dict[str, Any])
async def cancel_social_import_job(
    job_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    service = _service(user_id, db)
    await service.cancel_job(job_id)
    payload = SocialImportActionResponse(
        success=True,
        job_id=job_id,
        status="cancelled",
        message="Job cancelled",
    )
    return {"data": payload.model_dump(), "message": "Cancelled"}
