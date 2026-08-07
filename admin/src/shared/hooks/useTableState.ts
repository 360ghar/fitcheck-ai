import { useCallback, useMemo } from 'react'
import { useSearchParams } from 'react-router-dom'

import { DEFAULT_PAGE_SIZE } from '@/shared/lib/constants'

/**
 * URL-as-table-state (spec §2). Sorting, pagination, search, and extra
 * filters live in searchParams: deep-linkable, shareable, back-button-safe.
 *
 * - `params` is memoized (stable identity while the URL is unchanged) so it
 *   can be used directly in a TanStack Query key.
 * - Setters update the URL without clobbering unrelated params and reset
 *   `page` when the result set is likely to change (filters, search).
 */

export interface SortState {
  id: string
  desc: boolean
}

export type SortDirection = 'asc' | 'desc'

export interface TableStateParams {
  page: number
  page_size: number
  q: string | undefined
  sort_by: string | undefined
  sort_dir: SortDirection | undefined
  filters: Record<string, string | undefined>
}

export interface UseTableStateOptions {
  /** Default page size when ?pageSize is absent (default 20) */
  pageSize?: number
  /** Extra filter keys to sync to/from the URL (e.g. ['status', 'plan']) */
  filterKeys?: readonly string[]
}

/** Stable empty array so `filterKeys ?? EMPTY` keeps a constant identity. */
const EMPTY_FILTER_KEYS: readonly string[] = []

function parsePositiveInt(raw: string | null, fallback: number): number {
  if (!raw) return fallback
  const parsed = Number.parseInt(raw, 10)
  if (Number.isNaN(parsed) || parsed < 1) return fallback
  return parsed
}

function parseSortDir(raw: string | null): SortDirection | undefined {
  if (raw === 'asc' || raw === 'desc') return raw
  return undefined
}

export function useTableState(options: UseTableStateOptions = {}) {
  const defaultPageSize = options.pageSize ?? DEFAULT_PAGE_SIZE
  const filterKeys = options.filterKeys ?? EMPTY_FILTER_KEYS
  const [searchParams, setSearchParams] = useSearchParams()

  const page = parsePositiveInt(searchParams.get('page'), 1)
  const pageSize = parsePositiveInt(searchParams.get('pageSize'), defaultPageSize)
  const sortBy = searchParams.get('sortBy') ?? undefined
  const sortDir = parseSortDir(searchParams.get('sortDir'))
  const q = searchParams.get('q') ?? ''

  const filters = useMemo(() => {
    const out: Record<string, string | undefined> = {}
    for (const key of filterKeys) {
      out[key] = searchParams.get(key) ?? undefined
    }
    return out
  }, [filterKeys, searchParams])

  const params = useMemo<TableStateParams>(
    () => ({
      page,
      page_size: pageSize,
      q: q || undefined,
      sort_by: sortBy,
      sort_dir: sortDir,
      filters,
    }),
    [page, pageSize, q, sortBy, sortDir, filters],
  )

  const update = useCallback(
    (mutate: (next: URLSearchParams) => void) => {
      setSearchParams((prev) => {
        const next = new URLSearchParams(prev)
        mutate(next)
        return next
      })
    },
    [setSearchParams],
  )

  const setPage = useCallback(
    (nextPage: number) => {
      const clamped = Math.max(1, nextPage)
      update((next) => {
        if (clamped === 1) next.delete('page')
        else next.set('page', String(clamped))
      })
    },
    [update],
  )

  const setPageSize = useCallback(
    (size: number) => {
      update((next) => {
        if (size === defaultPageSize) next.delete('pageSize')
        else next.set('pageSize', String(size))
        next.delete('page')
      })
    },
    [update, defaultPageSize],
  )

  const setSort = useCallback(
    (sort: SortState | null) => {
      update((next) => {
        if (!sort) {
          next.delete('sortBy')
          next.delete('sortDir')
        } else {
          next.set('sortBy', sort.id)
          next.set('sortDir', sort.desc ? 'desc' : 'asc')
        }
        next.delete('page')
      })
    },
    [update],
  )

  const setQ = useCallback(
    (value: string) => {
      update((next) => {
        if (value) next.set('q', value)
        else next.delete('q')
        next.delete('page')
      })
    },
    [update],
  )

  const setFilter = useCallback(
    (key: string, value: string | undefined) => {
      update((next) => {
        if (value) next.set(key, value)
        else next.delete(key)
        next.delete('page')
      })
    },
    [update],
  )

  const reset = useCallback(() => {
    const managed = new Set<string>(['page', 'pageSize', 'q', 'sortBy', 'sortDir', ...filterKeys])
    update((next) => {
      for (const key of [...next.keys()]) {
        if (managed.has(key)) next.delete(key)
      }
    })
  }, [update, filterKeys])

  return {
    page,
    pageSize,
    sortBy,
    sortDir,
    q,
    filters,
    params,
    searchParams,
    setPage,
    setPageSize,
    setSort,
    setQ,
    setFilter,
    reset,
  }
}

export type TableState = ReturnType<typeof useTableState>
