"""
AI Pydantic models for validation and serialization.

Models for AI operations including item extraction and image generation.
"""

from pydantic import BaseModel, Field, field_validator, model_validator
from typing import Any, Dict, List, Optional
from uuid import UUID

from app.core.config import settings
from app.utils.image_processing import make_base64_image_validator

_MAX_INLINE_IMAGE_BYTES = 7 * 1024 * 1024

_validate_inline_image = make_base64_image_validator(_MAX_INLINE_IMAGE_BYTES)


def _validate_optional_inline_image(value: Optional[str]) -> Optional[str]:
    """Validate legacy inline data only when a value was actually supplied.

    Empty legacy fields are treated as omitted so callers can migrate to a
    storage path without being rejected by the legacy base64 validator.
    """
    if not value:
        return value
    return _validate_inline_image(value)


# =============================================================================
# BOUNDING BOX
# =============================================================================


class BoundingBox(BaseModel):
    """Bounding box for detected items (percentages 0-100)."""
    x: float = Field(..., ge=0, le=100)
    y: float = Field(..., ge=0, le=100)
    width: float = Field(..., ge=0, le=100)
    height: float = Field(..., ge=0, le=100)


# =============================================================================
# ITEM EXTRACTION MODELS
# =============================================================================


class DetectedItem(BaseModel):
    """A single item detected from an image."""
    temp_id: str
    category: str
    sub_category: Optional[str] = None
    colors: List[str] = Field(default_factory=list)
    material: Optional[str] = None
    pattern: Optional[str] = None
    brand: Optional[str] = None
    confidence: float = Field(..., ge=0, le=1)
    bounding_box: Optional[BoundingBox] = None
    detailed_description: Optional[str] = None
    status: str = "detected"
    person_id: Optional[str] = None
    person_label: Optional[str] = None
    is_current_user_person: Optional[bool] = None
    include_in_wardrobe: Optional[bool] = None


class DetectedPerson(BaseModel):
    """A person detected in extraction image."""
    person_id: str
    person_label: str
    is_current_user_person: bool = False
    confidence: float = Field(0.0, ge=0, le=1)


class ExtractItemsRequest(BaseModel):
    """Request to extract items from an image (inline or stored)."""
    image: Optional[str] = Field(None, description="Legacy base64-encoded image data")
    storage_path: Optional[str] = Field(None, description="Owned storage key for the image")

    _validate_image = field_validator("image")(_validate_optional_inline_image)

    @model_validator(mode="after")
    def require_image_source(self):
        if not self.image and not self.storage_path:
            raise ValueError("image or storage_path is required")
        return self


class ExtractItemsResponse(BaseModel):
    """Response from item extraction."""
    items: List[DetectedItem] = Field(default_factory=list)
    people: List[DetectedPerson] = Field(default_factory=list)
    overall_confidence: float = Field(0.0, ge=0, le=1)
    image_description: str = ""
    item_count: int = 0
    requires_review: bool = True
    has_profile_reference: bool = False
    profile_match_found: bool = False


class ExtractSingleItemRequest(BaseModel):
    """Request to extract a single item from an image (inline or stored)."""
    image: Optional[str] = Field(None, description="Legacy base64-encoded image data")
    storage_path: Optional[str] = Field(None, description="Owned storage key for the image")
    category_hint: Optional[str] = None

    _validate_image = field_validator("image")(_validate_optional_inline_image)

    @model_validator(mode="after")
    def require_image_source(self):
        if not self.image and not self.storage_path:
            raise ValueError("image or storage_path is required")
        return self


class ExtractSingleItemResponse(BaseModel):
    """Response from single item extraction."""
    category: str
    sub_category: Optional[str] = None
    colors: List[str] = Field(default_factory=list)
    material: Optional[str] = None
    pattern: Optional[str] = None
    brand: Optional[str] = None
    confidence: float = Field(0.0, ge=0, le=1)
    description: Optional[str] = None


# =============================================================================
# IMAGE GENERATION MODELS
# =============================================================================


