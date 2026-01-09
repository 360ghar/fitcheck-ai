/**
 * Sustainability Goals Service
 *
 * Helps users set and track sustainability-focused wardrobe goals.
 * Includes wear frequency targets, shopping reduction goals,
 * and environmental impact tracking.
 */

import type { Item, Outfit } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

export interface SustainabilityGoal {
  id: string
  type: GoalType
  title: string
  description: string
  target: number
  current: number
  unit: string
  startDate: string
  endDate?: string
  isActive: boolean
  createdAt: string
  completedAt?: string
}

export type GoalType =
  | 'wear-count'        // Wear items X times
  | 'no-new-items'      // Don't buy new items for X days
  | 'rewear-rate'       // Rewear X% of wardrobe
  | 'dormant-rescue'    // Wear X dormant items
  | 'cost-per-wear'     // Get average CPW below $X
  | 'capsule-challenge' // Use only X items for Y days
  | 'outfit-repeat'     // Create outfits without new purchases
  | 'donation-goal'     // Donate X items

export interface GoalTemplate {
  type: GoalType
  title: string
  description: string
  icon: string
  defaultTarget: number
  unit: string
  difficulty: 'easy' | 'medium' | 'hard'
  duration?: number // days
  tips: string[]
}

export interface SustainabilityStats {
  overallScore: number // 0-100
  totalGoalsCompleted: number
  currentStreak: number // consecutive days meeting goals
  carbonSaved: number // kg CO2
  moneyNotSpent: number // estimated savings from not buying
  itemsRescued: number // dormant items brought back
  averageWearCount: number
  rewearRate: number // percentage
}

export interface GoalProgress {
  goal: SustainabilityGoal
  percentComplete: number
  daysRemaining?: number
  onTrack: boolean
  projectedCompletion?: string
  suggestion?: string
}

// ============================================================================
// CONSTANTS
// ============================================================================

const STORAGE_KEY = 'fitcheck-sustainability-goals'

export const GOAL_TEMPLATES: GoalTemplate[] = [
  {
    type: 'wear-count',
    title: '30 Wears Challenge',
    description: 'Wear each item at least 30 times before considering replacement',
    icon: '👕',
    defaultTarget: 30,
    unit: 'wears per item',
    difficulty: 'medium',
    tips: [
      'Start with your most versatile pieces',
      'Track which items you reach for most',
      'Consider donating items you never choose',
    ],
  },
  {
    type: 'no-new-items',
    title: 'Shopping Pause',
    description: 'Go without buying new clothes for a period of time',
    icon: '🛑',
    defaultTarget: 30,
    unit: 'days',
    difficulty: 'medium',
    duration: 30,
    tips: [
      'Rediscover items already in your closet',
      'Make a wishlist instead of impulse buying',
      'Focus on creating new outfit combinations',
    ],
  },
  {
    type: 'rewear-rate',
    title: 'Wardrobe Activation',
    description: 'Wear a percentage of your wardrobe each month',
    icon: '🔄',
    defaultTarget: 80,
    unit: '% of items',
    difficulty: 'hard',
    duration: 30,
    tips: [
      'Create a rotation system',
      'Track unworn items and plan outfits with them',
      'Consider the 20% you never wear',
    ],
  },
  {
    type: 'dormant-rescue',
    title: 'Rescue Mission',
    description: 'Bring back items that haven\'t been worn in over a month',
    icon: '🦸',
    defaultTarget: 10,
    unit: 'items rescued',
    difficulty: 'easy',
    tips: [
      'Sort by last worn date to find dormant items',
      'Style them in new ways',
      'If you can\'t wear it, donate it',
    ],
  },
  {
    type: 'cost-per-wear',
    title: 'Value Maximizer',
    description: 'Lower your average cost per wear across all items',
    icon: '💰',
    defaultTarget: 5,
    unit: '$ per wear',
    difficulty: 'medium',
    tips: [
      'Focus on wearing expensive items more',
      'Quality over quantity for future purchases',
      'Track cost per wear improvements',
    ],
  },
  {
    type: 'capsule-challenge',
    title: 'Capsule Wardrobe Challenge',
    description: 'Live with only a limited number of items for a set period',
    icon: '📦',
    defaultTarget: 33,
    unit: 'items',
    difficulty: 'hard',
    duration: 90,
    tips: [
      'Choose versatile, mix-and-match pieces',
      'Include all categories you need',
      'Document what you learn about your style',
    ],
  },
  {
    type: 'outfit-repeat',
    title: 'No Buy Styling',
    description: 'Create new outfit combinations without purchasing anything',
    icon: '✨',
    defaultTarget: 20,
    unit: 'new outfits',
    difficulty: 'easy',
    tips: [
      'Experiment with unexpected combinations',
      'Try items in new contexts',
      'Use accessories to transform looks',
    ],
  },
  {
    type: 'donation-goal',
    title: 'Mindful Declutter',
    description: 'Donate items that no longer serve you',
    icon: '🎁',
    defaultTarget: 10,
    unit: 'items donated',
    difficulty: 'easy',
    tips: [
      'One in, one out rule',
      'Donate items you haven\'t worn in a year',
      'Give to local charities or clothing swaps',
    ],
  },
]

