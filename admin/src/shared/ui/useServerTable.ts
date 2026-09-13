import { keepPreviousData, useQuery } from '@tanstack/react-query'

import type { Paginated } from '@/shared/api/types'
import { useTableState, type TableStateParams } from '@/shared/hooks/useTableState'
import { DEFAULT_PAGE_SIZE, QUERY_STALE_TIMES } from '@/shared/lib/constants'
import type { SortState } from '@/shared/ui/DataTable'

/**
 * Wires the three pieces of server-driven table state together (spec §3):
 * URL-synced table state (useTableState) + a TanStack Query for the page of
 * data + the props DataTable expects.
 *
 * Features call it from their query hooks, e.g.:
 *
 *   const table = useServerTable({
 *     queryKey: ['users'],
 *     queryFn: listUsers,          // (params: TableStateParams) => Promise<Paginated<T>>
 *     filterKeys: ['status', 'plan'],
 *   })
 *   return { ...table, props: { ...table.props, columns, bulkActions } }
 */

export interface UseServerTableOptions<TData> {
  /** Base query key — params are appended, so invalidation by key prefix works */
  queryKey: readonly unknown[]
  queryFn: (params: TableStateParams) => Promise<Paginated<TData>>
  /** Default page size when the URL has none */
  pageSize?: number
  pageSizeOptions?: readonly number[]
  /** Extra filter keys synced to/from the URL */
  filterKeys?: readonly string[]
  /**
   * Search stays client-side: `q` stays in the URL/table state so the
   * toolbar keeps working, but it is stripped from the server query key
   * and fetch — typing then never refetches an identical server page.
   */
  localSearch?: boolean
}

export interface ServerTableResult<TData> {
  tableState: ReturnType<typeof useTableState>
  query: ReturnType<typeof useQuery<Paginated<TData>>>
  data: TData[]
  total: number
  props: {
    data: TData[]
    total: number
    page: number
    pageSize: number
    pageSizeOptions?: readonly number[]
    sortBy?: string
    sortDir?: 'asc' | 'desc'
    isLoading: boolean
    isFetching: boolean
    onSortChange: (sort: SortState | null) => void
    onPageChange: (page: number) => void
    onPageSizeChange: (size: number) => void
  }
}

export function useServerTable<TData>({
  queryKey,
  queryFn,
  pageSize = DEFAULT_PAGE_SIZE,
  pageSizeOptions,
  filterKeys = [],
  localSearch = false,
}: UseServerTableOptions<TData>): ServerTableResult<TData> {
  const tableState = useTableState({ pageSize, filterKeys })

  // Client-only search: drop `q` from the SERVER params (the type allows
  // undefined; TanStack's hashKey omits it, so the query key stays stable).
  const serverParams: TableStateParams = localSearch
    ? { ...tableState.params, q: undefined }
    : tableState.params

  const query = useQuery({
    queryKey: [...queryKey, serverParams],
    queryFn: () => queryFn(serverParams),
    placeholderData: keepPreviousData,
    staleTime: QUERY_STALE_TIMES.lists,
  })

  const data = query.data?.items ?? []
  const total = query.data?.total ?? 0

  return {
    tableState,
    query,
    data,
    total,
    props: {
      data,
      total,
      page: tableState.page,
      pageSize: tableState.pageSize,
      // exactOptionalPropertyTypes: never pass explicit `undefined` to
      // optional DataTable props — spread conditionally instead.
      ...(pageSizeOptions !== undefined ? { pageSizeOptions } : {}),
      ...(tableState.sortBy !== undefined ? { sortBy: tableState.sortBy } : {}),
      ...(tableState.sortDir !== undefined ? { sortDir: tableState.sortDir } : {}),
      isLoading: query.isPending,
      isFetching: query.isFetching,
      onSortChange: tableState.setSort,
      onPageChange: tableState.setPage,
      onPageSizeChange: tableState.setPageSize,
    },
  }
}

export type { TableStateParams }
