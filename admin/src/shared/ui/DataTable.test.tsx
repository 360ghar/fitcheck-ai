import type { ColumnDef } from '@tanstack/react-table'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'
import { axe } from 'vitest-axe'

import { DataTable, getPageNumbers } from './DataTable'

import { renderWithProviders } from '@/test/utils'

interface Row {
  id: string
  name: string
  status: string
}

const columns: ColumnDef<Row, unknown>[] = [
  { id: 'name', accessorKey: 'name', header: 'Name' },
  { id: 'status', accessorKey: 'status', header: 'Status' },
]

const rows: Row[] = [
  { id: '1', name: 'Alice', status: 'active' },
  { id: '2', name: 'Bob', status: 'suspended' },
]

const base = {
  columns,
  page: 1,
  pageSize: 20,
} as const

describe('DataTable', () => {
  it('renders columns, rows, and result count', () => {
    renderWithProviders(
      <DataTable {...base} data={rows} total={45} />,
    )
    expect(screen.getByRole('columnheader', { name: 'Name' })).toBeInTheDocument()
    expect(screen.getByText('Alice')).toBeInTheDocument()
    expect(screen.getByText('Bob')).toBeInTheDocument()
    expect(screen.getByText('1–20 of 45')).toBeInTheDocument()
  })

  it('calls onSortChange with ascending on the first header click', async () => {
    const onSortChange = vi.fn()
    renderWithProviders(
      <DataTable {...base} data={rows} total={45} onSortChange={onSortChange} />,
    )
    await userEvent.click(screen.getByRole('button', { name: 'Name' }))
    expect(onSortChange).toHaveBeenCalledWith({ id: 'name', desc: false })
  })

  it('applies aria-sort from the sort props', () => {
    renderWithProviders(
      <DataTable {...base} data={rows} total={45} sortBy="name" sortDir="desc" />,
    )
    expect(screen.getByRole('columnheader', { name: 'Name' })).toHaveAttribute(
      'aria-sort',
      'descending',
    )
  })

  it('shows skeleton rows and aria-busy while loading', () => {
    const { container } = renderWithProviders(
      <DataTable {...base} data={[]} total={0} isLoading />,
    )
    expect(container.querySelector('[aria-busy="true"]')).not.toBeNull()
    expect(screen.getAllByTestId('data-table-skeleton-row').length).toBeGreaterThan(0)
  })

  it('renders the default empty state', () => {
    renderWithProviders(<DataTable {...base} data={[]} total={0} />)
    expect(screen.getByText('No results')).toBeInTheDocument()
  })

  it('renders a custom empty state when provided', () => {
    renderWithProviders(
      <DataTable {...base} data={[]} total={0} emptyState={<div>custom-empty</div>} />,
    )
    expect(screen.getByText('custom-empty')).toBeInTheDocument()
  })

  it('paginates via previous/next and page-number controls', async () => {
    const onPageChange = vi.fn()
    renderWithProviders(
      <DataTable {...base} data={rows} total={45} onPageChange={onPageChange} />,
    )
    await userEvent.click(screen.getByRole('button', { name: 'Next page' }))
    expect(onPageChange).toHaveBeenCalledWith(2)
    await userEvent.click(screen.getByRole('button', { name: 'Page 3' }))
    expect(onPageChange).toHaveBeenCalledWith(3)
    await userEvent.click(screen.getByRole('button', { name: 'Previous page' }))
    expect(onPageChange).toHaveBeenCalledWith(2)
  })

  it('disables previous on the first page', () => {
    renderWithProviders(<DataTable {...base} data={rows} total={45} page={1} />)
    expect(screen.getByRole('button', { name: 'Previous page' })).toBeDisabled()
    expect(screen.getByRole('button', { name: 'Next page' })).toBeEnabled()
  })

  it('disables next on the last page', () => {
    renderWithProviders(<DataTable {...base} data={rows} total={45} page={3} />)
    expect(screen.getByRole('button', { name: 'Previous page' })).toBeEnabled()
    expect(screen.getByRole('button', { name: 'Next page' })).toBeDisabled()
  })

  it('renders bulk action slot with selected rows', async () => {
    const bulkActions = vi.fn((_selected: Row[]) => <button type="button">Bulk action</button>)
    renderWithProviders(
      <DataTable
        {...base}
        data={rows}
        total={45}
        getRowId={(row) => row.id}
        bulkActions={bulkActions}
      />,
    )
    await userEvent.click(screen.getAllByRole('checkbox')[1] as HTMLElement)
    expect(screen.getByText('1 selected')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Bulk action' })).toBeInTheDocument()
    expect(bulkActions).toHaveBeenCalledWith([rows[0]])
  })

  it('clears the selection via the bulk bar clear button', async () => {
    const bulkActions = vi.fn((_selected: Row[]) => <button type="button">Bulk action</button>)
    renderWithProviders(
      <DataTable
        {...base}
        data={rows}
        total={45}
        getRowId={(row) => row.id}
        bulkActions={bulkActions}
      />,
    )
    await userEvent.click(screen.getAllByRole('checkbox')[1] as HTMLElement)
    expect(screen.getByText('1 selected')).toBeInTheDocument()
    await userEvent.click(screen.getByRole('button', { name: 'Clear selection' }))
    expect(screen.queryByText('1 selected')).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Bulk action' })).not.toBeInTheDocument()
  })

  it('shows the fetch progress bar during background refetches only', () => {
    const { rerender } = renderWithProviders(
      <DataTable {...base} data={rows} total={45} isFetching isLoading />,
    )
    // Initial load (isLoading) → skeleton rows, no progress bar
    expect(screen.queryByTestId('data-table-fetch-progress')).not.toBeInTheDocument()
    rerender(<DataTable {...base} data={rows} total={45} isFetching />)
    expect(screen.getByTestId('data-table-fetch-progress')).toBeInTheDocument()
    rerender(<DataTable {...base} data={rows} total={45} />)
    expect(screen.queryByTestId('data-table-fetch-progress')).not.toBeInTheDocument()
  })

  it('exposes onRowClick via row click', async () => {
    const onRowClick = vi.fn()
    renderWithProviders(<DataTable {...base} data={rows} total={45} onRowClick={onRowClick} />)
    await userEvent.click(screen.getByText('Alice'))
    expect(onRowClick).toHaveBeenCalledWith(rows[0])
  })

  it('has no axe violations (WCAG 2.1 AA)', async () => {
    const { container } = renderWithProviders(
      <DataTable
        {...base}
        data={rows}
        total={45}
        sortBy="name"
        sortDir="asc"
        getRowId={(row) => row.id}
        bulkActions={() => <button type="button">Bulk</button>}
      />,
    )
    expect(await axe(container)).toHaveNoViolations()
  })

  it('keeps the live region polite and announces the current range', () => {
    const { container } = renderWithProviders(
      <DataTable {...base} data={rows} total={45} />,
    )
    // Scope to the table region — sonner's Toaster also uses aria-live.
    const tableRegion = container.querySelector('[role="region"]')
    const liveRegion = tableRegion?.querySelector('[aria-live="polite"]')
    expect(liveRegion).not.toBeNull()
    expect(liveRegion).toHaveClass('sr-only')
    expect(liveRegion).toHaveTextContent('Showing 1 to 20 of 45 rows.')
  })
})

describe('getPageNumbers', () => {
  it('returns sequential pages for short lists', () => {
    expect(getPageNumbers(1, 3)).toEqual([1, 2, 3])
  })

  it('windows long lists around the current page', () => {
    expect(getPageNumbers(5, 100)).toEqual([1, 'ellipsis', 4, 5, 6, 'ellipsis', 100])
    expect(getPageNumbers(1, 100)).toEqual([1, 2, 'ellipsis', 100])
    expect(getPageNumbers(100, 100)).toEqual([1, 'ellipsis', 99, 100])
  })
})
