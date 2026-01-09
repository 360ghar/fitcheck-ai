/**
 * Calendar Page
 *
 * Outfit planning against events using `/api/v1/calendar/*`.
 */

import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { Calendar as CalendarIcon, Loader2, MapPin, Plus, Unlink } from 'lucide-react'

import { CalendarView, type CalendarEvent as CalendarViewEvent, type WeatherData } from '@/components/calendar'
import { LocationInput } from '@/components/settings/LocationInput'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { useToast } from '@/components/ui/use-toast'

import { connectCalendar, createCalendarEvent, getCalendarEvents, removeOutfitFromEvent, assignOutfitToEvent } from '@/api/calendar'
import { getWeatherRecommendations } from '@/api/recommendations'
import { getUserSettings, updateUserSettings } from '@/api/users'
import { useGeolocation } from '@/hooks/useGeolocation'
import { useOutfitStore } from '@/stores/outfitStore'

function formatDateOnly(date: Date): string {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

function toDateTimeLocalValue(date: Date): string {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  const hh = String(date.getHours()).padStart(2, '0')
  const mm = String(date.getMinutes()).padStart(2, '0')
  return `${y}-${m}-${d}T${hh}:${mm}`
}

export default function CalendarPage() {
  const { toast } = useToast()

  const outfits = useOutfitStore((s) => s.outfits)
  const fetchOutfits = useOutfitStore((s) => s.fetchOutfits)

  const [events, setEvents] = useState<CalendarViewEvent[]>([])
  const [isLoadingEvents, setIsLoadingEvents] = useState(false)
  const [activeMonthKey, setActiveMonthKey] = useState<string>('')

  const [isConnecting, setIsConnecting] = useState(false)

  // Location state for weather
  const [userLocation, setUserLocation] = useState<string | null>(null)
  const [showLocationDialog, setShowLocationDialog] = useState(false)
  const [editingLocation, setEditingLocation] = useState('')
  const locationInitialized = useRef(false)
  const { state: geoState, requestLocation } = useGeolocation()

  const [createOpen, setCreateOpen] = useState(false)
  const [createTitle, setCreateTitle] = useState('')
  const [createDescription, setCreateDescription] = useState('')
  const [createLocation, setCreateLocation] = useState('')
  const [createStart, setCreateStart] = useState('')
  const [createEnd, setCreateEnd] = useState('')

  const [selectedEvent, setSelectedEvent] = useState<CalendarViewEvent | null>(null)

  const decoratedEvents = useMemo(() => {
    const byId = new Map(outfits.map((o) => [o.id, o]))
    return events.map((e) => {
      const o = e.outfit_id ? byId.get(e.outfit_id) : null
      const primaryImg = o?.images?.length
        ? (o.images.find((img) => img.is_primary) || o.images[0]).thumbnail_url ||
          (o.images.find((img) => img.is_primary) || o.images[0]).image_url
        : undefined
      return {
        ...e,
        outfit_name: o?.name,
        outfit_image_url: primaryImg,
      }
    })
  }, [events, outfits])

  // Initialize location on mount: load from settings or auto-detect
  useEffect(() => {
    if (locationInitialized.current) return
    locationInitialized.current = true

    const initLocation = async () => {
      try {
        const settings = await getUserSettings()
        if (settings.default_location) {
          setUserLocation(settings.default_location)
          return
        }

        // No saved location - try auto-detect
        if (geoState.permissionState !== 'denied') {
          const coords = await requestLocation()
          if (coords) {
            const locationString = `${coords.lat},${coords.lon}`
            setUserLocation(locationString)
            // Save to user settings
            await updateUserSettings({ default_location: locationString })
          }
        }
      } catch {
        // Silently fail - weather will use backend default
      }
    }

    initLocation()
  }, [geoState.permissionState, requestLocation])

  const loadEventsForMonth = useCallback(
    async (month: Date) => {
      const monthKey = `${month.getFullYear()}-${month.getMonth()}`
      if (monthKey === activeMonthKey) return
      setActiveMonthKey(monthKey)

      setIsLoadingEvents(true)
      try {
        // Load outfits alongside events (best-effort)
        fetchOutfits(true).catch(() => null)

        const start = new Date(month.getFullYear(), month.getMonth(), 1)
        const end = new Date(month.getFullYear(), month.getMonth() + 1, 0)
        const data = await getCalendarEvents({
          start_date: formatDateOnly(start),
          end_date: formatDateOnly(end),
        })

        setEvents(
          data.map((e) => ({
            id: e.id,
            title: e.title,
            description: e.description || undefined,
            start_time: e.start_time,
            end_time: e.end_time,
            location: e.location || undefined,
            outfit_id: e.outfit_id || undefined,
            is_all_day: false,
          }))
        )
      } catch (err) {
        toast({
          title: 'Failed to load events',
          description: err instanceof Error ? err.message : 'An error occurred',
          variant: 'destructive',
        })
      } finally {
        setIsLoadingEvents(false)
      }
    },
    [activeMonthKey, fetchOutfits, toast]
  )

  const handleConnect = async () => {
    setIsConnecting(true)
    try {
      await connectCalendar('local')
      toast({ title: 'Calendar connected', description: 'Local planning calendar enabled.' })
    } catch (err) {
      toast({
        title: 'Failed to connect calendar',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    } finally {
      setIsConnecting(false)
    }
  }

  const openCreate = (date: Date) => {
    const start = new Date(date)
    start.setHours(9, 0, 0, 0)
    const end = new Date(date)
    end.setHours(10, 0, 0, 0)
    setCreateTitle('')
    setCreateDescription('')
    setCreateLocation('')
    setCreateStart(toDateTimeLocalValue(start))
    setCreateEnd(toDateTimeLocalValue(end))
    setCreateOpen(true)
  }

  const submitCreate = async () => {
    if (!createTitle.trim()) {
      toast({ title: 'Title is required', variant: 'destructive' })
      return
    }
    if (!createStart || !createEnd) {
      toast({ title: 'Start and end time are required', variant: 'destructive' })
      return
    }

    try {
      const created = await createCalendarEvent({
        title: createTitle.trim(),
        description: createDescription.trim() || undefined,
        location: createLocation.trim() || undefined,
        start_time: new Date(createStart).toISOString(),
        end_time: new Date(createEnd).toISOString(),
      })

      setEvents((prev) => [
        ...prev,
        {
          id: created.id,
          title: created.title,
          description: created.description || undefined,
          start_time: created.start_time,
          end_time: created.end_time,
          location: created.location || undefined,
          outfit_id: created.outfit_id || undefined,
          is_all_day: false,
        },
      ])
      setCreateOpen(false)
      toast({ title: 'Event created' })
    } catch (err) {
      toast({
        title: 'Failed to create event',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    }
  }

  const handleAssignOutfit = async (eventId: string, outfitId: string) => {
    const updated = await assignOutfitToEvent(eventId, outfitId)
    setEvents((prev) =>
      prev.map((e) => (e.id === updated.id ? { ...e, outfit_id: updated.outfit_id || undefined } : e))
    )
  }

  const handleRemoveOutfit = async (eventId: string) => {
    const updated = await removeOutfitFromEvent(eventId)
    setEvents((prev) =>
      prev.map((e) => (e.id === updated.id ? { ...e, outfit_id: updated.outfit_id || undefined } : e))
    )
  }

  const getWeatherForDay = async (_date: Date): Promise<WeatherData | null> => {
    try {
      const rec = await getWeatherRecommendations(userLocation || undefined)
      return {
        temperature: rec.temperature,
        temp_category: rec.temp_category,
        weather_state: rec.weather_state,
        description: (rec.notes || []).join(' ') || rec.weather_state,
        icon: rec.weather_state,
      }
    } catch {
      return null
    }
  }

  const handleAutoDetect = async () => {
    const coords = await requestLocation()
    if (coords) {
      const locationString = `${coords.lat},${coords.lon}`
      setEditingLocation(locationString)
    }
  }

  const handleSaveLocation = async () => {
    const location = editingLocation.trim()
    try {
      await updateUserSettings({ default_location: location || undefined })
      setUserLocation(location || null)
      setShowLocationDialog(false)
      toast({ title: 'Location updated', description: 'Weather will now use your new location.' })
    } catch (err) {
      toast({
        title: 'Failed to save location',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    }
  }

  return (
    <div className="max-w-7xl mx-auto px-4 md:px-6 lg:px-8 py-4 md:py-8 space-y-4 md:space-y-6">
      <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div>
          <h1 className="text-xl md:text-2xl font-bold text-foreground flex items-center gap-2">
            <CalendarIcon className="h-5 w-5 md:h-6 md:w-6 text-primary" />
            Calendar
          </h1>
          <p className="text-sm text-muted-foreground">Plan outfits against your schedule.</p>
          <div className="flex items-center gap-2 mt-1 text-sm text-muted-foreground">
            <MapPin className="h-4 w-4" />
            {userLocation ? (
              <button
                onClick={() => {
                  setEditingLocation(userLocation)
                  setShowLocationDialog(true)
                }}
                className="hover:text-primary transition-colors underline-offset-2 hover:underline touch-target"
              >
                {userLocation}
              </button>
            ) : (
              <button
                onClick={async () => {
                  const coords = await requestLocation()
                  if (coords) {
                    const locationString = `${coords.lat},${coords.lon}`
                    setUserLocation(locationString)
                    await updateUserSettings({ default_location: locationString })
                  } else {
                    setEditingLocation('')
                    setShowLocationDialog(true)
                  }
                }}
                disabled={geoState.isLoading}
                className="text-primary hover:text-primary/80 touch-target"
              >
                {geoState.isLoading ? 'Detecting...' : 'Set location for weather'}
              </button>
            )}
          </div>
        </div>
        <Button onClick={handleConnect} variant="outline" disabled={isConnecting} className="w-full md:w-auto">
          {isConnecting ? (
            <>
              <Loader2 className="h-4 w-4 mr-2 animate-spin" />
              Connecting…
            </>
          ) : (
            'Connect Calendar'
          )}
        </Button>
      </div>

      <Card>
        <CardHeader className="flex-row items-center justify-between space-y-0 px-4 py-3 md:px-6 md:py-4">
          <CardTitle className="text-base md:text-lg">Events</CardTitle>
          {isLoadingEvents && (
            <div className="text-sm text-muted-foreground flex items-center gap-2">
              <Loader2 className="h-4 w-4 animate-spin" />
              <span className="hidden md:inline">Loading…</span>
            </div>
          )}
        </CardHeader>
        <CardContent className="p-2 md:p-4">
          <CalendarView
            events={decoratedEvents}
            outfits={outfits}
            onEventClick={(event) => setSelectedEvent(event)}
            onAssignOutfit={handleAssignOutfit}
            onCreateEvent={(date) => openCreate(date)}
            onMonthChange={(month) => loadEventsForMonth(month)}
            onGetWeather={getWeatherForDay}
          />
        </CardContent>
      </Card>

      {/* Create event dialog */}
      <Dialog open={createOpen} onOpenChange={setCreateOpen}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>Create Event</DialogTitle>
            <DialogDescription>Add a planning event and assign an outfit later.</DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="event-title">Title</Label>
              <Input
                id="event-title"
                placeholder="e.g., Team meeting"
                value={createTitle}
                onChange={(e) => setCreateTitle(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="event-description">Description</Label>
              <Textarea
                id="event-description"
                placeholder="Optional"
                value={createDescription}
                onChange={(e) => setCreateDescription(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="event-location">Location</Label>
              <Input
                id="event-location"
                placeholder="Optional"
                value={createLocation}
                onChange={(e) => setCreateLocation(e.target.value)}
              />
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <div className="space-y-2">
                <Label htmlFor="event-start">Start</Label>
                <Input
                  id="event-start"
                  type="datetime-local"
                  value={createStart}
                  onChange={(e) => setCreateStart(e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="event-end">End</Label>
                <Input
                  id="event-end"
                  type="datetime-local"
                  value={createEnd}
                  onChange={(e) => setCreateEnd(e.target.value)}
                />
              </div>
            </div>
          </div>
          <DialogFooter className="flex-col md:flex-row gap-2">
            <Button variant="outline" onClick={() => setCreateOpen(false)} className="w-full md:w-auto">
              Cancel
            </Button>
            <Button onClick={submitCreate} className="w-full md:w-auto">
              <Plus className="h-4 w-4 mr-2" />
              Create
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Event details */}
      <Dialog
        open={!!selectedEvent}
        onOpenChange={(open) => {
          if (!open) setSelectedEvent(null)
        }}
      >
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>{selectedEvent?.title}</DialogTitle>
            <DialogDescription>
              {selectedEvent
                ? `${new Date(selectedEvent.start_time).toLocaleString()} → ${new Date(selectedEvent.end_time).toLocaleString()}`
                : ''}
            </DialogDescription>
          </DialogHeader>

          {selectedEvent?.description && (
            <div className="text-sm text-muted-foreground">{selectedEvent.description}</div>
          )}

          {selectedEvent?.outfit_id ? (
            <div className="p-3 rounded-lg bg-muted">
              <div className="text-sm font-medium text-foreground">Assigned outfit</div>
              <div className="text-sm text-muted-foreground mt-1">{selectedEvent.outfit_name || selectedEvent.outfit_id}</div>
            </div>
          ) : (
            <div className="text-sm text-muted-foreground">No outfit assigned yet. Use "+ Outfit" on the calendar.</div>
          )}

          <DialogFooter className="flex-col md:flex-row gap-2">
            <Button variant="outline" onClick={() => setSelectedEvent(null)} className="w-full md:w-auto">
              Close
            </Button>
            {selectedEvent?.outfit_id && (
              <Button
                variant="destructive"
                className="w-full md:w-auto"
                onClick={async () => {
                  if (!selectedEvent) return
                  try {
                    await handleRemoveOutfit(selectedEvent.id)
                    toast({ title: 'Outfit removed' })
                    setSelectedEvent({ ...selectedEvent, outfit_id: undefined })
                  } catch (err) {
                    toast({
                      title: 'Failed to remove outfit',
                      description: err instanceof Error ? err.message : 'An error occurred',
                      variant: 'destructive',
                    })
                  }
                }}
              >
                <Unlink className="h-4 w-4 mr-2" />
                Remove outfit
              </Button>
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Location edit dialog */}
      <Dialog open={showLocationDialog} onOpenChange={setShowLocationDialog}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Weather Location</DialogTitle>
            <DialogDescription>
              Enter a city name or use auto-detect for precise coordinates.
            </DialogDescription>
          </DialogHeader>
          <LocationInput
            value={editingLocation}
            onChange={setEditingLocation}
            onAutoDetect={handleAutoDetect}
            isAutoDetecting={geoState.isLoading}
            error={geoState.error}
            showAutoDetectButton={true}
          />
          <DialogFooter className="gap-2">
            <Button variant="outline" onClick={() => setShowLocationDialog(false)}>
              Cancel
            </Button>
            <Button onClick={handleSaveLocation}>
              Save Location
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
