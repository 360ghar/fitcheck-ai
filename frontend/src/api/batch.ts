/**
 * Batch Processing API client for multi-image extraction.
 *
 * Provides functions for starting batch jobs and connecting to SSE endpoints.
 */

import { apiClient, getAccessToken } from './client';
import { API_BASE_URL } from '@/lib/apiBaseUrl';
import { ENDPOINTS } from '@/lib/endpoints';
import { createSSEConnection } from '@/lib/sse';
import type { BatchJobResponse } from '@/types';

// =============================================================================
// TYPES
// =============================================================================

export interface BatchJobStatusResponse {
  job_id: string;
  status: string;
  total_images: number;
  extractions_completed: number;
  extractions_failed: number;
  total_items: number;
  generations_completed: number;
  generations_failed: number;
  items: Array<{
    temp_id: string;
    image_id: string;
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
    bounding_box?: {
      x: number;
      y: number;
      width: number;
      height: number;
    };
    detailed_description?: string;
    status: string;
    generated_image_base64?: string;
    generated_image_url?: string;
    generation_error?: string;
    source_image_url?: string;
    source_image_storage_path?: string;
  }>;
  error?: string;
}

// =============================================================================
// API FUNCTIONS
// =============================================================================

/**
 * Start a batch extraction job via multipart file upload (preferred for web).
 *
 * Sends compressed binary files (not base64 JSON). Same SSE contract as JSON start.
 */
export async function startBatchExtractionMultipart(
  images: { imageId: string; file: File }[],
  options?: {
    autoGenerate?: boolean;
    generationBatchSize?: number;
    onUploadProgress?: (percent: number) => void;
  }
): Promise<BatchJobResponse> {
  const form = new FormData();
  const imageIds: string[] = [];
  for (const img of images) {
    form.append('files', img.file, img.file.name || `${img.imageId}.jpg`);
    imageIds.push(img.imageId);
  }
  form.append('image_ids', JSON.stringify(imageIds));
  form.append('auto_generate', String(options?.autoGenerate ?? true));
  form.append(
    'generation_batch_size',
    String(options?.generationBatchSize ?? 5)
  );

  const response = await apiClient.post<BatchJobResponse>(
    ENDPOINTS.AI.BATCH_EXTRACT_MULTIPART,
    form,
    {
      // Match items upload: multipart (axios/browser sets boundary).
      headers: { 'Content-Type': 'multipart/form-data' },
      ...(options?.onUploadProgress
        ? {
            onUploadProgress: (e: { loaded: number; total?: number }) => {
              if (e.total) options.onUploadProgress!((e.loaded / e.total) * 100);
            },
          }
        : {}),
    }
  );
  return response.data;
}

/**
 * Cancel a running batch job.
 *
 * @param jobId - The job ID to cancel
 */
export async function cancelBatchJob(jobId: string): Promise<void> {
  await apiClient.post(`${ENDPOINTS.AI.BATCH_EXTRACT_BASE}/${jobId}/cancel`);
}

/**
 * Get the current status of a batch job.
 *
 * @param jobId - The job ID to check
 * @returns Current job status and results
 */
export async function getBatchJobStatus(jobId: string): Promise<BatchJobStatusResponse> {
  const response = await apiClient.get<BatchJobStatusResponse>(
    `${ENDPOINTS.AI.BATCH_EXTRACT_BASE}/${jobId}/status`
  );
  return response.data;
}

/**
 * Create an authenticated SSE connection using fetch.
 *
 * Thin wrapper over the shared SSE client in `lib/sse.ts` that adds the
 * Authorization header. Supports arbitrary URLs.
 *
 * @param url - Full SSE endpoint URL (e.g. `/api/v1/ai/batch-extract/{id}/events`).
 *   Must be on the same origin or include the full API base.
 * @param onMessage - Callback for each SSE message
 * @param onError - Callback for errors
 * @param onClose - Callback when the stream ends; `sawTerminal` is true if a
 *   terminal event (job_complete/failed/cancelled) was received. Lets the
 *   caller detect a silent stream death (ended with no terminal event).
 * @returns Abort function to close the connection
 */
export function createAuthenticatedSSEConnection(
  url: string,
  onMessage: (event: { type: string; data: unknown; id?: number }) => void,
  onError?: (error: Error) => void,
  onClose?: (sawTerminal: boolean) => void,
  lastEventId?: number
): () => void {
  return createSSEConnection({
    url,
    onMessage,
    onError,
    onClose,
    lastEventId,
    headers: { Authorization: `Bearer ${getAccessToken()}` },
  });
}

/**
 * Create an authenticated SSE connection to a batch extraction job.
 *
 * @param jobId - The job ID to connect to
 * @param onMessage - Callback for each SSE message
 * @param onError - Callback for errors
 * @param onClose - Callback when the stream ends; `sawTerminal` is true if a
 *   terminal event (job_complete/failed/cancelled) was received.
 * @returns Abort function to close the connection
 */
export function subscribeToBatchJobEvents(
  jobId: string,
  onMessage: (event: { type: string; data: unknown; id?: number }) => void,
  onError?: (error: Error) => void,
  onClose?: (sawTerminal: boolean) => void,
  lastEventId?: number
): () => void {
  return createAuthenticatedSSEConnection(
    `${API_BASE_URL}${ENDPOINTS.AI.BATCH_EXTRACT_BASE}/${jobId}/events`,
    onMessage,
    onError,
    onClose,
    lastEventId
  );
}
