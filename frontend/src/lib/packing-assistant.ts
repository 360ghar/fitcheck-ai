/**
 * Packing Assistant Service
 *
 * Helps users build minimal, versatile packing lists for trips.
 * Uses wardrobe items to create capsule wardrobes optimized for
 * trip duration, destination, and planned activities.
 */

import type { Item, Category, Style } from '@/types'
import { OCCASION_PRESETS } from './occasion-presets'

// ============================================================================
// TYPES
// ============================================================================

export interface TripDetails {
  destination: string
  startDate: string
  endDate: string
  climate: 'hot' | 'warm' | 'mild' | 'cold' | 'mixed'
  activities: TripActivity[]
  travelStyle: 'minimal' | 'comfortable' | 'comprehensive'
}

export type TripActivity =
  | 'business'
  | 'casual'
  | 'formal-dinner'
  | 'sightseeing'
  | 'beach'
  | 'hiking'
  | 'workout'
  | 'nightlife'

export interface PackingItem {
  item: Item
  quantity: number
  reason: string
  category: Category
  isEssential: boolean
  outfitPotential: number // How many outfits this item can create
}

export interface PackingSuggestion {
  category: Category
  description: string
  reason: string
  priority: 'must-have' | 'recommended' | 'optional'
}

export interface PackingList {
  tripDetails: TripDetails
  items: PackingItem[]
  suggestions: PackingSuggestion[]
  statistics: {
    totalItems: number
    outfitCombinations: number
    daysPerItem: number
    categoryCounts: Record<Category, number>
  }
  outfitIdeas: Array<{
    name: string
    activity: TripActivity
    itemIds: string[]
  }>
}

// ============================================================================
// CONSTANTS
// ============================================================================

/**
 * Base item counts per day based on travel style.
 */
const STYLE_MULTIPLIERS = {
  minimal: 0.5, // Pack light, rewear items
  comfortable: 0.75, // Moderate packing
  comprehensive: 1, // Full outfit per day
}

/**
 * Activity to occasion mapping.
 */
const ACTIVITY_TO_OCCASION: Record<TripActivity, string[]> = {
  business: ['work-office', 'work-casual', 'interview'],
  casual: ['casual-day', 'weekend-errands'],
  'formal-dinner': ['dinner-party', 'cocktail', 'date-night'],
  sightseeing: ['vacation-sightseeing', 'casual-day'],
  beach: ['beach-day'],
  hiking: ['outdoor-hike'],
  workout: ['workout'],
  nightlife: ['night-out', 'cocktail'],
}

/**
 * Climate-based category priorities.
 */
const CLIMATE_PRIORITIES: Record<string, Category[]> = {
  hot: ['tops', 'bottoms', 'shoes', 'swimwear', 'accessories'],
  warm: ['tops', 'bottoms', 'shoes', 'accessories'],
  mild: ['tops', 'bottoms', 'outerwear', 'shoes', 'accessories'],
  cold: ['outerwear', 'tops', 'bottoms', 'shoes', 'accessories'],
  mixed: ['tops', 'bottoms', 'outerwear', 'shoes', 'accessories'],
}

/**
 * Essential items per category based on trip length.
 */
