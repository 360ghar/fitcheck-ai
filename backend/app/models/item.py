"""
Item Pydantic models for validation and serialization.
"""

from pydantic import BaseModel, Field, field_validator
from typing import Any, Optional, List
from uuid import UUID
from datetime import datetime


# Valid categories for items
VALID_CATEGORIES = [
    'tops', 'bottoms', 'shoes', 'accessories',
    'outerwear', 'swimwear', 'activewear', 'other'
]

# Valid conditions for items
VALID_CONDITIONS = ['clean', 'dirty', 'laundry', 'repair', 'donate']


def normalize_tag_list(value: Any) -> List[str]:
    """Normalize tag arrays by trimming, lowercasing, de-duping, and dropping empties."""
    if value is None:
        return []

    if isinstance(value, str):
        values = [value]
    elif isinstance(value, (list, tuple, set)):
        values = list(value)
    else:
        values = [value]

    normalized: List[str] = []
    seen = set()
    for entry in values:
        if entry is None:
            continue
        tag = str(entry).strip().lower()
        if not tag or tag in seen:
            continue
        seen.add(tag)
        normalized.append(tag)
    return normalized


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
    """Base item model with common fields.

    Deliberately carries no rejecting validators: ItemResponse reuses this
    base for serialization, so a legacy row must never 500 a read (same
    documented pattern as OutfitBase/OutfitCreate). Input strictness —
    category/condition whitelists, price bounds — lives on ItemCreate and
    ItemUpdate. Tag-list normalization below is lenient (never raises), so it
    is safe for both input and response sides.
    """
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
    # le=99_999_999.99 mirrors DECIMAL(10,2) (migration 001) — an unbounded
    # float used to pass Pydantic (even inf) and 500 with 22001 at the DB.
    price: Optional[float] = Field(None, ge=0, le=99_999_999.99, allow_inf_nan=False)
    purchase_date: Optional[datetime] = None
    purchase_location: Optional[str] = Field(None, max_length=255)
    tags: List[str] = Field(default_factory=list)
    notes: Optional[str] = None
    condition: str = Field(default="clean")
    is_favorite: bool = False

    @field_validator('colors', 'tags', 'seasonal_tags', 'occasion_tags', mode='before')
    @classmethod
    def validate_tag_lists(cls, v: Any) -> List[str]:
        """Normalize tag-ish list fields: trim, lowercase, de-dupe, drop empties.

        Keeps raw empty/duplicate/overlong entries from polluting the jsonb
        arrays used in filters (same treatment occasion_tags already got).
        """
        return normalize_tag_list(v)


class ItemCreate(ItemBase):
    """Model for creating a new item."""
    images: List[ItemImageBase] = Field(default_factory=list)
    # Original source photo reference (set by AI extraction flows; optional for
    # manual creation). Used as the reference image for product-image
    # regeneration so the exact garment (pattern, texture, branding) is preserved.
    source_image_url: Optional[str] = None
    source_image_storage_path: Optional[str] = None
    # Client-generated idempotency key (F1-07): transport retries re-issue the
    # same body, and the create endpoint replays the original row for a
    # repeated key instead of inserting a duplicate item.
    client_request_id: Optional[str] = Field(None, max_length=64)

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
            # Unreachable: Field(ge=0) rejects negatives before this
            # validator runs; kept as a defense-in-depth guard.
            raise ValueError('Price must be non-negative')  # pragma: no cover - shadowed by Field(ge=0)
        return v


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
    # Same DECIMAL(10,2) bounds as ItemBase.price.
    price: Optional[float] = Field(None, ge=0, le=99_999_999.99, allow_inf_nan=False)
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

    @field_validator('colors', 'tags', 'seasonal_tags', 'occasion_tags', mode='before')
    @classmethod
    def validate_tag_lists(cls, v: Any) -> Optional[List[str]]:
        """Normalize tag-ish list fields if provided (None stays None)."""
        if v is None:
            return None
        return normalize_tag_list(v)


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
    source_image_url: Optional[str] = None
    source_image_storage_path: Optional[str] = None

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
