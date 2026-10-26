/**
 * Warm the active catalog before React mounts.
 *
 * `main.tsx` already races a route-chunk preload against a deadline before it
 * mounts, so the prerendered HTML is not cleared in favour of a spinner. The
 * locale catalog joins that race: one ~10 kB fetch, and a non-English visitor's
 * first React render is already in their language instead of snapping over from
 * English a frame later.
 *
 * Also applied here (before paint, before React) is the document direction, so
 * an Arabic visitor's first frame is `dir="rtl"`. Doing it only in an effect
 * would let the whole LTR layout paint once and then mirror.
 */

import { initialResolve } from './initialResolve'
import { loadMessages } from './loadLocale'
import { isRtlLocale } from './localeMeta'
import { setActiveLocale } from './runtime'

let started: Promise<void> | null = null

export function preloadInitialLocale(): Promise<void> {
  if (started) return started
  const resolved = initialResolve()

  setActiveLocale(resolved.locale, resolved.formattingLocale)
  if (typeof document !== 'undefined') {
    document.documentElement.lang = resolved.formattingLocale
    document.documentElement.dir = isRtlLocale(resolved.locale) ? 'rtl' : 'ltr'
  }

  started = loadMessages(resolved.locale).then(() => undefined)
  return started
}
