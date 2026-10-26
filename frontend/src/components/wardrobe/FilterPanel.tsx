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
import { X, Grid3x3, List, SortAsc, SortDesc, SlidersHorizontal, Heart } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { SearchBar } from '@/components/ui/search-bar'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  BottomSheet,
  BottomSheetContent,
  BottomSheetHeader,
  BottomSheetTitle,
  BottomSheetDescription,
  BottomSheetFooter,
  BottomSheetTrigger,
} from '@/components/ui/bottom-sheet'
import { DEFAULT_USE_CASES, normalizeUseCase } from '@/lib/use-cases'
import { cn } from '@/lib/utils'
import { colorLabel, useTranslation, describeUseCase, useFormattingLocale } from '@/i18n'
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
  onFilterChange: <K extends keyof ItemFilters>(key: K, value: ItemFilters[K]) => void
  onSortChange: <K extends keyof SortOptions>(key: K, value: SortOptions[K]) => void
  onResetFilters: () => void
}

// ============================================================================
// CONSTANTS
// ============================================================================

// `value` is the canonical stored enum and never changes; `labelKey` is what
// the user reads. Resolved at render, not here, so a language switch repaints.
const CATEGORIES: { value: Category | 'all'; labelKey: string }[] = [
  { value: 'all', labelKey: 'filters.allCategories' },
  { value: 'tops', labelKey: 'taxonomy.category.tops' },
  { value: 'bottoms', labelKey: 'taxonomy.category.bottoms' },
  { value: 'shoes', labelKey: 'taxonomy.category.shoes' },
  { value: 'accessories', labelKey: 'taxonomy.category.accessories' },
  { value: 'outerwear', labelKey: 'taxonomy.category.outerwear' },
  { value: 'swimwear', labelKey: 'taxonomy.category.swimwear' },
  { value: 'activewear', labelKey: 'taxonomy.category.activewear' },
]

const CONDITIONS: { value: Condition | 'all'; labelKey: string }[] = [
  { value: 'all', labelKey: 'filters.allConditions' },
  { value: 'clean', labelKey: 'taxonomy.condition.clean' },
  { value: 'dirty', labelKey: 'taxonomy.condition.dirty' },
  { value: 'laundry', labelKey: 'taxonomy.condition.laundry' },
  { value: 'repair', labelKey: 'taxonomy.condition.repair' },
  { value: 'donate', labelKey: 'taxonomy.condition.donate' },
]

const SORT_OPTIONS = [
  { value: 'date_added', labelKey: 'filters.dateAdded' },
  { value: 'name', labelKey: 'filters.name' },
  { value: 'category', labelKey: 'filters.category' },
  { value: 'times_worn', labelKey: 'filters.timesWorn' },
]

