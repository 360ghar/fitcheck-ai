import { beforeEach, describe, expect, it, vi } from 'vitest'

vi.mock('@/api/outfits', () => ({
  getOutfits: vi.fn(),
  getOutfit: vi.fn(),
}))

import { getOutfits } from '@/api/outfits'
import { useOutfitStore } from '../outfitStore'
import type { Outfit } from '@/types'

function outfit(id: string): Outfit {
  return { id, name: id, item_ids: [], images: [] } as unknown as Outfit
}

function page(outfits: Outfit[], hasNext: boolean) {
  return {
    outfits,
    total: 4,
    page: 1,
    total_pages: 2,
    has_prev: false,
    has_next: hasNext,
  }
}

describe('outfitStore.fetchMore (infinite scroll)', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    useOutfitStore.setState({
      outfits: [],
      isLoading: false,
      isLoadingMore: false,
      hasMore: true,
      page: 1,
      pageSize: 24,
      error: null,
    })
  })

  it('appends the next page and reports hasMore from the response', async () => {
    vi.mocked(getOutfits).mockResolvedValueOnce(page([outfit('a')], true))
    await useOutfitStore.getState().fetchOutfits(true)

    vi.mocked(getOutfits).mockResolvedValueOnce(
      page([outfit('b'), outfit('c')], false)
    )
    await useOutfitStore.getState().fetchMore()

    expect(useOutfitStore.getState().outfits.map((o) => o.id)).toEqual([
      'a',
      'b',
      'c',
    ])
    expect(useOutfitStore.getState().hasMore).toBe(false)
    expect(useOutfitStore.getState().page).toBe(2)
    expect(useOutfitStore.getState().isLoadingMore).toBe(false)
    expect(getOutfits).toHaveBeenLastCalledWith(
      expect.objectContaining({ page: 2, page_size: 24 })
    )
  })

  it('is a no-op while a fetch is already in flight', async () => {
    useOutfitStore.setState({ isLoadingMore: true })
    await useOutfitStore.getState().fetchMore()
    expect(getOutfits).not.toHaveBeenCalled()
  })

  it('is a no-op once the list is exhausted', async () => {
    useOutfitStore.setState({ hasMore: false })
    await useOutfitStore.getState().fetchMore()
    expect(getOutfits).not.toHaveBeenCalled()
  })
})
