import type { Context } from '@netlify/edge-functions'

const BACKEND_API_URL = 'https://fitcheck-backend.railway.app'
const SITE_URL = 'https://fitcheckaiapp.com'
const DEFAULT_OG_IMAGE = `${SITE_URL}/og-default.svg`
const OUTFIT_FALLBACK_IMAGE = `${SITE_URL}/og-outfit-fallback.svg`

interface OutfitImage {
  id: string
  image_url: string
  thumbnail_url?: string
  is_primary: boolean
}

interface PublicOutfit {
  id: string
  name: string
  description?: string | null
  style?: string | null
  season?: string | null
  occasion?: string | null
  tags: string[]
  images: OutfitImage[]
  items: Array<{
    id: string
    name: string
    category: string
    colors: string[]
    brand?: string | null
  }>
}

// User agent patterns for social media crawlers
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
  'Anthropic-AI',
  'CCBot',
  'Google-Extended',
]

function isCrawler(userAgent: string | null): boolean {
  if (!userAgent) return false
  return CRAWLER_USER_AGENTS.some((crawler) =>
    userAgent.toLowerCase().includes(crawler.toLowerCase())
  )
}

function escapeHtml(text: string): string {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;')
}

function generateOgTags(outfit: PublicOutfit, url: string): string {
  const title = escapeHtml(outfit.name || 'Shared Outfit')
  const description = escapeHtml(
    outfit.description ||
      `Check out this ${outfit.style || ''} outfit on FitCheck AI`.trim()
  )

  // Get primary image or first image
  const primaryImage = outfit.images?.find((img) => img.is_primary)
  const firstImage = outfit.images?.[0]
  const ogImage =
    primaryImage?.image_url || firstImage?.image_url || OUTFIT_FALLBACK_IMAGE

  // Build item summary for description
  const itemsSummary = outfit.items
    ?.slice(0, 5)
    .map((item) => item.name)
    .join(', ')
  const fullDescription = itemsSummary
    ? `${description}. Items: ${escapeHtml(itemsSummary)}`
    : description

  const tags = [
    outfit.style,
    outfit.season,
    outfit.occasion,
    ...(outfit.tags || []),
  ]
    .filter(Boolean)
    .slice(0, 5)

  return `
    <!-- Primary Meta Tags (Dynamic) -->
    <title>${title} | FitCheck AI</title>
    <meta name="title" content="${title} | FitCheck AI" />
    <meta name="description" content="${fullDescription}" />

    <!-- Open Graph / Facebook -->
    <meta property="og:type" content="article" />
    <meta property="og:url" content="${escapeHtml(url)}" />
    <meta property="og:title" content="${title}" />
    <meta property="og:description" content="${fullDescription}" />
    <meta property="og:image" content="${escapeHtml(ogImage)}" />
    <meta property="og:image:width" content="1200" />
    <meta property="og:image:height" content="630" />
    <meta property="og:site_name" content="FitCheck AI" />

    <!-- Twitter -->
    <meta name="twitter:card" content="summary_large_image" />
    <meta name="twitter:url" content="${escapeHtml(url)}" />
    <meta name="twitter:title" content="${title}" />
    <meta name="twitter:description" content="${fullDescription}" />
    <meta name="twitter:image" content="${escapeHtml(ogImage)}" />

    <!-- Additional -->
    ${tags
      .map((tag) => `<meta property="article:tag" content="${escapeHtml(tag!)}" />`)
      .join('\n    ')}
  `
}

export default async function handler(
  request: Request,
  context: Context
): Promise<Response> {
  const url = new URL(request.url)
  const userAgent = request.headers.get('user-agent')

  // Only process shared outfit routes
  const match = url.pathname.match(/^\/shared\/outfits\/([a-f0-9-]+)$/i)
  if (!match) {
    return context.next()
  }

  const outfitId = match[1]

  // For non-crawlers, pass through to the SPA
  if (!isCrawler(userAgent)) {
    return context.next()
  }

  try {
    // Fetch outfit data from backend
    const apiResponse = await fetch(
      `${BACKEND_API_URL}/api/v1/outfits/public/${outfitId}`,
      {
        headers: {
          Accept: 'application/json',
        },
      }
    )

    if (!apiResponse.ok) {
      // If outfit not found, still serve the page but with default OG tags
      return context.next()
    }

    const json = await apiResponse.json()
    const outfit: PublicOutfit = json.data

    // Get the original HTML response
    const response = await context.next()
    const html = await response.text()

    // Generate OG tags
    const ogTags = generateOgTags(outfit, url.href)

    // Inject OG tags into <head> - replace existing meta tags for crawlers
    const modifiedHtml = html.replace(
      /<head[^>]*>/i,
      `<head>${ogTags}`
    )

    return new Response(modifiedHtml, {
      status: response.status,
      headers: {
        ...Object.fromEntries(response.headers.entries()),
        'content-type': 'text/html; charset=utf-8',
      },
    })
  } catch (error) {
    console.error('Edge function error:', error)
    // On error, fall through to normal SPA rendering
    return context.next()
  }
}

export const config = {
  path: '/shared/outfits/*',
}
