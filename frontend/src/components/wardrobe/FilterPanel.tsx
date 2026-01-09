/**
 * FilterPanel Component
 *
 * Reusable filter panel for wardrobe items.
 * Features:
 * - Search by name or tags
 * - Filter by category, color, condition
 * - Favorite toggle
 * - Sort options
 * - Active filter display with clear option
 * - Collapsible on mobile
 *
 * @see https://docs.fitcheck.ai/features/wardrobe/filtering
 */

import { useState } from 'react'
import { Search, X, Grid3x3, List, SortAsc, SortDesc, SlidersHorizontal } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from '@/components/ui/collapsible'
import type { Category, Condition } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

export interface ItemFilters {
  search: string
  category: Category | 'all'
  color: string
  condition: Condition | 'all'
  isFavorite: boolean
}

export interface SortOptions {
  sortBy: 'date_added' | 'name' | 'category' | 'times_worn'
  sortOrder: 'asc' | 'desc'
  isGridView: boolean
}

interface FilterPanelProps {
  filters: ItemFilters
  sort: SortOptions
  onFilterChange: (key: keyof ItemFilters, value: any) => void
  onSortChange: (key: keyof SortOptions, value: any) => void
  onResetFilters: () => void
}

// ============================================================================
// CONSTANTS
// ============================================================================

const CATEGORIES: { value: Category | 'all'; label: string }[] = [
  { value: 'all', label: 'All Categories' },
  { value: 'tops', label: 'Tops' },
  { value: 'bottoms', label: 'Bottoms' },
  { value: 'shoes', label: 'Shoes' },
  { value: 'accessories', label: 'Accessories' },
  { value: 'outerwear', label: 'Outerwear' },
  { value: 'swimwear', label: 'Swimwear' },
  { value: 'activewear', label: 'Activewear' },
]

const CONDITIONS: { value: Condition | 'all'; label: string }[] = [
  { value: 'all', label: 'All Conditions' },
  { value: 'clean', label: 'Clean' },
  { value: 'dirty', label: 'Dirty' },
  { value: 'laundry', label: 'In Laundry' },
  { value: 'repair', label: 'Needs Repair' },
  { value: 'donate', label: 'To Donate' },
]

const SORT_OPTIONS = [
  { value: 'date_added', label: 'Date Added' },
  { value: 'name', label: 'Name' },
  { value: 'category', label: 'Category' },
  { value: 'times_worn', label: 'Times Worn' },
]

const COMMON_COLORS = [
  'All Colors',
  'Black',
  'White',
  'Gray',
  'Navy',
  'Brown',
  'Beige',
  'Red',
  'Blue',
  'Green',
  'Yellow',
  'Pink',
  'Purple',
  'Orange',
  'Tan',
]

// ============================================================================
// COMPONENT
// ============================================================================

