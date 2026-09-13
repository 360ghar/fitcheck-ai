/**
 * useColumnCount — viewport → masonry column count.
 *
 * Dense tables so 3-4+ cards fit per row on real widths:
 *
 *   full  (no detail pane): base:3 sm:4 md:5 lg:6 xl:7 2xl:8
 *   split (detail open):                  lg:3 xl:4 2xl:4
 *
 * Tailwind breakpoints: sm=640, md=768, lg=1024, xl=1280, 2xl=1536.
 *
 * The split mode applies only at lg+ because `WardrobePage`/`OutfitsPage`
 * force compact list rows at exactly md-with-detail, so the masonry is never
 * rendered in the cramped `md` band — `useColumnCount` never needs to answer
 * for it.
 */
import { useMediaQuery, SM_QUERY, MD_QUERY, LG_QUERY, XL_QUERY, TWO_XL_QUERY } from './useMediaQuery'

export interface UseColumnCountOptions {
  /** True when the detail pane is open, selecting the (fewer-column) split table. */
  isDetailOpen?: boolean
}

export function useColumnCount({ isDetailOpen = false }: UseColumnCountOptions = {}): number {
  // Order matters: check widest first so the first match wins.
  const is2xl = useMediaQuery(TWO_XL_QUERY)
  const isXl = useMediaQuery(XL_QUERY)
  const isLg = useMediaQuery(LG_QUERY)
  const isMd = useMediaQuery(MD_QUERY)
  const isSm = useMediaQuery(SM_QUERY)

  if (isDetailOpen && isLg) {
    if (is2xl) return 4
    if (isXl) return 4
    return 3
  }

  if (is2xl) return 8
  if (isXl) return 7
  if (isLg) return 6
  if (isMd) return 5
  if (isSm) return 4
  return 3
}
