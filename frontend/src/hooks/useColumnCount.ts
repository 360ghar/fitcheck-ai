/**
 * useColumnCount — viewport → masonry column count.
 *
 *   full  (no detail pane): 3 (<375px) | 4 (375px–md) | lg:5 xl:6 2xl:7
 *   split (detail open):                            lg:2 xl:3 2xl:4
 *
 *   dense (closet item cutouts, `dense: true`):
 *   full:  4 (<md) | md:6 lg:7 xl:8 2xl:9
 *   split:           lg:4 xl:5 2xl:6
 *
 * Dense is for item images only: they are cropped to the item plus a small
 * pad (backend `remove_white_background(crop=True)`), so a narrow tile still
 * shows the whole garment. Outfit looks are full-frame photos and keep the
 * default table.
 *
 * Tailwind breakpoints: xs=375, sm=640, md=768, lg=1024, xl=1280, 2xl=1536.
 * Phones run dense (Alta-style thumbnail wall): 3 columns on the smallest
 * screens, 4 from `xs` up through `md` — sm and md both land on 4, so only
 * the `xs` step needs checking.
 *
 * The split mode applies only at lg+ because `WardrobePage`/`OutfitsPage`
 * force compact list rows at exactly md-with-detail, so the masonry is never
 * rendered in the cramped `md` band — `useColumnCount` never needs to answer
 * for it.
 */
import { useMediaQuery, MD_QUERY, LG_QUERY, XL_QUERY, TWO_XL_QUERY, XS_QUERY } from './useMediaQuery'

export interface UseColumnCountOptions {
  /** True when the detail pane is open, selecting the (fewer-column) split table. */
  isDetailOpen?: boolean
  /** Tight-cropped item cutouts: two more columns per breakpoint (4 on phones). */
  dense?: boolean
}

export function useColumnCount({ isDetailOpen = false, dense = false }: UseColumnCountOptions = {}): number {
  // Order matters: check widest first so the first match wins.
  const is2xl = useMediaQuery(TWO_XL_QUERY)
  const isXl = useMediaQuery(XL_QUERY)
  const isLg = useMediaQuery(LG_QUERY)
  const isMd = useMediaQuery(MD_QUERY)
  const isXs = useMediaQuery(XS_QUERY)

  if (dense) {
    if (isDetailOpen && isLg) {
      if (is2xl) return 6
      if (isXl) return 5
      return 4
    }
    if (is2xl) return 9
    if (isXl) return 8
    if (isLg) return 7
    if (isMd) return 6
    return 4
  }

  if (isDetailOpen && isLg) {
    if (is2xl) return 4
    if (isXl) return 3
    return 2
  }

  if (is2xl) return 7
  if (isXl) return 6
  if (isLg) return 5
  if (isMd) return 4
  if (isXs) return 4
  return 3
}
