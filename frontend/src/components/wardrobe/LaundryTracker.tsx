/**
 * Laundry Tracker Component
 *
 * UI for tracking wash history, managing laundry batches,
 * and viewing laundry reminders for wardrobe items.
 */

import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'
import {
  type WashEvent,
  type WashType,
  type DryMethod,
  type LaundryReminder,
  type LaundryStats,
  type LaundryBatch,
  WASH_TYPE_OPTIONS,
  DRY_METHOD_OPTIONS,
  logWashEvent,
  getItemWashHistory,
  deleteWashEvent,
  calculateLaundryStats,
  getLaundryReminders,
  createLaundryBatch,
  completeLaundryBatch,
  getPendingLaundryBatches,
  deleteLaundryBatch,
  suggestLaundryGroups,
  getLaundrySummary,
} from '@/lib/laundry-tracker'
import type { Item } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

interface LaundryTrackerProps {
  items: Item[]
  variant?: 'full' | 'compact' | 'dashboard' | 'reminders'
  className?: string
  onItemClick?: (itemId: string) => void
}

interface ItemLaundryPanelProps {
  item: Item
  variant?: 'full' | 'compact' | 'inline'
  className?: string
  onWashLogged?: () => void
}

// ============================================================================
// HELPER COMPONENTS
// ============================================================================

function WashTypeSelect({
  value,
  onChange,
}: {
  value: WashType
  onChange: (value: WashType) => void
}) {
  return (
    <div className="grid grid-cols-2 gap-2">
      {WASH_TYPE_OPTIONS.map((option) => (
        <button
          key={option.value}
          type="button"
          onClick={() => onChange(option.value)}
          className={cn(
            'flex items-center gap-2 p-2 rounded-lg border text-left transition-all text-sm',
            value === option.value
              ? 'border-primary bg-primary/5 ring-1 ring-primary'
              : 'border-border hover:border-primary/50 hover:bg-muted/50'
          )}
        >
          <span>{option.icon}</span>
          <span className="truncate">{option.label}</span>
        </button>
      ))}
    </div>
  )
}

function DryMethodSelect({
  value,
  onChange,
}: {
  value?: DryMethod
  onChange: (value: DryMethod) => void
}) {
  return (
    <div className="flex flex-wrap gap-2">
      {DRY_METHOD_OPTIONS.map((option) => (
        <button
          key={option.value}
          type="button"
          onClick={() => onChange(option.value)}
          className={cn(
            'flex items-center gap-1 px-3 py-1.5 rounded-full border text-sm transition-all',
            value === option.value
              ? 'border-primary bg-primary/5'
              : 'border-border hover:border-primary/50'
          )}
        >
          <span>{option.icon}</span>
          <span>{option.label}</span>
        </button>
      ))}
    </div>
  )
}

function ReminderCard({
  reminder,
  onLogWash,
}: {
  reminder: LaundryReminder
  onLogWash: () => void
}) {
  const urgencyColors = {
    high: 'bg-red-500/10 border-red-500/20 text-red-700 dark:text-red-400',
    medium: 'bg-yellow-500/10 border-yellow-500/20 text-yellow-700 dark:text-yellow-400',
    low: 'bg-blue-500/10 border-blue-500/20 text-blue-700 dark:text-blue-400',
  }

  const urgencyIcons = {
    high: '⚠️',
    medium: '⏰',
    low: '💡',
  }

  return (
    <div className={cn('p-3 rounded-lg border', urgencyColors[reminder.urgency])}>
      <div className="flex items-start justify-between gap-2">
        <div className="flex items-start gap-2">
          <span className="text-lg">{urgencyIcons[reminder.urgency]}</span>
          <div>
            <div className="font-medium text-sm">{reminder.itemName}</div>
            <div className="text-xs opacity-80">{reminder.message}</div>
          </div>
        </div>
        <Button variant="outline" size="sm" onClick={onLogWash}>
          Wash
        </Button>
      </div>
    </div>
  )
}

