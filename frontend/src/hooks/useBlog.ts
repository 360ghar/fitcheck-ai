/**
 * React Query hooks for blog data fetching (public read-side).
 *
 * Admin mutations moved to the admin app (`admin/src/features/content/`).
 */

import { useQuery, type UseQueryOptions } from '@tanstack/react-query'
import { getBlogPosts, getBlogPostBySlug, getBlogCategories } from '@/api/blog'
import type { BlogPost, BlogPostListResponse } from '@/types'

// ============================================================================
// QUERY KEYS
// ============================================================================

export const blogKeys = {
  all: ['blog'] as const,
  lists: () => [...blogKeys.all, 'list'] as const,
  list: (filters: { page?: number; pageSize?: number; category?: string; search?: string }) =>
    [...blogKeys.lists(), filters] as const,
  details: () => [...blogKeys.all, 'detail'] as const,
  detail: (slug: string) => [...blogKeys.details(), slug] as const,
  categories: () => [...blogKeys.all, 'categories'] as const,
}

// ============================================================================
// PUBLIC HOOKS
// ============================================================================

/**
 * Hook to fetch paginated blog posts
 */
export function useBlogPosts(
  page: number = 1,
  pageSize: number = 10,
  category?: string,
  search?: string,
  options?: Omit<UseQueryOptions<BlogPostListResponse, Error>, 'queryKey' | 'queryFn'>
) {
  return useQuery({
    queryKey: blogKeys.list({ page, pageSize, category, search }),
    queryFn: () => getBlogPosts(page, pageSize, category, search),
    ...options,
  })
}

/**
 * Hook to fetch a single blog post by slug
 */
export function useBlogPost(
  slug: string | undefined,
  options?: Omit<UseQueryOptions<BlogPost, Error>, 'queryKey' | 'queryFn'>
) {
  return useQuery({
    queryKey: blogKeys.detail(slug || ''),
    queryFn: () => getBlogPostBySlug(slug!),
    enabled: !!slug,
    ...options,
  })
}

/**
 * Hook to fetch all blog categories
 */
export function useBlogCategories(options?: Omit<UseQueryOptions<string[], Error>, 'queryKey' | 'queryFn'>) {
  return useQuery({
    queryKey: blogKeys.categories(),
    queryFn: getBlogCategories,
    ...options,
  })
}
