/**
 * Enhanced outfit generator with real matching algorithms
 * Generates outfit suggestions using color harmony, style coherence, and occasion matching
 */

import type { Item, CompleteLookSuggestion, Category } from '@/types'
import { calculateColorHarmonyScore, calculateOutfitColorHarmony } from './color-utils'

// Category groups for building complete outfits
const OUTFIT_SLOTS: Category[][] = [
  ['tops', 'outerwear'], // Upper body
  ['bottoms'], // Lower body
  ['shoes'], // Footwear
  ['accessories'], // Accessories
]

/**
 * Style compatibility matrix - scores for how well styles work together
 */
const STYLE_COMPATIBILITY: Record<string, Record<string, number>> = {
  casual: {
    casual: 100,
    sporty: 85,
    streetwear: 80,
    bohemian: 70,
    minimalist: 75,
    preppy: 65,
    formal: 20,
    business: 30,
    romantic: 50,
    edgy: 55,
    vintage: 60,
    classic: 70,
  },
  formal: {
    formal: 100,
    business: 85,
    minimalist: 75,
    classic: 85,
    romantic: 65,
    vintage: 55,
    casual: 20,
    sporty: 10,
    streetwear: 15,
    bohemian: 30,
    preppy: 60,
    edgy: 35,
  },
  business: {
    business: 100,
    formal: 85,
    minimalist: 80,
    classic: 85,
    preppy: 70,
    casual: 30,
    sporty: 15,
    streetwear: 10,
    bohemian: 20,
    romantic: 40,
    vintage: 50,
    edgy: 25,
  },
  sporty: {
    sporty: 100,
    casual: 85,
    streetwear: 75,
    minimalist: 65,
    preppy: 50,
    formal: 10,
    business: 15,
    romantic: 20,
    bohemian: 30,
    vintage: 30,
    classic: 40,
    edgy: 60,
  },
  streetwear: {
    streetwear: 100,
    casual: 80,
    sporty: 75,
    edgy: 80,
    minimalist: 60,
    vintage: 65,
    bohemian: 50,
    preppy: 35,
    formal: 15,
    business: 10,
    romantic: 25,
    classic: 40,
  },
  minimalist: {
    minimalist: 100,
    classic: 85,
    business: 80,
    formal: 75,
    casual: 75,
    sporty: 65,
    preppy: 70,
    streetwear: 60,
    romantic: 55,
    bohemian: 45,
    vintage: 60,
    edgy: 55,
  },
  bohemian: {
    bohemian: 100,
    vintage: 80,
    romantic: 75,
    casual: 70,
    edgy: 55,
    streetwear: 50,
    minimalist: 45,
    preppy: 40,
    classic: 45,
    sporty: 30,
    formal: 30,
    business: 20,
  },
  preppy: {
    preppy: 100,
    classic: 85,
    business: 70,
    casual: 65,
    minimalist: 70,
    formal: 60,
    sporty: 50,
    romantic: 55,
    vintage: 55,
    streetwear: 35,
    bohemian: 40,
    edgy: 30,
  },
  romantic: {
    romantic: 100,
    bohemian: 75,
    vintage: 75,
    formal: 65,
    classic: 60,
    preppy: 55,
    minimalist: 55,
    casual: 50,
    business: 40,
    edgy: 35,
    streetwear: 25,
    sporty: 20,
  },
  vintage: {
    vintage: 100,
    bohemian: 80,
    romantic: 75,
    classic: 70,
    casual: 60,
    streetwear: 65,
    preppy: 55,
    edgy: 60,
    minimalist: 60,
    formal: 55,
    business: 50,
    sporty: 30,
  },
  classic: {
    classic: 100,
    preppy: 85,
    business: 85,
    minimalist: 85,
    formal: 85,
    casual: 70,
    romantic: 60,
    vintage: 70,
    sporty: 40,
    bohemian: 45,
    streetwear: 40,
    edgy: 35,
  },
  edgy: {
    edgy: 100,
    streetwear: 80,
    vintage: 60,
    sporty: 60,
    casual: 55,
    bohemian: 55,
    minimalist: 55,
    romantic: 35,
    classic: 35,
    preppy: 30,
    formal: 35,
    business: 25,
  },
}

/**
 * Occasion compatibility - which categories are appropriate for each occasion
 */
