import { ListFilter, Loader2, X } from 'lucide-react'
import { useTranslation } from 'react-i18next'

import { cn } from '@/shared/lib/cn'
import { Button } from '@/shared/ui/button'
import { Input } from '@/shared/ui/input'
import { Popover, PopoverContent, PopoverTrigger } from '@/shared/ui/popover'
import { SearchInput } from '@/shared/ui/SearchInput'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/shared/ui/select'

/**
 * Hybrid table toolbar (UX v2): debounced search + one high-frequency
 * filter kept inline ("primary") + every other filter behind a Filters
 * popover. Applied filters surface as removable chips next to the toolbar;
 * the popover button carries an active-count badge.
 *
 * Values are controlled from the outside — pages wire them to useTableState
 * so every filter stays in the URL (deep-linkable, back-button-safe). The
 * "no filter" option is the page's own ALL entry (first option in each
 * list), exactly as the legacy FilterBar behaved, so `onValueChange` never
 * receives it.
 */
export interface TableToolbarFilter {
  key: string
  label: string
  placeholder: string
  options: readonly { value: string; label: string }[]
  value: string | undefined
  onValueChange: (value: string | undefined) => void
}

export interface TableToolbarDateFilter {
  key: string
  label: string
  value: string | undefined
  onValueChange: (value: string | undefined) => void
}

export interface TableToolbarProps {
  searchValue: string
  onSearchChange: (value: string) => void
  searchPlaceholder?: string
  /** Hide the search input when the backend endpoint has no search param */
  hideSearch?: boolean
  /** Single high-frequency filter kept visible inline (e.g. status) */
  primaryFilter?: TableToolbarFilter
  /** Secondary filters inside the Filters popover */
  filters?: readonly TableToolbarFilter[]
  /** Date-range inputs inside the Filters popover */
  dateFilters?: readonly TableToolbarDateFilter[]
  /** Clears search + all filters (useTableState.reset) */
  onReset?: () => void
  /** True while a background refetch is in flight — shows a spinner */
  isFetching?: boolean
  /** Right-aligned actions (e.g. export buttons) */
  actions?: React.ReactNode
  className?: string
}

function selectedLabel(filter: TableToolbarFilter): string {
  return filter.options.find((option) => option.value === filter.value)?.label ?? filter.value ?? ''
}