function WashEventCard({
  event,
  onDelete,
}: {
  event: WashEvent
  onDelete: () => void
}) {
  const washOption = WASH_TYPE_OPTIONS.find((o) => o.value === event.washType)
  const dryOption = DRY_METHOD_OPTIONS.find((o) => o.value === event.driedHow)

  return (
    <div className="flex items-center justify-between p-3 bg-muted/30 rounded-lg">
      <div className="flex items-center gap-3">
        <span className="text-xl">{washOption?.icon || '🧺'}</span>
        <div>
          <div className="text-sm font-medium">{washOption?.label || event.washType}</div>
          <div className="text-xs text-muted-foreground">
            {new Date(event.date).toLocaleDateString()}
            {dryOption && ` • ${dryOption.label}`}
          </div>
          {event.notes && (
            <div className="text-xs text-muted-foreground mt-1">{event.notes}</div>
          )}
        </div>
      </div>
      <Button variant="ghost" size="sm" onClick={onDelete}>
        ×
      </Button>
    </div>
  )
}

function StatsDisplay({ stats }: { stats: LaundryStats }) {
  return (
    <div className="grid grid-cols-2 gap-3">
      <div className="p-3 bg-muted/30 rounded-lg text-center">
        <div className="text-2xl font-bold">{stats.totalWashes}</div>
        <div className="text-xs text-muted-foreground">Total Washes</div>
      </div>
      <div className="p-3 bg-muted/30 rounded-lg text-center">
        <div className="text-2xl font-bold">{stats.currentWearsSinceWash}</div>
        <div className="text-xs text-muted-foreground">Wears Since Wash</div>
      </div>
      <div className="p-3 bg-muted/30 rounded-lg text-center">
        <div className="text-2xl font-bold">{stats.averageWearsBetweenWash}</div>
        <div className="text-xs text-muted-foreground">Avg Wears/Wash</div>
      </div>
      <div className="p-3 bg-muted/30 rounded-lg text-center">
        <div className="text-sm font-medium">
          {stats.lastWashed
            ? new Date(stats.lastWashed).toLocaleDateString()
            : 'Never'}
        </div>
        <div className="text-xs text-muted-foreground">Last Washed</div>
      </div>
    </div>
  )
}

// ============================================================================
// LOG WASH DIALOG
// ============================================================================

function LogWashDialog({
  itemId,
  itemName,
  trigger,
  onLogged,
}: {
  itemId: string
  itemName: string
  trigger: React.ReactNode
  onLogged?: () => void
}) {
  const [open, setOpen] = useState(false)
  const [washType, setWashType] = useState<WashType>('machine-regular')
  const [driedHow, setDriedHow] = useState<DryMethod | undefined>()
  const [date, setDate] = useState(new Date().toISOString().split('T')[0])
  const [notes, setNotes] = useState('')
  const [stainRemoved, setStainRemoved] = useState(false)

  const handleSubmit = () => {
    logWashEvent(itemId, washType, {
      driedHow,
      date,
      notes: notes || undefined,
      stainRemoved,
    })
    setOpen(false)
    onLogged?.()

    // Reset form
    setWashType('machine-regular')
    setDriedHow(undefined)
    setDate(new Date().toISOString().split('T')[0])
    setNotes('')
    setStainRemoved(false)
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>{trigger}</DialogTrigger>
      <DialogContent className="max-w-md">
        <DialogHeader>
          <DialogTitle>Log Wash</DialogTitle>
          <DialogDescription>Record washing {itemName}</DialogDescription>
        </DialogHeader>

        <div className="space-y-4">
          <div className="space-y-2">
            <Label>Date</Label>
            <Input
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
            />
          </div>

          <div className="space-y-2">
            <Label>Wash Type</Label>
            <WashTypeSelect value={washType} onChange={setWashType} />
          </div>

          <div className="space-y-2">
            <Label>How did you dry it?</Label>
            <DryMethodSelect value={driedHow} onChange={setDriedHow} />
          </div>

          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={() => setStainRemoved(!stainRemoved)}
              className={cn(
                'w-10 h-5 rounded-full transition-colors relative',
                stainRemoved ? 'bg-green-500' : 'bg-muted'
              )}
            >
              <div
                className={cn(
                  'absolute top-0.5 w-4 h-4 rounded-full bg-white transition-transform',
                  stainRemoved ? 'translate-x-5' : 'translate-x-0.5'
                )}
              />
            </button>
            <Label className="text-sm">Removed a stain</Label>
          </div>

          <div className="space-y-2">
            <Label>Notes (optional)</Label>
            <Textarea
              placeholder="Any notes about this wash..."
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              rows={2}
            />
          </div>

          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setOpen(false)}>
              Cancel
            </Button>
            <Button onClick={handleSubmit}>Log Wash</Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}

