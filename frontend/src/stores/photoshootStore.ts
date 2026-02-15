/**
 * Zustand store for Photoshoot feature
 */

import { create } from 'zustand';
import {
  generatePhotoshoot,
  getPhotoshootUsage,
  PhotoshootUsage,
  PhotoshootResult,
  PhotoshootUseCase,
  GeneratedImage,
} from '@/api/photoshoot';
import { getApiError } from '@/api/client';

// Types
export type PhotoshootStep = 'upload' | 'configure' | 'generating' | 'results';

interface PhotoshootState {
  // Step state
  currentStep: PhotoshootStep;

  // Upload state
  photos: File[];

  // Configuration state
  useCase: PhotoshootUseCase;
  customPrompt: string;
  numImages: number;

  // Usage state
  usage: PhotoshootUsage | null;
  isLoadingUsage: boolean;

  // Generation state
  isGenerating: boolean;
  progress: number;
  statusMessage: string;

  // Results state
  sessionId: string;
  generatedImages: GeneratedImage[];
  failedIndices: number[];
  failedCount: number;
  partialSuccess: boolean;
  retryingFailedIndex: number | null;

  // Error state
  error: string | null;

  // Actions
  setStep: (step: PhotoshootStep) => void;
  addPhotos: (files: File[]) => void;
  removePhoto: (index: number) => void;
  setUseCase: (useCase: PhotoshootUseCase) => void;
  setCustomPrompt: (prompt: string) => void;
  setNumImages: (count: number) => void;
  fetchUsage: () => Promise<void>;
  generate: () => Promise<PhotoshootResult | null>;
  retryFailedSlot: (index: number) => Promise<void>;
  reset: () => void;
}

const initialState = {
  currentStep: 'upload' as PhotoshootStep,
  photos: [] as File[],
  useCase: 'linkedin' as PhotoshootUseCase,
  customPrompt: '',
  numImages: 10,
  usage: null,
  isLoadingUsage: false,
  isGenerating: false,
  progress: 0,
  statusMessage: '',
  sessionId: '',
  generatedImages: [],
  failedIndices: [],
  failedCount: 0,
  partialSuccess: false,
  retryingFailedIndex: null,
  error: null,
};

