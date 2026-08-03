/**
 * Locks in the P1 fix: the create-page preview generation MUST send `item_id`.
 *
 * `generateOutfit` resolves each item's stored image server-side from its id and
 * sends it to the model as a garment reference. Without `item_id` the render
 * invents a lookalike from the text attributes, so the "preview-before-save"
 * flow would show clothes the user does not own — and then attach that invented
 * photo to the saved outfit.
 */
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

vi.mock('@/api/outfits', () => ({
  getAvailableItems: vi.fn(),
  createOutfit: vi.fn(),
}))

import { getAvailableItems } from '@/api/outfits'
import OutfitCreatePage from '@/pages/outfits/OutfitCreatePage'
import { useOutfitStore } from '@/stores/outfitStore'

const item = {
  id: 'item-1',
  name: 'Cream sweater',
  category: 'tops',
  colors: ['cream'],
  image_url: 'https://x.test/a.jpg',
}

/**
 * jsdom ships no matchMedia. Stub it so the MasterDetailLayout split/viewport
 * hooks resolve instead of throwing.
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

describe('OutfitCreatePage preview generation', () => {
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
    vi.mocked(getAvailableItems).mockResolvedValue([item])
    vi.mocked(getAvailableItems as unknown as { mockClear: () => void }).mockClear?.()
  })

  it('sends item_id for each picked piece so the backend renders the real garment', async () => {
    // Intercept the store action the page calls: assert the payload it receives.
    const previewSpy = vi
      .spyOn(useOutfitStore.getState(), 'generateOutfitPreview')
      .mockResolvedValue()

    const user = userEvent.setup()
    // `?items=item-1` is the same hand-off the Recommendations page uses: the
    // page seeds its draft from it.
    render(
      <MemoryRouter initialEntries={['/outfits/new?items=item-1']}>
        <Routes>
          <Route path="/outfits/new" element={<OutfitCreatePage />} />
        </Routes>
      </MemoryRouter>
    )

    await waitFor(() => expect(getAvailableItems).toHaveBeenCalled())

    await user.click(await screen.findByRole('button', { name: /generate preview/i }))

    await waitFor(() => expect(previewSpy).toHaveBeenCalledTimes(1))
    expect(previewSpy.mock.calls[0][0]).toEqual([
      { item_id: 'item-1', name: 'Cream sweater', category: 'tops', colors: ['cream'] },
    ])
    previewSpy.mockRestore()
  })
})
