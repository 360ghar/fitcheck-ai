/**
 * Blog types for FitCheck AI
 */

// ============================================================================
// BLOG POST TYPES
// ============================================================================

export interface BlogPost {
  id: string;
  slug: string;
  title: string;
  excerpt: string;
  content: string;
  category: string;
  emoji: string;
  keywords: string[];
  author: string;
  author_title?: string;
  published: boolean;
  published_at?: string;
  created_at: string;
  updated_at: string;
  read_time?: string;
  featured_image_url?: string;
}

export interface BlogPostCreate {
  slug: string;
  title: string;
  excerpt: string;
  content: string;
  category: string;
  emoji: string;
  keywords: string[];
  author: string;
  author_title?: string;
  published: boolean;
  published_at?: string;
  featured_image_url?: string;
}

export interface BlogPostUpdate {
  slug?: string;
  title?: string;
  excerpt?: string;
  content?: string;
  category?: string;
  emoji?: string;
  keywords?: string[];
  author?: string;
  author_title?: string;
  published?: boolean;
  published_at?: string;
  featured_image_url?: string;
}

// ============================================================================
// BLOG CATEGORY TYPES
// ============================================================================

export interface BlogCategory {
  id: string;
  name: string;
  slug: string;
  description?: string;
  post_count: number;
  created_at: string;
}

export interface BlogCategoryCreate {
  name: string;
  slug: string;
  description?: string;
}

export interface BlogCategoryUpdate {
  name?: string;
  slug?: string;
  description?: string;
}

// ============================================================================
// BLOG LIST FILTERS
// ============================================================================

export interface BlogPostFilters {
  search?: string;
  category?: string;
  published?: boolean;
  page?: number;
  page_size?: number;
}

// ============================================================================
// PAGINATED RESPONSE
// ============================================================================

export interface PaginatedBlogPostsResponse {
  posts: BlogPost[];
  total: number;
  page: number;
  total_pages: number;
  has_next: boolean;
  has_prev: boolean;
}

// ============================================================================
// BLOG FORM DATA
// ============================================================================

export interface BlogPostFormData {
  title: string;
  slug: string;
  excerpt: string;
  content: string;
  category: string;
  emoji: string;
  keywords: string[];
  author: string;
  author_title: string;
  published: boolean;
  published_at: string;
}
