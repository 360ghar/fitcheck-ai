/**
 * Batch extraction store (module-scoped, survives route changes).
 *
 * The batch flow used to keep all its state in `useState` inside
 * `useBatchExtraction`, so navigating away mid-job unmounted the flow and
 * orphaned the in-flight job: the job pill's reopen showed an empty dialog
 * while the backend job kept running. State now lives here, keyed by the active
 * job id, so the pill's cross-route reopen restores the in-flight job and the
 * SSE hook reconnects on remount.
 *
 * NOTE: `images` holds `File` objects + preview URLs, so this state is
 * intentionally in-memory only (never persisted to localStorage). It survives
 * SPA route changes but not a full page reload.
 */

import { create } from 'zustand'
import type { BatchExtractionState } from '@/types'

export const initialState: BatchExtractionState = {
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
  capacityExhausted: false,
  error: null,
}

/**
 * The store holds the full `BatchExtractionState`. The SSE hook
 * (`useBatchSSE`) drives updates via `useBatchExtractionStore.setState`, which
 * accepts functional updaters exactly like `useState`'s setter, so the merge /
 * replay logic is unchanged by the promotion.
 */
export const useBatchExtractionStore = create<BatchExtractionState>(() => initialState)

/** Reset to the pristine select state (used by cancel / save-complete / full close). */
export function resetBatchExtractionStore(): void {
  useBatchExtractionStore.setState(initialState)
}
