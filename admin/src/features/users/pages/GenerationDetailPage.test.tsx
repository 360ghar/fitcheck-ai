import { screen, within } from '@testing-library/react'
import type { RouteObject } from 'react-router-dom'
import { describe, expect, it } from 'vitest'

import { GenerationDetailPage } from './GenerationDetailPage'

import { renderWithProviders } from '@/test/utils'

const routes: RouteObject[] = [
  { path: '/users/:id', element: <div>user-detail-marker</div> },
  {
    path: '/users/:id/generations/:kind/:generationId',
    element: <GenerationDetailPage />,
  },
]

function renderViewer(kind: string, generationId = 'ps_job_1') {
  return renderWithProviders(<GenerationDetailPage />, {
    routes,
    initialEntries: [`/users/user_1/generations/${kind}/${generationId}`],
  })
}

describe('GenerationDetailPage', () => {
  it('renders a photoshoot generation: gallery, metadata, source ids', async () => {
    renderViewer('photoshoot')

    // Title from use_case (also echoed in the metadata rows)
    expect(await screen.findAllByText('linkedin').then((all) => all.length)).toBeGreaterThanOrEqual(1)
    // Metadata rows render from meta
    expect(screen.getByText('Aspect ratio')).toBeInTheDocument()
    expect(screen.getByText('4:5')).toBeInTheDocument()
    // Source identifiers block
    expect(screen.getByText('ps_job_1')).toBeInTheDocument()
    // Media thumbnails: 2 images
    expect(screen.getAllByRole('button', { name: /Show image/ }).length).toBe(2)
    // Back link carries the user name
    expect(screen.getByText('Back to Alice Example')).toBeInTheDocument()
  })

  it('renders the error banner for a failed generation', async () => {
    renderViewer('outfit_render', 'render_1')

    expect(await screen.findByText('Job error')).toBeInTheDocument()
    expect(screen.getByText(/provider timeout/)).toBeInTheDocument()
  })

  it('shows not-found for an unknown generation id', async () => {
    renderViewer('photoshoot', 'does_not_exist')

    expect(await screen.findByText('Generation not found')).toBeInTheDocument()
  })

  it('shows the not-found empty state for an unknown kind URL segment', async () => {
    renderViewer('nope')

    expect(await screen.findByText('Generation not found')).toBeInTheDocument()
  })

  it('lists extracted items for an item generation', async () => {
    renderViewer('item', 'job_1')

    // Card title + the total_items metadata row share the label
    expect((await screen.findAllByText('Extracted items')).length).toBeGreaterThanOrEqual(1)
    // The item name echoes in the media gallery label: scope to the row.
    const items = await screen.findAllByText('tops')
    expect(items.length).toBeGreaterThanOrEqual(1)
    const row = (items[0] as HTMLElement).closest('li')
    expect(row).not.toBeNull()
    expect(within(row as HTMLElement).getByText('Linen Shirt')).toBeInTheDocument()
  })
})
