/**
 * Laundry Tracker Service
 *
 * Enhanced laundry tracking with wash history, wear tracking,
 * care reminders, and laundry scheduling features.
 */

import type { Item } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

export interface WashEvent {
  id: string
  itemId: string
  date: string
  washType: WashType
  driedHow?: DryMethod
  notes?: string
  stainRemoved?: boolean
  createdAt: string
}

export type WashType =
  | 'machine-regular'
  | 'machine-delicate'
  | 'machine-heavy'
  | 'hand-wash'
  | 'dry-clean'
  | 'spot-clean'
  | 'steam'
  | 'air-refresh'

export type DryMethod =
  | 'tumble-dry'
  | 'hang-dry'
  | 'lay-flat'
  | 'air-dry'
  | 'dry-clean'

export interface LaundryStats {
  totalWashes: number
  lastWashed?: string
  averageWearsBetweenWash: number
  longestWearStreak: number
  currentWearsSinceWash: number
  mostCommonWashType?: WashType
  estimatedNextWash?: string
}

export interface LaundryReminder {
  itemId: string
  itemName: string
  reason: LaundryReason
  urgency: 'low' | 'medium' | 'high'
  message: string
  suggestedWashType?: WashType
}

export type LaundryReason =
  | 'max-wears'
  | 'time-based'
  | 'condition-dirty'
  | 'seasonal'
  | 'before-storage'

export interface LaundryBatch {
  id: string
  name: string
  items: string[]
  washType: WashType
  scheduledDate?: string
  completedAt?: string
  createdAt: string
}

export interface ItemWashSettings {
  itemId: string
  maxWearsBetweenWash: number
  preferredWashType: WashType
  preferredDryMethod: DryMethod
  requiresSeparation: boolean
  separationReason?: string
  customInstructions?: string
}

// ============================================================================
// CONSTANTS
// ============================================================================

const WASH_HISTORY_KEY = 'fitcheck-wash-history'
const WASH_SETTINGS_KEY = 'fitcheck-wash-settings'
const LAUNDRY_BATCHES_KEY = 'fitcheck-laundry-batches'

export const WASH_TYPE_OPTIONS: { value: WashType; label: string; icon: string; description: string }[] = [
  { value: 'machine-regular', label: 'Machine Wash', icon: '🧺', description: 'Standard machine cycle' },
  { value: 'machine-delicate', label: 'Delicate Cycle', icon: '🌸', description: 'Gentle machine cycle' },
  { value: 'machine-heavy', label: 'Heavy Duty', icon: '💪', description: 'For tough stains' },
  { value: 'hand-wash', label: 'Hand Wash', icon: '🤲', description: 'Gentle hand washing' },
  { value: 'dry-clean', label: 'Dry Clean', icon: '🧹', description: 'Professional cleaning' },
  { value: 'spot-clean', label: 'Spot Clean', icon: '🎯', description: 'Clean specific areas' },
  { value: 'steam', label: 'Steam', icon: '💨', description: 'Steam refresh' },
  { value: 'air-refresh', label: 'Air Out', icon: '🌬️', description: 'Just air it out' },
]

export const DRY_METHOD_OPTIONS: { value: DryMethod; label: string; icon: string }[] = [
  { value: 'tumble-dry', label: 'Tumble Dry', icon: '🌀' },
  { value: 'hang-dry', label: 'Hang Dry', icon: '👕' },
  { value: 'lay-flat', label: 'Lay Flat', icon: '📋' },
  { value: 'air-dry', label: 'Air Dry', icon: '🌬️' },
  { value: 'dry-clean', label: 'Dry Clean', icon: '🧹' },
]

// Default max wears before washing by category
export const DEFAULT_MAX_WEARS: Record<string, number> = {
  tops: 2,
  bottoms: 4,
  outerwear: 10,
  activewear: 1,
  swimwear: 1,
  shoes: 20,
  accessories: 15,
  other: 5,
}

// ============================================================================
// STORAGE
// ============================================================================

interface WashHistoryStore {
  [itemId: string]: WashEvent[]
}

interface WashSettingsStore {
  [itemId: string]: ItemWashSettings
}

function getWashHistory(): WashHistoryStore {
  try {
    const stored = localStorage.getItem(WASH_HISTORY_KEY)
    if (!stored) return {}
    return JSON.parse(stored) as WashHistoryStore
  } catch {
    return {}
  }
}

