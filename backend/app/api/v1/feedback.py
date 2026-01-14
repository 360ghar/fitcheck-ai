"""
Feedback API endpoints for submitting bug reports, feature requests, and feedback.
"""
import json
import logging
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends, File, Form, Header, UploadFile, HTTPException
from supabase import Client

from app.api.v1.deps import get_current_user, get_db
from app.core.exceptions import ValidationError
from app.core.security import verify_token, TokenData
from app.models.feedback import (
    TicketCategory,
    FeedbackResponse,
    TicketListResponse,
    DeviceInfo,
    CreateFeedbackRequest,
)
from app.services.feedback_service import FeedbackService
from app.services.storage_service import StorageService

logger = logging.getLogger(__name__)

router = APIRouter()


# =============================================================================
# Helper for optional authentication
# =============================================================================


async def get_optional_user(
    db: Client = Depends(get_db),
    authorization: Optional[str] = Header(None),
) -> Optional[dict]:
    """Get user if authenticated, otherwise return None."""
    if not authorization or not authorization.startswith("Bearer "):
        return None
    try:
        token = authorization.split(" ", 1)[1]
        from app.core.security import decode_token
        token_data = decode_token(token)
        user = db.table("users").select("*").eq("id", token_data.sub).single().execute()
        return user.data if user.data else None
    except Exception:
        return None


# =============================================================================
# Feedback Endpoints
# =============================================================================


@router.post("", response_model=Dict[str, Any])
async def submit_feedback(
    category: TicketCategory = Form(...),
    subject: str = Form(..., min_length=3, max_length=200),
    description: str = Form(..., min_length=10, max_length=5000),
    contact_email: Optional[str] = Form(None),
    device_info: Optional[str] = Form(None),  # JSON string
    app_version: Optional[str] = Form(None),
    app_platform: Optional[str] = Form(None),
    attachments: List[UploadFile] = File(default=[]),
    user: Optional[dict] = Depends(get_optional_user),
    db: Client = Depends(get_db),
):
    """
    Submit feedback, bug report, or feature request.

    Accepts both authenticated and anonymous submissions.
    Supports up to 5 screenshot attachments (max 5MB each).
    """
    user_id = user.get("id") if user else None

    # Validate attachments
    if len(attachments) > 5:
        raise ValidationError("Maximum 5 attachments allowed")

    # Upload attachments
    attachment_urls: List[str] = []
    for attachment in attachments:
        if attachment.filename:
            # Read file data
            file_data = await attachment.read()

            # Validate file size (5MB max)
            if len(file_data) > 5 * 1024 * 1024:
                raise ValidationError(f"Attachment {attachment.filename} exceeds 5MB limit")

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