const ESSENTIAL_COUNTS: Record<Category, { short: number; medium: number; long: number }> = {
  tops: { short: 3, medium: 5, long: 7 },
  bottoms: { short: 2, medium: 3, long: 4 },
  shoes: { short: 2, medium: 3, long: 4 },
  outerwear: { short: 1, medium: 2, long: 2 },
  accessories: { short: 2, medium: 4, long: 6 },
  activewear: { short: 1, medium: 2, long: 3 },
  swimwear: { short: 1, medium: 2, long: 2 },
  other: { short: 0, medium: 1, long: 2 },
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Calculate trip length category.
 */
function getTripLength(startDate: string, endDate: string): 'short' | 'medium' | 'long' {
  const start = new Date(startDate)
  const end = new Date(endDate)
  const days = Math.ceil((end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24))

  if (days <= 3) return 'short'
  if (days <= 7) return 'medium'
  return 'long'
}

/**
 * Get number of days in trip.
 */
function getTripDays(startDate: string, endDate: string): number {
  const start = new Date(startDate)
  const end = new Date(endDate)
  return Math.max(1, Math.ceil((end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24)))
}

/**
 * Score an item's versatility for packing.
 */
function scoreItemVersatility(item: Item, tripDetails: TripDetails): number {
  let score = 0

  // Neutral colors are more versatile
  const neutralColors = ['black', 'white', 'gray', 'navy', 'beige', 'brown', 'cream']
  const hasNeutral = item.colors.some((c) =>
    neutralColors.includes(c.toLowerCase())
  )
  if (hasNeutral) score += 3

  // Items that match multiple activities
  const matchingActivities = tripDetails.activities.filter((activity) => {
    const occasions = ACTIVITY_TO_OCCASION[activity] || []
    return occasions.some((occasionId) => {
      const occasion = OCCASION_PRESETS.find((o) => o.id === occasionId)
      if (!occasion) return false
      return occasion.categories.includes(item.category) ||
        (item.style && occasion.styles.includes(item.style as Style))
    })
  })
  score += matchingActivities.length * 2

  // Usage history indicates reliability
  if (item.usage_times_worn >= 10) score += 2
  else if (item.usage_times_worn >= 5) score += 1

  // Climate appropriateness
  if (tripDetails.climate === 'cold' && item.category === 'outerwear') score += 3
  if (tripDetails.climate === 'hot' && item.category === 'swimwear') score += 3

  // Favorites are trusted items
  if (item.is_favorite) score += 2

  return score
}

/**
 * Check if item matches activity requirements.
 */
function itemMatchesActivity(item: Item, activity: TripActivity): boolean {
  const occasionIds = ACTIVITY_TO_OCCASION[activity] || []

  return occasionIds.some((occasionId) => {
    const occasion = OCCASION_PRESETS.find((o) => o.id === occasionId)
    if (!occasion) return false

    const matchesCategory = occasion.categories.includes(item.category)
    const matchesStyle = item.style && occasion.styles.includes(item.style as Style)
    const matchesTags = item.tags.some((t) => occasion.tags.includes(t.toLowerCase()))

    return matchesCategory || matchesStyle || matchesTags
  })
}

// ============================================================================
// MAIN FUNCTIONS
// ============================================================================

/**
 * Generate a packing list for a trip.
 */
export function generatePackingList(
  items: Item[],
  tripDetails: TripDetails
): PackingList {
  const tripLength = getTripLength(tripDetails.startDate, tripDetails.endDate)
  const tripDays = getTripDays(tripDetails.startDate, tripDetails.endDate)
  const multiplier = STYLE_MULTIPLIERS[tripDetails.travelStyle]

  // Filter items that are available (clean)
  const availableItems = items.filter((item) => item.condition === 'clean')

  // Score all items for this trip
  const scoredItems = availableItems.map((item) => ({
    item,
    score: scoreItemVersatility(item, tripDetails),
    matchingActivities: tripDetails.activities.filter((a) => itemMatchesActivity(item, a)),
  }))

  // Sort by score
  scoredItems.sort((a, b) => b.score - a.score)

  // Select items per category
  const selectedItems: PackingItem[] = []
  const categoryCounts: Record<Category, number> = {
    tops: 0,
    bottoms: 0,
    shoes: 0,
    outerwear: 0,
    accessories: 0,
    activewear: 0,
    swimwear: 0,
    other: 0,
  }

  // Determine target counts per category
  const priorities = CLIMATE_PRIORITIES[tripDetails.climate] || CLIMATE_PRIORITIES.mild
  const essentialCounts = ESSENTIAL_COUNTS

  // First pass: select essential items for each activity
  const activityCoverage = new Map<TripActivity, boolean>()
  tripDetails.activities.forEach((activity) => activityCoverage.set(activity, false))

  for (const { item, matchingActivities } of scoredItems) {
    const baseCount = essentialCounts[item.category][tripLength]
    const targetCount = Math.ceil(baseCount * multiplier)

    if (categoryCounts[item.category] < targetCount) {
      const isEssential = priorities.slice(0, 3).includes(item.category)

      selectedItems.push({
        item,
        quantity: 1,
        reason: matchingActivities.length > 0
          ? `Great for ${matchingActivities.join(', ')}`
          : `Versatile ${item.category} item`,
        category: item.category,
        isEssential,
        outfitPotential: Math.max(1, matchingActivities.length * 2),
      })

      categoryCounts[item.category]++

      // Mark activities as covered
      matchingActivities.forEach((activity) => activityCoverage.set(activity, true))
    }
  }

  // Generate suggestions for missing items
  const suggestions: PackingSuggestion[] = []

  // Check for uncovered activities
  activityCoverage.forEach((covered, activity) => {
    if (!covered) {
      suggestions.push({
        category: 'tops',
        description: `Item suitable for ${activity}`,
        reason: `No items in your wardrobe match ${activity} activity`,
        priority: 'must-have',
      })
    }
  })

  // Climate-specific suggestions
  if (tripDetails.climate === 'cold' && categoryCounts.outerwear === 0) {
    suggestions.push({
      category: 'outerwear',
      description: 'Warm coat or jacket',
      reason: 'Essential for cold weather destination',
      priority: 'must-have',
    })
  }

  if ((tripDetails.climate === 'hot' || tripDetails.activities.includes('beach')) &&
      categoryCounts.swimwear === 0) {
    suggestions.push({
      category: 'swimwear',
      description: 'Swimsuit',
      reason: 'Needed for beach activities or hot climate',
      priority: 'must-have',
    })
  }

  if (tripDetails.activities.includes('workout') && categoryCounts.activewear === 0) {
    suggestions.push({
      category: 'activewear',
      description: 'Workout clothes',
      reason: 'Planned workout activities',
      priority: 'recommended',
    })
  }

  // Generate outfit ideas
  const outfitIdeas: PackingList['outfitIdeas'] = []
  tripDetails.activities.forEach((activity) => {
    const activityItems = selectedItems.filter((pi) =>
      itemMatchesActivity(pi.item, activity)
    )

    if (activityItems.length >= 2) {
      outfitIdeas.push({
        name: `${activity.charAt(0).toUpperCase() + activity.slice(1).replace('-', ' ')} Look`,
        activity,
        itemIds: activityItems.slice(0, 4).map((pi) => pi.item.id),
      })
    }
  })

  // Calculate statistics
  const totalItems = selectedItems.reduce((sum, pi) => sum + pi.quantity, 0)
  const outfitCombinations = calculateOutfitCombinations(selectedItems)

  return {
    tripDetails,
    items: selectedItems,
    suggestions,
    statistics: {
      totalItems,
      outfitCombinations,
      daysPerItem: Math.round((tripDays / totalItems) * 10) / 10,
      categoryCounts,
    },
    outfitIdeas,
  }
}

/**
 * Calculate approximate number of outfit combinations.
 */
function calculateOutfitCombinations(items: PackingItem[]): number {
  const tops = items.filter((i) => i.category === 'tops').length
  const bottoms = items.filter((i) => i.category === 'bottoms').length
  const shoes = items.filter((i) => i.category === 'shoes').length

  if (tops === 0 || bottoms === 0) return 0

  // Simple combination: tops * bottoms * shoes (if any)
  return tops * bottoms * Math.max(1, shoes)
}

/**
 * Get packing checklist format.
 */
export function getPackingChecklist(packingList: PackingList): string[] {
  const checklist: string[] = []

  // Group by category
  const grouped = new Map<Category, PackingItem[]>()
  packingList.items.forEach((item) => {
    const existing = grouped.get(item.category) || []
    existing.push(item)
    grouped.set(item.category, existing)
  })

  // Format checklist
  grouped.forEach((items, category) => {
    checklist.push(`\n## ${category.toUpperCase()}`)
    items.forEach((pi) => {
      const essential = pi.isEssential ? ' *' : ''
      checklist.push(`[ ] ${pi.item.name}${essential}`)
    })
  })

  // Add suggestions
  if (packingList.suggestions.length > 0) {
    checklist.push('\n## ITEMS TO BUY/BORROW')
    packingList.suggestions.forEach((s) => {
      checklist.push(`[ ] ${s.description} (${s.reason})`)
    })
  }

  return checklist
}

/**
 * Export packing list as formatted text.
 */
export function exportPackingList(packingList: PackingList): string {
  const lines: string[] = []

  lines.push(`# Packing List for ${packingList.tripDetails.destination}`)
  lines.push(`${packingList.tripDetails.startDate} - ${packingList.tripDetails.endDate}`)
  lines.push(`Climate: ${packingList.tripDetails.climate}`)
  lines.push(`Activities: ${packingList.tripDetails.activities.join(', ')}`)
  lines.push('')
  lines.push(`## Summary`)
  lines.push(`- Total items: ${packingList.statistics.totalItems}`)
  lines.push(`- Outfit combinations: ${packingList.statistics.outfitCombinations}`)
  lines.push('')

  lines.push(...getPackingChecklist(packingList))

  if (packingList.outfitIdeas.length > 0) {
    lines.push('\n## Outfit Ideas')
    packingList.outfitIdeas.forEach((outfit) => {
      const itemNames = packingList.items
        .filter((pi) => outfit.itemIds.includes(pi.item.id))
        .map((pi) => pi.item.name)
      lines.push(`- ${outfit.name}: ${itemNames.join(' + ')}`)
    })
  }

  return lines.join('\n')
}