function saveWashHistory(history: WashHistoryStore): void {
  try {
    localStorage.setItem(WASH_HISTORY_KEY, JSON.stringify(history))
  } catch (error) {
    console.error('Failed to save wash history:', error)
  }
}

function getWashSettings(): WashSettingsStore {
  try {
    const stored = localStorage.getItem(WASH_SETTINGS_KEY)
    if (!stored) return {}
    return JSON.parse(stored) as WashSettingsStore
  } catch {
    return {}
  }
}

function saveWashSettings(settings: WashSettingsStore): void {
  try {
    localStorage.setItem(WASH_SETTINGS_KEY, JSON.stringify(settings))
  } catch (error) {
    console.error('Failed to save wash settings:', error)
  }
}

function getLaundryBatches(): LaundryBatch[] {
  try {
    const stored = localStorage.getItem(LAUNDRY_BATCHES_KEY)
    if (!stored) return []
    return JSON.parse(stored) as LaundryBatch[]
  } catch {
    return []
  }
}

function saveLaundryBatches(batches: LaundryBatch[]): void {
  try {
    localStorage.setItem(LAUNDRY_BATCHES_KEY, JSON.stringify(batches))
  } catch (error) {
    console.error('Failed to save laundry batches:', error)
  }
}

// ============================================================================
// WASH HISTORY MANAGEMENT
// ============================================================================

function generateId(): string {
  return `wash-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`
}

/**
 * Log a new wash event for an item.
 */
export function logWashEvent(
  itemId: string,
  washType: WashType,
  options: {
    driedHow?: DryMethod
    notes?: string
    stainRemoved?: boolean
    date?: string
  } = {}
): WashEvent {
  const event: WashEvent = {
    id: generateId(),
    itemId,
    date: options.date || new Date().toISOString().split('T')[0],
    washType,
    driedHow: options.driedHow,
    notes: options.notes,
    stainRemoved: options.stainRemoved,
    createdAt: new Date().toISOString(),
  }

  const history = getWashHistory()
  if (!history[itemId]) {
    history[itemId] = []
  }
  history[itemId].push(event)
  saveWashHistory(history)

  return event
}

/**
 * Get wash history for an item.
 */
export function getItemWashHistory(itemId: string): WashEvent[] {
  const history = getWashHistory()
  return (history[itemId] || []).sort(
    (a, b) => new Date(b.date).getTime() - new Date(a.date).getTime()
  )
}

/**
 * Delete a wash event.
 */
export function deleteWashEvent(itemId: string, eventId: string): boolean {
  const history = getWashHistory()
  if (!history[itemId]) return false

  const initialLength = history[itemId].length
  history[itemId] = history[itemId].filter((e) => e.id !== eventId)

  if (history[itemId].length === initialLength) return false

  saveWashHistory(history)
  return true
}

/**
 * Clear all wash history for an item.
 */
export function clearItemWashHistory(itemId: string): void {
  const history = getWashHistory()
  delete history[itemId]
  saveWashHistory(history)
}

// ============================================================================
// WASH SETTINGS
// ============================================================================

/**
 * Get wash settings for an item.
 */
export function getItemWashSettings(itemId: string, category?: string): ItemWashSettings {
  const settings = getWashSettings()
  if (settings[itemId]) {
    return settings[itemId]
  }

  // Return defaults based on category
  return {
    itemId,
    maxWearsBetweenWash: category ? (DEFAULT_MAX_WEARS[category] || 5) : 5,
    preferredWashType: 'machine-regular',
    preferredDryMethod: 'hang-dry',
    requiresSeparation: false,
  }
}

/**
 * Save wash settings for an item.
 */
export function saveItemWashSettings(settings: ItemWashSettings): void {
  const allSettings = getWashSettings()
  allSettings[settings.itemId] = settings
  saveWashSettings(allSettings)
}

// ============================================================================
// LAUNDRY STATS
// ============================================================================

/**
 * Calculate laundry statistics for an item.
 */
