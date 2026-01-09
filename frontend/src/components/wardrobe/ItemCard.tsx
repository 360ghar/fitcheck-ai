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
import { Badge } from '@/components/ui/badge'
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

const getConditionConfig = (condition: string) => {
  switch (condition) {
    case 'clean':
      return {
        bg: 'bg-emerald-500/90',
        text: 'text-white',
        label: 'Clean',
      }
    case 'dirty':
      return {
        bg: 'bg-amber-500/90',
        text: 'text-white',
        label: 'Dirty',
      }
    case 'laundry':
      return {
        bg: 'bg-sky-500/90',
        text: 'text-white',
        label: 'Laundry',
      }
    case 'repair':
      return {
        bg: 'bg-rose-500/90',
        text: 'text-white',
        label: 'Repair',
      }
    case 'donate':
      return {
        bg: 'bg-violet-500/90',
        text: 'text-white',
        label: 'Donate',
      }
    default:
      return {
        bg: 'bg-gray-500/90',
        text: 'text-white',
        label: condition,
      }
  }
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
                alt={item.name}
                className="w-full h-full object-cover"
                loading="lazy"
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
            <Badge className={cn('text-[10px]', conditionConfig.bg, conditionConfig.text)}>
              {conditionConfig.label}
            </Badge>
            {showFavorite && (
              <button
                className={cn(
                  'p-2 rounded-full touch-target',
                  item.is_favorite
                    ? 'text-pink-500'
                    : 'text-muted-foreground hover:text-pink-500'
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
          'group relative rounded-xl overflow-hidden bg-muted',
          'cursor-pointer',
          'transition-all duration-300',
          'hover:shadow-card-hover hover:-translate-y-1',
          variant === 'compact' ? 'aspect-square' : 'aspect-[3/4]',
          isSelected && 'ring-2 ring-primary ring-offset-2',
          className
        )}
        onClick={onClick}
      >
        {/* Full-bleed Image */}
        {primaryImage ? (
          <img
            src={primaryImage.thumbnail_url || primaryImage.image_url}
            alt={item.name}
            className={cn(
              'absolute inset-0 w-full h-full object-cover',
              'transition-transform duration-300',
              'group-hover:scale-105'
            )}
            loading="lazy"
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center">
            <Shirt className="h-12 w-12 md:h-16 md:w-16 text-muted-foreground/30" />
          </div>
        )}

        {/* Gradient Overlay */}
        <div
          className={cn(
            'absolute inset-0',
            'bg-gradient-to-t from-black/70 via-black/20 to-transparent',
            'pointer-events-none'
          )}
        />

        {/* Selection Checkbox */}
        {showSelect && (
          <button
            className={cn(
              'absolute top-2.5 left-2.5 z-10',
              'w-6 h-6 rounded-md',
              'flex items-center justify-center',
              'transition-all duration-200',
              'touch-target',
              isSelected
                ? 'bg-primary text-primary-foreground'
                : 'bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm border border-white/20'
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

        {/* Favorite Button */}
        {showFavorite && (
          <button
            className={cn(
              'absolute top-2.5 right-2.5 z-10',
              'w-9 h-9 rounded-full',
              'flex items-center justify-center',
              'transition-all duration-200',
              'touch-target',
              item.is_favorite
                ? 'bg-pink-500 text-white shadow-lg shadow-pink-500/30'
                : 'bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm text-muted-foreground hover:text-pink-500'
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

        {/* Condition Badge */}
        <Badge
          className={cn(
            'absolute top-2.5 left-10 z-10',
            'text-[10px] font-medium px-2 py-0.5',
            'shadow-sm',
            conditionConfig.bg,
            conditionConfig.text
          )}
        >
          {conditionConfig.label}
        </Badge>

        {/* Bottom Info Overlay */}
        <div className="absolute bottom-0 left-0 right-0 p-3 z-10">
          <h3 className="font-semibold text-sm text-white truncate drop-shadow-sm">
            {item.name}
          </h3>
          <p className="text-xs text-white/80 capitalize">{item.category}</p>

          {/* Additional info - shown on hover on desktop */}
          {variant !== 'compact' && (
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
          )}
        </div>
      </div>
    )
  }
)
ItemCard.displayName = 'ItemCard'

export default ItemCard
