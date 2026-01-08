/**
 * Users API endpoints
 */

import { apiClient, getApiError } from './client';
import type {
  ApiEnvelope,
  User,
  UserPreferences,
  UserSettings,
  BodyProfile,
} from '../types';

// ============================================================================
// USERS API FUNCTIONS
// ============================================================================

/**
 * Get current user profile
 */
export async function getCurrentUser(): Promise<User> {
  try {
    const response = await apiClient.get<ApiEnvelope<User>>('/api/v1/users/me');
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Update current user profile
 */
export async function updateCurrentUser(data: {
  full_name?: string;
  avatar_url?: string;
  gender?: string | null;
}): Promise<User> {
  try {
    const response = await apiClient.put<ApiEnvelope<User>>('/api/v1/users/me', data);
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Delete current user account
 */
export async function deleteAccount(): Promise<void> {
  try {
    await apiClient.delete('/api/v1/users/me');
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get user preferences
 */
export async function getUserPreferences(): Promise<UserPreferences> {
  try {
    const response = await apiClient.get<ApiEnvelope<UserPreferences>>('/api/v1/users/preferences');
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Update user preferences
 */
export async function updateUserPreferences(data: {
  favorite_colors?: string[];
  preferred_styles?: string[];
  liked_brands?: string[];
  disliked_patterns?: string[];
  preferred_occasions?: string[];
  color_temperature?: string;
  style_personality?: string;
  data_points_collected?: number;
}): Promise<UserPreferences> {
  try {
    const response = await apiClient.put<ApiEnvelope<UserPreferences>>('/api/v1/users/preferences', data);
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get user settings
 */
export async function getUserSettings(): Promise<UserSettings> {
  try {
    const response = await apiClient.get<ApiEnvelope<UserSettings>>('/api/v1/users/settings');
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Update user settings
 */
export async function updateUserSettings(data: {
  default_location?: string;
  timezone?: string;
  language?: string;
  measurement_units?: 'imperial' | 'metric';
  notifications_enabled?: boolean;
  email_marketing?: boolean;
  dark_mode?: boolean;
}): Promise<UserSettings> {
  try {
    const response = await apiClient.put<ApiEnvelope<UserSettings>>('/api/v1/users/settings', data);
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get body profile
 */
export async function getBodyProfile(): Promise<BodyProfile> {
  try {
    const response = await apiClient.get<ApiEnvelope<BodyProfile>>('/api/v1/users/body-profile');
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Create or update body profile
 */
export async function updateBodyProfile(data: {
  name: string;
  height_cm: number;
  weight_kg: number;
  body_shape: string;
  skin_tone: string;
  is_default?: boolean;
}): Promise<BodyProfile> {
  try {
    const response = await apiClient.put<ApiEnvelope<BodyProfile>>('/api/v1/users/body-profile', data);
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Upload avatar image
 */
export async function uploadAvatar(file: File): Promise<{ avatar_url: string }> {
  try {
    const formData = new FormData();
    formData.append('file', file);

    const response = await apiClient.post<ApiEnvelope<{ avatar_url: string }>>(
      '/api/v1/users/me/avatar',
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
 * Get user dashboard data
 */
export async function getDashboardData(): Promise<{
  user: User;
  statistics: {
    total_items: number;
    total_outfits: number;
    items_added_this_month: number;
    outfits_created_this_month: number;
    most_worn_item: { name: string; times_worn: number } | null;
    favorite_items_count: number;
    favorite_outfits_count: number;
  };
  recent_activity: Array<{
    type: 'item_created' | 'outfit_created' | 'item_worn' | 'outfit_worn';
    description: string;
    timestamp: string;
  }>;
  suggestions: {
    weather_based: {
      temperature: number;
      recommendation: string;
    } | null;
    outfit_of_the_day: {
      id: string;
      name: string;
      image_url?: string;
    } | null;
  };
}> {
  try {
    const response = await apiClient.get<
      ApiEnvelope<{
        user: User;
        statistics: {
          total_items: number;
          total_outfits: number;
          items_added_this_month: number;
          outfits_created_this_month: number;
          most_worn_item: { name: string; times_worn: number } | null;
          favorite_items_count: number;
          favorite_outfits_count: number;
        };
        recent_activity: Array<{
          type: 'item_created' | 'outfit_created' | 'item_worn' | 'outfit_worn';
          description: string;
          timestamp: string;
        }>;
        suggestions: {
          weather_based: {
            temperature: number;
            recommendation: string;
          } | null;
          outfit_of_the_day: {
            id: string;
            name: string;
            image_url?: string;
          } | null;
        };
      }>
    >('/api/v1/users/dashboard');
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}
