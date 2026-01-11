"""
Instagram Pydantic models for validation and serialization.

Models for Instagram URL validation, scraping, and image import.
"""

from datetime import datetime
from enum import Enum
from typing import List, Optional

from pydantic import BaseModel, Field


# =============================================================================
# ENUMS
# =============================================================================


class InstagramURLType(str, Enum):
    """Type of Instagram URL."""
    PROFILE = "profile"
    POST = "post"
    REEL = "reel"


class InstagramScrapeStatus(str, Enum):
    """Status of an Instagram scrape job."""
    PENDING = "pending"
    VALIDATING = "validating"
    SCRAPING = "scraping"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    FAILED = "failed"


# =============================================================================
# URL VALIDATION MODELS
# =============================================================================


class InstagramURLRequest(BaseModel):
    """Request to validate an Instagram URL."""
    url: str = Field(..., description="Instagram URL to validate")


class InstagramURLValidation(BaseModel):
    """Response from URL validation."""
    valid: bool
    url_type: Optional[InstagramURLType] = None
    identifier: Optional[str] = None  # Username or shortcode
    error: Optional[str] = None


# =============================================================================
# PROFILE MODELS
# =============================================================================


class InstagramProfileRequest(BaseModel):
    """Request to check an Instagram profile."""
    username: str = Field(..., description="Instagram username")


class InstagramProfileInfo(BaseModel):
    """Basic profile information."""
    username: str
    is_public: bool
    post_count: int = 0
    profile_pic_url: Optional[str] = None
    full_name: Optional[str] = None
    bio: Optional[str] = None
    error: Optional[str] = None


# =============================================================================
# SCRAPED IMAGE MODELS
# =============================================================================


class InstagramImageMeta(BaseModel):
    """Metadata for a scraped Instagram image."""
    image_id: str  # Unique ID (shortcode + index)
    image_url: str  # CDN URL for full image
    thumbnail_url: Optional[str] = None  # CDN URL for thumbnail
    post_shortcode: str  # Instagram post shortcode
    post_url: str  # Full URL to the post
    caption: Optional[str] = None
    timestamp: Optional[datetime] = None
    is_video: bool = False
    width: Optional[int] = None
    height: Optional[int] = None


# =============================================================================
# SCRAPE JOB MODELS
# =============================================================================


class InstagramScrapeRequest(BaseModel):
    """Request to start an Instagram scrape job."""
    url: str = Field(..., description="Instagram URL (profile or post)")
    max_posts: int = Field(200, ge=1, le=500, description="Max posts to scrape for profiles")


class InstagramScrapeJobResponse(BaseModel):
    """Response from starting a scrape job."""
    job_id: str
    status: str
    url_type: InstagramURLType
    identifier: str
    sse_url: str
    message: str


class InstagramScrapeResult(BaseModel):
    """Result from a completed scrape job."""
    job_id: str
    status: str
    images: List[InstagramImageMeta] = Field(default_factory=list)
    total_found: int = 0
    has_more: bool = False
    error: Optional[str] = None


# =============================================================================
# BATCH PREPARATION MODELS
# =============================================================================


class InstagramBatchRequest(BaseModel):
    """Request to prepare Instagram images for batch extraction."""
    job_id: str = Field(..., description="Instagram scrape job ID")
    selected_image_ids: List[str] = Field(
        ...,
        min_length=1,
        max_length=50,
        description="List of image IDs to process"
    )


class InstagramBatchResponse(BaseModel):
    """Response from preparing Instagram batch."""
    batch_job_id: str
    sse_url: str
    image_count: int
    message: str


# =============================================================================
# SSE EVENT DATA MODELS
# =============================================================================


class InstagramScrapeProgressData(BaseModel):
    """Data for scrape progress SSE event."""
    scraped: int
    total: int
    images: List[InstagramImageMeta] = Field(default_factory=list)


class InstagramScrapeCompleteData(BaseModel):
    """Data for scrape complete SSE event."""
    total_images: int
    has_more: bool


# =============================================================================
# AUTHENTICATION MODELS
# =============================================================================


class InstagramLoginRequest(BaseModel):
    """Request to login to Instagram."""
    username: str = Field(..., min_length=1, description="Instagram username")
    password: str = Field(..., min_length=1, description="Instagram password")


class InstagramLoginResponse(BaseModel):
    """Response from Instagram login."""
    success: bool
    username: Optional[str] = None
    error: Optional[str] = None


class InstagramCredentialsStatus(BaseModel):
    """Status of stored Instagram credentials."""
    has_credentials: bool
    is_valid: bool = False
    username: Optional[str] = None
    last_used: Optional[datetime] = None