export function TableToolbar({
  searchValue,
  onSearchChange,
  searchPlaceholder,
  hideSearch = false,
  primaryFilter,
  filters = [],
  dateFilters = [],
  onReset,
  isFetching = false,
  actions,
  className,
}: TableToolbarProps) {
  const { t } = useTranslation('components')

  const activePopoverFilters =
    filters.filter((filter) => filter.value !== undefined).length +
    dateFilters.filter((filter) => filter.value).length

  // Chips = every applied filter (primary + popover + dates), removable.
  const chips: { key: string; label: string; onClear: () => void }[] = []
  if (primaryFilter && primaryFilter.value !== undefined) {
    chips.push({
      key: `filter-${primaryFilter.key}`,
      label: `${primaryFilter.label}: ${selectedLabel(primaryFilter)}`,
      onClear: () => primaryFilter.onValueChange(undefined),
    })
  }
  for (const filter of filters) {
    if (filter.value === undefined) continue
    chips.push({
      key: `filter-${filter.key}`,
      label: `${filter.label}: ${selectedLabel(filter)}`,
      onClear: () => filter.onValueChange(undefined),
    })
  }
  for (const filter of dateFilters) {
    if (!filter.value) continue
    chips.push({
      key: `date-${filter.key}`,
      label: `${filter.label}: ${filter.value}`,
      onClear: () => filter.onValueChange(undefined),
    })
  }

  const hasPopoverFilters = filters.length > 0 || dateFilters.length > 0

  return (
    <div className={cn('flex flex-wrap items-center gap-3', className)}>
      {hideSearch ? null : (
        <SearchInput
          value={searchValue}
          onValueChange={onSearchChange}
          {...(searchPlaceholder ? { placeholder: searchPlaceholder } : {})}
          className="w-full sm:max-w-xs"
          aria-label={t('toolbar.searchAriaLabel')}
        />
      )}

      {primaryFilter ? (
        <Select
          {...(primaryFilter.value !== undefined ? { value: primaryFilter.value } : {})}
          onValueChange={(value) => primaryFilter.onValueChange(value)}
        >
          <SelectTrigger className="h-10 w-full sm:w-44" aria-label={primaryFilter.label}>
            <SelectValue placeholder={primaryFilter.placeholder} />
          </SelectTrigger>
          <SelectContent>
            {primaryFilter.options.map((option) => (
              <SelectItem key={option.value} value={option.value}>
                {option.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      ) : null}

      {hasPopoverFilters ? (
        <Popover>
          <PopoverTrigger asChild>
            <Button
              variant="outline"
              size="sm"
              className="h-10"
              aria-label={
                activePopoverFilters > 0
                  ? t('toolbar.filtersWithCount', { count: activePopoverFilters })
                  : t('toolbar.filters')
              }
            >
              <ListFilter aria-hidden="true" />
              {t('toolbar.filters')}
              {activePopoverFilters > 0 ? (
                <span className="ml-0.5 inline-flex size-5 items-center justify-center rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
                  {activePopoverFilters}
                </span>
              ) : null}
            </Button>
          </PopoverTrigger>
          <PopoverContent align="start" className="w-80">
            <div className="space-y-4">
              {filters.map((filter) => (
                <div key={filter.key} className="space-y-1.5">
                  <p className="text-xs font-medium text-muted-foreground">{filter.label}</p>
                  <Select
                    {...(filter.value !== undefined ? { value: filter.value } : {})}
                    onValueChange={(value) => filter.onValueChange(value)}
                  >
                    <SelectTrigger className="h-10 w-full" aria-label={filter.label}>
                      <SelectValue placeholder={filter.placeholder} />
                    </SelectTrigger>
                    <SelectContent>
                      {filter.options.map((option) => (
                        <SelectItem key={option.value} value={option.value}>
                          {option.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              ))}
              {dateFilters.length > 0 ? (
                <div className="space-y-1.5">
                  <div className="grid grid-cols-2 gap-2">
                    {dateFilters.map((filter) => (
                      <div key={filter.key} className="space-y-1.5">
                        <label
                          htmlFor={`table-date-${filter.key}`}
                          className="block text-xs font-medium text-muted-foreground"
                        >
                          {filter.label}
                        </label>
                        <Input
                          id={`table-date-${filter.key}`}
                          type="date"
                          className="h-9"
                          value={filter.value ?? ''}
                          onChange={(event) =>
                            filter.onValueChange(event.target.value || undefined)
                          }
                          aria-label={filter.label}
                        />
                      </div>
                    ))}
                  </div>
                </div>
              ) : null}
            </div>
            <div className="mt-4 border-t border-border pt-3">
              <Button
                variant="ghost"
                size="sm"
                onClick={onReset}
                disabled={activePopoverFilters === 0}
              >
                {t('toolbar.reset')}
              </Button>
            </div>
          </PopoverContent>
        </Popover>
      ) : null}

      {chips.map((chip) => (
        <button
          key={chip.key}
          type="button"
          onClick={chip.onClear}
          aria-label={t('toolbar.clearFilter', { label: chip.label })}
          className="inline-flex items-center gap-1.5 rounded-full border border-border bg-surface-card px-3 py-1.5 text-xs font-medium text-ink transition-colors hover:border-muted-foreground/40 focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
        >
          {chip.label}
          <X className="size-3" aria-hidden="true" />
        </button>
      ))}
      {chips.length > 1 ? (
        <button
          type="button"
          onClick={onReset}
          className="text-xs font-medium text-muted-foreground underline-offset-4 transition-colors hover:text-foreground hover:underline focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
        >
          {t('toolbar.clearAll')}
        </button>
      ) : null}

      {actions || isFetching ? (
        <div className="ml-auto flex items-center gap-2">
          {isFetching ? (
            <span role="status" className="flex items-center">
              <Loader2
                className="size-4 animate-spin text-muted-foreground"
                aria-hidden="true"
              />
              <span className="sr-only">{t('toolbar.refreshing')}</span>
            </span>
          ) : null}
          {actions}
        </div>
      ) : null}
    </div>
  )
}
