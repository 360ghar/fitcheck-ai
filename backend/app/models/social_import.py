"""
Pydantic models for social URL import queue.
"""

from __future__ import annotations

from datetime import datetime
from enum import Enum
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field


class SocialPlatform(str, Enum):
    INSTAGRAM = "instagram"
    FACEBOOK = "facebook"


class SocialImportJobStatus(str, Enum):
    CREATED = "created"
    DISCOVERING = "discovering"
    AWAITING_AUTH = "awaiting_auth"
    PROCESSING = "processing"
    PAUSED_RATE_LIMITED = "paused_rate_limited"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    FAILED = "failed"


class SocialImportPhotoStatus(str, Enum):
    QUEUED = "queued"
    PROCESSING = "processing"
    AWAITING_REVIEW = "awaiting_review"
    BUFFERED_READY = "buffered_ready"
    APPROVED = "approved"
    REJECTED = "rejected"
    FAILED = "failed"


class SocialImportItemStatus(str, Enum):
    GENERATED = "generated"
    EDITED = "edited"
    FAILED = "failed"
    SAVED = "saved"
    DISCARDED = "discarded"


class SocialAuthType(str, Enum):
    OAUTH = "oauth"
    SCRAPER = "scraper"


class SocialImportStartRequest(BaseModel):
    source_url: str = Field(..., min_length=10, max_length=2048)


class SocialImportJobResponse(BaseModel):
    job_id: str
    status: SocialImportJobStatus
    platform: SocialPlatform
    source_url: str
    normalized_url: str
    message: str


class SocialImportOAuthAuthRequest(BaseModel):
    provider_access_token: str = Field(..., min_length=10)
    provider_refresh_token: Optional[str] = None
    provider_user_id: Optional[str] = None
    provider_page_access_token: Optional[str] = None
    provider_page_id: Optional[str] = None
    provider_username: Optional[str] = None
    expires_at: Optional[datetime] = None


class SocialImportOAuthConnectResponse(BaseModel):
    auth_url: str
    expires_in_seconds: int
    provider: str = "meta"


class SocialImportScraperAuthRequest(BaseModel):
    username: str = Field(..., min_length=2, max_length=255)
    password: str = Field(..., min_length=1, max_length=255)
    otp_code: Optional[str] = Field(None, min_length=4, max_length=12)


class SocialImportAuthResponse(BaseModel):
    success: bool
    status: SocialImportJobStatus
    message: str


class SocialImportItemPatchRequest(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    category: Optional[str] = Field(None, max_length=50)
    sub_category: Optional[str] = Field(None, max_length=50)
    colors: Optional[List[str]] = None
    material: Optional[str] = Field(None, max_length=50)
    pattern: Optional[str] = Field(None, max_length=50)
    brand: Optional[str] = Field(None, max_length=100)
    detailed_description: Optional[str] = None


class SocialImportActionResponse(BaseModel):
    success: bool
    job_id: str
    photo_id: Optional[str] = None
    status: Optional[str] = None
    message: str


class SocialImportPhotoItemResponse(BaseModel):
    id: str
    temp_id: str
    name: Optional[str] = None
    category: str
    sub_category: Optional[str] = None
    colors: List[str] = Field(default_factory=list)
    material: Optional[str] = None
    pattern: Optional[str] = None
    brand: Optional[str] = None
    confidence: float = 0
    bounding_box: Optional[Dict[str, float]] = None
    detailed_description: Optional[str] = None
    generated_image_url: Optional[str] = None
    generated_storage_path: Optional[str] = None
    generation_error: Optional[str] = None
    status: SocialImportItemStatus


class SocialImportPhotoResponse(BaseModel):
    id: str
    ordinal: int
    source_photo_url: str
    source_thumb_url: Optional[str] = None
    status: SocialImportPhotoStatus
    error_message: Optional[str] = None
    items: List[SocialImportPhotoItemResponse] = Field(default_factory=list)


class SocialImportJobStatusResponse(BaseModel):
    id: str
    status: SocialImportJobStatus
    platform: SocialPlatform
    source_url: str
    normalized_url: str
    total_photos: int = 0
    discovered_photos: int = 0
    processed_photos: int = 0
    approved_photos: int = 0
    rejected_photos: int = 0
    failed_photos: int = 0
    auth_required: bool = False
    discovery_completed: bool = False
    error_message: Optional[str] = None
    awaiting_review_photo: Optional[SocialImportPhotoResponse] = None
    buffered_photo: Optional[SocialImportPhotoResponse] = None
    processing_photo: Optional[SocialImportPhotoResponse] = None
    queued_count: int = 0


class SocialImportEventType(str, Enum):
    CONNECTED = "connected"
    JOB_UPDATED = "job_updated"
    PHOTO_DISCOVERED = "photo_discovered"
    PHOTO_PROCESSING_STARTED = "photo_processing_started"
    PHOTO_READY_FOR_REVIEW = "photo_ready_for_review"
    PHOTO_BUFFERED_READY = "photo_buffered_ready"
    PHOTO_APPROVED = "photo_approved"
    PHOTO_REJECTED = "photo_rejected"
    PHOTO_FAILED = "photo_failed"
    AUTH_REQUIRED = "auth_required"
    AUTH_ACCEPTED = "auth_accepted"
    RATE_LIMIT_PAUSED = "rate_limit_paused"
    JOB_COMPLETED = "job_completed"
    JOB_FAILED = "job_failed"
    JOB_CANCELLED = "job_cancelled"
    HEARTBEAT = "heartbeat"


class SocialImportSSEEvent(BaseModel):
    event: SocialImportEventType
    data: Dict[str, Any] = Field(default_factory=dict)


class ScrapedPhotoRef(BaseModel):
    source_photo_id: Optional[str] = None
    source_photo_url: str
    source_thumb_url: Optional[str] = None
    source_taken_at: Optional[datetime] = None
    metadata: Dict[str, Any] = Field(default_factory=dict)


class DiscoverPhotosResult(BaseModel):
    requires_auth: bool = False
    photos: List[ScrapedPhotoRef] = Field(default_factory=list)
    next_cursor: Optional[str] = None
    exhausted: bool = True
    metadata: Dict[str, Any] = Field(default_factory=dict)
