"""
Demo feature models.

Pydantic models for public demo endpoints (no authentication required).
"""

from typing import List, Optional

from pydantic import BaseModel, Field


# =============================================================================
# REQUEST MODELS
# =============================================================================


class DemoExtractItemsRequest(BaseModel):
    """Request to extract items from image (demo mode)."""

    image: str = Field(
        ...,
        description="Base64-encoded image data",
        max_length=10_000_000,  # ~7.5MB limit
    )


class DemoTryOnRequest(BaseModel):
    """Request for virtual try-on (demo mode)."""

    person_image: str = Field(
        ...,
        description="Base64-encoded person photo",
        max_length=10_000_000,
    )
    clothing_image: str = Field(
        ...,
        description="Base64-encoded clothing photo",
        max_length=10_000_000,
    )
    clothing_description: Optional[str] = Field(
        None,
        description="Optional description of the clothing",
        max_length=500,
    )
    style: str = Field(
        default="casual",
        description="Overall style (casual, formal, etc.)",
        max_length=50,
    )


# =============================================================================
# RESPONSE MODELS
# =============================================================================


class DemoDetectedItem(BaseModel):
    """A single item detected in demo mode."""

    category: str = Field(..., description="Main category (tops, bottoms, etc.)")
    sub_category: Optional[str] = Field(
        None, description="Sub-category (t-shirt, jeans, etc.)"
    )
    colors: List[str] = Field(default_factory=list, description="Detected colors")
    material: Optional[str] = Field(None, description="Material type")
    pattern: Optional[str] = Field(None, description="Pattern (solid, striped, etc.)")
    confidence: float = Field(
        ..., ge=0.0, le=1.0, description="Detection confidence (0-1)"
    )
    detailed_description: Optional[str] = Field(
        None, description="Detailed description of the item"
    )


class DemoExtractItemsResponse(BaseModel):
    """Response from demo item extraction."""

    items: List[DemoDetectedItem] = Field(
        default_factory=list, description="List of detected items"
    )
    overall_confidence: float = Field(
        ..., ge=0.0, le=1.0, description="Overall detection confidence"
    )
    image_description: str = Field(..., description="Description of the image")
    item_count: int = Field(..., ge=0, description="Number of items detected")


class DemoTryOnResponse(BaseModel):
    """Response from demo try-on."""

    image_base64: str = Field(..., description="Generated try-on image in base64")
    prompt: str = Field(..., description="AI prompt used for generation")


# =============================================================================
# RATE LIMIT INFO MODELS
# =============================================================================


class DemoRateLimitInfo(BaseModel):
    """Rate limit information for demo features."""

    used: int = Field(..., description="Number of requests used")
    limit: int = Field(..., description="Maximum requests allowed")
    remaining: int = Field(..., description="Remaining requests")


class DemoUsageStatsResponse(BaseModel):
    """Usage stats for demo features."""

    extraction: DemoRateLimitInfo
    try_on: DemoRateLimitInfo