// Colour names are translated by `colorLabel(t, value)`, which is keyed on the
// stored value; a colour the AI invented falls through as itself.
const COMMON_COLORS: { value: string; color: string | null }[] = [
  { value: 'all', color: null },
  { value: 'Black', color: '#000000' },
  { value: 'White', color: '#FFFFFF' },
  { value: 'Gray', color: '#6B7280' },
  { value: 'Navy', color: '#1E3A5F' },
  { value: 'Brown', color: '#92400E' },
  { value: 'Beige', color: '#D4C4B0' },
  { value: 'Red', color: '#DC2626' },
  { value: 'Blue', color: '#2563EB' },
  { value: 'Green', color: '#16A34A' },
  { value: 'Yellow', color: '#EAB308' },
  { value: 'Pink', color: '#EC4899' },
  { value: 'Purple', color: '#9333EA' },
  { value: 'Orange', color: '#EA580C' },
  { value: 'Tan', color: '#D2B48C' },
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
  const { t } = useTranslation()
  const formattingLocale = useFormattingLocale()
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
    <div className="mb-4 rounded-md border border-border bg-surface-soft p-3 md:mb-6 md:p-4">
      {/* Always visible: Search + Filter toggle (mobile) */}
      <div className="flex flex-wrap items-center gap-2 md:gap-4">
        {/* Search */}
        <div className="min-w-0 flex-[1_1_0%] md:flex-[1_1_18rem]">
          <SearchBar
            placeholder={t('filters.searchPlaceholder')}
            value={filters.search}
            onChange={(e) => onFilterChange('search', e.target.value)}
            aria-label={t('filters.searchLabel')}
          />
        </div>

        {/* Mobile filter bottom sheet */}
        <div className="md:hidden">
          <BottomSheet open={isOpen} onOpenChange={setIsOpen}>
            <BottomSheetTrigger asChild>
              <Button
                variant="outline"
                size="icon"
                // h-12 (48px) matches the search pill beside it; size="icon"
                // alone is h-11 (44px) and read as the small control in the
                // row. The wrapper is md:hidden, so desktop is unaffected.
                className="relative h-12 w-12 shrink-0"
                aria-label={
                  activeFilterCount > 0
                    ? `Filters and sort, ${activeFilterCount} active`
                    : 'Filters and sort'
                }
              >
                <SlidersHorizontal className="h-4 w-4" />
                {activeFilterCount > 0 && (
                  <span className="absolute -top-1 --end-1 w-4 h-4 bg-primary text-primary-foreground text-xs rounded-full flex items-center justify-center">
                    {activeFilterCount}
                  </span>
                )}
              </Button>
            </BottomSheetTrigger>
            <BottomSheetContent
              height="large"
              footer={
                <BottomSheetFooter>
                  <Button variant="outline" onClick={onResetFilters} className="flex-1">
                    {t('filters.clearAll')}
                  </Button>
                  <Button onClick={() => setIsOpen(false)} className="flex-1">
                    {t('filters.apply')}
                  </Button>
                </BottomSheetFooter>
              }
            >
              <BottomSheetHeader>
                <BottomSheetTitle>{t('filters.filtersAndSort')}</BottomSheetTitle>
                <BottomSheetDescription className="sr-only">
                  Choose wardrobe filters, sorting, and grid or list view.
                </BottomSheetDescription>
              </BottomSheetHeader>

              <div className="py-4 space-y-6">
                {/* Category Section */}
                <div className="space-y-2">
                  <label htmlFor="filter-category-mobile" className="text-sm font-medium text-foreground">{t('filters.category')}</label>
                  <Select
                    value={filters.category}
                    onValueChange={(value) => onFilterChange('category', value as ItemFilters['category'])}
                  >
                    <SelectTrigger id="filter-category-mobile" className="w-full">
                      <SelectValue placeholder={t('filters.category')} />
                    </SelectTrigger>
                    <SelectContent>
                      {CATEGORIES.map((cat) => (
                        <SelectItem key={cat.value} value={cat.value}>
                          {t(cat.labelKey)}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                {/* Color Section */}
                <div className="space-y-3">
                  <span id="filter-color-label-mobile" className="text-sm font-medium text-foreground">{t('filters.color')}</span>
                  <div role="group" aria-labelledby="filter-color-label-mobile" className="flex flex-wrap gap-2">
                    {COMMON_COLORS.map((c) => (
                      <button
                        type="button"
                        key={c.value}
                        onClick={() => onFilterChange('color', c.value === 'all' ? '' : c.value)}
                        className={cn(
                          'flex min-h-[44px] items-center gap-2 px-3 py-2 rounded-full text-sm',
                          'border transition-colors duration-200',
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
                        <span>{colorLabel(t, c.value)}</span>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Condition Section */}
                <div className="space-y-2">
                  <label htmlFor="filter-condition-mobile" className="text-sm font-medium text-foreground">{t('filters.condition')}</label>
                  <Select
                    value={filters.condition}
                    onValueChange={(value) => onFilterChange('condition', value as ItemFilters['condition'])}
                  >
                    <SelectTrigger id="filter-condition-mobile" className="w-full">
                      <SelectValue placeholder={t('filters.condition')} />
                    </SelectTrigger>
                    <SelectContent>
                      {CONDITIONS.map((cond) => (
                        <SelectItem key={cond.value} value={cond.value}>
                          {t(cond.labelKey)}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                {/* Use Case Section */}
                <div className="space-y-3">
                  <span id="filter-usecase-label-mobile" className="text-sm font-medium text-foreground">{t('filters.useCase')}</span>
                  <div role="group" aria-labelledby="filter-usecase-label-mobile" className="flex flex-wrap gap-2">
                    <button
                      type="button"
                      onClick={() => setOccasionFilter('')}
                      className={cn(
                        'inline-flex min-h-[44px] items-center px-3 py-2 rounded-full text-sm border transition-colors duration-200',
                        filters.occasion === ''
                          ? 'border-primary bg-primary/10 text-primary'
                          : 'border-border hover:border-primary/50'
                      )}
                    >
                      All
                    </button>
                    {DEFAULT_USE_CASES.map((useCase) => (
                      <button
                        type="button"
                        key={useCase}
                        onClick={() => setOccasionFilter(useCase)}
                        className={cn(
                          'inline-flex min-h-[44px] items-center px-3 py-2 rounded-full text-sm border transition-colors duration-200',
                          filters.occasion === useCase
                            ? 'border-primary bg-primary/10 text-primary'
                            : 'border-border hover:border-primary/50'
                        )}
                      >
                        {describeUseCase(t, useCase, formattingLocale)}
                      </button>
                    ))}
                  </div>
                  <div className="flex gap-2">
                    <label htmlFor="wardrobe-custom-use-case" className="sr-only">{t('filters.customUseCase')}</label>
                    <Input
                      id="wardrobe-custom-use-case"
                      name="custom_use_case"
                      autoComplete="off"
                      className="min-w-0 flex-1"
                      placeholder={t('filters.customUseCasePlaceholder')}
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
                  <span className="text-sm font-medium text-foreground">{t('filters.quickFilters')}</span>
                  <button
                    type="button"
                    onClick={() => onFilterChange('isFavorite', !filters.isFavorite)}
                    className={cn(
                      'flex items-center gap-2 px-4 py-3 rounded-xl w-full',
                      'border transition-colors duration-200',
                      filters.isFavorite
                        ? 'border-primary bg-primary/10 text-primary'
                        : 'border-border hover:border-primary/50'
                    )}
                  >
                    <Heart className={cn('h-5 w-5', filters.isFavorite && 'fill-current')} />
                    <span className="font-medium">{t('filters.favoritesOnly')}</span>
                  </button>
                </div>

                {/* Sort Section */}
                <div className="space-y-2">
                  <label htmlFor="filter-sortby-mobile" className="text-sm font-medium text-foreground">{t('filters.sortBy')}</label>
                  <div className="flex gap-2">
                    <Select
                      value={sort.sortBy}
                      onValueChange={(value) => onSortChange('sortBy', value as SortOptions['sortBy'])}
                    >
                      <SelectTrigger id="filter-sortby-mobile" className="flex-1">
                        <SelectValue placeholder={t('filters.sortBy')} />
                      </SelectTrigger>
                      <SelectContent>
                        {SORT_OPTIONS.map((opt) => (
                          <SelectItem key={opt.value} value={opt.value}>
                            {t(opt.labelKey)}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <Button
                      variant="outline"
                      size="icon"
                      aria-label={sort.sortOrder === 'asc' ? t('filters.sortAscending') : t('filters.sortDescending')}
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
                  <span id="filter-view-label-mobile" className="text-sm font-medium text-foreground">{t('filters.view')}</span>
                  <div role="group" aria-labelledby="filter-view-label-mobile" className="flex gap-2">
                    <Button
                      variant={sort.isGridView ? 'default' : 'outline'}
                      className="flex-1"
                      onClick={() => onSortChange('isGridView', true)}
                    >
                      <Grid3x3 className="h-4 w-4 me-2" />
                      {t('common.grid')}
                    </Button>
                    <Button
                      variant={!sort.isGridView ? 'default' : 'outline'}
                      className="flex-1"
                      onClick={() => onSortChange('isGridView', false)}
                    >
                      <List className="h-4 w-4 me-2" />
                      {t('common.list')}
                    </Button>
                  </div>
                </div>
              </div>

            </BottomSheetContent>
          </BottomSheet>
        </div>

        {/* Desktop filters - always visible */}
        <div className="hidden min-w-0 flex-[2_1_36rem] flex-wrap items-center gap-2 md:flex">
          {/* Category filter */}
          <Select
            value={filters.category}
            onValueChange={(value) => onFilterChange('category', value as ItemFilters['category'])}
          >
            <SelectTrigger className="w-[160px] lg:w-[180px]">
              <SelectValue placeholder={t('filters.category')} />
            </SelectTrigger>
            <SelectContent>
              {CATEGORIES.map((cat) => (
                <SelectItem key={cat.value} value={cat.value}>
                  {t(cat.labelKey)}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          {/* Color filter */}
          <Select
            value={filters.color || 'all'}
            onValueChange={(value) => onFilterChange('color', value === 'all' ? '' : value)}
          >
            <SelectTrigger className="w-[160px] lg:w-[180px]">
              <SelectValue placeholder={t('filters.color')} />
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
                    <span>{colorLabel(t, c.value)}</span>
                  </div>
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          {/* Condition filter */}
          <Select
            value={filters.condition}
            onValueChange={(value) => onFilterChange('condition', value as ItemFilters['condition'])}
          >
            <SelectTrigger className="w-[160px] lg:w-[180px]">
              <SelectValue placeholder={t('filters.condition')} />
            </SelectTrigger>
            <SelectContent>
              {CONDITIONS.map((cond) => (
                <SelectItem key={cond.value} value={cond.value}>
                  {t(cond.labelKey)}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          {/* Sort */}
          <div className="flex items-center gap-2">
            <Select
              value={sort.sortBy}
              onValueChange={(value) => onSortChange('sortBy', value as SortOptions['sortBy'])}
            >
              <SelectTrigger className="w-[160px] lg:w-[180px]">
                <SelectValue placeholder={t('filters.sortBy')} />
              </SelectTrigger>
              <SelectContent>
                {SORT_OPTIONS.map((opt) => (
                  <SelectItem key={opt.value} value={opt.value}>
                    {t(opt.labelKey)}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Button
              variant="outline"
              size="icon"
              onClick={() => onSortChange('sortOrder', sort.sortOrder === 'asc' ? 'desc' : 'asc')}
              title={sort.sortOrder === 'asc' ? 'Ascending' : 'Descending'}
              aria-label={sort.sortOrder === 'asc' ? t('filters.sortAscending') : t('filters.sortDescending')}
            >
              {sort.sortOrder === 'asc' ? (
                <SortAsc className="h-5 w-5" />
              ) : (
                <SortDesc className="h-5 w-5" />
              )}
            </Button>
          </div>

          {/* Favorites (parity with mobile sheet) */}
          <Button
            type="button"
            variant={filters.isFavorite ? 'default' : 'outline'}
            size="icon"
            aria-label={filters.isFavorite ? 'Show all items' : 'Show favorites only'}
            aria-pressed={filters.isFavorite}
            onClick={() => onFilterChange('isFavorite', !filters.isFavorite)}
            className={cn(
              filters.isFavorite && 'bg-primary hover:bg-primary/90 border-primary text-primary-foreground'
            )}
          >
            <Heart className={cn('h-5 w-5', filters.isFavorite && 'fill-current')} />
          </Button>

          {/* View toggle */}
          <div className="flex items-center gap-2">
            <Button
              variant={sort.isGridView ? 'default' : 'outline'}
              size="icon"
              aria-label={t('filters.gridView')}
              onClick={() => onSortChange('isGridView', true)}
            >
              <Grid3x3 className="h-5 w-5" />
            </Button>
            <Button
              variant={!sort.isGridView ? 'default' : 'outline'}
              size="icon"
              aria-label={t('filters.listView')}
              onClick={() => onSortChange('isGridView', false)}
            >
              <List className="h-5 w-5" />
            </Button>
          </div>
        </div>
      </div>

      <div className="hidden md:block mt-3 pt-3 border-t border-border">
        <span id="filter-usecase-label-desktop" className="text-sm font-medium text-foreground">{t('filters.useCase')}</span>
        <div role="group" aria-labelledby="filter-usecase-label-desktop" className="mt-2 flex flex-wrap items-center gap-2">
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
              {describeUseCase(t, useCase, formattingLocale)}
            </Button>
          ))}
          <div className="flex items-center gap-2">
            <label htmlFor="wardrobe-custom-use-case-mobile" className="sr-only">{t('filters.customUseCase')}</label>
            <Input
              id="wardrobe-custom-use-case-mobile"
              name="custom_use_case"
              autoComplete="off"
              className="h-9 w-[180px]"
              placeholder={t('filters.customUseCasePlaceholder')}
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
          <span className="text-sm text-muted-foreground shrink-0">{t('filters.active')}</span>
          <div className="flex items-center gap-2 overflow-x-auto scrollbar-hide">
            {filters.category !== 'all' && (
              <Badge variant="secondary" className="gap-1 shrink-0">
                {t(CATEGORIES.find((c) => c.value === filters.category)?.labelKey ?? 'filters.category')}
                <button
                  type="button"
                  onClick={() => onFilterChange('category', 'all')}
                  aria-label={t('filters.removeCategory')}
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
                  type="button"
                  onClick={() => onFilterChange('color', '')}
                  aria-label={t('filters.removeColor')}
                  className="hover:text-foreground touch-target flex items-center justify-center"
                >
                  <X className="h-3 w-3" />
                </button>
              </Badge>
            )}
            {filters.occasion && (
              <Badge variant="secondary" className="gap-1 shrink-0">
                {describeUseCase(t, filters.occasion, formattingLocale)}
                <button
                  type="button"
                  onClick={() => onFilterChange('occasion', '')}
                  aria-label={t('filters.removeUseCase')}
                  className="hover:text-foreground touch-target flex items-center justify-center"
                >
                  <X className="h-3 w-3" />
                </button>
              </Badge>
            )}
            {filters.condition !== 'all' && (
              <Badge variant="secondary" className="gap-1 shrink-0">
                {t(CONDITIONS.find((c) => c.value === filters.condition)?.labelKey ?? 'filters.condition')}
                <button
                  type="button"
                  onClick={() => onFilterChange('condition', 'all')}
                  aria-label={t('filters.removeCondition')}
                  className="hover:text-foreground touch-target flex items-center justify-center"
                >
                  <X className="h-3 w-3" />
                </button>
              </Badge>
            )}
            {filters.isFavorite && (
              <Badge variant="secondary" className="gap-1 shrink-0 text-primary">
                <Heart className="h-3 w-3 fill-current" />
                {t('common.favorites')}
                <button
                  type="button"
                  onClick={() => onFilterChange('isFavorite', false)}
                  aria-label={t('filters.removeFavorites')}
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
            className="ms-auto shrink-0"
          >
            {t('filters.clearAll')}
          </Button>
        </div>
      )}
    </div>
  )
}

export default FilterPanel
