/**
 * Wear History Component
 *
 * Displays outfit wear history and repetition warnings.
 * Allows users to log new wear events and manage history.
 */

import { useState, useEffect, useMemo } from 'react'
import {
  Calendar,
  Clock,
  Users,
  MapPin,
  AlertTriangle,
  CheckCircle,
  Plus,
  Trash2,
  ChevronDown,
  ChevronUp,
  Info,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'
import type { Outfit } from '@/types'
import {
  type WearEvent,
  type EventType,
  type RepetitionCheck,
  type OutfitWearStats,
  getOutfitWearHistory,
  getOutfitWearStats,
  checkRepetition,
  logWearEvent,
  deleteWearEvent,
  EVENT_TYPES,
  getSafeWearDate,
} from '@/lib/wear-history'

// ============================================================================
// TYPES
// ============================================================================

interface WearHistoryProps {
  outfit: Outfit
  plannedDate?: string
  plannedAttendees?: string[]
  onWearLogged?: (event: WearEvent) => void
  variant?: 'full' | 'compact' | 'warning-only'
  className?: string
}

interface LogWearDialogProps {
  isOpen: boolean
  onClose: () => void
  outfitId: string
  onSubmit: (event: WearEvent) => void
}

// ============================================================================
// SUB-COMPONENTS
// ============================================================================

function LogWearDialog({ isOpen, onClose, outfitId, onSubmit }: LogWearDialogProps) {
  const [date, setDate] = useState(new Date().toISOString().split('T')[0])
  const [eventName, setEventName] = useState('')
  const [eventType, setEventType] = useState<EventType>('casual')
  const [location, setLocation] = useState('')
  const [attendeesInput, setAttendeesInput] = useState('')
  const [notes, setNotes] = useState('')
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = () => {
    try {
      setError(null)
      const attendees = attendeesInput
        .split(',')
        .map((a) => a.trim())
        .filter(Boolean)

      const event = logWearEvent(outfitId, {
        date,
        eventName: eventName || undefined,
        eventType,
        location: location || undefined,
        attendees,
        notes: notes || undefined,
      })

      onSubmit(event)
      onClose()
      // Reset form
      setDate(new Date().toISOString().split('T')[0])
      setEventName('')
      setEventType('casual')
      setLocation('')
      setAttendeesInput('')
      setNotes('')
    } catch (err) {
      console.error('Failed to log wear event:', err)
      setError(err instanceof Error ? err.message : 'Failed to log wear event. Please try again.')
    }
  }

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Log Outfit Wear</DialogTitle>
        </DialogHeader>

        <div className="space-y-4 py-4">
          {/* Date */}
          <div className="space-y-2">
            <Label htmlFor="wear-date">Date</Label>
            <Input
              id="wear-date"
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
            />
          </div>

          {/* Event Name */}
          <div className="space-y-2">
            <Label htmlFor="event-name">Event Name (optional)</Label>
            <Input
              id="event-name"
              placeholder="e.g., Team meeting, Date night"
              value={eventName}
              onChange={(e) => setEventName(e.target.value)}
            />
          </div>

          {/* Event Type */}
          <div className="space-y-2">
            <Label>Event Type</Label>
            <div className="flex flex-wrap gap-2">
              {EVENT_TYPES.map((type) => (
                <button
                  key={type.value}
                  onClick={() => setEventType(type.value)}
                  className={cn(
                    'px-3 py-1.5 rounded-full text-sm border transition-colors',
                    eventType === type.value
                      ? 'bg-primary text-primary-foreground border-primary'
                      : 'bg-background border-border hover:bg-muted'
                  )}
                >
                  {type.icon} {type.label}
                </button>
              ))}
            </div>
          </div>

          {/* Location */}
          <div className="space-y-2">
            <Label htmlFor="location">Location (optional)</Label>
            <Input
              id="location"
              placeholder="e.g., Office, Restaurant name"
              value={location}
              onChange={(e) => setLocation(e.target.value)}
            />
          </div>

          {/* Attendees */}
          <div className="space-y-2">
            <Label htmlFor="attendees">People Present (optional)</Label>
            <Input
              id="attendees"
              placeholder="Comma-separated: John, Sarah, Mom"
              value={attendeesInput}
              onChange={(e) => setAttendeesInput(e.target.value)}
            />
            <p className="text-xs text-muted-foreground">
              Track who saw you in this outfit to avoid repetition
            </p>
          </div>

          {/* Notes */}
          <div className="space-y-2">
            <Label htmlFor="notes">Notes (optional)</Label>
            <Input
              id="notes"
              placeholder="Any additional notes..."
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
            />
          </div>

          {/* Error message */}
          {error && (
            <div className="p-3 rounded-lg bg-red-50 dark:bg-red-950 border border-red-200 dark:border-red-800">
              <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
            </div>
          )}
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={handleSubmit}>Log Wear</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}

function RepetitionWarningCard({ check }: { check: RepetitionCheck }) {
  if (!check.hasWarning) {
    return (
      <div className="flex items-start gap-3 p-4 rounded-lg bg-green-50 dark:bg-green-950 border border-green-200 dark:border-green-800">
        <CheckCircle className="w-5 h-5 text-green-600 dark:text-green-400 mt-0.5" />
        <div>
          <p className="font-medium text-green-800 dark:text-green-200">
            No repetition concerns
          </p>
          <p className="text-sm text-green-600 dark:text-green-400">
            {check.recommendation}
          </p>
        </div>
      </div>
    )
  }

  const highWarnings = check.warnings.filter((w) => w.severity === 'high')
  const otherWarnings = check.warnings.filter((w) => w.severity !== 'high')

  return (
    <div className="space-y-2">
      {highWarnings.map((warning, i) => (
        <div
          key={i}
          className="flex items-start gap-3 p-4 rounded-lg bg-red-50 dark:bg-red-950 border border-red-200 dark:border-red-800"
        >
          <AlertTriangle className="w-5 h-5 text-red-600 dark:text-red-400 mt-0.5" />
          <div>
            <p className="font-medium text-red-800 dark:text-red-200">{warning.message}</p>
            {warning.eventName && (
              <p className="text-sm text-red-600 dark:text-red-400">
                at {warning.eventName}
              </p>
            )}
            {warning.overlappingAttendees && warning.overlappingAttendees.length > 0 && (
              <div className="flex flex-wrap gap-1 mt-2">
                {warning.overlappingAttendees.map((name) => (
                  <Badge key={name} variant="secondary" className="text-xs">
                    {name}
                  </Badge>
                ))}
              </div>
            )}
          </div>
        </div>
      ))}

      {otherWarnings.map((warning, i) => (
        <div
          key={i}
          className={cn(
            'flex items-start gap-3 p-4 rounded-lg border',
            warning.severity === 'medium'
              ? 'bg-yellow-50 dark:bg-yellow-950 border-yellow-200 dark:border-yellow-800'
              : 'bg-blue-50 dark:bg-blue-950 border-blue-200 dark:border-blue-800'
          )}
        >
          <Info
            className={cn(
              'w-5 h-5 mt-0.5',
              warning.severity === 'medium'
                ? 'text-yellow-600 dark:text-yellow-400'
                : 'text-blue-600 dark:text-blue-400'
            )}
          />
          <div>
            <p
              className={cn(
                'font-medium',
                warning.severity === 'medium'
                  ? 'text-yellow-800 dark:text-yellow-200'
                  : 'text-blue-800 dark:text-blue-200'
              )}
            >
              {warning.message}
            </p>
          </div>
        </div>
      ))}

      {check.recommendation && (
        <p className="text-sm text-muted-foreground px-1">{check.recommendation}</p>
      )}
    </div>
  )
}

function WearEventCard({
  event,
  onDelete,
}: {
  event: WearEvent
  onDelete?: () => void
}) {
  const eventTypeInfo = EVENT_TYPES.find((t) => t.value === event.eventType)
  const formattedDate = new Date(event.date).toLocaleDateString('en-US', {
    weekday: 'short',
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })

  return (
    <div className="flex items-start justify-between p-3 rounded-lg bg-muted/50 border">
      <div className="space-y-1">
        <div className="flex items-center gap-2">
          <span className="text-lg">{eventTypeInfo?.icon || '📌'}</span>
          <span className="font-medium">
            {event.eventName || eventTypeInfo?.label || 'Worn'}
          </span>
        </div>

        <div className="flex items-center gap-4 text-sm text-muted-foreground">
          <span className="flex items-center gap-1">
            <Calendar className="w-3.5 h-3.5" />
            {formattedDate}
          </span>

          {event.location && (
            <span className="flex items-center gap-1">
              <MapPin className="w-3.5 h-3.5" />
              {event.location}
            </span>
          )}
        </div>

        {event.attendees.length > 0 && (
          <div className="flex items-center gap-1 text-sm text-muted-foreground">
            <Users className="w-3.5 h-3.5" />
            <span>{event.attendees.join(', ')}</span>
          </div>
        )}

        {event.notes && (
          <p className="text-sm text-muted-foreground italic">{event.notes}</p>
        )}
      </div>

      {onDelete && (
        <Button
          variant="ghost"
          size="icon"
          className="h-8 w-8 text-muted-foreground hover:text-destructive"
          onClick={onDelete}
        >
          <Trash2 className="w-4 h-4" />
        </Button>
      )}
    </div>
  )
}

function StatsSection({ stats }: { stats: OutfitWearStats }) {
  if (stats.totalWears === 0) {
    return (
      <div className="text-center py-6 text-muted-foreground">
        <Clock className="w-8 h-8 mx-auto mb-2 opacity-50" />
        <p>No wear history yet</p>
        <p className="text-sm">Log when you wear this outfit to track repetition</p>
      </div>
    )
  }

  return (
    <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
      <div className="text-center p-3 rounded-lg bg-muted/50">
        <p className="text-2xl font-bold">{stats.totalWears}</p>
        <p className="text-xs text-muted-foreground">Times Worn</p>
      </div>

      <div className="text-center p-3 rounded-lg bg-muted/50">
        <p className="text-2xl font-bold">{stats.averageDaysBetweenWears || '-'}</p>
        <p className="text-xs text-muted-foreground">Avg Days Between</p>
      </div>

      <div className="text-center p-3 rounded-lg bg-muted/50">
        <p className="text-2xl font-bold">{stats.uniqueAttendeeGroups}</p>
        <p className="text-xs text-muted-foreground">Different Groups</p>
      </div>

      <div className="text-center p-3 rounded-lg bg-muted/50">
        <p className="text-lg font-bold">
          {stats.lastWornDate
            ? new Date(stats.lastWornDate).toLocaleDateString('en-US', {
                month: 'short',
                day: 'numeric',
              })
            : '-'}
        </p>
        <p className="text-xs text-muted-foreground">Last Worn</p>
      </div>
    </div>
  )
}

// ============================================================================
// MAIN COMPONENT
// ============================================================================

export function WearHistory({
  outfit,
  plannedDate,
  plannedAttendees = [],
  onWearLogged,
  variant = 'full',
  className,
}: WearHistoryProps) {
  const [showLogDialog, setShowLogDialog] = useState(false)
  const [showHistory, setShowHistory] = useState(false)
  const [history, setHistory] = useState<WearEvent[]>([])
  const [stats, setStats] = useState<OutfitWearStats | null>(null)

  // Load history
  useEffect(() => {
    setHistory(getOutfitWearHistory(outfit.id))
    setStats(getOutfitWearStats(outfit.id))
  }, [outfit.id])

  // Check for repetition if planning
  const repetitionCheck = useMemo(() => {
    if (!plannedDate) return null
    return checkRepetition(outfit.id, plannedDate, plannedAttendees)
  }, [outfit.id, plannedDate, plannedAttendees])

  // Safe wear date suggestion
  const safeDate = useMemo(() => {
    return getSafeWearDate(outfit.id, plannedAttendees)
  }, [outfit.id, plannedAttendees])

  const handleWearLogged = (event: WearEvent) => {
    setHistory(getOutfitWearHistory(outfit.id))
    setStats(getOutfitWearStats(outfit.id))
    onWearLogged?.(event)
  }

  const handleDeleteEvent = (eventId: string) => {
    deleteWearEvent(eventId)
    setHistory(getOutfitWearHistory(outfit.id))
    setStats(getOutfitWearStats(outfit.id))
  }

  // Warning-only variant
  if (variant === 'warning-only' && repetitionCheck) {
    return (
      <div className={className}>
        <RepetitionWarningCard check={repetitionCheck} />
      </div>
    )
  }

  // Compact variant
  if (variant === 'compact') {
    return (
      <div className={cn('space-y-3', className)}>
        {/* Quick stats */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2 text-sm text-muted-foreground">
            <Clock className="w-4 h-4" />
            <span>
              Worn {stats?.totalWears || 0} time{stats?.totalWears !== 1 ? 's' : ''}
              {stats?.lastWornDate && (
                <span>
                  {' '}
                  · Last:{' '}
                  {new Date(stats.lastWornDate).toLocaleDateString('en-US', {
                    month: 'short',
                    day: 'numeric',
                  })}
                </span>
              )}
            </span>
          </div>
          <Button variant="outline" size="sm" onClick={() => setShowLogDialog(true)}>
            <Plus className="w-4 h-4 mr-1" />
            Log
          </Button>
        </div>

        {/* Warning if planning */}
        {repetitionCheck && repetitionCheck.hasWarning && (
          <RepetitionWarningCard check={repetitionCheck} />
        )}

        <LogWearDialog
          isOpen={showLogDialog}
          onClose={() => setShowLogDialog(false)}
          outfitId={outfit.id}
          onSubmit={handleWearLogged}
        />
      </div>
    )
  }

  // Full variant
  return (
    <div className={cn('space-y-4', className)}>
      {/* Header */}
      <div className="flex items-center justify-between">
        <h3 className="font-semibold">Wear History</h3>
        <Button onClick={() => setShowLogDialog(true)}>
          <Plus className="w-4 h-4 mr-2" />
          Log Outfit Wear
        </Button>
      </div>

      {/* Repetition check if planning */}
      {repetitionCheck && (
        <div className="space-y-2">
          <h4 className="text-sm font-medium flex items-center gap-2">
            <AlertTriangle className="w-4 h-4" />
            Repetition Check
            {plannedDate && (
              <Badge variant="outline" className="ml-2">
                For{' '}
                {new Date(plannedDate).toLocaleDateString('en-US', {
                  month: 'short',
                  day: 'numeric',
                })}
              </Badge>
            )}
          </h4>
          <RepetitionWarningCard check={repetitionCheck} />

          {!repetitionCheck.safeToWear && (
            <p className="text-sm text-muted-foreground">
              Safe to wear again after:{' '}
              <span className="font-medium">
                {new Date(safeDate).toLocaleDateString('en-US', {
                  weekday: 'short',
                  month: 'short',
                  day: 'numeric',
                })}
              </span>
            </p>
          )}
        </div>
      )}

      {/* Stats */}
      {stats && <StatsSection stats={stats} />}

      {/* History list */}
      {history.length > 0 && (
        <div className="space-y-2">
          <button
            onClick={() => setShowHistory(!showHistory)}
            className="flex items-center gap-2 text-sm font-medium hover:text-primary transition-colors"
          >
            {showHistory ? (
              <ChevronUp className="w-4 h-4" />
            ) : (
              <ChevronDown className="w-4 h-4" />
            )}
            {showHistory ? 'Hide' : 'Show'} wear history ({history.length} events)
          </button>

          {showHistory && (
            <div className="space-y-2 max-h-80 overflow-y-auto">
              {history.map((event) => (
                <WearEventCard
                  key={event.id}
                  event={event}
                  onDelete={() => handleDeleteEvent(event.id)}
                />
              ))}
            </div>
          )}
        </div>
      )}

      {/* Log dialog */}
      <LogWearDialog
        isOpen={showLogDialog}
        onClose={() => setShowLogDialog(false)}
        outfitId={outfit.id}
        onSubmit={handleWearLogged}
      />
    </div>
  )
}

export default WearHistory
