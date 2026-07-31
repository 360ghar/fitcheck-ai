import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Route, Routes, useLocation } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

vi.mock('@/api/items', () => ({
  getItems: vi.fn(),
  getItem: vi.fn(),
  updateItem: vi.fn(),
  deleteItem: vi.fn(),
  batchDeleteItems: vi.fn(),
  toggleItemFavorite: vi.fn(),
  markItemAsWorn: vi.fn(),
}))

import { getItems } from '@/api/items'
import WardrobePage from '@/pages/wardrobe/WardrobePage'
import { useClosetStore } from '@/stores/wardrobeStore'
import type { Item } from '@/types'

const item = {
  id: 'item-1',
  name: 'Linen shirt',
  category: 'tops',
  brand: 'Uniqlo',
  colors: ['white'],
  materials: [],
  seasonal_tags: [],
  occasion_tags: ['informal'],
  tags: ['summer'],
  condition: 'clean',
  is_favorite: false,
  usage_times_worn: 4,
  price: 40,
  created_at: '2026-06-01T00:00:00.000Z',
  updated_at: '2026-06-01T00:00:00.000Z',
  images: [],
} as unknown as Item

/**
 * jsdom ships no matchMedia; stub it so the desktop split pane is exercised.
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
    <MemoryRouter initialEntries={['/wardrobe']}>
      <LocationProbe />
      <Routes>
        <Route path="/wardrobe" element={<WardrobePage />} />
        <Route path="/wardrobe/:id" element={<WardrobePage />} />
      </Routes>
    </MemoryRouter>
  )
}

describe('WardrobePage detail selection is driven by the URL', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    stubDesktopViewport()
    useClosetStore.setState({
      items: [],
      filteredItems: [],
      selectedItem: null,
      selectedItems: new Set(),
      isLoading: false,
      isDetailLoading: false,
      error: null,
    })
    vi.mocked(getItems).mockResolvedValue({
      items: [item],
      total: 1,
      page: 1,
      total_pages: 1,
      has_prev: false,
      has_next: false,
    })
  })

  it('pushes /wardrobe/<id> on card click, returns to /wardrobe on close, and does not refetch the closet', async () => {
    const user = userEvent.setup()
    renderPage()

    await user.click(await screen.findByText('Linen shirt'))

    await waitFor(() =>
      expect(screen.getByTestId('pathname')).toHaveTextContent('/wardrobe/item-1')
    )

    // The pane renders its own content, including the cost-per-wear arithmetic.
    expect(await screen.findByText('cost per wear')).toBeInTheDocument()
    expect(screen.getByText('$40 ÷ 4 wears')).toBeInTheDocument()

    // Selection lives in the path, so opening a detail must NOT refetch the closet.
    expect(getItems).toHaveBeenCalledTimes(1)

    await user.click(screen.getByRole('button', { name: /close linen shirt details/i }))

    await waitFor(() => expect(screen.getByTestId('pathname')).toHaveTextContent('/wardrobe'))
    expect(screen.getByTestId('pathname').textContent).toBe('/wardrobe')
    expect(getItems).toHaveBeenCalledTimes(1)
  })
})