// ============================================================================
// STORAGE
// ============================================================================

function getStoredGoals(): SustainabilityGoal[] {
  try {
    const stored = localStorage.getItem(STORAGE_KEY)
    if (!stored) return []
    return JSON.parse(stored) as SustainabilityGoal[]
  } catch {
    return []
  }
}

function saveGoals(goals: SustainabilityGoal[]): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(goals))
  } catch (error) {
    console.error('Failed to save sustainability goals:', error)
  }
}

// ============================================================================
// GOAL MANAGEMENT
// ============================================================================

function generateId(): string {
  return `goal-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`
}

/**
 * Create a new sustainability goal.
 */
export function createGoal(
  type: GoalType,
  options: {
    title?: string
    description?: string
    target?: number
    endDate?: string
  } = {}
): SustainabilityGoal {
  const template = GOAL_TEMPLATES.find((t) => t.type === type)

  if (!template) {
    throw new Error(`Unknown goal type: ${type}`)
  }

  const goal: SustainabilityGoal = {
    id: generateId(),
    type,
    title: options.title || template.title,
    description: options.description || template.description,
    target: options.target || template.defaultTarget,
    current: 0,
    unit: template.unit,
    startDate: new Date().toISOString().split('T')[0],
    endDate: options.endDate,
    isActive: true,
    createdAt: new Date().toISOString(),
  }

  const goals = getStoredGoals()
  goals.push(goal)
  saveGoals(goals)

  return goal
}

/**
 * Get all goals.
 */
export function getGoals(): SustainabilityGoal[] {
  return getStoredGoals()
}

/**
 * Get active goals only.
 */
export function getActiveGoals(): SustainabilityGoal[] {
  return getStoredGoals().filter((g) => g.isActive && !g.completedAt)
}

/**
 * Update goal progress.
 */
export function updateGoalProgress(goalId: string, current: number): SustainabilityGoal | null {
  const goals = getStoredGoals()
  const index = goals.findIndex((g) => g.id === goalId)

  if (index === -1) return null

  goals[index].current = current

  // Check if goal is completed
  if (current >= goals[index].target && !goals[index].completedAt) {
    goals[index].completedAt = new Date().toISOString()
    goals[index].isActive = false
  }

  saveGoals(goals)
  return goals[index]
}

/**
 * Deactivate a goal.
 */
export function deactivateGoal(goalId: string): boolean {
  const goals = getStoredGoals()
  const index = goals.findIndex((g) => g.id === goalId)

  if (index === -1) return false

  goals[index].isActive = false
  saveGoals(goals)
  return true
}

/**
 * Delete a goal.
 */
export function deleteGoal(goalId: string): boolean {
  const goals = getStoredGoals()
  const filtered = goals.filter((g) => g.id !== goalId)

  if (filtered.length === goals.length) return false

  saveGoals(filtered)
  return true
}

