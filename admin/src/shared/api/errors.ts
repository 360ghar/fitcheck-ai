/**
 * Error normalization. Every failure path in the app funnels through here:
 * transport errors, HTTP errors, and the backend's `{error, code, details}`
 * envelope are all reduced to a typed `ApiError` with a stable `code` that
 * features map to i18n keys.
 */

export interface ApiErrorShape {
  /** HTTP status; 0 = transport/network failure */
  status: number
  /** Stable machine code (backend `code`, or a client-side code) */
  code: string
  /** Human message — backend-provided or a client-side fallback */
  message: string
  /** Backend `details` payload, when present */
  details?: Record<string, unknown>
  /** Field-level validation errors: field name → message */
  fieldErrors?: Record<string, string>
  /** Backend `correlation_id`, when present (support reference) */
  correlationId?: string
}

export class ApiError extends Error {
  readonly status: number
  readonly code: string
  readonly details: Record<string, unknown> | undefined
  readonly fieldErrors: Record<string, string> | undefined
  readonly correlationId: string | undefined

  constructor(shape: ApiErrorShape) {
    super(shape.message)
    this.name = 'ApiError'
    this.status = shape.status
    this.code = shape.code
    this.details = shape.details
    this.fieldErrors = shape.fieldErrors
    this.correlationId = shape.correlationId
  }
}

export function isApiError(error: unknown): error is ApiError {
  return error instanceof ApiError
}

export const NETWORK_ERROR_CODE = 'NETWORK_ERROR'
export const PARSE_ERROR_CODE = 'PARSE_ERROR'
export const PERMISSION_DENIED_CODE = 'PERMISSION_DENIED'
export const UNAUTHORIZED_CODE = 'AUTH_UNAUTHORIZED'

/**
 * Extract a stable code + message from an unknown failure. Non-ApiError
 * values (bugs, thrown strings) collapse into a generic INTERNAL_ERROR.
 */
export function normalizeError(error: unknown): ApiError {
  if (isApiError(error)) return error
  if (error instanceof Error) {
    return new ApiError({
      status: 0,
      code: 'INTERNAL_ERROR',
      message: error.message,
    })
  }
  return new ApiError({
    status: 0,
    code: 'INTERNAL_ERROR',
    message: 'An unexpected error occurred',
  })
}

/**
 * Map an ApiError to an i18n key. Features use this to turn stable codes into
 * user-facing copy; unknown codes fall back to the generic error key.
 */
export function apiErrorToI18nKey(error: ApiError, prefix = 'errors'): string {
  if (error.status === 0) return `${prefix}:network.title`
  switch (error.code) {
    case PERMISSION_DENIED_CODE:
      return `${prefix}:forbidden.title`
    case UNAUTHORIZED_CODE:
      return `${prefix}:unauthorized.title`
    case 'AUTH_INVALID_CREDENTIALS':
      return 'auth:errors.invalidCredentials'
    case 'AUTH_EMAIL_NOT_CONFIRMED':
      return 'auth:errors.emailNotConfirmed'
    case 'AUTH_TOKEN_EXPIRED':
      return `${prefix}:sessionExpired`
    default:
      return `${prefix}:generic.title`
  }
}
