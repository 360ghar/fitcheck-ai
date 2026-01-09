/**
 * Wardrobe Gap Analysis
 *
 * Analyzes the user's wardrobe to identify missing essential items,
 * underrepresented categories, and provides recommendations for building
 * a more versatile wardrobe.
 */

import type { Item, Category } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

export interface CategoryDistribution {
  category: Category
  count: number
  percentage: number
  idealPercentage: number
  status: 'surplus' | 'balanced' | 'deficit' | 'missing'
  gapScore: number // negative = surplus, positive = deficit
}

export interface StyleDistribution {
  style: string
  count: number
  percentage: number
}

export interface ColorDistribution {
  color: string
  count: number
  percentage: number
}

export interface WardrobeGap {
  category: Category
  subCategory?: string
  priority: 'high' | 'medium' | 'low'
  reason: string
  suggestion: string
  versatilityScore: number // How many outfits this item could enable
  estimatedCostPerWear?: number
}

export interface VersatilityMetrics {
  totalItems: number
  averageTimesWorn: number
  neverWornItems: number
  mostVersatileItems: Array<{
    item: Item
    timesWorn: number
    versatilityRating: string
  }>
  underutilizedItems: Array<{
    item: Item
    timesWorn: number
    daysOwned: number
  }>
}

export interface WardrobeAnalysis {
  categoryDistribution: CategoryDistribution[]
  styleDistribution: StyleDistribution[]
  colorDistribution: ColorDistribution[]
  gaps: WardrobeGap[]
  versatility: VersatilityMetrics
  overallScore: number
  summary: string
  suggestions: string[]
}

// ============================================================================
// CONSTANTS
// ============================================================================

/**
 * Ideal wardrobe distribution based on capsule wardrobe principles.
 * These percentages represent a balanced, versatile wardrobe.
 */
const IDEAL_DISTRIBUTION: Record<Category, number> = {
  tops: 30,
  bottoms: 20,
  shoes: 15,
  outerwear: 10,
  accessories: 15,
  activewear: 5,
  swimwear: 3,
  other: 2,
}

/**
 * Essential items every wardrobe should have for versatility.
 */
const ESSENTIAL_ITEMS: Array<{
  category: Category
  subCategory?: string
  description: string
  versatilityScore: number
}> = [
  { category: 'tops', subCategory: 'shirt', description: 'Classic white button-down shirt', versatilityScore: 9 },
  { category: 'tops', subCategory: 't-shirt', description: 'Neutral colored t-shirts', versatilityScore: 8 },
  { category: 'bottoms', subCategory: 'jeans', description: 'Dark wash jeans', versatilityScore: 9 },
  { category: 'bottoms', subCategory: 'pants', description: 'Neutral trousers', versatilityScore: 8 },
  { category: 'shoes', subCategory: 'sneakers', description: 'White or neutral sneakers', versatilityScore: 9 },
  { category: 'shoes', subCategory: 'dress shoes', description: 'Classic dress shoes', versatilityScore: 7 },
  { category: 'outerwear', subCategory: 'jacket', description: 'Versatile blazer or jacket', versatilityScore: 8 },
  { category: 'outerwear', subCategory: 'coat', description: 'Neutral winter coat', versatilityScore: 7 },
  { category: 'accessories', subCategory: 'bag', description: 'Everyday bag or backpack', versatilityScore: 8 },
  { category: 'accessories', subCategory: 'belt', description: 'Classic leather belt', versatilityScore: 7 },
]

/**
 * Neutral colors that are highly versatile.
 */
const NEUTRAL_COLORS = ['black', 'white', 'gray', 'navy', 'beige', 'brown', 'cream', 'charcoal', 'tan', 'khaki']

// ============================================================================
// ANALYSIS FUNCTIONS
// ============================================================================

/**
 * Calculate category distribution and identify gaps.
 */
