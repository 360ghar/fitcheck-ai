/**
 * Wardrobe store using Zustand
 * Manages items, filters, selection state, and UI state for the wardrobe
 */

import { create } from 'zustand';
import type { Item, Category, Condition, ItemFilters as ApiItemFilters } from '../types';
import * as itemsApi from '../api/items';
import { getApiError, ApiError } from '../api/client';

// ============================================================================
// WARDROBE STATE INTERFACE
// ============================================================================

interface WardrobeState {
  // Items data
  items: Item[];
  filteredItems: Item[];
  selectedItem: Item | null;
  selectedItems: Set<string>;

  // Filters
  filters: {
    category: Category | 'all';
    color: string | 'all';
    condition: Condition | 'all';
    search: string;
    isFavorite: boolean;
  };

  // UI state
  isLoading: boolean;
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
  setFilter: (filter: keyof WardrobeState['filters'], value: any) => void;
  resetFilters: () => void;
  setViewMode: (mode: 'all' | 'favorites' | 'recent') => void;
  setSortBy: (sortBy: WardrobeState['sortBy']) => void;
  setSortOrder: (order: 'asc' | 'desc') => void;
  setGridView: (isGrid: boolean) => void;
  toggleItemFavorite: (itemId: string) => Promise<void>;
  deleteItem: (itemId: string) => Promise<void>;
  deleteSelectedItems: () => Promise<void>;
  setPage: (page: number) => void;
  clearError: () => void;
}

// ============================================================================
// INITIAL FILTERS STATE
// ============================================================================

const initialFilters: WardrobeState['filters'] = {
  category: 'all',
  color: 'all',
  condition: 'all',
  search: '',
  isFavorite: false,
};

// ============================================================================
// HELPER FUNCTION
// ============================================================================

function applyFiltersAndSort(
  items: Item[],
  filters: WardrobeState['filters'],
  sortBy: WardrobeState['sortBy'],
  sortOrder: WardrobeState['sortOrder']
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
      case 'cost_per_wear':
        const aCpw = a.cost_per_wear ?? a.price ?? 0;
        const bCpw = b.cost_per_wear ?? b.price ?? 0;
        comparison = aCpw - bCpw;
        break;
    }

    return sortOrder === 'asc' ? comparison : -comparison;
  });

  return filtered;
}

// ============================================================================
// WARDROBE STORE
// ============================================================================

export const useWardrobeStore = create<WardrobeState>((set, get) => ({
  // Initial state
  items: [],
  filteredItems: [],
  selectedItem: null,
  selectedItems: new Set(),
  filters: initialFilters,
  isLoading: false,
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
    set({ isLoading: true, error: null });
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
        isLoading: false,
        filteredItems: applyFiltersAndSort(newItems, state.filters, state.sortBy, state.sortOrder),
      });
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError, isLoading: false });
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
  setFilter: (filter: keyof WardrobeState['filters'], value: any) => {
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
  setSortBy: (sortBy: WardrobeState['sortBy']) => {
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

  // Toggle item favorite
  toggleItemFavorite: async (itemId: string) => {
    try {
      const state = get();
      const updated = await itemsApi.toggleItemFavorite(itemId);
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
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError });
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

export const selectItems = (state: WardrobeState) => state.items;
export const selectFilteredItems = (state: WardrobeState) => state.filteredItems;
export const selectSelectedItem = (state: WardrobeState) => state.selectedItem;
export const selectSelectedItems = (state: WardrobeState) => state.selectedItems;
export const selectFilters = (state: WardrobeState) => state.filters;
export const selectIsLoading = (state: WardrobeState) => state.isLoading;
export const selectError = (state: WardrobeState) => state.error;
export const selectHasMore = (state: WardrobeState) => state.hasMore;

// ============================================================================
// HOOKS
// ============================================================================

/**
 * Hook to get all items
 */
export function useItems(): Item[] {
  return useWardrobeStore(selectItems);
}

/**
 * Hook to get filtered items
 */
export function useFilteredItems(): Item[] {
  return useWardrobeStore(selectFilteredItems);
}

/**
 * Hook to get selected item
 */
export function useSelectedItem(): Item | null {
  return useWardrobeStore(selectSelectedItem);
}

/**
 * Hook to get selected items count
 */
export function useSelectedItemsCount(): number {
  return useWardrobeStore((state) => state.selectedItems.size);
}

/**
 * Hook to check if item is selected
 */
export function useIsItemSelected(itemId: string): boolean {
  return useWardrobeStore((state) => state.selectedItems.has(itemId));
}