// ============================================================================
// PROGRESS CALCULATION
// ============================================================================

/**
 * Calculate progress for a goal based on wardrobe data.
 */
export function calculateGoalProgress(
  goal: SustainabilityGoal,
  items: Item[],
  outfits: Outfit[]
): GoalProgress {
  let current = goal.current
  let suggestion: string | undefined

  // Auto-calculate current based on goal type
  switch (goal.type) {
    case 'wear-count': {
      const totalWears = items.reduce((sum, i) => sum + i.usage_times_worn, 0)
      const avgWears = items.length > 0 ? totalWears / items.length : 0
      current = Math.round(avgWears)
      if (current < goal.target) {
        suggestion = `Wear items ${Math.ceil(goal.target - current)} more times on average`
      }
      break
    }

    case 'rewear-rate': {
      const wornItems = items.filter((i) => i.usage_times_worn > 0)
      current = items.length > 0 ? Math.round((wornItems.length / items.length) * 100) : 0
      if (current < goal.target) {
        const neededItems = Math.ceil((goal.target / 100) * items.length) - wornItems.length
        suggestion = `Wear ${neededItems} more unworn items`
      }
      break
    }

    case 'dormant-rescue': {
      const thirtyDaysAgo = new Date()
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)
      const _dormantWorn = items.filter((i) => {
        if (!i.usage_last_worn) return false
        const lastWorn = new Date(i.usage_last_worn)
        return lastWorn >= thirtyDaysAgo && i.usage_times_worn > 0
      })
      // This needs tracking of when items were "rescued" - using current for now
      void _dormantWorn // Placeholder for future implementation
      break
    }

    case 'cost-per-wear': {
      const itemsWithPrice = items.filter((i) => i.purchase_price && i.usage_times_worn > 0)
      if (itemsWithPrice.length > 0) {
        const totalCPW = itemsWithPrice.reduce(
          (sum, i) => sum + (i.purchase_price! / i.usage_times_worn),
          0
        )
        current = Math.round((totalCPW / itemsWithPrice.length) * 100) / 100
      }
      if (current > goal.target) {
        suggestion = 'Keep wearing your higher-priced items to lower CPW'
      }
      break
    }

    case 'outfit-repeat': {
      current = outfits.length
      break
    }

    case 'no-new-items': {
      // Calculate days since goal started
      const startDate = new Date(goal.startDate)
      const now = new Date()
      current = Math.floor((now.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24))
      break
    }

    case 'capsule-challenge': {
      // Would need UI to mark items as part of capsule
      break
    }

    case 'donation-goal': {
      // Would need tracking of donated items
      break
    }
  }

  const percentComplete = Math.min(100, Math.round((current / goal.target) * 100))

  // Calculate days remaining if there's an end date
  let daysRemaining: number | undefined
  if (goal.endDate) {
    const end = new Date(goal.endDate)
    const now = new Date()
    daysRemaining = Math.max(0, Math.ceil((end.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)))
  }

  // Determine if on track
  const onTrack =
    percentComplete >= 100 ||
    (daysRemaining !== undefined && percentComplete >= (1 - daysRemaining / 30) * 100)

  return {
    goal: { ...goal, current },
    percentComplete,
    daysRemaining,
    onTrack,
    suggestion,
  }
}

// ============================================================================
// SUSTAINABILITY STATS
// ============================================================================

/**
 * Calculate overall sustainability statistics.
 */
