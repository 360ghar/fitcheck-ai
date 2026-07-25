/**
 * Outfits API endpoints
 */

import { apiClient, getApiError } from './client';
import type {
  ApiEnvelope,
  Outfit,
  OutfitCreate,
  OutfitFilters,
  PaginatedOutfitsResponse,
  GenerationRequest,
  GenerationResponse,
  GenerationStatus,
  OutfitImage,
} from '../types';

// ============================================================================
// OUTFITS API FUNCTIONS
// ============================================================================

/**
 * Create a new outfit
 */
export async function createOutfit(data: OutfitCreate): Promise<Outfit> {
  try {
    const response = await apiClient.post<ApiEnvelope<Outfit>>('/api/v1/outfits', data);
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get list of outfits with optional filters
 */
export async function getOutfits(filters?: OutfitFilters): Promise<PaginatedOutfitsResponse<Outfit>> {
  try {
    const params = new URLSearchParams();

    if (filters?.style) params.append('style', filters.style);
    if (filters?.season) params.append('season', filters.season);
    if (filters?.search) params.append('search', filters.search);
    if (filters?.is_favorite !== undefined) params.append('is_favorite', String(filters.is_favorite));
    params.append('page', String(filters?.page || 1));
    params.append('page_size', String(filters?.page_size || 24));

    const response = await apiClient.get<ApiEnvelope<PaginatedOutfitsResponse<Outfit>>>(
      `/api/v1/outfits?${params.toString()}`
    );
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get a single outfit by ID
 */
export async function getOutfit(id: string): Promise<Outfit> {
  try {
    const response = await apiClient.get<ApiEnvelope<Outfit>>(`/api/v1/outfits/${id}`);
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Delete an outfit
 */
export async function deleteOutfit(id: string): Promise<void> {
  try {
    await apiClient.delete(`/api/v1/outfits/${id}`);
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Toggle favorite status of an outfit
 */
export async function toggleOutfitFavorite(id: string): Promise<{ id: string; is_favorite: boolean }> {
  try {
    const response = await apiClient.post<ApiEnvelope<{ id: string; is_favorite: boolean }>>(
      `/api/v1/outfits/${id}/favorite`
    );
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Mark outfit as worn
 */
export async function markOutfitAsWorn(
  id: string
): Promise<{ id: string; worn_count: number; last_worn_at: string }> {
  try {
    const response = await apiClient.post<ApiEnvelope<{ id: string; worn_count: number; last_worn_at: string }>>(
      `/api/v1/outfits/${id}/wear`
    );
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Duplicate an outfit
 */
export async function duplicateOutfit(id: string): Promise<Outfit> {
  try {
    const response = await apiClient.post<ApiEnvelope<Outfit>>(`/api/v1/outfits/${id}/duplicate`);
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Start AI generation for an outfit
 */
export async function generateOutfitVisualization(
  outfitId: string,
  request: Partial<GenerationRequest> = {}
): Promise<GenerationResponse> {
  try {
    const response = await apiClient.post<
      ApiEnvelope<{ generation_id: string; status: string; estimated_time?: number }>
    >(
      `/api/v1/outfits/${outfitId}/generate`,
      request
    );
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Check the status of an AI generation
 */
export async function getGenerationStatus(generationId: string): Promise<{
  status: GenerationStatus | string;
  progress?: number;
  images?: string[];
  error?: string;
}> {
  try {
    const response = await apiClient.get<
      ApiEnvelope<{
        status: GenerationStatus | string;
        progress?: number;
        images?: string[];
        error?: string;
      }>
    >(`/api/v1/outfits/generation/${generationId}`);
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get all items that can be added to outfits
 */
export async function getAvailableItems(): Promise<Array<{
  id: string;
  name: string;
  category: string;
  image_url?: string;
  colors: string[];
}>> {
  try {
    const response = await apiClient.get<
      ApiEnvelope<
      Array<{
        id: string;
        name: string;
        category: string;
        image_url?: string;
        colors: string[];
      }>
      >
    >('/api/v1/outfits/available-items');
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Upload an image for an existing outfit
 */
export async function uploadOutfitImage(
  outfitId: string,
  file: File,
  options: {
    isPrimary?: boolean;
    pose?: string;
    lighting?: string;
    body_profile_id?: string;
    generation_id?: string;
  } = {}
): Promise<OutfitImage> {
  try {
    const formData = new FormData();
    formData.append('file', file);
    if (options.pose) formData.append('pose', options.pose);
    if (options.lighting) formData.append('lighting', options.lighting);
    if (options.body_profile_id) formData.append('body_profile_id', options.body_profile_id);
    if (options.generation_id) formData.append('generation_id', options.generation_id);
    formData.append('is_primary', String(options.isPrimary ?? false));

    const response = await apiClient.post<ApiEnvelope<OutfitImage>>(
      `/api/v1/outfits/${outfitId}/images`,
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      }
    );
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

export async function shareOutfit(
  outfitId: string,
  options: {
    visibility?: 'public' | 'friends' | 'private';
    expires_at?: string;
    allow_feedback?: boolean;
    custom_caption?: string;
  } = {}
): Promise<{
  url: string;
  qr_code_url?: string | null;
  expires_at?: string | null;
  views?: number;
}> {
  try {
    const response = await apiClient.post<
      ApiEnvelope<{ share_link: { url: string; qr_code_url?: string | null; expires_at?: string | null; views?: number } }>
    >(`/api/v1/outfits/${outfitId}/share`, {
      visibility: options.visibility || 'public',
      expires_at: options.expires_at,
      allow_feedback: options.allow_feedback ?? true,
      custom_caption: options.custom_caption,
    })
    return response.data.data.share_link
  } catch (error) {
    throw getApiError(error)
  }
}

export interface PublicOutfitItem {
  id: string;
  name: string;
  category: string;
  colors: string[];
  brand?: string | null;
}

export interface PublicOutfit {
  id: string;
  name: string;
  description?: string | null;
  style?: string | null;
  season?: string | null;
  occasion?: string | null;
  tags: string[];
  created_at?: string;
  updated_at?: string;
  images: OutfitImage[];
  items: PublicOutfitItem[];
}

export async function getPublicOutfit(outfitId: string): Promise<PublicOutfit> {
  try {
    const response = await apiClient.get<ApiEnvelope<PublicOutfit>>(`/api/v1/outfits/public/${outfitId}`)
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

/**
 * Batch delete multiple outfits
 */
export async function batchDeleteOutfits(outfitIds: string[]): Promise<{ message: string; deleted_count: number }> {
  try {
    const response = await apiClient.post<ApiEnvelope<{ deleted_count: number }>>(
      '/api/v1/outfits/batch-delete',
      { outfit_ids: outfitIds }
    );
    return { message: response.data.message || 'OK', deleted_count: response.data.data.deleted_count };
  } catch (error) {
    throw getApiError(error);
  }
}
