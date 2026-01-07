"""
User Pydantic models for validation and serialization.
"""

from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime


# ============================================================================
# USER MODELS
# ============================================================================


class UserBase(BaseModel):
    """Base user model with common fields."""
    email: EmailStr
    full_name: Optional[str] = Field(None, max_length=255)
    avatar_url: Optional[str] = None
    is_active: bool = True


class UserCreate(BaseModel):
    """Model for creating a new user (internal use)."""
    email: EmailStr
    full_name: Optional[str] = Field(None, max_length=255)
    password: str  # Will be hashed by Supabase Auth


class UserUpdate(BaseModel):
    """Model for updating user profile."""
    full_name: Optional[str] = Field(None, max_length=255)
    avatar_url: Optional[str] = None
    is_active: Optional[bool] = None


class UserResponse(UserBase):
    """Model for user response with all fields."""
    id: UUID
    email_verified: bool = False
    created_at: datetime
    updated_at: Optional[datetime] = None
    last_login_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class UserProfile(UserResponse):
    """Extended user profile with preferences."""
    preferences: Optional['UserPreferences'] = None
    settings: Optional['UserSettings'] = None
    stats: Optional[Dict[str, Any]] = None  # Item count, outfit count, etc.


# ============================================================================
# USER PREFERENCES MODELS
# ============================================================================


class UserPreferencesBase(BaseModel):
    """Base user preferences model."""
    favorite_colors: List[str] = Field(default_factory=list)
    preferred_styles: List[str] = Field(default_factory=list)
    liked_brands: List[str] = Field(default_factory=list)
    disliked_patterns: List[str] = Field(default_factory=list)
    style_notes: Optional[str] = None


class UserPreferencesUpdate(BaseModel):
    """Model for updating user preferences (all fields optional)."""
    favorite_colors: Optional[List[str]] = None
    preferred_styles: Optional[List[str]] = None
    liked_brands: Optional[List[str]] = None
    disliked_patterns: Optional[List[str]] = None
    style_notes: Optional[str] = None


class UserPreferences(UserPreferencesBase):
    """Complete user preferences model."""
    id: UUID
    user_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# ============================================================================
# USER SETTINGS MODELS
# ============================================================================


class UserSettingsBase(BaseModel):
    """Base user settings model."""
    language: str = "en"
    measurement_units: str = "imperial"  # 'imperial' or 'metric'
    notifications_enabled: bool = True
    email_marketing: bool = False
    dark_mode: bool = False


class UserSettingsUpdate(BaseModel):
    """Model for updating user settings (all fields optional)."""
    language: Optional[str] = None
    measurement_units: Optional[str] = None
    notifications_enabled: Optional[bool] = None
    email_marketing: Optional[bool] = None
    dark_mode: Optional[bool] = None

    @field_validator('measurement_units')
    @classmethod
    def validate_units(cls, v: Optional[str]) -> Optional[str]:
        """Validate measurement units."""
        if v is not None and v not in ['imperial', 'metric']:
            raise ValueError('measurement_units must be either "imperial" or "metric"')
        return v


class UserSettings(UserSettingsBase):
    """Complete user settings model."""
    id: UUID
    user_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# ============================================================================
# BODY PROFILE MODELS
# ============================================================================


class BodyProfileBase(BaseModel):
    """Base body profile model for sizing recommendations."""
    height: Optional[int] = None  # In centimeters
    weight: Optional[int] = None  # In kilograms
    body_type: Optional[str] = None  # 'slim', 'average', 'athletic', 'plus'
    skin_tone: Optional[str] = None
    hair_color: Optional[str] = None
    eye_color: Optional[str] = None
    notes: Optional[str] = None


class BodyProfileCreate(BodyProfileBase):
    """Model for creating a body profile."""
    pass


class BodyProfileUpdate(BaseModel):
    """Model for updating body profile (all fields optional)."""
    height: Optional[int] = None
    weight: Optional[int] = None
    body_type: Optional[str] = None
    skin_tone: Optional[str] = None
    hair_color: Optional[str] = None
    eye_color: Optional[str] = None
    notes: Optional[str] = None


class BodyProfile(BodyProfileBase):
    """Complete body profile model."""
    id: UUID
    user_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# ============================================================================
# USER STATISTICS MODELS
# ============================================================================


class UserStats(BaseModel):
    """Statistics about user's wardrobe and usage."""
    total_items: int
    total_outfits: int
    items_by_category: Dict[str, int]
    items_by_condition: Dict[str, int]
    most_worn_items: List[Dict[str, Any]]
    least_worn_items: List[Dict[str, Any]]
    total_cost: Optional[float] = None
    avg_cost_per_wear: Optional[float] = None
    storage_used_bytes: Optional[int] = None


class UserDashboard(BaseModel):
    """Dashboard data for logged-in user."""
    user: UserResponse
    stats: UserStats
    recent_items: List[Dict[str, Any]] = []
    recent_outfits: List[Dict[str, Any]] = []
    recommendations: List[Dict[str, Any]] = []


# Forward references for circular dependencies
UserProfile.model_rebuild()
