/**
 * Occasion Presets
 *
 * Pre-defined occasion filters for quick wardrobe and outfit filtering.
 * Each preset includes style, category, and tag filters optimized for
 * specific occasions.
 */

import type { Category, Style } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

export interface OccasionPreset {
  id: string
  name: string
  icon: string
  description: string
  /** Styles commonly associated with this occasion */
  styles: Style[]
  /** Categories particularly relevant for this occasion */
  categories: Category[]
  /** Tags to filter by */
  tags: string[]
  /** Seasonal relevance (optional) */
  seasons?: string[]
  /** Color suggestions for this occasion */
  suggestedColors?: string[]
  /** Time of day relevance */
  timeOfDay?: 'morning' | 'afternoon' | 'evening' | 'all'
}

export interface OccasionCategory {
  name: string
  icon: string
  occasions: OccasionPreset[]
}

// ============================================================================
// OCCASION PRESETS
// ============================================================================

export const OCCASION_PRESETS: OccasionPreset[] = [
  // Work & Professional
  {
    id: 'work-office',
    name: 'Office Work',
    icon: '💼',
    description: 'Professional attire for the office',
    styles: ['business', 'formal', 'minimalist'],
    categories: ['tops', 'bottoms', 'shoes', 'outerwear'],
    tags: ['work', 'office', 'professional', 'business'],
    timeOfDay: 'all',
    suggestedColors: ['navy', 'black', 'gray', 'white', 'blue'],
  },
  {
    id: 'work-casual',
    name: 'Business Casual',
    icon: '👔',
    description: 'Smart casual for relaxed work environments',
    styles: ['business', 'casual', 'preppy'],
    categories: ['tops', 'bottoms', 'shoes'],
    tags: ['business-casual', 'smart-casual', 'work'],
    timeOfDay: 'all',
    suggestedColors: ['navy', 'khaki', 'white', 'light blue'],
  },
  {
    id: 'interview',
    name: 'Job Interview',
    icon: '🤝',
    description: 'Make a great first impression',
    styles: ['formal', 'business', 'minimalist'],
    categories: ['tops', 'bottoms', 'shoes', 'outerwear', 'accessories'],
    tags: ['interview', 'professional', 'formal'],
    timeOfDay: 'all',
    suggestedColors: ['navy', 'black', 'gray', 'white'],
  },

  // Casual & Everyday
  {
    id: 'casual-day',
    name: 'Casual Day',
    icon: '☀️',
    description: 'Relaxed everyday outfits',
    styles: ['casual', 'streetwear', 'minimalist'],
    categories: ['tops', 'bottoms', 'shoes'],
    tags: ['casual', 'everyday', 'relaxed'],
    timeOfDay: 'all',
  },
  {
    id: 'weekend-errands',
    name: 'Weekend Errands',
    icon: '🛒',
    description: 'Comfortable for running errands',
    styles: ['casual', 'sporty'],
    categories: ['tops', 'bottoms', 'shoes', 'accessories'],
    tags: ['casual', 'comfortable', 'weekend'],
    timeOfDay: 'all',
  },
  {
    id: 'brunch',
    name: 'Brunch',
    icon: '🥐',
    description: 'Stylish yet relaxed for brunch',
    styles: ['casual', 'bohemian', 'romantic'],
    categories: ['tops', 'bottoms', 'shoes', 'accessories'],
    tags: ['brunch', 'casual', 'weekend'],
    timeOfDay: 'morning',
    suggestedColors: ['pastels', 'white', 'light blue', 'cream'],
  },

  // Social & Going Out
  {
    id: 'date-night',
    name: 'Date Night',
    icon: '💕',
    description: 'Romantic evening looks',
    styles: ['romantic', 'formal', 'edgy'],
    categories: ['tops', 'bottoms', 'shoes', 'accessories'],
    tags: ['date', 'romantic', 'evening'],
    timeOfDay: 'evening',
    suggestedColors: ['black', 'red', 'burgundy', 'navy'],
  },
  {
    id: 'night-out',
    name: 'Night Out',
    icon: '🌙',
    description: 'Party and club looks',
    styles: ['edgy', 'streetwear', 'formal'],
    categories: ['tops', 'bottoms', 'shoes', 'accessories'],
    tags: ['party', 'club', 'nightlife', 'going-out'],
    timeOfDay: 'evening',
    suggestedColors: ['black', 'silver', 'gold', 'red'],
  },
  {
    id: 'dinner-party',
    name: 'Dinner Party',
    icon: '🍽️',
    description: 'Elegant dinner gatherings',
    styles: ['formal', 'romantic', 'minimalist'],
    categories: ['tops', 'bottoms', 'shoes', 'accessories'],
    tags: ['dinner', 'formal', 'elegant'],
    timeOfDay: 'evening',
  },
  {
    id: 'cocktail',
    name: 'Cocktail Event',
    icon: '🍸',
    description: 'Semi-formal cocktail attire',
    styles: ['formal', 'romantic', 'minimalist'],
    categories: ['tops', 'bottoms', 'shoes', 'accessories'],
    tags: ['cocktail', 'semi-formal', 'event'],
    timeOfDay: 'evening',
  },

  // Active & Outdoor
  {
    id: 'workout',
    name: 'Workout',
    icon: '💪',
    description: 'Gym and exercise wear',
    styles: ['sporty'],
    categories: ['activewear', 'shoes', 'accessories'],
    tags: ['gym', 'workout', 'exercise', 'fitness'],
    timeOfDay: 'all',
  },
  {
    id: 'outdoor-hike',
    name: 'Hiking',
    icon: '🥾',
    description: 'Trail-ready outdoor wear',
    styles: ['sporty', 'casual'],
    categories: ['activewear', 'outerwear', 'shoes', 'accessories'],
    tags: ['hiking', 'outdoor', 'nature', 'adventure'],
    timeOfDay: 'morning',
  },
  {
    id: 'beach-day',
    name: 'Beach Day',
    icon: '🏖️',
    description: 'Beach and pool ready',
    styles: ['casual', 'bohemian'],
    categories: ['swimwear', 'accessories', 'shoes'],
    tags: ['beach', 'pool', 'summer', 'vacation'],
    seasons: ['summer'],
    timeOfDay: 'all',
  },

  // Special Events
  {
    id: 'wedding-guest',
    name: 'Wedding Guest',
    icon: '💒',
    description: 'Elegant wedding guest attire',
    styles: ['formal', 'romantic', 'vintage'],
    categories: ['tops', 'bottoms', 'shoes', 'accessories'],
    tags: ['wedding', 'formal', 'event', 'celebration'],
    timeOfDay: 'all',
    suggestedColors: ['avoid white', 'pastels', 'navy', 'burgundy'],
  },
  {
    id: 'graduation',
    name: 'Graduation',
    icon: '🎓',
    description: 'Celebrate achievements in style',
    styles: ['formal', 'preppy', 'minimalist'],
    categories: ['tops', 'bottoms', 'shoes'],
    tags: ['graduation', 'ceremony', 'formal'],
    timeOfDay: 'all',
  },
  {
    id: 'holiday-party',
    name: 'Holiday Party',
    icon: '🎄',
    description: 'Festive holiday gatherings',
    styles: ['formal', 'romantic', 'vintage'],
    categories: ['tops', 'bottoms', 'shoes', 'accessories'],
    tags: ['holiday', 'festive', 'party', 'celebration'],
    seasons: ['winter'],
    timeOfDay: 'evening',
    suggestedColors: ['red', 'green', 'gold', 'silver', 'black'],
  },

  // Travel
  {
    id: 'travel-airport',
    name: 'Airport Travel',
    icon: '✈️',
    description: 'Comfortable yet put-together for travel',
    styles: ['casual', 'minimalist'],
    categories: ['tops', 'bottoms', 'shoes', 'outerwear', 'accessories'],
    tags: ['travel', 'airport', 'comfortable'],
    timeOfDay: 'all',
  },
  {
    id: 'vacation-sightseeing',
    name: 'Sightseeing',
    icon: '📸',
    description: 'Comfortable for walking tours',
    styles: ['casual', 'sporty'],
    categories: ['tops', 'bottoms', 'shoes', 'accessories'],
    tags: ['vacation', 'travel', 'sightseeing', 'tourist'],
    timeOfDay: 'all',
  },
]