class OutfitItemInput(BaseModel):
    """Input item for outfit generation.

    `item_id` is the caller's own wardrobe item. When present, the backend
    resolves that item's stored image server-side (scoped to the caller) and
    sends it to the image model as a labelled garment reference, so the
    generated outfit reproduces the real garment instead of inventing a
    lookalike from the text attributes below. Absent — or an item with no
    stored image — degrades to the text-only inventory.

    Clients never send image URLs or base64 here: a client-supplied URL the
    backend fetches is an SSRF primitive (StorageService.download_to_base64
    follows redirects with no host allow-list), and inline base64 would
    triple mobile request size.
    """
    item_id: Optional[UUID] = None
    name: str
    category: Optional[str] = None
    colors: List[str] = Field(default_factory=list)
    brand: Optional[str] = None
    material: Optional[str] = None
    pattern: Optional[str] = None


class GenerateOutfitRequest(BaseModel):
    """Request to generate an outfit visualization."""
    # Every item with a stored image becomes an inline reference image, so the
    # list length drives request payload size. max_length is purely an abuse
    # guard against payload amplification, NOT a cap on how many references a
    # genuine outfit may use - it has to sit above anything real. Real looks are
    # 3-8 items, but createOutfitFromSavedItems (frontend/src/lib/
    # outfit-from-upload.ts) builds one outfit from every item detected in a
    # single photo, and a wardrobe flat-lay can legitimately produce dozens.
    items: List[OutfitItemInput] = Field(..., min_length=1)

    @field_validator("items")
    @classmethod
    def validate_item_count(cls, value: List[OutfitItemInput]) -> List[OutfitItemInput]:
        if len(value) > settings.AI_MAX_OUTFIT_ITEMS:
            raise ValueError(
                f"At most {settings.AI_MAX_OUTFIT_ITEMS} outfit items are allowed"
            )
        return value
    style: str = "casual"
    # A short token, resolved to a prompt fragment by _resolve_background in
    # app/agents/image_generation_agent.py. Was "studio white"; the agent's own
    # default was the far worse "seamless clean light background", which invites
    # a gradient sweep the flat-lay matte cannot cut cleanly.
    background: str = "transparent"
    pose: str = "standing front"
    lighting: str = "professional studio lighting"
    view_angle: str = "full body"
    include_model: bool = True
    model_gender: str = "female"
    custom_prompt: Optional[str] = None
    save_to_storage: bool = False
    include_user_face: bool = True  # Use avatar for face consistency when available
    use_body_profile: bool = True   # Use body profile data if available
    # Upload flow ONLY: when True, the backend additionally resolves the
    # original uploaded source photo the outfit's items were extracted from
    # and sends it to the image model as an "as worn" reference, so the render
    # reproduces the garments' real fit, draping, and layering instead of
    # compounding the loss from the extracted/generated item shots. Default
    # False: the outfit builder and every other caller keep the existing
    # item-reference-only behavior. Resolution is server-side and user-scoped
    # (same SSRF posture as `item_id`); clients never send URLs or base64.
    use_source_photo: bool = False


class GenerateOutfitResponse(BaseModel):
    """Response from outfit generation."""
    image_base64: str
    image_url: Optional[str] = None
    storage_path: Optional[str] = None
    prompt: str
    model: str
    provider: str


class GenerateProductImageRequest(BaseModel):
    """Request to generate a product image."""
    item_description: str
    category: str
    sub_category: Optional[str] = None
    colors: List[str] = Field(default_factory=list)
    material: Optional[str] = None
    # "transparent" == "render on matte-optimal flat white, then cut the alpha
    # server-side". Resolves to the same prompt fragment as "white" (which every
    # existing client still sends); see _resolve_background.
    background: str = "transparent"
    view_angle: str = "front"
    include_shadows: bool = False
    save_to_storage: bool = False
    reference_image: Optional[str] = Field(
        None,
        max_length=10_000_000,
        description="Optional legacy base64 source photo",
    )
    reference_storage_path: Optional[str] = Field(None, description="Owned source photo storage key")

    _validate_reference_image = field_validator("reference_image")(_validate_optional_inline_image)


class GenerateProductImageResponse(BaseModel):
    """Response from product image generation."""
    image_base64: str
    image_url: Optional[str] = None
    storage_path: Optional[str] = None
    prompt: str
    model: str
    provider: str


# =============================================================================
# AI SETTINGS MODELS
# =============================================================================


class ProviderConfigInput(BaseModel):
    """Configuration for a single provider."""
    api_url: Optional[str] = None
    api_key: Optional[str] = None  # Will be encrypted before storage
    model: Optional[str] = None
    vision_model: Optional[str] = None
    vision_fallback_model: Optional[str] = None
    image_gen_model: Optional[str] = None


