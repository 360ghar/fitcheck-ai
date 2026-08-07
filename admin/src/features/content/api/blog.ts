import { apiDelete, apiGet, apiPost, apiPut } from '@/shared/api/client'
import type { components } from '@/shared/api/schema'
import type { TableStateParams } from '@/shared/hooks/useTableState'

/**
 * Content feature API — the blog admin, ported from `frontend/src/api/blog.ts`
 * and typed against the generated OpenAPI contract.
 *
 * The backend declares blog responses as untyped dicts (`Dict[str, Any]`,
 * see backend/app/api/v1/blog.py + backend/app/models/blog.py), so `BlogPost`
 * is the local, defensively-parsed shape. Request bodies ARE typed
 * (`BlogPostCreate` / `BlogPostUpdate`).
 *
 * Endpoints (auth: backend `verify_admin` — is_admin flag or
 * @fitcheckaiapp.com; UI gates with content.read / content.write):
 *
 *   GET    /api/v1/blog/admin/posts     → { data: { posts, total, page, page_size, total_pages, has_next, has_prev }, message }
 *   GET    /api/v1/blog/posts/{slug}    → { data: BlogPost }            (public — PUBLISHED only)
 *   GET    /api/v1/blog/categories      → { data: { categories: string[] } } (public — published only)
 *   POST   /api/v1/blog/posts           → 201 { data: BlogPost }
 *   PUT    /api/v1/blog/posts/{slug}    → { data: BlogPost }
 *   DELETE /api/v1/blog/posts/{slug}    → { data: { slug, deleted } }
 */

type BlogPostCreate = components['schemas']['BlogPostCreate']
type BlogPostUpdate = components['schemas']['BlogPostUpdate']

export interface BlogPost {
  id: string
  slug: string
  title: string
  excerpt: string
  content: string
  category: string
  date: string
  read_time: string
  emoji: string
  keywords: string[]
  author: string
  author_title: string | null
  is_published: boolean
  featured_image_url: string | null
  created_at?: string
  updated_at?: string
}

export interface BlogPostListData {
  posts: BlogPost[]
  total: number
  page: number
  page_size: number
  total_pages: number
  has_next: boolean
  has_prev: boolean
}

interface BlogEnvelope<T> {
  data: T
  message?: string
}

export const blogKeys = {
  all: ['blog'] as const,
  adminPosts: (params: TableStateParams) => [...blogKeys.all, 'admin-posts', params] as const,
  adminAll: ['blog', 'admin-all'] as const,
  post: (slug: string) => [...blogKeys.all, 'post', slug] as const,
  categories: ['blog', 'categories'] as const,
}

function parseString(value: unknown): string {
  return typeof value === 'string' ? value : ''
}

function parseStringOrNull(value: unknown): string | null {
  return typeof value === 'string' && value.length > 0 ? value : null
}

function parseKeywords(value: unknown): string[] {
  if (!Array.isArray(value)) return []
  return value.filter((entry): entry is string => typeof entry === 'string')
}

/** Defensive parse of a raw post dict into the local BlogPost shape. */
export function toBlogPost(row: Record<string, unknown>): BlogPost {
  const created_at = parseStringOrNull(row['created_at'])
  const updated_at = parseStringOrNull(row['updated_at'])
  return {
    id: parseString(row['id']),
    slug: parseString(row['slug']),
    title: parseString(row['title']),
    excerpt: parseString(row['excerpt']),
    content: parseString(row['content']),
    category: parseString(row['category']),
    date: parseString(row['date']),
    read_time: parseString(row['read_time']),
    emoji: parseString(row['emoji']),
    keywords: parseKeywords(row['keywords']),
    author: parseString(row['author']),
    author_title: parseStringOrNull(row['author_title']),
    is_published: row['is_published'] === true,
    featured_image_url: parseStringOrNull(row['featured_image_url']),
    // exactOptionalPropertyTypes: only set optional timestamps when present.
    ...(created_at !== null ? { created_at } : {}),
    ...(updated_at !== null ? { updated_at } : {}),
  }
}

function parseListEnvelope(envelope: unknown): BlogPostListData {
  const data =
    typeof envelope === 'object' && envelope !== null
      ? (envelope as BlogEnvelope<Record<string, unknown>>).data
      : null
  const posts = Array.isArray(data?.['posts']) ? data['posts'] : []
  return {
    posts: posts.map((row) => toBlogPost(row as Record<string, unknown>)),
    total: typeof data?.['total'] === 'number' ? data['total'] : 0,
    page: typeof data?.['page'] === 'number' ? data['page'] : 1,
    page_size: typeof data?.['page_size'] === 'number' ? data['page_size'] : 20,
    total_pages: typeof data?.['total_pages'] === 'number' ? data['total_pages'] : 1,
    has_next: data?.['has_next'] === true,
    has_prev: data?.['has_prev'] === true,
  }
}