// ============================================================================
// GROUPED BY CATEGORY
// ============================================================================

export const OCCASION_CATEGORIES: OccasionCategory[] = [
  {
    name: 'Work & Professional',
    icon: '💼',
    occasions: OCCASION_PRESETS.filter((o) =>
      ['work-office', 'work-casual', 'interview'].includes(o.id)
    ),
  },
  {
    name: 'Casual & Everyday',
    icon: '☀️',
    occasions: OCCASION_PRESETS.filter((o) =>
      ['casual-day', 'weekend-errands', 'brunch'].includes(o.id)
    ),
  },
  {
    name: 'Social & Going Out',
    icon: '🌙',
    occasions: OCCASION_PRESETS.filter((o) =>
      ['date-night', 'night-out', 'dinner-party', 'cocktail'].includes(o.id)
    ),
  },
  {
    name: 'Active & Outdoor',
    icon: '🏃',
    occasions: OCCASION_PRESETS.filter((o) =>
      ['workout', 'outdoor-hike', 'beach-day'].includes(o.id)
    ),
  },
  {
    name: 'Special Events',
    icon: '🎉',
    occasions: OCCASION_PRESETS.filter((o) =>
      ['wedding-guest', 'graduation', 'holiday-party'].includes(o.id)
    ),
  },
  {
    name: 'Travel',
    icon: '✈️',
    occasions: OCCASION_PRESETS.filter((o) =>
      ['travel-airport', 'vacation-sightseeing'].includes(o.id)
    ),
  },
]

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Get a specific occasion preset by ID.
 */
export function getOccasionById(id: string): OccasionPreset | undefined {
  return OCCASION_PRESETS.find((o) => o.id === id)
}

/**
 * Get occasions filtered by time of day.
 */
export function getOccasionsByTimeOfDay(
  time: 'morning' | 'afternoon' | 'evening'
): OccasionPreset[] {
  return OCCASION_PRESETS.filter((o) => o.timeOfDay === time || o.timeOfDay === 'all')
}

/**
 * Get occasions filtered by season.
 */
export function getOccasionsBySeason(season: string): OccasionPreset[] {
  return OCCASION_PRESETS.filter(
    (o) => !o.seasons || o.seasons.length === 0 || o.seasons.includes(season)
  )
}

/**
 * Search occasions by name or description.
 */
export function searchOccasions(query: string): OccasionPreset[] {
  const lowerQuery = query.toLowerCase()
  return OCCASION_PRESETS.filter(
    (o) =>
      o.name.toLowerCase().includes(lowerQuery) ||
      o.description.toLowerCase().includes(lowerQuery) ||
      o.tags.some((t) => t.includes(lowerQuery))
  )
}

/**
 * Get filter criteria from an occasion preset.
 * Returns an object that can be used with wardrobe/outfit filters.
 */
export function getFiltersFromOccasion(occasion: OccasionPreset): {
  styles: Style[]
  categories: Category[]
  tags: string[]
} {
  return {
    styles: occasion.styles,
    categories: occasion.categories,
    tags: occasion.tags,
  }
}
