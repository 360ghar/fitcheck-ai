"""
Feedback API endpoints for submitting bug reports, feature requests, and feedback.
"""
import json
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends, File, Form, Query, Request, UploadFile
from pydantic import EmailStr, TypeAdapter
from supabase import Client

from app.api.v1.deps import get_current_user, get_db
from app.core.exceptions import ValidationError
from app.core.ip_rate_limit import auth_rate_limited_operation
from app.core.logging_config import get_context_logger
from app.core.security import get_optional_user_id
from app.core.uploads import read_upload_capped
from app.models.feedback import (
    TicketCategory,
    DeviceInfo,
    CreateFeedbackRequest,
)
from app.services.feedback_service import FeedbackService
from app.services.storage_service import StorageService

logger = get_context_logger(__name__)

router = APIRouter()

# Per-attachment cap. Enforced during the read (see read_upload_capped) so an
# oversized upload is rejected before its bytes are buffered in memory.
MAX_ATTACHMENT_BYTES = 5 * 1024 * 1024


# =============================================================================
# Feedback Endpoints
# =============================================================================


@router.post("", response_model=Dict[str, Any])
async def submit_feedback(
    http_request: Request,
    category: TicketCategory = Form(...),
    subject: str = Form(..., min_length=3, max_length=200),
    description: str = Form(..., min_length=10, max_length=5000),
    contact_email: Optional[str] = Form(None),
    device_info: Optional[str] = Form(None),  # JSON string
    app_version: Optional[str] = Form(None),
    app_platform: Optional[str] = Form(None),
    attachments: List[UploadFile] = File(default=[]),
    user_id: Optional[str] = Depends(get_optional_user_id),
    db: Client = Depends(get_db),
):
    """
    Submit feedback, bug report, or feature request.

    Accepts both authenticated and anonymous submissions, so it is IP rate
    limited. Supports up to 5 screenshot attachments (max 5MB each).
    """
    async with auth_rate_limited_operation(http_request, "feedback submission"):
        return await _create_feedback_ticket(
            category=category,
            subject=subject,
            description=description,
            contact_email=contact_email,
            device_info=device_info,
            app_version=app_version,
            app_platform=app_platform,
            attachments=attachments,
            user_id=user_id,
            db=db,
        )


async def _create_feedback_ticket(
    *,
    category: TicketCategory,
    subject: str,
    description: str,
    contact_email: Optional[str],
    device_info: Optional[str],
    app_version: Optional[str],
    app_platform: Optional[str],
    attachments: List[UploadFile],
    user_id: Optional[str],
    db: Client,
) -> Dict[str, Any]:
    # Validate attachments
    if len(attachments) > 5:
        raise ValidationError("Maximum 5 attachments allowed")

    # B3-01: contact_email arrives as a plain Form string (FastAPI cannot
    # apply EmailStr to a Form field), so a malformed address used to surface
    # as a raw pydantic ValidationError → 500 when CreateFeedbackRequest was
    # built below. Validate at the boundary with the app's ValidationError
    # (422); an empty string is treated as absent.
    if contact_email is not None and contact_email.strip():
        try:
            TypeAdapter(EmailStr).validate_python(contact_email.strip())
        except Exception:
            raise ValidationError(
                "Invalid contact email",
                details={"field": "contact_email"},
            )
        contact_email = contact_email.strip()
    elif contact_email is not None:
        contact_email = None

    # Upload attachments. A4-24: track per-attachment status so the client
    # learns which files were actually stored (the old code swallowed upload
    # failures and told the user everything was OK).
    attachment_results: List[Dict[str, Any]] = []
    attachment_urls: List[str] = []
    attachment_storage_paths: List[str] = []
    for attachment in attachments:
        entry: Dict[str, Any] = {"filename": attachment.filename, "uploaded": False, "error": None}
        if attachment.filename:
            try:
                # Rejects before buffering past the cap, unlike read()-then-check.
                file_data = await read_upload_capped(attachment, MAX_ATTACHMENT_BYTES)

                # Upload to storage
                result = await StorageService.upload_feedback_attachment(
                    db=db,
                    user_id=user_id or "anonymous",
                    filename=attachment.filename,
                    file_data=file_data,
                )
                attachment_urls.append(result["image_url"])
                # Record the durable bucket key so the object can be cleaned up
                # during account deletion / orphan inventory. The URL alone is a
                # short-lived presigned URL and must NEVER be the durable ref.
                storage_path = result.get("storage_path")
                if storage_path:
                    attachment_storage_paths.append(storage_path)
                entry["uploaded"] = True
            except Exception as e:
                logger.warning(f"Failed to upload attachment: {e}")
                entry["error"] = str(e)[:200]
        else:
            entry["error"] = "empty filename"
        attachment_results.append(entry)

    # A4-24: attachments are best-effort - an upload failure must not reject
    # the ticket (the user's report still reaches support). The per-attachment
    # status entries below tell the client exactly which files were stored and
    # which failed, instead of the old behavior of claiming success for all.
    # Parse device info if provided
    parsed_device_info = None
    if device_info:
        try:
            info_dict = json.loads(device_info)
            parsed_device_info = DeviceInfo(**info_dict)
        except Exception:
            pass

    # Create the request object
    request = CreateFeedbackRequest(
        category=category,
        subject=subject,
        description=description,
        contact_email=contact_email if not user_id else None,
        device_info=parsed_device_info,
        app_version=app_version,
        app_platform=app_platform,
    )

    # Create ticket. A4-24: when the ticket insert fails, clean up the
    # uploaded objects so they do not orphan in storage (best-effort).
    try:
        result = await FeedbackService.create_ticket(
            request=request,
            user_id=user_id,
            attachment_urls=attachment_urls,
            attachment_storage_paths=attachment_storage_paths,
            db=db,
        )
    except Exception:
        if attachment_storage_paths:
            try:
                await StorageService.delete_temp_objects(attachment_storage_paths)
            except Exception as cleanup_err:
                logger.warning(
                    "Failed to clean up feedback attachments after ticket insert failure: %s",
                    cleanup_err,
                )
        raise

    return {
        "data": result.model_dump(mode="json"),
        "attachments": attachment_results,
        "message": "OK",
    }


@router.get("/my-tickets", response_model=Dict[str, Any])
async def get_my_tickets(
    # A4-08: negatives flow into PostgREST's .range() and 500; clamp at the
    # boundary instead.
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    user=Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Get the current user's submitted tickets.

    Requires authentication.
    """
    result = await FeedbackService.get_user_tickets(
        user_id=user["id"],
        db=db,
        limit=min(limit, 50),
        offset=offset,
    )

    return {"data": result.model_dump(mode="json"), "message": "OK"}
