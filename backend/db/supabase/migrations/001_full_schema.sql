-- FitCheck AI - Full Database Schema (single migration)
-- Consolidates and fixes prior migrations (incl. CREATE POLICY syntax).
--
-- Target: Supabase Postgres

BEGIN;

-- =============================================================================
-- EXTENSIONS
-- =============================================================================

-- Required for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- USERS & AUTH
-- =============================================================================

-- Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    avatar_url VARCHAR(500),
    body_profile_id UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    -- Puter linking
    puter_token TEXT,
    puter_username TEXT,
    puter_email TEXT,
    puter_uuid TEXT,
    puter_linked_at TIMESTAMP
);

-- Ensure Puter columns exist (safe when upgrading from partial schema)
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS puter_token TEXT,
  ADD COLUMN IF NOT EXISTS puter_username TEXT,
  ADD COLUMN IF NOT EXISTS puter_email TEXT,
  ADD COLUMN IF NOT EXISTS puter_uuid TEXT,
  ADD COLUMN IF NOT EXISTS puter_linked_at TIMESTAMP;

-- User preferences
CREATE TABLE IF NOT EXISTS public.user_preferences (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
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

ALTER TABLE public.user_preferences
  ADD COLUMN IF NOT EXISTS preferred_occasions JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS data_points_collected INTEGER DEFAULT 0;

-- User settings
CREATE TABLE IF NOT EXISTS public.user_settings (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
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

-- =============================================================================
-- WARDROBE MANAGEMENT
-- =============================================================================

-- Items table
CREATE TABLE IF NOT EXISTS public.items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
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
    is_deleted BOOLEAN DEFAULT FALSE,
    -- Enriched metadata (recommendations/categorization)
    material VARCHAR(50),
    pattern VARCHAR(50),
    style VARCHAR(50),
    materials JSONB DEFAULT '[]'::jsonb,
    seasonal_tags JSONB DEFAULT '[]'::jsonb,
    occasion_tags JSONB DEFAULT '[]'::jsonb
);

ALTER TABLE public.items
  ADD COLUMN IF NOT EXISTS material VARCHAR(50),
  ADD COLUMN IF NOT EXISTS pattern VARCHAR(50),
  ADD COLUMN IF NOT EXISTS style VARCHAR(50),
  ADD COLUMN IF NOT EXISTS materials JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS seasonal_tags JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS occasion_tags JSONB DEFAULT '[]'::jsonb;

-- Item images
CREATE TABLE IF NOT EXISTS public.item_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES public.items(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    storage_path TEXT,
    is_primary BOOLEAN DEFAULT FALSE,
    width INTEGER,
    height INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.item_images
  ADD COLUMN IF NOT EXISTS storage_path TEXT;

-- Item colors (for detailed color analysis)
CREATE TABLE IF NOT EXISTS public.item_colors (
    item_id UUID PRIMARY KEY REFERENCES public.items(id) ON DELETE CASCADE,
    primary_color VARCHAR(7),
    secondary_color VARCHAR(7),
    color_hsl JSONB,
    is_manual BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- BODY PROFILES
-- =============================================================================

-- Body profiles for AI generation
CREATE TABLE IF NOT EXISTS public.body_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
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

-- =============================================================================
-- OUTFITS
-- =============================================================================

-- Outfits table
CREATE TABLE IF NOT EXISTS public.outfits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    item_ids UUID[] NOT NULL,
    style VARCHAR(50),
    season VARCHAR(20),
    occasion VARCHAR(50),
    tags JSONB DEFAULT '[]'::jsonb,
    is_favorite BOOLEAN DEFAULT FALSE,
    is_draft BOOLEAN DEFAULT TRUE,
    is_public BOOLEAN DEFAULT FALSE,
    worn_count INTEGER DEFAULT 0,
    last_worn_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.outfits
  ADD COLUMN IF NOT EXISTS description TEXT,
  ADD COLUMN IF NOT EXISTS style VARCHAR(50),
  ADD COLUMN IF NOT EXISTS season VARCHAR(20),
  ADD COLUMN IF NOT EXISTS occasion VARCHAR(50),
  ADD COLUMN IF NOT EXISTS is_public BOOLEAN DEFAULT FALSE;

-- Outfit images (AI generated)
CREATE TABLE IF NOT EXISTS public.outfit_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    outfit_id UUID NOT NULL REFERENCES public.outfits(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    storage_path TEXT,
    pose VARCHAR(20) NOT NULL,
    lighting VARCHAR(50),
    body_profile_id UUID REFERENCES public.body_profiles(id) ON DELETE SET NULL,
    generation_type VARCHAR(20) DEFAULT 'ai',
    is_primary BOOLEAN DEFAULT TRUE,
    width INTEGER,
    height INTEGER,
    generation_metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.outfit_images
  ADD COLUMN IF NOT EXISTS storage_path TEXT,
  ADD COLUMN IF NOT EXISTS thumbnail_url VARCHAR(500),
  ADD COLUMN IF NOT EXISTS generation_type VARCHAR(20) DEFAULT 'ai',
  ADD COLUMN IF NOT EXISTS is_primary BOOLEAN DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS width INTEGER,
  ADD COLUMN IF NOT EXISTS height INTEGER;

-- Outfit collections
CREATE TABLE IF NOT EXISTS public.outfit_collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    is_favorite BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.outfit_collections
  ADD COLUMN IF NOT EXISTS is_favorite BOOLEAN DEFAULT FALSE;

-- Outfit collection items (junction table)
CREATE TABLE IF NOT EXISTS public.outfit_collection_items (
    collection_id UUID REFERENCES public.outfit_collections(id) ON DELETE CASCADE,
    outfit_id UUID REFERENCES public.outfits(id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (collection_id, outfit_id)
);

-- =============================================================================
-- OUTFIT GENERATION TRACKING (client-side generation)
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.outfit_generations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  outfit_id UUID NOT NULL REFERENCES public.outfits(id) ON DELETE CASCADE,
  status VARCHAR(20) NOT NULL DEFAULT 'processing',
  progress INTEGER DEFAULT 0,
  pose VARCHAR(20) DEFAULT 'front',
  lighting VARCHAR(50),
  body_profile_id UUID REFERENCES public.body_profiles(id) ON DELETE SET NULL,
  variations INTEGER DEFAULT 1,
  image_urls JSONB DEFAULT '[]'::jsonb,
  error TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  started_at TIMESTAMP,
  completed_at TIMESTAMP
);

-- =============================================================================
-- PLANNING: Calendar + Trips (MVP)
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.calendar_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  provider VARCHAR(50) NOT NULL,
  email VARCHAR(255),
  auth_code TEXT,
  access_token TEXT,
  refresh_token TEXT,
  token_expires_at TIMESTAMP,
  connected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_synced_at TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.calendar_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  calendar_id UUID REFERENCES public.calendar_connections(id) ON DELETE SET NULL,
  external_event_id VARCHAR(255),
  title VARCHAR(500) NOT NULL,
  description TEXT,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NOT NULL,
  location VARCHAR(500),
  attendees JSONB,
  outfit_id UUID REFERENCES public.outfits(id) ON DELETE SET NULL,
  synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trips + packing assistant (P1)
CREATE TABLE IF NOT EXISTS public.trips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  destination VARCHAR(255),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  activities JSONB DEFAULT '[]'::jsonb,
  weather_expectation VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.trip_capsule_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
  item_id UUID NOT NULL REFERENCES public.items(id) ON DELETE CASCADE,
  suggested_quantity INTEGER DEFAULT 1,
  is_packed BOOLEAN DEFAULT FALSE
);

-- =============================================================================
-- AI & RECOMMENDATIONS: feedback logging
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.recommendation_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  recommendation_type VARCHAR(50),
  items_shown UUID[],
  items_clicked UUID[],
  items_saved UUID[],
  items_worn UUID[],
  feedback JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- SOCIAL: share outfits + feedback
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.shared_outfits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  outfit_id UUID NOT NULL REFERENCES public.outfits(id) ON DELETE CASCADE,
  share_url VARCHAR(255) UNIQUE,
  visibility VARCHAR(20) DEFAULT 'public',
  expires_at TIMESTAMP,
  caption TEXT,
  allow_feedback BOOLEAN DEFAULT TRUE,
  view_count INTEGER DEFAULT 0,
  like_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.share_feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shared_outfit_id UUID NOT NULL REFERENCES public.shared_outfits(id) ON DELETE CASCADE,
  user_id UUID,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- GAMIFICATION: streaks + achievements + challenges
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.user_streaks (
  user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_planned_date DATE,
  streak_freezes_remaining INTEGER DEFAULT 3,
  streak_skips_remaining INTEGER DEFAULT 1,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  achievement_id VARCHAR(100) NOT NULL,
  earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  reward_claimed BOOLEAN DEFAULT FALSE,
  UNIQUE(user_id, achievement_id)
);

CREATE TABLE IF NOT EXISTS public.challenges (
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
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.challenge_participations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  challenge_id UUID NOT NULL REFERENCES public.challenges(id) ON DELETE CASCADE,
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  days_completed INTEGER DEFAULT 0,
  points INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  rank INTEGER,
  UNIQUE(user_id, challenge_id)
);

-- =============================================================================
-- INDEXES
-- =============================================================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON public.users(created_at DESC);

-- One Puter account should not be linked to multiple FitCheck users
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_puter_uuid_unique
  ON public.users (puter_uuid)
  WHERE puter_uuid IS NOT NULL;

-- Preferences/settings indexes
CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id ON public.user_preferences(user_id);

-- Items indexes
CREATE INDEX IF NOT EXISTS idx_items_user_id ON public.items(user_id);
CREATE INDEX IF NOT EXISTS idx_items_category ON public.items(category);
CREATE INDEX IF NOT EXISTS idx_items_condition ON public.items(condition);
CREATE INDEX IF NOT EXISTS idx_items_tags ON public.items USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_items_created_at ON public.items(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_items_is_favorite ON public.items(is_favorite);
CREATE INDEX IF NOT EXISTS idx_items_is_deleted ON public.items(is_deleted);

-- Item images indexes
CREATE INDEX IF NOT EXISTS idx_item_images_item_id ON public.item_images(item_id);
CREATE INDEX IF NOT EXISTS idx_item_images_is_primary ON public.item_images(is_primary);

-- Outfits indexes
CREATE INDEX IF NOT EXISTS idx_outfits_user_id ON public.outfits(user_id);
CREATE INDEX IF NOT EXISTS idx_outfits_tags ON public.outfits USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_outfits_is_favorite ON public.outfits(is_favorite);
CREATE INDEX IF NOT EXISTS idx_outfits_created_at ON public.outfits(created_at DESC);

-- Outfit images indexes
CREATE INDEX IF NOT EXISTS idx_outfit_images_outfit_id ON public.outfit_images(outfit_id);
CREATE INDEX IF NOT EXISTS idx_outfit_images_pose ON public.outfit_images(pose);

-- Outfit collections indexes
CREATE INDEX IF NOT EXISTS idx_outfit_collections_user_id ON public.outfit_collections(user_id);
CREATE INDEX IF NOT EXISTS idx_outfit_collection_items_collection_id ON public.outfit_collection_items(collection_id);
CREATE INDEX IF NOT EXISTS idx_outfit_collection_items_outfit_id ON public.outfit_collection_items(outfit_id);

-- Body profiles indexes
CREATE INDEX IF NOT EXISTS idx_body_profiles_user_id ON public.body_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_body_profiles_is_default ON public.body_profiles(is_default);

-- Outfit generations indexes
CREATE INDEX IF NOT EXISTS idx_outfit_generations_user_id ON public.outfit_generations(user_id);
CREATE INDEX IF NOT EXISTS idx_outfit_generations_outfit_id ON public.outfit_generations(outfit_id);

-- Calendar indexes
CREATE INDEX IF NOT EXISTS idx_calendar_connections_user_id ON public.calendar_connections(user_id);
CREATE INDEX IF NOT EXISTS idx_calendar_connections_provider ON public.calendar_connections(provider);
CREATE INDEX IF NOT EXISTS idx_calendar_events_user_id ON public.calendar_events(user_id);
CREATE INDEX IF NOT EXISTS idx_calendar_events_start_time ON public.calendar_events(start_time);
CREATE INDEX IF NOT EXISTS idx_calendar_events_outfit_id ON public.calendar_events(outfit_id);

-- Trips indexes
CREATE INDEX IF NOT EXISTS idx_trips_user_id ON public.trips(user_id);
CREATE INDEX IF NOT EXISTS idx_trip_capsule_items_trip_id ON public.trip_capsule_items(trip_id);

-- Recommendation logs
CREATE INDEX IF NOT EXISTS idx_recommendation_logs_user_id ON public.recommendation_logs(user_id);

-- Social
CREATE INDEX IF NOT EXISTS idx_shared_outfits_user_id ON public.shared_outfits(user_id);

-- Gamification
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON public.user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_challenges_is_active ON public.challenges(is_active);
CREATE INDEX IF NOT EXISTS idx_challenge_participations_user_id ON public.challenge_participations(user_id);

-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================

-- Enable RLS on all user-data tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.item_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.item_colors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.outfits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.outfit_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.outfit_collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.outfit_collection_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.body_profiles ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.outfit_generations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calendar_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calendar_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trip_capsule_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shared_outfits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.share_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenge_participations ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- RLS POLICIES (drop + recreate for idempotence)
-- =============================================================================

-- USERS
DROP POLICY IF EXISTS "Users can view own data" ON public.users;
DROP POLICY IF EXISTS "Users can update own data" ON public.users;

CREATE POLICY "Users can view own data"
    ON public.users FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own data"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

-- USER PREFERENCES
DROP POLICY IF EXISTS "Users can view own preferences" ON public.user_preferences;
DROP POLICY IF EXISTS "Users can insert own preferences" ON public.user_preferences;
DROP POLICY IF EXISTS "Users can update own preferences" ON public.user_preferences;

CREATE POLICY "Users can view own preferences"
    ON public.user_preferences FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own preferences"
    ON public.user_preferences FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own preferences"
    ON public.user_preferences FOR UPDATE
    USING (auth.uid() = user_id);

-- USER SETTINGS
DROP POLICY IF EXISTS "Users can view own settings" ON public.user_settings;
DROP POLICY IF EXISTS "Users can insert own settings" ON public.user_settings;
DROP POLICY IF EXISTS "Users can update own settings" ON public.user_settings;

CREATE POLICY "Users can view own settings"
    ON public.user_settings FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own settings"
    ON public.user_settings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own settings"
    ON public.user_settings FOR UPDATE
    USING (auth.uid() = user_id);

-- ITEMS
DROP POLICY IF EXISTS "Users can read own items" ON public.items;
DROP POLICY IF EXISTS "Users can insert own items" ON public.items;
DROP POLICY IF EXISTS "Users can update own items" ON public.items;
DROP POLICY IF EXISTS "Users can delete own items" ON public.items;

CREATE POLICY "Users can read own items"
    ON public.items FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own items"
    ON public.items FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own items"
    ON public.items FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own items"
    ON public.items FOR DELETE
    USING (auth.uid() = user_id);

-- ITEM IMAGES
DROP POLICY IF EXISTS "Users can read own item images" ON public.item_images;
DROP POLICY IF EXISTS "Users can insert own item images" ON public.item_images;
DROP POLICY IF EXISTS "Users can update own item images" ON public.item_images;
DROP POLICY IF EXISTS "Users can delete own item images" ON public.item_images;

CREATE POLICY "Users can read own item images"
    ON public.item_images FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.items
            WHERE items.id = item_images.item_id
            AND items.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own item images"
    ON public.item_images FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.items
            WHERE items.id = item_images.item_id
            AND items.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own item images"
    ON public.item_images FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.items
            WHERE items.id = item_images.item_id
            AND items.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete own item images"
    ON public.item_images FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.items
            WHERE items.id = item_images.item_id
            AND items.user_id = auth.uid()
        )
    );

-- ITEM COLORS
DROP POLICY IF EXISTS "Users can read own item colors" ON public.item_colors;
DROP POLICY IF EXISTS "Users can insert own item colors" ON public.item_colors;
DROP POLICY IF EXISTS "Users can update own item colors" ON public.item_colors;
DROP POLICY IF EXISTS "Users can delete own item colors" ON public.item_colors;

CREATE POLICY "Users can read own item colors"
    ON public.item_colors FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.items
            WHERE items.id = item_colors.item_id
            AND items.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own item colors"
    ON public.item_colors FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.items
            WHERE items.id = item_colors.item_id
            AND items.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own item colors"
    ON public.item_colors FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.items
            WHERE items.id = item_colors.item_id
            AND items.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete own item colors"
    ON public.item_colors FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.items
            WHERE items.id = item_colors.item_id
            AND items.user_id = auth.uid()
        )
    );

