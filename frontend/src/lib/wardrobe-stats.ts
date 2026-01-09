/**
 * Wardrobe Statistics Service
 *
 * Provides fun and insightful statistics about a user's wardrobe.
 * Includes cost-per-wear analysis, versatility metrics, style insights,
 * and entertaining facts about clothing habits.
 */

import type { Item, Outfit, Category, Style, Season } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

export interface WardrobeStats {
  // Core counts
  totalItems: number
  totalOutfits: number
  totalValue: number

  // Usage metrics
  totalWears: number
  averageWearsPerItem: number
  averageCostPerWear: number

  // Champions
  mostWornItem: Item | null
  leastWornItem: Item | null
  mostVersatileItem: Item | null
  bestValueItem: Item | null
  mostExpensiveItem: Item | null

  // Category insights
  categoryBreakdown: CategoryStats[]
  dominantCategory: Category | null

  // Color insights
  colorPalette: ColorStats[]
  dominantColors: string[]
  colorDiversity: number // 0-100 score

  // Style insights
  styleBreakdown: { style: Style; count: number; percentage: number }[]
  primaryStyle: Style | null
  stylePersonality: string

  // Seasonal balance
  seasonalBalance: { season: Season; count: number; percentage: number }[]

  // Fun facts
  funFacts: FunFact[]

  // Time insights
  newestItem: Item | null
  oldestItem: Item | null
  averageItemAge: number // in days

  // Value insights
  totalRetailValue: number
  costPerWearLeaders: { item: Item; cpw: number }[]
  dormantItems: Item[] // Items not worn in 30+ days
  workhorseItems: Item[] // Most versatile items

  // Sustainability
  sustainabilityScore: number // 0-100
  estimatedCarbonSavings: number // kg CO2 from rewearing
}

export interface CategoryStats {
  category: Category
  count: number
  percentage: number
  totalValue: number
  averageWears: number
  topItem: Item | null
}

export interface ColorStats {
  color: string
  count: number
  percentage: number
  hexApprox: string
}

export interface FunFact {
  id: string
  emoji: string
  title: string
  description: string
  value?: string | number
  category: 'achievement' | 'insight' | 'fun' | 'tip'
}

// ============================================================================
// COLOR MAPPING
// ============================================================================

const COLOR_HEX_MAP: Record<string, string> = {
  black: '#1a1a1a',
  white: '#ffffff',
  gray: '#808080',
  grey: '#808080',
  red: '#dc2626',
  orange: '#f97316',
  yellow: '#eab308',
  green: '#22c55e',
  blue: '#3b82f6',
  purple: '#a855f7',
  pink: '#ec4899',
  brown: '#92400e',
  beige: '#d4b896',
  cream: '#fffdd0',
  navy: '#1e3a5f',
  burgundy: '#722f37',
  olive: '#808000',
  teal: '#14b8a6',
  coral: '#ff7f50',
  maroon: '#800000',
  tan: '#d2b48c',
  gold: '#ffd700',
  silver: '#c0c0c0',
  khaki: '#c3b091',
  charcoal: '#36454f',
  ivory: '#fffff0',
  mint: '#98fb98',
  lavender: '#e6e6fa',
  salmon: '#fa8072',
  peach: '#ffcba4',
  turquoise: '#40e0d0',
  denim: '#1560bd',
  camel: '#c19a6b',
  rust: '#b7410e',
  mustard: '#ffdb58',
  blush: '#de5d83',
  forest: '#228b22',
  emerald: '#50c878',
  sapphire: '#0f52ba',
  rose: '#ff007f',
  wine: '#722f37',
  slate: '#708090',
  stone: '#a39e93',
}

function getColorHex(color: string): string {
  const normalized = color.toLowerCase().trim()
  return COLOR_HEX_MAP[normalized] || '#cccccc'
}

// ============================================================================
// STYLE PERSONALITY MAPPING
// ============================================================================

const STYLE_PERSONALITIES: Record<string, { name: string; emoji: string; description: string }> = {
  casual: {
    name: 'The Comfort Connoisseur',
    emoji: '😎',
    description: 'You prioritize comfort and easy-going style. Laid-back and approachable.',
  },
  formal: {
    name: 'The Polished Professional',
    emoji: '💼',
    description: 'You dress to impress with sharp, sophisticated choices.',
  },
  business: {
    name: 'The Power Player',
    emoji: '🏆',
    description: 'You mean business with a wardrobe that commands respect.',
  },
  sporty: {
    name: 'The Active Achiever',
    emoji: '🏃',
    description: 'Always ready for action with athletic-inspired style.',
  },
  bohemian: {
    name: 'The Free Spirit',
    emoji: '🌸',
    description: 'You express creativity through eclectic, artistic choices.',
  },
  streetwear: {
    name: 'The Trend Setter',
    emoji: '🔥',
    description: 'You stay ahead of the curve with bold, urban style.',
  },
  vintage: {
    name: 'The Time Traveler',
    emoji: '⏰',
    description: 'You appreciate classic styles with timeless appeal.',
  },
  minimalist: {
    name: 'The Essentialist',
    emoji: '✨',
    description: 'You believe less is more with clean, curated choices.',
  },
}

