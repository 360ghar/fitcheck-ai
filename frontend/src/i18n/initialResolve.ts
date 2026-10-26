/**
 * Initial locale resolution, shared by the provider and the preload in main.tsx.
 *
 * Split out so `main.tsx` can start the catalog download inside the same
 * `Promise.race` that already gates mounting on the public route chunk. By the
 * time React mounts, a Hindi visitor's catalog is normally already in memory,
 * so the provider never has to block paint or flash English first. That matters
 * most on the prerendered marketing pages: blanking baked-in HTML for a chunk
 * fetch would undo the prerender.
 */

import { useLocaleStore } from '@/stores/localeStore'
import { normalizeLocaleTag } from './localeMeta'
import { readBrowserLanguages, resolveLocale } from './resolveLocale'

export interface ResolvedLocale {
  /** Base language for the UI and the backend, e.g. `hi`. */
  locale: string
  /** Full BCP-47 tag for Intl formatting, e.g. `hi-IN`. */
  formattingLocale: string
}

export function initialResolve(): ResolvedLocale {
  const { explicit } = useLocaleStore.getState()
  const browserLanguages = readBrowserLanguages()

  if (explicit) {
    // A deliberate choice wins permanently. If the browser happens to report a
    // region variant of the same language (`hi-IN` for `hi`), use that tag for
    // formatting so dates and digits still follow the region.
    const regional = browserLanguages.find((tag) => normalizeLocaleTag(tag) === explicit)
    return { locale: explicit, formattingLocale: regional ?? explicit }
  }

  const locale = resolveLocale({ explicit: null, account: null, browserLanguages })
  const browserMatch = browserLanguages
    .map((tag) => ({ tag, base: normalizeLocaleTag(tag) }))
    .find((entry) => entry.base === locale)
  return { locale, formattingLocale: browserMatch?.tag ?? locale }
}