-- OUTFITS
DROP POLICY IF EXISTS "Users can read own outfits" ON public.outfits;
DROP POLICY IF EXISTS "Users can insert own outfits" ON public.outfits;
DROP POLICY IF EXISTS "Users can update own outfits" ON public.outfits;
DROP POLICY IF EXISTS "Users can delete own outfits" ON public.outfits;

CREATE POLICY "Users can read own outfits"
    ON public.outfits FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own outfits"
    ON public.outfits FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own outfits"
    ON public.outfits FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own outfits"
    ON public.outfits FOR DELETE
    USING (auth.uid() = user_id);

-- OUTFIT IMAGES
DROP POLICY IF EXISTS "Users can read own outfit images" ON public.outfit_images;
DROP POLICY IF EXISTS "Users can insert own outfit images" ON public.outfit_images;
DROP POLICY IF EXISTS "Users can update own outfit images" ON public.outfit_images;
DROP POLICY IF EXISTS "Users can delete own outfit images" ON public.outfit_images;

CREATE POLICY "Users can read own outfit images"
    ON public.outfit_images FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.outfits
            WHERE outfits.id = outfit_images.outfit_id
            AND outfits.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own outfit images"
    ON public.outfit_images FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.outfits
            WHERE outfits.id = outfit_images.outfit_id
            AND outfits.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own outfit images"
    ON public.outfit_images FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.outfits
            WHERE outfits.id = outfit_images.outfit_id
            AND outfits.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete own outfit images"
    ON public.outfit_images FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.outfits
            WHERE outfits.id = outfit_images.outfit_id
            AND outfits.user_id = auth.uid()
        )
    );

