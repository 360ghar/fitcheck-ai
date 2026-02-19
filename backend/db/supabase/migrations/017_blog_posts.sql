-- Migration: Blog Posts Table
-- Creates the blog_posts table for managing blog content

-- =============================================================================
-- BLOG POSTS TABLE
-- =============================================================================

CREATE TABLE IF NOT EXISTS blog_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    excerpt TEXT NOT NULL,
    content TEXT NOT NULL,
    category TEXT NOT NULL,
    date DATE NOT NULL,
    read_time TEXT NOT NULL,
    emoji TEXT NOT NULL,
    keywords TEXT[] DEFAULT '{}',
    author TEXT NOT NULL,
    author_title TEXT,
    is_published BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    featured_image_url TEXT
);

-- =============================================================================
-- INDEXES
-- =============================================================================

-- Index for slug lookups (used in public API)
CREATE INDEX IF NOT EXISTS idx_blog_posts_slug ON blog_posts(slug);

-- Index for category filtering
CREATE INDEX IF NOT EXISTS idx_blog_posts_category ON blog_posts(category);

-- Index for published status filtering
CREATE INDEX IF NOT EXISTS idx_blog_posts_published ON blog_posts(is_published);

-- Index for date ordering (newest first)
CREATE INDEX IF NOT EXISTS idx_blog_posts_date ON blog_posts(date DESC);

-- Composite index for common query pattern: published posts by category
CREATE INDEX IF NOT EXISTS idx_blog_posts_category_published ON blog_posts(category, is_published, date DESC);

-- GIN index for keyword searching
CREATE INDEX IF NOT EXISTS idx_blog_posts_keywords ON blog_posts USING GIN(keywords);

-- =============================================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================================

-- Enable RLS
ALTER TABLE blog_posts ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read published posts
CREATE POLICY "Anyone can read published blog posts"
    ON blog_posts
    FOR SELECT
    USING (is_published = true);

-- Policy: Only authenticated users with admin role can manage posts
-- Note: Admin checks are handled at the application level
CREATE POLICY "Authenticated users can read all blog posts"
    ON blog_posts
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Authenticated users can manage blog posts"
    ON blog_posts
    FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- =============================================================================
-- UPDATED_AT TRIGGER
-- =============================================================================

CREATE OR REPLACE FUNCTION update_blog_posts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_blog_posts_updated_at
    BEFORE UPDATE ON blog_posts
    FOR EACH ROW
    EXECUTE FUNCTION update_blog_posts_updated_at();

-- =============================================================================
-- COMMENTS
-- =============================================================================

COMMENT ON TABLE blog_posts IS 'Blog posts for the FitCheck AI blog';
COMMENT ON COLUMN blog_posts.slug IS 'URL-friendly unique identifier for the post';
COMMENT ON COLUMN blog_posts.excerpt IS 'Short summary for previews and SEO';
COMMENT ON COLUMN blog_posts.content IS 'Full markdown content of the post';
COMMENT ON COLUMN blog_posts.read_time IS 'Estimated reading time (e.g., "5 min read")';
COMMENT ON COLUMN blog_posts.keywords IS 'Array of SEO keywords/tags';
COMMENT ON COLUMN blog_posts.is_published IS 'Whether the post is publicly visible';
COMMENT ON COLUMN blog_posts.featured_image_url IS 'Optional hero image URL for the post';