function analyzeCategoryDistribution(items: Item[]): CategoryDistribution[] {
  const totalItems = items.length
  if (totalItems === 0) {
    return Object.keys(IDEAL_DISTRIBUTION).map((cat) => ({
      category: cat as Category,
      count: 0,
      percentage: 0,
      idealPercentage: IDEAL_DISTRIBUTION[cat as Category],
      status: 'missing' as const,
      gapScore: IDEAL_DISTRIBUTION[cat as Category],
    }))
  }

  const counts = new Map<Category, number>()
  items.forEach((item) => {
    counts.set(item.category, (counts.get(item.category) || 0) + 1)
  })

  return Object.entries(IDEAL_DISTRIBUTION).map(([category, ideal]) => {
    const count = counts.get(category as Category) || 0
    const percentage = (count / totalItems) * 100
    const gapScore = ideal - percentage

    let status: 'surplus' | 'balanced' | 'deficit' | 'missing'
    if (count === 0) {
      status = 'missing'
    } else if (gapScore > 5) {
      status = 'deficit'
    } else if (gapScore < -5) {
      status = 'surplus'
    } else {
      status = 'balanced'
    }

    return {
      category: category as Category,
      count,
      percentage: Math.round(percentage * 10) / 10,
      idealPercentage: ideal,
      status,
      gapScore: Math.round(gapScore * 10) / 10,
    }
  })
}

/**
 * Analyze style distribution in the wardrobe.
 */
function analyzeStyleDistribution(items: Item[]): StyleDistribution[] {
  const totalItems = items.length
  if (totalItems === 0) return []

  const styleCounts = new Map<string, number>()
  items.forEach((item) => {
    const style = item.style || 'unclassified'
    styleCounts.set(style, (styleCounts.get(style) || 0) + 1)
  })

  return Array.from(styleCounts.entries())
    .map(([style, count]) => ({
      style,
      count,
      percentage: Math.round((count / totalItems) * 100 * 10) / 10,
    }))
    .sort((a, b) => b.count - a.count)
}

/**
 * Analyze color distribution in the wardrobe.
 */
function analyzeColorDistribution(items: Item[]): ColorDistribution[] {
  const colorCounts = new Map<string, number>()

  items.forEach((item) => {
    item.colors.forEach((color) => {
      const normalizedColor = color.toLowerCase()
      colorCounts.set(normalizedColor, (colorCounts.get(normalizedColor) || 0) + 1)
    })
  })

  const totalColors = Array.from(colorCounts.values()).reduce((a, b) => a + b, 0)
  if (totalColors === 0) return []

  return Array.from(colorCounts.entries())
    .map(([color, count]) => ({
      color,
      count,
      percentage: Math.round((count / totalColors) * 100 * 10) / 10,
    }))
    .sort((a, b) => b.count - a.count)
}

/**
 * Identify wardrobe gaps and generate recommendations.
 */
function identifyGaps(
  items: Item[],
  categoryDistribution: CategoryDistribution[],
  colorDistribution: ColorDistribution[]
): WardrobeGap[] {
  const gaps: WardrobeGap[] = []

  // Check category gaps
  categoryDistribution
    .filter((cd) => cd.status === 'missing' || cd.status === 'deficit')
    .forEach((cd) => {
      const priority = cd.status === 'missing' ? 'high' : cd.gapScore > 10 ? 'high' : 'medium'
      gaps.push({
        category: cd.category,
        priority,
        reason: cd.status === 'missing'
          ? `You don't have any ${cd.category} in your wardrobe`
          : `Your ${cd.category} collection (${cd.percentage}%) is below the ideal (${cd.idealPercentage}%)`,
        suggestion: `Add versatile ${cd.category} pieces to balance your wardrobe`,
        versatilityScore: 7,
      })
    })

  // Check for essential items
  const subCategories = new Set<string>()
  items.forEach((item) => {
    if (item.sub_category) {
      subCategories.add(`${item.category}:${item.sub_category.toLowerCase()}`)
    }
  })

  ESSENTIAL_ITEMS.forEach((essential) => {
    const key = essential.subCategory
      ? `${essential.category}:${essential.subCategory.toLowerCase()}`
      : essential.category

    const hasItem = essential.subCategory
      ? subCategories.has(key)
      : items.some((item) => item.category === essential.category)

    if (!hasItem) {
      gaps.push({
        category: essential.category,
        subCategory: essential.subCategory,
        priority: essential.versatilityScore >= 8 ? 'high' : 'medium',
        reason: `Missing essential item: ${essential.description}`,
        suggestion: `Consider adding a ${essential.description.toLowerCase()}`,
        versatilityScore: essential.versatilityScore,
      })
    }
  })

  // Check neutral color ratio
  const neutralColorCount = colorDistribution
    .filter((cd) => NEUTRAL_COLORS.includes(cd.color))
    .reduce((sum, cd) => sum + cd.count, 0)
  const totalColors = colorDistribution.reduce((sum, cd) => sum + cd.count, 0)
  const neutralRatio = totalColors > 0 ? neutralColorCount / totalColors : 0

  if (neutralRatio < 0.3 && totalColors > 5) {
    gaps.push({
      category: 'tops',
      priority: 'medium',
      reason: `Only ${Math.round(neutralRatio * 100)}% of your items are neutral colors`,
      suggestion: 'Add more neutral-colored basics for easier outfit coordination',
      versatilityScore: 8,
    })
  }

  // Sort by priority and versatility
  return gaps.sort((a, b) => {
    const priorityOrder = { high: 0, medium: 1, low: 2 }
    if (priorityOrder[a.priority] !== priorityOrder[b.priority]) {
      return priorityOrder[a.priority] - priorityOrder[b.priority]
    }
    return b.versatilityScore - a.versatilityScore
  })
}

