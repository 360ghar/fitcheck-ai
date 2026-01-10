/**
 * CalendarView Component
 *
 * Displays calendar events with outfit assignments and weather information.
 * Features:
 * - Monthly view (desktop default)
 * - Weekly view (mobile default) - 7 days stacked vertically
 * - Agenda view - list of upcoming events
 * - Event display with outfit assignments
 * - Weather overlay for each day
 * - Quick outfit assignment
 *
 * @see https://docs.fitcheck.ai/features/calendar-integration
 */

import { useState, useEffect, useCallback, useMemo, useRef } from 'react'
import {
  ChevronLeft,
  ChevronRight,
  Sun,
  Cloud,
  CloudRain,
  CloudSnow,
  Bolt,
  Calendar as CalendarIcon,
  CalendarDays,
  List,
  Grid3x3,
  Plus,
  Wand2,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Progress } from '@/components/ui/progress'
import { useToast } from '@/components/ui/use-toast'
import { cn } from '@/lib/utils'
import type { Outfit } from '@/types'

// ============================================================================
// TYPES
// ============================================================================

export interface CalendarEvent {
  id: string
  title: string
  description?: string
  start_time: string
  end_time: string
  location?: string
  outfit_id?: string
  outfit_name?: string
  outfit_image_url?: string
  event_type?: string
  is_all_day: boolean
}

export interface WeatherData {
  temperature: number
  temp_category: string
  weather_state: string
  description: string
  icon: string
}

export interface DayData {
  date: Date
  isCurrentMonth: boolean
  isToday: boolean
  events: CalendarEvent[]
  weather?: WeatherData
}

export type CalendarViewMode = 'month' | 'week' | 'agenda'

interface CalendarViewProps {
  events: CalendarEvent[]
  outfits: Outfit[]
  onDateClick?: (date: Date) => void
  onEventClick?: (event: CalendarEvent) => void
  onAssignOutfit?: (eventId: string, outfitId: string) => Promise<void>
  onGetWeather?: (date: Date) => Promise<WeatherData | null>
  onCreateEvent?: (date: Date) => void
  onMonthChange?: (month: Date) => void
  /** Initial view mode - defaults to 'week' on mobile, 'month' on desktop */
  initialViewMode?: CalendarViewMode
}

// ============================================================================
// CONSTANTS
// ============================================================================

const WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
const MONTHS = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
]

const EVENT_TYPE_COLORS: Record<string, string> = {
  work: 'bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-300 border-blue-200 dark:border-blue-800',
  social: 'bg-pink-100 dark:bg-pink-900/30 text-pink-800 dark:text-pink-300 border-pink-200 dark:border-pink-800',
  casual: 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300 border-green-200 dark:border-green-800',
  formal: 'bg-purple-100 dark:bg-purple-900/30 text-purple-800 dark:text-purple-300 border-purple-200 dark:border-purple-800',
  other: 'bg-muted text-muted-foreground border-border',
}

// ============================================================================
// COMPONENTS
// ============================================================================

function WeatherIcon({ weatherState, className }: { weatherState: string; className?: string }) {
  const iconProps = { className }

  switch (weatherState) {
    case 'sunny':
      return <Sun {...iconProps} />
    case 'cloudy':
      return <Cloud {...iconProps} />
    case 'rainy':
      return <CloudRain {...iconProps} />
    case 'snowy':
      return <CloudSnow {...iconProps} />
    case 'stormy':
      return <Bolt {...iconProps} />
    default:
      return <Cloud {...iconProps} />
  }
}

interface EventBadgeProps {
  event: CalendarEvent
  onClick: (event: CalendarEvent) => void
}

function EventBadge({ event, onClick }: EventBadgeProps) {
  const colorClass = EVENT_TYPE_COLORS[event.event_type || 'other']

  return (
    <button
      onClick={() => onClick(event)}
      className={`w-full text-left px-2 py-1 rounded text-xs border truncate flex items-center gap-1 hover:opacity-80 transition-opacity ${colorClass}`}
      title={event.title}
    >
      {event.outfit_image_url && (
        <img
          src={event.outfit_image_url}
          alt=""
          className="w-4 h-4 rounded-full object-cover"
        />
      )}
      <span className="truncate flex-1">{event.title}</span>
    </button>
  )
}