export function calculateLaundryStats(
  itemId: string,
  timesWorn: number,
  category?: string
): LaundryStats {
  const washEvents = getItemWashHistory(itemId)
  const settings = getItemWashSettings(itemId, category)

  const totalWashes = washEvents.length
  const lastWashed = washEvents[0]?.date

  // Calculate wears since last wash
  const lastWashDate = lastWashed ? new Date(lastWashed) : null
  const currentWearsSinceWash = lastWashDate
    ? Math.max(0, timesWorn - washEvents.length) // Simplified estimate
    : timesWorn

  // Calculate average wears between washes
  const averageWearsBetweenWash = totalWashes > 0
    ? Math.round(timesWorn / totalWashes)
    : timesWorn

  // Find most common wash type
  const washTypeCounts = new Map<WashType, number>()
  washEvents.forEach((e) => {
    washTypeCounts.set(e.washType, (washTypeCounts.get(e.washType) || 0) + 1)
  })
  let mostCommonWashType: WashType | undefined
  let maxCount = 0
  washTypeCounts.forEach((count, type) => {
    if (count > maxCount) {
      maxCount = count
      mostCommonWashType = type
    }
  })

  // Estimate next wash date
  let estimatedNextWash: string | undefined
  if (currentWearsSinceWash >= settings.maxWearsBetweenWash * 0.8) {
    // Should wash soon
    estimatedNextWash = new Date().toISOString().split('T')[0]
  } else if (averageWearsBetweenWash > 0) {
    const wearsRemaining = settings.maxWearsBetweenWash - currentWearsSinceWash
    // Assume ~3 wears per week average
    const daysUntilWash = Math.round((wearsRemaining / 3) * 7)
    const nextWashDate = new Date()
    nextWashDate.setDate(nextWashDate.getDate() + daysUntilWash)
    estimatedNextWash = nextWashDate.toISOString().split('T')[0]
  }

  return {
    totalWashes,
    lastWashed,
    averageWearsBetweenWash,
    longestWearStreak: settings.maxWearsBetweenWash, // Simplified
    currentWearsSinceWash,
    mostCommonWashType,
    estimatedNextWash,
  }
}

// ============================================================================
// LAUNDRY REMINDERS
// ============================================================================

/**
 * Get laundry reminders for items that need washing.
 */
export function getLaundryReminders(items: Item[]): LaundryReminder[] {
  const reminders: LaundryReminder[] = []

  items.forEach((item) => {
    const settings = getItemWashSettings(item.id, item.category)
    const stats = calculateLaundryStats(item.id, item.usage_times_worn, item.category)

    // Check condition status
    if (item.condition === 'dirty' || item.condition === 'laundry') {
      reminders.push({
        itemId: item.id,
        itemName: item.name,
        reason: 'condition-dirty',
        urgency: 'high',
        message: `${item.name} is marked as ${item.condition}`,
        suggestedWashType: settings.preferredWashType,
      })
      return // Don't add multiple reminders for same item
    }

    // Check wear count
    if (stats.currentWearsSinceWash >= settings.maxWearsBetweenWash) {
      reminders.push({
        itemId: item.id,
        itemName: item.name,
        reason: 'max-wears',
        urgency: 'high',
        message: `${item.name} has been worn ${stats.currentWearsSinceWash} times since last wash`,
        suggestedWashType: settings.preferredWashType,
      })
    } else if (stats.currentWearsSinceWash >= settings.maxWearsBetweenWash * 0.8) {
      reminders.push({
        itemId: item.id,
        itemName: item.name,
        reason: 'max-wears',
        urgency: 'medium',
        message: `${item.name} will need washing soon (${stats.currentWearsSinceWash}/${settings.maxWearsBetweenWash} wears)`,
        suggestedWashType: settings.preferredWashType,
      })
    }

    // Check time since last wash (if not worn but sitting dirty)
    if (stats.lastWashed) {
      const daysSinceWash = Math.floor(
        (Date.now() - new Date(stats.lastWashed).getTime()) / (1000 * 60 * 60 * 24)
      )
      if (daysSinceWash > 60 && stats.currentWearsSinceWash > 0) {
        reminders.push({
          itemId: item.id,
          itemName: item.name,
          reason: 'time-based',
          urgency: 'low',
          message: `${item.name} hasn't been washed in ${daysSinceWash} days`,
          suggestedWashType: settings.preferredWashType,
        })
      }
    }
  })

  // Sort by urgency
  return reminders.sort((a, b) => {
    const urgencyOrder = { high: 0, medium: 1, low: 2 }
    return urgencyOrder[a.urgency] - urgencyOrder[b.urgency]
  })
}

