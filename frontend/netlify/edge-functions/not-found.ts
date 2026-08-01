/**
 * Crawler soft-404 guard.
 *
 * The SPA fallback (`/* → /index.html`, 200) makes every unknown URL look
 * indexable. For search/AI crawlers, paths outside the known public surface
 * get a real 404 with `X-Robots-Tag: noindex` so Google, Bing and AI engines
 * don't index garbage URLs. Real users still get the SPA fallback.
 *
 * Runs after og-tags (shared outfits) and seo-html (blog) in netlify.toml;
 * those functions return a Response for the paths they own, ending the chain.
 */
import type { Context } from '@netlify/edge-functions'

// Exact public paths (see scripts/seo-content.mjs — keep in sync)
const EXACT_PUBLIC = new Set([
  '/',
  '/features',
  '/features/ai-wardrobe-extraction',
  '/features/virtual-try-on',
  '/features/ai-photoshoot-generator',
  '/features/outfit-recommendations',
  '/features/wardrobe-analytics',
  '/about',
  '/faq',
  '/blog',
  '/support',
  '/privacy',
  '/terms',
  '/tools/cost-per-wear-calculator',
])

// Prefixes that are valid public or app surfaces (app routes are robots-disallowed)
const KNOWN_PREFIXES = [
  '/features/',
  '/blog/',
  '/best/',
  '/compare/',
  '/alternatives/',
  '/for/',
  '/guides/',
  '/wear/',
  '/tools/',
  '/shared/outfits/',
  '/dashboard',
  '/wardrobe',
  '/outfits',
  '/calendar',
  '/recommendations',
  '/try-on',
  '/photoshoot',
  '/gamification',
  '/profile',
  '/settings',
  '/auth/',
  '/admin/',
  '/api/',
  '/.well-known/',
  '/.netlify/',
  '/assets/',
]

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
  'OAI-SearchBot',
  'Claude-Web',
  'ClaudeBot',
  'Anthropic-AI',
  'anthropic-ai',
  'CCBot',
  'Google-Extended',
  'PerplexityBot',
  'Perplexity-User',
  'Bytespider',
  'cohere-ai',
  'Meta-ExternalAgent',
  'Amazonbot',
  'YouBot',
  'Grokbot',
]

function isCrawler(userAgent: string | null): boolean {
  if (!userAgent) return false
  const ua = userAgent.toLowerCase()
  return CRAWLER_USER_AGENTS.some((crawler) => ua.includes(crawler.toLowerCase()))
}

function hasFileExtension(pathname: string): boolean {
  return /\.[a-z0-9]{1,8}$/i.test(pathname) && !pathname.endsWith('/')
}

function isKnownPath(pathname: string): boolean {
  const clean = pathname.replace(/\/+$/, '') || '/'
  if (EXACT_PUBLIC.has(clean) || EXACT_PUBLIC.has(pathname)) return true
  if (KNOWN_PREFIXES.some((prefix) => pathname.startsWith(prefix))) return true
  if (pathname === '/index.html' || pathname === '/') return true
  return false
}

export default async function handler(
  request: Request,
  context: Context
): Promise<Response> {
  const url = new URL(request.url)
  const userAgent = request.headers.get('user-agent')

  if (!isCrawler(userAgent)) {
    return context.next()
  }

  if (hasFileExtension(url.pathname) || isKnownPath(url.pathname)) {
    return context.next()
  }

  return new Response(
    '<!doctype html><html><head><meta name="robots" content="noindex, nofollow"><title>404 — Not found</title></head><body><h1>404</h1><p>Page not found.</p></body></html>',
    {
      status: 404,
      headers: {
        'content-type': 'text/html; charset=utf-8',
        'x-robots-tag': 'noindex, nofollow',
      },
    }
  )
}

export const config = {
  path: '/*',
}