interface OutfitAssignDialogProps {
  isOpen: boolean
  onClose: () => void
  event: CalendarEvent | null
  outfits: Outfit[]
  onAssign: (outfitId: string) => Promise<void>
}

function OutfitAssignDialog({ isOpen, onClose, event, outfits, onAssign }: OutfitAssignDialogProps) {
  const [isAssigning, setIsAssigning] = useState(false)
  const { toast } = useToast()

  const handleAssign = async (outfitId: string) => {
    if (!event) return
    setIsAssigning(true)
    try {
      await onAssign(outfitId)
      toast({
        title: 'Outfit assigned',
        description: `"${event.title}" now has an outfit planned!`,
      })
      onClose()
    } catch (err) {
      toast({
        title: 'Failed to assign',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    } finally {
      setIsAssigning(false)
    }
  }

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>Assign Outfit</DialogTitle>
          <DialogDescription>
            {event && `Choose an outfit for "${event.title}" on ${new Date(event.start_time).toLocaleDateString()}`}
          </DialogDescription>
        </DialogHeader>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4 max-h-[60vh] overflow-y-auto">
          {outfits.map((outfit) => (
            <button
              key={outfit.id}
              onClick={() => handleAssign(outfit.id)}
              disabled={isAssigning}
              className="text-left touch-target"
            >
              <div className="aspect-square rounded-lg overflow-hidden bg-muted mb-2">
                {outfit.images?.length ? (
                  <img
                    src={(outfit.images.find((img) => img.is_primary) || outfit.images[0]).thumbnail_url || (outfit.images.find((img) => img.is_primary) || outfit.images[0]).image_url}
                    alt={outfit.name}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center">
                    <CalendarIcon className="h-8 w-8 text-muted-foreground" />
                  </div>
                )}
              </div>
              <p className="text-sm font-medium truncate text-foreground">{outfit.name}</p>
              {outfit.style && (
                <p className="text-xs text-muted-foreground capitalize">{outfit.style}</p>
              )}
            </button>
          ))}
        </div>

        {outfits.length === 0 && (
          <p className="text-center text-muted-foreground py-8">
            No outfits available. Create one first!
          </p>
        )}
      </DialogContent>
    </Dialog>
  )
}

// ============================================================================
// MAIN COMPONENT
// ============================================================================

export function CalendarView({
  events = [],
  outfits = [],
  onDateClick,
  onEventClick,
  onAssignOutfit,
  onGetWeather,
  onCreateEvent,
  onMonthChange,
  initialViewMode,
}: CalendarViewProps) {
  const [currentDate, setCurrentDate] = useState(new Date())
  const [assignDialogEvent, setAssignDialogEvent] = useState<CalendarEvent | null>(null)
  const [weatherCache, setWeatherCache] = useState<Map<string, WeatherData>>(new Map())
  const [isLoadingWeather, setIsLoadingWeather] = useState(false)
  const lastWeatherFetcherRef = useRef(onGetWeather)

  // Detect mobile and set default view mode
  const [_isMobile, setIsMobile] = useState(false)
  useEffect(() => {
    const checkMobile = () => setIsMobile(window.innerWidth < 768)
    checkMobile()
    window.addEventListener('resize', checkMobile)
    return () => window.removeEventListener('resize', checkMobile)
  }, [])

  const [viewMode, setViewMode] = useState<CalendarViewMode>(
    initialViewMode || (typeof window !== 'undefined' && window.innerWidth < 768 ? 'week' : 'month')
  )

  useEffect(() => {
    onMonthChange?.(currentDate)
  }, [currentDate, onMonthChange])

  // Get days for current week view
  const getWeekDays = useCallback((date: Date): DayData[] => {
    const today = new Date()
    const days: DayData[] = []

    // Get the start of the week (Sunday)
    const startOfWeek = new Date(date)
    startOfWeek.setDate(date.getDate() - date.getDay())

    for (let i = 0; i < 7; i++) {
      const currentDay = new Date(startOfWeek)
      currentDay.setDate(startOfWeek.getDate() + i)
      const dateStr = currentDay.toDateString()

      const dayEvents = events.filter((event) => {
        const eventDate = new Date(event.start_time)
        return eventDate.toDateString() === dateStr
      })

      days.push({
        date: currentDay,
        isCurrentMonth: currentDay.getMonth() === date.getMonth(),
        isToday:
          currentDay.getDate() === today.getDate() &&
          currentDay.getMonth() === today.getMonth() &&
          currentDay.getFullYear() === today.getFullYear(),
        events: dayEvents,
        weather: weatherCache.get(dateStr),
      })
    }

    return days
  }, [events, weatherCache])

  // Get upcoming events for agenda view
  const getAgendaEvents = useMemo(() => {
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    // Get events from today onwards, sorted by start time
    return events
      .filter((event) => {
        const eventDate = new Date(event.start_time)
        return eventDate >= today
      })
      .sort((a, b) => new Date(a.start_time).getTime() - new Date(b.start_time).getTime())
      .slice(0, 20) // Limit to 20 upcoming events
  }, [events])

  // Get days for current month view
  const getDaysInMonth = useCallback((date: Date): DayData[] => {
    const year = date.getFullYear()
    const month = date.getMonth()

    const firstDay = new Date(year, month, 1)
    const lastDay = new Date(year, month + 1, 0)

    const startDayOfWeek = firstDay.getDay()
    const daysInMonth = lastDay.getDate()

    const days: DayData[] = []
    const today = new Date()

    // Add days from previous month
    for (let i = startDayOfWeek - 1; i >= 0; i--) {
      const prevMonthDay = new Date(year, month, -i)
      days.push({
        date: prevMonthDay,
        isCurrentMonth: false,
        isToday: false,
        events: [],
      })
    }

    // Add days from current month
    for (let day = 1; day <= daysInMonth; day++) {
      const currentDay = new Date(year, month, day)
      const dateStr = currentDay.toDateString()

      // Get events for this day
      const dayEvents = events.filter((event) => {
        const eventDate = new Date(event.start_time)
        return eventDate.toDateString() === dateStr
      })

      days.push({
        date: currentDay,
        isCurrentMonth: true,
        isToday:
          currentDay.getDate() === today.getDate() &&
          currentDay.getMonth() === today.getMonth() &&
          currentDay.getFullYear() === today.getFullYear(),
        events: dayEvents,
        weather: weatherCache.get(dateStr),
      })
    }

    // Add days from next month to complete the grid
    const remainingDays = 42 - days.length
    for (let day = 1; day <= remainingDays; day++) {
      const nextMonthDay = new Date(year, month + 1, day)
      days.push({
        date: nextMonthDay,
        isCurrentMonth: false,
        isToday: false,
        events: [],
      })
    }

    return days
  }, [events, weatherCache])

  const days = getDaysInMonth(currentDate)

  // Fetch weather for the month
  useEffect(() => {
    const fetchWeatherForMonth = async () => {
      if (!onGetWeather) return

      const weatherFetcherChanged = lastWeatherFetcherRef.current !== onGetWeather
      if (weatherFetcherChanged) {
        lastWeatherFetcherRef.current = onGetWeather
      }

      const newCache = weatherFetcherChanged ? new Map<string, WeatherData>() : new Map(weatherCache)
      const year = currentDate.getFullYear()
      const month = currentDate.getMonth()
      const daysInMonth = new Date(year, month + 1, 0).getDate()
      const missingDates: string[] = []

      for (let day = 1; day <= daysInMonth; day++) {
        const dateStr = new Date(year, month, day).toDateString()
        if (!newCache.has(dateStr)) {
          missingDates.push(dateStr)
        }
      }

      if (missingDates.length === 0 && !weatherFetcherChanged) return

      setIsLoadingWeather(true)
      let didUpdate = false

      for (const dateStr of missingDates) {
        try {
          const date = new Date(dateStr)
          const weather = await onGetWeather(date)
          if (weather) {
            newCache.set(dateStr, weather)
            didUpdate = true
          }
        } catch (err) {
          console.error('Failed to fetch weather:', err)
        }
      }

      if (weatherFetcherChanged || didUpdate) {
        setWeatherCache(newCache)
      }
      setIsLoadingWeather(false)
    }

    fetchWeatherForMonth()
  }, [currentDate, onGetWeather, weatherCache])

  // Navigate to previous/next month or week
  const navigate = (direction: 'prev' | 'next') => {
    setCurrentDate((prev) => {
      const newDate = new Date(prev)
      if (viewMode === 'week') {
        // Navigate by week
        newDate.setDate(newDate.getDate() + (direction === 'next' ? 7 : -7))
      } else {
        // Navigate by month
        if (direction === 'prev') {
          newDate.setMonth(newDate.getMonth() - 1)
        } else {
          newDate.setMonth(newDate.getMonth() + 1)
        }
      }
      return newDate
    })
  }

  // Get week range string for display
  const getWeekRangeString = (date: Date): string => {
    const startOfWeek = new Date(date)
    startOfWeek.setDate(date.getDate() - date.getDay())
    const endOfWeek = new Date(startOfWeek)
    endOfWeek.setDate(startOfWeek.getDate() + 6)

    const startMonth = MONTHS[startOfWeek.getMonth()]
    const endMonth = MONTHS[endOfWeek.getMonth()]

    if (startOfWeek.getMonth() === endOfWeek.getMonth()) {
      return `${startMonth} ${startOfWeek.getDate()} - ${endOfWeek.getDate()}, ${startOfWeek.getFullYear()}`
    }
    return `${startMonth} ${startOfWeek.getDate()} - ${endMonth} ${endOfWeek.getDate()}, ${endOfWeek.getFullYear()}`
  }

  const weekDays = viewMode === 'week' ? getWeekDays(currentDate) : []

  const handleDayClick = (day: DayData) => {
    if (onDateClick) {
      onDateClick(day.date)
    }
  }

  const handleEventClick = (event: CalendarEvent) => {
    if (onEventClick) {
      onEventClick(event)
    }
  }

  const handleQuickAssign = (e: React.MouseEvent, event: CalendarEvent) => {
    e.stopPropagation()
    setAssignDialogEvent(event)
  }

  const handleAssignOutfit = async (outfitId: string) => {
    if (!assignDialogEvent || !onAssignOutfit) return
    await onAssignOutfit(assignDialogEvent.id, outfitId)
    setAssignDialogEvent(null)
  }

  const handleCreateEvent = (date: Date) => {
    if (onCreateEvent) {
      onCreateEvent(date)
    }
  }

  // Count events needing outfit
  const eventsNeedingOutfit = events.filter((e) => !e.outfit_id).length

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
      <div className="flex flex-wrap items-center gap-2 md:gap-4">
          <h2 className="text-lg md:text-2xl font-bold text-foreground">
            {viewMode === 'week'
              ? getWeekRangeString(currentDate)
              : viewMode === 'agenda'
              ? 'Upcoming Events'
              : `${MONTHS[currentDate.getMonth()]} ${currentDate.getFullYear()}`
            }
          </h2>
          {viewMode !== 'agenda' && (
            <div className="flex items-center gap-1">
              <Button variant="outline" size="icon" onClick={() => navigate('prev')}>
                <ChevronLeft className="h-4 w-4" />
              </Button>
              <Button variant="outline" size="icon" onClick={() => navigate('next')}>
                <ChevronRight className="h-4 w-4" />
              </Button>
            </div>
          )}
        </div>

        <div className="flex items-center gap-2 overflow-x-auto scrollbar-hide touch-pan-x overscroll-x-contain pb-1">
          {/* View mode toggle - visible on mobile */}
          <div className="flex items-center gap-1 md:hidden">
            <Button
              variant={viewMode === 'week' ? 'default' : 'outline'}
              size="sm"
              onClick={() => setViewMode('week')}
              className="gap-1"
            >
              <CalendarDays className="h-4 w-4" />
              <span className="hidden xs:inline">Week</span>
            </Button>
            <Button
              variant={viewMode === 'agenda' ? 'default' : 'outline'}
              size="sm"
              onClick={() => setViewMode('agenda')}
              className="gap-1"
            >
              <List className="h-4 w-4" />
              <span className="hidden xs:inline">Agenda</span>
            </Button>
            <Button
              variant={viewMode === 'month' ? 'default' : 'outline'}
              size="sm"
              onClick={() => setViewMode('month')}
              className="gap-1"
            >
              <Grid3x3 className="h-4 w-4" />
              <span className="hidden xs:inline">Month</span>
            </Button>
          </div>

          {/* Desktop view toggle */}
          <div className="hidden md:flex items-center gap-1">
            <Button
              variant={viewMode === 'month' ? 'default' : 'outline'}
              size="sm"
              onClick={() => setViewMode('month')}
            >
              Month
            </Button>
            <Button
              variant={viewMode === 'week' ? 'default' : 'outline'}
              size="sm"
              onClick={() => setViewMode('week')}
            >
              Week
            </Button>
            <Button
              variant={viewMode === 'agenda' ? 'default' : 'outline'}
              size="sm"
              onClick={() => setViewMode('agenda')}
            >
              Agenda
            </Button>
          </div>

          {eventsNeedingOutfit > 0 && (
            <Badge variant="outline" className="gap-1 shrink-0 hidden sm:flex">
              <Wand2 className="h-3 w-3" />
              {eventsNeedingOutfit} need outfit
            </Badge>
          )}

          <Button variant="outline" size="sm" onClick={() => setCurrentDate(new Date())} className="shrink-0">
            Today
          </Button>
        </div>
      </div>

      {/* Week View */}
      {viewMode === 'week' && (
        <Card>
          <CardContent className="p-2 md:p-4">
            <div className="space-y-2">
              {weekDays.map((day, index) => (
                <div
                  key={index}
                  onClick={() => handleDayClick(day)}
                  className={cn(
                    'flex items-start gap-3 p-3 rounded-lg border transition-all cursor-pointer touch-target',
                    day.isToday
                      ? 'bg-primary/5 border-primary'
                      : 'bg-card border-border hover:bg-accent'
                  )}
                >
                  {/* Day info */}
                  <div className={cn(
                    'flex flex-col items-center justify-center w-12 sm:w-14 shrink-0',
                    day.isToday ? 'text-primary' : 'text-muted-foreground'
                  )}>
                    <span className="text-xs font-medium uppercase">{WEEKDAYS[index]}</span>
                    <span className={cn(
                      'text-2xl font-bold',
                      day.isToday && 'text-primary'
                    )}>
                      {day.date.getDate()}
                    </span>
                  </div>

                  {/* Events and weather */}
                  <div className="flex-1 min-w-0">
                    {day.weather && (
                      <div className="flex items-center gap-1 text-xs text-muted-foreground mb-2">
                        <WeatherIcon weatherState={day.weather.weather_state} className="h-3 w-3" />
                        <span>{Math.round(day.weather.temperature)}° - {day.weather.description}</span>
                      </div>
                    )}

                    {day.events.length > 0 ? (
                      <div className="space-y-2">
                        {day.events.map((event) => (
                          <div key={event.id} className="flex items-center gap-2">
                            <EventBadge event={event} onClick={handleEventClick} />
                            {!event.outfit_id && onAssignOutfit && (
                              <button
                                onClick={(e) => handleQuickAssign(e, event)}
                                className="text-xs text-primary hover:text-primary/80 shrink-0"
                              >
                                + Outfit
                              </button>
                            )}
                          </div>
                        ))}
                      </div>
                    ) : (
                      <p className="text-sm text-muted-foreground">No events</p>
                    )}
                  </div>

                  {/* Add event button */}
                  {onCreateEvent && (
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={(e) => {
                        e.stopPropagation()
                        handleCreateEvent(day.date)
                      }}
                      className="shrink-0"
                    >
                      <Plus className="h-4 w-4" />
                    </Button>
                  )}
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Agenda View */}
      {viewMode === 'agenda' && (
        <Card>
          <CardContent className="p-2 md:p-4">
            {getAgendaEvents.length > 0 ? (
              <div className="space-y-2">
                {getAgendaEvents.map((event) => {
                  const eventDate = new Date(event.start_time)
                  const dateStr = eventDate.toDateString()
                  const weather = weatherCache.get(dateStr)

                  return (
                    <div
                      key={event.id}
                      onClick={() => handleEventClick(event)}
                      className="flex items-start gap-3 p-3 rounded-lg border border-border bg-card hover:bg-accent transition-colors cursor-pointer touch-target"
                    >
                      {/* Date column */}
                      <div className="flex flex-col items-center justify-center w-14 shrink-0 text-muted-foreground">
                        <span className="text-xs font-medium uppercase">
                          {WEEKDAYS[eventDate.getDay()]}
                        </span>
                        <span className="text-xl font-bold">{eventDate.getDate()}</span>
                        <span className="text-xs">{MONTHS[eventDate.getMonth()].slice(0, 3)}</span>
                      </div>

                      {/* Event details */}
                      <div className="flex-1 min-w-0">
                        <div className="flex items-start justify-between gap-2">
                          <div>
                            <h4 className="font-medium text-foreground truncate">{event.title}</h4>
                            <p className="text-sm text-muted-foreground">
                              {eventDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                              {event.location && ` • ${event.location}`}
                            </p>
                          </div>
                          {event.outfit_image_url && (
                            <img
                              src={event.outfit_image_url}
                              alt=""
                              className="w-10 h-10 rounded-lg object-cover shrink-0"
                            />
                          )}
                        </div>

                        {weather && (
                          <div className="flex items-center gap-1 text-xs text-muted-foreground mt-1">
                            <WeatherIcon weatherState={weather.weather_state} className="h-3 w-3" />
                            <span>{Math.round(weather.temperature)}°</span>
                          </div>
                        )}

                        {!event.outfit_id && onAssignOutfit && (
                          <button
                            onClick={(e) => handleQuickAssign(e, event)}
                            className="text-xs text-primary hover:text-primary/80 mt-1"
                          >
                            + Assign outfit
                          </button>
                        )}
                      </div>
                    </div>
                  )
                })}
              </div>
            ) : (
              <div className="text-center py-8">
                <CalendarIcon className="mx-auto h-12 w-12 text-muted-foreground" />
                <h3 className="mt-4 text-lg font-medium text-foreground">No upcoming events</h3>
                <p className="mt-2 text-sm text-muted-foreground">
                  Create an event to start planning your outfits
                </p>
                {onCreateEvent && (
                  <Button className="mt-4" onClick={() => onCreateEvent(new Date())}>
                    <Plus className="h-4 w-4 mr-2" />
                    Create Event
                  </Button>
                )}
              </div>
            )}
          </CardContent>
        </Card>
      )}

      {/* Month View */}
      {viewMode === 'month' && (
        <Card>
          <CardContent className="p-2 md:p-4 overflow-x-auto scrollbar-hide">
            <div className="min-w-[560px] md:min-w-0">
              {/* Weekday headers */}
              <div className="grid grid-cols-7 gap-1 md:gap-2 mb-2">
                {WEEKDAYS.map((day) => (
                  <div key={day} className="text-center text-xs md:text-sm font-medium text-muted-foreground">
                    <span className="hidden md:inline">{day}</span>
                    <span className="md:hidden">{day.charAt(0)}</span>
                  </div>
                ))}
              </div>

              {/* Days grid */}
              <div className="grid grid-cols-7 gap-1 md:gap-2">
                {days.map((day, index) => (
                  <div
                    key={index}
                    onClick={() => handleDayClick(day)}
                    className={cn(
                      'group min-h-[60px] md:min-h-24 p-1 md:p-2 rounded-lg border transition-all cursor-pointer',
                      day.isCurrentMonth
                        ? day.isToday
                          ? 'bg-primary/5 border-primary'
                          : 'bg-card border-border hover:bg-accent'
                        : 'bg-muted/50 border-transparent text-muted-foreground'
                    )}
                  >
                    <div className="flex items-center justify-between mb-1">
                      <span className={cn(
                        'text-xs md:text-sm font-medium',
                        day.isToday ? 'text-primary' : day.isCurrentMonth ? 'text-foreground' : 'text-muted-foreground'
                      )}>
                        {day.date.getDate()}
                      </span>

                      {/* Weather indicator */}
                      {day.weather && (
                        <div
                          className="hidden md:flex items-center gap-1 text-xs text-muted-foreground"
                          title={`${Math.round(day.weather.temperature)}°C - ${day.weather.description}`}
                        >
                          <WeatherIcon weatherState={day.weather.weather_state} className="h-3 w-3" />
                          <span>{Math.round(day.weather.temperature)}°</span>
                        </div>
                      )}
                    </div>

                    {/* Events */}
                    <div className="space-y-0.5 md:space-y-1">
                      {/* Mobile: show dots for events */}
                      <div className="flex gap-0.5 md:hidden">
                        {day.events.slice(0, 3).map((event) => (
                          <div
                            key={event.id}
                            className={cn(
                              'w-1.5 h-1.5 rounded-full',
                              event.outfit_id ? 'bg-primary' : 'bg-muted-foreground'
                            )}
                          />
                        ))}
                        {day.events.length > 3 && (
                          <span className="text-[10px] text-muted-foreground">+{day.events.length - 3}</span>
                        )}
                      </div>

                      {/* Desktop: show event badges */}
                      <div className="hidden md:block">
                        {day.events.slice(0, 2).map((event) => (
                          <div key={event.id}>
                            <EventBadge event={event} onClick={handleEventClick} />
                            {!event.outfit_id && onAssignOutfit && (
                              <button
                                onClick={(e) => handleQuickAssign(e, event)}
                                className="text-xs text-primary hover:text-primary/80 ml-1"
                              >
                                + Outfit
                              </button>
                            )}
                          </div>
                        ))}
                        {day.events.length > 2 && (
                          <div className="text-xs text-muted-foreground pl-2">
                            +{day.events.length - 2} more
                          </div>
                        )}
                      </div>
                    </div>

                    {/* Add event button - desktop only */}
                    {onCreateEvent && day.isCurrentMonth && (
                      <button
                        onClick={(e) => {
                          e.stopPropagation()
                          handleCreateEvent(day.date)
                        }}
                        className="hidden md:flex mt-1 w-full py-1 text-xs text-muted-foreground hover:text-primary items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
                      >
                        <Plus className="h-3 w-3" />
                      </button>
                    )}
                  </div>
                ))}
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Outfit assignment dialog */}
      <OutfitAssignDialog
        isOpen={assignDialogEvent !== null}
        onClose={() => setAssignDialogEvent(null)}
        event={assignDialogEvent}
        outfits={outfits}
        onAssign={handleAssignOutfit}
      />

      {/* Weather loading indicator */}
      {isLoadingWeather && onGetWeather && (
        <div className="flex items-center gap-2 text-sm text-muted-foreground">
          <Progress value={66} className="h-2 w-24" />
          <span>Loading weather...</span>
        </div>
      )}
    </div>
  )
}

export default CalendarView
