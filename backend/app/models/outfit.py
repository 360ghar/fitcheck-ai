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
    generation_type: str = "ai"  # 'ai' or 'manual'
    is_primary: bool = True
    width: Optional[int] = None
    height: Optional[int] = None
    metadata: Optional[Dict[str, Any]] = None  # AI prompt, model version, etc.


class OutfitImage(OutfitImageBase):
    """Complete outfit image model."""
    id: UUID
    outfit_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True


# ============================================================================
# OUTFIT ITEM MODELS
# ============================================================================


class OutfitItem(BaseModel):
    """An item within an outfit with optional styling notes."""
    item_id: UUID
    position: Optional[str] = None  # 'top', 'bottom', 'shoes', etc.
    notes: Optional[str] = None


# ============================================================================
# OUTFIT MODELS
# ============================================================================


class OutfitBase(BaseModel):
    """Base outfit model with common fields."""
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    items: List[OutfitItem] = Field(default_factory=list)
    style: Optional[str] = None
    season: Optional[str] = None
    occasion: Optional[str] = Field(None, max_length=100)
    tags: List[str] = Field(default_factory=list)
    is_favorite: bool = False
    is_public: bool = False  # For sharing in future

    @field_validator('style')
    @classmethod
    def validate_style(cls, v: Optional[str]) -> Optional[str]:
        """Validate style is one of the allowed values."""
        if v is not None:
            v_lower = v.lower()
            if v_lower not in VALID_STYLES:
                raise ValueError(
                    f'Invalid style. Must be one of: {", ".join(VALID_STYLES)}'
                )
            return v_lower
        return v

    @field_validator('season')
    @classmethod
    def validate_season(cls, v: Optional[str]) -> Optional[str]:
        """Validate season is one of the allowed values."""
        if v is not None:
            v_lower = v.lower()
            if v_lower not in VALID_SEASONS:
                raise ValueError(
                    f'Invalid season. Must be one of: {", ".join(VALID_SEASONS)}'
                )
            return v_lower
        return v

    @field_validator('items')
    @classmethod
    def validate_items(cls, v: List[OutfitItem]) -> List[OutfitItem]:
        """Ensure outfit has at least one item and no duplicate item_ids."""
        if len(v) == 0:
            raise ValueError('Outfit must contain at least one item')

        item_ids = [item.item_id for item in v]
        if len(item_ids) != len(set(item_ids)):
            raise ValueError('Outfit cannot contain duplicate items')

        return v


class OutfitCreate(OutfitBase):
    """Model for creating a new outfit."""
    generate_ai_image: bool = False


class OutfitUpdate(BaseModel):
    """Model for updating an outfit (all fields optional)."""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    items: Optional[List[OutfitItem]] = None
    style: Optional[str] = None
    season: Optional[str] = None
    occasion: Optional[str] = Field(None, max_length=100)
    tags: Optional[List[str]] = None
    is_favorite: Optional[bool] = None
    is_public: Optional[bool] = None

    @field_validator('style')
    @classmethod
    def validate_style(cls, v: Optional[str]) -> Optional[str]:
        """Validate style if provided."""
        if v is not None:
            v_lower = v.lower()
            if v_lower not in VALID_STYLES:
                raise ValueError(
                    f'Invalid style. Must be one of: {", ".join(VALID_STYLES)}'
                )
            return v_lower
        return v

    @field_validator('season')
    @classmethod
    def validate_season(cls, v: Optional[str]) -> Optional[str]:
        """Validate season if provided."""
        if v is not None:
            v_lower = v.lower()
            if v_lower not in VALID_SEASONS:
                raise ValueError(
                    f'Invalid season. Must be one of: {", ".join(VALID_SEASONS)}'
                )
            return v_lower
        return v

    @field_validator('items')
    @classmethod
    def validate_items(cls, v: Optional[List[OutfitItem]]) -> Optional[List[OutfitItem]]:
        """Ensure no duplicate item_ids if items provided."""
        if v is not None and len(v) > 0:
            item_ids = [item.item_id for item in v]
            if len(item_ids) != len(set(item_ids)):
                raise ValueError('Outfit cannot contain duplicate items')
        return v


class OutfitResponse(OutfitBase):
    """Model for outfit response with all fields."""
    id: UUID
    user_id: UUID
    image_url: Optional[str] = None
    times_worn: int = 0
    last_worn: Optional[datetime] = None
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
    outfit_id: UUID
    prompt: Optional[str] = None  # Custom prompt override
    style: Optional[str] = None
    background: Optional[str] = None  # 'studio', 'street', 'beach', etc.
    include_model: bool = True  # Show the outfit on a model
    model_gender: Optional[str] = None  # 'male', 'female', 'non-binary'
    model_body_type: Optional[str] = None  # 'slim', 'average', 'athletic'
    lighting: Optional[str] = 'natural'  # 'natural', 'studio', 'dramatic'
    view_angle: Optional[str] = 'front'  # 'front', 'side', 'three-quarter'


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
