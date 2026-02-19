/**
 * Blog API endpoints
 */

import { apiClient, getApiError } from './client'
import type {
  ApiEnvelope,
  BlogPost,
  BlogPostListResponse,
  BlogPostCategoriesResponse,
  BlogPostCreateRequest,
  BlogPostUpdateRequest,
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

// ============================================================================
// ADMIN ENDPOINTS
// ============================================================================

/**
 * Create a new blog post (admin only)
 */
export async function createBlogPost(postData: BlogPostCreateRequest): Promise<BlogPost> {
  try {
    const response = await apiClient.post<ApiEnvelope<BlogPost>>('/api/v1/blog/posts', postData)
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

/**
 * Update an existing blog post (admin only)
 */
export async function updateBlogPost(slug: string, postData: BlogPostUpdateRequest): Promise<BlogPost> {
  try {
    const response = await apiClient.put<ApiEnvelope<BlogPost>>(`/api/v1/blog/posts/${slug}`, postData)
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

/**
 * Delete a blog post (admin only)
 */
export async function deleteBlogPost(slug: string): Promise<{ slug: string; deleted: boolean }> {
  try {
    const response = await apiClient.delete<ApiEnvelope<{ slug: string; deleted: boolean }>>(
      `/api/v1/blog/posts/${slug}`
    )
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

/**
 * List all blog posts including unpublished (admin only)
 */
export async function getAllBlogPosts(
  page: number = 1,
  pageSize: number = 20,
  includeUnpublished: boolean = true
): Promise<BlogPostListResponse> {
  try {
    const response = await apiClient.get<ApiEnvelope<BlogPostListResponse>>('/api/v1/blog/admin/posts', {
      params: { page, page_size: pageSize, include_unpublished: includeUnpublished },
    })
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

/**
 * Generate a slug from a title
 */
export function generateSlug(title: string): string {
  return title
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '')
    .replace(/[\s_-]+/g, '-')
    .replace(/^-+|-+$/g, '')
}

/**
 * Calculate read time for content
 */
export function calculateReadTime(content: string): string {
  const wordsPerMinute = 200
  const wordCount = content.trim().split(/\s+/).length
  const minutes = Math.ceil(wordCount / wordsPerMinute)
  return `${minutes} min read`
}
