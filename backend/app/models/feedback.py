"""
Feedback/Support Ticket models for FitCheck AI.
"""
from datetime import datetime
from enum import Enum
from typing import Optional, List
from uuid import UUID

from pydantic import BaseModel, Field, EmailStr


class TicketCategory(str, Enum):
    """Support ticket categories."""
    BUG_REPORT = "bug_report"
    FEATURE_REQUEST = "feature_request"
    GENERAL_FEEDBACK = "general_feedback"
    SUPPORT_REQUEST = "support_request"


class TicketStatus(str, Enum):
    """Ticket status values."""
    OPEN = "open"
    IN_PROGRESS = "in_progress"
    RESOLVED = "resolved"
    CLOSED = "closed"


class DeviceInfo(BaseModel):
    """Device/browser information for context."""
    platform: Optional[str] = None  # 'web', 'ios', 'android'
    os_version: Optional[str] = None
    device_model: Optional[str] = None
    browser: Optional[str] = None
    screen_size: Optional[str] = None


class CreateFeedbackRequest(BaseModel):
    """Request to create a new feedback/support ticket."""
    category: TicketCategory
    subject: str = Field(..., min_length=3, max_length=200)
    description: str = Field(..., min_length=10, max_length=5000)
    contact_email: Optional[EmailStr] = None  # For anonymous submissions
    device_info: Optional[DeviceInfo] = None
    app_version: Optional[str] = Field(None, max_length=50)
    app_platform: Optional[str] = Field(None, max_length=20)  # 'web', 'ios', 'android'


class FeedbackResponse(BaseModel):
    """Response after creating feedback."""
    id: UUID
    category: TicketCategory
    subject: str
    status: TicketStatus
    created_at: datetime
    message: str = "Thank you for your feedback!"

    class Config:
        from_attributes = True


class TicketListItem(BaseModel):
    """Ticket in list view."""
    id: UUID
    category: TicketCategory
    subject: str
    status: TicketStatus
    created_at: datetime


class TicketListResponse(BaseModel):
    """List of user's tickets."""
    tickets: List[TicketListItem]
    total: int
