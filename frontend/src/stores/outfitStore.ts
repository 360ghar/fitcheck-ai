/**
 * Outfits store using Zustand
 * Manages outfits, creation state, and UI state for outfits
 */

import { create } from 'zustand';
import type { Outfit, OutfitImage, Style, Season, OutfitFilters as ApiOutfitFilters } from '../types';
import * as outfitsApi from '../api/outfits';
import { generateOutfit } from '../api/ai';
import { getApiError, ApiError } from '../api/client';
import { withRetry } from '../lib/retry';

// ============================================================================
// OUTFIT STATE INTERFACE
// ============================================================================

interface OutfitState {
  // Outfits data
  outfits: Outfit[];
  filteredOutfits: Outfit[];
  selectedOutfit: Outfit | null;
  selectedOutfits: Set<string>;

  // Creation state
  isCreating: boolean;
  creationItems: Set<string>;
  creationName: string;
  creationDescription: string;
  creationStyle?: Style;
  creationSeason?: Season;
  creationTags: string[];
  creationOccasion: string;

  // Generation state
  isGenerating: boolean;
  generationStatus: 'idle' | 'pending' | 'processing' | 'completed' | 'failed';
  generationId: string | null;
  generatedImageUrl: string | null;

  // Filters
  filters: {
    style: Style | 'all';
    season: Season | 'all';
    search: string;
    isFavorite: boolean;
  };

  // UI state
  isLoading: boolean;
  isGridView: boolean;
  viewMode: 'all' | 'favorites' | 'recent';
  sortBy: 'name' | 'date_added' | 'times_worn';
  sortOrder: 'asc' | 'desc';

  // Error state
  error: ApiError | null;

  // Pagination
  page: number;
  pageSize: number;
  totalOutfits: number;
  hasMore: boolean;

  // Actions
  fetchOutfits: (refresh?: boolean) => Promise<void>;
  fetchOutfitById: (id: string) => Promise<void>;
  setSelectedOutfit: (outfit: Outfit | null) => void;
  toggleOutfitSelected: (outfitId: string) => void;
  clearSelectedOutfits: () => void;
  setFilter: (filter: keyof OutfitState['filters'], value: any) => void;
  resetFilters: () => void;
  setViewMode: (mode: 'all' | 'favorites' | 'recent') => void;
  setSortBy: (sortBy: OutfitState['sortBy']) => void;
  setSortOrder: (order: 'asc' | 'desc') => void;
  setGridView: (isGrid: boolean) => void;
  toggleOutfitFavorite: (outfitId: string) => Promise<void>;
  markOutfitAsWorn: (outfitId: string) => Promise<void>;
  duplicateOutfit: (outfitId: string) => Promise<Outfit>;
  deleteOutfit: (outfitId: string) => Promise<void>;
  deleteSelectedOutfits: () => Promise<void>;
  setPage: (page: number) => void;

  // Creation actions
  startCreating: () => void;
  cancelCreating: () => void;
  setCreationItems: (itemIds: string[]) => void;
  toggleCreationItem: (itemId: string) => void;
  setCreationName: (name: string) => void;
  setCreationDescription: (description: string) => void;
  setCreationStyle: (style?: Style) => void;
  setCreationSeason: (season?: Season) => void;
  setCreationTags: (tags: string[]) => void;
  setCreationOccasion: (occasion: string) => void;
  createOutfit: () => Promise<Outfit>;

  // Generation actions
  startGeneration: (outfitId: string, request?: { pose?: string; variations?: number; lighting?: string; body_profile_id?: string }) => Promise<void>;
  checkGenerationStatus: () => Promise<void>;
  resetGeneration: () => void;
  clearError: () => void;
}

// ============================================================================
// INITIAL FILTERS STATE
// ============================================================================

const initialFilters: OutfitState['filters'] = {
  style: 'all',
  season: 'all',
  search: '',
  isFavorite: false,
};

