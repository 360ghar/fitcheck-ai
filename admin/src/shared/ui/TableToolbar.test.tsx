import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'
import { axe } from 'vitest-axe'

import { TableToolbar, type TableToolbarFilter } from './TableToolbar'

import { renderWithProviders } from '@/test/utils'

const statusFilter: TableToolbarFilter = {
  key: 'status',
  label: 'Status',
  placeholder: 'All statuses',
  options: [
    { value: 'all', label: 'All statuses' },
    { value: 'active', label: 'Active' },
    { value: 'suspended', label: 'Suspended' },
  ],
  value: undefined,
  onValueChange: vi.fn(),
}

const roleFilter: TableToolbarFilter = {
  key: 'role',
  label: 'Role',
  placeholder: 'All roles',
  options: [
    { value: 'all', label: 'All roles' },
    { value: 'admin', label: 'Admin' },
    { value: 'support', label: 'Support' },
  ],
  value: undefined,
  onValueChange: vi.fn(),
}

const base = {
  searchValue: '',
  onSearchChange: vi.fn(),
}

describe('TableToolbar', () => {
  it('renders search, inline primary filter, and a Filters popover button', () => {
    renderWithProviders(
      <TableToolbar
        {...base}
        searchPlaceholder="Search users"
        primaryFilter={statusFilter}
        filters={[roleFilter]}
      />,
    )
    expect(screen.getByRole('searchbox', { name: 'Filter results' })).toBeInTheDocument()
    expect(screen.getByRole('combobox', { name: 'Status' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Filters' })).toBeInTheDocument()
  })

  it('shows no popover button when there are no secondary filters', () => {
    renderWithProviders(<TableToolbar {...base} primaryFilter={statusFilter} />)
    expect(screen.queryByRole('button', { name: 'Filters' })).not.toBeInTheDocument()
  })

  it('applies a primary filter and shows it as a removable chip', async () => {
    const user = userEvent.setup()
    const onValueChange = vi.fn()
    renderWithProviders(
      <TableToolbar
        {...base}
        primaryFilter={{ ...statusFilter, onValueChange }}
        filters={[roleFilter]}
      />,
    )
    await user.click(screen.getByRole('combobox', { name: 'Status' }))
    await user.click(await screen.findByRole('option', { name: 'Suspended' }))
    expect(onValueChange).toHaveBeenCalledWith('suspended')
    // Re-render as the page would (value now controlled) — chip appears
    renderWithProviders(
      <TableToolbar
        {...base}
        primaryFilter={{ ...statusFilter, value: 'suspended', onValueChange }}
        filters={[roleFilter]}
      />,
    )
    expect(screen.getByText('Status: Suspended')).toBeInTheDocument()
  })

  it('selects a secondary filter from the popover and shows the active-count badge', async () => {
    const user = userEvent.setup()
    const onRoleChange = vi.fn()
    renderWithProviders(
      <TableToolbar
        {...base}
        filters={[{ ...roleFilter, onValueChange: onRoleChange }, statusFilter]}
      />,
    )
    await user.click(screen.getByRole('button', { name: 'Filters' }))
    await user.click(await screen.findByRole('combobox', { name: 'Role' }))
    await user.click(await screen.findByRole('option', { name: 'Admin' }))
    expect(onRoleChange).toHaveBeenCalledWith('admin')
    // Controlled re-render: badge shows 1 active filter, chip appears
    renderWithProviders(
      <TableToolbar
        {...base}
        filters={[{ ...roleFilter, value: 'admin', onValueChange: onRoleChange }, statusFilter]}
      />,
    )
    expect(screen.getByRole('button', { name: 'Filters (1 active)' })).toBeInTheDocument()
    expect(screen.getByText('Role: Admin')).toBeInTheDocument()
  })

  it('clears a single filter from its chip', async () => {
    const user = userEvent.setup()
    const onValueChange = vi.fn()
    renderWithProviders(
      <TableToolbar
        {...base}
        primaryFilter={{ ...statusFilter, value: 'active', onValueChange }}
      />,
    )
    await user.click(screen.getByRole('button', { name: 'Clear Status: Active' }))
    expect(onValueChange).toHaveBeenCalledWith(undefined)
  })

  it('renders date-range inputs inside the popover and clears via chips', async () => {
    const user = userEvent.setup()
    const onFromChange = vi.fn()
    const onToChange = vi.fn()
    renderWithProviders(
      <TableToolbar
        {...base}
        dateFilters={[
          { key: 'from', label: 'From', value: undefined, onValueChange: onFromChange },
          { key: 'to', label: 'To', value: undefined, onValueChange: onToChange },
        ]}
      />,
    )
    await user.click(screen.getByRole('button', { name: 'Filters' }))
    await user.type(screen.getByLabelText('From'), '2026-08-01')
    expect(onFromChange).toHaveBeenCalledWith('2026-08-01')
    // Controlled re-render shows the chip
    renderWithProviders(
      <TableToolbar
        {...base}
        dateFilters={[
          { key: 'from', label: 'From', value: '2026-08-01', onValueChange: onFromChange },
          { key: 'to', label: 'To', value: undefined, onValueChange: onToChange },
        ]}
      />,
    )
    expect(screen.getByText('From: 2026-08-01')).toBeInTheDocument()
  })

  it('resets every filter from the popover footer and shows Clear all for multiple chips', async () => {
    const user = userEvent.setup()
    const onReset = vi.fn()
    renderWithProviders(
      <TableToolbar
        {...base}
        primaryFilter={{ ...statusFilter, value: 'active', onValueChange: vi.fn() }}
        filters={[{ ...roleFilter, value: 'admin' }]}
        onReset={onReset}
      />,
    )
    expect(screen.getByRole('button', { name: 'Clear all' })).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Filters (1 active)' }))
    await user.click(screen.getByRole('button', { name: 'Reset filters' }))
    expect(onReset).toHaveBeenCalled()
  })

  it('shows a refreshing status while a background refetch runs', () => {
    renderWithProviders(<TableToolbar {...base} isFetching />)
    expect(screen.getByRole('status')).toHaveTextContent('Refreshing')
  })

  it('renders right-aligned actions and the searchbox keeps its accessible name', () => {
    renderWithProviders(
      <TableToolbar {...base} actions={<button type="button">Export</button>} />,
    )
    expect(screen.getByRole('button', { name: 'Export' })).toBeInTheDocument()
    expect(screen.getByRole('searchbox', { name: 'Filter results' })).toBeInTheDocument()
  })

  it('has no axe violations', async () => {
    const { container } = renderWithProviders(
      <TableToolbar
        {...base}
        primaryFilter={{ ...statusFilter, value: 'active', onValueChange: vi.fn() }}
        filters={[{ ...roleFilter, value: 'admin' }]}
        onReset={vi.fn()}
        actions={<button type="button">Export</button>}
      />,
    )
    expect(await axe(container)).toHaveNoViolations()
  })
})
