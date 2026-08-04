import { beforeEach, describe, expect, it, vi } from 'vitest'

const mocks = vi.hoisted(() => ({
  getItems: vi.fn(),
  getItem: vi.fn(),
  updateItem: vi.fn(),
  deleteItem: vi.fn(),
  batchDeleteItems: vi.fn(),
  toggleItemFavorite: vi.fn(),
  markItemAsWorn: vi.fn(),
}))

vi.mock('@/api/items', () => ({
  getItems: mocks.getItems,
  getItem: mocks.getItem,
  updateItem: mocks.updateItem,
  deleteItem: mocks.deleteItem,
  batchDeleteItems: mocks.batchDeleteItems,
  toggleItemFavorite: mocks.toggleItemFavorite,
  markItemAsWorn: mocks.markItemAsWorn,
}))

import { useClosetStore } from '../wardrobeStore'
import { clearRequestCache } from '@/lib/requestCache'
import type { Item } from '@/types'

const item = (overrides: Partial<Item> = {}): Item =>
  ({
    id: 'item-1',
    name: 'Linen shirt',
    category: 'tops',
    brand: 'Uniqlo',
    colors: ['white'],
    occasion_tags: ['informal'],
    tags: ['summer'],
    condition: 'clean',
    is_favorite: false,
    usage_times_worn: 4,
    price: 40,
    created_at: '2026-06-01T00:00:00.000Z',
    updated_at: '2026-06-01T00:00:00.000Z',
    images: [],
    ...overrides,
  }) as unknown as Item

function paginated(items: Item[], total = items.length) {
  return {
    items,
    total,
    page: 1,
    total_pages: 1,
    has_prev: false,
    has_next: false,
  }
}

describe('wardrobe store', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    // Reset the shared request cache so tests do not leak cached lists
    // between each other (the store's cache keys are user-scoped to 'anon'
    // in the test environment).
    clearRequestCache()
    // Full reset so `hasLoaded` does not leak across tests.
    useClosetStore.setState({
      items: [],
      filteredItems: [],
      selectedItem: null,
      selectedItems: new Set(),
      filters: {
        category: 'all',
        color: 'all',
        occasion: '',
        condition: 'all',
        search: '',
        isFavorite: false,
      },
      isLoading: false,
      hasLoaded: false,
      isLoadingMore: false,
      isDetailLoading: false,
      error: null,
      page: 1,
      pageSize: 24,
      totalItems: 0,
      hasMore: true,
    })
  })

  it('exposes hasLoaded so consumers can tell "not yet loaded" from "genuinely empty"', async () => {
    expect(useClosetStore.getState().hasLoaded).toBe(false)

    mocks.getItems.mockResolvedValue(paginated([]))
    await useClosetStore.getState().fetchItems(true)

    expect(useClosetStore.getState().hasLoaded).toBe(true)
    expect(useClosetStore.getState().items).toEqual([])
  })

  it('fetchMore appends the next page and keeps hasLoaded true', async () => {
    // First page advertises a next page so fetchMore has somewhere to go.
    mocks.getItems.mockResolvedValueOnce({
      items: [item()],
      total: 2,
      page: 1,
      total_pages: 2,
      has_prev: false,
      has_next: true,
    })
    await useClosetStore.getState().fetchItems(true)

    mocks.getItems.mockResolvedValueOnce({
      items: [item({ id: 'item-2', name: 'Jeans' })],
      total: 2,
      page: 2,
      total_pages: 2,
      has_prev: true,
      has_next: false,
    })
    await useClosetStore.getState().fetchMore()

    expect(useClosetStore.getState().items).toHaveLength(2)
    expect(useClosetStore.getState().hasLoaded).toBe(true)
    expect(mocks.getItems).toHaveBeenLastCalledWith(
      expect.objectContaining({ page: 2, page_size: 24 })
    )
  })

  it('clears the open detail selection when that item is bulk-deleted', async () => {
    const open = item()
    const other = item({ id: 'item-2', name: 'Jeans' })
    mocks.getItems.mockResolvedValue(paginated([open, other]))
    await useClosetStore.getState().fetchItems(true)
    useClosetStore.getState().setSelectedItem(open)
    useClosetStore.getState().toggleItemSelected(open.id)

    mocks.batchDeleteItems.mockResolvedValue({ deleted_count: 1 })
    await useClosetStore.getState().deleteSelectedItems()

    expect(useClosetStore.getState().selectedItem).toBeNull()
    expect(useClosetStore.getState().selectedItems.size).toBe(0)
  })

  it('does not hoist a global error when a deep-linked item 404s', async () => {
    mocks.getItems.mockResolvedValue(paginated([]))
    await useClosetStore.getState().fetchItems(true)
    expect(useClosetStore.getState().error).toBeNull()

    mocks.getItem.mockRejectedValue({
      isAxiosError: true,
      message: 'Request failed with status code 404',
      response: { status: 404, data: { error: 'Not found' } },
    })
    await useClosetStore.getState().fetchItemById('missing')

    expect(useClosetStore.getState().error).toBeNull()
    expect(useClosetStore.getState().isDetailLoading).toBe(false)
  })

  it('coalesces concurrent identical list fetches onto one API call', async () => {
    let resolveFetch: (v: unknown) => void = () => {}
    mocks.getItems.mockImplementation(
      () =>
        new Promise((resolve) => {
          resolveFetch = resolve
        })
    )

    const p1 = useClosetStore.getState().fetchItems()
    const p2 = useClosetStore.getState().fetchItems()
    expect(mocks.getItems).toHaveBeenCalledTimes(1)

    resolveFetch(paginated([item()]))
    await Promise.all([p1, p2])

    expect(mocks.getItems).toHaveBeenCalledTimes(1)
    expect(useClosetStore.getState().items).toHaveLength(1)
    expect(useClosetStore.getState().hasLoaded).toBe(true)
  })

  it('reuses a fresh cached list instead of re-fetching on a second load', async () => {
    mocks.getItems.mockResolvedValue(paginated([item()]))
    await useClosetStore.getState().fetchItems()
    await useClosetStore.getState().fetchItems()

    expect(mocks.getItems).toHaveBeenCalledTimes(1)
  })

  it('forces a fresh fetch when refresh=true', async () => {
    mocks.getItems.mockResolvedValue(paginated([item()]))
    await useClosetStore.getState().fetchItems()
    await useClosetStore.getState().fetchItems(true)

    expect(mocks.getItems).toHaveBeenCalledTimes(2)
  })

  it('a delete invalidates the cached list so the next read re-fetches', async () => {
    mocks.getItems.mockResolvedValue(paginated([item()]))
    mocks.deleteItem.mockResolvedValue(undefined)

    await useClosetStore.getState().fetchItems()
    await useClosetStore.getState().deleteItem('item-1')
    await useClosetStore.getState().fetchItems()

    // Initial load + post-delete re-read (cache was invalidated).
    expect(mocks.getItems).toHaveBeenCalledTimes(2)
  })
})