-- OUTFIT COLLECTIONS
DROP POLICY IF EXISTS "Users can read own outfit collections" ON public.outfit_collections;
DROP POLICY IF EXISTS "Users can insert own outfit collections" ON public.outfit_collections;
DROP POLICY IF EXISTS "Users can update own outfit collections" ON public.outfit_collections;
DROP POLICY IF EXISTS "Users can delete own outfit collections" ON public.outfit_collections;

CREATE POLICY "Users can read own outfit collections"
    ON public.outfit_collections FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own outfit collections"
    ON public.outfit_collections FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own outfit collections"
    ON public.outfit_collections FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own outfit collections"
    ON public.outfit_collections FOR DELETE
    USING (auth.uid() = user_id);

-- OUTFIT COLLECTION ITEMS
DROP POLICY IF EXISTS "Users can read own outfit collection items" ON public.outfit_collection_items;
DROP POLICY IF EXISTS "Users can insert own outfit collection items" ON public.outfit_collection_items;
DROP POLICY IF EXISTS "Users can delete own outfit collection items" ON public.outfit_collection_items;

CREATE POLICY "Users can read own outfit collection items"
    ON public.outfit_collection_items FOR SELECT
    USING (
      EXISTS (
        SELECT 1 FROM public.outfit_collections c
        WHERE c.id = outfit_collection_items.collection_id
        AND c.user_id = auth.uid()
      )
    );