/**
 * Admin post list (includes drafts). Accepts the shared table-state params:
 * q → search, filters.status (published|draft|all), filters.category.
 */
export async function listAllPosts(params: TableStateParams): Promise<BlogPostListData> {
  const search = new URLSearchParams({
    page: String(params.page),
    page_size: String(params.page_size),
    include_unpublished: 'true',
  })
  if (params.q) search.set('search', params.q)
  if (params.filters.status && params.filters.status !== 'all') {
    search.set('status', params.filters.status)
  }
  if (params.filters.category && params.filters.category !== 'all') {
    search.set('category', params.filters.category)
  }
  const envelope = await apiGet<unknown>(`/api/v1/blog/admin/posts?${search.toString()}`)
  return parseListEnvelope(envelope)
}

/**
 * Load one post for editing. The backend has NO admin single-post GET; the
 * public `GET /blog/posts/{slug}` only returns published posts (a draft
 * would 404). Workaround: fetch the admin list filtered by slug. See report.
 */
export async function getPostForEdit(slug: string): Promise<BlogPost> {
  const search = new URLSearchParams({
    page: '1',
    page_size: '100',
    include_unpublished: 'true',
    search: slug,
  })
  const envelope = await apiGet<unknown>(`/api/v1/blog/admin/posts?${search.toString()}`)
  const list = parseListEnvelope(envelope)
  const match = list.posts.find((post) => post.slug === slug)
  if (!match) {
    throw new Error(`Blog post '${slug}' not found`)
  }
  return match
}

/** Public categories endpoint — categories of published posts only. */
export async function listBlogCategories(): Promise<string[]> {
  const envelope = await apiGet<unknown>('/api/v1/blog/categories')
  const data =
    typeof envelope === 'object' && envelope !== null
      ? (envelope as BlogEnvelope<Record<string, unknown>>).data
      : null
  const categories = data?.['categories']
  return Array.isArray(categories) ? categories.filter((entry): entry is string => typeof entry === 'string') : []
}

/**
 * Fetch the whole post catalogue (summaries only — no content bodies) by
 * paging through the admin list at the backend's max page_size (100).
 * Used to derive category stats and the editor's category picker.
 */
export async function fetchAllAdminPosts(maxPages = 20): Promise<BlogPost[]> {
  const baseParams: TableStateParams = {
    page: 1,
    page_size: 100,
    q: undefined,
    sort_by: undefined,
    sort_dir: undefined,
    filters: {},
  }
  const first = await listAllPosts(baseParams)
  const posts = [...first.posts]
  let total = first.total
  let page = 2
  while (posts.length < total && page <= maxPages) {
    const next = await listAllPosts({ ...baseParams, page })
    posts.push(...next.posts)
    total = next.total
    page += 1
  }
  return posts
}

export function createBlogPost(body: BlogPostCreate): Promise<BlogPost> {
  return apiPost<BlogEnvelope<Record<string, unknown>>>('/api/v1/blog/posts', body).then(
    (envelope) => toBlogPost(envelope.data),
  )
}

export function updateBlogPost(slug: string, body: BlogPostUpdate): Promise<BlogPost> {
  return apiPut<BlogEnvelope<Record<string, unknown>>>(
    `/api/v1/blog/posts/${encodeURIComponent(slug)}`,
    body,
  ).then((envelope) => toBlogPost(envelope.data))
}

export function deleteBlogPost(slug: string): Promise<{ slug: string; deleted: boolean }> {
  return apiDelete<BlogEnvelope<{ slug: string; deleted: boolean }>>(
    `/api/v1/blog/posts/${encodeURIComponent(slug)}`,
  ).then((envelope) => envelope.data)
}

/** Paginated shape consumed by useServerTable ({ items, total, page, page_size }). */
export interface BlogPostPage {
  items: BlogPost[]
  total: number
  page: number
  page_size: number
}

export async function listAdminPostsPage(params: TableStateParams): Promise<BlogPostPage> {
  const data = await listAllPosts(params)
  return { items: data.posts, total: data.total, page: data.page, page_size: data.page_size }
}

export type { BlogPostCreate, BlogPostUpdate }
