import { env } from '@/config/env'
import { ApiError, isApiError, PARSE_ERROR_CODE } from '@/shared/api/errors'
import { getTokens, setTokens } from '@/shared/api/tokens'
import type { RefreshEnvelope } from '@/shared/api/types'

/**
 * Thin fetch wrapper over VITE_API_BASE_URL (default: same-origin, where the
 * Vite dev proxy / Netlify redirect forwards /api → the backend).
 *
 * Responsibilities:
 *   - attaches `Authorization: Bearer <token>` from token storage
 *   - parses backend errors ({error, code, details}) and FastAPI 422
 *     validation errors into a typed ApiError
 *   - on 401 (non-auth endpoint): attempts a silent single-flight token
 *     refresh (`POST /api/v1/auth/refresh`) and retries the failed request
 *     ONCE with the fresh token. Only when the refresh fails (or no refresh
 *     token exists) does it dispatch `session:unauthorized` so the session
 *     store can log out (auth endpoints are excluded — a failed login is
 *     not a session expiry)
 *   - honors abort signals
 */

export interface RequestOptions extends Omit<RequestInit, 'body' | 'headers'> {
  body?: unknown
  headers?: HeadersInit
  /** Skip the Authorization header (e.g. public endpoints) */
  skipAuth?: boolean
  /** Skip dispatching `session:unauthorized` on 401 */
  skipUnauthorizedEvent?: boolean
  /**
   * Internal: true on the single retry that follows a successful token
   * refresh. A 401 on a retried request is terminal — it dispatches the
   * unauthorized event instead of triggering another refresh (no loops).
   */
  retried?: boolean
}

/** Event dispatched on 401 so sessionStore can logout/refresh. */
export const SESSION_UNAUTHORIZED_EVENT = 'session:unauthorized'

export function dispatchUnauthorized(): void {
  if (typeof window !== 'undefined') {
    window.dispatchEvent(new CustomEvent(SESSION_UNAUTHORIZED_EVENT))
  }
}

const AUTH_PATHS = ['/api/v1/auth/login', '/api/v1/auth/refresh', '/api/v1/auth/logout']

function isAuthPath(path: string): boolean {
  return AUTH_PATHS.some((authPath) => path.startsWith(authPath))
}

// ────────────────────────────────────────────────────────────────────────────
// Silent token refresh (single-flight)
//
// Mirrors the proven frontend pattern (frontend/src/api/client.ts
// ensureFreshToken): concurrent 401s share ONE in-flight refresh request,
// and a refresh token the server definitively rejected (401/400 — rotated
// out, expired, revoked) is latched so the burst cannot re-present the dead
// token once per 401 handler. A fresh login issues a new refresh token, so
// the latch is scoped to the token value, not a boolean.
// ────────────────────────────────────────────────────────────────────────────

/** In-flight refresh promise — concurrent 401s await the same request. */
let refreshPromise: Promise<boolean> | null = null

/** Refresh token the server rejected; further refreshes with it fail fast. */
let failedRefreshToken: string | null = null

/**
 * Refresh the access token via `POST /api/v1/auth/refresh`. Resolves true
 * when new tokens were stored, false when there is nothing to refresh with
 * or the refresh was rejected/failed. Never throws — callers treat `false`
 * as "session is dead".
 */
export async function refreshAccessToken(): Promise<boolean> {
  const tokens = getTokens()
  if (failedRefreshToken !== null && tokens?.refresh_token === failedRefreshToken) {
    // Definitive rejection — don't re-present a dead token.
    return false
  }
  if (refreshPromise) return refreshPromise

  refreshPromise = (async () => {
    const current = getTokens()
    if (!current?.refresh_token) return false
    try {
      const envelope = await apiRequest<RefreshEnvelope>('/api/v1/auth/refresh', {
        method: 'POST',
        body: { refresh_token: current.refresh_token },
        skipAuth: true,
        skipUnauthorizedEvent: true,
      })
      const data = envelope?.data
      if (!data?.access_token || !data?.refresh_token) return false
      setTokens({ access_token: data.access_token, refresh_token: data.refresh_token })
      failedRefreshToken = null
      return true
    } catch (error) {
      // Only a definitive server rejection of the token itself is permanent;
      // a network blip must stay retryable.
      const status = isApiError(error) ? error.status : 0
      if (status === 401 || status === 400) {
        failedRefreshToken = current.refresh_token
      }
      return false
    } finally {
      refreshPromise = null
    }
  })()

  return refreshPromise
}