const OCCASION_CATEGORIES: Record<string, Category[]> = {
  casual: ['tops', 'bottoms', 'shoes', 'accessories', 'outerwear'],
  work: ['tops', 'bottoms', 'outerwear', 'shoes', 'accessories'],
  formal: ['tops', 'bottoms', 'outerwear', 'accessories', 'shoes'],
  date: ['tops', 'bottoms', 'accessories', 'shoes', 'outerwear'],
  party: ['tops', 'bottoms', 'accessories', 'shoes'],
  weekend: ['tops', 'bottoms', 'shoes', 'accessories', 'outerwear'],
  sport: ['activewear', 'shoes', 'accessories'],
  beach: ['swimwear', 'accessories', 'shoes'],
  travel: ['tops', 'bottoms', 'outerwear', 'shoes', 'accessories'],
}

/**
 * Style descriptors for generating descriptions
 */
const STYLE_ADJECTIVES: Record<string, string[]> = {
  casual: ['relaxed', 'easy-going', 'comfortable', 'laid-back'],
  formal: ['elegant', 'sophisticated', 'polished', 'refined'],
  business: ['professional', 'sharp', 'tailored', 'smart'],
  sporty: ['athletic', 'active', 'dynamic', 'energetic'],
  streetwear: ['urban', 'trendy', 'bold', 'contemporary'],
  minimalist: ['clean', 'streamlined', 'simple', 'modern'],
  bohemian: ['free-spirited', 'artistic', 'eclectic', 'relaxed'],
  preppy: ['polished', 'classic', 'refined', 'timeless'],
  romantic: ['feminine', 'soft', 'graceful', 'charming'],
  vintage: ['retro', 'nostalgic', 'timeless', 'classic'],
  classic: ['timeless', 'elegant', 'refined', 'sophisticated'],
  edgy: ['bold', 'striking', 'daring', 'modern'],
}

/**
 * Match score breakdown for transparency
 */
export interface MatchScoreBreakdown {
  colorHarmony: number
  styleCoherence: number
  occasionMatch: number
  categoryBalance: number
  overall: number
}

/**
 * Infer style from an item's properties
 */
function inferStyle(item: Item): string {
  // Use explicit style if available
  if (item.style) {
    return item.style.toLowerCase()
  }

  // Infer from category
  if (item.category === 'activewear') return 'sporty'
  if (item.category === 'swimwear') return 'casual'

  // Infer from materials
  const material = (item.material || '').toLowerCase()
  if (material.includes('silk') || material.includes('satin')) return 'formal'
  if (material.includes('denim')) return 'casual'
  if (material.includes('leather')) return 'edgy'
  if (material.includes('linen')) return 'casual'
  if (material.includes('wool') && material.includes('suit')) return 'business'

  // Default
  return 'casual'
}

/**
 * Calculate style coherence score for a set of items
 */
function calculateStyleCoherence(items: Item[]): number {
  if (items.length <= 1) return 100

  const styles = items.map(inferStyle)
  let totalScore = 0
  let pairCount = 0

  for (let i = 0; i < styles.length; i++) {
    for (let j = i + 1; j < styles.length; j++) {
      const s1 = styles[i]
      const s2 = styles[j]

      // Get compatibility score
      const score =
        STYLE_COMPATIBILITY[s1]?.[s2] ??
        STYLE_COMPATIBILITY[s2]?.[s1] ??
        50 // Default moderate compatibility

      totalScore += score
      pairCount++
    }
  }

  return pairCount > 0 ? Math.round(totalScore / pairCount) : 70
}

/**
 * Calculate occasion match score
 */
function calculateOccasionScore(
  items: Item[],
  targetOccasion?: string
): number {
  if (!targetOccasion) {
    // Check if items share common occasions
    const occasionCounts = new Map<string, number>()

    for (const item of items) {
      for (const occasion of item.occasion_tags || []) {
        occasionCounts.set(occasion, (occasionCounts.get(occasion) || 0) + 1)
      }
    }

    // Best score if most items share an occasion
    if (occasionCounts.size === 0) return 70

    const maxOverlap = Math.max(...occasionCounts.values())
    return Math.round(50 + (maxOverlap / items.length) * 50)
  }

  // Check against target occasion
  const validCategories = OCCASION_CATEGORIES[targetOccasion] || []
  let matchCount = 0

  for (const item of items) {
    // Check category fit
    if (validCategories.includes(item.category)) {
      matchCount++
    }
    // Check occasion tags
    if ((item.occasion_tags || []).includes(targetOccasion)) {
      matchCount++
    }
  }

  return Math.min(100, Math.round((matchCount / (items.length * 2)) * 100))
}