const initialCreationState = {
  creationItems: new Set<string>(),
  creationName: '',
  creationDescription: '',
  creationStyle: undefined as Style | undefined,
  creationSeason: undefined as Season | undefined,
  creationTags: [],
  creationOccasion: '',
};

// ============================================================================
// HELPER FUNCTION
// ============================================================================

function applyFiltersAndSort(
  outfits: Outfit[],
  filters: OutfitState['filters'],
  sortBy: OutfitState['sortBy'],
  sortOrder: OutfitState['sortOrder']
): Outfit[] {
  let filtered = [...outfits];

  // Apply style filter
  if (filters.style !== 'all') {
    filtered = filtered.filter((outfit) => outfit.style === filters.style);
  }

  // Apply season filter
  if (filters.season !== 'all') {
    filtered = filtered.filter((outfit) => outfit.season === filters.season);
  }

  // Apply favorite filter
  if (filters.isFavorite) {
    filtered = filtered.filter((outfit) => outfit.is_favorite);
  }

  // Apply search filter
  if (filters.search) {
    const searchLower = filters.search.toLowerCase();
    filtered = filtered.filter(
      (outfit) =>
        outfit.name.toLowerCase().includes(searchLower) ||
        outfit.description?.toLowerCase().includes(searchLower) ||
        outfit.tags.some((tag) => tag.toLowerCase().includes(searchLower)) ||
        outfit.occasion?.toLowerCase().includes(searchLower)
    );
  }

  // Apply sorting
  filtered.sort((a, b) => {
    let comparison = 0;

    switch (sortBy) {
      case 'name':
        comparison = a.name.localeCompare(b.name);
        break;
      case 'date_added':
        comparison = new Date(a.created_at).getTime() - new Date(b.created_at).getTime();
        break;
      case 'times_worn':
        comparison = a.worn_count - b.worn_count;
        break;
    }

    return sortOrder === 'asc' ? comparison : -comparison;
  });

  return filtered;
}

async function dataUrlToFile(dataUrl: string, filename: string): Promise<File> {
  const resp = await fetch(dataUrl);
  const blob = await resp.blob();
  return new File([blob], filename, { type: blob.type || 'image/png' });
}

function mapPoseToPrompt(pose?: string): string {
  const p = (pose || '').toLowerCase();
  if (p.includes('side')) return 'standing side';
  if (p.includes('back')) return 'standing back';
  return 'standing front';
}

// ============================================================================
// OUTFIT STORE
// ============================================================================

