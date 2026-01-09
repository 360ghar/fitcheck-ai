/**
 * Wear History Tracking Service
 *
 * Tracks when outfits are worn, with whom, and where.
 * Provides repetition detection to help users avoid wearing
 * the same outfit with the same people too frequently.
 */

import type { Outfit } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

export interface WearEvent {
  id: string
  outfitId: string
  date: string // ISO date string
  eventName?: string
  eventType?: EventType
  location?: string
  attendees: string[] // Names or identifiers of people present
  notes?: string
  photoUrl?: string
  calendarEventId?: string
  createdAt: string
}

export type EventType =
  | 'work'
  | 'casual'
  | 'formal'
  | 'date'
  | 'party'
  | 'wedding'
  | 'interview'
  | 'meeting'
  | 'travel'
  | 'sports'
  | 'other'

export interface WearWarning {
  type: 'same-outfit' | 'similar-attendees' | 'recent-wear'
  severity: 'low' | 'medium' | 'high'
  message: string
  lastWornDate: string
  overlappingAttendees?: string[]
  eventName?: string
  daysSince: number
}

export interface OutfitWearStats {
  outfitId: string
  totalWears: number
  lastWornDate?: string
  averageDaysBetweenWears: number
  mostFrequentEventType?: EventType
  uniqueAttendeeGroups: number
  wearEvents: WearEvent[]
}

export interface RepetitionCheck {
  hasWarning: boolean
  warnings: WearWarning[]
  lastWearWithSameGroup?: WearEvent
  safeToWear: boolean
  recommendation?: string
}

// ============================================================================
// STORAGE
// ============================================================================

const STORAGE_KEY = 'fitcheck-wear-history'

/**
 * Get all wear events from storage.
 */
export function getWearHistory(): WearEvent[] {
  try {
    const stored = localStorage.getItem(STORAGE_KEY)
    if (!stored) return []
    return JSON.parse(stored) as WearEvent[]
  } catch {
    return []
  }
}

/**
 * Save wear events to storage.
 */
function saveWearHistory(events: WearEvent[]): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(events))
  } catch (error) {
    console.error('Failed to save wear history:', error)
  }
}

// ============================================================================
// WEAR EVENT MANAGEMENT
// ============================================================================

/**
 * Generate a unique ID for wear events.
 */
function generateId(): string {
  return `wear-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`
}

/**
 * Log a new wear event.
 */
export function logWearEvent(
  outfitId: string,
  details: {
    date?: string
    eventName?: string
    eventType?: EventType
    location?: string
    attendees?: string[]
    notes?: string
    photoUrl?: string
    calendarEventId?: string
  } = {}
): WearEvent {
  const event: WearEvent = {
    id: generateId(),
    outfitId,
    date: details.date || new Date().toISOString().split('T')[0],
    eventName: details.eventName,
    eventType: details.eventType,
    location: details.location,
    attendees: details.attendees || [],
    notes: details.notes,
    photoUrl: details.photoUrl,
    calendarEventId: details.calendarEventId,
    createdAt: new Date().toISOString(),
  }

  const history = getWearHistory()
  history.unshift(event)
  saveWearHistory(history)

  return event
}

/**
 * Update an existing wear event.
 */
export function updateWearEvent(
  eventId: string,
  updates: Partial<Omit<WearEvent, 'id' | 'createdAt'>>
): WearEvent | null {
  const history = getWearHistory()
  const index = history.findIndex((e) => e.id === eventId)

  if (index === -1) return null

  history[index] = { ...history[index], ...updates }
  saveWearHistory(history)

  return history[index]
}

/**
 * Delete a wear event.
 */
export function deleteWearEvent(eventId: string): boolean {
  const history = getWearHistory()
  const filtered = history.filter((e) => e.id !== eventId)

  if (filtered.length === history.length) return false

  saveWearHistory(filtered)
  return true
}

/**
 * Get wear events for a specific outfit.
 */