function buildUrl(path: string): string {
  if (/^https?:\/\//.test(path)) return path
  const base = env.VITE_API_BASE_URL.replace(/\/+$/, '')
  return `${base}${path}`
}

interface BackendErrorBody {
  error?: unknown
  code?: unknown
  details?: unknown
}

function parseFieldErrors(details: unknown): Record<string, string> | undefined {
  if (typeof details !== 'object' || details === null) return undefined
  const candidate = (details as Record<string, unknown>)['field_errors']
  if (typeof candidate !== 'object' || candidate === null) return undefined
  const out: Record<string, string> = {}
  for (const [key, value] of Object.entries(candidate as Record<string, unknown>)) {
    out[key] = typeof value === 'string' ? value : JSON.stringify(value)
  }
  return Object.keys(out).length > 0 ? out : undefined
}

/**
 * Normalize a non-2xx response body into ApiError fields. Handles:
 *   - backend envelope: { error, code, details, correlation_id }
 *   - FastAPI 422: { detail: [{ loc: ['body','field'], msg, type }] }
 *   - FastAPI HTTPException: { detail: 'string' }
 */
function parseErrorResponse(
  status: number,
  body: unknown,
): {
  code: string
  message: string
  details: Record<string, unknown> | undefined
  fieldErrors: Record<string, string> | undefined
  correlationId: string | undefined
} {
  if (typeof body === 'object' && body !== null) {
    const record = body as BackendErrorBody & { detail?: unknown; correlation_id?: unknown }
    if (typeof record.error === 'string') {
      const code = typeof record.code === 'string' ? record.code : 'INTERNAL_ERROR'
      const details =
        typeof record.details === 'object' && record.details !== null
          ? (record.details as Record<string, unknown>)
          : undefined
      return {
        code,
        message: record.error,
        details,
        fieldErrors: parseFieldErrors(details),
        correlationId:
          typeof record.correlation_id === 'string' ? record.correlation_id : undefined,
      }
    }
    if (Array.isArray(record.detail)) {
      const fieldErrors: Record<string, string> = {}
      let firstMessage = 'Validation failed'
      for (const item of record.detail as unknown[]) {
        if (typeof item !== 'object' || item === null) continue
        const entry = item as { loc?: unknown; msg?: unknown }
        const msg = typeof entry.msg === 'string' ? entry.msg : 'Invalid value'
        if (Array.isArray(entry.loc)) {
          const field = entry.loc
            .filter((part): part is string => typeof part === 'string')
            .join('.')
          if (field) fieldErrors[field] = msg
        }
        if (firstMessage === 'Validation failed') firstMessage = msg
      }
      return {
        code: 'VALIDATION_ERROR',
        message: firstMessage,
        details: undefined,
        fieldErrors: Object.keys(fieldErrors).length > 0 ? fieldErrors : undefined,
        correlationId:
          typeof record.correlation_id === 'string' ? record.correlation_id : undefined,
      }
    }
    if (typeof record.detail === 'string') {
      return {
        code: 'INTERNAL_ERROR',
        message: record.detail,
        details: undefined,
        fieldErrors: undefined,
        correlationId:
          typeof record.correlation_id === 'string' ? record.correlation_id : undefined,
      }
    }
  }
  return {
    code: 'INTERNAL_ERROR',
    message: `Request failed with status ${status}`,
    details: undefined,
    fieldErrors: undefined,
    correlationId: undefined,
  }
}

export async function apiRequest<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const { body, skipAuth = false, skipUnauthorizedEvent = false, retried = false, headers, ...init } = options
  const url = buildUrl(path)
  const mergedHeaders = new Headers(headers)
  if (body !== undefined && !(body instanceof FormData)) {
    mergedHeaders.set('Content-Type', 'application/json')
  }
  const tokens = getTokens()
  if (!skipAuth && tokens?.access_token) {
    mergedHeaders.set('Authorization', `Bearer ${tokens.access_token}`)
  }

  let response: Response
  try {
    response = await fetch(url, {
      ...init,
      headers: mergedHeaders,
      ...(body !== undefined
        ? { body: body instanceof FormData ? body : JSON.stringify(body) }
        : {}),
    })
  } catch (error) {
    if (error instanceof DOMException && error.name === 'AbortError') {
      throw error
    }
    const message = error instanceof Error ? error.message : 'Network request failed'
    throw new ApiError({ status: 0, code: 'NETWORK_ERROR', message })
  }

  if (response.status === 401 && !skipUnauthorizedEvent && !isAuthPath(path)) {
    if (retried) {
      // A retry with a freshly-refreshed token still 401'd — the session is
      // definitively dead. Never refresh again for this request (no loops).
      dispatchUnauthorized()
    } else if (await refreshAccessToken()) {
      // Tokens rotated — replay this request exactly once with the new token.
      return apiRequest<T>(path, { ...options, retried: true })
    } else {
      // Nothing to refresh with, or the refresh was rejected/expired.
      dispatchUnauthorized()
    }
  }

  const text = await response.text()
  let parsed: unknown = null
  if (text) {
    try {
      parsed = JSON.parse(text)
    } catch {
      parsed = null
    }
  }

  if (!response.ok) {
    const errorBody = parseErrorResponse(response.status, parsed)
    throw new ApiError({
      status: response.status,
      code: errorBody.code,
      message: errorBody.message,
      ...(errorBody.details !== undefined ? { details: errorBody.details } : {}),
      ...(errorBody.fieldErrors !== undefined ? { fieldErrors: errorBody.fieldErrors } : {}),
      ...(errorBody.correlationId !== undefined
        ? { correlationId: errorBody.correlationId }
        : {}),
    })
  }

  if (parsed === null) {
    // 204-style empty responses
    return undefined as T
  }
  if (typeof parsed !== 'object') {
    throw new ApiError({
      status: response.status,
      code: PARSE_ERROR_CODE,
      message: 'Unexpected response payload',
    })
  }
  return parsed as T
}

/** GET shorthand. */
export function apiGet<T>(path: string, options: RequestOptions = {}): Promise<T> {
  return apiRequest<T>(path, { ...options, method: 'GET' })
}

/** POST shorthand. */
export function apiPost<T>(path: string, body?: unknown, options: RequestOptions = {}): Promise<T> {
  return apiRequest<T>(path, { ...options, method: 'POST', body })
}

/** PATCH shorthand. */
export function apiPatch<T>(path: string, body?: unknown, options: RequestOptions = {}): Promise<T> {
  return apiRequest<T>(path, { ...options, method: 'PATCH', body })
}

/** PUT shorthand. */
export function apiPut<T>(path: string, body?: unknown, options: RequestOptions = {}): Promise<T> {
  return apiRequest<T>(path, { ...options, method: 'PUT', body })
}

/** DELETE shorthand. */
export function apiDelete<T>(path: string, options: RequestOptions = {}): Promise<T> {
  return apiRequest<T>(path, { ...options, method: 'DELETE' })
}