export const useOutfitStore = create<OutfitState>((set, get) => ({
  // Initial state
  outfits: [],
  filteredOutfits: [],
  selectedOutfit: null,
  selectedOutfits: new Set(),
  isCreating: false,
  isGenerating: false,
  generationStatus: 'idle',
  generationId: null,
  generatedImageUrl: null,
  ...initialCreationState,
  filters: initialFilters,
  isLoading: false,
  isGridView: true,
  viewMode: 'all',
  sortBy: 'date_added',
  sortOrder: 'desc',
  error: null,
  page: 1,
  pageSize: 24,
  totalOutfits: 0,
  hasMore: true,

  // Fetch outfits
  fetchOutfits: async (refresh = false) => {
    const state = get();
    const { filters, page, pageSize, outfits } = state;

    const newPage = refresh ? 1 : page;

    set({ isLoading: true, error: null });

    try {
      const apiFilters: ApiOutfitFilters = {
        page: newPage,
        page_size: pageSize,
      };

      if (filters.style !== 'all') apiFilters.style = filters.style;
      if (filters.season !== 'all') apiFilters.season = filters.season;
      if (filters.search) apiFilters.search = filters.search;
      if (filters.isFavorite) apiFilters.is_favorite = true;

      const response = await outfitsApi.getOutfits(apiFilters);

      set({
        outfits: refresh || newPage === 1 ? response.outfits : [...outfits, ...response.outfits],
        totalOutfits: response.total,
        hasMore: response.has_next,
        page: newPage,
        isLoading: false,
      });

      // Apply filters and sort after outfits are set
      const currentState = get();
      set({
        filteredOutfits: applyFiltersAndSort(
          currentState.outfits,
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

  // Fetch single outfit by ID
  fetchOutfitById: async (id: string) => {
    set({ isLoading: true, error: null });
    try {
      const outfit = await outfitsApi.getOutfit(id);
      const state = get();
      const index = state.outfits.findIndex((o) => o.id === id);
      const newOutfits = [...state.outfits];
      if (index !== -1) {
        newOutfits[index] = outfit;
      } else {
        newOutfits.push(outfit);
      }

      set({
        outfits: newOutfits,
        selectedOutfit: outfit,
        isLoading: false,
        filteredOutfits: applyFiltersAndSort(newOutfits, state.filters, state.sortBy, state.sortOrder),
      });
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError, isLoading: false });
    }
  },

  // Set selected outfit
  setSelectedOutfit: (outfit: Outfit | null) => {
    set({ selectedOutfit: outfit });
  },

  // Toggle outfit selection
  toggleOutfitSelected: (outfitId: string) => {
    const state = get();
    const newSelected = new Set(state.selectedOutfits);
    if (newSelected.has(outfitId)) {
      newSelected.delete(outfitId);
    } else {
      newSelected.add(outfitId);
    }
    set({ selectedOutfits: newSelected });
  },

  // Clear selected outfits
  clearSelectedOutfits: () => {
    set({ selectedOutfits: new Set() });
  },

  // Set filter
  setFilter: (filter: keyof OutfitState['filters'], value: any) => {
    set({ filters: { ...get().filters, [filter]: value }, page: 1 });
    const state = get();
    set({
      filteredOutfits: applyFiltersAndSort(state.outfits, state.filters, state.sortBy, state.sortOrder),
    });
  },

  // Reset filters
  resetFilters: () => {
    set({ filters: initialFilters, page: 1 });
    const state = get();
    set({
      filteredOutfits: applyFiltersAndSort(state.outfits, state.filters, state.sortBy, state.sortOrder),
    });
  },

  // Set view mode
  setViewMode: (mode: 'all' | 'favorites' | 'recent') => {
    set({ viewMode: mode, page: 1, filters: { ...get().filters, isFavorite: mode === 'favorites' } });
  },

  // Set sort by
  setSortBy: (sortBy: OutfitState['sortBy']) => {
    set({ sortBy });
    const state = get();
    set({
      filteredOutfits: applyFiltersAndSort(state.outfits, state.filters, state.sortBy, state.sortOrder),
    });
  },

  // Set sort order
  setSortOrder: (sortOrder: 'asc' | 'desc') => {
    set({ sortOrder });
    const state = get();
    set({
      filteredOutfits: applyFiltersAndSort(state.outfits, state.filters, state.sortBy, state.sortOrder),
    });
  },

  // Set grid view
  setGridView: (isGrid: boolean) => {
    set({ isGridView: isGrid });
  },

  // Toggle outfit favorite
  toggleOutfitFavorite: async (outfitId: string) => {
    try {
      const state = get();
      const updated = await outfitsApi.toggleOutfitFavorite(outfitId);
      const newOutfits = state.outfits.map((outfit) =>
        outfit.id === outfitId ? { ...outfit, is_favorite: updated.is_favorite } : outfit
      );
      set({
        outfits: newOutfits,
        selectedOutfit:
          state.selectedOutfit?.id === outfitId
            ? { ...state.selectedOutfit, is_favorite: updated.is_favorite }
            : state.selectedOutfit,
        filteredOutfits: applyFiltersAndSort(newOutfits, state.filters, state.sortBy, state.sortOrder),
      });
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError });
    }
  },

  // Mark outfit as worn
  markOutfitAsWorn: async (outfitId: string) => {
    try {
      const updated = await outfitsApi.markOutfitAsWorn(outfitId);
      const state = get();
      const newOutfits = state.outfits.map((o) =>
        o.id === outfitId
          ? { ...o, worn_count: updated.worn_count, last_worn_at: updated.last_worn_at }
          : o
      );

      set({
        outfits: newOutfits,
        filteredOutfits: applyFiltersAndSort(newOutfits, state.filters, state.sortBy, state.sortOrder),
        selectedOutfit:
          state.selectedOutfit?.id === outfitId
            ? { ...state.selectedOutfit, worn_count: updated.worn_count, last_worn_at: updated.last_worn_at }
            : state.selectedOutfit,
      });
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError });
      throw error;
    }
  },

  // Duplicate outfit
  duplicateOutfit: async (outfitId: string) => {
    try {
      const duplicated = await outfitsApi.duplicateOutfit(outfitId);
      const state = get();
      const newOutfits = [duplicated, ...state.outfits];
      set({
        outfits: newOutfits,
        filteredOutfits: applyFiltersAndSort(newOutfits, state.filters, state.sortBy, state.sortOrder),
      });
      return duplicated;
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError });
      throw error;
    }
  },

  // Delete outfit
  deleteOutfit: async (outfitId: string) => {
    try {
      await outfitsApi.deleteOutfit(outfitId);
      const state = get();
      const newOutfits = state.outfits.filter((o) => o.id !== outfitId);
      const newSelected = new Set(state.selectedOutfits);
      newSelected.delete(outfitId);

      set({
        outfits: newOutfits,
        filteredOutfits: applyFiltersAndSort(newOutfits, state.filters, state.sortBy, state.sortOrder),
        selectedOutfit: state.selectedOutfit?.id === outfitId ? null : state.selectedOutfit,
        selectedOutfits: newSelected,
      });
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError });
      throw error;
    }
  },

  // Delete selected outfits
  deleteSelectedOutfits: async () => {
    const state = get();
    const { selectedOutfits } = state;
    if (selectedOutfits.size === 0) return;

    try {
      await outfitsApi.batchDeleteOutfits(Array.from(selectedOutfits));
      const newOutfits = state.outfits.filter((o) => !selectedOutfits.has(o.id));
      set({
        outfits: newOutfits,
        filteredOutfits: applyFiltersAndSort(newOutfits, state.filters, state.sortBy, state.sortOrder),
        selectedOutfits: new Set(),
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

  // Start creating outfit
  startCreating: () => {
    set({
      isCreating: true,
      creationItems: new Set(),
      creationName: '',
      creationDescription: '',
      creationStyle: undefined,
      creationSeason: undefined,
      creationTags: [],
      creationOccasion: '',
    });
  },

  // Cancel creating outfit
  cancelCreating: () => {
    set({ isCreating: false });
  },

  // Set creation items
  setCreationItems: (itemIds: string[]) => {
    set({ creationItems: new Set(itemIds) });
  },

  // Toggle creation item
  toggleCreationItem: (itemId: string) => {
    const state = get();
    const newItems = new Set(state.creationItems);
    if (newItems.has(itemId)) {
      newItems.delete(itemId);
    } else {
      newItems.add(itemId);
    }
    set({ creationItems: newItems });
  },

  // Set creation name
  setCreationName: (name: string) => {
    set({ creationName: name });
  },

  // Set creation description
  setCreationDescription: (description: string) => {
    set({ creationDescription: description });
  },

  // Set creation style
  setCreationStyle: (style?: Style) => {
    set({ creationStyle: style });
  },

  // Set creation season
  setCreationSeason: (season?: Season) => {
    set({ creationSeason: season });
  },

  // Set creation tags
  setCreationTags: (tags: string[]) => {
    set({ creationTags: tags });
  },

  // Set creation occasion
  setCreationOccasion: (occasion: string) => {
    set({ creationOccasion: occasion });
  },

  // Create outfit
  createOutfit: async () => {
    const state = get();
    const { creationItems, creationName, creationDescription, creationStyle, creationSeason, creationTags, creationOccasion } = state;

    if (creationItems.size === 0) {
      set({ error: { message: 'Please select at least one item' } });
      throw new Error('Please select at least one item');
    }

    if (!creationName) {
      set({ error: { message: 'Please enter a name' } });
      throw new Error('Please enter a name');
    }

    set({ isLoading: true, error: null });

    try {
      const outfit = await outfitsApi.createOutfit({
        name: creationName,
        description: creationDescription,
        item_ids: Array.from(creationItems),
        style: creationStyle,
        season: creationSeason,
        tags: creationTags,
        occasion: creationOccasion,
        is_favorite: false,
      });

      const currentState = get();
      const newOutfits = [outfit, ...currentState.outfits];
      set({
        outfits: newOutfits,
        filteredOutfits: applyFiltersAndSort(newOutfits, currentState.filters, currentState.sortBy, currentState.sortOrder),
        isCreating: false,
        isLoading: false,
        creationItems: new Set(),
        creationName: '',
        creationDescription: '',
        creationStyle: undefined,
        creationSeason: undefined,
        creationTags: [],
        creationOccasion: '',
      });

      return outfit;
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError, isLoading: false });
      throw error;
    }
  },

  // Start AI generation
  startGeneration: async (
    outfitId: string,
    options: { pose?: string; variations?: number; lighting?: string; body_profile_id?: string } = {}
  ) => {
    set({ isGenerating: true, generationStatus: 'pending', error: null });

    try {
      const response = await outfitsApi.generateOutfitVisualization(outfitId, options);

      set({
        generationId: response.generation_id,
        generationStatus:
          response.status === 'pending' ||
          response.status === 'processing' ||
          response.status === 'completed' ||
          response.status === 'failed'
            ? response.status
            : 'processing',
      });

      // Poll for status (generation completes when image is uploaded to backend)
      get().checkGenerationStatus();

      // Generate outfit via backend AI service, then upload to backend to mark completion.
      const state = get();
      let outfit =
        state.outfits.find((o) => o.id === outfitId) ||
        (state.selectedOutfit?.id === outfitId ? state.selectedOutfit : null);

      if (!outfit) {
        outfit = await outfitsApi.getOutfit(outfitId);
      }

      const itemIds = new Set(outfit.item_ids);
      const availableItems = await outfitsApi.getAvailableItems();
      const promptItems = availableItems
        .filter((it) => itemIds.has(it.id))
        .map((it) => ({
          name: it.name,
          category: it.category,
          colors: it.colors,
          brand: it.brand,
          material: it.material,
          pattern: it.pattern,
        }));

      if (promptItems.length === 0) {
        throw new Error('No outfit items available for generation');
      }

      // Generate outfit using backend AI service with retry
      const aiResult = await withRetry(
        () =>
          generateOutfit(promptItems, {
            style: outfit.style || 'casual',
            background: 'studio white',
            pose: mapPoseToPrompt(options.pose),
            lighting: options.lighting || 'studio',
            include_model: true,
          }),
        {
          maxRetries: 3,
          initialDelayMs: 2000, // AI operations need longer initial delay
          backoffFactor: 2,
          onRetry: (attempt, error, delayMs) => {
            console.log(`Retrying outfit generation, attempt ${attempt}, waiting ${delayMs}ms`, error);
          },
        }
      );

      if (!aiResult.success || !aiResult.data) {
        throw aiResult.error || new Error('AI image generation failed after retries');
      }

      // Get the image URL - either direct URL or convert base64 to data URL
      const imageUrl = aiResult.data.image_url || `data:image/png;base64,${aiResult.data.image_base64}`;

      if (!imageUrl) {
        throw new Error('AI image generation returned no image');
      }

      const imageFile = await dataUrlToFile(
        imageUrl,
        `outfit-${outfitId}-${Date.now()}.png`
      );

      const uploaded = await outfitsApi.uploadOutfitImage(outfitId, imageFile, {
        isPrimary: true,
        pose: options.pose || 'front',
        lighting: options.lighting,
        body_profile_id: options.body_profile_id,
        generation_id: response.generation_id,
      });

      // Update local outfits list with the new image
      const current = get();
      const updatedOutfits = current.outfits.map((o) => {
        if (o.id !== outfitId) return o;

        const existingImages = (o.images || []).map((img) => ({
          ...img,
          is_primary: uploaded.is_primary ? false : img.is_primary,
        }));

        const images: OutfitImage[] = [...existingImages, uploaded];
        return { ...o, images };
      });

      set({
        outfits: updatedOutfits,
        filteredOutfits: applyFiltersAndSort(
          updatedOutfits,
          current.filters,
          current.sortBy,
          current.sortOrder
        ),
        selectedOutfit:
          current.selectedOutfit?.id === outfitId
            ? { ...current.selectedOutfit, images: [...(current.selectedOutfit.images || []).map((img) => ({ ...img, is_primary: uploaded.is_primary ? false : img.is_primary })), uploaded] }
            : current.selectedOutfit,
        generatedImageUrl: uploaded.image_url,
        generationStatus: 'completed',
        isGenerating: false,
      });
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError, isGenerating: false, generationStatus: 'failed' });
    }
  },

  // Check generation status
  checkGenerationStatus: async () => {
    const { generationId } = get();

    if (!generationId) return;

    try {
      const status = await outfitsApi.getGenerationStatus(generationId);

      set({
        generationStatus:
          status.status === 'pending' ||
          status.status === 'processing' ||
          status.status === 'completed' ||
          status.status === 'failed'
            ? status.status
            : 'processing',
      });

      if (status.status === 'completed') {
        set({
          generatedImageUrl: status.images?.[0] || null,
          isGenerating: false,
        });
      } else if (status.status === 'failed') {
        set({
          error: { message: status.error || 'Generation failed' },
          isGenerating: false,
        });
      } else {
        // Continue polling
        setTimeout(() => get().checkGenerationStatus(), 2000);
      }
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError, isGenerating: false, generationStatus: 'failed' });
    }
  },

  // Reset generation state
  resetGeneration: () => {
    set({
      generationStatus: 'idle',
      generationId: null,
      generatedImageUrl: null,
      isGenerating: false,
    });
  },

  // Clear error
  clearError: () => set({ error: null }),
}));

