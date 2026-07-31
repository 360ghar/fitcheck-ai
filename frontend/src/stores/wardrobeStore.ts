/**
 * Wardrobe store using Zustand
 * Manages items, filters, selection state, and UI state for the wardrobe
 */

import { create } from 'zustand';
import type {
  Item,
  Category,
  Condition,
  ItemFilters as ApiItemFilters,
  ItemFormData,
} from '../types';
import * as itemsApi from '../api/items';
import { getApiError, type ApiError } from '../lib/errors';

// ============================================================================
// WARDROBE STATE INTERFACE
// ============================================================================

interface ClosetState {
  // Items data
  items: Item[];
  filteredItems: Item[];
  selectedItem: Item | null;
  selectedItems: Set<string>;

  // Filters
  filters: {
    category: Category | 'all';
    color: string | 'all';
    occasion: string;
    condition: Condition | 'all';
    search: string;
    isFavorite: boolean;
  };

  // UI state
  isLoading: boolean;
  /**
   * Detail-pane fetch, deliberately separate from `isLoading`.
   * `isLoading` swaps the whole grid for a skeleton; a deep link to
   * /wardrobe/:id must not blank the list it is being shown beside.
   */
  isDetailLoading: boolean;
  isGridView: boolean;
  viewMode: 'all' | 'favorites' | 'recent';
  sortBy: 'name' | 'category' | 'date_added' | 'times_worn' | 'cost_per_wear';
  sortOrder: 'asc' | 'desc';

  // Error state
  error: ApiError | null;

  // Pagination
  page: number;
  pageSize: number;
  totalItems: number;
  hasMore: boolean;

  // Actions
  fetchItems: (refresh?: boolean) => Promise<void>;
  fetchItemById: (id: string) => Promise<void>;
  setSelectedItem: (item: Item | null) => void;
  toggleItemSelected: (itemId: string) => void;
  clearSelectedItems: () => void;
  setFilter: <K extends keyof ClosetState['filters']>(filter: K, value: ClosetState['filters'][K]) => void;
  resetFilters: () => void;
  setViewMode: (mode: 'all' | 'favorites' | 'recent') => void;
  setSortBy: (sortBy: ClosetState['sortBy']) => void;
  setSortOrder: (order: 'asc' | 'desc') => void;
  setGridView: (isGrid: boolean) => void;
  toggleItemFavorite: (itemId: string) => Promise<{ id: string; is_favorite: boolean }>;
  /** Rejects on failure so an inline edit form can stay open for a retry. */
  updateItem: (itemId: string, data: Partial<ItemFormData>) => Promise<Item>;
  markItemAsWorn: (itemId: string) => Promise<Item>;
  deleteItem: (itemId: string) => Promise<void>;
  deleteSelectedItems: () => Promise<void>;
  setPage: (page: number) => void;
  clearError: () => void;
}

// ============================================================================
// INITIAL FILTERS STATE
// ============================================================================

const initialFilters: ClosetState['filters'] = {
  category: 'all',
  color: 'all',
  occasion: '',
  condition: 'all',
  search: '',
  isFavorite: false,
};

// ============================================================================
// HELPER FUNCTION
// ============================================================================

