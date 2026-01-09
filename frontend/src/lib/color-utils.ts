/**
 * Color harmony and matching utilities for outfit recommendations
 * Provides algorithms for color compatibility scoring
 */

// HSL color representation
interface HSL {
  h: number // 0-360 (hue)
  s: number // 0-100 (saturation)
  l: number // 0-100 (lightness)
}

/**
 * Map of common fashion color names to HSL values
 */
const COLOR_MAP: Record<string, HSL> = {
  // Neutrals
  black: { h: 0, s: 0, l: 0 },
  white: { h: 0, s: 0, l: 100 },
  gray: { h: 0, s: 0, l: 50 },
  grey: { h: 0, s: 0, l: 50 },
  charcoal: { h: 0, s: 0, l: 25 },
  silver: { h: 0, s: 0, l: 75 },
  ivory: { h: 40, s: 20, l: 95 },
  cream: { h: 45, s: 40, l: 90 },
  beige: { h: 40, s: 30, l: 80 },
  tan: { h: 35, s: 40, l: 65 },
  khaki: { h: 55, s: 35, l: 60 },
  taupe: { h: 30, s: 15, l: 50 },

  // Blues
  navy: { h: 240, s: 64, l: 27 },
  blue: { h: 210, s: 100, l: 50 },
  'light blue': { h: 200, s: 70, l: 75 },
  'sky blue': { h: 195, s: 80, l: 70 },
  'royal blue': { h: 225, s: 85, l: 45 },
  cobalt: { h: 215, s: 90, l: 40 },
  teal: { h: 180, s: 60, l: 35 },
  turquoise: { h: 175, s: 70, l: 55 },
  aqua: { h: 180, s: 75, l: 60 },
  cyan: { h: 180, s: 100, l: 50 },

  // Reds
  red: { h: 0, s: 100, l: 50 },
  burgundy: { h: 345, s: 80, l: 25 },
  maroon: { h: 0, s: 65, l: 30 },
  wine: { h: 345, s: 60, l: 30 },
  rust: { h: 15, s: 70, l: 40 },
  coral: { h: 16, s: 100, l: 66 },
  salmon: { h: 6, s: 90, l: 70 },
  crimson: { h: 348, s: 90, l: 45 },

  // Oranges
  orange: { h: 30, s: 100, l: 50 },
  peach: { h: 28, s: 80, l: 75 },
  apricot: { h: 25, s: 85, l: 70 },
  terracotta: { h: 15, s: 55, l: 45 },

  // Yellows
  yellow: { h: 60, s: 100, l: 50 },
  gold: { h: 50, s: 100, l: 50 },
  mustard: { h: 45, s: 75, l: 45 },
  lemon: { h: 55, s: 90, l: 65 },

  // Greens
  green: { h: 120, s: 100, l: 35 },
  olive: { h: 60, s: 45, l: 35 },
  sage: { h: 100, s: 25, l: 60 },
  mint: { h: 150, s: 50, l: 75 },
  emerald: { h: 145, s: 75, l: 35 },
  forest: { h: 130, s: 50, l: 25 },
  lime: { h: 90, s: 80, l: 50 },
  'hunter green': { h: 140, s: 55, l: 25 },

  // Purples
  purple: { h: 270, s: 60, l: 40 },
  lavender: { h: 270, s: 50, l: 80 },
  lilac: { h: 280, s: 45, l: 75 },
  violet: { h: 270, s: 75, l: 50 },
  plum: { h: 300, s: 45, l: 35 },
  mauve: { h: 310, s: 30, l: 65 },
  magenta: { h: 300, s: 100, l: 50 },
  fuchsia: { h: 315, s: 100, l: 50 },

  // Pinks
  pink: { h: 330, s: 70, l: 75 },
  'hot pink': { h: 330, s: 100, l: 55 },
  blush: { h: 355, s: 50, l: 85 },
  rose: { h: 345, s: 60, l: 55 },
  'dusty rose': { h: 345, s: 35, l: 60 },

  // Browns
  brown: { h: 30, s: 50, l: 30 },
  chocolate: { h: 25, s: 65, l: 25 },
  coffee: { h: 25, s: 55, l: 25 },
  camel: { h: 35, s: 50, l: 55 },
  cognac: { h: 25, s: 70, l: 40 },
  espresso: { h: 25, s: 60, l: 20 },
}

/**
 * Classic fashion color combinations that always work well
 */
const CLASSIC_COMBINATIONS: [string, string][] = [
  ['black', 'white'],
  ['navy', 'white'],
  ['navy', 'cream'],
  ['navy', 'beige'],
  ['gray', 'pink'],
  ['gray', 'blue'],
  ['blue', 'brown'],
  ['olive', 'beige'],
  ['olive', 'cream'],
  ['burgundy', 'cream'],
  ['burgundy', 'navy'],
  ['camel', 'navy'],
  ['camel', 'black'],
  ['tan', 'white'],
  ['brown', 'blue'],
  ['red', 'navy'],
  ['black', 'red'],
  ['white', 'blue'],
  ['charcoal', 'white'],
]

/**
 * Normalize color string for lookup
 */
function normalizeColor(color: string): string {
  return color.toLowerCase().trim()
}

/**
 * Get HSL value for a color name, with fuzzy matching
 */
