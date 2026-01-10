/**
 * OccasionQuickFilter Component
 *
 * Provides quick occasion-based filtering for wardrobe and outfit browsing.
 * Users can select an occasion to automatically apply relevant style, category,
 * and tag filters.
 */

import { useState } from 'react'
import { Tag, ChevronDown, ChevronRight, X } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'
import {
  OCCASION_PRESETS,
  OCCASION_CATEGORIES,
  type OccasionPreset,
  getFiltersFromOccasion,
} from '@/lib/occasion-presets'
import type { Category, Style } from '@/types'
import { cn } from '@/lib/utils'

interface OccasionQuickFilterProps {
  /** Called when an occasion is selected with the filter criteria */
  onOccasionSelect: (filters: {
    occasion: OccasionPreset
    styles: Style[]
    categories: Category[]
    tags: string[]
  }) => void
  /** Called when occasion filter is cleared */
  onClear?: () => void
  /** Currently selected occasion ID */
  selectedOccasionId?: string | null
  /** Show as compact horizontal list or expanded grid */
  variant?: 'compact' | 'expanded' | 'grouped'
  /** Limit number of visible presets (for compact mode) */
  limit?: number
  /** Additional class name */
  className?: string
}

function OccasionChip({
  occasion,
  isSelected,
  onClick,
}: {
  occasion: OccasionPreset
  isSelected: boolean
  onClick: () => void
}) {
  return (
    <button
      onClick={onClick}
      className={cn(
        'inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm font-medium transition-all',
        'border whitespace-nowrap',
        isSelected
          ? 'bg-gold-100 border-gold-300 text-gold-700 dark:bg-gold-900/40 dark:border-gold-700 dark:text-gold-300'
          : 'bg-muted border-border text-foreground hover:bg-accent dark:hover:bg-accent'
      )}
    >
      <span>{occasion.icon}</span>
      <span>{occasion.name}</span>
    </button>
  )
}

function OccasionCard({
  occasion,
  isSelected,
  onClick,
}: {
  occasion: OccasionPreset
  isSelected: boolean
  onClick: () => void
}) {
  return (
    <button
      onClick={onClick}
      className={cn(
        'p-3 rounded-lg border text-left transition-all w-full',
        isSelected
          ? 'bg-gold-50 border-gold-300 dark:bg-gold-900/30 dark:border-gold-700'
          : 'bg-card border-border hover:border-muted-foreground/50'
      )}
    >
      <div className="flex items-start gap-2">
        <span className="text-xl">{occasion.icon}</span>
        <div className="flex-1 min-w-0">
          <p className="font-medium text-foreground text-sm">
            {occasion.name}
          </p>
          <p className="text-xs text-muted-foreground mt-0.5 truncate">
            {occasion.description}
          </p>
        </div>
        {isSelected && (
          <Badge variant="secondary" className="text-xs">
            Active
          </Badge>
        )}
      </div>
    </button>
  )
}