/**
 * Analyze item versatility and usage patterns.
 */
function analyzeVersatility(items: Item[]): VersatilityMetrics {
  if (items.length === 0) {
    return {
      totalItems: 0,
      averageTimesWorn: 0,
      neverWornItems: 0,
      mostVersatileItems: [],
      underutilizedItems: [],
    }
  }

  const totalTimesWorn = items.reduce((sum, item) => sum + item.usage_times_worn, 0)
  const neverWornItems = items.filter((item) => item.usage_times_worn === 0).length

  // Most versatile items (worn most often)
  const sortedByUsage = [...items].sort((a, b) => b.usage_times_worn - a.usage_times_worn)
  const mostVersatileItems = sortedByUsage.slice(0, 5).map((item) => ({
    item,
    timesWorn: item.usage_times_worn,
    versatilityRating:
      item.usage_times_worn >= 20
        ? 'Wardrobe Hero'
        : item.usage_times_worn >= 10
          ? 'Reliable Staple'
          : item.usage_times_worn >= 5
            ? 'Regular Rotation'
            : 'Occasional Wear',
  }))

  // Underutilized items (owned for a while but rarely worn)
  const now = new Date()
  const underutilizedItems = items
    .filter((item) => {
      const createdAt = new Date(item.created_at)
      const daysOwned = Math.floor((now.getTime() - createdAt.getTime()) / (1000 * 60 * 60 * 24))
      // Owned for at least 30 days but worn less than once per 2 weeks
      return daysOwned >= 30 && item.usage_times_worn < daysOwned / 14
    })
    .slice(0, 5)
    .map((item) => {
      const createdAt = new Date(item.created_at)
      const daysOwned = Math.floor((now.getTime() - createdAt.getTime()) / (1000 * 60 * 60 * 24))
      return { item, timesWorn: item.usage_times_worn, daysOwned }
    })

  return {
    totalItems: items.length,
    averageTimesWorn: Math.round((totalTimesWorn / items.length) * 10) / 10,
    neverWornItems,
    mostVersatileItems,
    underutilizedItems,
  }
}

/**
 * Calculate overall wardrobe score (0-100).
 */
