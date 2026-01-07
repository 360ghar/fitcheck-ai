"""
Recommendation Pydantic models for validation and serialization.
"""

from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime
from enum import Enum


# ============================================================================
# RECOMMENDATION TYPES
# ============================================================================


class RecommendationType(str, Enum):
    """Types of recommendations."""
    MATCH = "match"  # Find items that match a given item
    COMPLETE_LOOK = "complete_look"  # Build a full outfit
    SIMILAR_ITEMS = "similar_items"  # Find similar items
    STYLE_SUGGESTION = "style_suggestion"  # Style recommendations
    SHOPPING = "shopping"  # Shopping suggestions


class MatchReason(str, Enum):
    """Reasons why items match."""
    COLOR_HARMONY = "color_harmony"
    STYLE_COMPATIBLE = "style_compatible"
    OCCASION_APPROPRIATE = "occasion_appropriate"
    SEASONAL = "seasonal"
    TRENDING = "trending"
    PROVEN_COMBINATION = "proven_combination"  # Used together before
    BRAND_COORDINATION = "brand_coordination"


# ============================================================================
# MATCH RESULT MODELS
# ============================================================================


class MatchReason(BaseModel):
    """A reason why items match together."""
    type: str
    description: str
    confidence: float = Field(..., ge=0, le=1)


class MatchResult(BaseModel):
    """Result of matching items together."""
    item_id: UUID
    item_name: str
    image_url: Optional[str] = None
    category: str
    score: float = Field(..., ge=0, le=1, description="Overall match score")
    reasons: List[MatchReason] = Field(default_factory=list)
    metadata: Optional[Dict[str, Any]] = None  # Additional info


class MatchResponse(BaseModel):
    """Response for item matching requests."""
    source_item_id: UUID
    matches: List[MatchResult]
    total_found: int
    search_params: Optional[Dict[str, Any]] = None


# ============================================================================
# COMPLETE LOOK MODELS
# ============================================================================


class SuggestedItem(BaseModel):
    """An item suggested for an outfit."""
    item_id: UUID
    item_name: str
    image_url: Optional[str] = None
    category: str
    position: str  # 'top', 'bottom', 'shoes', 'accessory', etc.
    confidence: float = Field(..., ge=0, le=1)
    can_replace_with: List[UUID] = Field(default_factory=list)  # Alternative items


class CompleteLookSuggestion(BaseModel):
    """A suggested complete outfit."""
    name: str
    description: Optional[str] = None
    items: List[SuggestedItem]
    style: Optional[str] = None
    occasion: Optional[str] = None
    confidence: float = Field(..., ge=0, le=1)
    metadata: Optional[Dict[str, Any]] = None


class CompleteLookResponse(BaseModel):
    """Response for complete look suggestions."""
    suggestions: List[CompleteLookSuggestion]
    total_suggestions: int
    base_item_id: Optional[UUID] = None
    criteria: Optional[Dict[str, Any]] = None


# ============================================================================
# SIMILAR ITEMS MODELS
# ============================================================================


class SimilarItemResult(BaseModel):
    """A result from similar items search."""
    item_id: UUID
    item_name: str
    image_url: Optional[str] = None
    category: str
    sub_category: Optional[str] = None
    brand: Optional[str] = None
    colors: List[str] = Field(default_factory=list)
    similarity: float = Field(..., ge=0, le=1, description="Vector similarity score")
    reasons: List[str] = Field(default_factory=list)  # Human-readable reasons


class SimilarItemsResponse(BaseModel):
    """Response for similar items requests."""
    source_item_id: UUID
    similar_items: List[SimilarItemResult]
    total_found: int
    filters_applied: Optional[Dict[str, Any]] = None


# ============================================================================
# RECOMMENDATION REQUEST MODELS
# ============================================================================


class RecommendationRequest(BaseModel):
    """Base recommendation request."""
    limit: int = Field(default=10, ge=1, le=50)
    exclude_worn_recently: bool = False
    days_recent: int = Field(default=7, ge=1, le=365)
    consider_weather: bool = False
    weather_temp: Optional[int] = None  # Fahrenheit
    weather_condition: Optional[str] = None  # 'sunny', 'rainy', 'snowy', etc.


class MatchRequest(RecommendationRequest):
    """Request to find items that match a given item."""
    item_id: UUID
    categories: Optional[List[str]] = None  # Filter to specific categories
    min_score: float = Field(default=0.5, ge=0, le=1)
    max_results: int = Field(default=10, ge=1, le=50)


class CompleteLookRequest(RecommendationRequest):
    """Request to generate complete outfit suggestions."""
    base_item_ids: List[UUID] = Field(default_factory=list)  # Start with these items
    style: Optional[str] = None
    occasion: Optional[str] = None
    season: Optional[str] = None
    max_suggestions: int = Field(default=5, ge=1, le=20)
    include_accessories: bool = True
    color_scheme: Optional[str] = None  # 'monochromatic', 'complementary', etc.


class SimilarItemsRequest(RecommendationRequest):
    """Request to find items similar to a given item."""
    item_id: UUID
    min_similarity: float = Field(default=0.6, ge=0, le=1)
    same_category_only: bool = False


# ============================================================================
# SHOPPING RECOMMENDATION MODELS
# ============================================================================


class ShoppingSuggestion(BaseModel):
    """A suggested item to purchase."""
    category: str
    sub_category: Optional[str] = None
    reason: str  # Why this item is recommended
    priority: str = Field(default="medium")  # 'low', 'medium', 'high'
    suggested_brands: List[str] = Field(default_factory=list)
    price_range: Optional[str] = None  # "$", "$$", "$$$"
    fill_gaps_in_wardrobe: bool = True


class ShoppingRecommendationsResponse(BaseModel):
    """Response for shopping recommendations."""
    suggestions: List[ShoppingSuggestion]
    wardrobe_analysis: Optional[Dict[str, Any]] = None
    total_suggestions: int


# ============================================================================
# STYLE ANALYSIS MODELS
# ============================================================================


class StyleAnalysis(BaseModel):
    """Analysis of user's style based on wardrobe."""
    dominant_styles: List[str] = Field(default_factory=list)
    color_palette: List[str] = Field(default_factory=list)
    favorite_brands: List[str] = Field(default_factory=list)
    most_common_categories: List[Dict[str, Any]] = Field(default_factory=list)
    style_score: Optional[Dict[str, float]] = None  # Style name -> confidence


class StyleAnalysisResponse(BaseModel):
    """Response for style analysis requests."""
    analysis: StyleAnalysis
    recommendations: List[str] = Field(default_factory=list)
    suggestions: List[str] = Field(default_factory=list)
    analyzed_at: datetime = Field(default_factory=datetime.now)


# ============================================================================
# FEEDBACK MODELS
# ============================================================================


class RecommendationFeedback(BaseModel):
    """User feedback on recommendations."""
    recommendation_type: RecommendationType
    recommendation_id: Optional[str] = None
    item_ids: List[UUID] = Field(default_factory=list)
    was_helpful: bool
    selected_items: List[UUID] = Field(default_factory=list)
    feedback: Optional[str] = None


class FeedbackResponse(BaseModel):
    """Response to feedback submission."""
    message: str
    feedback_recorded: bool = True