CREATE POLICY "Users can insert own outfit collection items"
    ON public.outfit_collection_items FOR INSERT
    WITH CHECK (
      EXISTS (
        SELECT 1 FROM public.outfit_collections c
        WHERE c.id = outfit_collection_items.collection_id
        AND c.user_id = auth.uid()
      )
      AND EXISTS (
        SELECT 1 FROM public.outfits o
        WHERE o.id = outfit_collection_items.outfit_id
        AND o.user_id = auth.uid()
      )
    );

CREATE POLICY "Users can delete own outfit collection items"
    ON public.outfit_collection_items FOR DELETE
    USING (
      EXISTS (
        SELECT 1 FROM public.outfit_collections c
        WHERE c.id = outfit_collection_items.collection_id
        AND c.user_id = auth.uid()
      )
    );

-- BODY PROFILES
DROP POLICY IF EXISTS "Users can read own body profiles" ON public.body_profiles;
DROP POLICY IF EXISTS "Users can insert own body profiles" ON public.body_profiles;
DROP POLICY IF EXISTS "Users can update own body profiles" ON public.body_profiles;
DROP POLICY IF EXISTS "Users can delete own body profiles" ON public.body_profiles;

CREATE POLICY "Users can read own body profiles"
    ON public.body_profiles FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own body profiles"
    ON public.body_profiles FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own body profiles"
    ON public.body_profiles FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own body profiles"
    ON public.body_profiles FOR DELETE
    USING (auth.uid() = user_id);

