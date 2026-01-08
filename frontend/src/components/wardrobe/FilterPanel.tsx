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
 *
 * @see https://docs.fitcheck.ai/features/wardrobe/filtering
 */

import { Search, X, Grid3x3, List, SortAsc, SortDesc } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
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
  const hasActiveFilters =
    filters.category !== 'all' ||
    filters.color !== '' ||
    filters.condition !== 'all' ||
    filters.isFavorite ||
    filters.search

  return (
    <div className="bg-white dark:bg-gray-800 shadow rounded-lg p-4 mb-6">
      <div className="flex flex-col lg:flex-row gap-4">
        {/* Search */}
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
          <Input
            type="text"
            placeholder="Search items..."
            value={filters.search}
            onChange={(e) => onFilterChange('search', e.target.value)}
            className="pl-10"
          />
        </div>

        {/* Category filter */}
        <Select
          value={filters.category}
          onValueChange={(value) => onFilterChange('category', value)}
        >
          <SelectTrigger className="w-full lg:w-[180px]">
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
          <SelectTrigger className="w-full lg:w-[180px]">
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
          <SelectTrigger className="w-full lg:w-[180px]">
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
            <SelectTrigger className="w-full lg:w-[180px]">
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

      {/* Active filters */}
      {hasActiveFilters && (
        <div className="flex items-center gap-2 mt-4 pt-4 border-t dark:border-gray-700">
          <span className="text-sm text-gray-600 dark:text-gray-400">Active filters:</span>
          {filters.category !== 'all' && (
            <Badge variant="secondary" className="gap-1">
              {CATEGORIES.find((c) => c.value === filters.category)?.label}
              <button
                onClick={() => onFilterChange('category', 'all')}
                className="hover:text-gray-900 dark:hover:text-white"
              >
                <X className="h-3 w-3" />
              </button>
            </Badge>
          )}
          {filters.color && (
            <Badge variant="secondary" className="gap-1">
              {filters.color}
              <button
                onClick={() => onFilterChange('color', '')}
                className="hover:text-gray-900 dark:hover:text-white"
              >
                <X className="h-3 w-3" />
              </button>
            </Badge>
          )}
          {filters.condition !== 'all' && (
            <Badge variant="secondary" className="gap-1">
              {CONDITIONS.find((c) => c.value === filters.condition)?.label}
              <button
                onClick={() => onFilterChange('condition', 'all')}
                className="hover:text-gray-900 dark:hover:text-white"
              >
                <X className="h-3 w-3" />
              </button>
            </Badge>
          )}
          {filters.isFavorite && (
            <Badge variant="secondary" className="gap-1">
              Favorites
              <button
                onClick={() => onFilterChange('isFavorite', false)}
                className="hover:text-gray-900 dark:hover:text-white"
              >
                <X className="h-3 w-3" />
              </button>
            </Badge>
          )}
          <Button
            variant="ghost"
            size="sm"
            onClick={onResetFilters}
            className="ml-auto"
          >
            Clear all
          </Button>
        </div>
      )}
    </div>
  )
}

export default FilterPanel