// ============================================================================
// CALCULATION FUNCTIONS
// ============================================================================

function calculateCostPerWear(item: Item): number {
  if (!item.purchase_price || item.usage_times_worn === 0) return Infinity
  return item.purchase_price / item.usage_times_worn
}

function calculateVersatilityScore(item: Item, outfits: Outfit[]): number {
  const outfitCount = outfits.filter((o) => o.item_ids.includes(item.id)).length
  const tagScore = item.tags.length * 2
  const neutralColors = ['black', 'white', 'gray', 'navy', 'beige', 'cream', 'brown']
  const hasNeutral = item.colors.some((c) => neutralColors.includes(c.toLowerCase()))
  const colorScore = hasNeutral ? 10 : 0

  return outfitCount * 5 + tagScore + colorScore + (item.usage_times_worn * 2)
}

function getDaysSince(dateString: string): number {
  const date = new Date(dateString)
  const now = new Date()
  return Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60 * 24))
}

function generateFunFacts(items: Item[], outfits: Outfit[], stats: Partial<WardrobeStats>): FunFact[] {
  const facts: FunFact[] = []

  // Total value fact
  if (stats.totalValue && stats.totalValue > 0) {
    facts.push({
      id: 'total-value',
      emoji: '💰',
      title: 'Wardrobe Worth',
      description: `Your wardrobe is valued at $${stats.totalValue.toLocaleString()}`,
      value: stats.totalValue,
      category: 'insight',
    })
  }

  // Outfits possible
  const tops = items.filter((i) => i.category === 'tops').length
  const bottoms = items.filter((i) => i.category === 'bottoms').length
  const shoes = items.filter((i) => i.category === 'shoes').length
  if (tops > 0 && bottoms > 0) {
    const combinations = tops * bottoms * Math.max(1, shoes)
    facts.push({
      id: 'outfit-combinations',
      emoji: '🎲',
      title: 'Infinite Possibilities',
      description: `You could create ${combinations.toLocaleString()} unique outfit combinations!`,
      value: combinations,
      category: 'fun',
    })
  }

  // Best value item
  if (stats.bestValueItem) {
    const cpw = calculateCostPerWear(stats.bestValueItem)
    if (cpw < Infinity) {
      facts.push({
        id: 'best-value',
        emoji: '🏅',
        title: 'Best Investment',
        description: `"${stats.bestValueItem.name}" costs only $${cpw.toFixed(2)} per wear!`,
        value: cpw,
        category: 'achievement',
      })
    }
  }

  // Workhorse item
  if (stats.mostWornItem) {
    facts.push({
      id: 'most-worn',
      emoji: '👑',
      title: 'Wardrobe MVP',
      description: `"${stats.mostWornItem.name}" is your most-worn item with ${stats.mostWornItem.usage_times_worn} wears`,
      value: stats.mostWornItem.usage_times_worn,
      category: 'achievement',
    })
  }

  // Dormant items warning
  if (stats.dormantItems && stats.dormantItems.length > 0) {
    facts.push({
      id: 'dormant-items',
      emoji: '😴',
      title: 'Sleeping Beauties',
      description: `${stats.dormantItems.length} items haven't been worn in over a month`,
      value: stats.dormantItems.length,
      category: 'tip',
    })
  }

  // Color diversity
  if (stats.colorDiversity !== undefined) {
    if (stats.colorDiversity > 70) {
      facts.push({
        id: 'color-rainbow',
        emoji: '🌈',
        title: 'Color Explorer',
        description: 'You have a diverse color palette! Great for versatile styling.',
        value: stats.colorDiversity,
        category: 'insight',
      })
    } else if (stats.colorDiversity < 30) {
      facts.push({
        id: 'color-focused',
        emoji: '🎨',
        title: 'Signature Palette',
        description: 'You have a focused color scheme. Very cohesive!',
        value: stats.colorDiversity,
        category: 'insight',
      })
    }
  }

  // Sustainability fact
  if (stats.totalWears && stats.totalWears > 0) {
    const estimatedNewItems = Math.floor(stats.totalWears / 30) // Assuming 30 wears = 1 new item avoided
    if (estimatedNewItems > 0) {
      facts.push({
        id: 'sustainability',
        emoji: '🌱',
        title: 'Eco Warrior',
        description: `By rewearing items, you've potentially avoided buying ${estimatedNewItems} new items!`,
        value: estimatedNewItems,
        category: 'achievement',
      })
    }
  }

  // Category imbalance
  const categoryCount = stats.categoryBreakdown?.reduce((acc, c) => acc + c.count, 0) || 0
  const topsPercentage = ((items.filter((i) => i.category === 'tops').length / categoryCount) * 100) || 0
  if (topsPercentage > 50) {
    facts.push({
      id: 'tops-heavy',
      emoji: '👕',
      title: 'Top Heavy',
      description: 'Over half your wardrobe is tops! Consider balancing with other categories.',
      value: Math.round(topsPercentage),
      category: 'tip',
    })
  }

  // Outfit creator
  if (outfits.length > 10) {
    facts.push({
      id: 'outfit-creator',
      emoji: '✨',
      title: 'Style Curator',
      description: `You've created ${outfits.length} outfit combinations!`,
      value: outfits.length,
      category: 'achievement',
    })
  }

  // Favorite items
  const favorites = items.filter((i) => i.is_favorite)
  if (favorites.length > 0) {
    facts.push({
      id: 'favorites',
      emoji: '❤️',
      title: 'Cherished Pieces',
      description: `You've marked ${favorites.length} items as favorites`,
      value: favorites.length,
      category: 'insight',
    })
  }

  return facts
}

