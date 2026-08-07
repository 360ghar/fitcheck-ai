import { STORAGE_KEYS } from '@/shared/lib/constants'

/**
 * returnTo survival across the Google OAuth round-trip.
 *
 * The login page stashes the target path before redirecting to Google; the
 * callback page consumes it after /auth/oauth/sync succeeds. Only same-origin
 * app paths are accepted — never a full URL or a path that could bounce the
 * user into an open redirect.
 */

const OAUTH_RETURN_TO_KEY = STORAGE_KEYS.oauthReturnTo

/** Return the path only when it is a safe same-origin app route. */
export function getSafeReturnTo(value: string | null | undefined): string | null {
  if (!value) return null
  if (!value.startsWith('/')) return null
  if (value.startsWith('//')) return null
  if (value.startsWith('/login')) return null
  return value
}

/** Stash before signInWithGoogle. A missing/unsafe returnTo removes the key. */
export function stashOAuthReturnTo(returnTo: string | null | undefined): void {
  const safe = getSafeReturnTo(returnTo)
  if (safe) {
    localStorage.setItem(OAUTH_RETURN_TO_KEY, safe)
  } else {
    localStorage.removeItem(OAUTH_RETURN_TO_KEY)
  }
}

/** Read-and-remove after the callback succeeds. */
export function consumeOAuthReturnTo(): string | null {
  const value = getSafeReturnTo(localStorage.getItem(OAUTH_RETURN_TO_KEY))
  localStorage.removeItem(OAUTH_RETURN_TO_KEY)
  return value
}
