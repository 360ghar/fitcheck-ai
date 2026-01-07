/**
 * Items API endpoints
 */

import { apiClient, getApiError } from './client';
import type {
  Item,
  ItemCreate,
  ItemFormData,
  ItemFilters,
  PaginatedResponse,
  ItemImageBase,
  ExtractedItem,
} from '../types';

// ============================================================================
// ITEMS API FUNCTIONS
// ============================================================================

/**
 * Create a new item manually
 */
export async function createItem(data: ItemCreate): Promise<Item> {
  try {
    const response = await apiClient.post<Item>('/api/v1/items/', data);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Upload images and extract items using AI
 */
export async function uploadForExtraction(formData: FormData): Promise<ExtractedItem[]> {
  try {
    const response = await apiClient.post<ExtractedItem[]>('/api/v1/items/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get list of items with optional filters
 */
export async function getItems(filters?: ItemFilters): Promise<PaginatedResponse<Item>> {
  try {
    const params = new URLSearchParams();

    if (filters?.category) params.append('category', filters.category);
    if (filters?.color) params.append('color', filters.color);
    if (filters?.condition) params.append('condition', filters.condition);
    if (filters?.search) params.append('search', filters.search);
    if (filters?.is_favorite !== undefined) params.append('is_favorite', String(filters.is_favorite));
    params.append('page', String(filters?.page || 1));
    params.append('page_size', String(filters?.page_size || 24));

    const response = await apiClient.get<PaginatedResponse<Item>>(`/api/v1/items/?${params.toString()}`);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get a single item by ID
 */
export async function getItem(id: string): Promise<Item> {
  try {
    const response = await apiClient.get<Item>(`/api/v1/items/${id}`);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Update an existing item
 */
export async function updateItem(id: string, data: Partial<ItemFormData>): Promise<Item> {
  try {
    const response = await apiClient.put<Item>(`/api/v1/items/${id}`, data);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Delete an item
 */
export async function deleteItem(id: string): Promise<{ message: string }> {
  try {
    const response = await apiClient.delete<{ message: string }>(`/api/v1/items/${id}`);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Toggle favorite status of an item
 */
export async function toggleItemFavorite(id: string): Promise<Item> {
  try {
    const response = await apiClient.post<Item>(`/api/v1/items/${id}/favorite`);
    return response.data;
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
): Promise<{ image_url: string; thumbnail_url: string }> {
  try {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('is_primary', String(isPrimary));

    const response = await apiClient.post<{ image_url: string; thumbnail_url: string }>(
      `/api/v1/items/${itemId}/images`,
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
 * Delete an item image
 */
export async function deleteItemImage(itemId: string, imageId: string): Promise<{ message: string }> {
  try {
    const response = await apiClient.delete<{ message: string }>(
      `/api/v1/items/${itemId}/images/${imageId}`
    );
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Mark item as worn
 */
export async function markItemAsWorn(id: string): Promise<Item> {
  try {
    const response = await apiClient.post<Item>(`/api/v1/items/${id}/wear`);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Batch delete multiple items
 */
export async function batchDeleteItems(itemIds: string[]): Promise<{ message: string; deleted_count: number }> {
  try {
    const response = await apiClient.post<{ message: string; deleted_count: number }>(
      '/api/v1/items/batch-delete',
      { item_ids: itemIds }
    );
    return response.data;
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
    const response = await apiClient.get('/api/v1/items/stats');
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get items by category
 */
export async function getItemsByCategory(category: string): Promise<Item[]> {
  try {
    const response = await apiClient.get<Item[]>(`/api/v1/items/by-category/${category}`);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Search items by query
 */
export async function searchItems(query: string, limit: number = 10): Promise<Item[]> {
  try {
    const response = await apiClient.get<Item[]>(`/api/v1/items/search?q=${encodeURIComponent(query)}&limit=${limit}`);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}
