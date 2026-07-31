/**
 * OutfitCard Component
 *
 * A modern, image-forward card for displaying outfits.
 * Features:
 * - Full-bleed image with gradient overlay
 * - AI generation badge
 * - Favorite button
 * - Loading state for AI generation
 * - Hover animations
 *
 * @see https://docs.fitcheck.ai/features/outfits
 */

import * as React from 'react'
import { Heart, Layers, Sparkles, Loader2 } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Badge } from '@/components/ui/badge'
import { useElapsedSeconds } from '@/hooks/useElapsedSeconds'
import type { Outfit } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

export interface OutfitCardProps {
  outfit: Outfit
  onClick?: () => void
  onToggleFavorite?: (e: React.MouseEvent) => void
  /** Generation status from store */
  generationStatus?: 'pending' | 'processing' | 'failed' | 'completed' | null
  /** Real failure message from the store, shown instead of a generic label */
  generationError?: string
  /** Display variant */
  variant?: 'default' | 'compact' | 'list'
  /** Show favorite button */
  showFavorite?: boolean
  /** Additional class names */
  className?: string
}

// ============================================================================
// COMPONENT
// ============================================================================

export const OutfitCard = React.forwardRef<HTMLDivElement, OutfitCardProps>(
  (
    {
      outfit,
      onClick,
      onToggleFavorite,
      generationStatus,
      generationError,
      variant = 'default',
      showFavorite = true,
      className,
    },
    ref
  ) => {
    const primaryImage = outfit.images?.find((img) => img.is_primary) || outfit.images?.[0]
    const hasAiImage = outfit.images?.some((img) => img.generation_type === 'ai')
    const isGenerating = generationStatus === 'pending' || generationStatus === 'processing'
    const generationFailed = generationStatus === 'failed'
    const [imageError, setImageError] = React.useState(false)
    // Only surface elapsed time once the wait is long enough to matter — a
    // tiny grid tile doesn't need a "1s" flicker for near-instant generations.
    const elapsedSeconds = useElapsedSeconds(isGenerating)
    const showElapsed = isGenerating && elapsedSeconds >= 3

    React.useEffect(() => {
      setImageError(false)
    }, [primaryImage?.thumbnail_url, primaryImage?.image_url, outfit.id])

    const imageSrc =
      !imageError && primaryImage
        ? primaryImage.thumbnail_url || primaryImage.image_url
        : null

    // True only when a real photograph is actually painted in the tile. Drives
    // both the legibility scrim and the ink of the bottom overlay: white text
    // is correct over a photo and invisible over the flat waiting / failed /
    // empty surfaces, which is what it used to render as in light mode.
    const onPhoto = !!imageSrc && !isGenerating && !generationFailed

    if (variant === 'list') {
      return (
        <div
          ref={ref}
          className={cn(
            'flex items-center gap-3 rounded-md border border-border bg-card p-3',
            // Queries its OWN width (see `.row-cq` in index.css). Mirrors ItemCard.
            'row-cq',
            // Not `hover:bg-accent`: `--accent` is byte-identical to `--card`
            // in `:root`, which would erase the light-mode hover. See ItemCard.
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
          {/* Image. `bg-card` matches ItemCard (a no-op swap off `--muted`, which
              is byte-identical today) so a flat-lay look with alpha lands on a
              real surface. `object-cover` stays: see the note on the grid tile. */}
          <div className="h-16 w-16 shrink-0 overflow-hidden rounded-md bg-card">
            {imageSrc ? (
              <img
                src={imageSrc}
                alt={outfit.name}
                className="w-full h-full object-cover"
                onError={() => setImageError(true)}
                loading="lazy"
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center">
                <Layers className="h-6 w-6 text-muted-foreground/50" />
              </div>
            )}
          </div>

          {/* Info */}
          <div className="flex-1 min-w-0">
            <h3 className="font-medium text-sm text-foreground truncate">{outfit.name}</h3>
            <p className="text-xs text-muted-foreground">
              {outfit.item_ids.length} {outfit.item_ids.length === 1 ? 'item' : 'items'}
            </p>
            {outfit.style && (
              <Badge variant="secondary" className="text-[10px] mt-1">
                {outfit.style}
              </Badge>
            )}
          </div>

          {/* Actions */}
          <div className="flex items-center gap-2">
            {hasAiImage && (
              <Badge className="row-cq-secondary bg-accent-purple text-white text-[10px]">
                <Sparkles className="h-3 w-3 mr-1" />
                AI
              </Badge>
            )}
            {showFavorite && (
              <button
                type="button"
                aria-label={outfit.is_favorite ? 'Remove from favorites' : 'Add to favorites'}
                className={cn(
                  'row-cq-secondary p-2 rounded-full touch-target',
                  // The list row sits on `bg-card`, not on a photo, so this one
                  // is page chrome and follows the page palette: brand red, not
                  // an off-system pink.
                  outfit.is_favorite
                    ? 'text-primary'
                    : 'text-muted-foreground hover:text-primary'
                )}
                onClick={(e) => {
                  e.stopPropagation()
                  onToggleFavorite?.(e)
                }}
              >
                <Heart className={cn('h-4 w-4', outfit.is_favorite && 'fill-current')} />
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
          (!imageSrc || isGenerating || generationFailed) && 'aspect-[3/4] min-h-36',
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
        {/* Image/Content */}
        {isGenerating ? (
          // Flat `bg-card`, not a red-to-violet wash. The gradient was pure
          // ornament on a waiting state: two hues that belong to no system,
          // and the spinner already carries the "working" signal.
          <div className="absolute inset-0 flex flex-col items-center justify-center bg-card">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
            <p className="text-xs text-muted-foreground mt-2">
              Generating AI image…{showElapsed ? ` (${elapsedSeconds}s elapsed)` : ''}
            </p>
          </div>
        ) : generationFailed ? (
          <div className="absolute inset-0 flex flex-col items-center justify-center bg-destructive/5 px-3">
            <Sparkles className="h-8 w-8 text-destructive/50" />
            <p className="text-xs font-medium text-foreground mt-2">Generation failed</p>
            <p className="text-[10px] text-muted-foreground text-center line-clamp-2">
              {generationError || 'Tap to retry'}
            </p>
          </div>
        ) : imageSrc ? (
          // DELIBERATE ASYMMETRY WITH ItemCard — do not "unify" these.
          // ItemCard's compact tile is `object-contain` because a wardrobe item
          // is a matted cutout with a real alpha channel, and `cover` crops its
          // hem. An outfit LOOK is an opaque photograph: only flat-lay looks get
          // matted and the model shot is the common case, so `contain` would
          // letterbox a hero photo against the card surface. `cover` is correct
          // here for exactly as long as that stays true.
          <img
            src={imageSrc}
            alt={outfit.name}
            className={cn(
              variant === 'compact' ? 'absolute inset-0 h-full w-full object-cover' : 'relative block h-auto w-full object-contain',
            )}
            loading="lazy"
            width={primaryImage?.width}
            height={primaryImage?.height}
            onError={() => setImageError(true)}
          />
        ) : (
          // Flat `bg-secondary`, not a red-to-neutral wash. This is the empty
          // "no look yet" tile; it reads as a raised, actionable surface off
          // `bg-card` on tone alone, which is what the gradient was faking.
          <div className="absolute inset-0 flex flex-col items-center justify-center p-4 bg-secondary">
            <Sparkles className="h-8 w-8 text-primary/40 mb-2" />
            <p className="text-xs font-medium text-foreground">Generate look</p>
            <p className="text-[10px] text-muted-foreground mt-0.5">
              {outfit.item_ids.length} piece{outfit.item_ids.length === 1 ? '' : 's'}
            </p>
          </div>
        )}

        {/* Scrim. KEEP this one — it is legibility for white text over
            photography, not ornament. But it is now gated on `onPhoto` rather
            than `imageSrc || isGenerating`: with no photo underneath there is
            nothing to darken for, and laying a black gradient over the flat
            waiting tile just muddied it and dragged the status copy down to
            unreadable contrast. */}
        {onPhoto && (
          <div
            className={cn(
              'absolute inset-0',
              'bg-gradient-to-t from-black/70 via-black/20 to-transparent',
              'pointer-events-none'
            )}
          />
        )}

        {/* AI Badge */}
        {hasAiImage && !isGenerating && (
          <Badge
            className={cn(
              'absolute top-2.5 left-2.5 z-10',
              'bg-accent-purple text-white text-[10px]'
            )}
          >
            <Sparkles className="h-3 w-3 mr-1" />
            AI
          </Badge>
        )}

        {/* Favorite Button */}
        {showFavorite && (
          <button
            type="button"
            className={cn(
              'absolute top-2.5 right-2.5 z-10',
              'w-9 h-9 rounded-full',
              'flex items-center justify-center',
              'transition-colors duration-200',
              'touch-target',
              // Mirrors ItemCard's disc. This floats over the look photograph,
              // so it is on-image chrome: theme-invariant, no `dark:` pair. The
              // old `bg-white/90 dark:bg-gray-800/90` flipped the disc dark in
              // dark mode even though its backdrop is a photo, and the pink was
              // a hue outside the red / purple / warm-neutral system.
              outfit.is_favorite
                ? 'bg-primary text-primary-foreground'
                : 'bg-on-image text-on-image-foreground/60 hover:text-primary'
            )}
            onClick={(e) => {
              e.stopPropagation()
              onToggleFavorite?.(e)
            }}
            aria-label={outfit.is_favorite ? 'Remove from favorites' : 'Add to favorites'}
          >
            <Heart className={cn('h-4 w-4', outfit.is_favorite && 'fill-current')} />
          </button>
        )}

        {/* Bottom Info Overlay.
            The ink follows the backdrop. Over a photograph (with the scrim
            above) it is white. On the generating / failed / empty tiles there is
            NO photo and NO scrim, so white here painted white-on-light — the
            outfit name and its meta row were simply invisible in light mode.
            Those states use the page ink instead. */}
        <div className="absolute bottom-0 left-0 right-0 p-3 z-10">
          <h3
            className={cn(
              'font-semibold text-sm truncate',
              onPhoto ? 'text-white' : 'text-foreground'
            )}
          >
            {outfit.name}
          </h3>

          <div className="flex items-center justify-between mt-1">
            <span
              className={cn(
                'text-[10px]',
                onPhoto ? 'text-white/80' : 'text-muted-foreground'
              )}
            >
              {outfit.item_ids.length} {outfit.item_ids.length === 1 ? 'item' : 'items'}
            </span>
            {outfit.style && (
              <Badge
                variant="secondary"
                className={cn(
                  'text-[10px] border-0 capitalize',
                  onPhoto && 'bg-white/20 text-white'
                )}
              >
                {outfit.style}
              </Badge>
            )}
          </div>

          {/* Additional info - shown on hover on desktop */}
          {variant !== 'compact' && (
            <div className="hidden md:flex items-center gap-2 mt-1.5 opacity-0 group-hover:opacity-100 transition-opacity">
              {outfit.worn_count > 0 && (
                <span
                  className={cn(
                    'text-[10px]',
                    onPhoto ? 'text-white/70' : 'text-muted-foreground'
                  )}
                >
                  Worn {outfit.worn_count}x
                </span>
              )}
              {outfit.description && (
                <span
                  className={cn(
                    'text-[10px] truncate',
                    onPhoto ? 'text-white/70' : 'text-muted-foreground'
                  )}
                >
                  {outfit.description}
                </span>
              )}
            </div>
          )}
        </div>
      </div>
    )
  }
)
OutfitCard.displayName = 'OutfitCard'

export default OutfitCard
