import { screen, waitFor, within } from '@testing-library/react'
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

    // Distinct cards per kind: item extraction, photoshoot, social import.
    expect(await screen.findByText('batch')).toBeInTheDocument()
    expect(await screen.findByText('linkedin')).toBeInTheDocument()
    expect(await screen.findByText('instagram')).toBeInTheDocument()
    // Outfit + render run share the outfit title
    expect(screen.getAllByText('Summer Look 1').length).toBe(2)
    // Media count + failed count surfaces — scoped per card so one card
    // cannot satisfy every assertion (outfit + render share a title).
    expect(within(screen.getByRole('button', { name: 'Open batch' })).getByText(/image/)).toBeInTheDocument()
    const summerCards = screen.getAllByRole('button', { name: 'Open Summer Look 1' })
    expect(summerCards.length).toBe(2)
    // The outfit card renders its media count; the failed render run
    // (failed_count 1 in the fixture) renders the failed-count branch.
    // Exact strings, distinguished by subtitle: the "Failed" StatusBadge
    // must not satisfy the count assertion.
    const renderCard = summerCards.find((card) => within(card).queryByText(/variations/))
    const outfitCard = summerCards.find((card) => within(card).queryByText(/3 items/))
    expect(renderCard).toBeDefined()
    expect(outfitCard).toBeDefined()
    expect(within(renderCard as HTMLElement).getByText('1 failed')).toBeInTheDocument()
    expect(within(outfitCard as HTMLElement).getByText('1 image')).toBeInTheDocument()
  })

  it('writes gen_tab into the URL when switching tabs', async () => {
    const { handlers, state } = createUsersHandlers()
    server.use(...handlers)
    const { router } = renderExplorer()
    const user = userEvent.setup()

    await user.click(await screen.findByRole('tab', { name: 'Items' }))

    await waitFor(() => {
      expect(state.lastGenerationsQuery?.searchParams.get('kind')).toBe('item')
    })
    expect(new URLSearchParams(router.state.location.search).get('gen_tab')).toBe('item')
  })

  it('navigates to the full-page viewer when a card is clicked', async () => {
    const { router } = renderExplorer()
    const user = userEvent.setup()

    await user.click(await screen.findByText('linkedin'))

    expect(await screen.findByText('viewer-marker')).toBeInTheDocument()
    expect(router.state.location.pathname).toBe('/users/user_1/generations/photoshoot/ps_job_1')
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