export function getOutfitWearHistory(outfitId: string): WearEvent[] {
  return getWearHistory().filter((e) => e.outfitId === outfitId)
}

/**
 * Get wear events for a date range.
 */
export function getWearEventsInRange(startDate: string, endDate: string): WearEvent[] {
  const history = getWearHistory()
  return history.filter((e) => e.date >= startDate && e.date <= endDate)
}

// ============================================================================
// REPETITION DETECTION
// ============================================================================

/**
 * Calculate days between two dates.
 */
function daysBetween(date1: string, date2: string): number {
  const d1 = new Date(date1)
  const d2 = new Date(date2)
  return Math.abs(Math.floor((d2.getTime() - d1.getTime()) / (1000 * 60 * 60 * 24)))
}

/**
 * Find overlapping attendees between two sets.
 */
function findOverlappingAttendees(a1: string[], a2: string[]): string[] {
  const set1 = new Set(a1.map((a) => a.toLowerCase().trim()))
  return a2.filter((a) => set1.has(a.toLowerCase().trim()))
}

/**
 * Check for outfit repetition warnings.
 */
export function checkRepetition(
  outfitId: string,
  plannedDate: string,
  plannedAttendees: string[] = [],
  options: {
    minDaysBetweenWears?: number
    attendeeOverlapThreshold?: number // 0-1, percentage of overlap to trigger warning
    considerRecentDays?: number
  } = {}
): RepetitionCheck {
  const {
    minDaysBetweenWears = 14,
    attendeeOverlapThreshold = 0.5,
    considerRecentDays = 90,
  } = options

  const warnings: WearWarning[] = []
  const history = getOutfitWearHistory(outfitId)

  if (history.length === 0) {
    return {
      hasWarning: false,
      warnings: [],
      safeToWear: true,
      recommendation: 'First time wearing this outfit - go for it!',
    }
  }

  // Sort by date descending
  const sortedHistory = [...history].sort(
    (a, b) => new Date(b.date).getTime() - new Date(a.date).getTime()
  )

  const cutoffDate = new Date()
  cutoffDate.setDate(cutoffDate.getDate() - considerRecentDays)
  const cutoffDateStr = cutoffDate.toISOString().split('T')[0]

  const recentWears = sortedHistory.filter((e) => e.date >= cutoffDateStr)
  const lastWear = sortedHistory[0]
  const daysSinceLast = daysBetween(lastWear.date, plannedDate)

  // Check 1: Too recent wear
  if (daysSinceLast < minDaysBetweenWears) {
    warnings.push({
      type: 'recent-wear',
      severity: daysSinceLast < 7 ? 'high' : 'medium',
      message: `You wore this outfit ${daysSinceLast} day${daysSinceLast === 1 ? '' : 's'} ago`,
      lastWornDate: lastWear.date,
      daysSince: daysSinceLast,
      eventName: lastWear.eventName,
    })
  }

  // Check 2: Same attendees
  if (plannedAttendees.length > 0) {
    for (const event of recentWears) {
      if (event.attendees.length === 0) continue

      const overlap = findOverlappingAttendees(plannedAttendees, event.attendees)
      const overlapRatio = overlap.length / Math.max(plannedAttendees.length, 1)

      if (overlapRatio >= attendeeOverlapThreshold && overlap.length > 0) {
        const days = daysBetween(event.date, plannedDate)
        warnings.push({
          type: 'similar-attendees',
          severity: overlapRatio >= 0.8 ? 'high' : days < 30 ? 'medium' : 'low',
          message: `${overlap.join(', ')} saw you in this outfit ${days} days ago`,
          lastWornDate: event.date,
          overlappingAttendees: overlap,
          daysSince: days,
          eventName: event.eventName,
        })
      }
    }
  }

  // Check 3: Same outfit + same event type recently
  const sameDateEvents = recentWears.filter(
    (e) => e.date === plannedDate
  )
  if (sameDateEvents.length > 0) {
    warnings.push({
      type: 'same-outfit',
      severity: 'high',
      message: 'You already logged wearing this outfit today',
      lastWornDate: sameDateEvents[0].date,
      daysSince: 0,
    })
  }

  // Find last wear with overlapping attendees
  let lastWearWithSameGroup: WearEvent | undefined
  if (plannedAttendees.length > 0) {
    for (const event of sortedHistory) {
      const overlap = findOverlappingAttendees(plannedAttendees, event.attendees)
      if (overlap.length > 0) {
        lastWearWithSameGroup = event
        break
      }
    }
  }

  // Generate recommendation
  let recommendation: string
  const highWarnings = warnings.filter((w) => w.severity === 'high')
  const mediumWarnings = warnings.filter((w) => w.severity === 'medium')

  if (highWarnings.length > 0) {
    recommendation = 'Consider choosing a different outfit to avoid repetition'
  } else if (mediumWarnings.length > 0) {
    recommendation = 'This outfit might be remembered - consider if that matters for this occasion'
  } else if (warnings.length > 0) {
    recommendation = 'Minor repetition detected, but probably fine'
  } else {
    recommendation = 'No repetition concerns - enjoy your outfit!'
  }

  return {
    hasWarning: warnings.length > 0,
    warnings,
    lastWearWithSameGroup,
    safeToWear: highWarnings.length === 0,
    recommendation,
  }
}