function applyFiltersAndSort(
  items: Item[],
  filters: ClosetState['filters'],
  sortBy: ClosetState['sortBy'],
  sortOrder: ClosetState['sortOrder']
): Item[] {
  let filtered = [...items];

  // Apply category filter
  if (filters.category !== 'all') {
    filtered = filtered.filter((item) => item.category === filters.category);
  }

  // Apply color filter
  if (filters.color !== 'all') {
    filtered = filtered.filter((item) =>
      item.colors.some((color) =>
        color.toLowerCase() === (filters.color as string).toLowerCase()
      )
    );
  }

  // Apply condition filter
  if (filters.condition !== 'all') {
    filtered = filtered.filter((item) => item.condition === filters.condition);
  }

  // Apply use-case filter
  if (filters.occasion) {
    const occasion = filters.occasion.toLowerCase();
    filtered = filtered.filter((item) =>
      (item.occasion_tags || []).some((tag) => tag.toLowerCase() === occasion)
    );
  }

  // Apply favorite filter
  if (filters.isFavorite) {
    filtered = filtered.filter((item) => item.is_favorite);
  }

  // Apply search filter
  if (filters.search) {
    const searchLower = filters.search.toLowerCase();
    filtered = filtered.filter(
      (item) =>
        item.name.toLowerCase().includes(searchLower) ||
        item.brand?.toLowerCase().includes(searchLower) ||
        item.tags.some((tag) => tag.toLowerCase().includes(searchLower)) ||
        item.notes?.toLowerCase().includes(searchLower)
    );
  }

  // Apply sorting
  filtered.sort((a, b) => {
    let comparison = 0;

    switch (sortBy) {
      case 'name':
        comparison = a.name.localeCompare(b.name);
        break;
      case 'category':
        comparison = a.category.localeCompare(b.category);
        break;
      case 'date_added':
        comparison = new Date(a.created_at).getTime() - new Date(b.created_at).getTime();
        break;
      case 'times_worn':
        comparison = a.usage_times_worn - b.usage_times_worn;
        break;
      case 'cost_per_wear': {
        const aCpw = a.cost_per_wear ?? a.price ?? 0;
        const bCpw = b.cost_per_wear ?? b.price ?? 0;
        comparison = aCpw - bCpw;
        break;
      }
    }

    return sortOrder === 'asc' ? comparison : -comparison;
  });

  return filtered;
}

// ============================================================================
// WARDROBE STORE
// ============================================================================

