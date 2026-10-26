/**
 * The account's language, read from `user_settings.language`.
 *
 * The phone app persists its locale locally and mirrors it to
 * `PUT /api/v1/users/settings` `{"language": "hi"}`. For the two clients to
 * agree, the web app has to read that value back — otherwise a user who chose
 * Tamil on the phone opens the website on a fresh browser and gets English,
 * with no way to know their account already has a language.
 *
 * One GET, memoized for the session. A failure is not fatal: it just means no
 * account-level suggestion, and the browser's own languages decide.
 */

import { getUserSettings } from '@/api/users'
import { logger } from '@/lib/logger'

let pending: Promise<string | null> | null = null

export function fetchAccountLanguage(): Promise<string | null> {
  if (pending) return pending
  pending = getUserSettings()
    .then((settings) => settings.language ?? null)
    .catch((error) => {
      // Signed out, or the settings row does not exist yet (the backend creates
      // it lazily). Neither is an error worth surfacing.
      logger.warn('i18n: account language unavailable', error)
      return null
    })
  return pending
}

/** Called on sign-out and on user switch so the next account is read fresh. */
export function resetAccountLanguage(): void {
  pending = null
}