export function OccasionQuickFilter({
  onOccasionSelect,
  onClear,
  selectedOccasionId,
  variant = 'compact',
  limit = 8,
  className,
}: OccasionQuickFilterProps) {
  const [expandedCategory, setExpandedCategory] = useState<string | null>(null)

  const handleSelect = (occasion: OccasionPreset) => {
    const filters = getFiltersFromOccasion(occasion)
    onOccasionSelect({
      occasion,
      ...filters,
    })
  }

  const selectedOccasion = selectedOccasionId
    ? OCCASION_PRESETS.find((o) => o.id === selectedOccasionId)
    : null

  // Compact horizontal list
  if (variant === 'compact') {
    const visiblePresets = OCCASION_PRESETS.slice(0, limit)
    const hasMore = OCCASION_PRESETS.length > limit

    return (
      <div className={cn('space-y-2', className)}>
        <div className="flex items-center justify-between">
          <label className="text-sm font-medium text-foreground/80 flex items-center gap-2">
            <Tag className="h-4 w-4" />
            Quick Occasion Filter
          </label>
          {selectedOccasion && onClear && (
            <Button variant="ghost" size="sm" onClick={onClear} className="h-6 text-xs">
              <X className="h-3 w-3 mr-1" />
              Clear
            </Button>
          )}
        </div>
        <div className="flex flex-wrap gap-2">
          {visiblePresets.map((occasion) => (
            <OccasionChip
              key={occasion.id}
              occasion={occasion}
              isSelected={selectedOccasionId === occasion.id}
              onClick={() => handleSelect(occasion)}
            />
          ))}
          {hasMore && (
            <span className="text-xs text-muted-foreground self-center">
              +{OCCASION_PRESETS.length - limit} more
            </span>
          )}
        </div>
        {selectedOccasion && (
          <div className="p-2 rounded bg-gold-50 dark:bg-gold-900/20 text-xs text-gold-700 dark:text-gold-300">
            Filtering for: {selectedOccasion.description}
          </div>
        )}
      </div>
    )
  }

  // Expanded grid view
  if (variant === 'expanded') {
    return (
      <div className={cn('space-y-3', className)}>
        <div className="flex items-center justify-between">
          <label className="text-sm font-medium text-foreground/80 flex items-center gap-2">
            <Tag className="h-4 w-4" />
            Filter by Occasion
          </label>
          {selectedOccasion && onClear && (
            <Button variant="ghost" size="sm" onClick={onClear} className="h-6 text-xs">
              <X className="h-3 w-3 mr-1" />
              Clear
            </Button>
          )}
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
          {OCCASION_PRESETS.map((occasion) => (
            <OccasionCard
              key={occasion.id}
              occasion={occasion}
              isSelected={selectedOccasionId === occasion.id}
              onClick={() => handleSelect(occasion)}
            />
          ))}
        </div>
      </div>
    )
  }

  // Grouped by category (accordion style)
  return (
    <div className={cn('space-y-2', className)}>
      <div className="flex items-center justify-between">
        <label className="text-sm font-medium text-foreground/80 flex items-center gap-2">
          <Tag className="h-4 w-4" />
          Occasion Presets
        </label>
        {selectedOccasion && onClear && (
          <Button variant="ghost" size="sm" onClick={onClear} className="h-6 text-xs">
            <X className="h-3 w-3 mr-1" />
            Clear
          </Button>
        )}
      </div>

      {selectedOccasion && (
        <div className="p-2 rounded bg-gold-50 dark:bg-gold-900/20 flex items-center justify-between">
          <span className="text-sm text-gold-700 dark:text-gold-300 flex items-center gap-2">
            <span>{selectedOccasion.icon}</span>
            {selectedOccasion.name}
          </span>
          <Badge variant="outline" className="text-xs">
            Active
          </Badge>
        </div>
      )}

      <div className="space-y-1">
        {OCCASION_CATEGORIES.map((category) => (
          <Collapsible
            key={category.name}
            open={expandedCategory === category.name}
            onOpenChange={(open) =>
              setExpandedCategory(open ? category.name : null)
            }
          >
            <CollapsibleTrigger asChild>
              <Button
                variant="ghost"
                className="w-full justify-between h-9 text-sm"
              >
                <span className="flex items-center gap-2">
                  <span>{category.icon}</span>
                  {category.name}
                </span>
                {expandedCategory === category.name ? (
                  <ChevronDown className="h-4 w-4" />
                ) : (
                  <ChevronRight className="h-4 w-4" />
                )}
              </Button>
            </CollapsibleTrigger>
            <CollapsibleContent className="pl-6 pt-1 pb-2">
              <div className="flex flex-wrap gap-2">
                {category.occasions.map((occasion) => (
                  <OccasionChip
                    key={occasion.id}
                    occasion={occasion}
                    isSelected={selectedOccasionId === occasion.id}
                    onClick={() => handleSelect(occasion)}
                  />
                ))}
              </div>
            </CollapsibleContent>
          </Collapsible>
        ))}
      </div>
    </div>
  )
}

export default OccasionQuickFilter