export const useClosetStore = create<ClosetState>((set, get) => ({
  // Initial state
  items: [],
  filteredItems: [],
  selectedItem: null,
  selectedItems: new Set(),
  filters: initialFilters,
  isLoading: false,
  isDetailLoading: false,
  isGridView: true,
  viewMode: 'all',
  sortBy: 'date_added',
  sortOrder: 'desc',
  error: null,
  page: 1,
  pageSize: 24,
  totalItems: 0,
  hasMore: true,

  // Fetch items
  fetchItems: async (refresh = false) => {
    const state = get();
    const { filters, page, pageSize, items } = state;

    const newPage = refresh ? 1 : page;

    set({ isLoading: true, error: null });

    try {
      const apiFilters: ApiItemFilters = {
        page: newPage,
        page_size: pageSize,
      };

      if (filters.category !== 'all') apiFilters.category = filters.category;
      if (filters.color !== 'all') apiFilters.color = filters.color;
      if (filters.occasion) apiFilters.occasion = filters.occasion;
      if (filters.condition !== 'all') apiFilters.condition = filters.condition;
      if (filters.search) apiFilters.search = filters.search;
      if (filters.isFavorite) apiFilters.is_favorite = true;

      const response = await itemsApi.getItems(apiFilters);

      set({
        items: refresh || newPage === 1 ? response.items : [...items, ...response.items],
        totalItems: response.total,
        hasMore: response.has_next,
        page: newPage,
        isLoading: false,
      });

      // Apply filters and sort after items are set
      const currentState = get();
      set({
        filteredItems: applyFiltersAndSort(
          currentState.items,
          currentState.filters,
          currentState.sortBy,
          currentState.sortOrder
        ),
      });
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError, isLoading: false });
    }
  },

  // Fetch single item by ID
  fetchItemById: async (id: string) => {
    // isDetailLoading, not isLoading: see the field comment.
    set({ isDetailLoading: true, error: null });
    try {
      const item = await itemsApi.getItem(id);
      const state = get();
      const index = state.items.findIndex((i) => i.id === id);
      const newItems = [...state.items];
      if (index !== -1) {
        newItems[index] = item;
      } else {
        newItems.push(item);
      }

      set({
        items: newItems,
        selectedItem: item,
        isDetailLoading: false,
        filteredItems: applyFiltersAndSort(newItems, state.filters, state.sortBy, state.sortOrder),
      });
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError, isDetailLoading: false });
    }
  },

  // Set selected item
  setSelectedItem: (item: Item | null) => {
    set({ selectedItem: item });
  },

  // Toggle item selection
  toggleItemSelected: (itemId: string) => {
    const state = get();
    const newSelected = new Set(state.selectedItems);
    if (newSelected.has(itemId)) {
      newSelected.delete(itemId);
    } else {
      newSelected.add(itemId);
    }
    set({ selectedItems: newSelected });
  },

  // Clear selected items
  clearSelectedItems: () => {
    set({ selectedItems: new Set() });
  },

  // Set filter
  setFilter: <K extends keyof ClosetState['filters']>(filter: K, value: ClosetState['filters'][K]) => {
    set({ filters: { ...get().filters, [filter]: value }, page: 1 });
    const state = get();
    set({
      filteredItems: applyFiltersAndSort(state.items, state.filters, state.sortBy, state.sortOrder),
    });
  },

  // Reset filters
  resetFilters: () => {
    set({ filters: initialFilters, page: 1 });
    const state = get();
    set({
      filteredItems: applyFiltersAndSort(state.items, state.filters, state.sortBy, state.sortOrder),
    });
  },

  // Set view mode
  setViewMode: (mode: 'all' | 'favorites' | 'recent') => {
    set({ viewMode: mode, page: 1, filters: { ...get().filters, isFavorite: mode === 'favorites' } });
  },

  // Set sort by
  setSortBy: (sortBy: ClosetState['sortBy']) => {
    set({ sortBy });
    const state = get();
    set({
      filteredItems: applyFiltersAndSort(state.items, state.filters, state.sortBy, state.sortOrder),
    });
  },

  // Set sort order
  setSortOrder: (sortOrder: 'asc' | 'desc') => {
    set({ sortOrder });
    const state = get();
    set({
      filteredItems: applyFiltersAndSort(state.items, state.filters, state.sortBy, state.sortOrder),
    });
  },

  // Set grid view
  setGridView: (isGrid: boolean) => {
    set({ isGridView: isGrid });
  },

  // Toggle item favorite (single API call; returns updated item)
  toggleItemFavorite: async (itemId: string) => {
    try {
      const updated = await itemsApi.toggleItemFavorite(itemId);
      // Re-read after await so concurrent list updates are not overwritten
      const state = get();
      const newItems = state.items.map((item) =>
        item.id === itemId ? { ...item, is_favorite: updated.is_favorite } : item
      );
      set({
        items: newItems,
        selectedItem:
          state.selectedItem?.id === itemId
            ? { ...state.selectedItem, is_favorite: updated.is_favorite }
            : state.selectedItem,
        filteredItems: applyFiltersAndSort(newItems, state.filters, state.sortBy, state.sortOrder),
      });
      return updated;
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError });
      throw error;
    }
  },

  // Update item (single API call; patches every collection in place)
  //
  // Lives in the store rather than the page because the detail pane now reads
  // from the store and stays mounted: a page-local `apiUpdateItem()` + a
  // `fetchItems(true)` repair would leave the pane showing stale data for the
  // whole round-trip. Rejects on failure so an inline edit form can stay open.
  updateItem: async (itemId: string, data: Partial<ItemFormData>) => {
    try {
      const updated = await itemsApi.updateItem(itemId, data);
      // Re-read after await so concurrent list updates are not overwritten.
      const state = get();
      const newItems = state.items.map((item) => (item.id === itemId ? updated : item));
      set({
        items: newItems,
        selectedItem: state.selectedItem?.id === itemId ? updated : state.selectedItem,
        filteredItems: applyFiltersAndSort(newItems, state.filters, state.sortBy, state.sortOrder),
      });
      return updated;
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError });
      throw error;
    }
  },

  // Mark item as worn
  //
  // The endpoint returns only `{ id, usage_times_worn }`; `usage_last_worn` is
  // mirrored to now because that is exactly what the server just recorded.
  // `cost_per_wear` is deliberately NOT recomputed here — the detail pane derives
  // the figure it shows from `price / usage_times_worn`, so there is one
  // definition of that arithmetic in the app rather than two.
  markItemAsWorn: async (itemId: string) => {
    try {
      const result = await itemsApi.markItemAsWorn(itemId);
      const state = get();
      const wornAt = new Date().toISOString();
      const patch = (item: Item): Item => ({
        ...item,
        usage_times_worn: result.usage_times_worn,
        usage_last_worn: wornAt,
      });
      const newItems = state.items.map((item) => (item.id === itemId ? patch(item) : item));
      const updated = newItems.find((item) => item.id === itemId);
      set({
        items: newItems,
        selectedItem:
          state.selectedItem?.id === itemId ? patch(state.selectedItem) : state.selectedItem,
        filteredItems: applyFiltersAndSort(newItems, state.filters, state.sortBy, state.sortOrder),
      });
      if (!updated) throw new Error('Item is no longer in the closet');
      return updated;
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError });
      throw error;
    }
  },

  // Delete item
  deleteItem: async (itemId: string) => {
    try {
      await itemsApi.deleteItem(itemId);
      const state = get();
      const newItems = state.items.filter((i) => i.id !== itemId);
      const newSelected = new Set(state.selectedItems);
      newSelected.delete(itemId);

      set({
        items: newItems,
        filteredItems: applyFiltersAndSort(newItems, state.filters, state.sortBy, state.sortOrder),
        selectedItem: state.selectedItem?.id === itemId ? null : state.selectedItem,
        selectedItems: newSelected,
      });
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError });
      throw error;
    }
  },

  // Delete selected items
  deleteSelectedItems: async () => {
    const state = get();
    const { selectedItems } = state;
    if (selectedItems.size === 0) return;

    try {
      await itemsApi.batchDeleteItems(Array.from(selectedItems));
      const newItems = state.items.filter((i) => !selectedItems.has(i.id));
      set({
        items: newItems,
        filteredItems: applyFiltersAndSort(newItems, state.filters, state.sortBy, state.sortOrder),
        selectedItems: new Set(),
      });
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError });
      throw error;
    }
  },

  // Set page
  setPage: (page: number) => {
    set({ page });
  },

  // Clear error
  clearError: () => set({ error: null }),
}));

