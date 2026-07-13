/**
 * Crawler-aware SEO for dynamic public routes (blog posts).
 * Shared outfits remain handled by og-tags.ts.
 */
import type { Context } from '@netlify/edge-functions'

const BACKEND_API_URL = 'https://fitcheck-backend.railway.app'
const SITE_URL = 'https://fitcheckaiapp.com'
const DEFAULT_OG_IMAGE = `${SITE_URL}/og-default.jpg`

const CRAWLER_USER_AGENTS = [
  'facebookexternalhit',
  'Facebot',
  'Twitterbot',
  'LinkedInBot',
  'Pinterest',
  'Slackbot',
  'WhatsApp',
  'TelegramBot',
  'Discordbot',
  'Googlebot',
  'bingbot',
  'Applebot',
  'ChatGPT-User',
  'GPTBot',
  'Claude-Web',
  'ClaudeBot',
  'Anthropic-AI',
  'anthropic-ai',
  'CCBot',
  'Google-Extended',
  'PerplexityBot',
  'Bytespider',
  'cohere-ai',
]

function isCrawler(userAgent: string | null): boolean {
  if (!userAgent) return false
  const ua = userAgent.toLowerCase()
  return CRAWLER_USER_AGENTS.some((crawler) => ua.includes(crawler.toLowerCase()))
}

function escapeHtml(text: string): string {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;')
}

interface BlogPost {
  slug: string
  title: string
  excerpt?: string
  content?: string
  date?: string
  updated_at?: string
  author?: string
  keywords?: string[]
  category?: string
  cover_image?: string
  image_url?: string
}

function generateBlogHead(post: BlogPost, url: string): string {
  const title = escapeHtml(`${post.title} | FitCheck AI Blog`)
  const description = escapeHtml(
    (post.excerpt || post.title || 'FitCheck AI blog').slice(0, 300)
  )
  const ogImage = escapeHtml(post.cover_image || post.image_url || DEFAULT_OG_IMAGE)
  const safeUrl = escapeHtml(url)
  const datePublished = post.date || new Date().toISOString()
  const dateModified = post.updated_at || datePublished
  const author = escapeHtml(post.author || 'FitCheck AI')

  const articleLd = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: post.title,
    description: post.excerpt || post.title,
    author: { '@type': 'Organization', name: post.author || 'FitCheck AI' },
    publisher: {
      '@type': 'Organization',
      name: 'FitCheck AI',
      logo: { '@type': 'ImageObject', url: DEFAULT_OG_IMAGE },
    },
    datePublished,
    dateModified,
    mainEntityOfPage: url,
    image: post.cover_image || post.image_url || DEFAULT_OG_IMAGE,
    keywords: (post.keywords || []).join(', '),
    articleSection: post.category,
  }

  return `
    <title>${title}</title>
    <meta name="title" content="${title}" />
    <meta name="description" content="${description}" />
    <link rel="canonical" href="${safeUrl}" />
    <meta property="og:type" content="article" />
    <meta property="og:url" content="${safeUrl}" />
    <meta property="og:title" content="${title}" />
    <meta property="og:description" content="${description}" />
    <meta property="og:image" content="${ogImage}" />
    <meta property="og:site_name" content="FitCheck AI" />
    <meta name="twitter:card" content="summary_large_image" />
    <meta name="twitter:url" content="${safeUrl}" />
    <meta name="twitter:title" content="${title}" />
    <meta name="twitter:description" content="${description}" />
    <meta name="twitter:image" content="${ogImage}" />
    <meta name="author" content="${author}" />
    <script type="application/ld+json">${JSON.stringify(articleLd)}</script>
  `
}

export default async function handler(
  request: Request,
  context: Context
): Promise<Response> {
  const url = new URL(request.url)
  const userAgent = request.headers.get('user-agent')

  const match = url.pathname.match(/^\/blog\/([a-z0-9-]+)\/?$/i)
  if (!match) {
    return context.next()
  }

  const slug = match[1]
  // Avoid treating category path as post slug when only /blog/category/...
  if (slug === 'category') {
    return context.next()
  }

  if (!isCrawler(userAgent)) {
    return context.next()
  }

  try {
    const apiResponse = await fetch(
      `${BACKEND_API_URL}/api/v1/blog/posts/${encodeURIComponent(slug)}`,
      { headers: { Accept: 'application/json' } }
    )

    if (!apiResponse.ok) {
      return context.next()
    }

    const json = await apiResponse.json()
    const post: BlogPost = json.data || json

    if (!post?.title) {
      return context.next()
    }

    const response = await context.next()
    const html = await response.text()
    const headTags = generateBlogHead(post, `${SITE_URL}/blog/${post.slug || slug}`)

    const modifiedHtml = html.replace(/<head[^>]*>/i, (open) => `${open}${headTags}`)

    return new Response(modifiedHtml, {
      status: response.status,
      headers: {
        ...Object.fromEntries(response.headers.entries()),
        'content-type': 'text/html; charset=utf-8',
      },
    })
  } catch (error) {
    console.error('seo-html edge error:', error)
    return context.next()
  }
}

export const config = {
  path: '/blog/*',
}
