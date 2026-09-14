/**
 * ItemCard Component
 *
 * Grid tiles are PURE IMAGE: the matted cutouts carry the visual, so the tile
 * adds no surface, shadow, text, or buttons of its own — no favorite heart, no
 * select disc, no name/category strip. Every item action lives in the detail
 * page; a long-press (touch or mouse-hold) starts bulk selection, after which a
 * tap toggles the tile's selection instead of opening it.
 *
 * The `list` variant stays a text row (it is the "list view", not a tile).
 */

import * as React from 'react'
import { Shirt, Check } from 'lucide-react'
import { cn } from '@/lib/utils'
import type { Item } from '@/types'
import { useImageWithFallback } from '@/hooks/useImageWithFallback'
import { useLongPress } from '@/hooks/useLongPress'

// ============================================================================
// TYPES
// ============================================================================

export interface ItemCardProps {
  item: Item
  onClick?: () => void
  /** Called when the tile is pressed and held (~450ms) — starts bulk selection. */
  onLongPress?: () => void
  /** Bulk selection is active somewhere on the page (tiles become toggle targets). */
  isSelecting?: boolean
  isSelected?: boolean
  /** Display variant: `default` = image tile, `list` = text row. */
  variant?: 'default' | 'list'
  /** Called once when the primary image fails to load (e.g. an expired presigned
   *  URL). The parent can refetch the list to obtain fresh URLs. */
  onImageError?: () => void
  /** Additional class names */
  className?: string
}

// ============================================================================
// HELPERS
// ============================================================================

/**
 * Garment condition, as a quiet index — a desaturated dot, not a pill.
 * `clean` deliberately has no entry: it is the default state, and labelling
 * the absence of a problem is noise. Used by the list variant only.
 */
const getConditionDot = (condition: string) => {
  return (
    {
      dirty: 'bg-condition-dirty',
      laundry: 'bg-condition-laundry',
      repair: 'bg-condition-repair',
      donate: 'bg-condition-donate',
    }[condition] ?? 'bg-condition-other'
  )
}

// ============================================================================
// COMPONENT
// ============================================================================

