import { render, screen, waitFor } from '@testing-library/react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

vi.mock('@/api/outfits', () => ({
  getOutfits: vi.fn(),
}))

vi.mock('@/api/items', () => ({
  getItems: vi.fn(),
}))

import { getItems } from '@/api/items'
import { getOutfits } from '@/api/outfits'
import FeatureErrorBoundary from '@/components/errors/FeatureErrorBoundary'
import OutfitsPage from '@/pages/outfits/OutfitsPage'
import { useClosetStore } from '@/stores/wardrobeStore'
import { useOutfitStore } from '@/stores/outfitStore'
import type { Outfit } from '@/types'

const outfit = {
  id: 'outfit-1',
  name: 'Weekend uniform',
  created_at: '2026-07-01T00:00:00.000Z',
  style: 'casual',
  season: 'summer',
  tags: ['weekend'],
  item_ids: ['item-1'],
  worn_count: 0,
  images: [],
} as unknown as Outfit

describe('OutfitsPage store stability', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    useOutfitStore.setState({
      outfits: [],
      selectedOutfit: null,
      isLoading: false,
      isDetailLoading: false,
      error: null,
      filters: { style: 'all', season: 'all', search: '', isFavorite: false },
      sortBy: 'date_added',
      sortOrder: 'desc',
      generatingOutfits: new Map(),
    })
    useClosetStore.setState({ items: [], filteredItems: [], isLoading: false, error: null })
    vi.mocked(getOutfits).mockResolvedValue({
      outfits: [outfit],
      total: 1,
      page: 1,
      total_pages: 1,
      has_prev: false,
      has_next: false,
    })
    vi.mocked(getItems).mockResolvedValue({
      items: [],
      total: 0,
      page: 1,
      total_pages: 0,
      has_prev: false,
      has_next: false,
    })
  })

  // NOTE: `window.matchMedia` is deliberately left undefined here. That is the
  // jsdom case the guard in `src/hooks/useMediaQuery.ts` exists for — without it
  // the throw is swallowed by FeatureErrorBoundary and the assertion below on the
  // boundary's absence fails.
  it('mounts without the feature boundary and fetches once', async () => {
    const page = (
      <FeatureErrorBoundary featureName="Outfits">
        <OutfitsPage />
      </FeatureErrorBoundary>
    )
    render(
      <MemoryRouter initialEntries={['/outfits']}>
        <Routes>
          <Route path="/outfits" element={page} />
          <Route path="/outfits/:id" element={page} />
        </Routes>
      </MemoryRouter>
    )

    expect(await screen.findByText('Weekend uniform')).toBeInTheDocument()
    expect(screen.queryByText('Something went wrong in Outfits')).not.toBeInTheDocument()
    await waitFor(() => expect(getOutfits).toHaveBeenCalledTimes(1))
  })
})
