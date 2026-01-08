/**
 * CalendarView Component
 *
 * Displays calendar events with outfit assignments and weather information.
 * Features:
 * - Monthly/weekly calendar view
 * - Event display with outfit assignments
 * - Weather overlay for each day
 * - Drag outfits to events
 * - Quick outfit assignment
 *
 * @see https://docs.fitcheck.ai/features/calendar-integration
 */

import { useState, useEffect, useCallback } from 'react'
import {
  ChevronLeft,
  ChevronRight,
  Sun,
  Cloud,
  CloudRain,
  CloudSnow,
  Bolt,
  Calendar as CalendarIcon,
  Plus,
  Wand2,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Progress } from '@/components/ui/progress'
import { useToast } from '@/components/ui/use-toast'
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

interface CalendarViewProps {
  events: CalendarEvent[]
  outfits: Outfit[]
  onDateClick?: (date: Date) => void
  onEventClick?: (event: CalendarEvent) => void
  onAssignOutfit?: (eventId: string, outfitId: string) => Promise<void>
  onGetWeather?: (date: Date) => Promise<WeatherData | null>
  onCreateEvent?: (date: Date) => void
  onMonthChange?: (month: Date) => void
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
  other: 'bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-300 border-gray-200 dark:border-gray-600',
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

        <div className="grid grid-cols-4 gap-4 max-h-96 overflow-y-auto">
          {outfits.map((outfit) => (
            <button
              key={outfit.id}
              onClick={() => handleAssign(outfit.id)}
              disabled={isAssigning}
              className="text-left"
            >
              <div className="aspect-square rounded-lg overflow-hidden bg-gray-100 dark:bg-gray-700 mb-2">
                {outfit.images?.length ? (
                  <img
                    src={(outfit.images.find((img) => img.is_primary) || outfit.images[0]).thumbnail_url || (outfit.images.find((img) => img.is_primary) || outfit.images[0]).image_url}
                    alt={outfit.name}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center">
                    <CalendarIcon className="h-8 w-8 text-gray-400" />
                  </div>
                )}
              </div>
              <p className="text-sm font-medium truncate text-gray-900 dark:text-white">{outfit.name}</p>
              {outfit.style && (
                <p className="text-xs text-gray-500 dark:text-gray-400 capitalize">{outfit.style}</p>
              )}
            </button>
          ))}
        </div>

        {outfits.length === 0 && (
          <p className="text-center text-gray-500 dark:text-gray-400 py-8">
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
}: CalendarViewProps) {
  const [currentDate, setCurrentDate] = useState(new Date())
  const [assignDialogEvent, setAssignDialogEvent] = useState<CalendarEvent | null>(null)
  const [weatherCache, setWeatherCache] = useState<Map<string, WeatherData>>(new Map())
  const [isLoadingWeather, setIsLoadingWeather] = useState(false)

  useEffect(() => {
    onMonthChange?.(currentDate)
  }, [currentDate, onMonthChange])

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

      setIsLoadingWeather(true)
      const newCache = new Map(weatherCache)

      // Fetch weather for each unique day in the current month
      const uniqueDates = new Set<string>()
      days.forEach((day) => {
        if (day.isCurrentMonth) {
          uniqueDates.add(day.date.toDateString())
        }
      })

      for (const dateStr of uniqueDates) {
        if (!newCache.has(dateStr)) {
          try {
            const date = new Date(dateStr)
            const weather = await onGetWeather(date)
            if (weather) {
              newCache.set(dateStr, weather)
            }
          } catch (err) {
            console.error('Failed to fetch weather:', err)
          }
        }
      }

      setWeatherCache(newCache)
      setIsLoadingWeather(false)
    }

