import type { BlogPost } from '@/features/content/api/blog'

/**
 * Categories are derived from posts — the backend has no category table
 * (`GET /blog/categories` returns distinct values of published posts).
 */

export interface CategoryStat {
  name: string
  total: number
  published: number
}

export function deriveCategoryStats(posts: readonly BlogPost[]): CategoryStat[] {
  const byName = new Map<string, CategoryStat>()
  for (const post of posts) {
    const name = post.category
    if (!name) continue
    const stat = byName.get(name) ?? { name, total: 0, published: 0 }
    stat.total += 1
    if (post.is_published) stat.published += 1
    byName.set(name, stat)
  }
  return [...byName.values()].sort((a, b) => a.name.localeCompare(b.name))
}

/** Distinct category names across all posts (sorted, case-insensitive). */
export function categoryNames(posts: readonly BlogPost[]): string[] {
  return [...new Set(posts.map((post) => post.category).filter(Boolean))]
    .sort((a, b) => a.localeCompare(b))
}