// ============================================================================
// LAUNDRY BATCHES
// ============================================================================

/**
 * Create a new laundry batch.
 */
export function createLaundryBatch(
  name: string,
  itemIds: string[],
  washType: WashType,
  scheduledDate?: string
): LaundryBatch {
  const batch: LaundryBatch = {
    id: `batch-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`,
    name,
    items: itemIds,
    washType,
    scheduledDate,
    createdAt: new Date().toISOString(),
  }

  const batches = getLaundryBatches()
  batches.push(batch)
  saveLaundryBatches(batches)

  return batch
}

/**
 * Complete a laundry batch (logs wash events for all items).
 */
export function completeLaundryBatch(batchId: string, driedHow?: DryMethod): boolean {
  const batches = getLaundryBatches()
  const batchIndex = batches.findIndex((b) => b.id === batchId)

  if (batchIndex === -1) return false

  const batch = batches[batchIndex]

  // Log wash events for all items
  batch.items.forEach((itemId) => {
    logWashEvent(itemId, batch.washType, { driedHow })
  })

  // Mark batch as completed
  batches[batchIndex].completedAt = new Date().toISOString()
  saveLaundryBatches(batches)

  return true
}

/**
 * Get all laundry batches.
 */
export function getAllLaundryBatches(): LaundryBatch[] {
  return getLaundryBatches().sort(
    (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
  )
}

/**
 * Get pending laundry batches (not completed).
 */
export function getPendingLaundryBatches(): LaundryBatch[] {
  return getLaundryBatches()
    .filter((b) => !b.completedAt)
    .sort((a, b) => {
      if (a.scheduledDate && b.scheduledDate) {
        return new Date(a.scheduledDate).getTime() - new Date(b.scheduledDate).getTime()
      }
      return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
    })
}

/**
 * Delete a laundry batch.
 */
export function deleteLaundryBatch(batchId: string): boolean {
  const batches = getLaundryBatches()
  const filtered = batches.filter((b) => b.id !== batchId)

  if (filtered.length === batches.length) return false

  saveLaundryBatches(filtered)
  return true
}

// ============================================================================
// SMART GROUPING
// ============================================================================

/**
 * Suggest laundry groups based on wash requirements.
 */
export function suggestLaundryGroups(items: Item[]): {
  groupName: string
  washType: WashType
  items: Item[]
  reason: string
}[] {
  const groups: Map<string, { washType: WashType; items: Item[]; reason: string }> = new Map()

  items.forEach((item) => {
    // Skip items that don't need washing
    if (item.condition !== 'dirty' && item.condition !== 'laundry') return

    const settings = getItemWashSettings(item.id, item.category)

    // Group by wash type
    const key = settings.preferredWashType
    if (!groups.has(key)) {
      const washOption = WASH_TYPE_OPTIONS.find((o) => o.value === key)
      groups.set(key, {
        washType: key,
        items: [],
        reason: washOption?.description || 'Similar wash requirements',
      })
    }
    groups.get(key)!.items.push(item)
  })

  // Convert to array and filter out empty groups
  return Array.from(groups.entries())
    .filter(([_, group]) => group.items.length > 0)
    .map(([key, group]) => ({
      groupName: WASH_TYPE_OPTIONS.find((o) => o.value === key)?.label || key,
      ...group,
    }))
}

/**
 * Get laundry summary stats for dashboard.
 */
export function getLaundrySummary(items: Item[]): {
  needsWashing: number
  upcomingSoon: number
  recentlyWashed: number
  totalWashesThisMonth: number
} {
  const reminders = getLaundryReminders(items)
  const history = getWashHistory()

  const now = new Date()
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1)
  const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)

  let totalWashesThisMonth = 0
  let recentlyWashed = 0

  Object.values(history).forEach((events) => {
    events.forEach((event) => {
      const eventDate = new Date(event.date)
      if (eventDate >= monthStart) {
        totalWashesThisMonth++
      }
      if (eventDate >= weekAgo) {
        recentlyWashed++
      }
    })
  })

  return {
    needsWashing: reminders.filter((r) => r.urgency === 'high').length,
    upcomingSoon: reminders.filter((r) => r.urgency === 'medium').length,
    recentlyWashed,
    totalWashesThisMonth,
  }
}
