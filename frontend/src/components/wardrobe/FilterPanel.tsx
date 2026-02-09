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
 * - Bottom sheet on mobile, inline on desktop
 *
 * @see https://docs.fitcheck.ai/features/wardrobe/filtering
 */

import { useState } from 'react'
import { Search, X, Grid3x3, List, SortAsc, SortDesc, SlidersHorizontal, Heart } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  BottomSheet,
  BottomSheetContent,
  BottomSheetHeader,
  BottomSheetTitle,
  BottomSheetFooter,
  BottomSheetTrigger,
} from '@/components/ui/bottom-sheet'
import { DEFAULT_USE_CASES, formatUseCaseLabel, normalizeUseCase } from '@/lib/use-cases'
import { cn } from '@/lib/utils'
import type { Category, Condition } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

export interface ItemFilters {
  search: string
  category: Category | 'all'
  color: string
  occasion: string
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
  { value: 'all', label: 'All Colors', color: null },
  { value: 'Black', label: 'Black', color: '#000000' },
  { value: 'White', label: 'White', color: '#FFFFFF' },
  { value: 'Gray', label: 'Gray', color: '#6B7280' },
  { value: 'Navy', label: 'Navy', color: '#1E3A5F' },
  { value: 'Brown', label: 'Brown', color: '#92400E' },
  { value: 'Beige', label: 'Beige', color: '#D4C4B0' },
  { value: 'Red', label: 'Red', color: '#DC2626' },
  { value: 'Blue', label: 'Blue', color: '#2563EB' },
  { value: 'Green', label: 'Green', color: '#16A34A' },
  { value: 'Yellow', label: 'Yellow', color: '#EAB308' },
  { value: 'Pink', label: 'Pink', color: '#EC4899' },
  { value: 'Purple', label: 'Purple', color: '#9333EA' },
  { value: 'Orange', label: 'Orange', color: '#EA580C' },
  { value: 'Tan', label: 'Tan', color: '#D2B48C' },
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
  const [isOpen, setIsOpen] = useState(false)
  const [customUseCase, setCustomUseCase] = useState('')

  const hasActiveFilters =
    filters.category !== 'all' ||
    filters.color !== '' ||
    filters.occasion !== '' ||
    filters.condition !== 'all' ||
    filters.isFavorite ||
    filters.search

  const activeFilterCount = [
    filters.category !== 'all',
    filters.color !== '',
    filters.occasion !== '',
    filters.condition !== 'all',
    filters.isFavorite,
  ].filter(Boolean).length

  const setOccasionFilter = (value: string) => {
    onFilterChange('occasion', normalizeUseCase(value))
  }

  const addCustomUseCase = () => {
    const normalized = normalizeUseCase(customUseCase)
    if (!normalized) return
    setOccasionFilter(normalized)
    setCustomUseCase('')
  }

