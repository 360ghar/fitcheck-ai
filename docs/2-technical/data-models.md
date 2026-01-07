# Data Models

## Overview

This document defines all data models for FitCheck AI, including database schemas, Pydantic models, TypeScript interfaces, and vector store design.

## Database Schema (Supabase PostgreSQL)

### 1. Users & Authentication

#### users

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    avatar_url VARCHAR(500),
    body_profile_id UUID REFERENCES body_profiles(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at DESC);
```

#### user_preferences

```sql
CREATE TABLE user_preferences (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    favorite_colors JSONB DEFAULT '[]'::jsonb,
    preferred_styles JSONB DEFAULT '[]'::jsonb,
    liked_brands JSONB DEFAULT '[]'::jsonb,
    disliked_patterns JSONB DEFAULT '[]'::jsonb,
    preferred_occasions JSONB DEFAULT '[]'::jsonb,
    color_temperature VARCHAR(20),
    style_personality VARCHAR(50),
    data_points_collected INTEGER DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id);
```

#### user_settings

```sql
CREATE TABLE user_settings (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    default_location VARCHAR(255),
    timezone VARCHAR(50),
    language VARCHAR(10) DEFAULT 'en',
    measurement_units VARCHAR(10) DEFAULT 'imperial',
    notifications_enabled BOOLEAN DEFAULT TRUE,
    email_marketing BOOLEAN DEFAULT FALSE,
    dark_mode BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2. Wardrobe Management

#### items

```sql
CREATE TABLE items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    sub_category VARCHAR(50),
    brand VARCHAR(100),
    colors JSONB DEFAULT '[]'::jsonb,
    size VARCHAR(50),
    price DECIMAL(10, 2),
    purchase_date DATE,
    purchase_location VARCHAR(255),
    tags JSONB DEFAULT '[]'::jsonb,
    notes TEXT,
    condition VARCHAR(20) DEFAULT 'clean',
    usage_times_worn INTEGER DEFAULT 0,
    usage_last_worn TIMESTAMP,
    cost_per_wear DECIMAL(10, 2),
    is_favorite BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_items_user_id ON items(user_id);
CREATE INDEX idx_items_category ON items(category);
CREATE INDEX idx_items_condition ON items(condition);
CREATE INDEX idx_items_tags ON items USING GIN(tags);
CREATE INDEX idx_items_created_at ON items(created_at DESC);
CREATE INDEX idx_items_is_favorite ON items(is_favorite);
```

#### item_images

```sql
CREATE TABLE item_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    is_primary BOOLEAN DEFAULT FALSE,
    width INTEGER,
    height INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_item_images_item_id ON item_images(item_id);
CREATE INDEX idx_item_images_is_primary ON item_images(is_primary);
```

#### item_colors

```sql
CREATE TABLE item_colors (
    item_id UUID PRIMARY KEY REFERENCES items(id) ON DELETE CASCADE,
    primary_color VARCHAR(7),
    secondary_color VARCHAR(7),
    color_hsl JSONB,
    is_manual BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3. Outfits

#### outfits

```sql
CREATE TABLE outfits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    item_ids UUID[] NOT NULL,
    tags JSONB DEFAULT '[]'::jsonb,
    is_favorite BOOLEAN DEFAULT FALSE,
    is_draft BOOLEAN DEFAULT TRUE,
    worn_count INTEGER DEFAULT 0,
    last_worn_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_outfits_user_id ON outfits(user_id);
CREATE INDEX idx_outfits_tags ON outfits USING GIN(tags);
CREATE INDEX idx_outfits_is_favorite ON outfits(is_favorite);
CREATE INDEX idx_outfits_created_at ON outfits(created_at DESC);
```

#### outfit_images

```sql
CREATE TABLE outfit_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    outfit_id UUID NOT NULL REFERENCES outfits(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    pose VARCHAR(20) NOT NULL,
    lighting VARCHAR(50),
    body_profile_id UUID REFERENCES body_profiles(id),
    generation_metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_outfit_images_outfit_id ON outfit_images(outfit_id);
CREATE INDEX idx_outfit_images_pose ON outfit_images(pose);
```

#### outfit_collections

```sql
CREATE TABLE outfit_collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_outfit_collections_user_id ON outfit_collections(user_id);
```

#### outfit_collection_items

```sql
CREATE TABLE outfit_collection_items (
    collection_id UUID REFERENCES outfit_collections(id) ON DELETE CASCADE,
    outfit_id UUID REFERENCES outfits(id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (collection_id, outfit_id)
);

CREATE INDEX idx_outfit_collection_items_collection_id ON outfit_collection_items(collection_id);
CREATE INDEX idx_outfit_collection_items_outfit_id ON outfit_collection_items(outfit_id);
```

### 4. Body Profiles

#### body_profiles

```sql
CREATE TABLE body_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    height_cm DECIMAL(5, 2) NOT NULL,
    weight_kg DECIMAL(5, 2) NOT NULL,
    body_shape VARCHAR(50) NOT NULL,
    skin_tone VARCHAR(50) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    encrypted_data BYTEA
);

CREATE INDEX idx_body_profiles_user_id ON body_profiles(user_id);
CREATE INDEX idx_body_profiles_is_default ON body_profiles(is_default);
```

### 5. Planning & Calendar

#### calendar_connections

```sql
CREATE TABLE calendar_connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL,
    email VARCHAR(255),
    access_token TEXT,
    refresh_token TEXT,
    token_expires_at TIMESTAMP,
    connected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_synced_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_calendar_connections_user_id ON calendar_connections(user_id);
```

#### calendar_events

```sql
CREATE TABLE calendar_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    calendar_id UUID REFERENCES calendar_connections(id),
    external_event_id VARCHAR(255),
    title VARCHAR(500) NOT NULL,
    description TEXT,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    location VARCHAR(500),
    attendees JSONB,
    outfit_id UUID REFERENCES outfits(id),
    synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_calendar_events_user_id ON calendar_events(user_id);
CREATE INDEX idx_calendar_events_start_time ON calendar_events(start_time);
CREATE INDEX idx_calendar_events_outfit_id ON calendar_events(outfit_id);
```

#### trips

```sql
CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    destination VARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    activities JSONB DEFAULT '[]'::jsonb,
    weather_expectation VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_trips_user_id ON trips(user_id);
```

#### trip_capsule_items

```sql
CREATE TABLE trip_capsule_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    suggested_quantity INTEGER DEFAULT 1,
    is_packed BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_trip_capsule_items_trip_id ON trip_capsule_items(trip_id);
```

### 6. AI & Recommendations

#### recommendation_logs

```sql
CREATE TABLE recommendation_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recommendation_type VARCHAR(50),
    items_shown UUID[],
    items_clicked UUID[],
    items_saved UUID[],
    items_worn UUID[],
    feedback JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_recommendation_logs_user_id ON recommendation_logs(user_id);
```

#### challenges

```sql
CREATE TABLE challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    rules TEXT,
    duration_days INTEGER NOT NULL,
    start_date DATE,
    end_date DATE,
    prize TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    participant_count INTEGER DEFAULT 0,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_challenges_is_active ON challenges(is_active);
```

#### challenge_participations

```sql
CREATE TABLE challenge_participations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    challenge_id UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    days_completed INTEGER DEFAULT 0,
    points INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    rank INTEGER,
    UNIQUE(user_id, challenge_id)
);

CREATE INDEX idx_challenge_participations_user_id ON challenge_participations(user_id);
```

### 7. Social Features

#### shared_outfits

```sql
CREATE TABLE shared_outfits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    outfit_id UUID NOT NULL REFERENCES outfits(id) ON DELETE CASCADE,
    share_url VARCHAR(255) UNIQUE,
    visibility VARCHAR(20) DEFAULT 'public',
    expires_at TIMESTAMP,
    caption TEXT,
    allow_feedback BOOLEAN DEFAULT TRUE,
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_shared_outfits_user_id ON shared_outfits(user_id);
```

#### share_feedback

```sql
CREATE TABLE share_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shared_outfit_id UUID NOT NULL REFERENCES shared_outfits(id) ON DELETE CASCADE,
    user_id UUID,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 8. Gamification

#### user_streaks

```sql
CREATE TABLE user_streaks (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_planned_date DATE,
    streak_freezes_remaining INTEGER DEFAULT 3,
    streak_skips_remaining INTEGER DEFAULT 1,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### user_achievements

```sql
CREATE TABLE user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id VARCHAR(100) NOT NULL,
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reward_claimed BOOLEAN DEFAULT FALSE,
    UNIQUE(user_id, achievement_id)
);

CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);
```

## Vector Store Schema (Pinecone)

### Item Embeddings

```python
{
    "id": "item_uuid",
    "values": [0.1, 0.2, 0.3, ...],  # 768-dim embedding
    "metadata": {
        "user_id": "user_uuid",
        "category": "tops",
        "colors": ["blue", "white"],
        "style": "casual",
        "sub_category": "t-shirt",
        "is_active": true
    },
    "namespace": "items"
}
```

### Index Configuration

```python
index_config = {
    "name": "fitcheck-items",
    "dimension": 768,  # Gemini embeddings dimension
    "metric": "cosine",
    "pods": 1,
    "pods_type": "p1.x1",
    "replicas": 1,
    "pod_type": "p1.x1"
}
```

## Pydantic Models

### User Models

```python
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime
from typing import Optional, List
from uuid import UUID

class UserBase(BaseModel):
    email: EmailStr
    full_name: Optional[str] = None

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None

class User(UserBase):
    id: UUID
    avatar_url: Optional[str] = None
    body_profile_id: Optional[UUID] = None
    created_at: datetime
    updated_at: datetime
    last_login_at: Optional[datetime] = None
    is_active: bool
    email_verified: bool

    class Config:
        from_attributes = True
```

### Item Models

```python
class ItemColor(BaseModel):
    hex: str
    name: str

class ItemBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    category: str
    sub_category: Optional[str] = None
    brand: Optional[str] = None
    colors: List[str] = []
    size: Optional[str] = None
    price: Optional[float] = Field(None, ge=0)
    purchase_date: Optional[datetime] = None
    purchase_location: Optional[str] = None
    tags: List[str] = []
    notes: Optional[str] = None
    condition: str = "clean"
    is_favorite: bool = False

class ItemCreate(ItemBase):
    pass

class ItemUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    category: Optional[str] = None
    sub_category: Optional[str] = None
    brand: Optional[str] = None
    colors: Optional[List[str]] = None
    size: Optional[str] = None
    price: Optional[float] = Field(None, ge=0)
    tags: Optional[List[str]] = None
    notes: Optional[str] = None
    condition: Optional[str] = None
    is_favorite: Optional[bool] = None

class ItemResponse(ItemBase):
    id: UUID
    user_id: UUID
    usage_times_worn: int
    usage_last_worn: Optional[datetime] = None
    cost_per_wear: Optional[float] = None
    created_at: datetime
    updated_at: datetime
    images: List[ItemImage] = []

    class Config:
        from_attributes = True

class ItemWithEmbedding(ItemResponse):
    embedding: Optional[List[float]] = None
```

### Outfit Models

```python
class OutfitBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    item_ids: List[UUID] = Field(..., min_length=1, max_length=10)
    tags: List[str] = []
    is_favorite: bool = False

class OutfitCreate(OutfitBase):
    pass

class OutfitUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    item_ids: Optional[List[UUID]] = Field(None, min_length=1, max_length=10)
    tags: Optional[List[str]] = None
    is_favorite: Optional[bool] = None

class OutfitResponse(OutfitBase):
    id: UUID
    user_id: UUID
    is_draft: bool
    worn_count: int
    last_worn_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    images: List[OutfitImage] = []

    class Config:
        from_attributes = True
```

### AI Generation Models

```python
class GenerationConfig(BaseModel):
    pose: str = "front"
    lighting: str = "natural"
    body_profile_id: Optional[UUID] = None
    variations: int = Field(1, ge=1, le=3)

class GenerationRequest(BaseModel):
    item_ids: List[UUID] = Field(..., min_length=1, max_length=10)
    config: GenerationConfig = GenerationConfig()

class GenerationResponse(BaseModel):
    generation_id: str
    status: str
    estimated_time: int

class GenerationResult(BaseModel):
    generation_id: str
    status: str
    progress: int
    images: Optional[List[str]] = []
    error: Optional[str] = None
```

### Recommendation Models

```python
class MatchResult(BaseModel):
    item: ItemResponse
    score: float = Field(..., ge=0, le=100)
    reasons: List[str] = []

class CompleteLookSuggestion(BaseModel):
    items: List[ItemResponse]
    match_score: float
    description: str

class RecommendationRequest(BaseModel):
    item_ids: List[UUID] = Field(..., min_length=1, max_length=5)
    match_type: str = "all"
    limit: int = Field(10, ge=1, le=20)

class RecommendationResponse(BaseModel):
    matches: List[MatchResult]
    complete_looks: List[CompleteLookSuggestion] = []
