import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it } from 'vitest'
import { axe } from 'vitest-axe'

import { CommandPalette } from './CommandPalette'

import { useCommandStore } from '@/shared/stores/commandStore'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { adminSearchFixture } from '@/test/msw/handlers/search'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

describe('CommandPalette', () => {
  beforeEach(() => {
    useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions: ['*'] })
    useCommandStore.setState({ open: true })
  })

  it('opens with the type hint before any query', () => {
    renderWithProviders(<CommandPalette />)
    expect(
      screen.getByText(
        'Type at least 2 characters to search across users, posts, tickets, and promo codes.',
      ),
    ).toBeInTheDocument()
  })

  it('groups results by type after typing a query', async () => {
    // Unfiltered fixture handler: this test exercises group RENDERING, not
    // the query filter (the filter is covered by the empty-state test).
    server.use(http.get('*/api/v1/admin/search', () => HttpResponse.json(adminSearchFixture)))
    renderWithProviders(<CommandPalette />)

    const user = userEvent.setup()
    await user.type(screen.getByRole('combobox'), 'alice')

    expect(await screen.findByText('Users')).toBeInTheDocument()
    expect(screen.getByText('Alice Example')).toBeInTheDocument()
    expect(screen.getByText('Posts')).toBeInTheDocument()
    expect(screen.getByText('Capsule Wardrobe Guide')).toBeInTheDocument()
    expect(screen.getByText('Feedback tickets')).toBeInTheDocument()
    expect(screen.getByText('Trial not activating')).toBeInTheDocument()
    expect(screen.getByText('Promo codes')).toBeInTheDocument()
    expect(screen.getByText('SUMMER2026')).toBeInTheDocument()
  })

  it('shows a distinct empty state when there are no matches', async () => {
    renderWithProviders(<CommandPalette />)

    const user = userEvent.setup()
    await user.type(screen.getByRole('combobox'), 'zz')

    // global handler returns an empty search result → empty message
    expect(await screen.findByText('No results found for “zz”.')).toBeInTheDocument()
  })

  it('shows an error state when the search request fails', async () => {
    server.use(
      http.get('*/api/v1/admin/search', () =>
        HttpResponse.json(
          { error: 'Search backend down', code: 'INTERNAL_ERROR', details: {} },
          { status: 503 },
        ),
      ),
    )
    renderWithProviders(<CommandPalette />)

    const user = userEvent.setup()
    await user.type(screen.getByRole('combobox'), 'al')

    expect(
      await screen.findByText('Search is unavailable right now. Try again.'),
    ).toBeInTheDocument()
  })

  it('has no axe violations in the open dialog (WCAG 2.1 AA)', async () => {
    renderWithProviders(<CommandPalette />)
    // cmdk portals the dialog into document.body — axe the full document.
    expect(await axe(document.body)).toHaveNoViolations()
  })
})
