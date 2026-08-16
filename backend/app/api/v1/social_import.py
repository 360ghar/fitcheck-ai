"""
API routes for social profile import queue.
"""

from __future__ import annotations

import asyncio
import json
from html import escape
from app.utils.datetime_util import parse_utc_datetime, utcnow_iso
from typing import Any, Dict, Optional
from urllib.parse import parse_qsl, urlencode, urlparse, urlunparse

from fastapi import APIRouter, Depends, Form, HTTPException, Query, Request, status
from fastapi.responses import HTMLResponse, RedirectResponse
from sse_starlette.sse import EventSourceResponse
from supabase import Client

from app.core.config import settings
from app.core.exceptions import SocialImportJobNotFoundError, ValidationError
from app.core.logging_config import get_context_logger
from app.api.v1.deps import get_active_user_id
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
from app.services.social_auth_service import SocialAuthService
from app.services.social_oauth_service import SocialOAuthService
from app.services.social_url_service import SocialURLService
from app.utils.sse_queue import SSE_QUEUE_MAXSIZE, STREAM_OVERFLOW, note_consumed

router = APIRouter()

logger = get_context_logger(__name__)

# Note the ``_completed`` spelling here: this stream's terminal names differ
# from batch/photoshoot's ``job_complete``. Kept as-is to avoid a client break.
_TERMINAL_SSE_EVENTS = {
    "job_completed",
    "job_failed",
    "job_cancelled",
    STREAM_OVERFLOW,
}


def _service(user_id: str, db: Client) -> SocialImportPipelineService:
    return SocialImportPipelineService(user_id=user_id, db=db)


def _frontend_origin() -> str:
    parsed = urlparse(settings.FRONTEND_URL or "")
    if parsed.scheme and parsed.netloc:
        return f"{parsed.scheme}://{parsed.netloc}"
    return (settings.FRONTEND_URL or "").rstrip("/")


def _validate_target_origin(target_origin: Optional[str]) -> str:
    """Validate target_origin against allowed origins for security."""
    if not target_origin:
        return _frontend_origin()

    target = target_origin.rstrip("/")
    parsed_target = urlparse(target)
    if parsed_target.scheme not in {"http", "https"} or not parsed_target.netloc:
        return _frontend_origin() or "*"
    target_host = parsed_target.hostname or ""

    allowed_origins = set(settings.BACKEND_CORS_ORIGINS or [])
    frontend = _frontend_origin()
    if frontend:
        allowed_origins.add(frontend)

    for allowed in allowed_origins:
        allowed = allowed.rstrip("/")
        if target == allowed:
            return target

        parsed_allowed = urlparse(allowed)
        allowed_host = parsed_allowed.hostname or ""
        if not allowed_host:
            continue

        # Allow fitcheck first-party subdomains, but avoid suffix tricks
        # such as evilfitcheckaiapp.com.
        if (
            allowed_host == "fitcheckaiapp.com"
            or allowed_host.endswith(".fitcheckaiapp.com")
        ):
            if target_host == "fitcheckaiapp.com" or target_host.endswith(".fitcheckaiapp.com"):
                return target

    # If no match, fall back to frontend_origin (don't allow arbitrary origins)
    return _frontend_origin() or "*"


def _build_oauth_payload(
    job_id: str,
    status_value: str,
    message: str,
    accounts: Optional[list] = None,
) -> Dict[str, str]:
    """Build the standard OAuth response payload."""
    payload = {
        "source": "fitcheck-social-oauth",
        "job_id": job_id,
        "status": status_value,
        "message": message,
    }
    # A4-28: when identity resolution needs an account selection, the
    # candidate pages ride along so the client can offer a picker instead of
    # failing silently. Additive key; existing clients ignore it.
    if accounts:
        payload["accounts"] = accounts
    return payload


def _json_for_inline_script(obj: Any) -> str:
    """
    Serialize to JSON safe for interpolation into an inline <script> tag.

    json.dumps does not escape '<', '>' or '&', so a value containing
    "</script><script>..." would otherwise break out of the script block.
    """
    return (
        json.dumps(obj)
        .replace("<", "\\u003c")
        .replace(">", "\\u003e")
        .replace("&", "\\u0026")
    )


