/**
 * Hook for managing the batch extraction flow state.
 *
 * Orchestrates the multi-image upload, extraction, and generation process.
 */

import { useState, useCallback, useRef } from 'react';
import { useBatchSSE } from './useBatchSSE';
import {
  startBatchExtractionMultipart,
  cancelBatchJob,
  getBatchJobStatus,
} from '@/api/batch';
import { compressImageFile } from '@/lib/image-compress';
import { cropImageFromBoundingBox } from '@/lib/crop-from-bounding-box';
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
  uploadProgress: 0,
  extractionProgress: 0,
  generationProgress: 0,
  currentBatch: 0,
  totalBatches: 0,
  isGenerationRunning: false,
  generationEtaSeconds: null,
  imagesCompleted: 0,
  imagesFailed: 0,
  itemsGenerated: 0,
  itemsFailed: 0,
  generationTotalItems: 0,
  error: null,
};

/**
 * Estimate remaining generation time from rolling average.
 * Uses batch concurrency so parallel work is accounted for.
 */
function estimateGenerationEtaSeconds(
  completedCount: number,
  failedCount: number,
  totalItems: number,
  startedAtMs: number | null,
  nowMs: number
): number | null {
  if (!startedAtMs || totalItems <= 0 || completedCount <= 0) return null;
  const remaining = Math.max(0, totalItems - completedCount - failedCount);
  if (remaining === 0) return 0;
  const elapsed = Math.max(1, nowMs - startedAtMs);
  // Wall-clock throughput already includes concurrency (items finished / elapsed).
  // Do not multiply by wave count again — that underestimates remaining time.
  const msPerItemWallClock = elapsed / completedCount;
  return Math.max(1, Math.ceil((remaining * msPerItemWallClock) / 1000));
}

/**
 * Resolve UI step after items arrive or a job ends.
 * - Never interrupt `saving`.
 * - Never demote `review` while the job is still in flight.
 * - Promote in-flight steps (`uploading`/`extracting`/`generating`) to `review`
 *   when items exist.
 * - On terminal empty results, fall back to `select`.
 */