export function FilterPanel({
  filters,
  sort,
  onFilterChange,
  onSortChange,
  onResetFilters,
}: FilterPanelProps) {
  const [isExpanded, setIsExpanded] = useState(false)

  const hasActiveFilters =
    filters.category !== 'all' ||
    filters.color !== '' ||
    filters.condition !== 'all' ||
    filters.isFavorite ||
    filters.search

  const activeFilterCount = [
    filters.category !== 'all',
    filters.color !== '',
    filters.condition !== 'all',
    filters.isFavorite,
  ].filter(Boolean).length

  return (
    <div className="bg-card shadow rounded-lg p-3 md:p-4 mb-4 md:mb-6">
      {/* Always visible: Search + Filter toggle (mobile) */}
      <div className="flex gap-2 md:gap-4">
        {/* Search */}
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 md:h-5 md:w-5 text-muted-foreground" />
          <Input
            type="text"
            placeholder="Search items..."
            value={filters.search}
            onChange={(e) => onFilterChange('search', e.target.value)}
            className="pl-9 md:pl-10"
          />
        </div>

        {/* Mobile filter toggle */}
        <Collapsible open={isExpanded} onOpenChange={setIsExpanded} className="md:contents">
          <CollapsibleTrigger asChild className="md:hidden">
            <Button variant="outline" size="icon" className="relative shrink-0">
              <SlidersHorizontal className="h-4 w-4" />
              {activeFilterCount > 0 && (
                <span className="absolute -top-1 -right-1 w-4 h-4 bg-primary text-primary-foreground text-xs rounded-full flex items-center justify-center">
                  {activeFilterCount}
                </span>
              )}
            </Button>
          </CollapsibleTrigger>

          {/* Desktop filters - always visible */}
          <div className="hidden md:contents">
            {/* Category filter */}
            <Select
              value={filters.category}
              onValueChange={(value) => onFilterChange('category', value)}
            >
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="Category" />
              </SelectTrigger>
              <SelectContent>
                {CATEGORIES.map((cat) => (
                  <SelectItem key={cat.value} value={cat.value}>
                    {cat.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            {/* Color filter */}
            <Select
              value={filters.color || 'all'}
              onValueChange={(value) => onFilterChange('color', value === 'all' ? '' : value)}
            >
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="Color" />
              </SelectTrigger>
              <SelectContent>
                {COMMON_COLORS.map((color) => (
                  <SelectItem key={color} value={color === 'All Colors' ? 'all' : color}>
                    {color}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            {/* Condition filter */}
            <Select
              value={filters.condition}
              onValueChange={(value) => onFilterChange('condition', value)}
            >
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="Condition" />
              </SelectTrigger>
              <SelectContent>
                {CONDITIONS.map((cond) => (
                  <SelectItem key={cond.value} value={cond.value}>
                    {cond.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            {/* Sort */}
            <div className="flex items-center gap-2">
              <Select
                value={sort.sortBy}
                onValueChange={(value) => onSortChange('sortBy', value)}
              >
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Sort by" />
                </SelectTrigger>
                <SelectContent>
                  {SORT_OPTIONS.map((opt) => (
                    <SelectItem key={opt.value} value={opt.value}>
                      {opt.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <Button
                variant="outline"
                size="icon"
                onClick={() => onSortChange('sortOrder', sort.sortOrder === 'asc' ? 'desc' : 'asc')}
                title={sort.sortOrder === 'asc' ? 'Ascending' : 'Descending'}
              >
                {sort.sortOrder === 'asc' ? (
                  <SortAsc className="h-5 w-5" />
                ) : (
                  <SortDesc className="h-5 w-5" />
                )}
              </Button>
            </div>

            {/* View toggle */}
            <div className="flex items-center gap-2">
              <Button
                variant={sort.isGridView ? 'default' : 'outline'}
                size="icon"
                onClick={() => onSortChange('isGridView', true)}
              >
                <Grid3x3 className="h-5 w-5" />
              </Button>
              <Button
                variant={!sort.isGridView ? 'default' : 'outline'}
                size="icon"
                onClick={() => onSortChange('isGridView', false)}
              >
                <List className="h-5 w-5" />
              </Button>
            </div>
          </div>

          {/* Mobile collapsible filters */}
          <CollapsibleContent className="md:hidden">
            <div className="grid grid-cols-2 gap-3 mt-3 pt-3 border-t border-border">
              {/* Category filter */}
              <Select
                value={filters.category}
                onValueChange={(value) => onFilterChange('category', value)}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Category" />
                </SelectTrigger>
                <SelectContent>
                  {CATEGORIES.map((cat) => (
                    <SelectItem key={cat.value} value={cat.value}>
                      {cat.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>

              {/* Color filter */}
              <Select
                value={filters.color || 'all'}
                onValueChange={(value) => onFilterChange('color', value === 'all' ? '' : value)}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Color" />
                </SelectTrigger>
                <SelectContent>
                  {COMMON_COLORS.map((color) => (
                    <SelectItem key={color} value={color === 'All Colors' ? 'all' : color}>
                      {color}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>

              {/* Condition filter */}
              <Select
                value={filters.condition}
                onValueChange={(value) => onFilterChange('condition', value)}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Condition" />
                </SelectTrigger>
                <SelectContent>
                  {CONDITIONS.map((cond) => (
                    <SelectItem key={cond.value} value={cond.value}>
                      {cond.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>

              {/* Sort */}
              <Select
                value={sort.sortBy}
                onValueChange={(value) => onSortChange('sortBy', value)}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Sort by" />
                </SelectTrigger>
                <SelectContent>
                  {SORT_OPTIONS.map((opt) => (
                    <SelectItem key={opt.value} value={opt.value}>
                      {opt.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>

              {/* View toggle + Sort order */}
              <div className="col-span-2 flex items-center justify-between gap-2">
                <div className="flex items-center gap-2">
                  <Button
                    variant={sort.isGridView ? 'default' : 'outline'}
                    size="icon"
                    onClick={() => onSortChange('isGridView', true)}
                  >
                    <Grid3x3 className="h-5 w-5" />
                  </Button>
                  <Button
                    variant={!sort.isGridView ? 'default' : 'outline'}
                    size="icon"
                    onClick={() => onSortChange('isGridView', false)}
                  >
                    <List className="h-5 w-5" />
                  </Button>
                </div>
                <Button
                  variant="outline"
                  size="icon"
                  onClick={() => onSortChange('sortOrder', sort.sortOrder === 'asc' ? 'desc' : 'asc')}
                >
                  {sort.sortOrder === 'asc' ? (
                    <SortAsc className="h-5 w-5" />
                  ) : (
                    <SortDesc className="h-5 w-5" />
                  )}
                </Button>
              </div>
            </div>
          </CollapsibleContent>
        </Collapsible>
      </div>

      {/* Active filters */}
      {hasActiveFilters && (
        <div className="flex items-center gap-2 mt-3 pt-3 border-t border-border overflow-x-auto scrollbar-hide">
          <span className="text-sm text-muted-foreground shrink-0">Active:</span>
          <div className="flex items-center gap-2 overflow-x-auto scrollbar-hide">
            {filters.category !== 'all' && (
              <Badge variant="secondary" className="gap-1 shrink-0">
                {CATEGORIES.find((c) => c.value === filters.category)?.label}
                <button
                  onClick={() => onFilterChange('category', 'all')}
                  className="hover:text-foreground touch-target flex items-center justify-center"
                >
                  <X className="h-3 w-3" />
                </button>
              </Badge>
            )}
            {filters.color && (
              <Badge variant="secondary" className="gap-1 shrink-0">
                {filters.color}
                <button
                  onClick={() => onFilterChange('color', '')}
                  className="hover:text-foreground touch-target flex items-center justify-center"
                >
                  <X className="h-3 w-3" />
                </button>
              </Badge>
            )}
            {filters.condition !== 'all' && (
              <Badge variant="secondary" className="gap-1 shrink-0">
                {CONDITIONS.find((c) => c.value === filters.condition)?.label}
                <button
                  onClick={() => onFilterChange('condition', 'all')}
                  className="hover:text-foreground touch-target flex items-center justify-center"
                >
                  <X className="h-3 w-3" />
                </button>
              </Badge>
            )}
            {filters.isFavorite && (
              <Badge variant="secondary" className="gap-1 shrink-0">
                Favorites
                <button
                  onClick={() => onFilterChange('isFavorite', false)}
                  className="hover:text-foreground touch-target flex items-center justify-center"
                >
                  <X className="h-3 w-3" />
                </button>
              </Badge>
            )}
          </div>
          <Button
            variant="ghost"
            size="sm"
            onClick={onResetFilters}
            className="ml-auto shrink-0"
          >
            Clear all
          </Button>
        </div>
      )}
    </div>
  )
}

export default FilterPanel
