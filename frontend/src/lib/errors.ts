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
  // Already an ApiError-shaped object — return as-is.
  if (isApiError(error)) {
    return error
  }

  // Axios-like error: extract status, code, correlationId from response.
  if (typeof error === 'object' && error !== null && 'isAxiosError' in error) {
    const resp = (error as { response?: { status?: number; data?: Record<string, unknown>; headers?: Record<string, string> } }).response
    const status = resp?.status
    const data = resp?.data as
      | { error?: string; detail?: string; message?: string; code?: string; details?: unknown; correlation_id?: string }
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
    }
  }

  if (error instanceof Error) {
    return { message: error.message }
  }

  return { message: 'An unknown error occurred' }
}
