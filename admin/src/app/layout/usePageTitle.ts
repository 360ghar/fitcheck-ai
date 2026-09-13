import { useTranslation } from 'react-i18next'
import { useMatches } from 'react-router-dom'

/**
 * Single page-title resolver: the deepest matched route's `handle.titleKey`
 * (see `src/routes.tsx`). Topbar (visible title) and RootLayout (document
 * title) both consume it so the lookup lives in exactly one place.
 */
export function usePageTitleKey(): string | null {
  const matches = useMatches()
  for (const match of [...matches].reverse()) {
    const handle = match.handle
    if (handle && typeof handle === 'object' && 'titleKey' in handle) {
      const titleKey = (handle as { titleKey?: unknown }).titleKey
      if (typeof titleKey === 'string') return titleKey
    }
  }
  return null
}

/** Translated page title for the active route, or null when unset. */
export function usePageTitle(): string | null {
  const { t } = useTranslation('layout')
  const titleKey = usePageTitleKey()
  return titleKey ? t(titleKey) : null
}
