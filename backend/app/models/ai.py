"""
AI Pydantic models for validation and serialization.

Models for AI operations including item extraction and image generation.
"""

from pydantic import BaseModel, Field
from typing import Any, Dict, List, Optional
from enum import Enum


# =============================================================================
# ENUMS
# =============================================================================


class AIProviderEnum(str, Enum):
    """Supported AI providers."""
    GEMINI = "gemini"
    OPENAI = "openai"
    CUSTOM = "custom"


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


class ExtractItemsRequest(BaseModel):
    """Request to extract items from an image."""
    image: str = Field(..., description="Base64-encoded image data")


class ExtractItemsResponse(BaseModel):
    """Response from item extraction."""
    items: List[DetectedItem] = Field(default_factory=list)
    overall_confidence: float = Field(0.0, ge=0, le=1)
    image_description: str = ""
    item_count: int = 0
    requires_review: bool = True


class ExtractSingleItemRequest(BaseModel):
    """Request to extract a single item from an image."""
    image: str = Field(..., description="Base64-encoded image data")
    category_hint: Optional[str] = None


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
    """Input item for outfit generation."""
    name: str
    category: Optional[str] = None
    colors: List[str] = Field(default_factory=list)
    brand: Optional[str] = None
    material: Optional[str] = None
    pattern: Optional[str] = None


class GenerateOutfitRequest(BaseModel):
    """Request to generate an outfit visualization."""
    items: List[OutfitItemInput] = Field(..., min_length=1)
    style: str = "casual"
    background: str = "studio white"
    pose: str = "standing front"
    lighting: str = "professional studio lighting"
    view_angle: str = "full body"
    include_model: bool = True
    model_gender: str = "female"
    custom_prompt: Optional[str] = None
    save_to_storage: bool = False


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
    background: str = "white"
    view_angle: str = "front"
    include_shadows: bool = False
    save_to_storage: bool = False
    reference_image: Optional[str] = None  # Base64 reference image for exact matching


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
    image_gen_model: Optional[str] = None


class ProviderConfigDisplay(BaseModel):
    """Provider config for display (API key masked)."""
    api_url: str = ""
    model: str = ""
    vision_model: str = ""
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
    api_url: str
    api_key: str
    model: str


class TestProviderResponse(BaseModel):
    """Response from testing a provider."""
    success: bool
    message: str
    model: Optional[str] = None
    response: Optional[str] = None


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
    clothing_image: str = Field(..., description="Base64-encoded clothing image")
    clothing_description: Optional[str] = Field(None, description="Optional description to improve accuracy")
    style: str = "casual"
    background: str = "studio white"
    pose: str = "standing front"
    lighting: str = "professional studio lighting"
    save_to_storage: bool = False


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
    gemini: Dict[str, List[str]] = Field(default_factory=dict)
    openai: Dict[str, List[str]] = Field(default_factory=dict)
    custom: Dict[str, List[str]] = Field(default_factory=dict)
