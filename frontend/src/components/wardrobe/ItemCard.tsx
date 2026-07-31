/**
 * ItemCard Component
 *
 * A modern, image-forward card for displaying wardrobe items.
 * Features:
 * - Full-bleed image with gradient overlay
 * - Floating action buttons for favorite/select
 * - Condition badge
 * - Hover animations
 * - Touch-friendly targets
 *
 * @see https://docs.fitcheck.ai/features/wardrobe
 */

import * as React from 'react'
import { Heart, Shirt, Check } from 'lucide-react'
import { cn } from '@/lib/utils'
import type { Item } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

export interface ItemCardProps {
  item: Item
  onClick?: () => void
  onToggleFavorite?: (e: React.MouseEvent) => void
  onSelect?: (e: React.MouseEvent) => void
  isSelected?: boolean
  /** Display variant */
  variant?: 'default' | 'compact' | 'list'
  /** Show selection checkbox */
  showSelect?: boolean
  /** Show favorite button */
  showFavorite?: boolean
  /** Additional class names */
  className?: string
}

// ============================================================================
// HELPERS
// ============================================================================

/**
 * Garment condition, as a quiet index.
 *
 * This used to be five saturated pills — emerald / amber / sky / rose / violet,
 * white text, flooding the chip. Five competing accents in a product whose
 * palette is one red is a straight break of DESIGN.md 01, and a tinted pill
 * around every scrap of metadata is its own tell. The condition still has to be
 * readable at a glance on a tile, so the differentiation stays: it just becomes
 * a DOT in a desaturated family (one saturation band, one lightness band, in
 * index.css) on the same opaque surface chip the corner controls use, so the
 * card has one chrome vocabulary instead of three.
 *
 * `clean` deliberately has no entry — it is the default state, the card does not
 * render a badge for it, and labelling the absence of a problem is noise.
 */
const getConditionConfig = (condition: string) => {
  const dot =
    {
      dirty: 'bg-condition-dirty',
      laundry: 'bg-condition-laundry',
      repair: 'bg-condition-repair',
      donate: 'bg-condition-donate',
    }[condition] ?? 'bg-condition-other'

  const label =
    { dirty: 'Dirty', laundry: 'Laundry', repair: 'Repair', donate: 'Donate', clean: 'Clean' }[
      condition
    ] ?? condition

  return { dot, label }
}

// ============================================================================
// COMPONENT
// ============================================================================