def _oauth_popup_response(
    *,
    job_id: str,
    status_value: str,
    message: str,
    target_origin: Optional[str] = None,
    accounts: Optional[list] = None,
) -> HTMLResponse:
    payload = _build_oauth_payload(job_id, status_value, message, accounts=accounts)
    target_origin = _validate_target_origin(target_origin).rstrip("/")
    payload_json = _json_for_inline_script(payload)
    target_origin_json = _json_for_inline_script(target_origin)
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
    accounts: Optional[list] = None,
) -> RedirectResponse:
    parsed = urlparse(redirect_uri)
    query = dict(parse_qsl(parsed.query, keep_blank_values=True))
    query.update(_build_oauth_payload(job_id, status_value, message, accounts=accounts))
    target = urlunparse(parsed._replace(query=urlencode(query), fragment=""))
    return RedirectResponse(url=target, status_code=status.HTTP_302_FOUND)


def _oauth_response(
    *,
    job_id: str,
    status_value: str,
    message: str,
    mobile_redirect_uri: Optional[str] = None,
    opener_origin: Optional[str] = None,
    accounts: Optional[list] = None,
) -> HTMLResponse | RedirectResponse:
    """Return appropriate OAuth response based on client type (mobile vs web)."""
    if mobile_redirect_uri:
        return _oauth_mobile_redirect_response(
            redirect_uri=mobile_redirect_uri,
            job_id=job_id,
            status_value=status_value,
            message=message,
            accounts=accounts,
        )
    return _oauth_popup_response(
        job_id=job_id,
        status_value=status_value,
        message=message,
        target_origin=opener_origin,
        accounts=accounts,
    )


