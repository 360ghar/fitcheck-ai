"""
Waitlist API routes.

Public endpoint for mobile app waitlist signups.
"""

from typing import Any, Dict, Optional

from fastapi import APIRouter, Depends, status
from pydantic import BaseModel, EmailStr, Field
from supabase import Client
from postgrest.exceptions import APIError as PostgrestAPIError

from app.core.exceptions import (
    DatabaseError,
    ValidationError,
)
from app.core.logging_config import get_context_logger
from app.db.connection import get_db

logger = get_context_logger(__name__)

router = APIRouter()


# ============================================================================
# REQUEST/RESPONSE MODELS
# ============================================================================


class WaitlistJoinRequest(BaseModel):
    """Request to join the mobile app waitlist."""
    email: EmailStr
    full_name: Optional[str] = Field(None, max_length=255)


class WaitlistJoinResponse(BaseModel):
    """Response after joining waitlist."""
    id: str
    email: str
    full_name: Optional[str]
    created_at: str


# ============================================================================
# CUSTOM EXCEPTIONS
# ============================================================================


class EmailAlreadyOnWaitlistError(ValidationError):
    """Raised when email is already on the waitlist."""

    error_code = "WAITLIST_EMAIL_EXISTS"

    def __init__(self):
        super().__init__(
            message="This email is already on the waitlist",
            details={"field": "email"}
        )


# ============================================================================
# ENDPOINTS
# ============================================================================


@router.post("/join", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def join_waitlist(
    request: WaitlistJoinRequest,
    db: Client = Depends(get_db),
):
    """
    Join the mobile app waitlist.

    Public endpoint - no authentication required.
    """
    try:
        # Insert waitlist entry
        insert_data = {
            "email": request.email,
            "full_name": request.full_name,
            "source": "landing_page",
        }

        result = db.table("waitlist").insert(insert_data).execute()

        if not result.data:
            raise DatabaseError(
                message="Failed to join waitlist",
                operation="insert_waitlist"
            )

        entry = result.data[0]

        logger.info(
            "User joined waitlist",
            email=request.email,
            waitlist_id=entry.get("id")
        )

        return {
            "data": {
                "id": entry.get("id"),
                "email": entry.get("email"),
                "full_name": entry.get("full_name"),
                "created_at": entry.get("created_at"),
            },
            "message": "Successfully joined the waitlist! We'll notify you when the mobile app launches.",
        }

    except PostgrestAPIError as e:
        error_info = getattr(e, 'json', lambda: {})() or {}
        code = error_info.get('code') or getattr(e, 'code', None)
        message = error_info.get('message', str(e))

        # Handle unique constraint violation (duplicate email)
        if code == '23505' or 'waitlist_email_unique' in message:
            raise EmailAlreadyOnWaitlistError()

        logger.error(
            "Waitlist join error",
            email=request.email,
            error=str(e)
        )
        raise DatabaseError(
            message="Failed to join waitlist",
            operation="insert_waitlist"
        )

    except (EmailAlreadyOnWaitlistError, DatabaseError):
        raise

    except Exception as e:
        logger.error(
            "Unexpected waitlist join error",
            email=request.email,
            error=str(e)
        )
        raise DatabaseError(
            message="An error occurred while joining the waitlist",
            operation="insert_waitlist"
        )