function resolveStepWithItems(
  prevStep: BatchExtractionState['step'],
  hasItems: boolean,
  mode: 'in_flight' | 'terminal'
): BatchExtractionState['step'] {
  if (prevStep === 'saving') return 'saving';
  if (hasItems) return 'review';
  if (mode === 'in_flight') {
    // Still running with zero items: keep the current processing step.
    return prevStep;
  }
  // Terminal, no items: leave processing UI.
  return 'select';
}

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
 * Convert API item to frontend DetectedItem format.
 * When the job is still generating and the item has no studio photo/error yet,
 * emit `generating` so review cards keep the in-progress badge.
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
  imageId?: string,
  jobStatus?: string
): DetectedItem {
  const hasImage = Boolean(apiItem.generated_image_base64 || apiItem.generated_image_url);
  const hasError = Boolean(apiItem.generation_error);
  const stillGenerating =
    !hasImage &&
    !hasError &&
    (jobStatus === 'generating' || jobStatus === 'pending' || jobStatus === 'extracting');

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
    status: hasImage ? 'generated' : hasError ? 'failed' : stillGenerating ? 'generating' : 'detected',
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

/**
 * Overlay a server row onto a local row, preserving user edits and local-only
 * fields (deletes, name, toggles, source preview, in-flight generating).
 */
function overlayServerItem(local: DetectedItem, server: DetectedItem): DetectedItem {
  const preserveGenerating =
    local.status === 'generating' &&
    !server.generatedImageUrl &&
    !server.generationError;

  return {
    ...server,
    name: local.name ?? server.name,
    includeInWardrobe: local.includeInWardrobe ?? server.includeInWardrobe,
    tags: local.tags ?? server.tags,
    occasion_tags: local.occasion_tags ?? server.occasion_tags,
    sourcePreviewUrl: local.sourcePreviewUrl ?? server.sourcePreviewUrl,
    sourceImageId: local.sourceImageId ?? server.sourceImageId,
    generatedImageUrl: server.generatedImageUrl ?? local.generatedImageUrl,
    // A user-deleted item stays deleted so save skips it.
    // Keep local "generating" when the status API has no image yet.
    status:
      local.status === 'deleted'
        ? 'deleted'
        : preserveGenerating
          ? 'generating'
          : server.status,
  };
}

/**
 * Merge authoritative server items over the locally-tracked items, preserving
 * any edits the user made during review (name, wardrobe toggle, tags, deletes)
 * and a client-side image when the server hasn't produced one yet. Keyed by
 * tempId so it's safe to call repeatedly (job_complete, reconcile polling).
 *
 * Union semantics: never replace the full list with an empty server payload
 * (transient glitch / partial response). Overlay matches and append server-only
 * rows so local items are not wiped.
 */
function mergeServerItems(
  existing: DetectedItem[],
  serverItems: DetectedItem[]
): DetectedItem[] {
  if (serverItems.length === 0) return existing;

  const serverById = new Map(serverItems.map((item) => [item.tempId, item]));
  const seen = new Set<string>();
  const result: DetectedItem[] = [];

  for (const local of existing) {
    const server = serverById.get(local.tempId);
    if (server) {
      result.push(overlayServerItem(local, server));
      seen.add(local.tempId);
    } else {
      result.push(local);
    }
  }

  for (const server of serverItems) {
    if (!seen.has(server.tempId)) {
      result.push(server);
    }
  }

  return result;
}

/**
 * Upsert newly extracted items into the existing list by tempId.
 * Makes SSE event-history replay on reconnect idempotent.
 */
function upsertDetectedItems(
  existing: DetectedItem[],
  incoming: DetectedItem[]
): DetectedItem[] {
  if (incoming.length === 0) return existing;

  const byId = new Map(existing.map((item) => [item.tempId, item]));
  const order = existing.map((item) => item.tempId);
  const newIds: string[] = [];

  for (const item of incoming) {
    const prev = byId.get(item.tempId);
    if (prev) {
      // Prefer fresher extraction fields; keep user deletes, edits, and any
      // post-extraction progress (generating/generated/failed) from local state
      // so a replayed extraction event cannot roll status backward.
      const keepLocalStatus =
        prev.status === 'deleted' ||
        prev.status === 'generating' ||
        prev.status === 'generated' ||
        prev.status === 'failed';
      byId.set(item.tempId, {
        ...item,
        name: prev.name ?? item.name,
        includeInWardrobe: prev.includeInWardrobe ?? item.includeInWardrobe,
        tags: prev.tags ?? item.tags,
        occasion_tags: prev.occasion_tags ?? item.occasion_tags,
        sourcePreviewUrl: item.sourcePreviewUrl ?? prev.sourcePreviewUrl,
        generatedImageUrl: prev.generatedImageUrl ?? item.generatedImageUrl,
        status: keepLocalStatus ? prev.status : item.status,
        generationError: prev.generationError ?? item.generationError,
      });
    } else {
      byId.set(item.tempId, item);
      newIds.push(item.tempId);
    }
  }

  return [...order, ...newIds]
    .map((id) => byId.get(id))
    .filter((item): item is DetectedItem => item != null);
}

/**
 * Map items with a fixed concurrency pool (avoids decoding 50 bitmaps at once).
 */
async function mapPool<T, R>(
  items: T[],
  concurrency: number,
  fn: (item: T, index: number) => Promise<R>
): Promise<R[]> {
  if (items.length === 0) return [];
  const results = new Array<R>(items.length);
  let next = 0;

  const workers = Array.from({ length: Math.min(concurrency, items.length) }, async () => {
    while (next < items.length) {
      const index = next++;
      results[index] = await fn(items[index], index);
    }
  });

  await Promise.all(workers);
  return results;
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
  // Latest job id (state.jobId is stale inside the [] deps SSE callbacks).
  const jobIdRef = useRef<string | null>(null);
  // Guards reconcile polling against running twice.
  const reconcilingRef = useRef(false);
  // Generation ETA: wall clock when generation_started fired.
  const generationStartedAtRef = useRef<number | null>(null);
  // Mirror of images for SSE handlers (setState updaters are not sync in React 18).
  const imagesRef = useRef(state.images);
  imagesRef.current = state.images;

  /**
   * Attach per-item crops from bounding boxes so review shows the right garment
   * before studio photos arrive. Non-blocking: full source is used first, crops
   * upgrade in place.
   */
  const upgradeItemCrops = useCallback(
    async (imageId: string, items: DetectedItem[], sourcePreviewUrl: string) => {
      if (!sourcePreviewUrl || items.length === 0) return;

      const cropped = await Promise.all(
        items.map(async (item) => {
          if (!item.boundingBox) {
            return { tempId: item.tempId, sourcePreviewUrl };
          }
          try {
            const cropUrl = await cropImageFromBoundingBox(
              sourcePreviewUrl,
              item.boundingBox,
              { paddingFraction: 0.12 }
            );
            return { tempId: item.tempId, sourcePreviewUrl: cropUrl };
          } catch {
            return { tempId: item.tempId, sourcePreviewUrl };
          }
        })
      );

      setState((prev) => {
        const cropById = new Map(cropped.map((c) => [c.tempId, c.sourcePreviewUrl]));
        return {
          ...prev,
          allDetectedItems: prev.allDetectedItems.map((item) => {
            const crop = cropById.get(item.tempId);
            if (!crop || item.generatedImageUrl) return item;
            // Don't overwrite a crop we already applied.
            if (item.sourcePreviewUrl && item.sourcePreviewUrl !== sourcePreviewUrl) {
              return item;
            }
            return { ...item, sourcePreviewUrl: crop };
          }),
          images: prev.images.map((img) => {
            if (img.imageId !== imageId || !img.detectedItems) return img;
            return {
              ...img,
              detectedItems: img.detectedItems.map((item) => {
                const crop = cropById.get(item.tempId);
                if (!crop) return item;
                if (item.sourcePreviewUrl && item.sourcePreviewUrl !== sourcePreviewUrl) {
                  return item;
                }
                return { ...item, sourcePreviewUrl: crop };
              }),
            };
          }),
        };
      });
    },
    []
  );

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
          const baseItems: DetectedItem[] = data.items.map((item) =>
            convertToDetectedItem(item, data.image_id)
          );

          // Resolve preview outside setState — React 18 does not run updaters
          // synchronously, so reading inside the updater then using it after
          // would leave sourcePreviewUrl undefined and skip bbox crops.
          const sourcePreviewUrl = imagesRef.current.find(
            (img) => img.imageId === data.image_id
          )?.previewUrl;

          setState((prev) => {
            // Attach the uploaded photo's preview so review can show each item
            // before its studio photo is generated (decoupling).
            // Under overlap, gen may already be running — mark new items generating.
            const newItems = baseItems.map((item) => ({
              ...item,
              sourcePreviewUrl,
              status:
                prev.isGenerationRunning && item.status === 'detected'
                  ? ('generating' as const)
                  : item.status,
            }));
            // Upsert by tempId so SSE reconnect event-history replay does not
            // duplicate items (mid-generation save would otherwise persist them).
            const allDetectedItems = upsertDetectedItems(prev.allDetectedItems, newItems);
            const hasItems = allDetectedItems.length > 0;
            return {
              ...prev,
              images: prev.images.map((img) =>
                img.imageId === data.image_id
                  ? { ...img, status: 'completed' as const, detectedItems: newItems }
                  : img
              ),
              allDetectedItems,
              imagesCompleted: data.completed_count,
              extractionProgress: (data.completed_count / data.total_images) * 100,
              // Review as soon as any items exist — do not wait for all images
              // or for studio generation.
              step: resolveStepWithItems(prev.step, hasItems, 'in_flight'),
            };
          });

          if (sourcePreviewUrl && baseItems.length > 0) {
            void upgradeItemCrops(data.image_id, baseItems, sourcePreviewUrl);
          }
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
          // Extraction is done - show results NOW. Studio photos keep streaming
          // in via item_generation_complete; we no longer hold the UI hostage
          // for the (slow) generation phase.
          setState((prev) => {
            const hasItems = prev.allDetectedItems.length > 0;
            return {
              ...prev,
              extractionProgress: 100,
              step: resolveStepWithItems(prev.step, hasItems, 'terminal'),
              error:
                !hasItems && prev.step !== 'saving'
                  ? 'No items found. Try a clearer, well-lit photo.'
                  : prev.error,
            };
          });
          break;

        case 'generation_started': {
          const data = event.data as GenerationStartedData;
          totalItemsRef.current = data.total_items;
          generationStartedAtRef.current = Date.now();

          setState((prev) => {
            const hasItems = prev.allDetectedItems.length > 0;
            // Prefer review whenever items exist. Only use the full generating
            // screen when there is nothing to review yet (rare race).
            let nextStep = prev.step;
            if (prev.step !== 'review' && prev.step !== 'saving') {
              nextStep = hasItems ? 'review' : 'generating';
            }
            return {
              ...prev,
              step: nextStep,
              totalBatches: data.total_batches,
              currentBatch: 1,
              isGenerationRunning: true,
              generationEtaSeconds: null,
              generationTotalItems: data.total_items,
              // Mark items as generating, preserving terminal statuses
              // (deleted / generated / failed) so SSE replay does not revive them.
              allDetectedItems: prev.allDetectedItems.map((item) =>
                item.status === 'deleted' ||
                item.status === 'generated' ||
                item.status === 'failed'
                  ? item
                  : { ...item, status: 'generating' as const }
              ),
            };
          });
          break;
        }

        case 'batch_generation_started': {
          const data = event.data as BatchGenerationStartedData;
          setState((prev) => ({
            ...prev,
            currentBatch: data.batch_number,
            isGenerationRunning: true,
          }));
          break;
        }

        case 'item_generation_complete': {
          const data = event.data as ItemGenerationCompleteData;
          totalItemsRef.current = data.total_items;
          const now = Date.now();
          const eta = estimateGenerationEtaSeconds(
            data.completed_count,
            0,
            data.total_items,
            generationStartedAtRef.current,
            now
          );

          setState((prev) => {
            const itemsFailed = prev.itemsFailed;
            const refinedEta = estimateGenerationEtaSeconds(
              data.completed_count,
              itemsFailed,
              data.total_items,
              generationStartedAtRef.current,
              now
            );
            // Do NOT clear isGenerationRunning when completed >= total_items:
            // under overlap, total_items grows as more images extract. Only
            // all_generations_complete / job_complete is authoritative.
            return {
              ...prev,
              allDetectedItems: prev.allDetectedItems.map((item) =>
                item.tempId === data.temp_id && item.status !== 'deleted'
                  ? {
                      ...item,
                      status: 'generated' as const,
                      generatedImageUrl: `data:image/png;base64,${data.generated_image_base64}`,
                    }
                  : item
              ),
              itemsGenerated: data.completed_count,
              // total_items may grow as more images finish extract (overlap).
              generationProgress: Math.min(
                100,
                (data.completed_count / Math.max(data.total_items, 1)) * 100
              ),
              generationTotalItems: Math.max(
                data.total_items,
                prev.generationTotalItems,
                data.completed_count
              ),
              generationEtaSeconds: refinedEta ?? eta,
              isGenerationRunning: true,
              // Stay on review if items exist (replay / race safety).
              step:
                prev.step === 'saving'
                  ? 'saving'
                  : prev.allDetectedItems.length > 0 || data.completed_count > 0
                    ? 'review'
                    : prev.step,
            };
          });
          break;
        }

        case 'item_generation_failed': {
          const data = event.data as ItemGenerationFailedData;
          const now = Date.now();

          setState((prev) => {
            const completed = data.completed_count ?? prev.itemsGenerated;
            const failed = data.failed_count;
            const total = data.total_items ?? prev.generationTotalItems;
            const eta = estimateGenerationEtaSeconds(
              completed,
              failed,
              total,
              generationStartedAtRef.current,
              now
            );
            return {
              ...prev,
              allDetectedItems: prev.allDetectedItems.map((item) =>
                item.tempId === data.temp_id && item.status !== 'deleted'
                  ? {
                      ...item,
                      status: 'failed' as const,
                      generationError: data.error,
                    }
                  : item
              ),
              itemsFailed: failed,
              generationProgress:
                total > 0
                  ? Math.min(100, ((completed + failed) / total) * 100)
                  : prev.generationProgress,
              generationTotalItems: Math.max(total, prev.generationTotalItems),
              generationEtaSeconds: eta,
              // Stay running until all_generations_complete (totals can grow).
              isGenerationRunning: true,
            };
          });
          break;
        }

        case 'all_generations_complete':
          setState((prev) => ({
            ...prev,
            generationProgress: 100,
            isGenerationRunning: false,
            generationEtaSeconds: 0,
          }));
          break;

        case 'job_complete': {
          const data = event.data as JobCompleteData;

          // Final items from server
          const finalItems: DetectedItem[] = data.items.map((item) =>
            convertToDetectedItem(item, item.image_id)
          );

          setState((prev) => {
            // Merge over local items so edits/toggles/deletes made during the
            // (now-decoupled) review survive the terminal event.
            const merged = mergeServerItems(prev.allDetectedItems, finalItems);

            const itemsByImage = merged.reduce<Record<string, DetectedItem[]>>(
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

            return {
              ...prev,
              step: resolveStepWithItems(prev.step, merged.length > 0, 'terminal'),
              generationProgress: 100,
              isGenerationRunning: false,
              generationEtaSeconds: 0,
              allDetectedItems: merged,
              images: prev.images.map((image) => ({
                ...image,
                status: image.status === 'failed' ? 'failed' : 'completed',
                detectedItems: itemsByImage[image.imageId] || image.detectedItems || [],
              })),
            };
          });
          break;
        }

        case 'job_failed': {
          const data = event.data as { error?: string };
          // Leave the loading screen: show whatever was extracted, or return to
          // select with the error. Never strand the user on a spinner. Never
          // interrupt an in-progress save.
          setState((prev) => ({
            ...prev,
            step: resolveStepWithItems(
              prev.step,
              prev.allDetectedItems.length > 0,
              'terminal'
            ),
            isGenerationRunning: false,
            error: data.error || 'Job failed',
          }));
          break;
        }

        case 'job_cancelled':
          generationStartedAtRef.current = null;
          setState((prev) => ({
            ...prev,
            step: 'select',
            isGenerationRunning: false,
            generationEtaSeconds: null,
            error: 'Job was cancelled',
          }));
          break;

        case 'heartbeat':
          // Ignore heartbeats
          break;
      }
    },
    [upgradeItemCrops]
  );

  /**
   * Reconcile the UI against the authoritative job status by polling /status.
   * This is the recovery path when the SSE stream dies silently, errors out
   * after retries, goes idle, or when the job was lost entirely (process
   * OOM/redeploy -> the status endpoint 404s). Bounded by a 2-minute deadline.
   */
  const reconcileJobStatus = useCallback(async () => {
    const jobId = jobIdRef.current;
    if (!jobId || reconcilingRef.current) return;
    reconcilingRef.current = true;

    const deadline = Date.now() + 120_000;
    const TERMINAL = new Set(['completed', 'failed', 'cancelled']);

    const poll = async () => {
      if (!reconcilingRef.current) return;
      let terminal = false;

      try {
        const status = await getBatchJobStatus(jobId);
        const serverItems = (status.items || []).map((item) =>
          convertToDetectedItem(item, item.image_id, status.status)
        );
        terminal = TERMINAL.has(status.status);

        setState((prev) => {
          const merged = mergeServerItems(prev.allDetectedItems, serverItems);
          const hasItems = merged.length > 0;
          if (status.status === 'completed') {
            return {
              ...prev,
              allDetectedItems: merged,
              step: resolveStepWithItems(prev.step, hasItems, 'terminal'),
              generationProgress: 100,
              isGenerationRunning: false,
              generationEtaSeconds: 0,
              error: null,
            };
          }
          if (status.status === 'failed' || status.status === 'cancelled') {
            return {
              ...prev,
              allDetectedItems: merged,
              step: resolveStepWithItems(prev.step, hasItems, 'terminal'),
              isGenerationRunning: false,
              error: status.error || 'Job failed',
            };
          }
          // Still running: backfill items and promote to review as soon as
          // anything exists (mirrors Flutter). Don't strand on extracting.
          // Never interrupt saving.
          return {
            ...prev,
            allDetectedItems: merged,
            step: resolveStepWithItems(prev.step, hasItems, 'in_flight'),
            isGenerationRunning: status.status === 'generating',
            error: hasItems ? null : prev.error,
          };
        });
      } catch (err) {
        const is404 =
          (err as { response?: { status?: number } })?.response?.status === 404;
        if (is404) {
          // Job gone (OOM/redeploy): recover with whatever already arrived.
          terminal = true;
          setState((prev) => {
            const hasItems = prev.allDetectedItems.length > 0;
            return {
              ...prev,
              step: resolveStepWithItems(prev.step, hasItems, 'terminal'),
              isGenerationRunning: false,
              generationEtaSeconds: hasItems ? 0 : null,
              error: hasItems ? null : 'Connection was lost. Try again.',
            };
          });
        }
        // Other errors are transient: keep polling until the deadline.
      }

      if (terminal) {
        reconcilingRef.current = false;
        return;
      }
      if (Date.now() > deadline) {
        reconcilingRef.current = false;
        setState((prev) => {
          const hasItems = prev.allDetectedItems.length > 0;
          return {
            ...prev,
            step: resolveStepWithItems(prev.step, hasItems, 'terminal'),
            isGenerationRunning: false,
            generationEtaSeconds: hasItems ? 0 : null,
            error: hasItems ? prev.error : 'Connection lost while processing.',
          };
        });
        return;
      }
      setTimeout(poll, 5_000);
    };

    poll();
  }, []);

  // By the time onError fires, useBatchSSE has exhausted its reconnects.
  const handleSSEError = useCallback(() => {
    void reconcileJobStatus();
  }, [reconcileJobStatus]);

  // The stream ended without a terminal event (silent death / idle timeout).
  const handleStreamEnded = useCallback(() => {
    void reconcileJobStatus();
  }, [reconcileJobStatus]);

  const { isConnected, disconnect } = useBatchSSE({
    jobId: state.jobId,
    onEvent: handleSSEEvent,
    onError: handleSSEError,
    onStreamEnded: handleStreamEnded,
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

    reconcilingRef.current = false;
    generationStartedAtRef.current = null;
    setState((prev) => ({
      ...prev,
      step: 'uploading',
      uploadProgress: 0,
      extractionProgress: 0,
      generationProgress: 0,
      isGenerationRunning: false,
      generationEtaSeconds: null,
      generationTotalItems: 0,
      itemsGenerated: 0,
      itemsFailed: 0,
      imagesCompleted: 0,
      imagesFailed: 0,
      allDetectedItems: [],
      error: null,
    }));

    try {
      // Compress for upload size; original File stays in state for save fallback.
      // Multipart sends binary (no base64 bloat). Pool decode for mobile safety.
      const compressed = await mapPool(state.images, 3, async (img) => ({
        imageId: img.imageId,
        file: await compressImageFile(img.file),
      }));

      const job = await startBatchExtractionMultipart(compressed, {
        autoGenerate: true,
        generationBatchSize: 5,
        onUploadProgress: (percent) =>
          setState((prev) => ({ ...prev, uploadProgress: percent })),
      });

      jobIdRef.current = job.job_id;
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

    jobIdRef.current = null;
    reconcilingRef.current = false;
    generationStartedAtRef.current = null;
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

    jobIdRef.current = null;
    reconcilingRef.current = false;
    generationStartedAtRef.current = null;
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
