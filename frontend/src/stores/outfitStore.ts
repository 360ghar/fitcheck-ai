/**
 * Outfits store using Zustand
 * Manages outfits, creation state, and UI state for outfits
 */

import { create } from 'zustand';
import { useShallow } from 'zustand/react/shallow';
import type { Outfit, OutfitImage, Style, Season, OutfitFilters as ApiOutfitFilters } from '../types';
import * as outfitsApi from '../api/outfits';
import { generateOutfit, type OutfitItemInput } from '../api/ai';
import { skipToast } from '../api/client';
import { getApiError, RATE_LIMIT_EXCEEDED, type ApiError } from '../lib/errors';
import { withRetry } from '../lib/retry';
import { logger } from '../lib/logger';
import { useUpgradePromptStore } from '../stores/upgradePromptStore';

// ============================================================================
// OUTFIT STATE INTERFACE
// ============================================================================

interface OutfitState {
  // Outfits data
  outfits: Outfit[];
  selectedOutfit: Outfit | null;
  selectedOutfits: Set<string>;

  /**
   * Draft state for the Create Outfit page (`/outfits/new`).
   * There is deliberately no `isCreating` flag any more: creation is a ROUTE, so
   * the URL is what says whether you are creating. A boolean in the store that
   * mirrors the router is a second source of truth waiting to disagree.
   */
  creationItems: Set<string>;
  creationName: string;
  creationDescription: string;
  creationStyle?: Style;
  creationSeason?: Season;
  creationTags: string[];
  creationOccasion: string;

  /**
   * Preview-before-save state.
   *
   * This is the whole redesign in five fields: a generation is produced, held in
   * memory, LOOKED AT, and only then attached to an outfit that is created at
   * that moment. Nothing is persisted until the user approves, and approving
   * costs no further generation because these bytes are what gets uploaded.
   */
  previewStatus: 'idle' | 'processing' | 'ready' | 'failed';
  previewImageDataUrl: string | null;
  previewMeta: { provider: string; model: string; prompt: string } | null;
  previewError: string | null;
  /**
   * Fingerprint of the draft the preview was generated FROM (sorted item ids +
   * style). Compared against the live draft to detect a preview that no longer
   * depicts the current selection, so the UI can say so instead of quietly
   * showing a picture of different clothes.
   */
  previewSourceKey: string | null;

  // Generation state
  isGenerating: boolean;
  generationStatus: 'idle' | 'pending' | 'processing' | 'completed' | 'failed';
  generationId: string | null;
  generatedImageUrl: string | null;

  // Per-outfit generation tracking (for auto-generation on create)
  generatingOutfits: Map<string, {
    status: 'pending' | 'processing' | 'completed' | 'failed';
    error?: string;
  }>;

  // Filters
  filters: {
    style: Style | 'all';
    season: Season | 'all';
    search: string;
    isFavorite: boolean;
  };

  // UI state
  isLoading: boolean;
  /**
   * Detail-pane fetch, deliberately separate from `isLoading`.
   * `isLoading` swaps the whole grid for a skeleton; a deep link to
   * /outfits/:id must not blank the list it is being shown beside.
   */
  isDetailLoading: boolean;
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
  setFilter: <K extends keyof OutfitState['filters']>(filter: K, value: OutfitState['filters'][K]) => void;
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

  // Draft actions
  resetOutfitDraft: () => void;
  setCreationItems: (itemIds: string[]) => void;
  toggleCreationItem: (itemId: string) => void;
  setCreationName: (name: string) => void;
  setCreationDescription: (description: string) => void;
  setCreationStyle: (style?: Style) => void;
  setCreationSeason: (season?: Season) => void;
  setCreationTags: (tags: string[]) => void;
  setCreationOccasion: (occasion: string) => void;

  // Preview-before-save actions
  /** The ONLY metered spend in the create flow. Creates no outfit row. */
  generateOutfitPreview: (promptItems: OutfitItemInput[]) => Promise<void>;
  discardOutfitPreview: () => void;
  /** Creates the outfit, then attaches the already-generated bytes. Free. */
  saveOutfitFromDraft: () => Promise<Outfit>;

