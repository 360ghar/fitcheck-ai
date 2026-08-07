/**
 * Blog API endpoints (public read-side).
 *
 * Admin CRUD moved to the admin app (`admin/src/features/content/api/blog.ts`)
 * — the backend's `/api/v1/blog/admin/posts` endpoint is admin-app only.
 */

import { apiClient, getApiError } from './client'
import type {
  ApiEnvelope,
  BlogPost,
  BlogPostListResponse,
  BlogPostCategoriesResponse,
} from '../types'

// ============================================================================
// PUBLIC ENDPOINTS
// ============================================================================

/**
 * List all published blog posts with pagination
 */
export async function getBlogPosts(
  page: number = 1,
  pageSize: number = 10,
  category?: string,
  search?: string
): Promise<BlogPostListResponse> {
  try {
    const params: Record<string, string | number> = { page, page_size: pageSize }
    if (category) params.category = category
    if (search) params.search = search

    const response = await apiClient.get<ApiEnvelope<BlogPostListResponse>>('/api/v1/blog/posts', {
      params,
    })
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

/**
 * Get a single blog post by slug
 */
export async function getBlogPostBySlug(slug: string): Promise<BlogPost> {
  try {
    const response = await apiClient.get<ApiEnvelope<BlogPost>>(`/api/v1/blog/posts/${slug}`)
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

/**
 * Get all unique blog categories
 */
export async function getBlogCategories(): Promise<string[]> {
  try {
    const response = await apiClient.get<ApiEnvelope<BlogPostCategoriesResponse>>('/api/v1/blog/categories')
    return response.data.data.categories
  } catch (error) {
    throw getApiError(error)
  }
}
