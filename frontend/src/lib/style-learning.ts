/**
 * Style Learning Service
 *
 * Tracks user interactions with items and outfits to learn style preferences.
 * Uses local storage for interaction tracking and periodically syncs insights
 * to the backend for AI analysis.
 */

import type { Item, Outfit, UserPreferences } from '@/types'
import { updateUserPreferences, getUserPreferences } from '@/api/users'

// ============================================================================
// TYPES
// ============================================================================

export interface StyleInteraction {
  type: 'favorite' | 'unfavorite' | 'worn' | 'outfit_created' | 'item_added' | 'item_viewed' | 'outfit_generated'
  itemId?: string
  outfitId?: string
  category?: string
  colors?: string[]
  style?: string
  brand?: string
  timestamp: number
}

export interface StyleInsight {
  type: 'color' | 'style' | 'brand' | 'category' | 'pattern'
  value: string
  confidence: number
  count: number
  message: string
}

export interface LearnedPreferences {
  topColors: Array<{ color: string; score: number }>
  topStyles: Array<{ style: string; score: number }>
  topBrands: Array<{ brand: string; score: number }>
  topCategories: Array<{ category: string; score: number }>
  colorTemperature: 'warm' | 'cool' | 'neutral' | 'mixed'
  stylePersonality: string
  insights: StyleInsight[]
  dataPointsAnalyzed: number
  lastAnalyzed: string
}

// ============================================================================
// CONSTANTS
// ============================================================================

const STORAGE_KEY = 'fitcheck_style_interactions'
const INSIGHTS_KEY = 'fitcheck_style_insights'
const MAX_INTERACTIONS = 500
const MIN_INTERACTIONS_FOR_ANALYSIS = 10

// Color temperature classifications
const WARM_COLORS = ['red', 'orange', 'yellow', 'gold', 'coral', 'peach', 'rust', 'terracotta', 'burgundy', 'maroon']
const COOL_COLORS = ['blue', 'navy', 'teal', 'cyan', 'purple', 'lavender', 'mint', 'emerald', 'sage', 'slate']

// Style personality mappings
const STYLE_PERSONALITIES: Record<string, string[]> = {
  'Classic Minimalist': ['minimalist', 'classic', 'timeless', 'elegant'],
  'Urban Trendsetter': ['streetwear', 'urban', 'trendy', 'contemporary'],
  'Casual Comfort': ['casual', 'relaxed', 'comfortable', 'everyday'],
  'Bold Maximalist': ['bold', 'colorful', 'eclectic', 'artistic'],
  'Professional Polished': ['business', 'formal', 'professional', 'polished'],
  'Boho Free Spirit': ['bohemian', 'boho', 'artistic', 'vintage'],
  'Athletic Active': ['sporty', 'athletic', 'activewear', 'performance'],
}

// ============================================================================
// STORAGE FUNCTIONS
// ============================================================================

function getStoredInteractions(): StyleInteraction[] {
  try {
    const stored = localStorage.getItem(STORAGE_KEY)
    return stored ? JSON.parse(stored) : []
  } catch {
    return []
  }
}

function saveInteractions(interactions: StyleInteraction[]): void {
  try {
    // Keep only the most recent interactions
    const trimmed = interactions.slice(-MAX_INTERACTIONS)
    localStorage.setItem(STORAGE_KEY, JSON.stringify(trimmed))
  } catch (error) {
    console.error('Failed to save style interactions:', error)
  }
}

function getStoredInsights(): LearnedPreferences | null {
  try {
    const stored = localStorage.getItem(INSIGHTS_KEY)
    return stored ? JSON.parse(stored) : null
  } catch {
    return null
  }
}

function saveInsights(insights: LearnedPreferences): void {
  try {
    localStorage.setItem(INSIGHTS_KEY, JSON.stringify(insights))
  } catch (error) {
    console.error('Failed to save style insights:', error)
  }
}

// ============================================================================
// TRACKING FUNCTIONS
// ============================================================================

/**
 * Track a style-related user interaction.
 */
export function trackInteraction(interaction: Omit<StyleInteraction, 'timestamp'>): void {
  const interactions = getStoredInteractions()
  interactions.push({
    ...interaction,
    timestamp: Date.now(),
  })
  saveInteractions(interactions)
}

/**
 * Track when user favorites an item.
 */
