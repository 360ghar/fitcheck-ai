import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Route, Routes, useLocation } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

vi.mock('@/api/outfits', () => ({
  getOutfits: vi.fn(),
  getOutfit: vi.fn(),
}))

vi.mock('@/api/items', () => ({
  getItems: vi.fn(),
}))

import { getItems } from '@/api/items'
import { getOutfits } from '@/api/outfits'
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
  occasion: 'work',
  tags: ['weekend'],
  item_ids: [],
  worn_count: 3,
  images: [],
} as unknown as Outfit

/**
 * jsdom ships no matchMedia. Stub it so the desktop split pane (the primary
 * surface) is what gets exercised here; `OutfitsPage.stability.test.tsx`
 * deliberately leaves it undefined to cover the guard in `useMediaQuery`.
 */
function stubDesktopViewport() {
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    configurable: true,
    value: (query: string) => ({
      matches: /min-width/.test(query),
      media: query,
      onchange: null,
      addEventListener: () => undefined,
      removeEventListener: () => undefined,
      addListener: () => undefined,
      removeListener: () => undefined,
      dispatchEvent: () => false,
    }),
  })
}

function LocationProbe() {
  const location = useLocation()
  return <div data-testid="pathname">{location.pathname}</div>
}

function renderPage() {
  return render(
    <MemoryRouter initialEntries={['/outfits']}>
      <LocationProbe />
      <Routes>
        <Route path="/outfits" element={<OutfitsPage />} />
        <Route path="/outfits/:id" element={<OutfitsPage />} />
      </Routes>
    </MemoryRouter>
  )
}

describe('OutfitsPage selection is driven by the URL', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    stubDesktopViewport()
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

  it('pushes /outfits/<id> on card click and returns to /outfits on close', async () => {
    const user = userEvent.setup()
    renderPage()

    await user.click(await screen.findByText('Weekend uniform'))

    await waitFor(() =>
      expect(screen.getByTestId('pathname')).toHaveTextContent('/outfits/outfit-1')
    )

    // The detail surface is real content, not a placeholder.
    expect(await screen.findByText('times worn')).toBeInTheDocument()

    await user.click(
      screen.getByRole('button', { name: /close weekend uniform details/i })
    )

    // Closing genuinely clears the id, so the same card can be reopened.
    await waitFor(() => expect(screen.getByTestId('pathname')).toHaveTextContent('/outfits'))
    expect(screen.getByTestId('pathname').textContent).toBe('/outfits')
  })
})