```

## TypeScript Interfaces

### Frontend Types

```typescript
// types/user.ts
export interface User {
  id: string;
  email: string;
  fullName?: string;
  avatarUrl?: string;
  createdAt: string;
  updatedAt: string;
  isActive: boolean;
}

export interface UserPreferences {
  favoriteColors: string[];
  preferredStyles: string[];
  likedBrands: string[];
  dislikedPatterns: string[];
  colorTemperature?: 'warm' | 'cool' | 'neutral';
}

// types/item.ts
export interface Item {
  id: string;
  userId: string;
  name: string;
  category: string;
  subCategory?: string;
  brand?: string;
  colors: string[];
  size?: string;
  price?: number;
  purchaseDate?: string;
  purchaseLocation?: string;
  tags: string[];
  notes?: string;
  condition: 'clean' | 'dirty' | 'laundry' | 'repair' | 'donate';
  usageTimesWorn: number;
  usageLastWorn?: string;
  costPerWear?: number;
  isFavorite: boolean;
  images: ItemImage[];
  createdAt: string;
  updatedAt: string;
}

export interface ItemImage {
  id: string;
  itemId: string;
  imageUrl: string;
  thumbnailUrl?: string;
  isPrimary: boolean;
}

// types/outfit.ts
export interface Outfit {
  id: string;
  userId: string;
  name: string;
  itemIds: string[];
  tags: string[];
  isFavorite: boolean;
  isDraft: boolean;
  wornCount: number;
  lastWornAt?: string;
  createdAt: string;
  updatedAt: string;
  images: OutfitImage[];
}

export interface OutfitImage {
  id: string;
  outfitId: string;
  imageUrl: string;
  pose: 'front' | 'left' | 'right' | 'back';
  lighting?: string;
}

// types/recommendation.ts
export interface MatchResult {
  item: Item;
  score: number;
  reasons: string[];
}

export interface RecommendationResponse {
  matches: MatchResult[];
  completeLooks: CompleteLookSuggestion[];
}

// types/api.ts
export interface ApiResponse<T> {
  data: T;
  message?: string;
}

export interface ApiError {
  error: string;
  code?: string;
  details?: Record<string, any>;
}
```

## Database Migrations

### Migration Strategy

**Tools:**
- Supabase Migrations (built-in)
- Version control via Git

**Migration Files:**
```
supabase/
├── migrations/
│   ├── 20240101000001_initial_schema.sql
│   ├── 20240102000002_add_body_profiles.sql
│   ├── 20240103000003_add_gamification.sql
│   └── ...
└── seed.sql
```

### Sample Migration

```sql
-- File: 20240101000001_initial_schema.sql

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    avatar_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_users_email ON users(email);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own data"
ON users FOR SELECT
USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own data"
ON users FOR UPDATE
USING (auth.uid()::text = id::text);
```

## Data Validation Rules

### Item Validation

```python
from pydantic import validator

class ItemCreate(BaseModel):
    name: str
    category: str
    price: Optional[float] = None

    @validator('category')
    def validate_category(cls, v):
        valid_categories = [
            'tops', 'bottoms', 'shoes', 'accessories',
            'outerwear', 'swimwear', 'activewear'
        ]
        if v.lower() not in valid_categories:
            raise ValueError(f'Invalid category. Must be one of: {valid_categories}')
        return v.lower()

    @validator('price')
    def validate_price(cls, v):
        if v is not None and v < 0:
            raise ValueError('Price must be non-negative')
        return v
```

### Outfit Validation

```python
class OutfitCreate(BaseModel):
    item_ids: List[UUID]

    @validator('item_ids')
    def validate_item_count(cls, v):
        if len(v) < 1:
            raise ValueError('At least one item required')
        if len(v) > 10:
            raise ValueError('Maximum 10 items allowed')
        return v

    @validator('item_ids')
    def validate_no_duplicates(cls, v):
        if len(v) != len(set(v)):
            raise ValueError('Duplicate items not allowed')
        return v
```

## Summary

**Total Tables:** 25+
**Total Pydantic Models:** 20+
**Total TypeScript Interfaces:** 15+
**Vector Dimensions:** 768 (Gemini Embeddings)
**Index Strategy:** User ID, Category, Created At, GIN for JSONB fields
**Constraints:** Foreign Keys, Unique, Check, Not Null
**Migrations:** Supabase built-in migrations
