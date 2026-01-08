/**
 * Axios HTTP client with authentication interceptors
 */

import axios, { AxiosError, InternalAxiosRequestConfig, AxiosResponse } from 'axios';
import { showApiError, showWarning, showNetworkError } from '@/lib/toast-utils';

// ============================================================================
// AXIOS CONFIG TYPE EXTENSION
// ============================================================================

declare module 'axios' {
  export interface InternalAxiosRequestConfig {
    _skipToast?: boolean;
  }
}

// ============================================================================
// SILENT ERROR CODES - These errors won't show toast notifications
// ============================================================================

const SILENT_ERROR_CODES = new Set([
  'AUTH_UNAUTHORIZED',
  'AUTH_TOKEN_EXPIRED',
]);

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ||
  import.meta.env.VITE_API_URL ||
  'http://localhost:8000';

// ============================================================================
// AXIOS INSTANCE
// ============================================================================

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 600000, // 10 minutes
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: false,
});

// ============================================================================
// TOKEN STORAGE
// ============================================================================

const TOKEN_STORAGE_KEY = 'fitcheck_auth_tokens';
const AUTH_STORAGE_KEY = 'fitcheck-auth-storage';
const USER_STORAGE_KEY = 'fitcheck_user';

// ============================================================================
// AUTH ENDPOINTS - Skip 401 handling for these (they return 401 for invalid credentials)
// ============================================================================

const AUTH_ENDPOINTS = [
  '/api/v1/auth/login',
  '/api/v1/auth/register',
  '/api/v1/auth/refresh',
  '/api/v1/auth/reset-password',
  '/api/v1/auth/confirm-reset-password',
];

function isAuthEndpoint(url: string | undefined): boolean {
  if (!url) return false;
  return AUTH_ENDPOINTS.some(endpoint => url.includes(endpoint));
}

export interface AuthTokens {
  access_token: string;
  refresh_token: string;
}

export function getTokens(): AuthTokens | null {
  try {
    const stored = localStorage.getItem(TOKEN_STORAGE_KEY);
    return stored ? JSON.parse(stored) : null;
  } catch {
    return null;
  }
}

export function setTokens(tokens: AuthTokens): void {
  localStorage.setItem(TOKEN_STORAGE_KEY, JSON.stringify(tokens));
}

export function clearTokens(): void {
  localStorage.removeItem(TOKEN_STORAGE_KEY);
}

function clearAuthStorage(): void {
  clearTokens();
  localStorage.removeItem(AUTH_STORAGE_KEY);
  localStorage.removeItem(USER_STORAGE_KEY);
}

function forceLogout(): void {
  if (hasForcedLogout) return;
  hasForcedLogout = true;
  clearAuthStorage();
  if (typeof window !== 'undefined') {
    window.location.href = '/auth/login';
  }
}

/**
 * Reset the forced logout flag. Call this after successful login.
 */
export function resetForcedLogoutFlag(): void {
  hasForcedLogout = false;
}

export function getAccessToken(): string | null {
  return getTokens()?.access_token || null;
}

// ============================================================================
// REQUEST INTERCEPTOR - Add auth token
// ============================================================================

apiClient.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = getAccessToken();
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error: AxiosError) => {
    return Promise.reject(error);
  }
);

// ============================================================================
// RESPONSE INTERCEPTOR - Handle 401 and token refresh
// ============================================================================

let isRefreshing = false;
let hasForcedLogout = false;
let failedQueue: Array<{
  resolve: (value?: unknown) => void;
  reject: (reason?: unknown) => void;
}> = [];

const processQueue = (error: Error | null = null) => {
  failedQueue.forEach(({ resolve, reject }) => {
    if (error) {
      reject(error);
    } else {
      resolve();
    }
  });
  failedQueue = [];
};

