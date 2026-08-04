/**
 * useColumnCount — viewport → masonry column count.
 *
 * Mirrors the two breakpoint tables the old CSS-columns `PinGrid` used, so the
 * JS masonry lands on the exact same geometry at every breakpoint and in both
 * modes:
 *
 *   full  (no detail pane): columns-2 sm:3 md:4 lg:5 xl:6 2xl:7
 *   split (detail open):                  lg:2 xl:3 2xl:4
 *
 * Tailwind breakpoints: sm=640, md=768, lg=1024, xl=1280, 2xl=1536.
 *
 * The split mode applies only at lg+ because `WardrobePage`/`OutfitsPage`
 * force compact list rows at exactly md-with-detail, so the masonry is never
 * rendered in the cramped `md` band — `useColumnCount` never needs to answer
 * for it.
 */
import { useMediaQuery } from './useMediaQuery'

export interface UseColumnCountOptions {
  /** True when the detail pane is open, selecting the (fewer-column) split table. */
  isDetailOpen?: boolean
}

export function useColumnCount({ isDetailOpen = false }: UseColumnCountOptions = {}): number {
  // Order matters: check widest first so the first match wins.
  const is2xl = useMediaQuery('(min-width: 1536px)')
  const isXl = useMediaQuery('(min-width: 1280px)')
  const isLg = useMediaQuery('(min-width: 1024px)')
  const isMd = useMediaQuery('(min-width: 768px)')
  const isSm = useMediaQuery('(min-width: 640px)')

  if (isDetailOpen && isLg) {
    if (is2xl) return 4
    if (isXl) return 3
    return 2
  }

  if (is2xl) return 7
  if (isXl) return 6
  if (isLg) return 5
  if (isMd) return 4
  if (isSm) return 3
  return 2
}
