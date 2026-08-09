import { beforeEach, describe, expect, it, vi } from 'vitest'

vi.mock('@/api/outfits', () => ({
  getOutfits: vi.fn(),
  getOutfit: vi.fn(),
}))

import { getOutfits } from '@/api/outfits'
import { useOutfitStore } from '../outfitStore'
import { clearRequestCache } from '@/lib/requestCache'
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
    // Reset the shared request cache so cached outfit lists do not leak
    // between tests (mirrors wardrobeStore.test.ts).
    clearRequestCache()
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

  it('a plain fetchOutfits() replaces the loaded list instead of appending', async () => {
    vi.mocked(getOutfits).mockResolvedValueOnce(page([outfit('a')], false))
    await useOutfitStore.getState().fetchOutfits(true)
    expect(useOutfitStore.getState().outfits.map((o) => o.id)).toEqual(['a'])

    // Simulate a mutation (cache invalidated) so the next plain load goes to
    // the wire with different page-1 content: replacement must not append the
    // old rows.
    clearRequestCache()
    vi.mocked(getOutfits).mockResolvedValueOnce(page([outfit('c')], false))
    await useOutfitStore.getState().fetchOutfits()

    expect(useOutfitStore.getState().outfits.map((o) => o.id)).toEqual(['c'])
    expect(useOutfitStore.getState().page).toBe(1)
  })

  it('a plain fetchOutfits() after fetchMore resets to page 1 with no duplicates', async () => {
    vi.mocked(getOutfits).mockResolvedValueOnce(page([outfit('a')], true))
    await useOutfitStore.getState().fetchOutfits(true)

    vi.mocked(getOutfits).mockResolvedValueOnce(page([outfit('b')], false))
    await useOutfitStore.getState().fetchMore()
    expect(useOutfitStore.getState().outfits.map((o) => o.id)).toEqual(['a', 'b'])

    // The forced page-1 result is still cached: the plain fetch replaces with
    // page 1 only, so the page-2 rows cannot duplicate the list.
    await useOutfitStore.getState().fetchOutfits()
    expect(useOutfitStore.getState().outfits.map((o) => o.id)).toEqual(['a'])
    expect(useOutfitStore.getState().page).toBe(1)
    expect(useOutfitStore.getState().hasMore).toBe(true)
  })

  it('refresh=true also replaces instead of appending', async () => {
    vi.mocked(getOutfits).mockResolvedValueOnce(page([outfit('a')], true))
    await useOutfitStore.getState().fetchOutfits(true)

    vi.mocked(getOutfits).mockResolvedValueOnce(page([outfit('b')], false))
    await useOutfitStore.getState().fetchMore()
    expect(useOutfitStore.getState().outfits.map((o) => o.id)).toEqual(['a', 'b'])

    // Forced re-fetch returns a NEW page 1: must replace, not append.
    vi.mocked(getOutfits).mockResolvedValueOnce(page([outfit('c')], false))
    await useOutfitStore.getState().fetchOutfits(true)

    expect(useOutfitStore.getState().outfits.map((o) => o.id)).toEqual(['c'])
    expect(useOutfitStore.getState().page).toBe(1)
  })
})