    fetchWeatherForMonth()
  }, [currentDate, onGetWeather])

  // Navigate to previous/next month
  const navigateMonth = (direction: 'prev' | 'next') => {
    setCurrentDate((prev) => {
      const newDate = new Date(prev)
      if (direction === 'prev') {
        newDate.setMonth(newDate.getMonth() - 1)
      } else {
        newDate.setMonth(newDate.getMonth() + 1)
      }
      return newDate
    })
  }

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
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
            {MONTHS[currentDate.getMonth()]} {currentDate.getFullYear()}
          </h2>
          <div className="flex items-center gap-1">
            <Button variant="outline" size="icon" onClick={() => navigateMonth('prev')}>
              <ChevronLeft className="h-4 w-4" />
            </Button>
            <Button variant="outline" size="icon" onClick={() => navigateMonth('next')}>
              <ChevronRight className="h-4 w-4" />
            </Button>
          </div>
        </div>

        <div className="flex items-center gap-2">
          {eventsNeedingOutfit > 0 && (
            <Badge variant="outline" className="gap-1">
              <Wand2 className="h-3 w-3" />
              {eventsNeedingOutfit} event{eventsNeedingOutfit > 1 ? 's' : ''} need outfit
            </Badge>
          )}
          <Button variant="outline" onClick={() => setCurrentDate(new Date())}>
            Today
          </Button>
        </div>
      </div>

      {/* Calendar grid */}
      <Card>
        <CardContent className="p-4">
          {/* Weekday headers */}
          <div className="grid grid-cols-7 gap-2 mb-2">
            {WEEKDAYS.map((day) => (
              <div key={day} className="text-center text-sm font-medium text-gray-600 dark:text-gray-400">
                {day}
              </div>
            ))}
          </div>

          {/* Days grid */}
          <div className="grid grid-cols-7 gap-2">
            {days.map((day, index) => (
              <div
                key={index}
                onClick={() => handleDayClick(day)}
                className={`group min-h-24 p-2 rounded-lg border transition-all cursor-pointer ${
                  day.isCurrentMonth
                    ? day.isToday
                      ? 'bg-indigo-50 dark:bg-indigo-900/20 border-indigo-300 dark:border-indigo-700'
                      : 'bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700'
                    : 'bg-gray-50 dark:bg-gray-900 border-gray-100 dark:border-gray-800 text-gray-400 dark:text-gray-600'
                }`}
              >
                <div className="flex items-center justify-between mb-1">
                  <span className={`text-sm font-medium ${day.isToday ? 'text-indigo-600 dark:text-indigo-400' : 'text-gray-900 dark:text-white'}`}>
                    {day.date.getDate()}
                  </span>

                  {/* Weather indicator */}
                  {day.weather && (
                    <div
                      className="flex items-center gap-1 text-xs text-gray-500 dark:text-gray-400"
                      title={`${Math.round(day.weather.temperature)}°C - ${day.weather.description}`}
                    >
                      <WeatherIcon weatherState={day.weather.weather_state} className="h-3 w-3" />
                      <span>{Math.round(day.weather.temperature)}°</span>
                    </div>
                  )}
                </div>

                {/* Events */}
                <div className="space-y-1">
                  {day.events.slice(0, 3).map((event) => (
                    <div key={event.id}>
                      <EventBadge event={event} onClick={handleEventClick} />
                      {!event.outfit_id && onAssignOutfit && (
                        <button
                          onClick={(e) => handleQuickAssign(e, event)}
                          className="text-xs text-indigo-600 dark:text-indigo-400 hover:text-indigo-800 dark:hover:text-indigo-300 ml-1"
                        >
                          + Outfit
                        </button>
                      )}
                    </div>
                  ))}
                  {day.events.length > 3 && (
                    <div className="text-xs text-gray-500 dark:text-gray-400 pl-2">
                      +{day.events.length - 3} more
                    </div>
                  )}
                </div>

                {/* Add event button */}
                {onCreateEvent && day.isCurrentMonth && (
                  <button
                    onClick={(e) => {
                      e.stopPropagation()
                      handleCreateEvent(day.date)
                    }}
                    className="mt-1 w-full py-1 text-xs text-gray-400 dark:text-gray-500 hover:text-indigo-600 dark:hover:text-indigo-400 flex items-center justify-center opacity-0 group-hover:opacity-100"
                  >
                    <Plus className="h-3 w-3" />
                  </button>
                )}
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

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
        <div className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
          <Progress value={66} className="h-2 w-24" />
          <span>Loading weather...</span>
        </div>
      )}
    </div>
  )
}

export default CalendarView
