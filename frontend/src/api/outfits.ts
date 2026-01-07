/**
 * Outfits API endpoints
 */

import { apiClient, getApiError } from './client';
import type {
  Outfit,
  OutfitCreate,
  OutfitFormData,
  OutfitFilters,
  PaginatedResponse,
  GenerationRequest,
  GenerationResponse,
  GenerationStatus,
} from '../types';

// ============================================================================
// OUTFITS API FUNCTIONS
// ============================================================================

/**
 * Create a new outfit
 */
export async function createOutfit(data: OutfitCreate): Promise<Outfit> {
  try {
    const response = await apiClient.post<Outfit>('/api/v1/outfits/', data);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get list of outfits with optional filters
 */
export async function getOutfits(filters?: OutfitFilters): Promise<PaginatedResponse<Outfit>> {
  try {
    const params = new URLSearchParams();

    if (filters?.style) params.append('style', filters.style);
    if (filters?.season) params.append('season', filters.season);
    if (filters?.search) params.append('search', filters.search);
    if (filters?.is_favorite !== undefined) params.append('is_favorite', String(filters.is_favorite));
    params.append('page', String(filters?.page || 1));
    params.append('page_size', String(filters?.page_size || 24));

    const response = await apiClient.get<PaginatedResponse<Outfit>>(`/api/v1/outfits/?${params.toString()}`);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get a single outfit by ID
 */
export async function getOutfit(id: string): Promise<Outfit> {
  try {
    const response = await apiClient.get<Outfit>(`/api/v1/outfits/${id}`);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Update an existing outfit
 */
export async function updateOutfit(id: string, data: Partial<OutfitFormData>): Promise<Outfit> {
  try {
    const response = await apiClient.put<Outfit>(`/api/v1/outfits/${id}`, data);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Delete an outfit
 */
export async function deleteOutfit(id: string): Promise<{ message: string }> {
  try {
    const response = await apiClient.delete<{ message: string }>(`/api/v1/outfits/${id}`);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Toggle favorite status of an outfit
 */
export async function toggleOutfitFavorite(id: string): Promise<Outfit> {
  try {
    const response = await apiClient.post<Outfit>(`/api/v1/outfits/${id}/favorite`);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Mark outfit as worn
 */
export async function markOutfitAsWorn(id: string): Promise<Outfit> {
  try {
    const response = await apiClient.post<Outfit>(`/api/v1/outfits/${id}/wear`);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Duplicate an outfit
 */
export async function duplicateOutfit(id: string): Promise<Outfit> {
  try {
    const response = await apiClient.post<Outfit>(`/api/v1/outfits/${id}/duplicate`);
    return response.data;
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
    const response = await apiClient.post<GenerationResponse>(
      `/api/v1/outfits/${outfitId}/generate`,
      request
    );
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Check the status of an AI generation
 */
export async function getGenerationStatus(generationId: string): Promise<{
  status: GenerationStatus;
  image_url?: string;
  error?: string;
  created_at: string;
}> {
  try {
    const response = await apiClient.get<{
      status: GenerationStatus;
      image_url?: string;
      error?: string;
      created_at: string;
    }>(`/api/v1/outfits/generation/${generationId}`);
    return response.data;
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
      Array<{
        id: string;
        name: string;
        category: string;
        image_url?: string;
        colors: string[];
      }>
    >('/api/v1/outfits/available-items');
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Add an item to an existing outfit
 */
export async function addItemToOutfit(
  outfitId: string,
  itemId: string,
  position?: string
): Promise<Outfit> {
  try {
    const response = await apiClient.post<Outfit>(`/api/v1/outfits/${outfitId}/items`, {
      item_id: itemId,
      position,
    });
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Remove an item from an outfit
 */
export async function removeItemFromOutfit(outfitId: string, itemId: string): Promise<Outfit> {
  try {
    const response = await apiClient.delete<Outfit>(`/api/v1/outfits/${outfitId}/items/${itemId}`);
    return response.data;
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
  isPrimary: boolean = false
): Promise<{ image_url: string; thumbnail_url: string }> {
  try {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('is_primary', String(isPrimary));

    const response = await apiClient.post<{ image_url: string; thumbnail_url: string }>(
      `/api/v1/outfits/${outfitId}/images`,
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      }
    );
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Delete an outfit image
 */
export async function deleteOutfitImage(outfitId: string, imageId: string): Promise<{ message: string }> {
  try {
    const response = await apiClient.delete<{ message: string }>(
      `/api/v1/outfits/${outfitId}/images/${imageId}`
    );
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get outfit statistics
 */
export async function getOutfitStats(): Promise<{
  total_outfits: number;
  outfits_by_style: Record<string, number>;
  outfits_by_season: Record<string, number>;
  most_worn_outfits: Array<{ id: string; name: string; times_worn: number }>;
  recent_outfits: Array<{ id: string; name: string; created_at: string }>;
}> {
  try {
    const response = await apiClient.get('/api/v1/outfits/stats');
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Batch delete multiple outfits
 */
export async function batchDeleteOutfits(outfitIds: string[]): Promise<{ message: string; deleted_count: number }> {
  try {
    const response = await apiClient.post<{ message: string; deleted_count: number }>(
      '/api/v1/outfits/batch-delete',
      { outfit_ids: outfitIds }
    );
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get recently worn outfits
 */
export async function getRecentlyWornOutfits(limit: number = 5): Promise<Outfit[]> {
  try {
    const response = await apiClient.get<Outfit[]>(`/api/v1/outfits/recently-worn?limit=${limit}`);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get favorite outfits
 */
export async function getFavoriteOutfits(): Promise<Outfit[]> {
  try {
    const response = await apiClient.get<Outfit[]>('/api/v1/outfits/favorites');
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}
