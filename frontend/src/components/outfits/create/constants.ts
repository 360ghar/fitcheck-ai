/**
 * Shared vocabulary for the Create Outfit page.
 *
 * `STYLES` / `SEASONS` were inlined in the deleted `OutfitCreateDialog`; they are
 * the `Style` / `Season` unions from `@/types` spelled out in the order a person
 * would scan them, so they live here rather than being re-derived per component.
 *
 * The band map is the other half: it is the single place that decides where a
 * garment sits on the preview stage, so `OutfitCollagePreview` and the rail order
 * cannot disagree about what "a top" means.
 */

import type { Season, Style } from '@/types'

/** The shape `GET /api/v1/outfits/available-items` returns. */
export interface AvailableItem {
  id: string
  name: string
  category: string
  image_url?: string
  colors: string[]
}

export const STYLES: Style[] = [
  'casual',
  'formal',
  'business',
  'sporty',
  'bohemian',
  'streetwear',
  'vintage',
  'minimalist',
  'romantic',
  'edgy',
  'preppy',
  'artsy',
  'other',
]

export const SEASONS: Season[] = ['spring', 'summer', 'fall', 'winter', 'all-season']

export const DEFAULT_STYLE: Style = 'casual'
export const DEFAULT_SEASON: Season = 'all-season'

/**
 * Where a category lands on the stage.
 *
 * `upper` sits in the top band, `lower` centred beneath it, `base` on the ground
 * line, and `rail` in a narrow right-hand column. This mirrors how the pieces
 * actually sit on a body, which is the whole reason the collage reads as an
 * outfit rather than a grid of thumbnails.
 */
export type StageBand = 'upper' | 'lower' | 'base' | 'rail'

const BAND_BY_CATEGORY: Record<string, StageBand> = {
  outerwear: 'upper',
  tops: 'upper',
  activewear: 'upper',
  swimwear: 'upper',
  bottoms: 'lower',
  shoes: 'base',
  accessories: 'rail',
  other: 'rail',
}

export function bandForCategory(category: string | undefined): StageBand {
  return BAND_BY_CATEGORY[(category || '').toLowerCase()] ?? 'rail'
}

/**
 * Rail order for the picker: wearing order, not alphabetical.
 * The old dialog sorted category groups with `localeCompare`, which put
 * "accessories" above "outerwear" and read as a database dump.
 */
const CATEGORY_ORDER = [
  'outerwear',
  'tops',
  'bottoms',
  'shoes',
  'accessories',
  'activewear',
  'swimwear',
  'other',
]

export function compareCategories(a: string, b: string): number {
  const ia = CATEGORY_ORDER.indexOf(a.toLowerCase())
  const ib = CATEGORY_ORDER.indexOf(b.toLowerCase())
  // Unknown categories sort after the known ones, then alphabetically.
  if (ia === -1 && ib === -1) return a.localeCompare(b)
  if (ia === -1) return 1
  if (ib === -1) return -1
  return ia - ib
}
