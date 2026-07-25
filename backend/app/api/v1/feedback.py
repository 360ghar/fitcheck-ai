"""
Feedback API endpoints for submitting bug reports, feature requests, and feedback.
"""
import json
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends, File, Form, Request, UploadFile
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

    # Upload attachments
    attachment_urls: List[str] = []
    for attachment in attachments:
        if attachment.filename:
            # Rejects before buffering past the cap, unlike read()-then-check.
            file_data = await read_upload_capped(attachment, MAX_ATTACHMENT_BYTES)

            # Upload to storage
            try:
                result = await StorageService.upload_feedback_attachment(
                    db=db,
                    user_id=user_id or "anonymous",
                    filename=attachment.filename,
                    file_data=file_data,
                )
                attachment_urls.append(result["image_url"])
            except Exception as e:
                logger.warning(f"Failed to upload attachment: {e}")
                # Continue without this attachment

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

    # Create ticket
    result = await FeedbackService.create_ticket(
        request=request,
        user_id=user_id,
        attachment_urls=attachment_urls,
        db=db,
    )

    return {"data": result.model_dump(mode="json"), "message": "OK"}


@router.get("/my-tickets", response_model=Dict[str, Any])
async def get_my_tickets(
    limit: int = 20,
    offset: int = 0,
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
