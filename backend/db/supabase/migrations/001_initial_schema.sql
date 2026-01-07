-- FitCheck AI - Initial Database Schema
-- Run this in Supabase SQL Editor or via migration

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- USERS & AUTH
-- ============================================================================

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
    email_verified BOOLEAN DEFAULT FALSE
);

-- User preferences
CREATE TABLE IF NOT EXISTS public.user_preferences (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    favorite_colors JSONB DEFAULT '[]'::jsonb,
    preferred_styles JSONB DEFAULT '[]'::jsonb,
    liked_brands JSONB DEFAULT '[]'::jsonb,
    disliked_patterns JSONB DEFAULT '[]'::jsonb,
    color_temperature VARCHAR(20),
    style_personality VARCHAR(50),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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

-- ============================================================================
-- WARDROBE MANAGEMENT
-- ============================================================================

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
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Item images
CREATE TABLE IF NOT EXISTS public.item_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES public.items(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    is_primary BOOLEAN DEFAULT FALSE,
    width INTEGER,
    height INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Item colors (for detailed color analysis)
CREATE TABLE IF NOT EXISTS public.item_colors (
    item_id UUID PRIMARY KEY REFERENCES public.items(id) ON DELETE CASCADE,
    primary_color VARCHAR(7),
    secondary_color VARCHAR(7),
    color_hsl JSONB,
    is_manual BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- OUTFITS
-- ============================================================================

-- Outfits table
CREATE TABLE IF NOT EXISTS public.outfits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
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

-- Outfit images (AI generated)
CREATE TABLE IF NOT EXISTS public.outfit_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    outfit_id UUID NOT NULL REFERENCES public.outfits(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    pose VARCHAR(20) NOT NULL,
    lighting VARCHAR(50),
    body_profile_id UUID,
    generation_metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Outfit collections
CREATE TABLE IF NOT EXISTS public.outfit_collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Outfit collection items (junction table)
CREATE TABLE IF NOT EXISTS public.outfit_collection_items (
    collection_id UUID REFERENCES public.outfit_collections(id) ON DELETE CASCADE,
    outfit_id UUID REFERENCES public.outfits(id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (collection_id, outfit_id)
);

-- ============================================================================
-- BODY PROFILES
-- ============================================================================

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

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON public.users(created_at DESC);

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

-- Body profiles indexes
CREATE INDEX IF NOT EXISTS idx_body_profiles_user_id ON public.body_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_body_profiles_is_default ON public.body_profiles(is_default);

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

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

-- ============================================================================
-- RLS POLICIES
-- ============================================================================

-- Users policies
CREATE POLICY "Users can view own data"
    ON public.users FOR SELECT
    USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own data"
    ON public.users FOR UPDATE
    USING (auth.uid()::text = id::text);

-- User preferences policies
CREATE POLICY "Users can view own preferences"
    ON public.user_preferences FOR SELECT
    USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own preferences"
    ON public.user_preferences FOR INSERT
    WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own preferences"
    ON public.user_preferences FOR UPDATE
    USING (auth.uid()::text = user_id::text);

-- User settings policies
CREATE POLICY "Users can view own settings"
    ON public.user_settings FOR SELECT
    USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own settings"
    ON public.user_settings FOR INSERT
    WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own settings"
    ON public.user_settings FOR UPDATE
    USING (auth.uid()::text = user_id::text);

-- Items policies
CREATE POLICY "Users can read own items"
    ON public.items FOR SELECT
    USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own items"
    ON public.items FOR INSERT
    WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own items"
    ON public.items FOR UPDATE
    USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own items"
    ON public.items FOR DELETE
    USING (auth.uid()::text = user_id::text);

-- Item images policies
CREATE POLICY "Users can read own item images"
    ON public.item_images FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.items
            WHERE items.id = item_images.item_id
            AND items.user_id::text = auth.uid()::text
        )
    );

CREATE POLICY "Users can insert own item images"
    ON public.item_images FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.items
            WHERE items.id = item_images.item_id
            AND items.user_id::text = auth.uid()::text
        )
    );

-- Outfits policies
CREATE POLICY "Users can read own outfits"
    ON public.outfits FOR SELECT
    USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own outfits"
    ON public.outfits FOR INSERT
    WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own outfits"
    ON public.outfits FOR UPDATE
    USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own outfits"
    ON public.outfits FOR DELETE
    USING (auth.uid()::text = user_id::text);

-- Outfit images policies
CREATE POLICY "Users can read own outfit images"
    ON public.outfit_images FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.outfits
            WHERE outfits.id = outfit_images.outfit_id
            AND outfits.user_id::text = auth.uid()::text
        )
    );

CREATE POLICY "Users can insert own outfit images"
    ON public.outfit_images FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.outfits
            WHERE outfits.id = outfit_images.outfit_id
            AND outfits.user_id::text = auth.uid()::text
        )
    );

-- Body profiles policies
CREATE POLICY "Users can read own body profiles"
    ON public.body_profiles FOR SELECT
    USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own body profiles"
    ON public.body_profiles FOR INSERT
    WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own body profiles"
    ON public.body_profiles FOR UPDATE
    USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own body profiles"
    ON public.body_profiles FOR DELETE
    USING (auth.uid()::text = user_id::text);

-- ============================================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_items_updated_at
    BEFORE UPDATE ON public.items
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_outfits_updated_at
    BEFORE UPDATE ON public.outfits
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at
    BEFORE UPDATE ON public.user_preferences
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- STORAGE BUCKETS
-- ============================================================================

-- Create storage buckets (run these in Supabase Storage section or via API)
-- bucket names: item-images, outfit-images, user-avatars

-- ============================================================================
-- INITIAL SETUP COMPLETE
-- ============================================================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