// ============================================================================
// STATISTICS
// ============================================================================

/**
 * Get wear statistics for an outfit.
 */
export function getOutfitWearStats(outfitId: string): OutfitWearStats {
  const events = getOutfitWearHistory(outfitId)

  if (events.length === 0) {
    return {
      outfitId,
      totalWears: 0,
      averageDaysBetweenWears: 0,
      uniqueAttendeeGroups: 0,
      wearEvents: [],
    }
  }

  // Sort by date
  const sortedEvents = [...events].sort(
    (a, b) => new Date(a.date).getTime() - new Date(b.date).getTime()
  )

  // Calculate average days between wears
  let totalDays = 0
  for (let i = 1; i < sortedEvents.length; i++) {
    totalDays += daysBetween(sortedEvents[i - 1].date, sortedEvents[i].date)
  }
  const avgDays = sortedEvents.length > 1 ? totalDays / (sortedEvents.length - 1) : 0

  // Find most frequent event type
  const eventTypeCounts: Record<string, number> = {}
  for (const event of events) {
    if (event.eventType) {
      eventTypeCounts[event.eventType] = (eventTypeCounts[event.eventType] || 0) + 1
    }
  }
  const mostFrequentEventType = Object.entries(eventTypeCounts).sort(
    (a, b) => b[1] - a[1]
  )[0]?.[0] as EventType | undefined

  // Count unique attendee groups
  const attendeeGroups = new Set<string>()
  for (const event of events) {
    if (event.attendees.length > 0) {
      const groupKey = [...event.attendees].sort().join('|').toLowerCase()
      attendeeGroups.add(groupKey)
    }
  }

  return {
    outfitId,
    totalWears: events.length,
    lastWornDate: sortedEvents[sortedEvents.length - 1].date,
    averageDaysBetweenWears: Math.round(avgDays),
    mostFrequentEventType,
    uniqueAttendeeGroups: attendeeGroups.size,
    wearEvents: events,
  }
}

/**
 * Get global wear statistics.
 */
