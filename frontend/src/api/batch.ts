/**
 * Batch Processing API client for multi-image extraction.
 *
 * Provides functions for starting batch jobs and connecting to SSE endpoints.
 */

import { apiClient, getAccessToken } from './client';
import type { BatchJobResponse } from '@/types';

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ||
  import.meta.env.VITE_API_URL ||
  'http://localhost:8000';

// =============================================================================
// TYPES
// =============================================================================

export interface BatchImageInputRequest {
  image_id: string;
  image_base64: string;
  filename?: string;
}

export interface StartBatchExtractionRequest {
  images: BatchImageInputRequest[];
  auto_generate?: boolean;
  generation_batch_size?: number;
}

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
  }>;
  error?: string;
}

// =============================================================================
// API FUNCTIONS
// =============================================================================

/**
 * Convert a File to base64 string
 */
export async function fileToBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      const result = reader.result as string;
      // Remove the data URL prefix (e.g., "data:image/png;base64,")
      const base64 = result.split(',')[1];
      resolve(base64);
    };
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

/**
 * Start a batch extraction job.
 *
 * @param images - Array of images with their IDs and base64 data
 * @param options - Optional configuration for generation
 * @returns Job response with ID and SSE URL
 */
export async function startBatchExtraction(
  images: BatchImageInputRequest[],
  options?: {
    autoGenerate?: boolean;
    generationBatchSize?: number;
  }
): Promise<BatchJobResponse> {
  const response = await apiClient.post<BatchJobResponse>('/api/v1/ai/batch-extract', {
    images,
    auto_generate: options?.autoGenerate ?? true,
    generation_batch_size: options?.generationBatchSize ?? 5,
  });
  return response.data;
}

/**
 * Cancel a running batch job.
 *
 * @param jobId - The job ID to cancel
 */
export async function cancelBatchJob(jobId: string): Promise<void> {
  await apiClient.post(`/api/v1/ai/batch-extract/${jobId}/cancel`);
}

/**
 * Get the current status of a batch job.
 *
 * @param jobId - The job ID to check
 * @returns Current job status and results
 */
export async function getBatchJobStatus(jobId: string): Promise<BatchJobStatusResponse> {
  const response = await apiClient.get<BatchJobStatusResponse>(
    `/api/v1/ai/batch-extract/${jobId}/status`
  );
  return response.data;
}

/**
 * Create an EventSource connection to the batch job SSE endpoint.
 *
 * Note: EventSource doesn't support custom headers, so we pass the token
 * as a query parameter. The backend accepts both Authorization header
 * and token query param for SSE endpoints.
 *
 * @param jobId - The job ID to connect to
 * @returns EventSource instance
 */
export function createBatchSSEConnection(jobId: string): EventSource {
  // Note: token not used directly since EventSource doesn't support custom headers
  // The authenticated version uses fetch-based approach instead
  const url = `${API_BASE_URL}/api/v1/ai/batch-extract/${jobId}/events`;

  // Note: Standard EventSource doesn't support custom headers.
  // For authenticated SSE, we'd need to use a polyfill or fetch-based approach.
  // For now, we'll rely on the browser's cookie-based auth if available,
  // or the backend should support token in query param.
  const eventSource = new EventSource(url, {
    withCredentials: true,
  });

  return eventSource;
}

/**
 * Create an authenticated SSE connection using fetch.
 *
 * This is a more flexible approach that supports Authorization headers.
 *
 * @param jobId - The job ID to connect to
 * @param onMessage - Callback for each SSE message
 * @param onError - Callback for errors
 * @returns Abort function to close the connection
 */
export function createAuthenticatedSSEConnection(
  jobId: string,
  onMessage: (event: { type: string; data: unknown }) => void,
  onError?: (error: Error) => void
): () => void {
  const controller = new AbortController();
  const token = getAccessToken();
  const url = `${API_BASE_URL}/api/v1/ai/batch-extract/${jobId}/events`;

  const connect = async () => {
    try {
      const response = await fetch(url, {
        headers: {
          Authorization: `Bearer ${token}`,
          Accept: 'text/event-stream',
        },
        signal: controller.signal,
      });

      if (!response.ok) {
        throw new Error(`SSE connection failed: ${response.status}`);
      }

      const reader = response.body?.getReader();
      if (!reader) {
        throw new Error('No response body');
      }

      const decoder = new TextDecoder();
      let buffer = '';
      let currentEvent = '';
      let dataLines: string[] = [];

      const dispatchEvent = () => {
        if (!currentEvent && dataLines.length === 0) return;

        const payload = dataLines.join('\n');
        const eventType = currentEvent || 'message';

        if (payload) {
          try {
            const parsed = JSON.parse(payload);
            onMessage({ type: eventType, data: parsed });
          } catch {
            onMessage({ type: eventType, data: payload });
          }
        } else {
          onMessage({ type: eventType, data: null });
        }

        currentEvent = '';
        dataLines = [];
      };

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');
        buffer = lines.pop() || '';

        for (const rawLine of lines) {
          const line = rawLine.replace(/\r$/, '');

          if (line.startsWith('event:')) {
            currentEvent = line.slice(6).trim();
            continue;
          }

          if (line.startsWith('data:')) {
            dataLines.push(line.slice(5).trimStart());
            continue;
          }

          if (line === '') {
            dispatchEvent();
          }
        }
      }

      dispatchEvent();
    } catch (error) {
      if ((error as Error).name !== 'AbortError') {
        onError?.(error as Error);
      }
    }
  };

  connect();

  return () => {
    controller.abort();
  };
}
