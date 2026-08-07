import {
  flexRender,
  getCoreRowModel,
  useReactTable,
  type ColumnDef,
  type Row,
  type SortingState,
  type VisibilityState,
} from '@tanstack/react-table'
import { useVirtualizer } from '@tanstack/react-virtual'
import {
  ArrowDown,
  ArrowUp,
  ArrowUpDown,
  ChevronLeft,
  ChevronRight,
  Columns3,
  Inbox,
  Rows3,
  SlidersHorizontal,
  X,
} from 'lucide-react'
import { useEffect, useMemo, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'

import { cn } from '@/shared/lib/cn'
import { PAGE_SIZES } from '@/shared/lib/constants'
import { useUiStore } from '@/shared/stores/uiStore'
import { Button } from '@/shared/ui/button'
import { Checkbox } from '@/shared/ui/checkbox'
import {
  DropdownMenu,
  DropdownMenuCheckboxItem,
  DropdownMenuContent,
  DropdownMenuLabel,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/shared/ui/dropdown-menu'
import { EmptyState } from '@/shared/ui/EmptyState'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/shared/ui/select'
import { Skeleton } from '@/shared/ui/skeleton'

/**
 * The admin workhorse (spec §3): a server-driven TanStack Table with
 * pagination, single-column sorting, column visibility, density, row
 * selection + bulk actions, sticky header, frozen first column, skeleton
 * rows, live-region announcements, and windowed virtualization past a
 * threshold.
 *
 * Everything is controlled from props — pages wire it to `useServerTable`
 * (URL-synced table state + TanStack Query) or drive it manually.
 */

export interface SortState {
  id: string
  desc: boolean
}

export interface DataTableProps<TData, TValue = unknown> {
  columns: ColumnDef<TData, TValue>[]
  data: TData[]
  total: number
  page: number
  pageSize: number
  pageSizeOptions?: readonly number[]
  isLoading?: boolean
  /** True while a background refetch is in flight */
  isFetching?: boolean
  sortBy?: string | null
  sortDir?: 'asc' | 'desc' | null
  onSortChange?: (sort: SortState | null) => void
  onPageChange?: (page: number) => void
  onPageSizeChange?: (size: number) => void
  onRowClick?: (row: TData) => void
  /** Row identity for selection; defaults to row index */
  getRowId?: (row: TData, index: number) => string
  /** Renders the bulk-action toolbar when rows are selected */
  bulkActions?: (selectedRows: TData[]) => React.ReactNode
  /** Custom empty state (default: themed EmptyState) */
  emptyState?: React.ReactNode
  /** Called by the default empty state's "clear filters" action */
  onResetFilters?: () => void
  /** Windowed virtualization once rows exceed this count */
  virtualizeThreshold?: number
  ariaLabel?: string
  skeletonRows?: number
  className?: string
}

/** Page-number windowing for the pagination controls. */
export function getPageNumbers(current: number, total: number): (number | 'ellipsis')[] {
  if (total <= 7) {
    return Array.from({ length: total }, (_, index) => index + 1)
  }
  const candidates = [1, total, current - 1, current, current + 1]
  const sorted = [...new Set(candidates)]
    .filter((p) => p >= 1 && p <= total)
    .sort((a, b) => a - b)
  const out: (number | 'ellipsis')[] = []
  let previous = 0
  for (const page of sorted) {
    if (previous !== 0 && page - previous > 1) out.push('ellipsis')
    out.push(page)
    previous = page
  }
  return out
}

export function DataTable<TData, TValue = unknown>({
  columns,
  data,
  total,
  page,
  pageSize,
  pageSizeOptions = PAGE_SIZES,
  isLoading = false,
  isFetching = false,
  sortBy = null,
  sortDir = null,
  onSortChange,
  onPageChange,
  onPageSizeChange,
  onRowClick,
  getRowId,
  bulkActions,
  emptyState,
  onResetFilters,
  virtualizeThreshold = 200,
  ariaLabel,
  skeletonRows = 5,
  className,
}: DataTableProps<TData, TValue>) {
  const { t } = useTranslation('dataTable')
  const density = useUiStore((state) => state.density)
  const [columnVisibility, setColumnVisibility] = useState<VisibilityState>({})
  const [rowSelection, setRowSelection] = useState<Record<string, boolean>>({})
  const scrollRef = useRef<HTMLDivElement>(null)

  const sorting = useMemo<SortingState>(
    () => (sortBy ? [{ id: sortBy, desc: sortDir === 'desc' }] : []),
    [sortBy, sortDir],
  )

  const selectionColumn = useMemo<ColumnDef<TData, unknown> | null>(() => {
    if (!bulkActions) return null
    return {
      id: '__select__',
      header: ({ table }) => (
        <Checkbox
          checked={table.getIsAllPageRowsSelected()}
          onCheckedChange={(value) => table.toggleAllPageRowsSelected(Boolean(value))}
          aria-label={t('selectAll')}
        />
      ),
      cell: ({ row }) => (
        <Checkbox
          checked={row.getIsSelected()}
          onCheckedChange={(value) => row.toggleSelected(Boolean(value))}
          aria-label={t('selectRow')}
          // Selection clicks must not bubble into the row action (onRowClick)
          onClick={(event) => event.stopPropagation()}
        />
      ),
      enableSorting: false,
      enableHiding: false,
      size: 44,
    }
  }, [bulkActions, t])

  const allColumns = useMemo<ColumnDef<TData, TValue>[]>(() => {
    if (!selectionColumn) return columns
    return [selectionColumn, ...columns]
  }, [columns, selectionColumn])

  const table = useReactTable({
    data,
    columns: allColumns,
    state: {
      sorting,
      columnVisibility,
      pagination: { pageIndex: Math.max(0, page - 1), pageSize },
      ...(bulkActions ? { rowSelection } : {}),
    },
    onSortingChange: (updater) => {
      const next = typeof updater === 'function' ? updater(sorting) : updater
      onSortChange?.(next[0] ? { id: next[0].id, desc: next[0].desc } : null)
    },
    onColumnVisibilityChange: setColumnVisibility,
    onRowSelectionChange: setRowSelection,
    manualPagination: true,
    manualSorting: true,
    pageCount: Math.max(1, Math.ceil(total / pageSize)),
    enableRowSelection: Boolean(bulkActions),
    getRowId: getRowId ?? ((_row, index) => String(index)),
    getCoreRowModel: getCoreRowModel(),
  })

  // Selection is page-scoped: reset when the page/page-size changes.
  useEffect(() => {
    setRowSelection({})
  }, [page, pageSize])

  const rows = table.getRowModel().rows
  const visibleColumns = table.getVisibleLeafColumns()
  const selectedRows = bulkActions
    ? table.getSelectedRowModel().rows.map((row) => row.original)
    : []

  // Live-region announcement for sort/pagination changes (spec §3).
  const [announcement, setAnnouncement] = useState('')
  useEffect(() => {
    const from = total === 0 ? 0 : (page - 1) * pageSize + 1
    const to = Math.min(page * pageSize, total)
    const parts = [t('announce.showing', { from, to, total })]
    if (sortBy) {
      const column = visibleColumns.find((c) => c.id === sortBy)
      const headerLabel =
        column && typeof column.columnDef.header === 'string' ? column.columnDef.header : sortBy
      parts.push(
        t('announce.sortedBy', {
          column: headerLabel,
          dir: t(sortDir === 'desc' ? 'sortDir.descending' : 'sortDir.ascending'),
        }),
      )
    }
    setAnnouncement(parts.join(' '))
    // eslint-disable-next-line react-hooks/exhaustive-deps -- visibleColumns identity is unstable; data is stable
  }, [page, pageSize, total, sortBy, sortDir, t])

  const handleSortClick = (columnId: string): void => {
    const current = sorting.find((s) => s.id === columnId)
    if (!current) onSortChange?.({ id: columnId, desc: false })
    else if (!current.desc) onSortChange?.({ id: columnId, desc: true })
    else onSortChange?.(null)
  }

  // Windowed virtualization (optional, default past 200 rows).
  const virtualize = rows.length > virtualizeThreshold
  const rowVirtualizer = useVirtualizer({
    count: virtualize ? rows.length : 0,
    getScrollElement: () => scrollRef.current,
    estimateSize: () => (density === 'compact' ? 36 : 48),
    overscan: 12,
  })
  const virtualRows = virtualize ? rowVirtualizer.getVirtualItems() : null
  const rowHeightClass = density === 'compact' ? 'h-9' : 'h-12'

  const showSkeleton = isLoading && data.length === 0
  const skeletonRowCount = Math.min(skeletonRows, pageSize)
  const frozenCellClass =
    'sticky left-0 z-10 bg-background data-[state=selected]:bg-surface-card'

  return (
    <div
      role="region"
      aria-label={ariaLabel ?? t('aria.label')}
      aria-busy={isLoading || undefined}
      className={cn('w-full', className)}
    >
      {/* Toolbar */}
      <div className="flex flex-wrap items-center gap-2 py-2">
        {bulkActions && selectedRows.length > 0 ? (
          <div className="flex min-w-0 flex-1 items-center gap-3 rounded-md border border-border bg-surface-card px-3 py-2">
            <span className="text-sm font-medium text-muted-foreground">
              {t('selected', { count: selectedRows.length })}
            </span>
            <div className="flex items-center gap-2">{bulkActions(selectedRows)}</div>
            <Button
              variant="ghost"
              size="icon"
              className="ml-auto size-7 text-muted-foreground hover:text-foreground"
              aria-label={t('clearSelection')}
              onClick={() => table.resetRowSelection()}
            >
              <X aria-hidden="true" />
            </Button>
          </div>
        ) : null}
        <div className="ml-auto flex items-center gap-1.5">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="sm" aria-label={t('columns.label')}>
                <Columns3 aria-hidden="true" />
                <span className="hidden sm:inline">{t('columns.label')}</span>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-52">
              <DropdownMenuLabel>{t('columns.label')}</DropdownMenuLabel>
              <DropdownMenuSeparator />
              {table
                .getAllLeafColumns()
                .filter((column) => column.getCanHide())
                .map((column) => {
                  const header = column.columnDef.header
                  const label =
                    typeof header === 'string' ? header : String(column.id)
                  return (
                    <DropdownMenuCheckboxItem
                      key={column.id}
                      className="capitalize"
                      checked={column.getIsVisible()}
                      onCheckedChange={(value) => column.toggleVisibility(Boolean(value))}
                    >
                      {label}
                    </DropdownMenuCheckboxItem>
                  )
                })}
            </DropdownMenuContent>
          </DropdownMenu>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="sm" aria-label={t('density.label')}>
                <SlidersHorizontal aria-hidden="true" />
                <span className="hidden sm:inline">{t('density.label')}</span>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuRadioGroup
                value={density}
                onValueChange={(value) => {
                  useUiStore.getState().setDensity(value === 'compact' ? 'compact' : 'comfortable')
                }}
              >
                <DropdownMenuRadioItem value="comfortable">
                  <Rows3 aria-hidden="true" />
                  {t('density.comfortable')}
                </DropdownMenuRadioItem>
                <DropdownMenuRadioItem value="compact">
                  {t('density.compact')}
                </DropdownMenuRadioItem>
              </DropdownMenuRadioGroup>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>

      {/* Table */}
      <div
        ref={scrollRef}
        className="relative max-h-[65dvh] overflow-auto rounded-md border border-border"
      >
        {/* Indeterminate fetch progress while a background refetch runs */}
        {isFetching && !isLoading ? (
          <div
            className="pointer-events-none absolute inset-x-0 top-0 z-30 h-0.5 overflow-hidden"
            aria-hidden="true"
            data-testid="data-table-fetch-progress"
          >
            <div className="h-full w-1/3 animate-fc-progress bg-primary" />
          </div>
        ) : null}
        <table className="w-full caption-bottom text-sm">
          <thead className="sticky top-0 z-20 bg-background">
            {table.getHeaderGroups().map((headerGroup) => (
              <tr key={headerGroup.id} className="border-b border-border">
                {headerGroup.headers.map((header, index) => {
                  const isFirst = index === 0
                  const sorted = header.column.getIsSorted()
                  const sortable = header.column.getCanSort()
                  return (
                    <th
                      key={header.id}
                      aria-sort={
                        sorted === 'asc'
                          ? 'ascending'
                          : sorted === 'desc'
                            ? 'descending'
                            : 'none'
                      }
                      className={cn(
                        'h-11 whitespace-nowrap px-3 text-left align-middle text-xs font-semibold uppercase tracking-wide text-muted-foreground',
                        isFirst && frozenCellClass,
                      )}
                      style={{ width: header.getSize() }}
                    >
                      {sortable ? (
                        <button
                          type="button"
                          onClick={() => handleSortClick(header.column.id)}
                          className="inline-flex items-center gap-1 rounded-md px-1 py-1 font-semibold uppercase tracking-wide text-muted-foreground transition-colors hover:text-foreground focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
                        >
                          {flexRender(header.column.columnDef.header, header.getContext())}
                          {sorted === 'asc' ? (
                            <ArrowUp className="size-3.5 text-primary" aria-hidden="true" />
                          ) : sorted === 'desc' ? (
                            <ArrowDown className="size-3.5 text-primary" aria-hidden="true" />
                          ) : (
                            <ArrowUpDown className="size-3.5 opacity-40" aria-hidden="true" />
                          )}
                        </button>
                      ) : (
                        flexRender(header.column.columnDef.header, header.getContext())
                      )}
                    </th>
                  )
                })}
              </tr>
            ))}
          </thead>
          <tbody
            className="relative"
            style={
              virtualRows
                ? { height: rowVirtualizer.getTotalSize(), position: 'relative' }
                : undefined
            }
          >
            {showSkeleton
              ? Array.from({ length: skeletonRowCount }, (_, rowIndex) => (
                  <tr key={`skeleton-${rowIndex}`} className="border-b border-border" data-testid="data-table-skeleton-row">
                    {visibleColumns.map((column) => (
                      <td key={column.id} className="px-3 py-2">
                        <Skeleton className="h-4 w-full max-w-40" />
                      </td>
                    ))}
                  </tr>
                ))
              : virtualRows
                ? virtualRows.map((virtualRow) => {
                    const row = rows[virtualRow.index]
                    if (!row) return null
                    return (
                      <TableRowContent
                        key={row.id}
                        row={row}
                        rowHeightClass={rowHeightClass}
                        onRowClick={onRowClick}
                        frozenCellClass={frozenCellClass}
                        style={{
                          position: 'absolute',
                          top: 0,
                          left: 0,
                          width: '100%',
                          transform: `translateY(${virtualRow.start}px)`,
                        }}
                      />
                    )
                  })
                : rows.map((row) => (
                    <TableRowContent
                      key={row.id}
                      row={row}
                      rowHeightClass={rowHeightClass}
                      onRowClick={onRowClick}
                      frozenCellClass={frozenCellClass}
                    />
                  ))}
            {!showSkeleton && rows.length === 0 ? (
              <tr className="border-b border-border">
                <td colSpan={visibleColumns.length} className="px-3 py-2">
                  {emptyState ?? (
                    <EmptyState
                      icon={Inbox}
                      title={t('empty.title')}
                      message={t('empty.message')}
                      action={
                        onResetFilters ? (
                          <Button variant="secondary" size="sm" onClick={onResetFilters}>
                            {t('empty.clearFilters')}
                          </Button>
                        ) : undefined
                      }
                    />
                  )}
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      </div>

      {/* Footer */}
      <div className="flex flex-wrap items-center justify-between gap-3 py-3">
        <p className="text-sm text-muted-foreground">
          {t('showing', {
            from: total === 0 ? 0 : (page - 1) * pageSize + 1,
            to: Math.min(page * pageSize, total),
            total,
          })}
        </p>
        <div className="flex flex-wrap items-center gap-4">
          <div className="flex items-center gap-2">
            <label htmlFor="data-table-page-size" className="text-sm text-muted-foreground">
              {t('pageSize')}
            </label>
            <Select
              value={String(pageSize)}
              onValueChange={(value) => onPageSizeChange?.(Number(value))}
            >
              <SelectTrigger id="data-table-page-size" className="h-9 w-20" aria-label={t('pageSize')}>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {pageSizeOptions.map((size) => (
                  <SelectItem key={size} value={String(size)}>
                    {String(size)}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <PaginationControls page={page} pageCount={Math.max(1, Math.ceil(total / pageSize))} onPageChange={onPageChange} />
        </div>
      </div>

      <div className="sr-only" aria-live="polite">
        {announcement}
      </div>
    </div>
  )
}

interface TableRowContentProps<TData> {
  row: Row<TData>
  rowHeightClass: string
  onRowClick: ((row: TData) => void) | undefined
  frozenCellClass: string
  style?: React.CSSProperties
}

function TableRowContent<TData>({
  row,
  rowHeightClass,
  onRowClick,
  frozenCellClass,
  style,
}: TableRowContentProps<TData>) {
  const clickable = Boolean(onRowClick)
  return (
    <tr
      data-state={row.getIsSelected() ? 'selected' : undefined}
      className={cn(
        'border-b border-border transition-colors data-[state=selected]:bg-surface-card',
        clickable && 'cursor-pointer hover:bg-surface-card/60',
      )}
      onClick={clickable ? () => onRowClick?.(row.original) : undefined}
      onKeyDown={
        clickable
          ? (event) => {
              if (event.key === 'Enter' || event.key === ' ') {
                event.preventDefault()
                onRowClick?.(row.original)
              }
            }
          : undefined
      }
      tabIndex={clickable ? 0 : undefined}
      style={style}
    >
      {row.getVisibleCells().map((cell, index) => (
        <td
          key={cell.id}
          className={cn(rowHeightClass, 'px-3 align-middle', index === 0 && frozenCellClass)}
        >
          {flexRender(cell.column.columnDef.cell, cell.getContext())}
        </td>
      ))}
    </tr>
  )
}

interface PaginationControlsProps {
  page: number
  pageCount: number
  onPageChange: ((page: number) => void) | undefined
}

function PaginationControls({ page, pageCount, onPageChange }: PaginationControlsProps) {
  const { t } = useTranslation('dataTable')
  const pages = getPageNumbers(page, pageCount)
  return (
    <nav aria-label={t('pagination.label')} className="flex items-center gap-1">
      <Button
        variant="outline"
        size="icon"
        className="size-9"
        disabled={page <= 1}
        onClick={() => onPageChange?.(page - 1)}
        aria-label={t('pagination.previous')}
      >
        <ChevronLeft aria-hidden="true" />
      </Button>
      {pages.map((item, index) =>
        item === 'ellipsis' ? (
          <span key={`ellipsis-${index}`} className="px-1 text-sm text-muted-foreground" aria-hidden="true">
            …
          </span>
        ) : (
          <Button
            key={item}
            variant={item === page ? 'primary' : 'outline'}
            size="icon"
            className="size-9"
            onClick={() => onPageChange?.(item)}
            aria-current={item === page ? 'page' : undefined}
            aria-label={t('pagination.page', { page: item })}
          >
            {item}
          </Button>
        ),
      )}
      <Button
        variant="outline"
        size="icon"
        className="size-9"
        disabled={page >= pageCount}
        onClick={() => onPageChange?.(page + 1)}
        aria-label={t('pagination.next')}
      >
        <ChevronRight aria-hidden="true" />
      </Button>
    </nav>
  )
}
