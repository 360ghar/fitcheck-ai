import type { BlogPostSummary, BlogPost } from '@/types'

/**
 * @deprecated This interface is kept for backward compatibility.
 * Use BlogPost from '@/types' instead.
 */
export interface BlogPostLegacy {
  slug: string
  title: string
  excerpt: string
  content: string
  category: string
  date: string
  readTime: string
  emoji: string
  keywords: string[]
  author: string
  authorTitle?: string
}

/**
 * Transform API BlogPost to legacy format for backward compatibility
 */
export function toLegacyFormat(post: BlogPost | BlogPostSummary): BlogPostLegacy {
  return {
    slug: post.slug,
    title: post.title,
    excerpt: post.excerpt,
    content: 'content' in post ? post.content : '',
    category: post.category,
    date: formatDate(post.date),
    readTime: post.read_time,
    emoji: post.emoji,
    keywords: post.keywords,
    author: post.author,
    authorTitle: post.author_title,
  }
}

/**
 * Format ISO date string to display format
 */
function formatDate(dateString: string): string {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })
}

/**
 * @deprecated Use useBlogPosts hook instead.
 * This function now returns empty array and should be replaced with API calls.
 */
export const blogPosts: BlogPostLegacy[] = []

/**
 * @deprecated Use useBlogPost hook instead.
 */
export function getBlogPostBySlug(_slug: string): BlogPostLegacy | undefined {
  console.warn('getBlogPostBySlug is deprecated. Use useBlogPost hook instead.')
  return undefined
}

/**
 * @deprecated Use useBlogPosts hook with category filter instead.
 */
export function getRelatedPosts(_currentSlug: string, _limit: number = 3): BlogPostLegacy[] {
  console.warn('getRelatedPosts is deprecated. Use useBlogPosts hook instead.')
  return []
}

/**
 * @deprecated Use useBlogPosts hook with category filter instead.
 */
export function getPostsByCategory(_category: string): BlogPostLegacy[] {
  console.warn('getPostsByCategory is deprecated. Use useBlogPosts hook instead.')
  return []
}

/**
 * @deprecated Use useBlogCategories hook instead.
 */
export const blogCategories: string[] = []

/**
 * Re-export types for convenience
 */
export type { BlogPost, BlogPostSummary }