def _oauth_picker_response(
    *,
    job_id: str,
    selection_token: str,
    message: str,
    accounts: list,
    mobile_redirect_uri: Optional[str] = None,
    opener_origin: Optional[str] = None,
    select_url: Optional[str] = None,
) -> HTMLResponse:
    """Server-rendered account picker for the multi-Instagram-account flow.

    First-time OAuth with several business pages needs a human to choose the
    page (A4-28). This is served straight from the callback (no client code
    change required): it lists the candidate pages and POSTs the selection to
    ``{select_url}``, which resolves identity from the already-exchanged token
    and resumes the job. Popup clients get a postMessage + close; mobile
    redirect clients get a redirect back to their deep link with the standard
    payload. The selection is authorized by the signed ``selection_token``
    (the picker's browser cannot present the app's Authorization header).
    """
    target_origin = _validate_target_origin(opener_origin).rstrip("/")
    safe_message = escape(message)
    safe_job_id = escape(job_id)
    safe_token = escape(selection_token)
    # The router is mounted under /api/v1/ai (main.py), so the form target is
    # resolved from the request (url_for) rather than hardcoded — a bare
    # "/api/v1/social-import/..." here would 404 on the real prefix.
    if not select_url:
        select_url = f"/api/v1/ai/social-import/jobs/{safe_job_id}/auth/oauth/select-page"
    select_url = escape(select_url)

    options_html = "".join(
        f"""
        <button type="submit" name="provider_page_id" value="{escape(str(a.get('provider_page_id', '')))}"
                class="page-option">
          <span class="page-name">{escape(str(a.get('page_name') or a.get('provider_page_id') or ''))}</span>
          <span class="page-handle">@{escape(str(a.get('username') or ''))}</span>
        </button>"""
        for a in accounts
    )

    mobile_redirect_json = _json_for_inline_script(mobile_redirect_uri or "")
    success_payload_json = _json_for_inline_script(
        _build_oauth_payload(job_id, "success", "Account connected. Import resumed.")
    )
    target_origin_json = _json_for_inline_script(target_origin)

    html = f"""<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Select Instagram account</title>
    <style>
      body {{ font-family: -apple-system, system-ui, sans-serif; margin: 0;
              background: #fafafa; color: #262626; }}
      .card {{ max-width: 420px; margin: 10vh auto; background: #fff;
               border: 1px solid #dbdbdb; border-radius: 12px; padding: 24px; }}
      h1 {{ font-size: 18px; margin: 0 0 8px; }}
      p {{ font-size: 14px; color: #555; margin: 0 0 20px; }}
      form {{ display: flex; flex-direction: column; gap: 10px; }}
      .page-option {{ display: flex; flex-direction: column; gap: 2px; padding: 14px 16px;
                      border: 1px solid #dbdbdb; border-radius: 8px; background: #fff;
                      text-align: left; cursor: pointer; font: inherit; }}
      .page-option:hover {{ background: #f5f5f5; }}
      .page-name {{ font-weight: 600; }}
      .page-handle {{ color: #888; font-size: 13px; }}
    </style>
  </head>
  <body>
    <div class="card">
      <h1>Which Instagram account should FitCheck import?</h1>
      <p>{safe_message}</p>
      <div id="picker-error" style="display:none;color:#b00020;font-size:13px;margin:0 0 12px;"></div>
      <form method="post" action="{select_url}" id="picker-form">
        <input type="hidden" name="selection_token" value="{safe_token}" />
        <input type="hidden" name="provider_page_id" id="selection-input" />
        {options_html}
      </form>
    </div>
    <script>
      (function () {{
        var form = document.getElementById('picker-form');
        var buttons = document.querySelectorAll('.page-option');
        var mobileRedirectUri = {mobile_redirect_json};
        var successPayload = {success_payload_json};
        var targetOrigin = {target_origin_json};
        function finishWithError(errMessage) {{
          // Surface a picker error instead of leaving the popup open. For
          // mobile redirect clients, forward status=error; popup clients
          // postMessage the failure so the app can show it before we close.
          if (window.opener && !window.opener.closed) {{
            try {{
              window.opener.postMessage(Object.assign({{}}, successPayload,
                {{ status: 'error', message: errMessage }}), targetOrigin);
            }} catch (err) {{}}
            window.setTimeout(function () {{ window.close(); }}, 150);
          }} else if (mobileRedirectUri) {{
            var sep = mobileRedirectUri.indexOf('?') >= 0 ? '&' : '?';
            window.location.href = mobileRedirectUri + sep + 'status=error&job_id=' +
              encodeURIComponent(successPayload.job_id) + '&message=' + encodeURIComponent(errMessage);
          }} else {{
            var err = document.getElementById('picker-error');
            if (err) {{ err.textContent = errMessage; err.style.display = 'block'; }}
            buttons.forEach(function (b) {{ b.disabled = false; }});
          }}
        }}
        function finish() {{
          if (window.opener && !window.opener.closed) {{
            try {{ window.opener.postMessage(successPayload, targetOrigin); }} catch (err) {{}}
            window.setTimeout(function () {{ window.close(); }}, 150);
          }} else if (mobileRedirectUri) {{
            var sep = mobileRedirectUri.indexOf('?') >= 0 ? '&' : '?';
            window.location.href = mobileRedirectUri + sep + 'status=success&job_id=' +
              encodeURIComponent(successPayload.job_id);
          }}
        }}
        buttons.forEach(function (btn) {{
          btn.addEventListener('click', function (ev) {{
            ev.preventDefault();
            document.getElementById('selection-input').value = btn.value;
            // Submit via fetch (AJAX) and invoke finish() on success. A native
            // form.submit() navigates the popup to the JSON response body and
            // never closes it, so the app reports a login timeout. On failure
            // show the error in-page (popup) or forward it (mobile redirect).
            buttons.forEach(function (b) {{ b.disabled = true; }});
            var data = new FormData(form);
            data.set('provider_page_id', btn.value);
            fetch(form.action, {{ method: 'POST', body: data }})
              .then(function (res) {{ return res.json().then(function (body) {{
                return {{ ok: res.ok, body: body }};
              }}); }})
              .then(function (out) {{
                if (out.ok && out.body && out.body.data && out.body.data.success) {{
                  finish();
                }} else {{
                  // The API surfaces validation failures as {{error, code, details}}
                  // (FitCheckException.to_dict) — surface that message so an
                  // invalid/expired selection reaches the popup/mobile client
                  // instead of always falling back to the generic reconnect text.
                  var msg = (out.body && (out.body.error || out.body.message
                    || (out.body.detail && out.body.detail.message)))
                    || 'Could not select that account. Please reconnect.';
                  finishWithError(msg);
                }}
              }})
              .catch(function () {{
                finishWithError('Network error while selecting the account. Please reconnect.');
              }});
          }});
        }});
      }})();
    </script>
  </body>
</html>"""
    return HTMLResponse(content=html)


