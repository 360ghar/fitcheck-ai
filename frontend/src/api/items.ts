/**
 * Items API endpoints
 */

import { apiClient, getApiError } from './client';
import type {
  ApiEnvelope,
  Item,
  ItemCreate,
  ItemFormData,
  ItemFilters,
  PaginatedItemsResponse,
  ItemImage,
} from '../types';

// ============================================================================
// ITEMS API FUNCTIONS
// ============================================================================

/**
 * Create a new item manually
 */
export async function createItem(data: ItemCreate): Promise<Item> {
  try {
    const response = await apiClient.post<ApiEnvelope<Item>>('/api/v1/items', data);
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Upload item images (for client-side AI extraction)
 */
export async function uploadItemImages(formData: FormData): Promise<{
  upload_id: string;
  status: string;
  uploaded_count: number;
  images: Array<{
    image_url?: string;
    thumbnail_url?: string;
    storage_path?: string;
    filename?: string;
  }>;
}> {
  try {
    const response = await apiClient.post<
      ApiEnvelope<{
        upload_id: string;
        status: string;
        uploaded_count: number;
        images: Array<{
          image_url?: string;
          thumbnail_url?: string;
          storage_path?: string;
          filename?: string;
        }>;
      }>
    >('/api/v1/items/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get list of items with optional filters
 */
export async function getItems(filters?: ItemFilters): Promise<PaginatedItemsResponse<Item>> {
  try {
    const params = new URLSearchParams();

    if (filters?.category) params.append('category', filters.category);
    if (filters?.color) params.append('color', filters.color);
    if (filters?.condition) params.append('condition', filters.condition);
    if (filters?.brand) params.append('brand', filters.brand);
    if (filters?.search) params.append('search', filters.search);
    if (filters?.is_favorite !== undefined) params.append('is_favorite', String(filters.is_favorite));
    params.append('page', String(filters?.page || 1));
    params.append('page_size', String(filters?.page_size || 24));

    const response = await apiClient.get<ApiEnvelope<PaginatedItemsResponse<Item>>>(
      `/api/v1/items?${params.toString()}`
    );
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get a single item by ID
 */
export async function getItem(id: string): Promise<Item> {
  try {
    const response = await apiClient.get<ApiEnvelope<Item>>(`/api/v1/items/${id}`);
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Update an existing item
 */
export async function updateItem(id: string, data: Partial<ItemFormData>): Promise<Item> {
  try {
    const response = await apiClient.put<ApiEnvelope<Item>>(`/api/v1/items/${id}`, data);
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Delete an item
 */
export async function deleteItem(id: string): Promise<void> {
  try {
    await apiClient.delete(`/api/v1/items/${id}`);
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Toggle favorite status of an item
 */
export async function toggleItemFavorite(id: string): Promise<{ id: string; is_favorite: boolean }> {
  try {
    const response = await apiClient.post<ApiEnvelope<{ id: string; is_favorite: boolean }>>(
      `/api/v1/items/${id}/favorite`
    );
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Upload an image for an existing item
 */
export async function uploadItemImage(
  itemId: string,
  file: File,
  isPrimary: boolean = false
): Promise<ItemImage> {
  try {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('is_primary', String(isPrimary));

    const response = await apiClient.post<ApiEnvelope<ItemImage>>(
      `/api/v1/items/${itemId}/images`,
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

/**
 * Delete an item image
 */
export async function deleteItemImage(itemId: string, imageId: string): Promise<{ deleted: boolean }> {
  try {
    const response = await apiClient.delete<ApiEnvelope<{ deleted: boolean }>>(
      `/api/v1/items/${itemId}/images/${imageId}`
    );
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Mark item as worn
 */
export async function markItemAsWorn(id: string): Promise<{ id: string; usage_times_worn: number }> {
  try {
    const response = await apiClient.post<ApiEnvelope<{ id: string; usage_times_worn: number }>>(
      `/api/v1/items/${id}/wear`
    );
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Batch delete multiple items
 */
export async function batchDeleteItems(itemIds: string[]): Promise<{ message: string; deleted_count: number }> {
  try {
    const response = await apiClient.post<ApiEnvelope<{ deleted_count: number }>>(
      '/api/v1/items/batch-delete',
      { item_ids: itemIds }
    );
    return { message: response.data.message || 'OK', deleted_count: response.data.data.deleted_count };
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get item statistics
 */
export async function getItemStats(): Promise<{
  total_items: number;
  items_by_category: Record<string, number>;
  items_by_color: Record<string, number>;
  items_by_condition: Record<string, number>;
  total_value: number;
  most_worn_items: Array<{ id: string; name: string; times_worn: number }>;
  least_worn_items: Array<{ id: string; name: string; times_worn: number }>;
}> {
  try {
    const response = await apiClient.get<
      ApiEnvelope<{
        total_items: number;
        items_by_category: Record<string, number>;
        items_by_color: Record<string, number>;
        items_by_condition: Record<string, number>;
        total_value: number;
        most_worn_items: Array<{ id: string; name: string; times_worn: number }>;
        least_worn_items: Array<{ id: string; name: string; times_worn: number }>;
      }>
    >('/api/v1/items/stats');
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get items by category
 */
export async function getItemsByCategory(category: string): Promise<Item[]> {
  try {
    const response = await apiClient.get<ApiEnvelope<{ items: Item[] }>>(
      `/api/v1/items/by-category/${category}`
    );
    return response.data.data.items;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Search items by query
 */
export async function searchItems(query: string, limit: number = 10): Promise<Item[]> {
  try {
    const response = await apiClient.get<ApiEnvelope<{ items: Item[] }>>(
      `/api/v1/items/search?q=${encodeURIComponent(query)}&limit=${limit}`
    );
    return response.data.data.items;
  } catch (error) {
    throw getApiError(error);
  }
}

// ============================================================================
// DUPLICATE DETECTION
// ============================================================================

/**
 * Duplicate item found during check
 */
export interface DuplicateItem {
  id: string;
  name: string;
  category: string;
  sub_category?: string;
  colors: string[];
  brand?: string;
  similarity_score: number;
  image_url?: string;
  reasons: string[];
}

/**
 * Response from duplicate check
 */
export interface DuplicateCheckResponse {
  has_duplicates: boolean;
  duplicates: DuplicateItem[];
  threshold: number;
}

/**
 * Request body for duplicate check
 */
export interface DuplicateCheckRequest {
  name: string;
  category: string;
  colors?: string[];
  brand?: string;
  sub_category?: string;
  material?: string;
  tags?: string[];
}

/**
 * Check for potential duplicate items before adding a new item
 */
export async function checkDuplicates(
  request: DuplicateCheckRequest,
  options?: { threshold?: number; limit?: number }
): Promise<DuplicateCheckResponse> {
  try {
    const params = new URLSearchParams();
    if (options?.threshold) params.append('threshold', options.threshold.toString());
    if (options?.limit) params.append('limit', options.limit.toString());

    const queryString = params.toString() ? `?${params.toString()}` : '';
    const response = await apiClient.post<ApiEnvelope<DuplicateCheckResponse>>(
      `/api/v1/items/check-duplicates${queryString}`,
      {
        name: request.name,
        category: request.category,
        colors: request.colors || [],
        brand: request.brand || null,
        sub_category: request.sub_category || null,
        material: request.material || null,
        tags: request.tags || [],
      }
    );
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Find items similar to a specific item
 */
export async function findSimilarItems(
  itemId: string,
  options?: { limit?: number; minScore?: number }
): Promise<{ items: Item[]; source_item_id: string }> {
  try {
    const params = new URLSearchParams();
    if (options?.limit) params.append('limit', options.limit.toString());
    if (options?.minScore) params.append('min_score', options.minScore.toString());

    const queryString = params.toString() ? `?${params.toString()}` : '';
    const response = await apiClient.get<ApiEnvelope<{ items: Item[]; source_item_id: string }>>(
      `/api/v1/items/${itemId}/similar${queryString}`
    );
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}
