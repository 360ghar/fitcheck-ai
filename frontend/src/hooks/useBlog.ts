/**
 * React Query hooks for blog data fetching
 */

import {
  useQuery,
  useMutation,
  useQueryClient,
  type UseQueryOptions,
  type UseMutationOptions,
} from '@tanstack/react-query'
import {
  getBlogPosts,
  getBlogPostBySlug,
  getBlogCategories,
  createBlogPost,
  updateBlogPost,
  deleteBlogPost,
  getAllBlogPosts,
} from '@/api/blog'
import type {
  BlogPost,
  BlogPostListResponse,
  BlogPostCreateRequest,
  BlogPostUpdateRequest,
} from '@/types'

// ============================================================================
// QUERY KEYS
// ============================================================================

export const blogKeys = {
  all: ['blog'] as const,
  lists: () => [...blogKeys.all, 'list'] as const,
  list: (filters: { page?: number; pageSize?: number; category?: string; search?: string }) =>
    [...blogKeys.lists(), filters] as const,
  adminLists: () => [...blogKeys.all, 'admin', 'list'] as const,
  adminList: (filters: { page?: number; pageSize?: number }) =>
    [...blogKeys.adminLists(), filters] as const,
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

// ============================================================================
// ADMIN HOOKS
// ============================================================================

/**
 * Hook to fetch all blog posts including unpublished (admin only)
 */
export function useAllBlogPosts(
  page: number = 1,
  pageSize: number = 20,
  includeUnpublished: boolean = true,
  options?: Omit<UseQueryOptions<BlogPostListResponse, Error>, 'queryKey' | 'queryFn'>
) {
  return useQuery({
    queryKey: blogKeys.adminList({ page, pageSize }),
    queryFn: () => getAllBlogPosts(page, pageSize, includeUnpublished),
    ...options,
  })
}

// ============================================================================
// MUTATIONS
// ============================================================================

/**
 * Hook to create a new blog post
 */
export function useCreateBlogPost(
  options?: Omit<UseMutationOptions<BlogPost, Error, BlogPostCreateRequest>, 'mutationFn'>
) {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: createBlogPost,
    onSuccess: () => {
      // Invalidate all blog lists
      queryClient.invalidateQueries({ queryKey: blogKeys.lists() })
      queryClient.invalidateQueries({ queryKey: blogKeys.adminLists() })
    },
    ...options,
  })
}

/**
 * Hook to update an existing blog post
 */
export function useUpdateBlogPost(
  options?: Omit<
    UseMutationOptions<BlogPost, Error, { slug: string; data: BlogPostUpdateRequest }>,
    'mutationFn'
  >
) {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: ({ slug, data }) => updateBlogPost(slug, data),
    onSuccess: (_, variables) => {
      // Invalidate specific post and all lists
      queryClient.invalidateQueries({ queryKey: blogKeys.detail(variables.slug) })
      queryClient.invalidateQueries({ queryKey: blogKeys.lists() })
      queryClient.invalidateQueries({ queryKey: blogKeys.adminLists() })
    },
    ...options,
  })
}

/**
 * Hook to delete a blog post
 */
export function useDeleteBlogPost(
  options?: Omit<UseMutationOptions<{ slug: string; deleted: boolean }, Error, string>, 'mutationFn'>
) {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: deleteBlogPost,
    onSuccess: (_, slug) => {
      // Remove specific post from cache and invalidate lists
      queryClient.removeQueries({ queryKey: blogKeys.detail(slug) })
      queryClient.invalidateQueries({ queryKey: blogKeys.lists() })
      queryClient.invalidateQueries({ queryKey: blogKeys.adminLists() })
    },
    ...options,
  })
}