-- OUTFIT GENERATIONS
DROP POLICY IF EXISTS "Users can read own outfit generations" ON public.outfit_generations;
DROP POLICY IF EXISTS "Users can insert own outfit generations" ON public.outfit_generations;
DROP POLICY IF EXISTS "Users can update own outfit generations" ON public.outfit_generations;
DROP POLICY IF EXISTS "Users can delete own outfit generations" ON public.outfit_generations;

CREATE POLICY "Users can read own outfit generations"
  ON public.outfit_generations FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own outfit generations"
  ON public.outfit_generations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own outfit generations"
  ON public.outfit_generations FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own outfit generations"
  ON public.outfit_generations FOR DELETE
  USING (auth.uid() = user_id);

-- CALENDAR CONNECTIONS
DROP POLICY IF EXISTS "Users can read own calendar connections" ON public.calendar_connections;
DROP POLICY IF EXISTS "Users can insert own calendar connections" ON public.calendar_connections;
DROP POLICY IF EXISTS "Users can update own calendar connections" ON public.calendar_connections;
DROP POLICY IF EXISTS "Users can delete own calendar connections" ON public.calendar_connections;

CREATE POLICY "Users can read own calendar connections"
  ON public.calendar_connections FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own calendar connections"
  ON public.calendar_connections FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own calendar connections"
  ON public.calendar_connections FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own calendar connections"
  ON public.calendar_connections FOR DELETE
  USING (auth.uid() = user_id);