// ============================================================================
// SELECTORS
// ============================================================================

export const selectItems = (state: ClosetState) => state.items;
export const selectFilteredItems = (state: ClosetState) => state.filteredItems;
export const selectSelectedItem = (state: ClosetState) => state.selectedItem;
export const selectSelectedItems = (state: ClosetState) => state.selectedItems;
export const selectFilters = (state: ClosetState) => state.filters;
export const selectIsLoading = (state: ClosetState) => state.isLoading;
export const selectError = (state: ClosetState) => state.error;
export const selectHasMore = (state: ClosetState) => state.hasMore;

// ============================================================================
// HOOKS
// ============================================================================

/**
 * Hook to get all items
 */
export function useItems(): Item[] {
  return useClosetStore(selectItems);
}

/**
 * Hook to get filtered items
 */
export function useFilteredItems(): Item[] {
  return useClosetStore(selectFilteredItems);
}

/**
 * Hook to get selected item
 */
export function useSelectedItem(): Item | null {
  return useClosetStore(selectSelectedItem);
}

/**
 * Hook to get selected items count
 */
export function useSelectedItemsCount(): number {
  return useClosetStore((state) => state.selectedItems.size);
}

/**
 * Hook to check if item is selected
 */
export function useIsItemSelected(itemId: string): boolean {
  return useClosetStore((state) => state.selectedItems.has(itemId));
}