export function trackItemFavorite(item: Item): void {
  trackInteraction({
    type: 'favorite',
    itemId: item.id,
    category: item.category,
    colors: item.colors,
    brand: item.brand,
  })
}

/**
 * Track when user unfavorites an item.
 */
export function trackItemUnfavorite(item: Item): void {
  trackInteraction({
    type: 'unfavorite',
    itemId: item.id,
    category: item.category,
    colors: item.colors,
    brand: item.brand,
  })
}

/**
 * Track when user wears an item.
 */
export function trackItemWorn(item: Item): void {
  trackInteraction({
    type: 'worn',
    itemId: item.id,
    category: item.category,
    colors: item.colors,
    brand: item.brand,
  })
}

/**
 * Track when user creates an outfit.
 */
export function trackOutfitCreated(outfit: Outfit, style?: string): void {
  trackInteraction({
    type: 'outfit_created',
    outfitId: outfit.id,
    style,
    colors: (outfit.items || []).flatMap((item) => item.colors || []),
  })
}

/**
 * Track when user adds an item to wardrobe.
 */
export function trackItemAdded(item: Item): void {
  trackInteraction({
    type: 'item_added',
    itemId: item.id,
    category: item.category,
    colors: item.colors,
    brand: item.brand,
  })
}

/**
 * Track when user generates an AI outfit with specific style.
 */
export function trackOutfitGenerated(style: string, colors: string[]): void {
  trackInteraction({
    type: 'outfit_generated',
    style,
    colors,
  })
}

// ============================================================================
// ANALYSIS FUNCTIONS
// ============================================================================

/**
 * Analyze interactions and generate style insights.
 */