/**
 * Calculate category balance score - are all outfit slots filled appropriately?
 */
function calculateCategoryBalance(items: Item[]): number {
  const categories = new Set(items.map((i) => i.category))

  // Check how many outfit slots are filled
  let filledSlots = 0
  for (const slotCategories of OUTFIT_SLOTS) {
    if (slotCategories.some((cat) => categories.has(cat))) {
      filledSlots++
    }
  }

  // Ideally have top + bottom + shoes at minimum
  const minSlots = 3
  const maxSlots = OUTFIT_SLOTS.length

  if (filledSlots >= minSlots) {
    return 70 + Math.round(((filledSlots - minSlots) / (maxSlots - minSlots)) * 30)
  }

  return Math.round((filledSlots / minSlots) * 70)
}

/**
 * Calculate comprehensive match score for adding an item to existing selection
 */
export function calculateMatchScore(
  selectedItems: Item[],
  candidateItem: Item,
  options?: { style?: string; occasion?: string }
): MatchScoreBreakdown {
  const allItems = [...selectedItems, candidateItem]

  // Color harmony (35% weight)
  const colorHarmony = calculateColorHarmonyScore(
    selectedItems.flatMap((i) => i.colors || []),
    candidateItem.colors || []
  )

  // Style coherence (30% weight)
  const styleCoherence = calculateStyleCoherence(allItems)

  // Occasion match (20% weight)
  const occasionMatch = calculateOccasionScore(allItems, options?.occasion)

  // Category balance (15% weight)
  const categoryBalance = calculateCategoryBalance(allItems)

  // Weighted overall score
  const overall = Math.round(
    colorHarmony * 0.35 +
      styleCoherence * 0.3 +
      occasionMatch * 0.2 +
      categoryBalance * 0.15
  )

  return {
    colorHarmony,
    styleCoherence,
    occasionMatch,
    categoryBalance,
    overall,
  }
}

/**
 * Detect dominant style from items
 */
function detectDominantStyle(items: Item[]): string {
  const styleCounts = new Map<string, number>()

  for (const item of items) {
    const style = inferStyle(item)
    styleCounts.set(style, (styleCounts.get(style) || 0) + 1)
  }

  let maxCount = 0
  let dominant = 'casual'

  for (const [style, count] of styleCounts) {
    if (count > maxCount) {
      maxCount = count
      dominant = style
    }
  }

  return dominant
}

/**
 * Detect best occasion fit from items
 */
function detectBestOccasion(items: Item[]): string {
  const occasionCounts = new Map<string, number>()

  for (const item of items) {
    for (const occasion of item.occasion_tags || []) {
      occasionCounts.set(occasion, (occasionCounts.get(occasion) || 0) + 1)
    }
  }

  if (occasionCounts.size === 0) {
    // Infer from style
    const style = detectDominantStyle(items)
    if (style === 'formal' || style === 'business') return 'work'
    if (style === 'sporty') return 'active'
    return 'everyday'
  }

  let maxCount = 0
  let bestOccasion = 'everyday'

  for (const [occasion, count] of occasionCounts) {
    if (count > maxCount) {
      maxCount = count
      bestOccasion = occasion
    }
  }

  return bestOccasion
}

/**
 * Generate meaningful outfit description based on actual properties
 */
function generateDescription(items: Item[]): string {
  const style = detectDominantStyle(items)
  const occasion = detectBestOccasion(items)

  const adjectives = STYLE_ADJECTIVES[style] || STYLE_ADJECTIVES.casual
  const adjective = adjectives[Math.floor(Math.random() * adjectives.length)]

  // Describe color palette if notable
  const allColors = items.flatMap((i) => i.colors || [])
  const uniqueColors = [...new Set(allColors)]
  const colorNote =
    uniqueColors.length <= 2
      ? ` in ${uniqueColors.join(' and ')}`
      : ''

  return `A ${adjective} ${style} look${colorNote} for ${occasion}`
}

/**
 * Score and rank candidate items for a slot
 */
