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
    _retry?: boolean;
    _retryCount?: number;
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
// TIMEOUTS + RETRY CONFIG
// ============================================================================

/**
 * Default timeout for typical CRUD requests. Kept low so a hung request fails
 * fast instead of freezing the UI for 10 minutes.
 */
const DEFAULT_TIMEOUT_MS = 30_000; // 30 seconds

/**
 * Longer timeout for AI/batch endpoints that legitimately run for a while
 * (image extraction, generation, virtual try-on, multipart batch upload).
 */
const LONG_RUNNING_TIMEOUT_MS = 600_000; // 10 minutes

/**
 * URL prefixes that map to long-running AI/batch operations. Requests matching
 * one of these get the extended timeout automatically so individual call sites
 * do not each have to remember to pass it.
 */
const LONG_RUNNING_PREFIXES = [
  '/api/v1/ai/extract-items',
  '/api/v1/ai/extract-single-item',
  '/api/v1/ai/generate-outfit',
  '/api/v1/ai/generate-product-image',
  '/api/v1/ai/try-on',
  '/api/v1/ai/batch-extract-multipart',
];

function isLongRunningRequest(url: string | undefined): boolean {
  if (!url) return false;
  return LONG_RUNNING_PREFIXES.some((prefix) => url.includes(prefix));
}

/**
 * HTTP statuses considered transient and safe to retry automatically.
 * 408 Request Timeout, 429 Too Many Requests, and 5xx server errors.
 * Client errors (400, 401, 403, 404, 409, 422) are never retried.
 */
const RETRYABLE_STATUS_CODES = new Set([408, 429, 500, 502, 503, 504]);

const MAX_RETRIES = 2; // 3 total attempts

// ============================================================================
// AXIOS INSTANCE
// ============================================================================

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: DEFAULT_TIMEOUT_MS,
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

let hasForcedLogout = false;

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
// TOKEN EXPIRY CHECK + SINGLE-FLIGHT REFRESH
// ============================================================================

/** Decode the JWT exp claim; true if expired or expiring within 30s. */
function isTokenExpired(jwt: string): boolean {
  try {
    // JWT payloads are base64url-encoded; atob only accepts base64, so
    // translate -_ and pad. Without this, any payload containing '-' or '_'
    // (very common) threw, the catch returned false, and proactive refresh
    // silently never fired for that token.
    const b64 = jwt.split('.')[1].replace(/-/g, '+').replace(/_/g, '/');
    const padded = b64.padEnd(b64.length + ((4 - (b64.length % 4)) % 4), '=');
    const payload = JSON.parse(atob(padded));
    return typeof payload.exp === 'number' && payload.exp * 1000 < Date.now() + 30_000;
  } catch {
    return false; // can't decode → let the server decide
  }
}

/** Single-flight refresh: concurrent callers share one in-flight request. */
let refreshPromise: Promise<void> | null = null;

async function ensureFreshToken(): Promise<void> {
  if (refreshPromise) return refreshPromise;

  refreshPromise = (async () => {
    try {
      const tokens = getTokens();
      if (!tokens?.refresh_token) {
        throw new Error('No refresh token available');
      }

      const response = await axios.post<{
        data?: { access_token: string; refresh_token: string };
        access_token?: string;
        refresh_token?: string;
      }>(
        `${API_BASE_URL}/api/v1/auth/refresh`,
        { refresh_token: tokens.refresh_token },
        // ponytail: explicit timeout — the global axios instance has none and
        // this call sits on the hot request path (proactive refresh). A hung
        // /auth/refresh must fail fast, not freeze every API call app-wide.
        { timeout: 15_000 }
      );

      const refreshed = response.data?.data || response.data;
      if (!refreshed?.access_token || !refreshed?.refresh_token) {
        throw new Error('Token refresh failed');
      }

      const newTokens: AuthTokens = {
        access_token: refreshed.access_token,
        refresh_token: refreshed.refresh_token,
      };

      setTokens(newTokens);

      // Keep Zustand persist in sync so rehydrate does not restore stale tokens
      try {
        const raw = localStorage.getItem(AUTH_STORAGE_KEY);
        if (raw) {
          const parsed = JSON.parse(raw) as {
            state?: { tokens?: AuthTokens; isAuthenticated?: boolean };
          };
          if (parsed?.state) {
            parsed.state.tokens = newTokens;
            parsed.state.isAuthenticated = true;
            localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(parsed));
          }
        }
      } catch {
        // Non-fatal: request-path tokens are already updated via setTokens
      }
    } finally {
      refreshPromise = null;
    }
  })();

  return refreshPromise;
}