export function analyzeStylePreferences(): LearnedPreferences {
  const interactions = getStoredInteractions()

  if (interactions.length < MIN_INTERACTIONS_FOR_ANALYSIS) {
    return {
      topColors: [],
      topStyles: [],
      topBrands: [],
      topCategories: [],
      colorTemperature: 'mixed',
      stylePersonality: 'Exploring',
      insights: [],
      dataPointsAnalyzed: interactions.length,
      lastAnalyzed: new Date().toISOString(),
    }
  }

  // Create weight map based on interaction type
  const interactionWeights: Record<StyleInteraction['type'], number> = {
    favorite: 3,
    worn: 2,
    outfit_created: 2,
    outfit_generated: 1.5,
    item_added: 1,
    item_viewed: 0.5,
    unfavorite: -2,
  }

  // Extract and weight data
  const colorData: Array<{ color: string; weight: number }> = []
  const styleData: Array<{ style: string; weight: number }> = []
  const brandData: Array<{ brand: string; weight: number }> = []
  const categoryData: Array<{ category: string; weight: number }> = []

  interactions.forEach((interaction) => {
    const weight = interactionWeights[interaction.type]

    if (interaction.colors) {
      interaction.colors.forEach((color) => {
        colorData.push({ color: color.toLowerCase(), weight })
      })
    }

    if (interaction.style) {
      styleData.push({ style: interaction.style.toLowerCase(), weight })
    }

    if (interaction.brand) {
      brandData.push({ brand: interaction.brand, weight })
    }

    if (interaction.category) {
      categoryData.push({ category: interaction.category, weight })
    }
  })

  // Aggregate scores
  const colorScores = new Map<string, number>()
  colorData.forEach(({ color, weight }) => {
    colorScores.set(color, (colorScores.get(color) || 0) + weight)
  })

  const styleScores = new Map<string, number>()
  styleData.forEach(({ style, weight }) => {
    styleScores.set(style, (styleScores.get(style) || 0) + weight)
  })

  const brandScores = new Map<string, number>()
  brandData.forEach(({ brand, weight }) => {
    brandScores.set(brand, (brandScores.get(brand) || 0) + weight)
  })

  const categoryScores = new Map<string, number>()
  categoryData.forEach(({ category, weight }) => {
    categoryScores.set(category, (categoryScores.get(category) || 0) + weight)
  })

  // Sort and get top items
  const topColors = Array.from(colorScores.entries())
    .map(([color, score]) => ({ color, score }))
    .sort((a, b) => b.score - a.score)
    .slice(0, 5)

  const topStyles = Array.from(styleScores.entries())
    .map(([style, score]) => ({ style, score }))
    .sort((a, b) => b.score - a.score)
    .slice(0, 5)

  const topBrands = Array.from(brandScores.entries())
    .map(([brand, score]) => ({ brand, score }))
    .sort((a, b) => b.score - a.score)
    .slice(0, 5)

  const topCategories = Array.from(categoryScores.entries())
    .map(([category, score]) => ({ category, score }))
    .sort((a, b) => b.score - a.score)
    .slice(0, 5)

  // Determine color temperature
  let warmScore = 0
  let coolScore = 0
  topColors.forEach(({ color, score }) => {
    if (WARM_COLORS.some((w) => color.includes(w))) warmScore += score
    if (COOL_COLORS.some((c) => color.includes(c))) coolScore += score
  })

  let colorTemperature: LearnedPreferences['colorTemperature'] = 'mixed'
  if (warmScore > coolScore * 1.5) colorTemperature = 'warm'
  else if (coolScore > warmScore * 1.5) colorTemperature = 'cool'
  else if (Math.abs(warmScore - coolScore) < 5) colorTemperature = 'neutral'

  // Determine style personality
  let stylePersonality = 'Eclectic Explorer'
  const topStyleNames = topStyles.map((s) => s.style)
  for (const [personality, styles] of Object.entries(STYLE_PERSONALITIES)) {
    if (topStyleNames.some((s) => styles.includes(s))) {
      stylePersonality = personality
      break
    }
  }

  // Generate insights
  const insights: StyleInsight[] = []

  if (topColors.length > 0) {
    insights.push({
      type: 'color',
      value: topColors[0].color,
      confidence: Math.min(topColors[0].score / 10, 1),
      count: Math.round(topColors[0].score),
      message: `${topColors[0].color.charAt(0).toUpperCase() + topColors[0].color.slice(1)} is your go-to color`,
    })
  }

  if (topStyles.length > 0) {
    insights.push({
      type: 'style',
      value: topStyles[0].style,
      confidence: Math.min(topStyles[0].score / 10, 1),
      count: Math.round(topStyles[0].score),
      message: `You gravitate towards ${topStyles[0].style} looks`,
    })
  }

  if (topBrands.length > 0 && topBrands[0].score > 3) {
    insights.push({
      type: 'brand',
      value: topBrands[0].brand,
      confidence: Math.min(topBrands[0].score / 10, 1),
      count: Math.round(topBrands[0].score),
      message: `${topBrands[0].brand} is a favorite brand`,
    })
  }

  if (topCategories.length > 0) {
    insights.push({
      type: 'category',
      value: topCategories[0].category,
      confidence: Math.min(topCategories[0].score / 15, 1),
      count: Math.round(topCategories[0].score),
      message: `Your wardrobe is strong in ${topCategories[0].category}`,
    })
  }

  const result: LearnedPreferences = {
    topColors,
    topStyles,
    topBrands,
    topCategories,
    colorTemperature,
    stylePersonality,
    insights,
    dataPointsAnalyzed: interactions.length,
    lastAnalyzed: new Date().toISOString(),
  }

  // Save locally
  saveInsights(result)

  return result
}

/**
 * Sync learned preferences to the backend.
 */
export async function syncPreferencesToBackend(): Promise<UserPreferences> {
  const learned = analyzeStylePreferences()

  // Only sync if we have enough data
  if (learned.dataPointsAnalyzed < MIN_INTERACTIONS_FOR_ANALYSIS) {
    return getUserPreferences()
  }

  return updateUserPreferences({
    favorite_colors: learned.topColors.slice(0, 5).map((c) => c.color),
    preferred_styles: learned.topStyles.slice(0, 5).map((s) => s.style),
    liked_brands: learned.topBrands.slice(0, 5).map((b) => b.brand),
    color_temperature: learned.colorTemperature,
    style_personality: learned.stylePersonality,
    data_points_collected: learned.dataPointsAnalyzed,
  })
}

/**
 * Get cached insights without reanalyzing.
 */
export function getCachedInsights(): LearnedPreferences | null {
  return getStoredInsights()
}

/**
 * Get the number of tracked interactions.
 */
export function getInteractionCount(): number {
  return getStoredInteractions().length
}

/**
 * Clear all tracked interactions.
 */
export function clearInteractions(): void {
  localStorage.removeItem(STORAGE_KEY)
  localStorage.removeItem(INSIGHTS_KEY)
}
