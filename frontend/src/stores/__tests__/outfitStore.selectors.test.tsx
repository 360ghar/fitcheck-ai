import { act, renderHook } from '@testing-library/react'
import { beforeEach, describe, expect, it } from 'vitest'

import { useFilteredOutfits, useOutfitStore } from '@/stores/outfitStore'
import type { Outfit } from '@/types'

const firstOutfit = {
  id: 'outfit-1',
  name: 'Weekend uniform',
  created_at: '2026-07-01T00:00:00.000Z',
  style: 'casual',
  season: 'summer',
  tags: ['weekend'],
  item_ids: ['item-1'],
  worn_count: 2,
  images: [],
} as unknown as Outfit

const secondOutfit = {
  ...firstOutfit,
  id: 'outfit-2',
  name: 'Office look',
  created_at: '2026-07-02T00:00:00.000Z',
  style: 'business',
  tags: ['office'],
} as Outfit

describe('outfitStore derived selectors', () => {
  beforeEach(() => {
    useOutfitStore.setState({
      outfits: [firstOutfit, secondOutfit],
      filters: { style: 'all', season: 'all', search: '', isFavorite: false },
      sortBy: 'date_added',
      sortOrder: 'desc',
      isLoading: false,
    })
  })

  it('keeps the filtered snapshot stable for unrelated store changes', () => {
    const { result } = renderHook(() => useFilteredOutfits())
    const initialSnapshot = result.current

    act(() => {
      useOutfitStore.setState({ isLoading: true })
    })

    expect(result.current).toBe(initialSnapshot)
  })

  it('recomputes when a filter input changes', () => {
    const { result } = renderHook(() => useFilteredOutfits())

    act(() => {
      useOutfitStore.setState({
        filters: { style: 'business', season: 'all', search: '', isFavorite: false },
      })
    })

    expect(result.current).toEqual([secondOutfit])
  })
})