// ============================================================================
// ITEM LAUNDRY PANEL
// ============================================================================

export function ItemLaundryPanel({
  item,
  variant = 'full',
  className,
  onWashLogged,
}: ItemLaundryPanelProps) {
  const [history, setHistory] = useState<WashEvent[]>([])
  const [stats, setStats] = useState<LaundryStats | null>(null)
  const [refreshKey, setRefreshKey] = useState(0)

  useEffect(() => {
    setHistory(getItemWashHistory(item.id))
    setStats(calculateLaundryStats(item.id, item.usage_times_worn, item.category))
  }, [item.id, item.usage_times_worn, item.category, refreshKey])

  const handleWashLogged = () => {
    setRefreshKey((k) => k + 1)
    onWashLogged?.()
  }

  const handleDeleteEvent = (eventId: string) => {
    deleteWashEvent(item.id, eventId)
    setRefreshKey((k) => k + 1)
  }

  if (variant === 'inline') {
    return (
      <div className={cn('flex items-center gap-2', className)}>
        <span className="text-sm text-muted-foreground">
          {stats?.totalWashes || 0} washes
        </span>
        <LogWashDialog
          itemId={item.id}
          itemName={item.name}
          trigger={
            <Button variant="outline" size="sm">
              🧺 Log Wash
            </Button>
          }
          onLogged={handleWashLogged}
        />
      </div>
    )
  }

  if (variant === 'compact') {
    return (
      <div className={cn('space-y-3', className)}>
        <div className="flex items-center justify-between">
          <div className="text-sm">
            <span className="font-medium">{stats?.totalWashes || 0}</span> washes
            {stats?.lastWashed && (
              <span className="text-muted-foreground">
                {' '}• Last: {new Date(stats.lastWashed).toLocaleDateString()}
              </span>
            )}
          </div>
          <LogWashDialog
            itemId={item.id}
            itemName={item.name}
            trigger={
              <Button variant="outline" size="sm">
                Log Wash
              </Button>
            }
            onLogged={handleWashLogged}
          />
        </div>
      </div>
    )
  }

  return (
    <div className={cn('space-y-4', className)}>
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold flex items-center gap-2">
          <span>🧺</span>
          Laundry History
        </h3>
        <LogWashDialog
          itemId={item.id}
          itemName={item.name}
          trigger={<Button>Log Wash</Button>}
          onLogged={handleWashLogged}
        />
      </div>

      {/* Stats */}
      {stats && <StatsDisplay stats={stats} />}

      {/* History */}
      <div className="space-y-2">
        <h4 className="text-sm font-medium">Wash History</h4>
        {history.length === 0 ? (
          <p className="text-sm text-muted-foreground">
            No wash history recorded yet.
          </p>
        ) : (
          <div className="space-y-2 max-h-60 overflow-y-auto">
            {history.slice(0, 10).map((event) => (
              <WashEventCard
                key={event.id}
                event={event}
                onDelete={() => handleDeleteEvent(event.id)}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

// ============================================================================
// MAIN LAUNDRY TRACKER
// ============================================================================

export function LaundryTracker({
  items,
  variant = 'full',
  className,
  onItemClick,
}: LaundryTrackerProps) {
  const [reminders, setReminders] = useState<LaundryReminder[]>([])
  const [batches, setBatches] = useState<LaundryBatch[]>([])
  const [suggestedGroups, setSuggestedGroups] = useState<ReturnType<typeof suggestLaundryGroups>>([])
  const [summary, setSummary] = useState(getLaundrySummary(items))
  const [refreshKey, setRefreshKey] = useState(0)

  useEffect(() => {
    setReminders(getLaundryReminders(items))
    setBatches(getPendingLaundryBatches())
    setSuggestedGroups(suggestLaundryGroups(items))
    setSummary(getLaundrySummary(items))
  }, [items, refreshKey])

  const handleRefresh = () => setRefreshKey((k) => k + 1)

  const handleCreateBatch = (group: (typeof suggestedGroups)[0]) => {
    createLaundryBatch(group.groupName, group.items.map((i) => i.id), group.washType)
    handleRefresh()
  }

  const handleCompleteBatch = (batchId: string) => {
    completeLaundryBatch(batchId)
    handleRefresh()
  }

  const handleDeleteBatch = (batchId: string) => {
    deleteLaundryBatch(batchId)
    handleRefresh()
  }

  // Dashboard variant
  if (variant === 'dashboard') {
    return (
      <div className={cn('p-4 bg-card rounded-lg border', className)}>
        <div className="flex items-center gap-2 mb-4">
          <span className="text-xl">🧺</span>
          <h3 className="font-semibold">Laundry Status</h3>
        </div>

        <div className="grid grid-cols-2 gap-3">
          <div className="text-center p-3 bg-red-500/10 rounded-lg">
            <div className="text-2xl font-bold text-red-600">{summary.needsWashing}</div>
            <div className="text-xs text-muted-foreground">Needs Washing</div>
          </div>
          <div className="text-center p-3 bg-yellow-500/10 rounded-lg">
            <div className="text-2xl font-bold text-yellow-600">{summary.upcomingSoon}</div>
            <div className="text-xs text-muted-foreground">Upcoming</div>
          </div>
          <div className="text-center p-3 bg-green-500/10 rounded-lg">
            <div className="text-2xl font-bold text-green-600">{summary.recentlyWashed}</div>
            <div className="text-xs text-muted-foreground">This Week</div>
          </div>
          <div className="text-center p-3 bg-blue-500/10 rounded-lg">
            <div className="text-2xl font-bold text-blue-600">{summary.totalWashesThisMonth}</div>
            <div className="text-xs text-muted-foreground">This Month</div>
          </div>
        </div>

        {reminders.length > 0 && (
          <div className="mt-4 pt-4 border-t">
            <div className="text-sm font-medium mb-2">Top Priority</div>
            <ReminderCard
              reminder={reminders[0]}
              onLogWash={() => {
                onItemClick?.(reminders[0].itemId)
              }}
            />
          </div>
        )}
      </div>
    )
  }

  // Reminders only variant
  if (variant === 'reminders') {
    return (
      <div className={cn('space-y-3', className)}>
        {reminders.length === 0 ? (
          <div className="text-center py-8 text-muted-foreground">
            <span className="text-3xl">✨</span>
            <p className="mt-2">All caught up! No laundry reminders.</p>
          </div>
        ) : (
          reminders.map((reminder) => (
            <ReminderCard
              key={reminder.itemId}
              reminder={reminder}
              onLogWash={() => onItemClick?.(reminder.itemId)}
            />
          ))
        )}
      </div>
    )
  }

  // Compact variant
  if (variant === 'compact') {
    return (
      <div className={cn('space-y-4', className)}>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="text-xl">🧺</span>
            <span className="font-medium">Laundry</span>
          </div>
          <div className="flex items-center gap-3 text-sm">
            {summary.needsWashing > 0 && (
              <Badge variant="destructive">{summary.needsWashing} need washing</Badge>
            )}
            {summary.upcomingSoon > 0 && (
              <Badge variant="secondary">{summary.upcomingSoon} soon</Badge>
            )}
          </div>
        </div>

        {reminders.slice(0, 3).map((reminder) => (
          <ReminderCard
            key={reminder.itemId}
            reminder={reminder}
            onLogWash={() => onItemClick?.(reminder.itemId)}
          />
        ))}
      </div>
    )
  }

  // Full variant
  return (
    <div className={cn('space-y-6', className)}>
      {/* Header */}
      <div className="flex items-center justify-between">
        <h2 className="text-xl font-bold flex items-center gap-2">
          <span>🧺</span>
          Laundry Tracker
        </h2>
        <Button variant="outline" onClick={handleRefresh}>
          Refresh
        </Button>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-4 gap-4">
        <div className="p-4 bg-card rounded-lg border text-center">
          <div className="text-3xl font-bold text-red-600">{summary.needsWashing}</div>
          <div className="text-sm text-muted-foreground">Needs Washing</div>
        </div>
        <div className="p-4 bg-card rounded-lg border text-center">
          <div className="text-3xl font-bold text-yellow-600">{summary.upcomingSoon}</div>
          <div className="text-sm text-muted-foreground">Upcoming</div>
        </div>
        <div className="p-4 bg-card rounded-lg border text-center">
          <div className="text-3xl font-bold text-green-600">{summary.recentlyWashed}</div>
          <div className="text-sm text-muted-foreground">Washed This Week</div>
        </div>
        <div className="p-4 bg-card rounded-lg border text-center">
          <div className="text-3xl font-bold text-blue-600">{summary.totalWashesThisMonth}</div>
          <div className="text-sm text-muted-foreground">This Month</div>
        </div>
      </div>

      {/* Reminders */}
      <div className="space-y-3">
        <h3 className="font-semibold">Laundry Reminders</h3>
        {reminders.length === 0 ? (
          <div className="text-center py-8 text-muted-foreground bg-muted/30 rounded-lg">
            <span className="text-3xl">✨</span>
            <p className="mt-2">All caught up! No items need washing.</p>
          </div>
        ) : (
          <div className="space-y-2">
            {reminders.map((reminder) => (
              <ReminderCard
                key={reminder.itemId}
                reminder={reminder}
                onLogWash={() => onItemClick?.(reminder.itemId)}
              />
            ))}
          </div>
        )}
      </div>

      {/* Suggested Batches */}
      {suggestedGroups.length > 0 && (
        <div className="space-y-3">
          <h3 className="font-semibold">Suggested Laundry Loads</h3>
          <div className="grid gap-3 sm:grid-cols-2">
            {suggestedGroups.map((group, i) => {
              const washOption = WASH_TYPE_OPTIONS.find((o) => o.value === group.washType)
              return (
                <div key={i} className="p-4 bg-card rounded-lg border">
                  <div className="flex items-center justify-between mb-2">
                    <div className="flex items-center gap-2">
                      <span className="text-xl">{washOption?.icon}</span>
                      <span className="font-medium">{group.groupName}</span>
                    </div>
                    <Badge variant="secondary">{group.items.length} items</Badge>
                  </div>
                  <p className="text-sm text-muted-foreground mb-3">{group.reason}</p>
                  <Button
                    variant="outline"
                    size="sm"
                    className="w-full"
                    onClick={() => handleCreateBatch(group)}
                  >
                    Create Batch
                  </Button>
                </div>
              )
            })}
          </div>
        </div>
      )}

      {/* Pending Batches */}
      {batches.length > 0 && (
        <div className="space-y-3">
          <h3 className="font-semibold">Pending Laundry Batches</h3>
          <div className="space-y-2">
            {batches.map((batch) => {
              const washOption = WASH_TYPE_OPTIONS.find((o) => o.value === batch.washType)
              return (
                <div
                  key={batch.id}
                  className="flex items-center justify-between p-4 bg-card rounded-lg border"
                >
                  <div className="flex items-center gap-3">
                    <span className="text-xl">{washOption?.icon || '🧺'}</span>
                    <div>
                      <div className="font-medium">{batch.name}</div>
                      <div className="text-sm text-muted-foreground">
                        {batch.items.length} items
                        {batch.scheduledDate && ` • Scheduled: ${new Date(batch.scheduledDate).toLocaleDateString()}`}
                      </div>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => handleDeleteBatch(batch.id)}
                    >
                      Cancel
                    </Button>
                    <Button size="sm" onClick={() => handleCompleteBatch(batch.id)}>
                      Complete
                    </Button>
                  </div>
                </div>
              )
            })}
          </div>
        </div>
      )}
    </div>
  )
}

export default LaundryTracker
