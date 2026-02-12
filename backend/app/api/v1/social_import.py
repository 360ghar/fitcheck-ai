"""
API routes for social profile import queue.
"""

from __future__ import annotations

import asyncio
import json
from html import escape
from datetime import datetime, timezone
from typing import Any, Dict, Optional
from urllib.parse import parse_qsl, urlencode, urlparse, urlunparse

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from fastapi.responses import HTMLResponse, RedirectResponse
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
    SocialImportOAuthConnectResponse,
    SocialImportOAuthAuthRequest,
    SocialImportScraperAuthRequest,
    SocialImportStartRequest,
    SocialPlatform,
)
from app.services.social_import_event_service import SocialImportEventService
from app.services.social_import_job_store import SocialImportJobStore
from app.services.social_import_pipeline_service import SocialImportPipelineService
from app.services.social_oauth_service import SocialOAuthService
from app.services.social_url_service import SocialURLService

router = APIRouter()


def _service(user_id: str, db: Client) -> SocialImportPipelineService:
    return SocialImportPipelineService(user_id=user_id, db=db)


def _frontend_origin() -> str:
    parsed = urlparse(settings.FRONTEND_URL or "")
    if parsed.scheme and parsed.netloc:
        return f"{parsed.scheme}://{parsed.netloc}"
    return (settings.FRONTEND_URL or "").rstrip("/")


def _oauth_popup_response(
    *,
    job_id: str,
    status_value: str,
    message: str,
    target_origin: Optional[str] = None,
) -> HTMLResponse:
    payload = {
        "source": "fitcheck-social-oauth",
        "job_id": job_id,
        "status": status_value,
        "message": message,
    }
    target_origin = (target_origin or _frontend_origin() or "*").rstrip("/")
    payload_json = json.dumps(payload)
    target_origin_json = json.dumps(target_origin)
    safe_message = escape(message)

    html = f"""<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>Social Connect</title>
  </head>
  <body>
    <p>{safe_message}</p>
    <script>
      (function () {{
        var payload = {payload_json};
        var targetOrigin = {target_origin_json};
        try {{
          if (window.opener && !window.opener.closed) {{
            window.opener.postMessage(payload, targetOrigin);
          }}
        }} catch (err) {{
          // Ignore and continue to close flow.
        }}
        window.setTimeout(function () {{
          window.close();
        }}, 150);
      }})();
    </script>
    </body>
</html>"""
    return HTMLResponse(content=html)


def _oauth_mobile_redirect_response(
    *,
    redirect_uri: str,
    job_id: str,
    status_value: str,
    message: str,
) -> RedirectResponse:
    parsed = urlparse(redirect_uri)
    query = dict(parse_qsl(parsed.query, keep_blank_values=True))
    query.update(
        {
            "source": "fitcheck-social-oauth",
            "job_id": job_id,
            "status": status_value,
            "message": message,
        }
    )
    target = urlunparse(parsed._replace(query=urlencode(query), fragment=""))
    return RedirectResponse(url=target, status_code=status.HTTP_302_FOUND)


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


@router.post("/social-import/jobs/{job_id}/auth/oauth/connect", response_model=Dict[str, Any])
async def create_oauth_connect_url(
    job_id: str,
    request: Request,
    mobile_redirect_uri: Optional[str] = Query(default=None),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    if not settings.ENABLE_SOCIAL_IMPORT:
        raise HTTPException(status_code=404, detail="Social import is disabled")

    job = await SocialImportJobStore.get_job(db, job_id=job_id, user_id=user_id)
    if not job:
        raise SocialImportJobNotFoundError(job_id)

    platform = SocialPlatform(job["platform"])
    redirect_uri = str(request.url_for("social_oauth_callback"))
    oauth_data = SocialOAuthService.build_authorize_url(
        user_id=user_id,
        job_id=job_id,
        platform=platform,
        redirect_uri=redirect_uri,
        opener_origin=request.headers.get("origin"),
        mobile_redirect_uri=mobile_redirect_uri,
    )
    response = SocialImportOAuthConnectResponse(**oauth_data)
    return {"data": response.model_dump(), "message": "OK"}


@router.get(
    "/social-import/auth/oauth/callback",
    response_class=HTMLResponse,
    name="social_oauth_callback",
)
async def social_oauth_callback(
    request: Request,
    state: Optional[str] = Query(default=None),
    code: Optional[str] = Query(default=None),
    error: Optional[str] = Query(default=None),
    error_description: Optional[str] = Query(default=None),
    db: Client = Depends(get_db),
):
    if not settings.ENABLE_SOCIAL_IMPORT:
        return _oauth_popup_response(
            job_id="unknown",
            status_value="error",
            message="Social import is disabled",
        )

    if not state:
        return _oauth_popup_response(
            job_id="unknown",
            status_value="error",
            message="Missing OAuth state",
        )

    try:
        state_payload = SocialOAuthService.parse_state(state)
    except Exception as exc:
        return _oauth_popup_response(
            job_id="unknown",
            status_value="error",
            message=str(exc),
        )

    if error:
        message = error_description or error
        if state_payload.mobile_redirect_uri:
            return _oauth_mobile_redirect_response(
                redirect_uri=state_payload.mobile_redirect_uri,
                job_id=state_payload.job_id,
                status_value="error",
                message=message,
            )
        return _oauth_popup_response(
            job_id=state_payload.job_id,
            status_value="error",
            message=message,
            target_origin=state_payload.opener_origin,
        )

    if not code:
        if state_payload.mobile_redirect_uri:
            return _oauth_mobile_redirect_response(
                redirect_uri=state_payload.mobile_redirect_uri,
                job_id=state_payload.job_id,
                status_value="error",
                message="Missing OAuth code",
            )
        return _oauth_popup_response(
            job_id=state_payload.job_id,
            status_value="error",
            message="Missing OAuth code",
            target_origin=state_payload.opener_origin,
        )

    try:
        redirect_uri = str(request.url_for("social_oauth_callback"))
        token_payload = await SocialOAuthService.exchange_code_for_token(
            code=code,
            redirect_uri=redirect_uri,
        )
        identity_payload = await SocialOAuthService.resolve_platform_identity(
            platform=state_payload.platform,
            access_token=token_payload["provider_access_token"],
        )

        payload = {
            "provider_access_token": token_payload["provider_access_token"],
            "provider_refresh_token": None,
            "provider_user_id": identity_payload.get("provider_user_id"),
            "provider_page_access_token": identity_payload.get("provider_page_access_token"),
            "provider_page_id": identity_payload.get("provider_page_id"),
            "provider_username": identity_payload.get("provider_username"),
            "expires_at": token_payload.get("expires_at"),
        }
        service = _service(state_payload.user_id, db)
        await service.accept_oauth_auth(state_payload.job_id, payload)
    except Exception as exc:
        if state_payload.mobile_redirect_uri:
            return _oauth_mobile_redirect_response(
                redirect_uri=state_payload.mobile_redirect_uri,
                job_id=state_payload.job_id,
                status_value="error",
                message=str(exc),
            )
        return _oauth_popup_response(
            job_id=state_payload.job_id,
            status_value="error",
            message=str(exc),
            target_origin=state_payload.opener_origin,
        )

    if state_payload.mobile_redirect_uri:
        return _oauth_mobile_redirect_response(
            redirect_uri=state_payload.mobile_redirect_uri,
            job_id=state_payload.job_id,
            status_value="success",
            message="Social account connected. Import resumed.",
        )

    return _oauth_popup_response(
        job_id=state_payload.job_id,
        status_value="success",
        message="Social account connected. Import resumed.",
        target_origin=state_payload.opener_origin,
    )


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