export const ItemCard = React.forwardRef<HTMLDivElement, ItemCardProps>(
  (
    {
      item,
      onClick,
      onToggleFavorite,
      onSelect,
      isSelected = false,
      variant = 'default',
      showSelect = true,
      showFavorite = true,
      className,
    },
    ref
  ) => {
    const conditionConfig = getConditionConfig(item.condition)
    const primaryImage = item.images?.[0]
    const [imageError, setImageError] = React.useState(false)

    // Reset error when image source changes
    React.useEffect(() => {
      setImageError(false)
    }, [primaryImage?.thumbnail_url, primaryImage?.image_url, item.id])

    const imageSrc =
      !imageError && primaryImage
        ? primaryImage.thumbnail_url || primaryImage.image_url
        : null

    if (variant === 'list') {
      return (
        <div
          ref={ref}
          className={cn(
            'flex items-center gap-3 rounded-md border border-border bg-card p-3',
            // Queries its OWN width (see `.row-cq` in index.css): the md split
            // leaves this column at 253px with the sidebar out, 351px with it in.
            'row-cq',
            // Deliberately NOT `hover:bg-accent`: `--accent` is byte-identical
            // to `--card` in `:root`, so that would erase the light-mode hover
            // entirely. `--surface-soft` is the only token that lifts off
            // `--card` in the SAME direction (lighter) in both themes.
            'hover:bg-surface-soft transition-colors cursor-pointer',
            'touch-target',
            className
          )}
          onClick={onClick}
          role="button"
          tabIndex={0}
          onKeyDown={(e) => {
            if (e.target !== e.currentTarget) return
            if (e.key === 'Enter' || e.key === ' ') {
              e.preventDefault()
              onClick?.()
            }
          }}
        >
          {/* Image — garment photos are now matted WebP with a real alpha
              channel, so the tile is a SURFACE the cutout sits on, not a
              placeholder tint. `bg-card` (byte-identical to `--muted` today, so
              a no-op swap) plus `object-contain` and a hair of padding keeps a
              portrait silhouette whole instead of cropping its hem. */}
          <div className="h-16 w-16 shrink-0 overflow-hidden rounded-md bg-card p-0.5">
            {imageSrc ? (
              <img
                src={imageSrc}
                alt={item.name}
                className="w-full h-full object-contain"
                loading="lazy"
                onError={() => setImageError(true)}
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center">
                <Shirt className="h-6 w-6 text-muted-foreground/50" />
              </div>
            )}
          </div>

          {/* Info */}
          <div className="flex-1 min-w-0">
            <h3 className="font-medium text-sm text-foreground truncate">{item.name}</h3>
            <p className="text-xs text-muted-foreground capitalize">{item.category}</p>
            {item.brand && (
              <p className="text-xs text-muted-foreground/70 truncate">{item.brand}</p>
            )}
          </div>

          {/* Actions */}
          <div className="flex items-center gap-2">
            <span className="row-cq-secondary flex items-center gap-1.5 text-[11px] text-muted-foreground">
              <span
                className={cn('h-1.5 w-1.5 shrink-0 rounded-full', conditionConfig.dot)}
                aria-hidden="true"
              />
              {conditionConfig.label}
            </span>
            {showFavorite && (
              <button
                type="button"
                aria-label={item.is_favorite ? 'Remove from favorites' : 'Add to favorites'}
                className={cn(
                  'row-cq-secondary p-2 rounded-full touch-target',
                  // List row sits on `bg-card`, not on a photo: page chrome, so
                  // brand red rather than an off-system pink (mirrors the grid
                  // tile's disc, which already uses `bg-primary`).
                  item.is_favorite
                    ? 'text-primary'
                    : 'text-muted-foreground hover:text-primary'
                )}
                onClick={(e) => {
                  e.stopPropagation()
                  onToggleFavorite?.(e)
                }}
              >
                <Heart className={cn('h-4 w-4', item.is_favorite && 'fill-current')} />
              </button>
            )}
          </div>
        </div>
      )
    }

    return (
      <div
        ref={ref}
        className={cn(
          'group relative overflow-hidden rounded-md bg-card',
          'cursor-pointer',
          'border border-transparent transition-colors hover:border-border',
          variant === 'compact' && 'aspect-square',
          !imageSrc && 'aspect-[3/4] min-h-36',
          isSelected && 'ring-2 ring-primary ring-offset-2',
          className
        )}
        onClick={onClick}
        role="button"
        tabIndex={0}
        onKeyDown={(e) => {
          if (e.target !== e.currentTarget) return
          if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault()
            onClick?.()
          }
        }}
      >
        {/* Item image. The compact tile is a fixed `aspect-square`, so `cover`
            centre-cropped every portrait cutout and ate its hem and shoulders —
            the one edit the whole matting pipeline was waiting on. `contain`
            plus padding fits the silhouette whole; the transparent margins
            reveal `bg-card`, which is the surface the tile already was.
            The pad is asymmetric because the name/brand strip below is an
            OPAQUE overlay on `absolute bottom-0`, so it would guillotine the
            hem. Measured: 38px at its two-line maximum (11px title + 10px
            brand + `py-1.5`). `pb-11` (44px) clears that by 6px — pad past the
            cut by more than the cut removes, and re-measure if the strip's type
            ever changes. `pb-8` (32px) hid 6px of hem behind it. */}
        {imageSrc ? (
          <img
            src={imageSrc}
            alt={item.name}
            className={cn(
              variant === 'compact'
                ? 'absolute inset-0 h-full w-full object-contain p-2 pb-11'
                : 'relative block h-auto w-full object-contain',
            )}
            loading="lazy"
            width={primaryImage?.width}
            height={primaryImage?.height}
            onError={() => setImageError(true)}
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center">
            <Shirt className="h-12 w-12 md:h-16 md:w-16 text-muted-foreground/30" />
          </div>
        )}

        {/* Gradient Overlay — only needed when overlaying text on the image */}
        {variant !== 'compact' && (
          <div
            className={cn(
              'absolute inset-0',
              'bg-gradient-to-t from-black/70 via-black/20 to-transparent',
              'pointer-events-none'
            )}
          />
        )}

        {/* Selection Checkbox */}
        {showSelect && (
          <button
            type="button"
            className={cn(
              'absolute top-2.5 left-2.5 z-10',
              // NOT the theme-invariant `on-image` pair. That token assumes an
              // opaque photo filling the tile, which stopped being true when
              // item images became transparent cutouts: most of the tile is now
              // `bg-card`, so a fixed-white disc rendered as a heavy white blob
              // on a near-black tile in dark mode. An opaque SURFACE chip reads
              // correctly over both a cutout on the card and an un-matted photo
              // (G1 skips those), which is the whole range this has to cover.
              'h-11 w-11 rounded-full',
              'flex items-center justify-center',
              'transition-colors duration-200',
              'touch-target',
              isSelected
                ? 'bg-primary text-primary-foreground'
                : 'bg-background/90 text-foreground border border-border'
            )}
            onClick={(e) => {
              e.stopPropagation()
              onSelect?.(e)
            }}
            aria-label={isSelected ? 'Deselect item' : 'Select item'}
          >
            {isSelected && <Check className="h-4 w-4" strokeWidth={3} />}
          </button>
        )}

        {/* Favorite Button — hidden in compact (dense) mode to keep tiles clean */}
        {showFavorite && variant !== 'compact' && (
          <button
            type="button"
            className={cn(
              'absolute top-2.5 right-2.5 z-10',
              'h-11 w-11 rounded-full',
              'flex items-center justify-center',
              'transition-colors duration-200',
              'touch-target',
              item.is_favorite
                ? 'bg-primary text-primary-foreground'
                // Surface chip, not `on-image` — same reason as the select disc
                // above: the tile behind a cutout is `bg-card`, not a photo.
                : 'bg-background/90 text-muted-foreground border border-border hover:text-primary'
            )}
            onClick={(e) => {
              e.stopPropagation()
              onToggleFavorite?.(e)
            }}
            aria-label={item.is_favorite ? 'Remove from favorites' : 'Add to favorites'}
          >
            <Heart className={cn('h-4 w-4', item.is_favorite && 'fill-current')} />
          </button>
        )}

        {/* Everything anchored to the bottom lives in ONE stacking column.
            The condition badge used to be `absolute bottom-14` — a pixel guess
            at the height of the overlay below it, and a wrong one: the default
            overlay runs ~60px tall, so the badge sat inside it and collided
            with the item name on any card whose condition was not `clean`.
            Stacking them means the badge clears the overlay by construction,
            whatever the overlay happens to contain. */}
        <div className="absolute bottom-0 left-0 right-0 z-10 flex flex-col">
          {/* Condition — `clean` is the default state and saying so is noise. */}
          {item.condition && item.condition !== 'clean' && (
            <span
              className={cn(
                'mb-1.5 ml-2.5 self-start',
                // Same opaque surface chip as the corner controls: legible over
                // a cutout on the card AND over an un-matted photo.
                'flex items-center gap-1.5 rounded-full border border-border bg-background/90',
                'px-2.5 py-1 text-[11px] font-medium text-foreground'
              )}
            >
              <span
                className={cn('h-1.5 w-1.5 shrink-0 rounded-full', conditionConfig.dot)}
                aria-hidden="true"
              />
              {conditionConfig.label}
            </span>
          )}

          {/* Bottom Info — compact: clean cutout + name/brand below (Alta-style); default: overlay */}
          {variant === 'compact' ? (
            <div className="bg-background/95 px-2 py-1.5">
              <h3 className="truncate text-[11px] font-medium leading-tight text-foreground">
                {item.name}
              </h3>
              {item.brand && (
                <p className="truncate text-[10px] leading-tight text-muted-foreground">
                  {item.brand}
                </p>
              )}
            </div>
          ) : (
            <div className="p-3">
              <h3 className="text-sm font-semibold text-white truncate">
                {item.name}
              </h3>
              <p className="text-xs text-white/80 capitalize">{item.category}</p>

              {/* Additional info - shown on hover on desktop */}
              <div className="hidden md:flex items-center gap-2 mt-1.5 opacity-0 group-hover:opacity-100 transition-opacity">
                {item.brand && (
                  <span className="text-[10px] text-white/70 truncate">{item.brand}</span>
                )}
                {item.usage_times_worn > 0 && (
                  <span className="text-[10px] text-white/70">
                    Worn {item.usage_times_worn}x
                  </span>
                )}
              </div>
            </div>
          )}
        </div>
      </div>
    )
  }
)
ItemCard.displayName = 'ItemCard'

export default ItemCard
