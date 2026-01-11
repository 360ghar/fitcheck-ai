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

    if (variant === 'list') {
      return (
        <div
          ref={ref}
          className={cn(
            'flex items-center gap-3 p-3 bg-card rounded-xl',
            'border border-border/50',
            'hover:bg-accent/50 transition-colors cursor-pointer',
            'touch-target',
            className
          )}
          onClick={onClick}
        >
          {/* Image */}
          <div className="h-16 w-16 rounded-lg overflow-hidden bg-muted shrink-0">
            {primaryImage ? (
              <img
                src={primaryImage.thumbnail_url || primaryImage.image_url}
                alt={outfit.name}
                className="w-full h-full object-cover"
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
              <Badge className="bg-violet-500/90 text-white text-[10px]">
                <Sparkles className="h-3 w-3 mr-1" />
                AI
              </Badge>
            )}
            {showFavorite && (
              <button
                className={cn(
                  'p-2 rounded-full touch-target',
                  outfit.is_favorite
                    ? 'text-pink-500'
                    : 'text-muted-foreground hover:text-pink-500'
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
          'group relative rounded-xl overflow-hidden bg-muted',
          'cursor-pointer',
          'transition-all duration-300',
          'hover:shadow-card-hover hover:-translate-y-1',
          variant === 'compact' ? 'aspect-square' : 'aspect-[4/3]',
          className
        )}
        onClick={onClick}
      >
        {/* Image/Content */}
        {isGenerating ? (
          <div className="absolute inset-0 flex flex-col items-center justify-center bg-gradient-to-br from-primary/10 to-violet-500/10">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
            <p className="text-xs text-muted-foreground mt-2">Generating AI image...</p>
          </div>
        ) : generationFailed ? (
          <div className="absolute inset-0 flex flex-col items-center justify-center bg-destructive/5">
            <Sparkles className="h-8 w-8 text-destructive/50" />
            <p className="text-xs text-muted-foreground mt-2">Generation failed</p>
            <p className="text-[10px] text-muted-foreground">Click to retry</p>
          </div>
        ) : primaryImage ? (
          <img
            src={primaryImage.thumbnail_url || primaryImage.image_url}
            alt={outfit.name}
            className={cn(
              'absolute inset-0 w-full h-full object-cover',
              'transition-transform duration-300',
              'group-hover:scale-105'
            )}
            loading="lazy"
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center p-4">
            <div className="grid grid-cols-3 gap-2">
              {outfit.item_ids.slice(0, 6).map((_, index) => (
                <div
                  key={index}
                  className="aspect-square bg-muted-foreground/10 rounded flex items-center justify-center"
                >
                  <Layers className="h-4 w-4 md:h-6 md:w-6 text-muted-foreground/50" />
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Gradient Overlay */}
        {(primaryImage || isGenerating) && (
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
              'bg-violet-500/90 text-white text-[10px]',
              'shadow-sm'
            )}
          >
            <Sparkles className="h-3 w-3 mr-1" />
            AI
          </Badge>
        )}

        {/* Favorite Button */}
        {showFavorite && (
          <button
            className={cn(
              'absolute top-2.5 right-2.5 z-10',
              'w-9 h-9 rounded-full',
              'flex items-center justify-center',
              'transition-all duration-200',
              'touch-target',
              outfit.is_favorite
                ? 'bg-pink-500 text-white shadow-lg shadow-pink-500/30'
                : 'bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm text-muted-foreground hover:text-pink-500'
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

        {/* Bottom Info Overlay */}
        <div className="absolute bottom-0 left-0 right-0 p-3 z-10">
          <h3 className="font-semibold text-sm text-white truncate drop-shadow-sm">
            {outfit.name}
          </h3>

          <div className="flex items-center justify-between mt-1">
            <span className="text-[10px] text-white/80">
              {outfit.item_ids.length} {outfit.item_ids.length === 1 ? 'item' : 'items'}
            </span>
            {outfit.style && (
              <Badge
                variant="secondary"
                className="text-[10px] bg-white/20 text-white border-0 capitalize"
              >
                {outfit.style}
              </Badge>
            )}
          </div>

          {/* Additional info - shown on hover on desktop */}
          {variant !== 'compact' && (
            <div className="hidden md:flex items-center gap-2 mt-1.5 opacity-0 group-hover:opacity-100 transition-opacity">
              {outfit.worn_count > 0 && (
                <span className="text-[10px] text-white/70">
                  Worn {outfit.worn_count}x
                </span>
              )}
              {outfit.description && (
                <span className="text-[10px] text-white/70 truncate">
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