function rankCandidates(
  selectedItems: Item[],
  candidates: Item[],
  options?: { style?: string; occasion?: string }
): Array<{ item: Item; score: MatchScoreBreakdown }> {
  return candidates
    .map((item) => ({
      item,
      score: calculateMatchScore(selectedItems, item, options),
    }))
    .sort((a, b) => b.score.overall - a.score.overall)
}

/**
 * Generate fallback outfit suggestions client-side
 * Uses real matching algorithms for accurate recommendations
 */
export function generateFallbackOutfits(
  selectedItems: Item[],
  allItems: Item[],
  limit: number = 6,
  options?: { style?: string; occasion?: string }
): CompleteLookSuggestion[] {
  const selectedIds = new Set(selectedItems.map((i) => i.id))
  const selectedCategories = new Set(selectedItems.map((i) => i.category))

  // Group available items by category
  const availableByCategory = new Map<Category, Item[]>()
  for (const item of allItems) {
    if (!selectedIds.has(item.id)) {
      const list = availableByCategory.get(item.category) || []
      list.push(item)
      availableByCategory.set(item.category, list)
    }
  }

  // Find missing slots and their best candidates
  const missingSlots: Array<{ slot: Category[]; candidates: Item[] }> = []

  for (const slotCategories of OUTFIT_SLOTS) {
    const hasSlot = slotCategories.some((cat) => selectedCategories.has(cat))
    if (!hasSlot) {
      const candidates: Item[] = []
      for (const cat of slotCategories) {
        const available = availableByCategory.get(cat) || []
        candidates.push(...available)
      }
      if (candidates.length > 0) {
        missingSlots.push({ slot: slotCategories, candidates })
      }
    }
  }

  // Generate outfit variations
  const suggestions: CompleteLookSuggestion[] = []
  const usedCombinations = new Set<string>()

  // If no missing slots, create variations with accessories
  if (missingSlots.length === 0) {
    const accessories = availableByCategory.get('accessories') || []
    if (accessories.length > 0) {
      const ranked = rankCandidates(selectedItems, accessories, options)
      for (let i = 0; i < Math.min(limit, ranked.length); i++) {
        const { item, score } = ranked[i]
        const outfitItems = [...selectedItems, item]
        suggestions.push({
          items: outfitItems,
          match_score: score.overall,
          description: generateDescription(outfitItems),
          style: detectDominantStyle(outfitItems),
          occasion: detectBestOccasion(outfitItems),
        })
      }
    }
    return suggestions
  }

  // Generate combinations by picking top candidates from each slot
  const maxIterations = limit * 3
  let iterations = 0

  while (suggestions.length < limit && iterations < maxIterations) {
    iterations++

    const outfitItems = [...selectedItems]
    const addedIds: string[] = []

    // Pick one item from each missing slot
    for (const { candidates } of missingSlots) {
      // Rank candidates based on current outfit
      const ranked = rankCandidates(outfitItems, candidates, options)

      if (ranked.length > 0) {
        // Pick from top candidates with some randomization
        const topCount = Math.min(3, ranked.length)
        const idx = Math.floor(Math.random() * topCount)
        const chosen = ranked[idx]

        outfitItems.push(chosen.item)
        addedIds.push(chosen.item.id)
      }
    }

    // Check for duplicate combinations
    const combinationKey = addedIds.sort().join('-')
    if (usedCombinations.has(combinationKey)) {
      continue
    }
    usedCombinations.add(combinationKey)

    // Calculate final score for complete outfit
    const colorHarmony = calculateOutfitColorHarmony(
      outfitItems.map((i) => i.colors || [])
    )
    const styleCoherence = calculateStyleCoherence(outfitItems)
    const occasionMatch = calculateOccasionScore(outfitItems, options?.occasion)
    const categoryBalance = calculateCategoryBalance(outfitItems)

    const overall = Math.round(
      colorHarmony * 0.35 +
        styleCoherence * 0.3 +
        occasionMatch * 0.2 +
        categoryBalance * 0.15
    )

    suggestions.push({
      items: outfitItems,
      match_score: overall,
      description: generateDescription(outfitItems),
      style: detectDominantStyle(outfitItems),
      occasion: detectBestOccasion(outfitItems),
    })
  }

  // Sort by match score
  suggestions.sort((a, b) => b.match_score - a.match_score)

  return suggestions.slice(0, limit)
}