function getHSL(colorName: string): HSL | null {
  const normalized = normalizeColor(colorName)

  // Direct match
  if (COLOR_MAP[normalized]) {
    return COLOR_MAP[normalized]
  }

  // Fuzzy match - check if color name contains a known color
  for (const [key, hsl] of Object.entries(COLOR_MAP)) {
    if (normalized.includes(key) || key.includes(normalized)) {
      return hsl
    }
  }

  return null
}

/**
 * Check if a color is neutral (pairs well with most colors)
 */
function isNeutral(color: string): boolean {
  const hsl = getHSL(color)
  if (!hsl) {
    // Default assumption for unknown colors
    const lower = normalizeColor(color)
    return ['black', 'white', 'gray', 'grey', 'beige', 'cream', 'tan', 'khaki', 'ivory', 'taupe', 'charcoal', 'silver'].some(n => lower.includes(n))
  }

  // Low saturation or very light/dark = neutral
  return hsl.s < 20 || hsl.l < 15 || hsl.l > 85
}

/**
 * Calculate hue distance on color wheel (0-180)
 */
function hueDistance(h1: number, h2: number): number {
  const diff = Math.abs(h1 - h2)
  return Math.min(diff, 360 - diff)
}

/**
 * Check if two colors are complementary (opposite on color wheel)
 */
function areComplementary(color1: HSL, color2: HSL): boolean {
  const dist = hueDistance(color1.h, color2.h)
  return dist >= 150 && dist <= 180
}

/**
 * Check if two colors are analogous (adjacent on color wheel)
 */
function areAnalogous(color1: HSL, color2: HSL): boolean {
  const dist = hueDistance(color1.h, color2.h)
  return dist <= 60
}

/**
 * Check if colors form a triadic scheme
 */
function areTriadic(color1: HSL, color2: HSL): boolean {
  const dist = hueDistance(color1.h, color2.h)
  return dist >= 100 && dist <= 140
}

/**
 * Check if two colors are a classic fashion combination
 */
function isClassicCombination(color1: string, color2: string): boolean {
  const c1 = normalizeColor(color1)
  const c2 = normalizeColor(color2)

  return CLASSIC_COMBINATIONS.some(
    ([a, b]) =>
      (c1.includes(a) && c2.includes(b)) ||
      (c1.includes(b) && c2.includes(a))
  )
}

/**
 * Calculate harmony score between two individual colors (0-100)
 */
function colorPairScore(color1: string, color2: string): number {
  const c1 = normalizeColor(color1)
  const c2 = normalizeColor(color2)

  // Same color family
  if (c1 === c2 || c1.includes(c2) || c2.includes(c1)) {
    return 90
  }

  // Classic combination bonus
  if (isClassicCombination(c1, c2)) {
    return 95
  }

  // Neutrals pair with everything
  if (isNeutral(c1) || isNeutral(c2)) {
    return 85
  }

  const hsl1 = getHSL(c1)
  const hsl2 = getHSL(c2)

  if (!hsl1 || !hsl2) {
    // Unknown colors - assume moderate compatibility
    return 60
  }

  // Complementary colors
  if (areComplementary(hsl1, hsl2)) {
    return 80
  }

  // Analogous colors
  if (areAnalogous(hsl1, hsl2)) {
    return 85
  }

  // Triadic colors
  if (areTriadic(hsl1, hsl2)) {
    return 70
  }

  // Default moderate score for other combinations
  const hueDist = hueDistance(hsl1.h, hsl2.h)
  // Penalize awkward distances (between analogous and complementary)
  if (hueDist > 60 && hueDist < 100) {
    return 45
  }

  return 55
}

/**
 * Calculate overall color harmony score for an outfit
 * @param colors1 - Colors from first set of items
 * @param colors2 - Colors from second set of items (candidate item)
 * @returns Score from 0-100
 */
export function calculateColorHarmonyScore(
  colors1: string[],
  colors2: string[]
): number {
  // Handle empty arrays
  if (colors1.length === 0 || colors2.length === 0) {
    return 70 // Neutral score when no color info
  }

  // Flatten and dedupe all colors
  const allColors = [...new Set([...colors1, ...colors2])]

  // All neutrals = great match
  if (allColors.every(isNeutral)) {
    return 90
  }

  // Calculate pairwise scores between the two sets
  let totalScore = 0
  let pairCount = 0

  for (const c1 of colors1) {
    for (const c2 of colors2) {
      totalScore += colorPairScore(c1, c2)
      pairCount++
    }
  }

  if (pairCount === 0) {
    return 70
  }

  const avgScore = totalScore / pairCount

  // Bonus for limited color palette (cohesive look)
  const uniqueCount = allColors.filter(c => !isNeutral(c)).length
  const paletteBonus = uniqueCount <= 3 ? 5 : 0

  return Math.min(100, Math.round(avgScore + paletteBonus))
}

/**
 * Calculate color harmony for a complete outfit (array of items with colors)
 */
export function calculateOutfitColorHarmony(
  itemColors: string[][]
): number {
  const allColors = itemColors.flat()

  if (allColors.length === 0) {
    return 70
  }

  // Check all pairs
  let totalScore = 0
  let pairCount = 0

  for (let i = 0; i < allColors.length; i++) {
    for (let j = i + 1; j < allColors.length; j++) {
      totalScore += colorPairScore(allColors[i], allColors[j])
      pairCount++
    }
  }

  if (pairCount === 0) {
    return 70
  }

  return Math.round(totalScore / pairCount)
}

// Export utilities for testing
export { isNeutral, getHSL, colorPairScore }
