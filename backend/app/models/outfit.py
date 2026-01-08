"""
Outfit Pydantic models for validation and serialization.
"""

from pydantic import BaseModel, Field, field_validator
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime
from enum import Enum


# Valid outfit styles/occasions
VALID_STYLES = [
    'casual', 'formal', 'business', 'sporty',
    'bohemian', 'streetwear', 'vintage', 'minimalist',
    'romantic', 'edgy', 'preppy', 'artsy', 'other'
]

# Valid seasons
VALID_SEASONS = ['spring', 'summer', 'fall', 'winter', 'all-season']


class GenerationStatus(str, Enum):
    """Status of AI outfit generation."""
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


# ============================================================================
# OUTFIT IMAGE MODELS
# ============================================================================


class OutfitImageBase(BaseModel):
    """Base model for outfit images."""
    image_url: str
    thumbnail_url: Optional[str] = None
    storage_path: Optional[str] = None
    pose: str = Field(..., min_length=1, max_length=50)
    lighting: Optional[str] = Field(None, max_length=50)
    body_profile_id: Optional[UUID] = None
    generation_type: Optional[str] = Field(default="ai", max_length=20)
    is_primary: Optional[bool] = True
    width: Optional[int] = None
    height: Optional[int] = None
    generation_metadata: Optional[Dict[str, Any]] = None  # prompt/model/version/etc


class OutfitImage(OutfitImageBase):
    """Complete outfit image model."""
    id: UUID
    outfit_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True


# ============================================================================
# OUTFIT MODELS
# ============================================================================


class OutfitBase(BaseModel):
    """Base outfit model with common fields."""
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    item_ids: List[UUID] = Field(default_factory=list)
    style: Optional[str] = Field(None, max_length=50)
    season: Optional[str] = Field(None, max_length=20)
    occasion: Optional[str] = Field(None, max_length=50)
    tags: List[str] = Field(default_factory=list)
    is_favorite: bool = False
    is_draft: bool = True
    is_public: bool = False

    @field_validator("item_ids")
    @classmethod
    def validate_item_ids(cls, v: List[UUID]) -> List[UUID]:
        if not v:
            raise ValueError("Outfit must contain at least one item")
        if len(v) != len(set(v)):
            raise ValueError("Outfit cannot contain duplicate items")
        return v


class OutfitCreate(OutfitBase):
    """Model for creating a new outfit."""
    pass


class OutfitUpdate(BaseModel):
    """Model for updating an outfit (all fields optional)."""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    item_ids: Optional[List[UUID]] = None
    style: Optional[str] = Field(None, max_length=50)
    season: Optional[str] = Field(None, max_length=20)
    occasion: Optional[str] = Field(None, max_length=50)
    tags: Optional[List[str]] = None
    is_favorite: Optional[bool] = None
    is_draft: Optional[bool] = None
    is_public: Optional[bool] = None

    @field_validator("item_ids")
    @classmethod
    def validate_item_ids(cls, v: Optional[List[UUID]]) -> Optional[List[UUID]]:
        if v is None:
            return v
        if not v:
            raise ValueError("Outfit must contain at least one item")
        if len(v) != len(set(v)):
            raise ValueError("Outfit cannot contain duplicate items")
        return v


class OutfitResponse(OutfitBase):
    """Model for outfit response with all fields."""
    id: UUID
    user_id: UUID
    worn_count: int = 0
    last_worn_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    images: List[OutfitImage] = Field(default_factory=list)

    class Config:
        from_attributes = True


class OutfitListResponse(BaseModel):
    """Model for paginated outfit list response."""
    outfits: List[OutfitResponse]
    total: int
    page: int
    total_pages: int
    has_next: bool = False
    has_prev: bool = False


class OutfitDetailResponse(OutfitResponse):
    """Detailed outfit response with full item details."""
    items_details: Optional[List[Dict[str, Any]]] = None  # Full item objects


# ============================================================================
# AI GENERATION MODELS
# ============================================================================


class GenerationRequest(BaseModel):
    """Request model for AI outfit image generation."""
    pose: str = Field(default="front", max_length=20)
    variations: int = Field(default=1, ge=1, le=3)
    lighting: Optional[str] = Field(default="natural", max_length=50)
    body_profile_id: Optional[UUID] = None


class GenerationResponse(BaseModel):
    """Response model for outfit generation requests."""
    generation_id: str
    outfit_id: UUID
    status: GenerationStatus
    image_url: Optional[str] = None
    estimated_time: Optional[int] = None  # Seconds until completion
    created_at: datetime


class GenerationStatusResponse(BaseModel):
    """Response model for checking generation status."""
    generation_id: str
    outfit_id: UUID
    status: GenerationStatus
    progress: Optional[float] = None  # 0.0 to 1.0
    image_url: Optional[str] = None
    error: Optional[str] = None
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None


# ============================================================================
# OUTFIT COLLECTION MODELS
# ============================================================================


class OutfitCollectionBase(BaseModel):
    """Base model for outfit collections (grouping outfits)."""
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    is_favorite: bool = False


class OutfitCollectionCreate(OutfitCollectionBase):
    """Model for creating a collection."""
    outfit_ids: List[UUID] = Field(default_factory=list)


class OutfitCollectionUpdate(BaseModel):
    """Model for updating a collection."""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    outfit_ids: Optional[List[UUID]] = None
    is_favorite: Optional[bool] = None


class OutfitCollectionResponse(OutfitCollectionBase):
    """Model for collection response."""
    id: UUID
    user_id: UUID
    outfit_count: int = 0
    created_at: datetime
    updated_at: datetime
    outfits: Optional[List[OutfitResponse]] = None

    class Config:
        from_attributes = True


# ============================================================================
# STATISTICS MODELS
# ============================================================================


class OutfitStats(BaseModel):
    """Statistics about user's outfits."""
    total_outfits: int
    favorite_outfits: int
    most_worn_outfit: Optional[Dict[str, Any]] = None
    outfits_by_style: Dict[str, int]
    outfits_by_season: Dict[str, int]
    avg_items_per_outfit: float