-- CALENDAR EVENTS
DROP POLICY IF EXISTS "Users can read own calendar events" ON public.calendar_events;
DROP POLICY IF EXISTS "Users can insert own calendar events" ON public.calendar_events;
DROP POLICY IF EXISTS "Users can update own calendar events" ON public.calendar_events;
DROP POLICY IF EXISTS "Users can delete own calendar events" ON public.calendar_events;

CREATE POLICY "Users can read own calendar events"
  ON public.calendar_events FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own calendar events"
  ON public.calendar_events FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND (
      calendar_id IS NULL
      OR EXISTS (
        SELECT 1 FROM public.calendar_connections c
        WHERE c.id = calendar_events.calendar_id
        AND c.user_id = auth.uid()
      )
    )
  );

CREATE POLICY "Users can update own calendar events"
  ON public.calendar_events FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own calendar events"
  ON public.calendar_events FOR DELETE
  USING (auth.uid() = user_id);

-- TRIPS
DROP POLICY IF EXISTS "Users can read own trips" ON public.trips;
DROP POLICY IF EXISTS "Users can insert own trips" ON public.trips;
DROP POLICY IF EXISTS "Users can update own trips" ON public.trips;
DROP POLICY IF EXISTS "Users can delete own trips" ON public.trips;

CREATE POLICY "Users can read own trips"
  ON public.trips FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own trips"
  ON public.trips FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own trips"
  ON public.trips FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own trips"
  ON public.trips FOR DELETE
  USING (auth.uid() = user_id);