// ============================================================================
// MAIN FUNCTION
// ============================================================================

/**
 * Calculate comprehensive wardrobe statistics.
 */
export function calculateWardrobeStats(items: Item[], outfits: Outfit[]): WardrobeStats {
  // Basic counts
  const totalItems = items.length
  const totalOutfits = outfits.length
  const totalValue = items.reduce((sum, i) => sum + (i.purchase_price || 0), 0)
  const totalWears = items.reduce((sum, i) => sum + i.usage_times_worn, 0)
  const averageWearsPerItem = totalItems > 0 ? Math.round(totalWears / totalItems) : 0

  // Cost per wear
  const itemsWithPrice = items.filter((i) => i.purchase_price && i.purchase_price > 0)
  const itemsWithWears = itemsWithPrice.filter((i) => i.usage_times_worn > 0)
  const averageCostPerWear = itemsWithWears.length > 0
    ? itemsWithWears.reduce((sum, i) => sum + calculateCostPerWear(i), 0) / itemsWithWears.length
    : 0

  // Champions - with wear history
  const wornItems = items.filter((i) => i.usage_times_worn > 0)
  const sortedByWears = [...wornItems].sort((a, b) => b.usage_times_worn - a.usage_times_worn)
  const mostWornItem = sortedByWears[0] || null
  const leastWornItem = sortedByWears.length > 0 ? sortedByWears[sortedByWears.length - 1] : null

  // Most versatile (appears in most outfits + high wear count)
  const itemVersatility = items.map((item) => ({
    item,
    score: calculateVersatilityScore(item, outfits),
  }))
  itemVersatility.sort((a, b) => b.score - a.score)
  const mostVersatileItem = itemVersatility[0]?.item || null

  // Best value (lowest cost per wear)
  const itemsWithCPW = itemsWithWears.map((item) => ({
    item,
    cpw: calculateCostPerWear(item),
  }))
  itemsWithCPW.sort((a, b) => a.cpw - b.cpw)
  const bestValueItem = itemsWithCPW[0]?.item || null
  const costPerWearLeaders = itemsWithCPW.slice(0, 5)

  // Most expensive
  const sortedByPrice = [...items]
    .filter((i) => i.purchase_price)
    .sort((a, b) => (b.purchase_price || 0) - (a.purchase_price || 0))
  const mostExpensiveItem = sortedByPrice[0] || null

  // Category breakdown
  const categories: Category[] = ['tops', 'bottoms', 'shoes', 'outerwear', 'accessories', 'activewear', 'swimwear', 'other']
  const categoryBreakdown: CategoryStats[] = categories.map((category) => {
    const categoryItems = items.filter((i) => i.category === category)
    const count = categoryItems.length
    const categoryValue = categoryItems.reduce((sum, i) => sum + (i.purchase_price || 0), 0)
    const categoryWears = categoryItems.reduce((sum, i) => sum + i.usage_times_worn, 0)
    const topItem = [...categoryItems].sort((a, b) => b.usage_times_worn - a.usage_times_worn)[0] || null

    return {
      category,
      count,
      percentage: totalItems > 0 ? Math.round((count / totalItems) * 100) : 0,
      totalValue: categoryValue,
      averageWears: count > 0 ? Math.round(categoryWears / count) : 0,
      topItem,
    }
  }).filter((c) => c.count > 0)

  const dominantCategory = categoryBreakdown.length > 0
    ? categoryBreakdown.sort((a, b) => b.count - a.count)[0].category
    : null

  // Color analysis
  const colorCounts: Record<string, number> = {}
  for (const item of items) {
    for (const color of item.colors) {
      const normalized = color.toLowerCase().trim()
      colorCounts[normalized] = (colorCounts[normalized] || 0) + 1
    }
  }
  const colorPalette: ColorStats[] = Object.entries(colorCounts)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 12)
    .map(([color, count]) => ({
      color,
      count,
      percentage: Math.round((count / totalItems) * 100),
      hexApprox: getColorHex(color),
    }))

  const dominantColors = colorPalette.slice(0, 3).map((c) => c.color)
  const uniqueColors = Object.keys(colorCounts).length
  const colorDiversity = Math.min(100, Math.round((uniqueColors / 20) * 100)) // 20 colors = 100%

  // Style analysis
  const styleCounts: Record<string, number> = {}
  for (const item of items) {
    if (item.style) {
      styleCounts[item.style] = (styleCounts[item.style] || 0) + 1
    }
  }
  const styleBreakdown = Object.entries(styleCounts)
    .sort((a, b) => b[1] - a[1])
    .map(([style, count]) => ({
      style: style as Style,
      count,
      percentage: Math.round((count / totalItems) * 100),
    }))

  const primaryStyle = styleBreakdown[0]?.style || null
  const personalityInfo = primaryStyle ? STYLE_PERSONALITIES[primaryStyle] : null
  const stylePersonality = personalityInfo
    ? `${personalityInfo.emoji} ${personalityInfo.name}`
    : '🎭 The Eclectic'

  // Seasonal balance
  const seasonCounts: Record<string, number> = {}
  for (const item of items) {
    if (item.season) {
      seasonCounts[item.season] = (seasonCounts[item.season] || 0) + 1
    }
  }
  const seasonalBalance = Object.entries(seasonCounts)
    .map(([season, count]) => ({
      season: season as Season,
      count,
      percentage: Math.round((count / totalItems) * 100),
    }))

  // Time insights
  const sortedByCreated = [...items].sort(
    (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
  )
  const newestItem = sortedByCreated[0] || null
  const oldestItem = sortedByCreated[sortedByCreated.length - 1] || null
  const totalAge = items.reduce((sum, i) => sum + getDaysSince(i.created_at), 0)
  const averageItemAge = items.length > 0 ? Math.round(totalAge / items.length) : 0

  // Dormant items (not worn in 30+ days)
  const dormantItems = items.filter((item) => {
    if (!item.usage_last_worn) return true
    return getDaysSince(item.usage_last_worn) > 30
  })

  // Workhorse items (top 10% by versatility)
  const workhorseCount = Math.max(1, Math.ceil(items.length * 0.1))
  const workhorseItems = itemVersatility.slice(0, workhorseCount).map((iv) => iv.item)

  // Sustainability score (based on average wears and rewear rate)
  const targetWears = 30 // Industry target for sustainable fashion
  const wearRatio = averageWearsPerItem / targetWears
  const sustainabilityScore = Math.min(100, Math.round(wearRatio * 100))
  const estimatedCarbonSavings = Math.round(totalWears * 0.5) // ~0.5kg CO2 per wear vs buying new

  // Build partial stats for fun facts
  const partialStats: Partial<WardrobeStats> = {
    totalValue,
    totalWears,
    bestValueItem,
    mostWornItem,
    dormantItems,
    colorDiversity,
    categoryBreakdown,
  }

  const funFacts = generateFunFacts(items, outfits, partialStats)

  return {
    totalItems,
    totalOutfits,
    totalValue,
    totalWears,
    averageWearsPerItem,
    averageCostPerWear,
    mostWornItem,
    leastWornItem,
    mostVersatileItem,
    bestValueItem,
    mostExpensiveItem,
    categoryBreakdown,
    dominantCategory,
    colorPalette,
    dominantColors,
    colorDiversity,
    styleBreakdown,
    primaryStyle,
    stylePersonality,
    seasonalBalance,
    funFacts,
    newestItem,
    oldestItem,
    averageItemAge,
    totalRetailValue: totalValue,
    costPerWearLeaders,
    dormantItems,
    workhorseItems,
    sustainabilityScore,
    estimatedCarbonSavings,
  }
}

/**
 * Get quick stats summary (for dashboard).
 */
export function getQuickStats(items: Item[], outfits: Outfit[]): {
  totalItems: number
  totalOutfits: number
  totalValue: string
  averageWears: number
  favoriteCount: number
} {
  const totalValue = items.reduce((sum, i) => sum + (i.purchase_price || 0), 0)
  const totalWears = items.reduce((sum, i) => sum + i.usage_times_worn, 0)

  return {
    totalItems: items.length,
    totalOutfits: outfits.length,
    totalValue: new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    }).format(totalValue),
    averageWears: items.length > 0 ? Math.round(totalWears / items.length) : 0,
    favoriteCount: items.filter((i) => i.is_favorite).length,
  }
}
