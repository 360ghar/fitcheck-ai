/**
 * Which language does this visitor get?
 *
 * Resolution order, and why each step is where it is:
 *
 * 1. **An explicit choice** the user made in Settings, persisted locally. It
 *    outranks everything, forever. A Tamil speaker on a Spanish-locale laptop
 *    must not be flipped back to Spanish by a browser update, a new device
 *    profile, or a shared kiosk — so this is checked first and the value is
 *    never overwritten by detection.
 * 2. **The signed-in account's language** (`user_settings.language`, set by the
 *    phone app or by an earlier web session). Adopted only when the user has
 *    never chosen on this browser, so it is a suggestion, not an override —
 *    one tap in the picker makes it an explicit choice.
 * 3. **The browser's own preference list** (`navigator.languages`), walked in
 *    the user's stated priority order. `navigator.languages[0]` alone is wrong:
 *    `[ta-IN, en-US]` means "Tamil, but English is acceptable", and we ship
 *    Tamil, so Tamil wins.
 * 4. **English.**
 *
 * Kept as a pure function so it can be unit-tested without a DOM.
 */

import { DEFAULT_LOCALE, normalizeLocaleTag } from './localeMeta'

export interface ResolveInput {
  /** Locally persisted explicit choice, or null when the user never chose. */
  explicit: string | null
  /** `user_settings.language` from the account, or null when signed out/unknown. */
  account: string | null
  /** `navigator.languages`, in the user's priority order. */
  browserLanguages: readonly string[]
}

export function resolveLocale(input: ResolveInput): string {
  const explicit = normalizeLocaleTag(input.explicit)
  if (explicit) return explicit

  const account = normalizeLocaleTag(input.account)
  if (account) return account

  for (const tag of input.browserLanguages) {
    const match = normalizeLocaleTag(tag)
    if (match) return match
  }

  return DEFAULT_LOCALE
}

/** `navigator.languages` with a `navigator.language` fallback, guarded for SSR. */
export function readBrowserLanguages(): string[] {
  if (typeof navigator === 'undefined') return []
  const list = navigator.languages
  if (Array.isArray(list) && list.length > 0) return [...list]
  return navigator.language ? [navigator.language] : []
}