// ============================================================================
// SELECTORS
// ============================================================================

export const selectOutfits = (state: OutfitState) => state.outfits;
export const selectFilteredOutfits = (state: OutfitState) => state.filteredOutfits;
export const selectSelectedOutfit = (state: OutfitState) => state.selectedOutfit;

// ============================================================================
// HOOKS
// ============================================================================

/**
 * Hook to get all outfits
 */
export function useOutfits(): Outfit[] {
  return useOutfitStore(selectOutfits);
}

/**
 * Hook to get filtered outfits
 */
export function useFilteredOutfits(): Outfit[] {
  return useOutfitStore(selectFilteredOutfits);
}

/**
 * Hook to get selected outfit
 */
export function useSelectedOutfit(): Outfit | null {
  return useOutfitStore(selectSelectedOutfit);
}

/**
 * Hook to check if outfit is selected
 */
export function useIsOutfitSelected(outfitId: string): boolean {
  return useOutfitStore((state) => state.selectedOutfits.has(outfitId));
}

/**
 * Hook to get creation state
 */
export function useOutfitCreation(): {
  isCreating: boolean;
  selectedItems: Set<string>;
  name: string;
  description: string;
  style?: Style;
  season?: Season;
  tags: string[];
  occasion: string;
} {
  return useOutfitStore((state) => ({
    isCreating: state.isCreating,
    selectedItems: state.creationItems,
    name: state.creationName,
    description: state.creationDescription,
    style: state.creationStyle,
    season: state.creationSeason,
    tags: state.creationTags,
    occasion: state.creationOccasion,
  }));
}