export function calculateSustainabilityStats(items: Item[], _outfits: Outfit[]): SustainabilityStats {
  const goals = getStoredGoals()
  const completedGoals = goals.filter((g) => g.completedAt)

  // Calculate total wears
  const totalWears = items.reduce((sum, i) => sum + i.usage_times_worn, 0)
  const averageWearCount = items.length > 0 ? Math.round(totalWears / items.length) : 0

  // Rewear rate
  const wornItems = items.filter((i) => i.usage_times_worn > 0)
  const rewearRate = items.length > 0 ? Math.round((wornItems.length / items.length) * 100) : 0

  // Carbon saved (estimate: 0.5kg CO2 per wear vs buying new)
  const carbonSaved = Math.round(totalWears * 0.5)

  // Money not spent (estimate: $30 average per avoided purchase, 30 wears = 1 item)
  const itemsAvoided = Math.floor(totalWears / 30)
  const moneyNotSpent = itemsAvoided * 30

  // Items rescued (worn in last 30 days that were dormant before)
  const thirtyDaysAgo = new Date()
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)
  const recentlyWorn = items.filter((i) => {
    if (!i.usage_last_worn) return false
    return new Date(i.usage_last_worn) >= thirtyDaysAgo
  })
  const itemsRescued = recentlyWorn.length

  // Overall score (weighted average)
  const wearScore = Math.min(100, (averageWearCount / 30) * 100)
  const rewearScore = rewearRate
  const goalScore = Math.min(100, completedGoals.length * 20)
  const overallScore = Math.round((wearScore * 0.4 + rewearScore * 0.4 + goalScore * 0.2))

  // Streak calculation (would need daily tracking - simplified here)
  const currentStreak = completedGoals.length > 0 ? completedGoals.length * 7 : 0

  return {
    overallScore,
    totalGoalsCompleted: completedGoals.length,
    currentStreak,
    carbonSaved,
    moneyNotSpent,
    itemsRescued,
    averageWearCount,
    rewearRate,
  }
}

/**
 * Get suggested goals based on current wardrobe state.
 */
export function getSuggestedGoals(items: Item[], outfits: Outfit[]): GoalTemplate[] {
  const suggestions: GoalTemplate[] = []
  const stats = calculateSustainabilityStats(items, outfits)

  // Suggest based on current stats
  if (stats.averageWearCount < 10) {
    suggestions.push(GOAL_TEMPLATES.find((t) => t.type === 'wear-count')!)
  }

  if (stats.rewearRate < 60) {
    suggestions.push(GOAL_TEMPLATES.find((t) => t.type === 'rewear-rate')!)
  }

  // Check for dormant items
  const dormantItems = items.filter((i) => {
    if (!i.usage_last_worn) return true
    const lastWorn = new Date(i.usage_last_worn)
    const thirtyDaysAgo = new Date()
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)
    return lastWorn < thirtyDaysAgo
  })

  if (dormantItems.length > 5) {
    suggestions.push(GOAL_TEMPLATES.find((t) => t.type === 'dormant-rescue')!)
  }

  // Always suggest these as good starting points
  if (suggestions.length === 0) {
    suggestions.push(
      GOAL_TEMPLATES.find((t) => t.type === 'no-new-items')!,
      GOAL_TEMPLATES.find((t) => t.type === 'outfit-repeat')!
    )
  }

  return suggestions.filter(Boolean).slice(0, 3)
}

/**
 * Get environmental impact summary.
 */
export function getEnvironmentalImpact(items: Item[]): {
  carbonSaved: number
  waterSaved: number
  wasteAvoided: number
  equivalents: string[]
} {
  const totalWears = items.reduce((sum, i) => sum + i.usage_times_worn, 0)

  // Estimates based on fashion industry data
  const carbonSaved = Math.round(totalWears * 0.5) // kg CO2
  const waterSaved = Math.round(totalWears * 10) // liters (cotton shirt uses ~2700L to make)
  const wasteAvoided = Math.round(totalWears / 30) // kg (average garment weight)

  const equivalents: string[] = []

  if (carbonSaved >= 100) {
    equivalents.push(`Equivalent to ${Math.round(carbonSaved / 4)} car trips avoided`)
  }
  if (waterSaved >= 1000) {
    equivalents.push(`Saved ${Math.round(waterSaved / 150)} showers worth of water`)
  }
  if (wasteAvoided >= 5) {
    equivalents.push(`Kept ${wasteAvoided}kg of clothes out of landfills`)
  }

  return {
    carbonSaved,
    waterSaved,
    wasteAvoided,
    equivalents,
  }
}
