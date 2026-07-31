/**
 * Users API endpoints
 */

import { apiClient, getApiError } from './client';
import { ENDPOINTS } from '@/lib/endpoints';
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
    const response = await apiClient.get<ApiEnvelope<User>>(ENDPOINTS.USERS.ME);
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
    const response = await apiClient.put<ApiEnvelope<User>>(ENDPOINTS.USERS.ME, data);
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
    await apiClient.delete(ENDPOINTS.USERS.ME);
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Get user preferences
 */
export async function getUserPreferences(): Promise<UserPreferences> {
  try {
    const response = await apiClient.get<ApiEnvelope<UserPreferences>>(ENDPOINTS.USERS.PREFERENCES);
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
  color_temperature?: string | null;
  style_personality?: string | null;
  data_points_collected?: number;
}): Promise<UserPreferences> {
  try {
    const response = await apiClient.put<ApiEnvelope<UserPreferences>>(ENDPOINTS.USERS.PREFERENCES, data);
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
    const response = await apiClient.get<ApiEnvelope<UserSettings>>(ENDPOINTS.USERS.SETTINGS);
    return response.data.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Update user settings
 */
export async function updateUserSettings(data: {
  default_location?: string | null;
  timezone?: string;
  language?: string;
  measurement_units?: 'imperial' | 'metric';
  notifications_enabled?: boolean;
  email_marketing?: boolean;
  dark_mode?: boolean;
}): Promise<UserSettings> {
  try {
    const response = await apiClient.put<ApiEnvelope<UserSettings>>(ENDPOINTS.USERS.SETTINGS, data);
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
      ENDPOINTS.USERS.AVATAR,
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
