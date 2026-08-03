/**
 * Photoshoot API functions
 */

import { apiClient, getApiError } from './client';
import { createAuthenticatedSSEConnection } from './batch';

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ||
  import.meta.env.VITE_API_URL ||
  'http://localhost:8000';

// Types
export interface GeneratedImage {
  id: string;
  index: number;
  image_url?: string;
  image_base64?: string;
  storage_path?: string;
  /** Human scene label from the backend ("Sunlit cafe, seated upper body") */
  label?: string;
}

export interface PhotoshootUsage {
  used_today: number;
  limit_today: number;
  remaining: number;
  plan_type: string;
  resets_at?: string;
}

export interface PhotoshootResult {
  session_id: string;
  status: 'pending' | 'generating' | 'complete' | 'failed';
  images: GeneratedImage[];
  generated_count?: number;
  failed_count?: number;
  image_failures?: Array<{ index: number; error: string }>;
  partial_success?: boolean;
  usage?: PhotoshootUsage;
  error?: string;
}

export interface PhotoshootJobStartResponse {
  job_id: string;
  status: string;
  message: string;
}

export interface PhotoshootJobStatusResponse {
  job_id: string;
  status: 'pending' | 'processing' | 'complete' | 'failed' | 'cancelled';
  generated_count: number;
  failed_count: number;
  failed_indices: number[];
  partial_success: boolean;
  total_count: number;
  current_batch: number;
  total_batches: number;
  images: GeneratedImage[];
  usage?: PhotoshootUsage | null;
  error?: string | null;
}

export interface UseCaseInfo {
  id: string;
  name: string;
  description: string;
  example_prompts: string[];
}

export type PhotoshootUseCase = 'linkedin' | 'dating_app' | 'model_portfolio' | 'instagram' | 'custom';

export interface PhotoshootRequest {
  photos: string[];
  use_case: PhotoshootUseCase;
  custom_prompt?: string;
  num_images?: number;
}

// API envelope wrapper
interface ApiEnvelope<T> {
  data: T;
}

// API Functions

/**
 * Get current user's photoshoot usage for today
 */
export async function getPhotoshootUsage(): Promise<PhotoshootUsage> {
  try {
    const response = await apiClient.get<ApiEnvelope<PhotoshootUsage>>('/api/v1/photoshoot/usage');
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Start a photoshoot generation job (async, SSE-tracked).
 *
 * Returns a job_id immediately; subscribe to progress via
 * subscribeToPhotoshootEvents or poll getPhotoshootJobStatus.
 */
export async function startPhotoshootJob(
  request: PhotoshootRequest
): Promise<PhotoshootJobStartResponse> {
  try {
    const response = await apiClient.post<ApiEnvelope<PhotoshootJobStartResponse>>(
      '/api/v1/photoshoot/generate',
      {
        photos: request.photos,
        use_case: request.use_case,
        custom_prompt: request.custom_prompt,
        num_images: request.num_images ?? 10,
      }
    );
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get the current status of a photoshoot job (poll fallback / recovery).
 */
export async function getPhotoshootJobStatus(
  jobId: string
): Promise<PhotoshootJobStatusResponse> {
  try {
    const response = await apiClient.get<ApiEnvelope<PhotoshootJobStatusResponse>>(
      `/api/v1/photoshoot/${jobId}/status`
    );
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Cancel a running photoshoot job.
 */
export async function cancelPhotoshootJob(jobId: string): Promise<void> {
  try {
    await apiClient.post(`/api/v1/photoshoot/${jobId}/cancel`);
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Subscribe to photoshoot job SSE events (progress, per-image results).
 *
 * @returns Abort function to close the connection
 */
export function subscribeToPhotoshootEvents(
  jobId: string,
  onMessage: (event: { type: string; data: unknown }) => void,
  onError?: (error: Error) => void,
  onClose?: (sawTerminal: boolean) => void
): () => void {
  // Backend route is /api/v1/photoshoot/{job_id}/events — NOT under
  // /generate, which is a POST-only endpoint.
  return createAuthenticatedSSEConnection(
    `${API_BASE_URL}/api/v1/photoshoot/${jobId}/events`,
    onMessage,
    onError,
    onClose
  );
}

/**
 * Generate photoshoot images (synchronous mode — legacy, kept for callers
 * that have not migrated to the async job flow).
 */
export async function generatePhotoshoot(request: PhotoshootRequest): Promise<PhotoshootResult> {
  try {
    const response = await apiClient.post<ApiEnvelope<PhotoshootResult>>('/api/v1/photoshoot/generate?sync=true', {
      photos: request.photos,
      use_case: request.use_case,
      custom_prompt: request.custom_prompt,
      num_images: request.num_images ?? 10,
    });
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

// Use case display info
export const USE_CASE_INFO: Record<PhotoshootUseCase, { label: string; description: string; icon: string }> = {
  linkedin: {
    label: 'LinkedIn Profile',
    description: 'Professional headshots for business profiles',
    icon: '💼',
  },
  dating_app: {
    label: 'Dating App',
    description: 'Casual, approachable photos for dating profiles',
    icon: '💕',
  },
  model_portfolio: {
    label: 'Model Portfolio',
    description: 'High-fashion editorial style shots',
    icon: '📸',
  },
  instagram: {
    label: 'Instagram Content',
    description: 'Trendy lifestyle and aesthetic content',
    icon: '✨',
  },
  custom: {
    label: 'Custom Prompt',
    description: 'Write your own prompt for unique results',
    icon: '🎨',
  },
};
