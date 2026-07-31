/**
 * ItemImage component with loading and error handling
 * Displays wardrobe item images with fallback states
 */

import { useEffect, useRef, useState } from 'react'
import { Shirt, AlertTriangle } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Skeleton } from './skeleton'
import { ZoomableImage } from './zoomable-image'
import type { Item } from '@/types'

interface ItemImageProps {
  item: Item
  size?: 'sm' | 'md' | 'lg'
  className?: string
  /**
   * Enable click-to-zoom functionality. When true, clicking opens a lightbox.
   * Recommended for 'lg' size images where detail matters.
   * @default false
   */
  enableZoom?: boolean
}

const SIZE_CLASSES = {
  sm: 'h-10 w-10',
  md: 'h-16 w-16',
  lg: 'h-24 w-24',
}

const ICON_SIZES = {
  sm: 'h-4 w-4',
  md: 'h-6 w-6',
  lg: 'h-10 w-10',
}

/**
 * Get the best available image URL for an item.
 * Accepts wardrobe-normalized `images[]`, raw Supabase `item_images[]`, or flat `image_url`.
 */
function getImageUrl(item: Item, preferThumbnail: boolean = true): string | null {
  const raw = item as Item & {
    item_images?: Array<{
      image_url?: string
      thumbnail_url?: string
      is_primary?: boolean
    }>
  }

  const images =
    (raw.images && raw.images.length > 0
      ? raw.images
      : raw.item_images && raw.item_images.length > 0
        ? raw.item_images
        : null) as
      | Array<{ image_url?: string; thumbnail_url?: string; is_primary?: boolean }>
      | null

  if (images && images.length > 0) {
    const primaryImage = images.find((img) => img.is_primary) || images[0]
    if (preferThumbnail && primaryImage.thumbnail_url) {
      return primaryImage.thumbnail_url
    }
    if (primaryImage.image_url) {
      return primaryImage.image_url
    }
    if (primaryImage.thumbnail_url) {
      return primaryImage.thumbnail_url
    }
  }

  // Flat convenience fields used by some recommendation payloads
  if (raw.image_url) {
    return raw.image_url
  }

  return null
}

/**
 * Get category-based icon for fallback display
 */
function getCategoryIcon() {
  // Could extend with more category-specific icons
  return Shirt
}

/**
 * ItemImage - Displays item image with loading skeleton and error fallback
 *
 * Surface convention, and the divergence is deliberate:
 * - The image WRAPPERS carry `bg-card`, because item photos are matted WebP
 *   with a real alpha channel. The tile is the surface the cutout sits on, so
 *   it must be a known surface rather than whatever the caller happens to
 *   provide underneath. Paired with `object-contain` — these are fixed
 *   40/64/96px squares, so `cover` would centre-crop a portrait silhouette.
 * - The no-image and error FALLBACKS keep `bg-muted`, because those genuinely
 *   are placeholders, which is what that token should mean.
 * The `<Skeleton>` needs no surface of its own: it only renders inside
 * `{isLoading && …}` and unmounts on `onLoad`.
 */