apiClient.interceptors.response.use(
  (response: AxiosResponse) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & {
      _retry?: boolean;
      _skipAuth?: boolean;
    };

    // Skip 401 handling for auth endpoints - they return 401 for invalid credentials,
    // not expired tokens, so we should let the error bubble up to the UI
    const skipAuthHandling =
      originalRequest._skipAuth ||
      isAuthEndpoint(originalRequest.url);

    if (error.response?.status === 401 && !skipAuthHandling) {
      if (originalRequest._retry) {
        forceLogout();
        return Promise.reject(error);
      }

      if (hasForcedLogout) {
        return Promise.reject(error);
      }

      if (isRefreshing) {
        // Queue the request while refreshing
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        })
          .then(() => apiClient(originalRequest))
          .catch((err) => Promise.reject(err));
      }

      originalRequest._retry = true;
      isRefreshing = true;

      try {
        const tokens = getTokens();
        if (!tokens?.refresh_token) {
          throw new Error('No refresh token available');
        }

        // Refresh the token
        const response = await axios.post<{
          data?: { access_token: string; refresh_token: string };
          access_token?: string;
          refresh_token?: string;
        }>(`${API_BASE_URL}/api/v1/auth/refresh`, { refresh_token: tokens.refresh_token });

        const refreshed = response.data?.data || response.data;
        if (!refreshed?.access_token || !refreshed?.refresh_token) {
          throw new Error('Token refresh failed');
        }

        const newTokens: AuthTokens = {
          access_token: refreshed.access_token,
          refresh_token: refreshed.refresh_token,
        };

        setTokens(newTokens);
        processQueue(null);

        // Retry original request with new token
        if (originalRequest.headers) {
          originalRequest.headers.Authorization = `Bearer ${newTokens.access_token}`;
        }

        return apiClient(originalRequest);
      } catch (refreshError) {
        processQueue(refreshError as Error);
        forceLogout();

        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }

    // ========================================================================
    // GLOBAL TOAST NOTIFICATIONS FOR API ERRORS
    // ========================================================================

    // Extract the API error for analysis
    const apiError = getApiError(error);

    // Determine if we should show a toast notification
    const shouldShowToast =
      // Not a 401 (handled by auth flow with redirect)
      error.response?.status !== 401 &&
      // Not in the silent error codes list
      !SILENT_ERROR_CODES.has(apiError.code || '') &&
      // Not explicitly skipped by the request
      !originalRequest._skipToast;

    if (shouldShowToast) {
      if (!error.response) {
        // Network error - no response received
        showNetworkError();
      } else if (error.response.status === 429) {
        // Rate limit error - show as warning
        showWarning(apiError.message || 'Too many requests. Please slow down.', 'Rate Limited');
      } else {
        // Other API errors - show with appropriate styling
        showApiError(apiError);
      }
    }

    return Promise.reject(error);
  }
);

// ============================================================================
// API ERROR TYPES
// ============================================================================

export interface ApiError {
  message: string;
  code?: string;
  status?: number;
  details?: unknown;
  correlationId?: string;
}

export function isApiError(error: unknown): error is ApiError {
  return (
    typeof error === 'object' &&
    error !== null &&
    'message' in error &&
    typeof (error as ApiError).message === 'string'
  );
}

/**
 * Extract a normalized API error from an Axios error or unknown error.
 * Logs the error with correlation ID for debugging.
 */
export function getApiError(error: unknown): ApiError {
  if (axios.isAxiosError(error)) {
    const status = error.response?.status;
    const data = error.response?.data as
      | { error?: string; detail?: string; message?: string; code?: string; details?: unknown; correlation_id?: string }
      | undefined;
    const headers = error.response?.headers;

    // Extract correlation ID from response headers or body
    const correlationId =
      headers?.['x-correlation-id'] ||
      data?.correlation_id ||
      undefined;

    const apiError: ApiError = {
      message: data?.error || data?.detail || data?.message || error.message || 'An error occurred',
      code: data?.code,
      status,
      details: data?.details ?? data,
      correlationId,
    };

    // Log the error with correlation ID for debugging (dev mode only)
    if (import.meta.env.DEV) {
      console.error('[API Error]', {
        message: apiError.message,
        code: apiError.code,
        status: apiError.status,
        correlationId: apiError.correlationId,
        url: error.config?.url,
        method: error.config?.method?.toUpperCase(),
      });
    }

    return apiError;
  }

  if (isApiError(error)) {
    return error;
  }

  if (error instanceof Error) {
    return { message: error.message };
  }

  return { message: 'An unknown error occurred' };
}

// ============================================================================
// TOAST SKIP HELPER
// ============================================================================

/**
 * Config object to skip toast notifications for a specific request.
 * Usage: apiClient.get('/endpoint', skipToast)
 */
export const skipToast = { _skipToast: true };