export const usePhotoshootStore = create<PhotoshootState>()((set, get) => ({
  ...initialState,

  setStep: (step) => set({ currentStep: step }),

  addPhotos: (files) => {
    const current = get().photos;
    const maxPhotos = 4;
    const newPhotos = [...current, ...files].slice(0, maxPhotos);
    set({ photos: newPhotos, error: null });
  },

  removePhoto: (index) => {
    const current = get().photos;
    set({ photos: current.filter((_, i) => i !== index) });
  },

  setUseCase: (useCase) => {
    set({ useCase });
    if (useCase !== 'custom') {
      set({ customPrompt: '' });
    }
  },

  setCustomPrompt: (prompt) => set({ customPrompt: prompt }),

  setNumImages: (count) => {
    const remaining = get().usage?.remaining ?? 10;
    const maxImages = Math.min(10, remaining);
    set({ numImages: Math.max(1, Math.min(count, maxImages)) });
  },

  fetchUsage: async () => {
    set({ isLoadingUsage: true });
    try {
      const usage = await getPhotoshootUsage();
      set({ usage, isLoadingUsage: false });

      // Adjust numImages if needed
      const { numImages } = get();
      if (numImages > usage.remaining) {
        set({ numImages: Math.max(1, Math.min(10, usage.remaining)) });
      }
    } catch (error) {
      // Log the error for debugging, but don't block the user
      console.warn('Failed to fetch photoshoot usage, using defaults:', error);
      set({ isLoadingUsage: false });
      // Default to free limits
      set({ usage: { used_today: 0, limit_today: 10, remaining: 10, plan_type: 'free' } });
    }
  },

  generate: async () => {
    const { photos, useCase, customPrompt, numImages, usage } = get();

    if (photos.length === 0) {
      set({ error: 'Please add at least one photo' });
      return null;
    }

    if (useCase === 'custom' && !customPrompt.trim()) {
      set({ error: 'Please enter a custom prompt' });
      return null;
    }

    if (usage && numImages > usage.remaining) {
      set({ error: 'Not enough images remaining today' });
      return null;
    }

    set({
      isGenerating: true,
      error: null,
      progress: 0,
      statusMessage: 'Preparing your photos...',
      currentStep: 'generating',
    });

    try {
      // Convert photos to base64
      set({ statusMessage: 'Processing photos...', progress: 10 });

      const photosBase64 = await Promise.all(
        photos.map(async (file) => {
          return new Promise<string>((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => {
              const result = reader.result as string;
              // Remove data:image/...;base64, prefix
              const base64 = result.split(',')[1];
              resolve(base64);
            };
            reader.onerror = reject;
            reader.readAsDataURL(file);
          });
        })
      );

      set({ statusMessage: `Generating ${numImages} images...`, progress: 20 });

      // Simulate progress updates during generation
      const progressInterval = setInterval(() => {
        const currentProgress = get().progress;
        if (currentProgress < 90) {
          set({ progress: Math.min(90, currentProgress + 10) });
        }
      }, 3000);

      // Generate
      let result;
      try {
        result = await generatePhotoshoot({
        photos: photosBase64,
        use_case: useCase,
        custom_prompt: useCase === 'custom' ? customPrompt : undefined,
          num_images: numImages,
        });
      } finally {
        clearInterval(progressInterval);
      }

      set({
        progress: 100,
        sessionId: result.session_id,
        generatedImages: result.images,
        failedIndices: (result.image_failures ?? []).map((f) => f.index),
        failedCount: result.failed_count ?? (result.image_failures?.length ?? 0),
        partialSuccess: Boolean(result.partial_success),
        currentStep: 'results',
        isGenerating: false,
      });

      if (result.usage) {
        set({ usage: result.usage });
      }

      return result;
    } catch (error) {
      const apiError = getApiError(error);
      set({
        error: apiError.message,
        isGenerating: false,
        currentStep: 'configure',
      });
      return null;
    }
  },

  retryFailedSlot: async (index) => {
    const { photos, useCase, customPrompt, usage, failedIndices, generatedImages } = get();

    if (!failedIndices.includes(index)) return;
    if (photos.length === 0) return;
    if (usage && usage.remaining <= 0) {
      set({ error: 'Not enough images remaining today' });
      return;
    }

    set({ retryingFailedIndex: index, error: null });

    try {
      const photosBase64 = await Promise.all(
        photos.map(async (file) => {
          return new Promise<string>((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => {
              const result = reader.result as string;
              resolve(result.split(',')[1]);
            };
            reader.onerror = reject;
            reader.readAsDataURL(file);
          });
        })
      );

      const result = await generatePhotoshoot({
        photos: photosBase64,
        use_case: useCase,
        custom_prompt: useCase === 'custom' ? customPrompt : undefined,
        num_images: 1,
      });

      const retriedImage = result.images[0];
      if (!retriedImage) {
        set({ error: 'Retry failed. Please try again.', retryingFailedIndex: null });
        return;
      }

      const patchedImage: GeneratedImage = { ...retriedImage, index };
      const nextImages = [...generatedImages.filter((img) => img.index !== index), patchedImage]
        .sort((a, b) => a.index - b.index);
      const nextFailed = failedIndices.filter((i) => i !== index).sort((a, b) => a - b);

      set({
        generatedImages: nextImages,
        failedIndices: nextFailed,
        failedCount: nextFailed.length,
        partialSuccess: nextFailed.length > 0,
        retryingFailedIndex: null,
      });

      if (result.usage) {
        set({ usage: result.usage });
      }
    } catch (error) {
      const apiError = getApiError(error);
      set({ error: apiError.message, retryingFailedIndex: null });
    }
  },

  reset: () => {
    set({
      ...initialState,
      usage: get().usage, // Preserve usage info
    });
    // Fire and forget - don't block reset on usage fetch
    void get().fetchUsage();
  },
}));

// Selectors
export const selectCanGenerate = (state: PhotoshootState) => {
  const { photos, useCase, customPrompt, numImages, usage } = state;
  if (photos.length === 0) return false;
  if (useCase === 'custom' && !customPrompt.trim()) return false;
  if (usage && numImages > usage.remaining) return false;
  return true;
};

export const selectRemainingToday = (state: PhotoshootState) => state.usage?.remaining ?? 10;
export const selectEffectiveMaxImages = (state: PhotoshootState) =>
  Math.max(1, Math.min(10, state.usage?.remaining ?? 10));

// Hooks
export function usePhotoshoot() {
  return usePhotoshootStore();
}

export function useCanGenerate() {
  return usePhotoshootStore(selectCanGenerate);
}

export function useRemainingToday() {
  return usePhotoshootStore(selectRemainingToday);
}
