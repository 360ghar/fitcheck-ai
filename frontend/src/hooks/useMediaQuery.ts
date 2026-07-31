/**
 * Media-query hooks for layout decisions that CSS alone cannot make.
 *
 * These exist because `MasterDetailLayout` must mount EXACTLY ONE presentation
 * of a detail surface: a Radix Sheet portals to `document.body`, so it cannot be
 * CSS-hidden, and double-mounting would give two focus traps over one document.
 *
 * jsdom has no `window.matchMedia`. The guard below is load-bearing: without it
 * every page that consumes these hooks throws on first render under Vitest, the
 * throw is swallowed by `FeatureErrorBoundary`, and
 * `OutfitsPage.stability.test.tsx` fails on the boundary it asserts is absent.
 */

import { useEffect, useState } from 'react'

function readMatch(query: string): boolean {
  if (typeof window === 'undefined' || typeof window.matchMedia !== 'function') return false
  return window.matchMedia(query).matches
}

export function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(() => readMatch(query))

  useEffect(() => {
    if (typeof window === 'undefined' || typeof window.matchMedia !== 'function') return
    const list = window.matchMedia(query)
    const onChange = (event: MediaQueryListEvent) => setMatches(event.matches)
    // Re-read on subscribe: the query can already have flipped between the
    // initial render and this effect (a resize during hydration).
    setMatches(list.matches)
    list.addEventListener('change', onChange)
    return () => list.removeEventListener('change', onChange)
  }, [query])

  return matches
}

/** `md` — the breakpoint where the list/detail split engages (tailwind.config.ts). */
export const SPLIT_VIEWPORT_QUERY = '(min-width: 768px)'
/** `lg` — the breakpoint where the shrunken list can hold masonry again. */
export const WIDE_VIEWPORT_QUERY = '(min-width: 1024px)'

export function useIsSplitViewport(): boolean {
  return useMediaQuery(SPLIT_VIEWPORT_QUERY)
}

export function useIsWideViewport(): boolean {
  return useMediaQuery(WIDE_VIEWPORT_QUERY)
}