class ProviderConfigDisplay(BaseModel):
    """Provider config for display (API key masked)."""
    api_url: str = ""
    model: str = ""
    vision_model: str = ""
    vision_fallback_model: str = ""
    image_gen_model: str = ""
    api_key_set: bool = False


class AISettingsUpdate(BaseModel):
    """Request to update AI settings."""
    default_provider: Optional[str] = None
    provider_configs: Optional[Dict[str, ProviderConfigInput]] = None


class AISettingsResponse(BaseModel):
    """Response with AI settings."""
    default_provider: str
    provider_configs: Dict[str, ProviderConfigDisplay] = Field(default_factory=dict)
    usage: Optional[Dict[str, Any]] = None


class TestProviderRequest(BaseModel):
    """Request to test a provider configuration."""
    provider: str = "custom"  # "openai" | "custom" | "gemini". Default keeps
    # the existing frontend call (which never sent this field) working
    # unchanged.
    api_url: Optional[str] = None  # required for openai/custom, ignored for gemini
    api_key: str
    model: str


class TestProviderResponse(BaseModel):
    """Response from testing a provider."""
    success: bool
    message: str
    model: Optional[str] = None
    response: Optional[str] = None


class HealthCheckResult(BaseModel):
    """Result of a provider connection/health probe.

    Canonical fields are ``available`` and ``message``. ``success``, ``model``,
    and ``response`` are preserved as wire-compatible aliases so existing
    callers (including tests that subscript the result) keep working during
    migration. Domain exceptions such as ``AIServiceError`` / ``DatabaseError``
    must still propagate from provider methods; they are intentionally not
    flattened into this envelope.
    """
    available: bool
    message: str
    model: Optional[str] = None
    response: Optional[str] = None
    error_type: Optional[str] = None
    latency_ms: Optional[float] = None

    @property
    def success(self) -> bool:
        return self.available

    def to_api_dict(self) -> Dict[str, Any]:
        data: Dict[str, Any] = {
            "success": self.available,
            "message": self.message,
        }
        for key in ("model", "response", "error_type", "latency_ms"):
            value = getattr(self, key, None)
            if value is not None:
                data[key] = value
        return data

    def __getitem__(self, key: str) -> Any:
        """Backward-compatibility shim: allow result['success'] style access."""
        if key == "success":
            return self.success
        if key == "available":
            return self.available
        if hasattr(self, key):
            return getattr(self, key)
        raise KeyError(key)


class UsageStatsResponse(BaseModel):
    """AI usage statistics."""
    daily: Dict[str, int]
    total: Dict[str, int]
    limits: Dict[str, int]
    remaining: Dict[str, int]


class RateLimitCheckResponse(BaseModel):
    """Rate limit check result."""
    allowed: bool
    current_count: int
    limit: int
    remaining: int


# =============================================================================
# TRY-ON MODELS
# =============================================================================


class TryOnRequest(BaseModel):
    """Request for virtual try-on generation."""
    clothing_image: Optional[str] = Field(
        None,
        max_length=10_000_000,
        description="Legacy base64-encoded clothing image",
    )
    clothing_storage_path: Optional[str] = Field(None, description="Owned clothing image storage key")
    avatar_storage_path: Optional[str] = Field(None, description="Owned avatar storage key; defaults to profile avatar")
    clothing_description: Optional[str] = Field(None, description="Optional description to improve accuracy")
    style: str = "casual"
    background: str = "studio white"
    pose: str = "standing front"
    lighting: str = "professional studio lighting"
    save_to_storage: bool = False

    _validate_image = field_validator("clothing_image")(_validate_optional_inline_image)

    @model_validator(mode="after")
    def require_clothing_source(self):
        if not self.clothing_image and not self.clothing_storage_path:
            raise ValueError("clothing_image or clothing_storage_path is required")
        return self


class TryOnResponse(BaseModel):
    """Response from try-on generation."""
    image_base64: str
    image_url: Optional[str] = None
    storage_path: Optional[str] = None
    prompt: str
    model: str
    provider: str


# =============================================================================
# MODEL LISTING
# =============================================================================


class AvailableModelsResponse(BaseModel):
    """Available models by provider."""
    openai: Dict[str, List[str]] = Field(default_factory=dict)
    custom: Dict[str, List[str]] = Field(default_factory=dict)
    gemini: Dict[str, List[str]] = Field(default_factory=dict)
