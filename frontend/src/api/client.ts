/**
 * Axios HTTP client with authentication interceptors
 */

import axios, { AxiosError, InternalAxiosRequestConfig, AxiosResponse } from 'axios';
import { showApiError, showWarning, showNetworkError } from '@/lib/toast-utils';
import {
  AuthTokens,
  forceLogout,
  getAccessToken,
  getTokens,
  hasForcedLogout,
  isTokenExpired,
  setTokens,
} from '@/lib/auth';
import { logger } from '@/lib/logger';
import { RATE_LIMIT_EXCEEDED, getApiError as getBaseApiError, isRateLimitExhausted, type ApiError } from '@/lib/errors';
import { ENDPOINTS, LONG_RUNNING_PREFIXES } from '@/lib/endpoints';
import { useUpgradePromptStore } from '@/stores/upgradePromptStore';

// ============================================================================
// AXIOS CONFIG TYPE EXTENSION
// ============================================================================

declare module 'axios' {
  // `_skipToast` lives on the public config so callers can pass `skipToast`
  // as a per-request option; InternalAxiosRequestConfig inherits it.
  export interface AxiosRequestConfig {
    _skipToast?: boolean;
  }
  export interface InternalAxiosRequestConfig {
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
 *
 * Defined centrally in `@/lib/endpoints` to keep call sites and the timeout
 * logic from drifting apart.
 */
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
// AUTH ENDPOINTS - Skip 401 handling for these (they return 401 for invalid credentials)
// ============================================================================

// Auth endpoints that return 401 for invalid credentials (not expired tokens).
// Kept in sync with the centralized AUTH routes in `@/lib/endpoints`; only the
// credential-validation subset is excluded from refresh/retry handling so
// runtime behavior is unchanged.
const AUTH_ENDPOINTS = [
  ENDPOINTS.AUTH.LOGIN,
  ENDPOINTS.AUTH.REGISTER,
  ENDPOINTS.AUTH.REFRESH,
  ENDPOINTS.AUTH.RESET_PASSWORD,
  ENDPOINTS.AUTH.CONFIRM_RESET_PASSWORD,
] as const;

function isAuthEndpoint(url: string | undefined): boolean {
  if (!url) return false;
  return AUTH_ENDPOINTS.some((endpoint) => url.includes(endpoint));
}

export function isAuthenticated(): boolean {
  return Boolean(getAccessToken());
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
        `${API_BASE_URL}${ENDPOINTS.AUTH.REFRESH}`,
        { refresh_token: tokens.refresh_token },
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
    // A deterministic quota-exhausted response (the user's OWN plan limit,
    // raised pre-flight by the backend) cannot clear within seconds, so
    // retrying it only multiplies duplicate requests and delays the upgrade
    // prompt in the interceptor below. 429s from upstream capacity issues
    // (error_kind: upstream_quota / transient) are still retried.
    const isRetryable = !isRateLimitExhausted(error) && (isNetworkError || (status !== undefined && RETRYABLE_STATUS_CODES.has(status)));

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
      logger.warn(
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

    // The user hit THEIR OWN plan limit (backend RATE_LIMIT_EXCEEDED): this is
    // the one place we show an upgrade prompt. Upstream AI capacity issues
    // (errorKind) are "on us" and handled as a friendly retry below — never an
    // upgrade.
    if (!originalRequest._skipToast && apiError.code === RATE_LIMIT_EXCEEDED) {
      useUpgradePromptStore.getState().open('rate_limit', apiError.message);
      return Promise.reject(error);
    }

    if (shouldShowToast) {
      if (!error.response) {
        // Network error - no response received
        showNetworkError();
      } else if (apiError.errorKind === 'upstream_quota' || apiError.errorKind === 'transient') {
        // Upstream AI capacity/provider failure ("on us"): friendly retry
        // message, not the scary generic error and never an upgrade prompt.
        // "hard" errors (auth/content-policy/parse) are permanent — retrying
        // cannot resolve them, so they fall through to showApiError.
        showWarning(
          'Our AI service is busy. Please try again in a few minutes.',
          'AI busy'
        );
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

/**
 * Extract a normalized API error from an Axios error or unknown error.
 * Logs the error with correlation ID for debugging (dev mode only).
 *
 * Field extraction lives in `lib/errors.ts` (single source of truth shared
 * with stores); this wrapper only adds the client-specific DEV logging so
 * metadata (code/status/correlationId/errorKind/retryAfterSeconds) can never
 * drift between the two entry points.
 */
export function getApiError(error: unknown): ApiError {
  const apiError = getBaseApiError(error);
  if (import.meta.env.DEV) {
    const axiosError = error as AxiosError;
    logger.error('[API Error]', {
      message: apiError.message,
      code: apiError.code,
      status: apiError.status,
      correlationId: apiError.correlationId,
      url: axiosError.config?.url,
      method: axiosError.config?.method?.toUpperCase(),
    });
  }
  return apiError;
}

// ============================================================================
// TOAST SKIP HELPER
// ============================================================================

/**
 * Config object to skip toast notifications for a specific request.
 * Usage: apiClient.get('/endpoint', skipToast)
 */
export const skipToast = { _skipToast: true };

// ============================================================================
// RE-EXPORTS (convenience for consumers importing from @/api/client)
// ============================================================================

export { clearTokens, getAccessToken, getTokens, resetForcedLogoutFlag, setTokens } from '@/lib/auth';
export { isApiError, type ApiError } from '@/lib/errors';
