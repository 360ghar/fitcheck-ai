/**
 * Authentication API endpoints
 */

import { apiClient, getTokens, setTokens, clearTokens, getApiError } from './client';
import type { ApiEnvelope, AuthTokens, LoginRequest, RegisterRequest, AuthResponse, User } from '../types';

// ============================================================================
// AUTH API FUNCTIONS
// ============================================================================

/**
 * Register a new user account
 */
export async function register(data: RegisterRequest): Promise<AuthResponse> {
  try {
    const response = await apiClient.post<ApiEnvelope<AuthResponse>>('/api/v1/auth/register', data);
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
    const response = await apiClient.post<ApiEnvelope<AuthResponse>>('/api/v1/auth/login', data);
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
    await apiClient.post('/api/v1/auth/logout');
  } catch (error) {
    console.warn('Logout request failed:', getApiError(error));
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
      '/api/v1/auth/refresh',
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
    const response = await apiClient.post<{ message: string }>('/api/v1/auth/reset-password', { email });
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
    const response = await apiClient.post<{ message: string }>('/api/v1/auth/confirm-reset-password', data);
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
 * Get initial auth state from storage
 */
export function getInitialAuthState(): { tokens: AuthTokens | null; user: User | null } {
  const tokens = getTokens();

  // Parse user from storage if available
  let user: User | null = null;
  try {
    const storedUser = localStorage.getItem('fitcheck_user');
    user = storedUser ? JSON.parse(storedUser) : null;
  } catch {
    user = null;
  }

  return { tokens, user };
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
  const response = await apiClient.post<ApiEnvelope<{
    user: User;
    is_new_user: boolean;
    referral?: {
      success: boolean;
      message: string;
      credit_months: number;
    };
  }>>(
    '/api/v1/auth/oauth/sync',
    { referral_code: referralCode },
    {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    }
  );
  return response.data.data;
}