@router.post(
    "/social-import/jobs",
    response_model=Dict[str, Any],
    status_code=status.HTTP_202_ACCEPTED,
)
async def create_social_import_job(
    body: SocialImportStartRequest,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    if not settings.ENABLE_SOCIAL_IMPORT:
        raise HTTPException(status_code=404, detail="Social import is disabled")

    max_concurrent_jobs = max(1, int(settings.SOCIAL_IMPORT_MAX_CONCURRENT_JOBS or 1))
    normalized = SocialURLService.normalize_profile_url(body.source_url)
    try:
        job = await SocialImportJobStore.create_job(
            db,
            user_id=user_id,
            platform=normalized.platform.value,
            source_url=normalized.source_url,
            normalized_url=normalized.normalized_url,
            max_concurrent_jobs=max_concurrent_jobs,
        )
    except Exception as exc:
        # The RPC serializes admission per user and rejects only when the
        # configured limit is reached. A duplicate-key race (two concurrent
        # creates for the same user) is the same user-facing condition - an
        # active job already exists - so surface both as 429, never 500.
        message = str(exc).lower()
        if "concurrency limit reached" in message or "duplicate key value violates" in message:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=(
                    "You already have the maximum number of active social imports. "
                    "Please finish or cancel an existing job before starting a new one."
                ),
            ) from exc
        raise

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
    user_id: str = Depends(get_active_user_id),
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    if not settings.ENABLE_SOCIAL_IMPORT:
        raise HTTPException(status_code=404, detail="Social import is disabled")

    job = await SocialImportJobStore.get_job(db, job_id=job_id, user_id=user_id)
    if not job:
        raise SocialImportJobNotFoundError(job_id)

    async def event_generator():
        queue: asyncio.Queue = asyncio.Queue(maxsize=SSE_QUEUE_MAXSIZE)
        await SocialImportEventService.add_subscriber(job_id, queue)

        try:
            status_payload = await _service(user_id, db).get_status(job_id)
            connected_payload = {
                "job_id": job_id,
                "status": status_payload["status"],
                "timestamp": utcnow_iso(),
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
                if event["type"] in _TERMINAL_SSE_EVENTS:
                    return

            while True:
                try:
                    # Items are (event, size) tuples; report consumption so
                    # the byte budget tracks only buffered data.
                    event, event_size = await asyncio.wait_for(queue.get(), timeout=30)
                    note_consumed(queue, event_size)
                    max_replayed_id = event.get("id") or max_replayed_id
                    payload = {
                        "event": event["type"],
                        "data": json.dumps(event["data"]),
                    }
                    # Only locally-generated events (e.g. stream_overflow) lack
                    # a DB id; emitting "None" would poison the client's
                    # Last-Event-ID and 422 the int query param on reconnect.
                    if event.get("id") is not None:
                        payload["id"] = str(event["id"])
                    yield payload
                    if event["type"] in _TERMINAL_SSE_EVENTS:
                        break
                except asyncio.TimeoutError:
                    status_payload = await _service(user_id, db).get_status(job_id)
                    heartbeat = {
                        "job_id": job_id,
                        "timestamp": utcnow_iso(),
                        "last_event_id": max_replayed_id,
                        "status": status_payload.get("status"),
                    }
                    yield {"event": "heartbeat", "data": json.dumps(heartbeat)}
        except asyncio.CancelledError:
            # Client disconnected; no one left to receive a terminal event.
            pass
        except Exception:
            # Guarantee a terminal SSE event so clients never hang on a
            # silently-closed stream when an unexpected error occurs.
            logger.exception(
                "Unexpected error in social import SSE generator",
                extra={"job_id": job_id},
            )
            yield {
                "event": "job_failed",
                "data": json.dumps({
                    "error": "Internal error while streaming import events",
                    "timestamp": utcnow_iso(),
                }),
            }
        finally:
            await SocialImportEventService.remove_subscriber(job_id, queue)

    return EventSourceResponse(
        event_generator(),
        headers={
            "X-Accel-Buffering": "no",
            "Cache-Control": "no-cache, no-transform",
        },
        ping=15,  # SSE comment keep-alive; the app-level heartbeat (which also
                  # carries last_event_id/status) stays at 30s.
    )


@router.post("/social-import/jobs/{job_id}/auth/oauth/connect", response_model=Dict[str, Any])
async def create_oauth_connect_url(
    job_id: str,
    request: Request,
    mobile_redirect_uri: Optional[str] = Query(default=None),
    user_id: str = Depends(get_active_user_id),
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
    # Early error checks (before state parsing)
    if not settings.ENABLE_SOCIAL_IMPORT:
        return _oauth_response(
            job_id="unknown",
            status_value="error",
            message="Social import is disabled",
        )

    if not state:
        return _oauth_response(
            job_id="unknown",
            status_value="error",
            message="Missing OAuth state",
        )

    try:
        state_payload = SocialOAuthService.parse_state(state)
    except Exception as exc:
        return _oauth_response(
            job_id="unknown",
            status_value="error",
            message=str(exc),
        )

    mobile_uri = state_payload.mobile_redirect_uri
    opener = state_payload.opener_origin
    job_id = state_payload.job_id

    # OAuth provider returned an error
    if error:
        return _oauth_response(
            job_id=job_id,
            status_value="error",
            message=error_description or error,
            mobile_redirect_uri=mobile_uri,
            opener_origin=opener,
        )

    # Missing authorization code
    if not code:
        return _oauth_response(
            job_id=job_id,
            status_value="error",
            message="Missing OAuth code",
            mobile_redirect_uri=mobile_uri,
            opener_origin=opener,
        )

    # Exchange code for token and resolve identity
    try:
        redirect_uri = str(request.url_for("social_oauth_callback"))
        token_payload = await SocialOAuthService.exchange_code_for_token(
            code=code,
            redirect_uri=redirect_uri,
        )
        # A4-28: when the user has several Instagram business accounts, prefer
        # the page the connection was already bound to (provider_page_id
        # stored on the auth session from a previous connect/selection).
        preferred_page_id = None
        try:
            existing_session = await SocialAuthService.get_active_session(
                db,
                job_id=state_payload.job_id,
                user_id=state_payload.user_id,
            )
            session_payload = (existing_session or {}).get("session_payload") or {}
            preferred_page_id = session_payload.get("provider_page_id")
        except Exception as session_err:  # noqa: BLE001 - best-effort preference lookup
            logger.debug(
                "Could not load existing OAuth session for page preference",
                extra={"job_id": state_payload.job_id, "error": str(session_err)},
            )
        identity_payload = await SocialOAuthService.resolve_platform_identity(
            platform=state_payload.platform,
            access_token=token_payload["provider_access_token"],
            preferred_page_id=preferred_page_id,
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
        await service.accept_auth(job_id, "oauth", payload)
    except Exception as exc:
        # A4-28: when identity resolution found multiple business accounts,
        # surface the candidate list so the client can ask the user to select
        # an account (the message also names the accounts).
        accounts = None
        details = getattr(exc, "details", None) or {}
        if details.get("requires_page_selection") and details.get("accounts"):
            accounts = details["accounts"]
            # Persist the just-exchanged token (flagged selection_pending) so
            # the picker can complete identity resolution from the chosen page
            # WITHOUT re-doing the whole OAuth dance. Without this, first-time
            # connects with several business accounts dead-ended here: the
            # token existed only in this frame's locals and nothing could bind
            # the user's selection to it (A4-28).
            try:
                await SocialAuthService.store_selection_pending_session(
                    db,
                    job_id=job_id,
                    user_id=state_payload.user_id,
                    provider_access_token=token_payload["provider_access_token"],
                    provider_refresh_token=token_payload.get("provider_refresh_token"),
                    expires_at=token_payload.get("expires_at"),
                    candidates=details["accounts"],
                )
            except Exception as session_err:  # noqa: BLE001 - picker persistence is best-effort
                logger.warning(
                    "Could not persist pending account selection; picker will "
                    "ask the user to reconnect",
                    extra={"job_id": job_id, "error": str(session_err)},
                )
        if accounts:
            try:
                selection_token = SocialOAuthService.create_selection_token(
                    user_id=state_payload.user_id,
                    job_id=job_id,
                )
            except Exception as token_err:  # noqa: BLE001
                logger.warning(
                    "Could not sign account selection token; falling back to "
                    "reconnect flow",
                    extra={"job_id": job_id, "error": str(token_err)},
                )
                return _oauth_response(
                    job_id=job_id,
                    status_value="error",
                    message=str(exc),
                    mobile_redirect_uri=mobile_uri,
                    opener_origin=opener,
                    accounts=accounts,
                )
            return _oauth_picker_response(
                job_id=job_id,
                selection_token=selection_token,
                message=str(exc),
                accounts=accounts,
                mobile_redirect_uri=mobile_uri,
                opener_origin=opener,
                # Resolve the select-page endpoint from the request so the
                # form target carries the real /api/v1/ai mount prefix.
                select_url=str(request.url_for("select_oauth_page", job_id=job_id)),
            )
        return _oauth_response(
            job_id=job_id,
            status_value="error",
            message=str(exc),
            mobile_redirect_uri=mobile_uri,
            opener_origin=opener,
            accounts=accounts,
        )

    # Success response
    return _oauth_response(
        job_id=job_id,
        status_value="success",
        message="Social account connected. Import resumed.",
        mobile_redirect_uri=mobile_uri,
        opener_origin=opener,
    )


@router.post("/social-import/jobs/{job_id}/auth/oauth", response_model=Dict[str, Any])
async def submit_oauth_auth(
    job_id: str,
    body: SocialImportOAuthAuthRequest,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    service = _service(user_id, db)
    await service.accept_auth(job_id, "oauth", body.model_dump())
    return {
        "data": SocialImportAuthResponse(
            success=True,
            status="processing",
            message="OAuth auth accepted. Import resumed.",
        ).model_dump(),
        "message": "OK",
    }


@router.post("/social-import/jobs/{job_id}/auth/oauth/select-page", response_model=Dict[str, Any])
async def select_oauth_page(
    job_id: str,
    selection_token: str = Form(...),
    provider_page_id: str = Form(...),
    db: Client = Depends(get_db),
):
    """Complete a multi-account Instagram OAuth by selecting the page.

    The account picker (served by the callback when several business pages
    are connected) POSTs the chosen ``provider_page_id`` with a signed
    ``selection_token``. The token pins the job + user (short-TTL HMAC, same
    construction as the OAuth state) because the picker's browser context
    cannot present the app's Authorization header. Identity is resolved from
    the token persisted by the callback (``store_selection_pending_session``)
    using the selected page, then the real session is stored and the import
    resumes — no re-run of the OAuth flow (A4-28).

    Fails closed: an invalid/expired token, no pending session, a page id
    outside the candidate list, or a resolution error all return a validation
    error asking the user to reconnect.

    Single-use ordering (backend #16): an already-consumed token is rejected
    with a cheap non-destructive check BEFORE the outbound Graph API call, and
    the token is only burned immediately before ``accept_auth``. If auth
    persistence fails, the burn is released so the link stays usable.
    """
    try:
        # consume_selection_token (not parse) so the picker link is single-use:
        # the signed nonce is recorded atomically and a replay raises, which
        # stops a second submission from binding a different candidate page
        # after the job already resumed (backend #16). Validate with the
        # NON-destructive parse first so a transient failure later in this
        # handler (e.g. a Meta Graph API hiccup in resolve_platform_identity)
        # does not permanently burn a still-valid selection token — the
        # single-use consume happens only right before accept_auth.
        selection = SocialOAuthService.parse_selection_token(selection_token)
    except Exception as exc:
        raise ValidationError(
            "This account selection link has expired. Please connect your "
            "Instagram account again."
        ) from exc
    user_id = selection["user_id"]
    token_job_id = selection["job_id"]
    if token_job_id != job_id:
        raise ValidationError(
            "This account selection does not match the import. Please "
            "connect your Instagram account again."
        )

    existing_session = await SocialAuthService.get_active_session(
        db,
        job_id=job_id,
        user_id=user_id,
    )
    session_payload = (existing_session or {}).get("session_payload") or {}
    access_token = session_payload.get("provider_access_token")
    if not access_token or session_payload.get("selection_pending") is not True:
        raise ValidationError(
            "No pending account selection found. Please connect your "
            "Instagram account again."
        )

    candidates = session_payload.get("candidates") or []
    candidate_ids = {
        str(c.get("provider_page_id")) for c in candidates if c.get("provider_page_id")
    }
    if provider_page_id not in candidate_ids:
        raise ValidationError(
            "The selected page is not among the connected Instagram accounts. "
            "Please reconnect."
        )

    # Replay guard, cheap and early: a replayed (already-consumed but still
    # pending) token is rejected HERE, BEFORE the outbound Meta Graph API call
    # in resolve_platform_identity below — otherwise a replay would spend a
    # remote request on a submission that is doomed to be rejected at the burn
    # step. The actual single-use burn still happens only at the end (backend
    # #16), so a transient failure after this point does not permanently
    # consume a still-valid token.
    try:
        if SocialOAuthService.is_selection_token_consumed(selection_token):
            raise ValidationError(
                "This account selection link has already been used. Please "
                "connect your Instagram account again."
            )
    except ValidationError:
        raise
    except Exception as exc:
        raise ValidationError(
            "This account selection link has expired. Please connect your "
            "Instagram account again."
        ) from exc

    try:
        identity_payload = await SocialOAuthService.resolve_platform_identity(
            platform=SocialPlatform.INSTAGRAM,
            access_token=access_token,
            preferred_page_id=provider_page_id,
        )
    except Exception as exc:
        raise ValidationError(
            f"Could not complete account selection: {exc}"
        ) from exc

    payload = {
        "provider_access_token": access_token,
        "provider_refresh_token": session_payload.get("provider_refresh_token"),
        "provider_user_id": identity_payload.get("provider_user_id"),
        "provider_page_access_token": identity_payload.get("provider_page_access_token"),
        "provider_page_id": identity_payload.get("provider_page_id"),
        "provider_username": identity_payload.get("provider_username"),
        # The pending session stored the OAuth token expiry as an ISO string
        # (store_selection_pending_session calls expires_at.isoformat()), but
        # store_oauth_session expects a datetime and calls .isoformat() on it.
        # Parse the stored value back to a datetime before handing it through,
        # otherwise the multi-account selection path raises AttributeError.
        "expires_at": parse_utc_datetime(session_payload.get("provider_expires_at")),
    }
    # Single-use consume immediately before the write: all validations above
    # (job match, pending session, candidate membership, identity resolution)
    # passed, so only now should the token be burned. A concurrent second
    # submission that also passed the checks loses the consume here and is
    # rejected — replay protection is intact.
    try:
        SocialOAuthService.consume_selection_token(selection_token)
    except Exception as exc:
        raise ValidationError(
            "This account selection link has already been used. Please "
            "connect your Instagram account again."
        ) from exc
    service = _service(user_id, db)
    try:
        await service.accept_auth(job_id, "oauth", payload)
    except Exception:
        # The nonce was burned above but auth persistence failed: release the
        # claim so a transient backend error (a Meta hiccup on resume, a DB
        # blip) does not force the user to reconnect — the same picker link
        # stays usable. A submission that actually won the concurrent race is
        # unaffected: its nonce is already committed and release only removes
        # a nonce that failed to persist. (backend #16)
        SocialOAuthService.release_selection_token(selection_token)
        raise
    return {
        "data": SocialImportAuthResponse(
            success=True,
            status="processing",
            message="Instagram account selected. Import resumed.",
        ).model_dump(),
        "message": "OK",
    }


@router.post(
    "/social-import/jobs/{job_id}/auth/scraper-login", response_model=Dict[str, Any]
)
async def submit_scraper_login(
    job_id: str,
    body: SocialImportScraperAuthRequest,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    service = _service(user_id, db)
    await service.accept_auth(job_id, "scraper", body.model_dump())
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
    user_id: str = Depends(get_active_user_id),
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
    user_id: str = Depends(get_active_user_id),
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
    data = payload.model_dump()
    # Include the saved item ids/categories so the client can auto-create an outfit
    # from this photo's items and kick off its render.
    data["saved_items"] = result.get("saved_items", [])
    return {"data": data, "message": "Approved"}


@router.post(
    "/social-import/jobs/{job_id}/photos/{photo_id}/reject",
    response_model=Dict[str, Any],
)
async def reject_social_photo(
    job_id: str,
    photo_id: str,
    user_id: str = Depends(get_active_user_id),
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
    user_id: str = Depends(get_active_user_id),
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
