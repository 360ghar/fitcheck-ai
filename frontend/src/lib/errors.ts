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

export function isApiError(error: unknown): error is ApiError {
  return (
    typeof error === 'object' &&
    error !== null &&
    'message' in error &&
    typeof (error as ApiError).message === 'string'
  )
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
  if (typeof error === 'object' && error !== null && 'isAxiosError' in error) {
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
