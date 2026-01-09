/**
 * ItemImage component with loading and error handling
 * Displays wardrobe item images with fallback states
 */

import { useState } from 'react'
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
 * Get the best available image URL for an item
 */
function getImageUrl(item: Item, preferThumbnail: boolean = true): string | null {
  if (!item.images || item.images.length === 0) {
    return null
  }

  const primaryImage = item.images.find(img => img.is_primary) || item.images[0]

  if (preferThumbnail && primaryImage.thumbnail_url) {
    return primaryImage.thumbnail_url
  }

  return primaryImage.image_url || null
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
 */
export function ItemImage({ item, size = 'sm', className, enableZoom = false }: ItemImageProps) {
  const [isLoading, setIsLoading] = useState(true)
  const [hasError, setHasError] = useState(false)

  // For zoom, use full-size image instead of thumbnail
  const imageUrl = getImageUrl(item, !enableZoom && size === 'sm')
  const sizeClass = SIZE_CLASSES[size]
  const iconSize = ICON_SIZES[size]
  const CategoryIcon = getCategoryIcon()

  // No image available
  if (!imageUrl) {
    return (
      <div
        className={cn(
          sizeClass,
          'rounded-lg bg-muted flex items-center justify-center text-muted-foreground',
          className
        )}
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
      >
        <AlertTriangle className={cn(iconSize, 'text-muted-foreground')} />
      </div>
    )
  }

  // Use ZoomableImage when zoom is enabled
  if (enableZoom) {
    return (
      <div className={cn(sizeClass, 'relative rounded-lg overflow-hidden', className)}>
        {isLoading && (
          <Skeleton className="absolute inset-0" />
        )}
        <ZoomableImage
          src={imageUrl}
          alt={item.name}
          className={cn(
            'h-full w-full object-cover',
            isLoading && 'opacity-0'
          )}
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
    <div className={cn(sizeClass, 'relative rounded-lg overflow-hidden', className)}>
      {isLoading && (
        <Skeleton className="absolute inset-0" />
      )}
      <img
        src={imageUrl}
        alt={item.name}
        className={cn(
          'h-full w-full object-cover',
          isLoading && 'opacity-0'
        )}
        loading="lazy"
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

  if (!imageUrl || hasError) {
    return (
      <div
        className={cn(
          sizeClass,
          'rounded-lg bg-muted flex items-center justify-center text-muted-foreground',
          className
        )}
      >
        <CategoryIcon className={iconSize} />
      </div>
    )
  }

  return (
    <img
      src={imageUrl}
      alt={item.name}
      className={cn(sizeClass, 'rounded-lg object-cover', className)}
      loading="lazy"
      onError={() => setHasError(true)}
    />
  )
}
