/**
 * Users API endpoints
 */

import { apiClient, getApiError } from './client';
import type {
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
    const response = await apiClient.get<User>('/api/v1/users/me');
    return response.data;
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
}): Promise<User> {
  try {
    const response = await apiClient.put<User>('/api/v1/users/me', data);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Delete current user account
 */
export async function deleteAccount(): Promise<{ message: string }> {
  try {
    const response = await apiClient.delete<{ message: string }>('/api/v1/users/me');
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get user preferences
 */
export async function getUserPreferences(): Promise<UserPreferences> {
  try {
    const response = await apiClient.get<UserPreferences>('/api/v1/users/preferences');
    return response.data;
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
  style_notes?: string;
}): Promise<UserPreferences> {
  try {
    const response = await apiClient.put<UserPreferences>('/api/v1/users/preferences', data);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get user settings
 */
export async function getUserSettings(): Promise<UserSettings> {
  try {
    const response = await apiClient.get<UserSettings>('/api/v1/users/settings');
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Update user settings
 */
export async function updateUserSettings(data: {
  language?: string;
  measurement_units?: 'imperial' | 'metric';
  notifications_enabled?: boolean;
  email_marketing?: boolean;
  dark_mode?: boolean;
}): Promise<UserSettings> {
  try {
    const response = await apiClient.put<UserSettings>('/api/v1/users/settings', data);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get body profile
 */
export async function getBodyProfile(): Promise<BodyProfile> {
  try {
    const response = await apiClient.get<BodyProfile>('/api/v1/users/body-profile');
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Create or update body profile
 */
export async function updateBodyProfile(data: {
  height?: number;
  weight?: number;
  body_type?: string;
  skin_tone?: string;
  hair_color?: string;
  eye_color?: string;
  notes?: string;
}): Promise<BodyProfile> {
  try {
    const response = await apiClient.put<BodyProfile>('/api/v1/users/body-profile', data);
    return response.data;
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

    const response = await apiClient.post<{ avatar_url: string }>(
      '/api/v1/users/me/avatar',
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
    const response = await apiClient.get('/api/v1/users/dashboard');
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}
