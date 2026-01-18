"""
Pydantic models for AI Photoshoot Generator feature.
"""

from enum import Enum
from typing import List, Optional
from datetime import datetime, date

from pydantic import BaseModel, Field, field_validator


class PhotoshootUseCase(str, Enum):
    """Predefined use cases for photoshoot generation."""
    LINKEDIN = "linkedin"
    DATING_APP = "dating_app"
    MODEL_PORTFOLIO = "model_portfolio"
    INSTAGRAM = "instagram"
    AESTHETIC = "aesthetic"
    CUSTOM = "custom"


class PhotoshootStatus(str, Enum):
    """Status of a photoshoot generation session."""
    PENDING = "pending"
    GENERATING = "generating"
    COMPLETE = "complete"
    FAILED = "failed"


# =============================================================================
# Request Models
# =============================================================================


# Maximum size for a single base64-encoded photo (10MB encoded, ~7.5MB decoded)
MAX_PHOTO_SIZE = 10 * 1024 * 1024


class StartPhotoshootRequest(BaseModel):
    """Request to start a photoshoot generation session."""
    photos: List[str] = Field(
        ...,
        min_length=1,
        max_length=4,
        description="Base64-encoded reference photos (1-4, max 10MB each)",
    )
    use_case: PhotoshootUseCase = Field(
        ...,
        description="The use case for the photoshoot",
    )
    custom_prompt: Optional[str] = Field(
        None,
        max_length=500,
        description="Custom prompt for 'custom' use case",
    )
    num_images: int = Field(
        default=10,
        ge=1,
        le=10,
        description="Number of images to generate (1-10)",
    )

    @field_validator("photos")
    @classmethod
    def validate_photo_sizes(cls, v: List[str]) -> List[str]:
        """Validate that each photo is within size limits."""
        for i, photo in enumerate(v):
            if len(photo) > MAX_PHOTO_SIZE:
                raise ValueError(
                    f"Photo {i + 1} exceeds maximum size of 10MB"
                )
        return v


class DemoPhotoshootRequest(BaseModel):
    """Request for demo photoshoot (anonymous, limited to 2 images)."""
    photo: str = Field(
        ...,
        max_length=MAX_PHOTO_SIZE,
        description="Base64-encoded reference photo (max 10MB)",
    )
    use_case: PhotoshootUseCase = Field(
        default=PhotoshootUseCase.AESTHETIC,
        description="The use case for the photoshoot (no custom allowed)",
    )


# =============================================================================
# Response Models
# =============================================================================


class GeneratedImage(BaseModel):
    """A single generated photoshoot image."""
    id: str
    index: int = Field(..., ge=0, le=9)
    image_url: Optional[str] = None
    image_base64: Optional[str] = None
    storage_path: Optional[str] = None


class PhotoshootUsage(BaseModel):
    """User's photoshoot usage for the current day."""
    used_today: int = Field(..., ge=0)
    limit_today: int = Field(..., ge=0)
    remaining: int = Field(..., ge=0)
    plan_type: str
    resets_at: Optional[datetime] = None


class PhotoshootResultResponse(BaseModel):
    """Full photoshoot generation result."""
    session_id: str
    status: PhotoshootStatus
    images: List[GeneratedImage] = Field(default_factory=list)
    usage: Optional[PhotoshootUsage] = None
    generation_time_seconds: Optional[float] = None
    error: Optional[str] = None


class DemoPhotoshootResponse(BaseModel):
    """Response for demo photoshoot (anonymous users)."""
    session_id: str
    status: PhotoshootStatus
    images: List[GeneratedImage] = Field(default_factory=list)
    remaining_today: int = Field(..., ge=0)
    signup_cta: str = "Sign up for 10 free images per day!"


class UseCaseInfo(BaseModel):
    """Information about a photoshoot use case."""
    id: str
    name: str
    description: str
    example_prompts: List[str] = Field(default_factory=list)


class UseCasesResponse(BaseModel):
    """Response containing all available use cases."""
    use_cases: List[UseCaseInfo] = Field(default_factory=list)


# =============================================================================
# Internal Models (for prompt generation)
# =============================================================================


class PhotoshootPrompt(BaseModel):
    """A single prompt specification for image generation."""
    index: int = Field(..., ge=0, le=9)
    setting: str = Field(..., description="The setting/location for the photo")
    outfit: str = Field(..., description="The outfit description")
    pose: str = Field(..., description="The pose description")
    lighting: str = Field(..., description="The lighting description")
    style: str = Field(..., description="The overall style")
    mood: str = Field(..., description="The mood/emotion")
    full_prompt: str = Field(..., description="The complete prompt for generation")


class GeneratedPromptsResponse(BaseModel):
    """Response from LLM prompt generation."""
    prompts: List[PhotoshootPrompt]
