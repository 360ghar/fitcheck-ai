/**
 * Hook for managing the batch extraction flow state.
 *
 * Orchestrates the multi-image upload, extraction, and generation process.
 */

import { useState, useCallback, useRef } from 'react';
import { useBatchSSE } from './useBatchSSE';
import {
  startBatchExtraction,
  cancelBatchJob,
  fileToBase64,
} from '@/api/batch';
import { normalizeUseCases } from '@/lib/use-cases';
import type {
  BatchExtractionState,
  BatchImageInput,
  DetectedItem,
  BatchSSEEventType,
  ImageExtractionCompleteData,
  ImageExtractionFailedData,
  GenerationStartedData,
  BatchGenerationStartedData,
  ItemGenerationCompleteData,
  ItemGenerationFailedData,
  JobCompleteData,
  Category,
} from '@/types';

const initialState: BatchExtractionState = {
  step: 'select',
  images: [],
  jobId: null,
  allDetectedItems: [],
  extractionProgress: 0,
  generationProgress: 0,
  currentBatch: 0,
  totalBatches: 0,
  imagesCompleted: 0,
  imagesFailed: 0,
  itemsGenerated: 0,
  itemsFailed: 0,
  error: null,
};

/**
 * Generate a unique ID for an image
 */
function generateImageId(): string {
  return `img-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
}

/**
 * Generate a name for an item based on its properties
 */
function generateItemName(item: {
  colors?: string[];
  sub_category?: string;
  category: string;
}): string {
  const parts: string[] = [];
  if (item.colors?.[0]) {
    parts.push(item.colors[0].charAt(0).toUpperCase() + item.colors[0].slice(1));
  }
  if (item.sub_category) {
    parts.push(item.sub_category.charAt(0).toUpperCase() + item.sub_category.slice(1));
  } else if (item.category) {
    parts.push(item.category.charAt(0).toUpperCase() + item.category.slice(1));
  }
  return parts.join(' ') || 'New Item';
}

/**
 * Convert API item to frontend DetectedItem format
 */
function convertToDetectedItem(
  apiItem: {
    temp_id: string;
    person_id?: string;
    person_label?: string;
    is_current_user_person?: boolean;
    include_in_wardrobe?: boolean;
    category: string;
    sub_category?: string;
    colors: string[];
    material?: string;
    pattern?: string;
    brand?: string;
    confidence: number;
    bounding_box?: { x: number; y: number; width: number; height: number };
    detailed_description?: string;
    status: string;
    generated_image_base64?: string;
    generated_image_url?: string;
    generation_error?: string;
    occasion_tags?: string[];
  },
  imageId?: string
): DetectedItem {
  return {
    tempId: apiItem.temp_id,
    sourceImageId: imageId,
    personId: apiItem.person_id,
    personLabel: apiItem.person_label,
    isCurrentUserPerson: apiItem.is_current_user_person,
    includeInWardrobe:
      apiItem.include_in_wardrobe !== undefined ? apiItem.include_in_wardrobe : true,
    category: apiItem.category as Category,
    sub_category: apiItem.sub_category,
    colors: apiItem.colors || [],
    material: apiItem.material,
    pattern: apiItem.pattern,
    brand: apiItem.brand,
    confidence: apiItem.confidence,
    boundingBox: apiItem.bounding_box,
    detailedDescription: apiItem.detailed_description || '',
    status: apiItem.generated_image_base64 || apiItem.generated_image_url
      ? 'generated'
      : apiItem.generation_error
        ? 'failed'
        : 'detected',
    generatedImageUrl: apiItem.generated_image_url ||
      (apiItem.generated_image_base64
        ? `data:image/png;base64,${apiItem.generated_image_base64}`
        : undefined),
    generationError: apiItem.generation_error,
    name: generateItemName({
      colors: apiItem.colors,
      sub_category: apiItem.sub_category,
      category: apiItem.category,
    }),
    occasion_tags: normalizeUseCases(apiItem.occasion_tags),
  };
}

export interface UseBatchExtractionReturn {
  /** Current state */
  state: BatchExtractionState;
  /** Whether SSE is connected */
  isConnected: boolean;
  /** Add images to selection */
  addImages: (files: File[]) => void;
  /** Remove an image from selection */
  removeImage: (imageId: string) => void;
  /** Clear all selected images */
  clearImages: () => void;
  /** Start the extraction process */
  startExtraction: () => Promise<void>;
  /** Cancel the current job */
  cancel: () => Promise<void>;
  /** Reset to initial state */
  reset: () => void;
  /** Update a detected item */
  updateItem: (tempId: string, updates: Partial<DetectedItem>) => void;
  /** Delete a detected item (mark as deleted) */
  deleteItem: (tempId: string) => void;
  /** Proceed to saving step */
  proceedToSaving: () => void;
}

/**
 * Hook for managing the batch extraction flow.
 */
export function useBatchExtraction(): UseBatchExtractionReturn {
  const [state, setState] = useState<BatchExtractionState>(initialState);
  const totalImagesRef = useRef(0);
  const totalItemsRef = useRef(0);

  /**
   * Handle SSE events
   */
  const handleSSEEvent = useCallback(
    (event: { type: BatchSSEEventType; data: unknown }) => {
      switch (event.type) {
        case 'connected':
          // Connected to SSE
          break;

        case 'extraction_started':
          setState((prev) => ({
            ...prev,
            step: 'extracting',
          }));
          break;

        case 'image_extraction_complete': {
          const data = event.data as ImageExtractionCompleteData;
          totalImagesRef.current = data.total_images;

          // Convert API items to frontend format
          const newItems: DetectedItem[] = data.items.map((item) =>
            convertToDetectedItem(item, data.image_id)
          );

          setState((prev) => ({
            ...prev,
            images: prev.images.map((img) =>
              img.imageId === data.image_id
                ? { ...img, status: 'completed' as const, detectedItems: newItems }
                : img
            ),
            allDetectedItems: [...prev.allDetectedItems, ...newItems],
            imagesCompleted: data.completed_count,
            extractionProgress: (data.completed_count / data.total_images) * 100,
          }));
          break;
        }

        case 'image_extraction_failed': {
          const data = event.data as ImageExtractionFailedData;
          setState((prev) => ({
            ...prev,
            images: prev.images.map((img) =>
              img.imageId === data.image_id
                ? { ...img, status: 'failed' as const, error: data.error }
                : img
            ),
            imagesFailed: data.failed_count,
            extractionProgress:
              ((data.completed_count + data.failed_count) / data.total_images) * 100,
          }));
          break;
        }

        case 'all_extractions_complete':
          setState((prev) => ({
            ...prev,
            extractionProgress: 100,
          }));
          break;

        case 'generation_started': {
          const data = event.data as GenerationStartedData;
          totalItemsRef.current = data.total_items;

          setState((prev) => ({
            ...prev,
            step: 'generating',
            totalBatches: data.total_batches,
            currentBatch: 1,
            // Mark all items as generating
            allDetectedItems: prev.allDetectedItems.map((item) => ({
              ...item,
              status: 'generating' as const,
            })),
          }));
          break;
        }

        case 'batch_generation_started': {
          const data = event.data as BatchGenerationStartedData;
          setState((prev) => ({
            ...prev,
            currentBatch: data.batch_number,
          }));
          break;
        }

        case 'item_generation_complete': {
          const data = event.data as ItemGenerationCompleteData;
          totalItemsRef.current = data.total_items;

          setState((prev) => ({
            ...prev,
            allDetectedItems: prev.allDetectedItems.map((item) =>
              item.tempId === data.temp_id
                ? {
                    ...item,
                    status: 'generated' as const,
                    generatedImageUrl: `data:image/png;base64,${data.generated_image_base64}`,
                  }
                : item
            ),
            itemsGenerated: data.completed_count,
            generationProgress: (data.completed_count / data.total_items) * 100,
          }));
          break;
        }

        case 'item_generation_failed': {
          const data = event.data as ItemGenerationFailedData;
          setState((prev) => ({
            ...prev,
            allDetectedItems: prev.allDetectedItems.map((item) =>
              item.tempId === data.temp_id
                ? {
                    ...item,
                    status: 'failed' as const,
                    generationError: data.error,
                  }
                : item
            ),
            itemsFailed: data.failed_count,
            generationProgress:
              ((data.completed_count + data.failed_count) / data.total_items) * 100,
          }));
          break;
        }

        case 'all_generations_complete':
          setState((prev) => ({
            ...prev,
            generationProgress: 100,
          }));
          break;

        case 'job_complete': {
          const data = event.data as JobCompleteData;

          // Merge final items from server
          const finalItems: DetectedItem[] = data.items.map((item) =>
            convertToDetectedItem(item, item.image_id)
          );

          const itemsByImage = finalItems.reduce<Record<string, DetectedItem[]>>(
            (acc, item) => {
              if (item.sourceImageId) {
                if (!acc[item.sourceImageId]) {
                  acc[item.sourceImageId] = [];
                }
                acc[item.sourceImageId].push(item);
              }
              return acc;
            },
            {}
          );

          setState((prev) => ({
            ...prev,
            step: 'review',
            generationProgress: 100,
            allDetectedItems: finalItems,
            images: prev.images.map((image) => ({
              ...image,
              status: image.status === 'failed' ? 'failed' : 'completed',
              detectedItems: itemsByImage[image.imageId] || image.detectedItems || [],
            })),
          }));
          break;
        }

        case 'job_failed': {
          const data = event.data as { error?: string };
          setState((prev) => ({
            ...prev,
            error: data.error || 'Job failed',
          }));
          break;
        }

        case 'job_cancelled':
          setState((prev) => ({
            ...prev,
            step: 'select',
            error: 'Job was cancelled',
          }));
          break;

        case 'heartbeat':
          // Ignore heartbeats
          break;
      }
    },
    []
  );

  const { isConnected, disconnect } = useBatchSSE({
    jobId: state.jobId,
    onEvent: handleSSEEvent,
    onError: (error) => {
      setState((prev) => ({ ...prev, error: error.message }));
    },
    autoConnect: true,
  });

  /**
   * Add images to selection
   */
  const addImages = useCallback((files: File[]) => {
    const newImages: BatchImageInput[] = files.map((file) => ({
      imageId: generateImageId(),
      file,
      previewUrl: URL.createObjectURL(file),
      status: 'pending' as const,
    }));

    setState((prev) => ({
      ...prev,
      images: [...prev.images, ...newImages].slice(0, 50), // Max 50 images
      error: null,
    }));
  }, []);

  /**
   * Remove an image from selection
   */
  const removeImage = useCallback((imageId: string) => {
    setState((prev) => {
      const image = prev.images.find((img) => img.imageId === imageId);
      if (image) {
        URL.revokeObjectURL(image.previewUrl);
      }
      return {
        ...prev,
        images: prev.images.filter((img) => img.imageId !== imageId),
      };
    });
  }, []);

  /**
   * Clear all selected images
   */
  const clearImages = useCallback(() => {
    setState((prev) => {
      prev.images.forEach((img) => URL.revokeObjectURL(img.previewUrl));
      return {
        ...prev,
        images: [],
      };
    });
  }, []);

  /**
   * Start the extraction process
   */
  const startExtraction = useCallback(async () => {
    if (state.images.length === 0) return;

    setState((prev) => ({
      ...prev,
      step: 'uploading',
      error: null,
    }));

    try {
      // Convert all images to base64
      const imagesWithBase64 = await Promise.all(
        state.images.map(async (img) => ({
          image_id: img.imageId,
          image_base64: await fileToBase64(img.file),
          filename: img.file.name,
        }))
      );

      // Start the batch job
      const job = await startBatchExtraction(imagesWithBase64, {
        autoGenerate: true,
        generationBatchSize: 5,
      });

      setState((prev) => ({
        ...prev,
        jobId: job.job_id,
        step: 'extracting',
        images: prev.images.map((img) => ({
          ...img,
          status: 'extracting' as const,
        })),
      }));
    } catch (error) {
      setState((prev) => ({
        ...prev,
        step: 'select',
        error: error instanceof Error ? error.message : 'Failed to start extraction',
      }));
    }
  }, [state.images]);

  /**
   * Cancel the current job
   */
  const cancel = useCallback(async () => {
    if (state.jobId) {
      try {
        await cancelBatchJob(state.jobId);
      } catch {
        // Ignore errors when cancelling
      }
      disconnect();
    }

    // Cleanup preview URLs
    state.images.forEach((img) => URL.revokeObjectURL(img.previewUrl));

    setState(initialState);
  }, [state.jobId, state.images, disconnect]);

  /**
   * Reset to initial state
   */
  const reset = useCallback(() => {
    if (state.jobId) {
      disconnect();
    }

    state.images.forEach((img) => URL.revokeObjectURL(img.previewUrl));

    setState(initialState);
  }, [state.jobId, state.images, disconnect]);

  /**
   * Update a detected item
   */
  const updateItem = useCallback((tempId: string, updates: Partial<DetectedItem>) => {
    setState((prev) => ({
      ...prev,
      allDetectedItems: prev.allDetectedItems.map((item) =>
        item.tempId === tempId ? { ...item, ...updates } : item
      ),
    }));
  }, []);

  /**
   * Delete a detected item (mark as deleted)
   */
  const deleteItem = useCallback((tempId: string) => {
    setState((prev) => ({
      ...prev,
      allDetectedItems: prev.allDetectedItems.map((item) =>
        item.tempId === tempId ? { ...item, status: 'deleted' as const } : item
      ),
    }));
  }, []);

  /**
   * Proceed to saving step
   */
  const proceedToSaving = useCallback(() => {
    setState((prev) => ({
      ...prev,
      step: 'saving',
    }));
  }, []);

  return {
    state,
    isConnected,
    addImages,
    removeImage,
    clearImages,
    startExtraction,
    cancel,
    reset,
    updateItem,
    deleteItem,
    proceedToSaving,
  };
}

export default useBatchExtraction;