export function getGlobalWearStats(): {
  totalWearEvents: number
  outfitsWorn: number
  averageWearsPerOutfit: number
  mostWornOutfitId?: string
  mostWornCount?: number
  topEventTypes: { type: EventType; count: number }[]
  frequentAttendees: { name: string; count: number }[]
} {
  const history = getWearHistory()

  if (history.length === 0) {
    return {
      totalWearEvents: 0,
      outfitsWorn: 0,
      averageWearsPerOutfit: 0,
      topEventTypes: [],
      frequentAttendees: [],
    }
  }

  // Count wears per outfit
  const wearCounts: Record<string, number> = {}
  for (const event of history) {
    wearCounts[event.outfitId] = (wearCounts[event.outfitId] || 0) + 1
  }

  const sortedOutfits = Object.entries(wearCounts).sort((a, b) => b[1] - a[1])

  // Count event types
  const eventTypeCounts: Record<string, number> = {}
  for (const event of history) {
    if (event.eventType) {
      eventTypeCounts[event.eventType] = (eventTypeCounts[event.eventType] || 0) + 1
    }
  }

  // Count attendees
  const attendeeCounts: Record<string, number> = {}
  for (const event of history) {
    for (const attendee of event.attendees) {
      const key = attendee.toLowerCase().trim()
      attendeeCounts[key] = (attendeeCounts[key] || 0) + 1
    }
  }

  return {
    totalWearEvents: history.length,
    outfitsWorn: Object.keys(wearCounts).length,
    averageWearsPerOutfit:
      Math.round((history.length / Object.keys(wearCounts).length) * 10) / 10,
    mostWornOutfitId: sortedOutfits[0]?.[0],
    mostWornCount: sortedOutfits[0]?.[1],
    topEventTypes: Object.entries(eventTypeCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([type, count]) => ({ type: type as EventType, count })),
    frequentAttendees: Object.entries(attendeeCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10)
      .map(([name, count]) => ({ name, count })),
  }
}

/**
 * Get upcoming calendar events and check for repetition.
 */
export function getRepetitionWarningsForOutfit(
  outfit: Outfit,
  plannedEvents: Array<{ date: string; attendees: string[]; eventName?: string }>
): Array<{ event: typeof plannedEvents[0]; check: RepetitionCheck }> {
  return plannedEvents.map((event) => ({
    event,
    check: checkRepetition(outfit.id, event.date, event.attendees),
  }))
}

/**
 * Get suggestions for when it's safe to wear an outfit again.
 */
export function getSafeWearDate(
  outfitId: string,
  attendees: string[] = [],
  minDays: number = 14
): string {
  const history = getOutfitWearHistory(outfitId)

  if (history.length === 0) {
    return new Date().toISOString().split('T')[0]
  }

  // Find the most recent wear with these attendees
  const sortedHistory = [...history].sort(
    (a, b) => new Date(b.date).getTime() - new Date(a.date).getTime()
  )

  let relevantDate = sortedHistory[0].date

  if (attendees.length > 0) {
    for (const event of sortedHistory) {
      const overlap = findOverlappingAttendees(attendees, event.attendees)
      if (overlap.length > 0) {
        if (event.date > relevantDate) {
          relevantDate = event.date
        }
        break
      }
    }
  }

  const safeDate = new Date(relevantDate)
  safeDate.setDate(safeDate.getDate() + minDays)

  return safeDate.toISOString().split('T')[0]
}

// ============================================================================
// EXPORT FOR CALENDAR INTEGRATION
// ============================================================================

export const EVENT_TYPES: { value: EventType; label: string; icon: string }[] = [
  { value: 'work', label: 'Work', icon: '💼' },
  { value: 'casual', label: 'Casual', icon: '😊' },
  { value: 'formal', label: 'Formal', icon: '👔' },
  { value: 'date', label: 'Date', icon: '❤️' },
  { value: 'party', label: 'Party', icon: '🎉' },
  { value: 'wedding', label: 'Wedding', icon: '💒' },
  { value: 'interview', label: 'Interview', icon: '📋' },
  { value: 'meeting', label: 'Meeting', icon: '🤝' },
  { value: 'travel', label: 'Travel', icon: '✈️' },
  { value: 'sports', label: 'Sports', icon: '⚽' },
  { value: 'other', label: 'Other', icon: '📌' },
]