-- TRIP CAPSULE ITEMS
DROP POLICY IF EXISTS "Users can read own trip capsule items" ON public.trip_capsule_items;
DROP POLICY IF EXISTS "Users can insert own trip capsule items" ON public.trip_capsule_items;
DROP POLICY IF EXISTS "Users can update own trip capsule items" ON public.trip_capsule_items;
DROP POLICY IF EXISTS "Users can delete own trip capsule items" ON public.trip_capsule_items;

CREATE POLICY "Users can read own trip capsule items"
  ON public.trip_capsule_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.trips
      WHERE trips.id = trip_capsule_items.trip_id
      AND trips.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own trip capsule items"
  ON public.trip_capsule_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.trips
      WHERE trips.id = trip_capsule_items.trip_id
      AND trips.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own trip capsule items"
  ON public.trip_capsule_items FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.trips
      WHERE trips.id = trip_capsule_items.trip_id
      AND trips.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own trip capsule items"
  ON public.trip_capsule_items FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.trips
      WHERE trips.id = trip_capsule_items.trip_id
      AND trips.user_id = auth.uid()
    )
  );

-- RECOMMENDATION LOGS
DROP POLICY IF EXISTS "Users can read own recommendation logs" ON public.recommendation_logs;
DROP POLICY IF EXISTS "Users can insert own recommendation logs" ON public.recommendation_logs;

CREATE POLICY "Users can read own recommendation logs"
  ON public.recommendation_logs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own recommendation logs"
  ON public.recommendation_logs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- SHARED OUTFITS
DROP POLICY IF EXISTS "Users can read own shared outfits" ON public.shared_outfits;
DROP POLICY IF EXISTS "Users can insert own shared outfits" ON public.shared_outfits;
DROP POLICY IF EXISTS "Users can update own shared outfits" ON public.shared_outfits;
DROP POLICY IF EXISTS "Users can delete own shared outfits" ON public.shared_outfits;

CREATE POLICY "Users can read own shared outfits"
  ON public.shared_outfits FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own shared outfits"
  ON public.shared_outfits FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own shared outfits"
  ON public.shared_outfits FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own shared outfits"
  ON public.shared_outfits FOR DELETE
  USING (auth.uid() = user_id);

-- SHARE FEEDBACK
DROP POLICY IF EXISTS "Users can read feedback for own shared outfits" ON public.share_feedback;
DROP POLICY IF EXISTS "Anyone can insert share feedback" ON public.share_feedback;

CREATE POLICY "Users can read feedback for own shared outfits"
  ON public.share_feedback FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.shared_outfits
      WHERE shared_outfits.id = share_feedback.shared_outfit_id
      AND shared_outfits.user_id = auth.uid()
    )
  );

CREATE POLICY "Anyone can insert share feedback"
  ON public.share_feedback FOR INSERT
  WITH CHECK (true);