// ============================================================================
// REQUEST INTERCEPTOR - Add auth token (proactive refresh if expired)
// ============================================================================

apiClient.interceptors.request.use(
  async (config: InternalAxiosRequestConfig) => {
    // Extend the timeout for long-running AI/batch endpoints unless the caller
    // already asked for an even longer one.
    if (isLongRunningRequest(config.url)) {
      config.timeout = Math.max(config.timeout ?? 0, LONG_RUNNING_TIMEOUT_MS);
    }

    let token = getAccessToken();

    // Proactively refresh if the token is expired and this isn't an auth endpoint
    if (token && isTokenExpired(token) && !isAuthEndpoint(config.url)) {
      try {
        await ensureFreshToken();
        token = getAccessToken();
      } catch {
        // Refresh failed; attach the stale token and let the 401 handler deal with it
      }
    }

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
// RESPONSE INTERCEPTOR - Automatic retry for transient failures
// ============================================================================

/** Sleep helper for retry backoff. */
function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Retry transient failures (network errors + 408/429/5xx) with exponential
 * backoff: 1s, then 2s. Client errors (400/401/403/404/409/422) and auth
 * endpoints are never retried. Registered before the 401/toast interceptor so
 * a successful retry is transparent and toasts only fire once retries exhaust.
 */
apiClient.interceptors.response.use(
  (response: AxiosResponse) => response,
  async (error: AxiosError) => {
    const config = error.config as InternalAxiosRequestConfig | undefined;

    // No config means we cannot retry (e.g. request setup failed).
    if (!config) {
      return Promise.reject(error);
    }

    // Never double-handle a token-refresh retry.
    if (config._retry) {
      return Promise.reject(error);
    }

    // Never retry auth endpoints — a 401 there means bad credentials.
    if (isAuthEndpoint(config.url)) {
      return Promise.reject(error);
    }

    const status = error.response?.status;
    const isNetworkError = !error.response && !!error.request;
    const isRetryable = isNetworkError || (status !== undefined && RETRYABLE_STATUS_CODES.has(status));

    if (!isRetryable) {
      return Promise.reject(error);
    }

    const retryCount = config._retryCount ?? 0;
    if (retryCount >= MAX_RETRIES) {
      return Promise.reject(error);
    }

    config._retryCount = retryCount + 1;
    // Exponential backoff: 1s, 2s.
    const backoff = 1000 * config._retryCount;

    if (import.meta.env.DEV) {
      console.warn(
        `[API Retry] ${config.method?.toUpperCase()} ${config.url} attempt ${config._retryCount}/${MAX_RETRIES} after ${backoff}ms (status=${status ?? 'network'})`
      );
    }

    await sleep(backoff);
    return apiClient(config);
  }
);

// ============================================================================
// RESPONSE INTERCEPTOR - Handle 401 and token refresh
// ============================================================================

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
      if (originalRequest._retry || hasForcedLogout) {
        forceLogout();
        return Promise.reject(error);
      }

      originalRequest._retry = true;

      try {
        await ensureFreshToken();

        // Retry original request with fresh token
        const freshToken = getAccessToken();
        if (freshToken && originalRequest.headers) {
          originalRequest.headers.Authorization = `Bearer ${freshToken}`;
        }

        return apiClient(originalRequest);
      } catch (refreshError) {
        forceLogout();
        return Promise.reject(refreshError);
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
