"""
Shared outfit feedback routes.

Enables public or authenticated feedback on shared outfits.
"""

from datetime import datetime, timezone
from typing import Any, Dict, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, status
from pydantic import BaseModel, Field
from supabase import Client

from app.core.exceptions import (
    DatabaseError,
    FitCheckException,
    PermissionDeniedError,
    SharedOutfitNotFoundError,
)
from app.core.logging_config import get_context_logger
from app.core.security import get_optional_user_id
from app.db.connection import get_db

logger = get_context_logger(__name__)

router = APIRouter()


class ShareFeedbackRequest(BaseModel):
    rating: int = Field(..., ge=1, le=5)
    comment: Optional[str] = None


class ShareExpiredError(FitCheckException):
    """Raised when a share link has expired."""

    status_code = status.HTTP_410_GONE
    error_code = "SHARE_EXPIRED"

    def __init__(self, share_id: Optional[str] = None):
        super().__init__(
            message="Share link has expired",
            details={"share_id": share_id} if share_id else None,
        )


def _parse_iso_datetime(value: Optional[str]) -> Optional[datetime]:
    if not value:
        return None
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
        if parsed.tzinfo is None:
            return parsed.replace(tzinfo=timezone.utc)
        return parsed
    except ValueError:
        return None


@router.post("/{share_id}/feedback", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def submit_feedback(
    share_id: UUID,
    request: ShareFeedbackRequest,
    user_id: Optional[str] = Depends(get_optional_user_id),
    db: Client = Depends(get_db),
):
    try:
        share_id_str = str(share_id)
        share = (
            db.table("shared_outfits")
            .select("id, allow_feedback, expires_at")
            .eq("id", share_id_str)
            .single()
            .execute()
        )
        if not share.data:
            raise SharedOutfitNotFoundError(share_id=share_id_str)

        if share.data.get("allow_feedback") is False:
            raise PermissionDeniedError(
                message="Feedback is disabled for this shared outfit",
                resource_type="shared_outfit"
            )

        expires_at = _parse_iso_datetime(share.data.get("expires_at"))
        if expires_at and expires_at < datetime.now(timezone.utc):
            raise ShareExpiredError(share_id=share_id_str)

        insert = {
            "shared_outfit_id": share_id_str,
            "user_id": user_id,
            "rating": request.rating,
            "comment": request.comment,
        }
        res = db.table("share_feedback").insert(insert).execute()
        row = (res.data or [None])[0]
        if not row:
            raise DatabaseError(
                message="Failed to submit feedback",
                operation="submit_feedback"
            )

        logger.info(
            "Feedback submitted for shared outfit",
            share_id=share_id_str,
            user_id=user_id,
            rating=request.rating
        )
        return {"data": row, "message": "Created"}
    except (SharedOutfitNotFoundError, PermissionDeniedError, ShareExpiredError, DatabaseError):
        raise
    except Exception as e:
        logger.error(
            "Submit feedback error",
            share_id=str(share_id),
            user_id=user_id,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to submit feedback",
            operation="submit_feedback"
        )
