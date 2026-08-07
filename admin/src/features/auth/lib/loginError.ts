import { isApiError } from '@/shared/api/errors'

/**
 * Map a login failure to an i18n key under the `auth` namespace.
 * Distinguishes invalid credentials, unconfirmed email, non-admin accounts
 * (403 from /me), rate limiting, and server-side failures (404/5xx) from
 * network failures and unknown errors.
 */
export function loginErrorKey(error: unknown): string {
  if (!isApiError(error)) return 'errors.generic'
  const apiError = error
  switch (apiError.code) {
    case 'AUTH_INVALID_CREDENTIALS':
      return 'errors.invalidCredentials'
    case 'AUTH_EMAIL_NOT_CONFIRMED':
      return 'errors.emailNotConfirmed'
    case 'AUTH_SUSPENDED':
    case 'ACCOUNT_SUSPENDED':
      // Backend sends ACCOUNT_SUSPENDED (401) from get_current_user when the
      // profile is suspended; AUTH_SUSPENDED is the legacy alias.
      return 'errors.suspended'
    case 'RATE_LIMIT_EXCEEDED':
      return 'errors.rateLimited'
    case 'HTTP_ERROR':
      return apiError.status === 404 ? 'errors.notFound' : 'errors.server'
    case 'NETWORK_ERROR':
      return 'errors.network'
    case 'INTERNAL_ERROR':
      // Client-side synthesis carries status 0 — never claim a network
      // outage for it; a real backend 5xx INTERNAL_ERROR is a server issue.
      return apiError.status >= 500 ? 'errors.server' : 'errors.generic'
    default:
      if (apiError.status === 0) return 'errors.network'
      if (apiError.status === 429) return 'errors.rateLimited'
      if (apiError.status >= 500) return 'errors.server'
      if (apiError.status === 404) return 'errors.notFound'
      return apiError.status === 403 ? 'errors.notAdmin' : 'errors.generic'
  }
}

