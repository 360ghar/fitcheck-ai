import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { http, HttpResponse } from 'msw'
import type { RouteObject } from 'react-router-dom'
import { describe, expect, it } from 'vitest'

import { GenerationsExplorer } from './GenerationsExplorer'

import { adminUserGenerationsFixture, createUsersHandlers } from '@/test/msw/handlers/users'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

function explorerRoutes(userId: string): RouteObject[] {
  return [
    { path: '/users/:id', element: <GenerationsExplorer userId={userId} /> },
    { path: '/users/:id/generations/:kind/:generationId', element: <div>viewer-marker</div> },
  ]
}

function renderExplorer(userId = 'user_1') {
  return renderWithProviders(<GenerationsExplorer userId={userId} />, {
    routes: explorerRoutes(userId),
    initialEntries: [`/users/${userId}`],
  })
}

describe('GenerationsExplorer', () => {
  it('renders generation cards across kinds with media, status and counts', async () => {
    renderExplorer()

    expect(await screen.findByText('linkedin')).toBeInTheDocument()
    // Outfit + render run share the outfit title
    expect(screen.getAllByText('Summer Look 1').length).toBe(2)
    // Media count + failed count surfaces
    expect(screen.getAllByText(/image/).length).toBeGreaterThanOrEqual(1)
  })

  it('writes gen_tab into the URL when switching tabs', async () => {
    const { handlers, state } = createUsersHandlers()
    server.use(...handlers)
    renderExplorer()
    const user = userEvent.setup()

    await user.click(await screen.findByRole('tab', { name: 'Items' }))

    await waitFor(() => {
      expect(state.lastGenerationsQuery?.searchParams.get('kind')).toBe('item')
    })
  })

  it('navigates to the full-page viewer when a card is clicked', async () => {
    renderExplorer()
    const user = userEvent.setup()

    await user.click(await screen.findByText('linkedin'))

    expect(await screen.findByText('viewer-marker')).toBeInTheDocument()
  })

  it('shows the empty state when the user has no generations', async () => {
    server.use(
      http.get('*/api/v1/admin/users/user_2/generations', () =>
        HttpResponse.json({
          ...adminUserGenerationsFixture,
          items: [],
          total: 0,
          counts: {
            item_generations: 0,
            outfits: 0,
            outfit_renders: 0,
            photoshoot_jobs: 0,
            social_import_jobs: 0,
          },
        }),
      ),
    )
    renderExplorer('user_2')

    expect(await screen.findByText('No generations yet')).toBeInTheDocument()
  })
})
