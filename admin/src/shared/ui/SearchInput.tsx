import { Search, X } from 'lucide-react'
import { useEffect, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'

import { cn } from '@/shared/lib/cn'
import { SEARCH_DEBOUNCE_MS } from '@/shared/lib/constants'
import { Input } from '@/shared/ui/input'

/**
 * Search input with debounced onChange — the TableToolbar / table search
 * primitive. Rounded-full per DESIGN.md §03 (search bar).
 */
export interface SearchInputProps {
  value: string
  onValueChange: (value: string) => void
  placeholder?: string
  /** Override the default 300ms debounce */
  debounceMs?: number
  className?: string
  'aria-label'?: string
}

export function SearchInput({
  value,
  onValueChange,
  placeholder,
  debounceMs = SEARCH_DEBOUNCE_MS,
  className,
  'aria-label': ariaLabel,
}: SearchInputProps) {
  const { t } = useTranslation('components')
  const [localValue, setLocalValue] = useState(value)
  const firstRender = useRef(true)

  // Keep the local copy in sync when the URL (source of truth) changes
  // externally (back button, reset, …).
  useEffect(() => {
    if (firstRender.current) {
      firstRender.current = false
      return
    }
    setLocalValue(value)
  }, [value])

  useEffect(() => {
    if (localValue === value) return
    const timer = setTimeout(() => onValueChange(localValue), debounceMs)
    return () => clearTimeout(timer)
    // eslint-disable-next-line react-hooks/exhaustive-deps -- only re-arm on input change
  }, [localValue, debounceMs])

  return (
    <div className={cn('relative', className)}>
      <Search
        className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground"
        aria-hidden="true"
      />
      <Input
        type="search"
        role="searchbox"
        value={localValue}
        onChange={(event) => setLocalValue(event.target.value)}
        placeholder={placeholder ?? t('search.placeholder')}
        aria-label={ariaLabel ?? t('search.ariaLabel')}
        className="h-12 rounded-full pl-9 pr-9"
      />
      {localValue ? (
        <button
          type="button"
          onClick={() => {
            setLocalValue('')
            onValueChange('')
          }}
          aria-label={t('search.clear')}
          className="absolute right-3 top-1/2 -translate-y-1/2 rounded-full p-1 text-muted-foreground transition-colors hover:bg-surface-card hover:text-foreground focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
        >
          <X className="size-4" aria-hidden="true" />
        </button>
      ) : null}
    </div>
  )
}
