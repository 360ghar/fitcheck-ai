/**
 * Photoshoot API functions
 */

import { apiClient, getApiError } from './client';

// Types
export interface GeneratedImage {
  id: string;
  index: number;
  image_url?: string;
  image_base64?: string;
  storage_path?: string;
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
  usage?: PhotoshootUsage;
  error?: string;
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
 * Get available photoshoot use cases
 */
export async function getUseCases(): Promise<UseCaseInfo[]> {
  try {
    const response = await apiClient.get<ApiEnvelope<{ use_cases: UseCaseInfo[] }>>('/api/v1/photoshoot/use-cases');
    return response.data.data.use_cases;
  } catch (error) {
    throw getApiError(error);
  }
}

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
 * Generate photoshoot images (synchronous mode)
 * Uses sync=true to wait for all images before returning.
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