-- USER STREAKS
DROP POLICY IF EXISTS "Users can read own streaks" ON public.user_streaks;
DROP POLICY IF EXISTS "Users can insert own streaks" ON public.user_streaks;
DROP POLICY IF EXISTS "Users can update own streaks" ON public.user_streaks;

CREATE POLICY "Users can read own streaks"
  ON public.user_streaks FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own streaks"
  ON public.user_streaks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own streaks"
  ON public.user_streaks FOR UPDATE
  USING (auth.uid() = user_id);

-- USER ACHIEVEMENTS
DROP POLICY IF EXISTS "Users can read own achievements" ON public.user_achievements;
DROP POLICY IF EXISTS "Users can insert own achievements" ON public.user_achievements;

CREATE POLICY "Users can read own achievements"
  ON public.user_achievements FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own achievements"
  ON public.user_achievements FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- CHALLENGES
DROP POLICY IF EXISTS "Users can read challenges" ON public.challenges;

CREATE POLICY "Users can read challenges"
  ON public.challenges FOR SELECT
  USING (true);

-- CHALLENGE PARTICIPATIONS
DROP POLICY IF EXISTS "Users can participate in challenges" ON public.challenge_participations;
DROP POLICY IF EXISTS "Users can read own challenge participations" ON public.challenge_participations;

CREATE POLICY "Users can participate in challenges"
  ON public.challenge_participations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read own challenge participations"
  ON public.challenge_participations FOR SELECT
  USING (auth.uid() = user_id);

-- =============================================================================
-- FUNCTIONS & TRIGGERS
-- =============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update last_updated timestamp (user_preferences)
CREATE OR REPLACE FUNCTION public.update_last_updated_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- updated_at triggers (drop + recreate for idempotence)
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_items_updated_at ON public.items;
CREATE TRIGGER update_items_updated_at
    BEFORE UPDATE ON public.items
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_outfits_updated_at ON public.outfits;
CREATE TRIGGER update_outfits_updated_at
    BEFORE UPDATE ON public.outfits
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_settings_updated_at ON public.user_settings;
CREATE TRIGGER update_user_settings_updated_at
    BEFORE UPDATE ON public.user_settings
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_body_profiles_updated_at ON public.body_profiles;
CREATE TRIGGER update_body_profiles_updated_at
    BEFORE UPDATE ON public.body_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_outfit_collections_updated_at ON public.outfit_collections;
CREATE TRIGGER update_outfit_collections_updated_at
    BEFORE UPDATE ON public.outfit_collections
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_calendar_connections_updated_at ON public.calendar_connections;
CREATE TRIGGER update_calendar_connections_updated_at
    BEFORE UPDATE ON public.calendar_connections
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_calendar_events_updated_at ON public.calendar_events;
CREATE TRIGGER update_calendar_events_updated_at
    BEFORE UPDATE ON public.calendar_events
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_item_colors_updated_at ON public.item_colors;
CREATE TRIGGER update_item_colors_updated_at
    BEFORE UPDATE ON public.item_colors
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_streaks_updated_at ON public.user_streaks;
CREATE TRIGGER update_user_streaks_updated_at
    BEFORE UPDATE ON public.user_streaks
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- last_updated trigger for user_preferences (fixes incorrect prior trigger)
DROP TRIGGER IF EXISTS update_user_preferences_updated_at ON public.user_preferences;
DROP TRIGGER IF EXISTS update_user_preferences_last_updated ON public.user_preferences;
CREATE TRIGGER update_user_preferences_last_updated
    BEFORE UPDATE ON public.user_preferences
    FOR EACH ROW
    EXECUTE FUNCTION public.update_last_updated_column();

-- =============================================================================
-- STORAGE BUCKETS (optional, but required for app uploads)
-- =============================================================================

-- Buckets used by backend/app/services/storage_service.py
-- If these tables don't exist (non-Supabase Postgres), comment this section out.
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('fitcheck-images', 'fitcheck-images', true),
  ('items', 'items', true),
  ('outfits', 'outfits', true),
  ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- GRANTS
-- =============================================================================

GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;

COMMIT;
