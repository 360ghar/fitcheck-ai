/**
 * Authentication API endpoints
 */

import { apiClient, getTokens, setTokens, clearTokens, getApiError } from './client';
import { logger } from '@/lib/logger';
import { ENDPOINTS } from '@/lib/endpoints';
import type { AxiosRequestConfig } from 'axios';
import type { ApiEnvelope, AuthTokens, LoginRequest, RegisterRequest, AuthResponse, User } from '../types';

// ============================================================================
// AUTH API FUNCTIONS
// ============================================================================

/**
 * Register a new user account
 */
export async function register(data: RegisterRequest): Promise<AuthResponse> {
  try {
    const response = await apiClient.post<ApiEnvelope<AuthResponse>>(ENDPOINTS.AUTH.REGISTER, data);
    const payload = response.data.data;
    if (payload.access_token && payload.refresh_token) {
      setTokens({
        access_token: payload.access_token,
        refresh_token: payload.refresh_token,
      });
    } else {
      clearTokens();
    }
    return payload;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Login with email and password
 */
export async function login(data: LoginRequest): Promise<AuthResponse> {
  try {
    const response = await apiClient.post<ApiEnvelope<AuthResponse>>(ENDPOINTS.AUTH.LOGIN, data);
    const payload = response.data.data;
    if (payload.access_token && payload.refresh_token) {
      setTokens({
        access_token: payload.access_token,
        refresh_token: payload.refresh_token,
      });
    } else {
      clearTokens();
    }
    return payload;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Logout the current user
 */
export async function logout(): Promise<void> {
  try {
    await apiClient.post(ENDPOINTS.AUTH.LOGOUT);
  } catch (error) {
    logger.warn('Logout request failed:', getApiError(error));
  } finally {
    clearTokens();
  }
}

/**
 * Refresh the access token using refresh token
 */
export async function refreshAccessToken(refreshToken: string): Promise<AuthTokens> {
  try {
    const response = await apiClient.post<ApiEnvelope<{ access_token: string; refresh_token: string }>>(
      ENDPOINTS.AUTH.REFRESH,
      { refresh_token: refreshToken }
    );

    const tokens: AuthTokens = {
      access_token: response.data.data.access_token,
      refresh_token: response.data.data.refresh_token,
    };

    setTokens(tokens);
    return tokens;
  } catch (error) {
    clearTokens();
    throw getApiError(error);
  }
}

/**
 * Request a password reset email
 */
export async function requestPasswordReset(email: string): Promise<{ message: string }> {
  try {
    const response = await apiClient.post<{ message: string }>(ENDPOINTS.AUTH.RESET_PASSWORD, { email });
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Confirm password reset with token
 */
export async function confirmPasswordReset(data: {
  access_token?: string;
  refresh_token?: string;
  token?: string;
  new_password: string;
}): Promise<{ message: string }> {
  try {
    const response = await apiClient.post<{ message: string }>(ENDPOINTS.AUTH.CONFIRM_RESET_PASSWORD, data);
    return response.data;
  } catch (error) {
    throw getApiError(error);
  }
}

/**
 * Check if user is authenticated (has valid tokens)
 */
export function isAuthenticated(): boolean {
  const tokens = getTokens();
  return !!tokens?.access_token;
}

/**
 * Store user data in localStorage
 */
export function storeUser(user: User): void {
  localStorage.setItem('fitcheck_user', JSON.stringify(user));
}

/**
 * Clear user data from localStorage
 */
export function clearUser(): void {
  localStorage.removeItem('fitcheck_user');
}

/**
 * Sync OAuth profile with backend after OAuth authentication
 * Creates user profile if it doesn't exist
 */
export async function syncOAuthProfile(accessToken: string, referralCode?: string): Promise<{
  user: User;
  is_new_user: boolean;
  referral?: {
    success: boolean;
    message: string;
    credit_months: number;
  };
}> {
  // `_skipAuth` opts this request out of the client's 401 refresh/retry (and
  // forced-logout). A 401 here means the Supabase OAuth session token is
  // invalid/expired, not that the app's own token needs refreshing — retrying
  // would swap in the app's localStorage token and sync the WRONG user's
  // profile. Skip handling so the error surfaces to the auth callback's own
  // error state instead.
  const config = {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
    _skipAuth: true,
  } as AxiosRequestConfig & { _skipAuth?: boolean };

  const response = await apiClient.post<ApiEnvelope<{
    user: User;
    is_new_user: boolean;
    referral?: {
      success: boolean;
      message: string;
      credit_months: number;
    };
  }>>(
    ENDPOINTS.AUTH.OAUTH_SYNC,
    { referral_code: referralCode },
    config,
  );
  return response.data.data;
}