  return (
    <div className="bg-card shadow-sm rounded-xl p-3 md:p-4 mb-4 md:mb-6">
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

        {/* Mobile filter bottom sheet */}
        <div className="md:hidden">
          <BottomSheet open={isOpen} onOpenChange={setIsOpen}>
            <BottomSheetTrigger asChild>
              <Button variant="outline" size="icon" className="relative shrink-0">
                <SlidersHorizontal className="h-4 w-4" />
                {activeFilterCount > 0 && (
                  <span className="absolute -top-1 -right-1 w-4 h-4 bg-primary text-primary-foreground text-xs rounded-full flex items-center justify-center">
                    {activeFilterCount}
                  </span>
                )}
              </Button>
            </BottomSheetTrigger>
            <BottomSheetContent height="large">
              <BottomSheetHeader>
                <BottomSheetTitle>Filters & Sort</BottomSheetTitle>
              </BottomSheetHeader>

              <div className="flex-1 overflow-y-auto py-4 space-y-6">
                {/* Category Section */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">Category</label>
                  <Select
                    value={filters.category}
                    onValueChange={(value) => onFilterChange('category', value)}
                  >
                    <SelectTrigger className="w-full">
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
                </div>

                {/* Color Section */}
                <div className="space-y-3">
                  <label className="text-sm font-medium text-foreground">Color</label>
                  <div className="flex flex-wrap gap-2">
                    {COMMON_COLORS.map((c) => (
                      <button
                        key={c.value}
                        onClick={() => onFilterChange('color', c.value === 'all' ? '' : c.value)}
                        className={cn(
                          'flex items-center gap-2 px-3 py-2 rounded-full text-sm',
                          'border transition-all duration-200',
                          (filters.color === c.value || (c.value === 'all' && filters.color === ''))
                            ? 'border-primary bg-primary/10 text-primary'
                            : 'border-border hover:border-primary/50'
                        )}
                      >
                        {c.color && (
                          <span
                            className="w-4 h-4 rounded-full border border-border/50"
                            style={{ backgroundColor: c.color }}
                          />
                        )}
                        <span>{c.label}</span>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Condition Section */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">Condition</label>
                  <Select
                    value={filters.condition}
                    onValueChange={(value) => onFilterChange('condition', value)}
                  >
                    <SelectTrigger className="w-full">
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
                </div>

                {/* Use Case Section */}
                <div className="space-y-3">
                  <label className="text-sm font-medium text-foreground">Use Case</label>
                  <div className="flex flex-wrap gap-2">
                    <button
                      onClick={() => setOccasionFilter('')}
                      className={cn(
                        'px-3 py-2 rounded-full text-sm border transition-all duration-200',
                        filters.occasion === ''
                          ? 'border-primary bg-primary/10 text-primary'
                          : 'border-border hover:border-primary/50'
                      )}
                    >
                      All
                    </button>
                    {DEFAULT_USE_CASES.map((useCase) => (
                      <button
                        key={useCase}
                        onClick={() => setOccasionFilter(useCase)}
                        className={cn(
                          'px-3 py-2 rounded-full text-sm border transition-all duration-200',
                          filters.occasion === useCase
                            ? 'border-primary bg-primary/10 text-primary'
                            : 'border-border hover:border-primary/50'
                        )}
                      >
                        {formatUseCaseLabel(useCase)}
                      </button>
                    ))}
                  </div>
                  <div className="flex gap-2">
                    <Input
                      placeholder="Custom use case"
                      value={customUseCase}
                      onChange={(e) => setCustomUseCase(e.target.value)}
                      onKeyDown={(e) => {
                        if (e.key === 'Enter') {
                          e.preventDefault()
                          addCustomUseCase()
                        }
                      }}
                    />
                    <Button type="button" variant="outline" onClick={addCustomUseCase}>
                      Add
                    </Button>
                  </div>
                </div>

                {/* Favorites Toggle */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">Quick Filters</label>
                  <button
                    onClick={() => onFilterChange('isFavorite', !filters.isFavorite)}
                    className={cn(
                      'flex items-center gap-2 px-4 py-3 rounded-xl w-full',
                      'border transition-all duration-200',
                      filters.isFavorite
                        ? 'border-pink-500 bg-pink-500/10 text-pink-500'
                        : 'border-border hover:border-pink-500/50'
                    )}
                  >
                    <Heart className={cn('h-5 w-5', filters.isFavorite && 'fill-current')} />
                    <span className="font-medium">Favorites Only</span>
                  </button>
                </div>

                {/* Sort Section */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">Sort By</label>
                  <div className="flex gap-2">
                    <Select
                      value={sort.sortBy}
                      onValueChange={(value) => onSortChange('sortBy', value)}
                    >
                      <SelectTrigger className="flex-1">
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
                    >
                      {sort.sortOrder === 'asc' ? (
                        <SortAsc className="h-5 w-5" />
                      ) : (
                        <SortDesc className="h-5 w-5" />
                      )}
                    </Button>
                  </div>
                </div>

                {/* View Toggle */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">View</label>
                  <div className="flex gap-2">
                    <Button
                      variant={sort.isGridView ? 'default' : 'outline'}
                      className="flex-1"
                      onClick={() => onSortChange('isGridView', true)}
                    >
                      <Grid3x3 className="h-4 w-4 mr-2" />
                      Grid
                    </Button>
                    <Button
                      variant={!sort.isGridView ? 'default' : 'outline'}
                      className="flex-1"
                      onClick={() => onSortChange('isGridView', false)}
                    >
                      <List className="h-4 w-4 mr-2" />
                      List
                    </Button>
                  </div>
                </div>
              </div>

              <BottomSheetFooter>
                <Button variant="outline" onClick={onResetFilters} className="flex-1">
                  Clear All
                </Button>
                <Button onClick={() => setIsOpen(false)} className="flex-1">
                  Apply Filters
                </Button>
              </BottomSheetFooter>
            </BottomSheetContent>
          </BottomSheet>
        </div>

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
              {COMMON_COLORS.map((c) => (
                <SelectItem key={c.value} value={c.value}>
                  <div className="flex items-center gap-2">
                    {c.color && (
                      <span
                        className="w-3 h-3 rounded-full border border-border/50"
                        style={{ backgroundColor: c.color }}
                      />
                    )}
                    <span>{c.label}</span>
                  </div>
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
      </div>

      <div className="hidden md:block mt-3 pt-3 border-t border-border">
        <label className="text-sm font-medium text-foreground">Use Case</label>
        <div className="mt-2 flex flex-wrap items-center gap-2">
          <Button
            type="button"
            variant={filters.occasion === '' ? 'default' : 'outline'}
            size="sm"
            onClick={() => setOccasionFilter('')}
          >
            All
          </Button>
          {DEFAULT_USE_CASES.map((useCase) => (
            <Button
              key={useCase}
              type="button"
              variant={filters.occasion === useCase ? 'default' : 'outline'}
              size="sm"
              onClick={() => setOccasionFilter(useCase)}
            >
              {formatUseCaseLabel(useCase)}
            </Button>
          ))}
          <div className="flex items-center gap-2">
            <Input
              className="h-9 w-[180px]"
              placeholder="Custom use case"
              value={customUseCase}
              onChange={(e) => setCustomUseCase(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter') {
                  e.preventDefault()
                  addCustomUseCase()
                }
              }}
            />
            <Button type="button" variant="outline" size="sm" onClick={addCustomUseCase}>
              Add
            </Button>
          </div>
        </div>
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
                <span
                  className="w-3 h-3 rounded-full border border-border/50"
                  style={{ backgroundColor: COMMON_COLORS.find((c) => c.value === filters.color)?.color || undefined }}
                />
                {filters.color}
                <button
                  onClick={() => onFilterChange('color', '')}
                  className="hover:text-foreground touch-target flex items-center justify-center"
                >
                  <X className="h-3 w-3" />
                </button>
              </Badge>
            )}
            {filters.occasion && (
              <Badge variant="secondary" className="gap-1 shrink-0">
                {formatUseCaseLabel(filters.occasion)}
                <button
                  onClick={() => onFilterChange('occasion', '')}
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
              <Badge variant="secondary" className="gap-1 shrink-0 text-pink-500">
                <Heart className="h-3 w-3 fill-current" />
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
