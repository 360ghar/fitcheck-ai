/**
 * Recommendations API endpoints
 */

import { isAxiosError } from 'axios';

import { apiClient, getApiError, skipToast } from './client';
import { logger } from '../lib/logger';
import type {
  ApiEnvelope,
  MatchResult,
  CompleteLookSuggestion,
  WeatherRecommendation,
  AstrologyRecommendation,
  AstrologyRecommendationMode,
} from '../types';

// ============================================================================
// RECOMMENDATIONS API FUNCTIONS
// ============================================================================

/**
 * Find matching items for a given item
 */
export async function findMatchingItems(
  itemId: string,
  options?: {
    category?: string;
    limit?: number;
    min_score?: number;
  }
): Promise<{ matches: MatchResult[]; complete_looks: CompleteLookSuggestion[] }> {
  try {
    const params = new URLSearchParams();
    if (options?.category) params.append('category', options.category);
    if (options?.limit) params.append('limit', String(options.limit));
    if (options?.min_score) params.append('min_score', String(options.min_score));

    const response = await apiClient.post<
      ApiEnvelope<{
        matches: MatchResult[];
        complete_looks: CompleteLookSuggestion[];
      }>
    >(
      `/api/v1/recommendations/match?${params.toString()}`,
      { item_id: itemId }
    );
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get complete outfit suggestions based on selected items
 */
export async function getCompleteLookSuggestions(
  itemIds: string[],
  options?: {
    style?: string;
    occasion?: string;
    limit?: number;
  }
): Promise<CompleteLookSuggestion[]> {
  try {
    const params = new URLSearchParams();
    if (options?.style) params.append('style', options.style);
    if (options?.occasion) params.append('occasion', options.occasion);
    if (options?.limit) params.append('limit', String(options.limit));

    const response = await apiClient.post<
      ApiEnvelope<{
        complete_looks: CompleteLookSuggestion[];
      }>
    >(
      `/api/v1/recommendations/complete-look?${params.toString()}`,
      { item_ids: itemIds },
      // The only caller degrades to client-side suggestions on failure and
      // deliberately stays silent when that works — an interceptor toast would
      // contradict a recovery the user never sees fail.
      skipToast
    );

    // Defensive: ensure we always return an array
    const looks = response.data?.data?.complete_looks;
    if (!Array.isArray(looks)) {
      logger.warn('[recommendations] Unexpected response structure from complete-look API:', response.data);
      return [];
    }
    return looks;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get weather-based outfit recommendations
 */
export async function getWeatherRecommendations(
  location?: string
): Promise<WeatherRecommendation> {
  try {
    const params = location ? `?location=${encodeURIComponent(location)}` : '';
    const response = await apiClient.get<ApiEnvelope<WeatherRecommendation>>(
      `/api/v1/recommendations/weather${params}`
    );
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get astrology-based lucky colors and wardrobe picks
 */
export async function getAstrologyRecommendations(options?: {
  target_date?: string;
  mode?: AstrologyRecommendationMode;
  limit_per_category?: number;
}): Promise<AstrologyRecommendation> {
  try {
    const params = new URLSearchParams();
    if (options?.target_date) params.append('target_date', options.target_date);
    if (options?.mode) params.append('mode', options.mode);
    if (options?.limit_per_category) params.append('limit_per_category', String(options.limit_per_category));

    const queryString = params.toString();
    const endpoint = queryString
      ? `/api/v1/recommendations/astrology?${queryString}`
      : '/api/v1/recommendations/astrology';
    // The caller drops responses from superseded requests (fast date/mode
    // switching) and rewrites the 404 below into actionable copy, so it owns
    // the toast for this endpoint.
    const response = await apiClient.get<ApiEnvelope<AstrologyRecommendation>>(endpoint, skipToast);
    return response.data.data;
  } catch (error) {
    if (isAxiosError(error) && error.response?.status === 404) {
      throw new Error(
        'Astrology API is not available on the current backend deployment. Please update backend routes.',
      );
    }
    throw getApiError(error);
  }
}

/**
 * Get shopping recommendations based on wardrobe
 */
export async function getShoppingRecommendations(options?: {
  category?: string;
  budget?: number;
  style?: string;
}): Promise<Array<{
  category: string;
  description: string;
  priority: 'high' | 'medium' | 'low';
  suggested_brands?: string[];
  price_range?: { min: number; max: number };
}>> {
  try {
    const params = new URLSearchParams();
    if (options?.category) params.append('category', options.category);
    if (options?.budget) params.append('budget', String(options.budget));
    if (options?.style) params.append('style', options.style);

    const response = await apiClient.get<ApiEnvelope<
      Array<{
        category: string;
        description: string;
        priority: 'high' | 'medium' | 'low';
        suggested_brands?: string[];
        price_range?: { min: number; max: number };
      }>
    >>(`/api/v1/recommendations/shopping?${params.toString()}`);
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}
