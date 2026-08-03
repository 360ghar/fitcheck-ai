/**
 * Thin API error envelope shared by HTTP callers and Zustand stores.
 *
 * Stores must not depend on the Axios transport layer; extracting this type
 * keeps api/ and stores/ in separate modules even though both consume it.
 */

export interface ApiError {
  message: string
  code?: string
  status?: number
  details?: unknown
  correlationId?: string
  /** Backend AI-error bucket ("upstream_quota" | "transient" | "hard") for
   * capacity/provider failures that are "on us" — NOT the user's plan limit.
   * Lets the UI show "try again shortly" instead of an upgrade prompt. */
  errorKind?: string
  /** Advised retry delay (seconds) from the provider's RetryInfo, when present. */
  retryAfterSeconds?: number
}

/**
 * Backend error code for a deterministic quota-exhausted response. A 429
 * carrying this code is the user's OWN plan limit (raised pre-flight), so it
 * cannot clear within seconds — retrying it only multiplies duplicate
 * requests and delays the upgrade prompt.
 */
export const RATE_LIMIT_EXCEEDED = 'RATE_LIMIT_EXCEEDED' as const

/**
 * True when an HTTP error is a deterministic quota-exhausted 429.
 *
 * Shared by the axios retry interceptor and `withRetry()` so both retry
 * layers agree on which 429s are the user's own plan limit (never retry) vs
 * upstream capacity (retry with backoff).
 */
export function isRateLimitExhausted(error: unknown): boolean {
  if (typeof error !== 'object' || error === null) return false
  const response = (error as { response?: { status?: number; data?: unknown } }).response
  if (response?.status !== 429) return false
  const data = response.data as { code?: string } | undefined
  return typeof data === 'object' && data !== null && data.code === RATE_LIMIT_EXCEEDED
}

export function isApiError(error: unknown): error is ApiError {
  return (
    typeof error === 'object' &&
    error !== null &&
    'message' in error &&
    typeof (error as ApiError).message === 'string'
  )
}

/**
 * True for Axios errors (duck-typed via the `isAxiosError` flag), matching
 * the check inside `getApiError`. Shared so error-copy helpers that need to
 * distinguish "transport-level failure with no response" from plain local
 * Errors don't each re-implement the same duck-typing.
 */
export function isAxiosLike(error: unknown): boolean {
  return typeof error === 'object' && error !== null && 'isAxiosError' in error
}

/**
 * Extract a normalized API error from an Axios error or unknown error.
 *
 * Duck-types Axios errors via `isAxiosError` flag so this module stays
 * framework-agnostic (no `axios` import). When the caller knows it has an
 * AxiosError, the dedicated extractor in `api/client.ts` is equivalent.
 */
export function getApiError(error: unknown): ApiError {
  // Axios-like error: extract status, code, correlationId from response.
  // Must check BEFORE the generic isApiError guard because AxiosError already
  // has a `message` property which would match isApiError and bypass the
  // response-metadata extraction below.
  if (isAxiosLike(error)) {
    const resp = (error as { response?: { status?: number; data?: Record<string, unknown>; headers?: Record<string, string> } }).response
    const status = resp?.status
    const data = resp?.data as
      | { error?: string; detail?: string; message?: string; code?: string; details?: unknown; correlation_id?: string; error_kind?: string; retry_after_seconds?: number }
      | undefined
    const headers = resp?.headers
    const correlationId =
      headers?.['x-correlation-id'] || data?.correlation_id || undefined
    const message =
      data?.error || data?.detail || data?.message ||
      (error as { message?: string }).message || 'An error occurred'
    return {
      message,
      code: data?.code,
      status,
      details: data?.details ?? data,
      correlationId,
      errorKind: data?.error_kind,
      retryAfterSeconds: data?.retry_after_seconds,
    }
  }

  // Already an ApiError-shaped object — return as-is.
  if (isApiError(error)) {
    return error
  }

  if (error instanceof Error) {
    return { message: error.message }
  }

  return { message: 'An unknown error occurred' }
}
