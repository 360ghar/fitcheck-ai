"""
Item Pydantic models for validation and serialization.
"""

from pydantic import BaseModel, Field, field_validator
from typing import Optional, List
from uuid import UUID
from datetime import datetime


# Valid categories for items
VALID_CATEGORIES = [
    'tops', 'bottoms', 'shoes', 'accessories',
    'outerwear', 'swimwear', 'activewear', 'other'
]

# Valid conditions for items
VALID_CONDITIONS = ['clean', 'dirty', 'laundry', 'repair', 'donate']


# ============================================================================
# ITEM IMAGE MODELS
# ============================================================================


class ItemImageBase(BaseModel):
    """Base model for item images."""
    image_url: str
    thumbnail_url: Optional[str] = None
    storage_path: Optional[str] = None
    is_primary: bool = False
    width: Optional[int] = None
    height: Optional[int] = None


class ItemImage(ItemImageBase):
    """Complete item image model."""
    id: UUID
    item_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True


# ============================================================================
# ITEM MODELS
# ============================================================================


class ItemBase(BaseModel):
    """Base item model with common fields."""
    name: str = Field(..., min_length=1, max_length=255)
    category: str
    sub_category: Optional[str] = Field(None, max_length=50)
    brand: Optional[str] = Field(None, max_length=100)
    colors: List[str] = Field(default_factory=list)
    style: Optional[str] = Field(None, max_length=50)
    material: Optional[str] = Field(None, max_length=50)
    materials: List[str] = Field(default_factory=list)
    pattern: Optional[str] = Field(None, max_length=50)
    seasonal_tags: List[str] = Field(default_factory=list)
    occasion_tags: List[str] = Field(default_factory=list)
    size: Optional[str] = Field(None, max_length=50)
    price: Optional[float] = Field(None, ge=0)
    purchase_date: Optional[datetime] = None
    purchase_location: Optional[str] = Field(None, max_length=255)
    tags: List[str] = Field(default_factory=list)
    notes: Optional[str] = None
    condition: str = Field(default="clean")
    is_favorite: bool = False

    @field_validator('category')
    @classmethod
    def validate_category(cls, v: str) -> str:
        """Validate category is one of the allowed values."""
        v_lower = v.lower()
        if v_lower not in VALID_CATEGORIES:
            raise ValueError(
                f'Invalid category. Must be one of: {", ".join(VALID_CATEGORIES)}'
            )
        return v_lower

    @field_validator('condition')
    @classmethod
    def validate_condition(cls, v: str) -> str:
        """Validate condition is one of the allowed values."""
        if v not in VALID_CONDITIONS:
            raise ValueError(
                f'Invalid condition. Must be one of: {", ".join(VALID_CONDITIONS)}'
            )
        return v

    @field_validator('price')
    @classmethod
    def validate_price(cls, v: Optional[float]) -> Optional[float]:
        """Validate price is non-negative."""
        if v is not None and v < 0:
            raise ValueError('Price must be non-negative')
        return v


class ItemCreate(ItemBase):
    """Model for creating a new item."""
    images: List[ItemImageBase] = Field(default_factory=list)


class ItemUpdate(BaseModel):
    """Model for updating an item (all fields optional)."""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    category: Optional[str] = None
    sub_category: Optional[str] = Field(None, max_length=50)
    brand: Optional[str] = Field(None, max_length=100)
    colors: Optional[List[str]] = None
    style: Optional[str] = Field(None, max_length=50)
    material: Optional[str] = Field(None, max_length=50)
    materials: Optional[List[str]] = None
    pattern: Optional[str] = Field(None, max_length=50)
    seasonal_tags: Optional[List[str]] = None
    occasion_tags: Optional[List[str]] = None
    size: Optional[str] = Field(None, max_length=50)
    price: Optional[float] = Field(None, ge=0)
    purchase_date: Optional[datetime] = None
    purchase_location: Optional[str] = Field(None, max_length=255)
    tags: Optional[List[str]] = None
    notes: Optional[str] = None
    condition: Optional[str] = None
    is_favorite: Optional[bool] = None

    @field_validator('category')
    @classmethod
    def validate_category(cls, v: Optional[str]) -> Optional[str]:
        """Validate category if provided."""
        if v is not None:
            v_lower = v.lower()
            if v_lower not in VALID_CATEGORIES:
                raise ValueError(
                    f'Invalid category. Must be one of: {", ".join(VALID_CATEGORIES)}'
                )
            return v_lower
        return v

    @field_validator('condition')
    @classmethod
    def validate_condition(cls, v: Optional[str]) -> Optional[str]:
        """Validate condition if provided."""
        if v is not None and v not in VALID_CONDITIONS:
            raise ValueError(
                f'Invalid condition. Must be one of: {", ".join(VALID_CONDITIONS)}'
            )
        return v


class ItemResponse(ItemBase):
    """Model for item response with all fields."""
    id: UUID
    user_id: UUID
    usage_times_worn: int = 0
    usage_last_worn: Optional[datetime] = None
    cost_per_wear: Optional[float] = None
    created_at: datetime
    updated_at: datetime
    images: List[ItemImage] = Field(default_factory=list)

    class Config:
        from_attributes = True


class ItemListResponse(BaseModel):
    """Model for paginated item list response."""
    items: List[ItemResponse]
    total: int
    page: int
    total_pages: int
    has_next: bool = False
    has_prev: bool = False


# ============================================================================
# ITEM EXTRACTION MODELS (AI)
# ============================================================================


class ExtractedItem(BaseModel):
    """Model for an item extracted by AI from an image."""
    id: Optional[str] = None  # Temporary ID before saving
    image_url: Optional[str] = None
    category: str
    sub_category: Optional[str] = None
    colors: List[str] = Field(default_factory=list)
    confidence: float = Field(..., ge=0, le=1)
    bounding_box: Optional[dict] = None  # {x, y, width, height} as percentages


class ItemExtractionResponse(BaseModel):
    """Response model for AI item extraction."""
    extraction_id: str
    items: List[ExtractedItem]
    status: str = "completed"


class ItemUploadResponse(BaseModel):
    """Response model for item upload request."""
    upload_id: str
    status: str = "processing"
    uploaded_count: int
    extracted_items: List[ExtractedItem] = Field(default_factory=list)