export const ItemCard = React.forwardRef<HTMLDivElement, ItemCardProps>(
  (
    {
      item,
      onClick,
      onLongPress,
      onImageError,
      isSelecting = false,
      isSelected = false,
      variant = 'default',
      className,
    },
    ref
  ) => {
    const primaryImage = item.images?.[0]
    // `thumbnail_url` is derived from the parent key with no existence check, so
    // it can 404 while the full-size object is healthy (best-effort thumb
    // encode, or an object predating the backfill). Retry the full size before
    // treating the tile as broken.
    // onExhausted asks the parent for fresh URLs once BOTH sources have failed —
    // the signal that the presigned URLs expired. A thumb that merely does not
    // exist is fixed by the fallback, so re-minting on that would be wasted.
    const {
      src: imageSrc,
      onError: handleImageError,
    } = useImageWithFallback(primaryImage?.thumbnail_url, primaryImage?.image_url, {
      onExhausted: onImageError,
      resetKey: item.id,
    })

    // The hook's onClick IS the tap handler when long-press is active: it
    // eats the release-click after a fired long-press and forwards real taps.
    const { handlers: longPressHandlers } = useLongPress({
      onLongPress: () => onLongPress?.(),
      onClick,
    })

    const handleKeyDown = (e: React.KeyboardEvent) => {
      if (e.target !== e.currentTarget) return
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault()
        onClick?.()
      }
      // Keyboard equivalent of the long-press gesture: a pointer user holds a
      // tile to start bulk selection; a keyboard user shifts+enters. Kept on
      // a modifier so Enter/Space remain unambiguous open/toggle actions.
      if (onLongPress && e.key === 'Enter' && e.shiftKey) {
        e.preventDefault()
        onLongPress()
      }
    }

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
            'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
            'touch-target',
            // Same selection state as the tile variant: rows are toggle
            // targets while a bulk selection is on, so they must show it.
            isSelecting && isSelected && 'ring-2 ring-primary ring-offset-2 ring-offset-background',
            className
          )}
          {...(onLongPress ? longPressHandlers : { onClick })}
          role="button"
          tabIndex={0}
          aria-label={item.name}
          aria-pressed={isSelecting ? isSelected : undefined}
          onKeyDown={handleKeyDown}
        >
          {/* Image — garment photos are matted WebP with a real alpha channel,
              so the thumb is a surface the cutout sits on. `object-contain`
              keeps a portrait silhouette whole instead of cropping its hem. */}
          <div className="h-16 w-16 shrink-0 overflow-hidden rounded-md bg-card p-0.5">
            {imageSrc ? (
              <img
                src={imageSrc}
                alt=""
                className="w-full h-full object-contain"
                loading="lazy"
                onError={(event) =>
                  handleImageError(event.currentTarget.currentSrc || event.currentTarget.src)
                }
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

          {/* Selection badge — mirrors the tile variant so users can see which
              rows the bulk actions will hit. */}
          {isSelecting && isSelected && (
            <span
              data-testid="item-card-selected-badge"
              className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-sm"
            >
              <Check className="h-3 w-3" strokeWidth={3} />
            </span>
          )}

          {/* Condition — a quiet dot + label; secondary affordance hides below
              the 20rem container width (.row-cq-secondary in index.css).
              `clean` is the default state and renders nothing: the dot map has
              no clean entry, so rendering the wrapper unconditionally would
              show a misleading "other" dot. */}
          {item.condition !== 'clean' && (
            <span className="row-cq-secondary flex items-center gap-1.5 text-[11px] text-muted-foreground">
              <span
                className={cn('h-1.5 w-1.5 shrink-0 rounded-full', getConditionDot(item.condition))}
                aria-hidden="true"
              />
              <span className="capitalize">{item.condition}</span>
            </span>
          )}
        </div>
      )
    }

    return (
      <div
        ref={ref}
        className={cn(
          // PURE IMAGE tile: no background, no border, no shadow — the matted
          // cutout floats on the page. All item actions live in the detail
          // page; selection state appears only while a bulk selection is on.
          'group relative cursor-pointer',
          isSelecting && isSelected && 'ring-2 ring-primary ring-offset-2 ring-offset-background',
          'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
          className
        )}
        {...(onLongPress ? longPressHandlers : { onClick })}
        role="button"
        tabIndex={0}
        aria-label={item.name}
        aria-pressed={isSelecting ? isSelected : undefined}
        onKeyDown={handleKeyDown}
      >
        {/* aspect box reserves the tile's height BEFORE the image decodes. The
            backend ships width/height as null (storage_service.py), so without
            this box every card collapses to ~2px pre-load — on a slow phone the
            whole grid renders as a band of slivers, then jumps per image. */}
        {imageSrc ? (
          <img
            src={imageSrc}
            alt=""
            className="relative block aspect-[3/4] w-full object-contain"
            loading="lazy"
            width={primaryImage?.width}
            height={primaryImage?.height}
            onError={(event) =>
              handleImageError(event.currentTarget.currentSrc || event.currentTarget.src)
            }
          />
        ) : (
          <div className="relative flex aspect-[3/4] w-full items-center justify-center">
            <Shirt className="h-12 w-12 md:h-16 md:w-16 text-muted-foreground/30" />
          </div>
        )}

        {/* Selection badge — the ONLY chrome a tile can carry, and only while
            a bulk selection is active. Long-press started it; tap toggles. */}
        {isSelecting && isSelected && (
          <span
            data-testid="item-card-selected-badge"
            className="absolute right-1 top-1 z-10 flex h-5 w-5 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-sm"
          >
            <Check className="h-3 w-3" strokeWidth={3} />
          </span>
        )}
      </div>
    )
  }
)
ItemCard.displayName = 'ItemCard'

export default ItemCard
