import { useState } from 'react'
import { cn } from '@/lib/utils'
import { unsplashSrc, unsplashSrcSet } from '@/lib/images'

interface BlogImageProps {
  src?: string | null
  alt: string
  /** Emoji shown when there is no image or the image fails to load. */
  emoji?: string | null
  /** Tailwind classes for the fallback emoji span (size/transform). */
  emojiClassName?: string
  /** Tailwind classes for the <img> element. */
  imgClassName?: string
  sizes: string
  widths: number[]
  quality?: number
  /** Skip lazy-loading for above-the-fold images. */
  priority?: boolean
  width: number
  height: number
}

/**
 * Blog card / hero image with responsive Unsplash srcset and a graceful
 * fallback.
 *
 * - Rewrites the stored Unsplash URL to `auto=format&w=…&q=…` so the CDN
 *   serves AVIF/WebP at the right size (see lib/images.ts).
 * - `onError` swaps a dead image (e.g. a removed Unsplash photo) for the
 *   post's emoji instead of a broken-image icon or a console 404.
 */
export function BlogImage({
  src,
  alt,
  emoji,
  emojiClassName,
  imgClassName,
  sizes,
  widths,
  quality = 70,
  priority = false,
  width,
  height,
}: BlogImageProps) {
  const [failed, setFailed] = useState(false)

  if (!src || failed) {
    return emoji ? (
      <span className={cn('relative z-10', emojiClassName)} aria-hidden="true">
        {emoji}
      </span>
    ) : null
  }

  const srcUrl = unsplashSrc(src, widths[Math.floor(widths.length / 2)], quality)
  const srcSet = unsplashSrcSet(src, widths, quality)

  // `fetchpriority` is passed lowercase: React 18 does not know the camelCase
  // `fetchPriority` prop yet (React 19 does) and warns + drops it.
  return (
    <img
      src={srcUrl}
      srcSet={srcSet || undefined}
      sizes={sizes}
      alt={alt}
      width={width}
      height={height}
      loading={priority ? 'eager' : 'lazy'}
      {...(priority ? { fetchpriority: 'high' } : {})}
      decoding="async"
      onError={() => setFailed(true)}
      className={cn('absolute inset-0 w-full h-full object-cover', imgClassName)}
    />
  )
}
