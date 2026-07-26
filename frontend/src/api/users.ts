/**
 * Users API endpoints
 */

import { apiClient, getApiError } from './client';
import type {
  ApiEnvelope,
  User,
  UserPreferences,
  UserSettings,
} from '../types';

export interface UpdateCurrentUserResult {
  user: User;
  skippedFields: string[];
}

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
  birth_date?: string | null;
  birth_time?: string | null;
  birth_place?: string | null;
}): Promise<UpdateCurrentUserResult> {
  try {
    const response = await apiClient.put<ApiEnvelope<User>>('/api/v1/users/me', data);
    const meta = response.data.meta;
    const skippedFieldsRaw =
      meta && typeof meta === 'object' && 'skipped_fields' in meta
        ? (meta as { skipped_fields?: unknown }).skipped_fields
        : undefined;
    const skippedFields = Array.isArray(skippedFieldsRaw)
      ? skippedFieldsRaw.map((field) => String(field))
      : [];

    return {
      user: response.data.data,
      skippedFields,
    };
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
 * Upload avatar image
 */
export async function uploadAvatar(
  file: File,
  /** Real byte-upload percent (0-100); omitted (never fabricated) when the browser can't report a total. */
  onUploadPercent?: (percent: number) => void
): Promise<{ avatar_url: string }> {
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
        onUploadProgress: onUploadPercent
          ? (progressEvent) => {
              if (progressEvent.total) {
                onUploadPercent(Math.round((progressEvent.loaded / progressEvent.total) * 100));
              }
            }
          : undefined,
      }
    );
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}