export function ItemImage({ item, size = 'sm', className, enableZoom = false }: ItemImageProps) {
  const [isLoading, setIsLoading] = useState(true)
  const [hasError, setHasError] = useState(false)
  const wrapperRef = useRef<HTMLDivElement>(null)

  // For zoom, use full-size image instead of thumbnail
  const imageUrl = getImageUrl(item, !enableZoom && size === 'sm')
  const sizeClass = SIZE_CLASSES[size]
  const iconSize = ICON_SIZES[size]
  const CategoryIcon = getCategoryIcon()

  // Settle the skeleton from the element's OWN state, not only from `onLoad`.
  // `onLoad` is not dependable here: a cached image can finish before React
  // attaches the handler, and with `loading="lazy"` Chrome was observed holding
  // `complete === false` on an image that already reported
  // `naturalWidth === 700`, with no load event ever dispatched. This effect also
  // resets the flags when the source changes, which nothing did before.
  // `ZoomableImage` does not forward a ref, hence reading the img through the
  // wrapper. The <img> is never hidden while this is pending — see below.
  useEffect(() => {
    setIsLoading(true)
    setHasError(false)
  }, [imageUrl])

  useEffect(() => {
    // A failed image renders the fallback instead of the wrapper. When its
    // URL changes, the reset effect above first clears the error, which mounts
    // the new image; this effect then runs again and inspects that image. Keep
    // the error state stable until the source actually changes so a broken URL
    // does not bounce between the fallback and an immediate retry.
    if (hasError) return
    const img = wrapperRef.current?.querySelector('img')
    if (!img) return
    // Intrinsic width is the honest "has paintable pixels" signal.
    if (img.naturalWidth > 0) {
      setIsLoading(false)
      setHasError(false)
      return
    }
    if (img.complete) {
      // Finished with no intrinsic size: the fetch resolved to nothing.
      setIsLoading(false)
      setHasError(true)
      return
    }
    // Still in flight. `decode()` is a promise, so unlike the `load` event it
    // cannot be missed by arriving before the handler was attached — which is
    // what left the skeleton pulsing forever under a `loading="lazy"` image
    // whose load event never fired.
    // Older browsers and jsdom do not implement decode(); in those runtimes
    // the normal load/error handlers remain the source of truth.
    if (typeof img.decode !== 'function') return
    let cancelled = false
    img
      .decode()
      .then(() => {
        if (!cancelled) setIsLoading(false)
      })
      .catch(() => {
        // Aborted (source swapped mid-flight) or genuinely broken. `onError`
        // owns the error state; do not flag a failure from a cancelled decode.
      })
    return () => {
      cancelled = true
    }
  }, [imageUrl, hasError])

  // No image available
  if (!imageUrl) {
    return (
      <div
        className={cn(
          sizeClass,
          'rounded-lg bg-muted flex items-center justify-center text-muted-foreground',
          className
        )}
        role="img"
        aria-label={`No image available for ${item.name}`}
      >
        <CategoryIcon className={iconSize} />
      </div>
    )
  }

  // Image failed to load
  if (hasError) {
    return (
      <div
        className={cn(
          sizeClass,
          'rounded-lg bg-muted flex items-center justify-center',
          className
        )}
        role="img"
        aria-label={`Image for ${item.name} could not be loaded`}
      >
        <AlertTriangle className={cn(iconSize, 'text-muted-foreground')} />
      </div>
    )
  }

  // Use ZoomableImage when zoom is enabled
  if (enableZoom) {
    return (
      <div ref={wrapperRef} className={cn(sizeClass, 'relative overflow-hidden rounded-lg bg-card', className)}>
        {isLoading && (
          <Skeleton className="absolute inset-0" />
        )}
        {/* NEVER `opacity-0` while loading. The skeleton sits BEHIND the image,
            so an image with no pixels yet simply lets it show through, and one
            that has pixels paints over it. Hiding the img until a load callback
            fired is what made every cached thumbnail render as an empty box. */}
        <ZoomableImage
          src={imageUrl}
          alt={item.name}
          className="h-full w-full object-contain"
          onLoad={() => setIsLoading(false)}
          onError={() => {
            setIsLoading(false)
            setHasError(true)
          }}
        />
      </div>
    )
  }

  return (
    <div ref={wrapperRef} className={cn(sizeClass, 'relative overflow-hidden rounded-lg bg-card', className)}>
      {isLoading && (
        <Skeleton className="absolute inset-0" />
      )}
      {/* Not `opacity-0` while loading — see the note in the zoom branch. */}
      <img
        src={imageUrl}
        alt={item.name}
        className="h-full w-full object-contain"
        loading="lazy"
        decoding="async"
        onLoad={() => setIsLoading(false)}
        onError={() => {
          setIsLoading(false)
          setHasError(true)
        }}
      />
    </div>
  )
}

/**
 * ItemImageSimple - Lighter version for inline use without skeleton
 * Falls back immediately on missing/broken images
 */
export function ItemImageSimple({
  item,
  size = 'sm',
  className
}: ItemImageProps) {
  const [hasError, setHasError] = useState(false)

  const imageUrl = getImageUrl(item, size === 'sm')
  const sizeClass = SIZE_CLASSES[size]
  const iconSize = ICON_SIZES[size]
  const CategoryIcon = getCategoryIcon()

  // Clear a stale error when the item (and so the source) changes. No loading
  // flag here, so this variant never had the invisible-image failure above.
  useEffect(() => {
    setHasError(false)
  }, [imageUrl])

  if (!imageUrl || hasError) {
    return (
      <div
        className={cn(
          sizeClass,
          'rounded-lg bg-muted flex items-center justify-center text-muted-foreground',
          className
        )}
        role="img"
        aria-label={`No image available for ${item.name}`}
      >
        <CategoryIcon className={iconSize} />
      </div>
    )
  }

  return (
    <img
      src={imageUrl}
      alt={item.name}
      className={cn(sizeClass, 'rounded-lg bg-card object-contain', className)}
      loading="lazy"
      decoding="async"
      onError={() => setHasError(true)}
    />
  )
}