function calculateOverallScore(
  categoryDistribution: CategoryDistribution[],
  colorDistribution: ColorDistribution[],
  versatility: VersatilityMetrics,
  gaps: WardrobeGap[]
): number {
  let score = 100

  // Deduct for category imbalances
  categoryDistribution.forEach((cd) => {
    if (cd.status === 'missing') score -= 10
    else if (cd.status === 'deficit' && cd.gapScore > 10) score -= 5
    else if (cd.status === 'deficit') score -= 2
  })

  // Deduct for high-priority gaps
  gaps.forEach((gap) => {
    if (gap.priority === 'high') score -= 5
    else if (gap.priority === 'medium') score -= 2
  })

  // Deduct for low neutral color ratio
  const neutralCount = colorDistribution
    .filter((cd) => NEUTRAL_COLORS.includes(cd.color))
    .reduce((sum, cd) => sum + cd.count, 0)
  const totalColors = colorDistribution.reduce((sum, cd) => sum + cd.count, 0)
  if (totalColors > 0 && neutralCount / totalColors < 0.3) {
    score -= 10
  }

  // Deduct for underutilized items
  if (versatility.totalItems > 0) {
    const neverWornRatio = versatility.neverWornItems / versatility.totalItems
    if (neverWornRatio > 0.3) score -= 10
    else if (neverWornRatio > 0.2) score -= 5
  }

  return Math.max(0, Math.min(100, score))
}

/**
 * Generate summary and suggestions.
 */
function generateSummary(
  categoryDistribution: CategoryDistribution[],
  gaps: WardrobeGap[],
  versatility: VersatilityMetrics,
  overallScore: number
): { summary: string; suggestions: string[] } {
  const suggestions: string[] = []

  // Overall assessment
  let summary: string
  if (overallScore >= 80) {
    summary = 'Your wardrobe is well-balanced and versatile! Just a few tweaks could make it even better.'
  } else if (overallScore >= 60) {
    summary = 'Your wardrobe has a good foundation but has some gaps that could limit your outfit options.'
  } else if (overallScore >= 40) {
    summary = 'Your wardrobe needs some attention. Adding key pieces will significantly improve your outfit possibilities.'
  } else {
    summary = 'Time to build up your wardrobe! Focus on essentials first to create a versatile foundation.'
  }

  // Category-based suggestions
  const missingCategories = categoryDistribution.filter((cd) => cd.status === 'missing')
  if (missingCategories.length > 0) {
    suggestions.push(`Add items in: ${missingCategories.map((cd) => cd.category).join(', ')}`)
  }

  // High-priority gaps
  const highPriorityGaps = gaps.filter((g) => g.priority === 'high').slice(0, 3)
  highPriorityGaps.forEach((gap) => {
    suggestions.push(gap.suggestion)
  })

  // Utilization suggestions
  if (versatility.neverWornItems > versatility.totalItems * 0.2) {
    suggestions.push(`${versatility.neverWornItems} items have never been worn - consider styling them or donating`)
  }

  if (versatility.underutilizedItems.length > 0) {
    suggestions.push('Some items are underutilized - try incorporating them into new outfit combinations')
  }

  return { summary, suggestions: suggestions.slice(0, 5) }
}

// ============================================================================
// MAIN EXPORT
// ============================================================================

/**
 * Perform a comprehensive wardrobe gap analysis.
 */
export function analyzeWardrobe(items: Item[]): WardrobeAnalysis {
  const categoryDistribution = analyzeCategoryDistribution(items)
  const styleDistribution = analyzeStyleDistribution(items)
  const colorDistribution = analyzeColorDistribution(items)
  const gaps = identifyGaps(items, categoryDistribution, colorDistribution)
  const versatility = analyzeVersatility(items)
  const overallScore = calculateOverallScore(categoryDistribution, colorDistribution, versatility, gaps)
  const { summary, suggestions } = generateSummary(categoryDistribution, gaps, versatility, overallScore)

  return {
    categoryDistribution,
    styleDistribution,
    colorDistribution,
    gaps,
    versatility,
    overallScore,
    summary,
    suggestions,
  }
}

/**
 * Get wardrobe health status based on score.
 */
export function getWardrobeHealthStatus(score: number): {
  status: 'excellent' | 'good' | 'fair' | 'poor'
  color: string
  emoji: string
} {
  if (score >= 80) return { status: 'excellent', color: 'green', emoji: '🌟' }
  if (score >= 60) return { status: 'good', color: 'blue', emoji: '👍' }
  if (score >= 40) return { status: 'fair', color: 'yellow', emoji: '⚡' }
  return { status: 'poor', color: 'red', emoji: '🔧' }
}
