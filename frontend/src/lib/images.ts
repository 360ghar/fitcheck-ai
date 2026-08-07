/**
 * Optimized Unsplash image URLs for blog/media imagery.
 *
 * Blog `featured_image_url` values are stored as Unsplash URLs like
 * `https://images.unsplash.com/photo-xxx?w=800&q=80` — a fixed 800px-wide
 * JPEG regardless of where the image is displayed. Unsplash's imgix endpoint
 * serves modern formats (AVIF/WebP) via `auto=format` and resizes per request,
 * so the renderer rewrites the URL at use time:
 *
 *   - `auto=format` lets the CDN negotiate AVIF/WebP from the browser's Accept
 *     header (measured ~62% smaller than the stored JPEG at the same width).
 *   - `w=<width>` + `srcset` serve only as many pixels as the layout needs
 *     (a 350px card on mobile should not download 800px).
 *   - `q=70` trades a little quality for a lot of bytes on card-sized images.
 *
 * Only `images.unsplash.com` URLs are rewritten; any other URL (e.g. a future
 * R2-hosted image) passes through untouched.
 */

const UNSPLASH_HOST = 'images.unsplash.com'

export function isUnsplashImageUrl(url: string): boolean {
  try {
    return new URL(url).hostname === UNSPLASH_HOST
  } catch {
    return false
  }
}

/**
 * Rewrite an Unsplash URL for a target display width. Non-Unsplash URLs are
 * returned unchanged. `auto=format` (AVIF/WebP negotiation) is the big win;
 * `w` and `q` right-size the download.
 */
export function unsplashSrc(url: string, width: number, quality = 70): string {
  if (!isUnsplashImageUrl(url)) return url
  const parsed = new URL(url)
  // Drop the stored params (e.g. `w=800&q=80`) so they cannot fight ours.
  parsed.search = ''
  parsed.searchParams.set('auto', 'format')
  parsed.searchParams.set('w', String(width))
  parsed.searchParams.set('q', String(quality))
  return parsed.toString()
}

/** Build a `srcset` (width descriptors) from the same base URL. Returns ''
 * for non-Unsplash URLs: the helper can only right-size Unsplash's imgix
 * endpoint, and a srcset of identical URLs would just make the browser pick
 * the largest one. */
export function unsplashSrcSet(url: string, widths: number[], quality = 70): string {
  if (!isUnsplashImageUrl(url)) return ''
  return widths.map((w) => `${unsplashSrc(url, w, quality)} ${w}w`).join(', ')
}
