/**
 * useInfiniteBlogPosts — React Query infinite list for the blog index.
 *
 * Replaces the page-by-page Prev/Next URL navigation with infinite scroll. A
 * change to `category` or `search` changes the query key, so React Query resets
 * to page 1 automatically (no manual page reset). Each page's posts are appended
 * via `fetchNextPage` as the sentinel scrolls into view.
 */
import { useInfiniteQuery } from '@tanstack/react-query'
import { getBlogPosts } from '@/api/blog'
import type { BlogPostSummary } from '@/types'

export interface UseInfiniteBlogPostsOptions {
  category?: string
  search?: string
  pageSize?: number
  enabled?: boolean
}

export interface InfiniteBlogResult {
  posts: BlogPostSummary[]
  hasNextPage: boolean
  isFetchingNextPage: boolean
  isLoading: boolean
  isError: boolean
  error: unknown
  fetchNextPage: () => void
  refetch: () => void
}

export function useInfiniteBlogPosts({
  category,
  search,
  pageSize = 12,
  enabled = true,
}: UseInfiniteBlogPostsOptions): InfiniteBlogResult {
  const query = useInfiniteQuery({
    queryKey: ['blog', 'infinite', { category, search, pageSize }],
    queryFn: ({ pageParam }) => getBlogPosts(pageParam, pageSize, category, search),
    initialPageParam: 1,
    getNextPageParam: (lastPage) => (lastPage.has_next ? lastPage.page + 1 : undefined),
    enabled,
  })

  const posts = query.data?.pages.flatMap((page) => page.posts) ?? []

  return {
    posts,
    hasNextPage: Boolean(query.hasNextPage),
    isFetchingNextPage: query.isFetchingNextPage,
    isLoading: query.isLoading,
    isError: query.isError,
    error: query.error,
    fetchNextPage: () => {
      if (query.hasNextPage && !query.isFetchingNextPage) {
        void query.fetchNextPage()
      }
    },
    refetch: () => {
      void query.refetch()
    },
  }
}
