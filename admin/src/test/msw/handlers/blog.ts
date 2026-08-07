import { http, HttpResponse } from 'msw'
import type { HttpHandler } from 'msw'

/**
 * Blog fixtures + handlers — wire shapes mirror the FastAPI blog endpoints
 * (envelope `{ data, message }`, admin list under `data.posts`; POST/PUT
 * return `{ data: <post fields>, message }` per backend blog.py). The
 * fixture array is mutable so POST/PUT/DELETE tests exercise the full round
 * trip.
 */

export interface BlogPostFixture {
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
  created_at: string | null
  updated_at: string | null
}

export const blogFixtures: BlogPostFixture[] = [
  {
    id: 'post_1',
    slug: 'wardrobe-studio-guide',
    title: 'Wardrobe Studio Guide',
    excerpt: 'How to digitize your closet in 10 minutes.',
    content: '## Getting started\n\nUpload photos of your clothes to build your digital wardrobe.',
    category: 'Guides',
    date: '2026-07-02T00:00:00Z',
    read_time: '3 min read',
    emoji: '👔',
    keywords: ['wardrobe', 'closet', 'guide'],
    author: 'FitCheck AI Team',
    author_title: 'Product',
    is_published: true,
    featured_image_url: 'https://images.example.com/wardrobe.jpg',
    created_at: '2026-07-01T10:00:00Z',
    updated_at: '2026-07-01T10:00:00Z',
  },
  {
    id: 'post_2',
    slug: 'outfit-generation-tips',
    title: 'Outfit Generation Tips',
    excerpt: 'Get better AI outfit suggestions.',
    content: '## Tips\n\nDescribe the occasion to get more relevant outfits.',
    category: 'Guides',
    date: '2026-07-05T00:00:00Z',
    read_time: '4 min read',
    emoji: '✨',
    keywords: ['outfits', 'ai'],
    author: 'FitCheck AI Team',
    author_title: null,
    is_published: true,
    featured_image_url: null,
    created_at: '2026-07-04T09:00:00Z',
    updated_at: '2026-07-05T09:00:00Z',
  },
  {
    id: 'post_3',
    slug: 'seasonal-capsule-draft',
    title: 'Seasonal Capsule (Draft)',
    excerpt: 'Draft notes for the seasonal capsule post.',
    content: '## Draft\n\nCapsule wardrobe for autumn.',
    category: 'Style',
    date: '2026-08-01T00:00:00Z',
    read_time: '2 min read',
    emoji: '🍂',
    keywords: ['capsule', 'seasonal'],
    author: 'Ada Admin',
    author_title: 'Editor',
    is_published: false,
    featured_image_url: null,
    created_at: '2026-07-30T12:00:00Z',
    updated_at: null,
  },
]

function postEnvelope(post: BlogPostFixture) {
  // Backend contract: `data` IS the post fields (blog.py returns
  // `{ "data": created_post.model_dump(mode="json"), "message": ... }`).
  // The client's toBlogPost(envelope.data) parses post fields directly.
  return { data: post, message: 'OK' }
}

export interface BlogHandlersState {
  posts: BlogPostFixture[]
  requests: URL[]
}

export function createBlogHandlers(initial?: Partial<BlogHandlersState>) {
  const state: BlogHandlersState = {
    posts: structuredClone(blogFixtures),
    requests: [],
    ...initial,
  }

  const handlers: HttpHandler[] = [
    http.get('*/api/v1/blog/admin/posts', ({ request }) => {
      const url = new URL(request.url)
      state.requests.push(url)
      const status = url.searchParams.get('status')
      const category = url.searchParams.get('category')
      const q = url.searchParams.get('search')?.toLowerCase()
      let posts = state.posts
      if (status === 'published') posts = posts.filter((p) => p.is_published)
      if (status === 'draft') posts = posts.filter((p) => !p.is_published)
      if (category) posts = posts.filter((p) => p.category === category)
      if (q) {
        posts = posts.filter(
          (p) =>
            p.slug.includes(q) ||
            p.title.toLowerCase().includes(q) ||
            p.author.toLowerCase().includes(q) ||
            p.category.toLowerCase().includes(q),
        )
      }
      const page = Number(url.searchParams.get('page') ?? '1')
      const pageSize = Number(url.searchParams.get('page_size') ?? '100')
      const start = (page - 1) * pageSize
      const slice = posts.slice(start, start + pageSize)
      const totalPages = Math.max(1, Math.ceil(posts.length / pageSize))
      return HttpResponse.json({
        data: {
          posts: slice,
          total: posts.length,
          page,
          page_size: pageSize,
          total_pages: totalPages,
          has_next: page < totalPages,
          has_prev: page > 1,
        },
        message: 'OK',
      })
    }),

    http.post('*/api/v1/blog/posts', async ({ request }) => {
      const body = (await request.json()) as Omit<
        BlogPostFixture,
        'id' | 'created_at' | 'updated_at'
      >
      const post: BlogPostFixture = {
        ...body,
        id: `post_${state.posts.length + 1}`,
        created_at: '2026-08-07T00:00:00Z',
        updated_at: '2026-08-07T00:00:00Z',
      }
      state.posts.unshift(post)
      return HttpResponse.json(postEnvelope(post), { status: 201 })
    }),

    http.put('*/api/v1/blog/posts/:slug', async ({ request, params }) => {
      const slug = String(params.slug)
      const body = (await request.json()) as Partial<BlogPostFixture>
      const existing = state.posts.find((p) => p.slug === slug)
      if (!existing) {
        return HttpResponse.json(
          { error: 'Post not found', code: 'NOT_FOUND', details: {} },
          { status: 404 },
        )
      }
      const updated: BlogPostFixture = {
        ...existing,
        ...body,
        id: existing.id,
        updated_at: '2026-08-07T00:00:00Z',
      }
      state.posts[state.posts.indexOf(existing)] = updated
      return HttpResponse.json(postEnvelope(updated))
    }),

    http.delete('*/api/v1/blog/posts/:slug', ({ params }) => {
      const slug = String(params.slug)
      const existing = state.posts.find((p) => p.slug === slug)
      if (!existing) {
        return HttpResponse.json(
          { error: 'Post not found', code: 'NOT_FOUND', details: {} },
          { status: 404 },
        )
      }
      state.posts.splice(state.posts.indexOf(existing), 1)
      return HttpResponse.json({ data: { slug: existing.slug, deleted: true }, message: 'OK' })
    }),

    http.get('*/api/v1/blog/categories', () => {
      const categories = [
        ...new Set(state.posts.filter((p) => p.is_published).map((p) => p.category)),
      ]
      return HttpResponse.json({ data: { categories }, message: 'OK' })
    }),
  ]

  return { handlers, state }
}

export const blogHandlers = createBlogHandlers().handlers