  // Generation actions
  startGeneration: (outfitId: string, request?: { pose?: string; variations?: number; lighting?: string; body_profile_id?: string }) => Promise<void>;
  /**
   * Fire-and-forget generation for a newly created outfit (marks it in
   * `generatingOutfits`). `useSourcePhoto` is the upload flow's opt-in: pass
   * true only when this outfit was built from one uploaded photo's extracted
   * items, so the backend can send the original photo as an "as worn"
   * reference. Default false keeps the builder/retry paths unchanged.
   */
  startGenerationForNewOutfit: (outfitId: string, options?: { useSourcePhoto?: boolean }) => void;
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

/**
 * A fresh draft.
 *
 * `creationStyle` / `creationSeason` are SEEDED rather than left undefined: the
 * meta bar's Select shows "casual" / "all-season" as its resting value, and a
 * control that displays a value the payload does not carry is a lie. The old
 * dialog papered over this with a mount effect that wrote the defaults in as a
 * side-effect; the draft owns its own defaults now.
 *
 * Literals rather than an import from `components/outfits/create/constants`:
 * a store must not depend on a component module (ARCHITECTURE.md).
 */
const initialCreationState = {
  creationItems: new Set<string>(),
  creationName: '',
  creationDescription: '',
  creationStyle: 'casual' as Style | undefined,
  creationSeason: 'all-season' as Season | undefined,
  creationTags: [] as string[],
  creationOccasion: '',
};

/** No preview held, nothing spent. */
const initialPreviewState = {
  previewStatus: 'idle' as OutfitState['previewStatus'],
  previewImageDataUrl: null as string | null,
  previewMeta: null as OutfitState['previewMeta'],
  previewError: null as string | null,
  previewSourceKey: null as string | null,
};

/**
 * Fingerprint of the draft a preview depicts.
 *
 * Item ids are SORTED, so re-picking the same pieces in a different order does
 * not falsely invalidate a good render, while adding, removing or restyling
 * anything does. Style is in the key because it is part of the prompt.
 */
function draftPreviewKey(itemIds: Iterable<string>, style?: Style): string {
  return `${[...itemIds].sort().join(',')}|${style || 'casual'}`;
}

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
  selectedOutfit: null,
  selectedOutfits: new Set(),
  isGenerating: false,
  generationStatus: 'idle',
  generationId: null,
  generatedImageUrl: null,
  generatingOutfits: new Map(),
  ...initialCreationState,
  ...initialPreviewState,
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
        // Keep generatingOutfits across refresh so mid-flight auto-gen badges
        // and job pills are not wiped while AI is still running.
      });
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError, isLoading: false });
    }
  },

  // Fetch single outfit by ID
  fetchOutfitById: async (id: string) => {
    // isDetailLoading, not isLoading: see the field comment.
    set({ isDetailLoading: true, error: null });
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
        isDetailLoading: false,
      });
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError, isDetailLoading: false });
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
  setFilter: <K extends keyof OutfitState['filters']>(filter: K, value: OutfitState['filters'][K]) => {
    set({ filters: { ...get().filters, [filter]: value }, page: 1 });
  },

  // Reset filters
  resetFilters: () => {
    set({ filters: initialFilters, page: 1 });
  },

  // Set view mode
  setViewMode: (mode: 'all' | 'favorites' | 'recent') => {
    set({ viewMode: mode, page: 1, filters: { ...get().filters, isFavorite: mode === 'favorites' } });
  },

  // Set sort by
  setSortBy: (sortBy: OutfitState['sortBy']) => {
    set({ sortBy });
  },

  // Set sort order
  setSortOrder: (sortOrder: 'asc' | 'desc') => {
    set({ sortOrder });
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

  /**
   * Clear the draft AND any held preview.
   *
   * Called once when the create route mounts. It resets both halves together on
   * purpose: a preview left over from a previous visit would open the page
   * showing a render of clothes the user has not picked this time.
   */
  resetOutfitDraft: () => {
    set({
      ...initialCreationState,
      // A fresh Set/array per reset — never the module-level instances, which
      // would be shared across every draft and mutated by `toggleCreationItem`.
      creationItems: new Set<string>(),
      creationTags: [],
      ...initialPreviewState,
    });
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

  /**
   * Render a look for the CURRENT draft without creating anything.
   *
   * This is the only metered spend in the create flow, and it is deliberately
   * separated from saving: the old dialog created the outfit first and then
   * fire-and-forgot a generation the user had never seen, so every save cost a
   * render whether or not the result was wanted. Here the bytes are held in
   * memory until approved, and `saveOutfitFromDraft` reuses them.
   */
  generateOutfitPreview: async (promptItems: OutfitItemInput[]) => {
    if (promptItems.length === 0) {
      set({ previewStatus: 'failed', previewError: 'Pick at least one piece first' });
      return;
    }

    const { creationItems, creationStyle } = get();
    // Captured BEFORE the await so a selection changed mid-flight is detected
    // rather than silently attributed to the render that is on its way back.
    const sourceKey = draftPreviewKey(creationItems, creationStyle);

    set({ previewStatus: 'processing', previewError: null });

    // Mirrors the auto-generation options (`startGenerationForNewOutfit`),
    // so what the user approves is what the old auto-generation would have
    // produced. Deliberately NO `useSourcePhoto`: the preview lives in the
    // outfit builder, and the source-photo "as worn" reference is upload-flow
    // only. No `background`: the backend default owns that prompt fragment
    // now. `skipToast`: this flow surfaces its own inline `previewError`, so
    // the global error toast is suppressed — otherwise each withRetry attempt
    // would also toast.
    const aiResult = await withRetry(
      () =>
        generateOutfit(
          promptItems,
          {
            style: creationStyle || 'casual',
            pose: 'standing front',
            lighting: 'studio',
            include_model: true,
            include_user_face: true,
            use_body_profile: true,
          },
          skipToast
        ),
      {
        maxRetries: 3,
        initialDelayMs: 2000,
        backoffFactor: 2,
        onRetry: (attempt, error, delayMs) => {
          logger.info(`Retrying outfit preview, attempt ${attempt}, waiting ${delayMs}ms`, error);
        },
      }
    );

    if (!aiResult.success || !aiResult.data) {
      const previewApiError = getApiError(aiResult.error);
      // The request went through `skipToast`, so the axios interceptor's
      // global handling (including the RATE_LIMIT_EXCEEDED upgrade prompt)
      // never fires. Surface the prompt here for the user's OWN plan limit —
      // the one case a bare inline error string under-serves.
      if (previewApiError.code === RATE_LIMIT_EXCEEDED) {
        useUpgradePromptStore.getState().open('rate_limit', previewApiError.message);
      }
      set({
        previewStatus: 'failed',
        previewError: previewApiError.message || 'Could not render this look',
      });
      return;
    }

    const imageUrl =
      aiResult.data.image_url || `data:image/png;base64,${aiResult.data.image_base64}`;

    if (!imageUrl) {
      set({ previewStatus: 'failed', previewError: 'The render came back empty' });
      return;
    }

    set({
      previewStatus: 'ready',
      previewImageDataUrl: imageUrl,
      previewSourceKey: sourceKey,
      previewError: null,
      previewMeta: {
        provider: aiResult.data.provider,
        model: aiResult.data.model,
        prompt: aiResult.data.prompt,
      },
    });
  },

  discardOutfitPreview: () => {
    set({ ...initialPreviewState });
  },

  /**
   * Create the outfit and attach the already-approved bytes.
   *
   * Costs no generation. If there is no preview the outfit is still created,
   * imageless — the detail pane's "No AI look yet" state and its Generate
   * action are the first-class path for that, and auto-firing a render here
   * would reintroduce exactly the invisible spend this flow removes.
   */
  saveOutfitFromDraft: async () => {
    const state = get();
    const {
      creationItems,
      creationName,
      creationDescription,
      creationStyle,
      creationSeason,
      creationTags,
      creationOccasion,
      previewImageDataUrl,
      previewStatus,
      previewSourceKey,
    } = state;

    if (creationItems.size === 0) {
      const message = 'Please select at least one item';
      set({ error: { message } });
      throw new Error(message);
    }

    if (!creationName.trim()) {
      const message = 'Please enter a name';
      set({ error: { message } });
      throw new Error(message);
    }

    set({ isLoading: true, error: null });

    let outfit: Outfit;
    try {
      outfit = await outfitsApi.createOutfit({
        name: creationName.trim(),
        description: creationDescription,
        item_ids: Array.from(creationItems),
        style: creationStyle,
        season: creationSeason,
        tags: creationTags,
        occasion: creationOccasion,
        is_favorite: false,
      }, skipToast);
    } catch (error) {
      set({ error: getApiError(error), isLoading: false });
      throw error;
    }

    set((current) => ({ outfits: [outfit, ...current.outfits], isLoading: false }));

    // Nothing approved — the outfit exists without a look, on purpose. A
    // preview whose source key no longer matches the live draft must also be
    // treated as nothing approved: attaching it would ship a photo of
    // different clothes than the outfit's item_ids.
    const previewMatchesDraft =
      previewSourceKey !== null &&
      previewSourceKey === draftPreviewKey(creationItems, creationStyle);
    if (
      previewStatus !== 'ready' ||
      !previewImageDataUrl ||
      !previewMatchesDraft
    ) {
      set({ ...initialCreationState, creationItems: new Set<string>(), ...initialPreviewState });
      return outfit;
    }

    try {
      const imageFile = await dataUrlToFile(
        previewImageDataUrl,
        `outfit-${outfit.id}-preview.png`
      );

      const uploaded = await withRetry(
        () =>
          outfitsApi.uploadOutfitImage(outfit.id, imageFile, {
            isPrimary: true,
            pose: 'front',
            lighting: 'studio',
          }),
        { maxRetries: 3, initialDelayMs: 1000, backoffFactor: 2 }
      );

      if (!uploaded.success || !uploaded.data) {
        throw uploaded.error || new Error('Upload failed after retries');
      }

      const image = uploaded.data;
      set((current) => ({
        outfits: current.outfits.map((o) =>
          o.id === outfit.id
            ? {
                ...o,
                images: [
                  ...(o.images || []).map((img) => ({
                    ...img,
                    is_primary: image.is_primary ? false : img.is_primary,
                  })),
                  image,
                ],
              }
            : o
        ),
      }));
    } catch (error) {
      // The outfit is KEPT. Losing a saved outfit because its picture failed to
      // upload would be the worse outcome, and the look is regenerable from the
      // detail pane.
      logger.error('Outfit saved but preview upload failed', error);
      set({
        error: {
          message: 'Outfit saved, but the look could not be attached. Generate it again from the outfit.',
        },
      });
    }

    set({ ...initialCreationState, creationItems: new Set<string>(), ...initialPreviewState });
    return outfit;
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
        // Client still does the heavy AI call next — treat as processing
        generationStatus: 'processing',
      });

      // Do not poll generation status in parallel: this path generates and
      // uploads client-side, and concurrent polling can flip isGenerating/status
      // to completed/failed before the upload finishes.

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
      const promptItems: Parameters<typeof generateOutfit>[0] = [];
      for (const it of availableItems) {
        if (itemIds.has(it.id)) {
          // item_id lets the backend fetch this item's own image and send it to
          // the model as a garment reference. it.image_url stays unused on
          // purpose: the id is the contract, the backend resolves the image.
          promptItems.push({ item_id: it.id, name: it.name, category: it.category, colors: it.colors });
        }
      }

      if (promptItems.length === 0) {
        throw new Error('No outfit items available for generation');
      }

      // Generate outfit using backend AI service with retry
      set({ generationStatus: 'processing' });
      const aiResult = await withRetry(
        () =>
          generateOutfit(promptItems, {
            style: outfit.style || 'casual',
            pose: mapPoseToPrompt(options.pose),
            lighting: options.lighting || 'studio',
            include_model: true,
            // Match the auto-generation options (`startGenerationForNewOutfit`)
            // so a Regenerate from the detail pane produces the same style of
            // look (avatar face + body profile) as the original create/upload
            // render, instead of a faceless generic model.
            include_user_face: true,
            use_body_profile: true,
          }),
        {
          maxRetries: 3,
          initialDelayMs: 2000, // AI operations need longer initial delay
          backoffFactor: 2,
          onRetry: (attempt, error, delayMs) => {
            logger.info(`Retrying outfit generation, attempt ${attempt}, waiting ${delayMs}ms`, error);
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

      // A successful manual generation must also clear this outfit's
      // fire-and-forget map entry: without this, a look that auto-gen had
      // marked `failed` stays a "Generation failed" card (and pane notice)
      // forever, even after the user successfully regenerates from the pane.
      const successMap = new Map(current.generatingOutfits);
      successMap.delete(outfitId);

      set({
        outfits: updatedOutfits,
        selectedOutfit:
          current.selectedOutfit?.id === outfitId
            ? { ...current.selectedOutfit, images: [...(current.selectedOutfit.images || []).map((img) => ({ ...img, is_primary: uploaded.is_primary ? false : img.is_primary })), uploaded] }
            : current.selectedOutfit,
        generatedImageUrl: uploaded.image_url,
        generationStatus: 'completed',
        isGenerating: false,
        generatingOutfits: successMap,
      });
      try {
        const { useJobUiStore } = await import('@/stores/jobUiStore');
        useJobUiStore.getState().clearJob('outfit-generate');
      } catch {
        logger.error('Failed to clear outfit-generate job from jobUiStore');
      }
    } catch (error) {
      const apiError = getApiError(error);
      // Mirror the failure into the map so the grid card (and the pane notice
      // built from `generatingOutfits`) shows the retry state consistently.
      const failedMap = new Map(get().generatingOutfits);
      failedMap.set(outfitId, { status: 'failed', error: apiError.message });
      set({ error: apiError, isGenerating: false, generationStatus: 'failed', generatingOutfits: failedMap });
      try {
        const { useJobUiStore } = await import('@/stores/jobUiStore');
        useJobUiStore.getState().clearJob('outfit-generate');
      } catch {
        logger.error('Failed to clear outfit-generate job from jobUiStore');
      }
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

  // Start generation for newly created outfit (fire-and-forget, updates generatingOutfits map)
  startGenerationForNewOutfit: (outfitId: string, options?: { useSourcePhoto?: boolean }) => {
    // Run async generation in background
    (async () => {
      try {
        // Update status to processing
        const state = get();
        const newMap = new Map(state.generatingOutfits);
        newMap.set(outfitId, { status: 'processing' });
        set({ generatingOutfits: newMap });

        // Surface pill even if OutfitsPage effect has not run yet
        try {
          const outfit = state.outfits.find((o) => o.id === outfitId);
          const { useJobUiStore } = await import('@/stores/jobUiStore');
          useJobUiStore.getState().setJob({
            id: 'outfit-generate',
            label: outfit?.name
              ? `Generating look · ${outfit.name}`
              : 'Generating outfit look…',
            isActive: true,
            href: '/outfits',
          });
        } catch {
          logger.error('Failed to set outfit-generate job from jobUiStore');
        }

        // Get outfit data
        let outfit = state.outfits.find((o) => o.id === outfitId);
        if (!outfit) {
          outfit = await outfitsApi.getOutfit(outfitId);
        }

        // Get items for generation
        const itemIds = new Set(outfit.item_ids);
        const availableItems = await outfitsApi.getAvailableItems();
        const promptItems: Parameters<typeof generateOutfit>[0] = [];
        for (const it of availableItems) {
          if (itemIds.has(it.id)) {
            // See startGeneration: item_id is how the backend resolves this
            // item's image into a garment reference for the model.
            promptItems.push({ item_id: it.id, name: it.name, category: it.category, colors: it.colors });
          }
        }

        if (promptItems.length === 0) {
          throw new Error('No outfit items available for generation');
        }

        // Generate outfit using backend AI service with retry
        const aiResult = await withRetry(
          () =>
            generateOutfit(promptItems, {
              style: outfit.style || 'casual',
              pose: 'standing front',
              lighting: 'studio',
              include_model: true,
              include_user_face: true,
              use_body_profile: true,
              // Upload flow only: the outfit came from one uploaded photo, so
              // the backend sends that photo as an "as worn" reference.
              useSourcePhoto: options?.useSourcePhoto ?? false,
            }),
          {
            maxRetries: 3,
            initialDelayMs: 2000,
            backoffFactor: 2,
            onRetry: (attempt, error, delayMs) => {
              logger.info(`Retrying auto outfit generation, attempt ${attempt}, waiting ${delayMs}ms`, error);
            },
          }
        );

        if (!aiResult.success || !aiResult.data) {
          throw aiResult.error || new Error('AI image generation failed after retries');
        }

        // Get the image URL
        const imageUrl = aiResult.data.image_url || `data:image/png;base64,${aiResult.data.image_base64}`;
        if (!imageUrl) {
          throw new Error('AI image generation returned no image');
        }

        // Convert to file and upload
        const imageFile = await dataUrlToFile(
          imageUrl,
          `outfit-${outfitId}-${Date.now()}.png`
        );

        const uploaded = await outfitsApi.uploadOutfitImage(outfitId, imageFile, {
          isPrimary: true,
          pose: 'front',
        });

        // Update outfits with new image and remove from generatingOutfits
        const current = get();
        const updatedOutfits = current.outfits.map((o) => {
          if (o.id !== outfitId) return o;
          const images: OutfitImage[] = [...(o.images || []), uploaded];
          return { ...o, images };
        });

        const finalMap = new Map(current.generatingOutfits);
        finalMap.delete(outfitId);

        set({
          outfits: updatedOutfits,
          generatingOutfits: finalMap,
        });

        // Clear pill if OutfitsPage is not mounted (user left after create).
        try {
          const { useJobUiStore } = await import('@/stores/jobUiStore');
          useJobUiStore.getState().clearJob('outfit-generate');
        } catch {
          logger.error('Failed to clear outfit-generate job from jobUiStore');
        }

      } catch (error) {
        logger.error('Auto generation failed for outfit', outfitId, error);
        // Mark as failed in the map
        const current = get();
        const failedMap = new Map(current.generatingOutfits);
        failedMap.set(outfitId, {
          status: 'failed',
          error: getApiError(error).message || 'Generation failed',
        });
        set({ generatingOutfits: failedMap });
        try {
          const { useJobUiStore } = await import('@/stores/jobUiStore');
          useJobUiStore.getState().clearJob('outfit-generate');
        } catch {
          logger.error('Failed to clear outfit-generate job from jobUiStore');
        }
      }
    })();
  },

  // Clear error
  clearError: () => set({ error: null }),
}));

// ============================================================================
// SELECTORS
// ============================================================================

export const selectOutfits = (state: OutfitState) => state.outfits;
export const selectFilteredOutfits = (state: OutfitState) =>
  applyFiltersAndSort(state.outfits, state.filters, state.sortBy, state.sortOrder);
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
  return useOutfitStore(useShallow(selectFilteredOutfits));
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
  selectedItems: Set<string>;
  name: string;
  description: string;
  style?: Style;
  season?: Season;
  tags: string[];
  occasion: string;
} {
  return useOutfitStore(
    useShallow((state) => ({
      selectedItems: state.creationItems,
      name: state.creationName,
      description: state.creationDescription,
      style: state.creationStyle,
      season: state.creationSeason,
      tags: state.creationTags,
      occasion: state.creationOccasion,
    }))
  );
}
