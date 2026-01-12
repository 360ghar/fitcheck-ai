/**
 * StreakDisplay Component
 *
 * Displays user streaks with visual indicators.
 * Features:
 * - Current streak count
 * - Longest streak record
 * - Daily activity tracking
 * - Streak expiration warning
 *
 * @see https://docs.fitcheck.ai/features/gamification/streaks
 */

import { useState } from 'react'
import {
  Flame,
  Calendar,
  TrendingUp,
  AlertCircle,
  Clock,
  Zap,
} from 'lucide-react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from '@/components/ui/tooltip'

// ============================================================================
// TYPES
// ============================================================================

export interface Streak {
  id: string
  streak_type: string
  name: string
  current_streak: number
  last_activity_at: Date
  streak_start_date: Date
  longest_streak: number
  longest_streak_end_date?: Date
  is_active_today: boolean
  days_until_lost: number
}

interface StreakDisplayProps {
  streaks: Streak[]
  onLogActivity?: (streakType: string) => Promise<void>
  compact?: boolean
}

// ============================================================================
// CONSTANTS
// ============================================================================

const STREAK_CONFIGS: Record<string, { icon: React.ElementType; color: string; description: string }> = {
  outfit_log: {
    icon: Flame,
    color: 'text-orange-500',
    description: 'Log an outfit daily to maintain your streak'
  },
  daily_plan: {
    icon: Calendar,
    color: 'text-blue-500',
    description: 'Plan your outfits in advance'
  },
  social_engagement: {
    icon: Zap,
    color: 'text-purple-500',
    description: 'Engage with the community daily'
  }
}

const STREAK_MILESTONES = [3, 7, 14, 30, 60, 100, 365]

// ============================================================================
// COMPONENTS
// ============================================================================

function StreakFlame({ days, isActive }: { days: number; isActive: boolean }) {
  const size = Math.min(40, 20 + days * 0.5)

  // Calculate color intensity based on streak length
  const getFlameColor = () => {
    if (!isActive) return 'text-gray-300'
    if (days >= 30) return 'text-orange-500'
    if (days >= 14) return 'text-orange-400'
    if (days >= 7) return 'text-yellow-500'
    return 'text-yellow-400'
  }

  return (
    <Flame className={`${getFlameColor()} fill-current`} style={{ width: size, height: size }} />
  )
}

function StreakMilestones({ currentStreak, longestStreak }: { currentStreak: number; longestStreak: number }) {
  return (
    <div className="flex gap-1 mt-3">
      {STREAK_MILESTONES.map((milestone) => {
        const isCurrentReached = currentStreak >= milestone
        const isLongestReached = longestStreak >= milestone

        return (
          <TooltipProvider key={milestone}>
            <Tooltip>
              <TooltipTrigger asChild>
                <div
                  className={`
                    h-6 rounded-full transition-all
                    ${isCurrentReached
                      ? 'bg-gradient-to-t from-orange-500 to-yellow-400 w-6'
                      : isLongestReached
                        ? 'bg-orange-200 dark:bg-orange-900 w-5'
                        : 'bg-gray-200 dark:bg-gray-700 w-4'
                    }
                  `}
                />
              </TooltipTrigger>
              <TooltipContent>
                <p>{milestone} day milestone</p>
                {isCurrentReached && <p className="text-green-500">Currently reached!</p>}
                {!isCurrentReached && isLongestReached && <p className="text-yellow-500">Previous best</p>}
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>
        )
      })}
    </div>
  )
}

function WeeklyStreakCalendar({ currentStreak }: { currentStreak: number }) {
  const today = new Date()
  const days = []

  // Show last 7 days
  for (let i = 6; i >= 0; i--) {
    const date = new Date(today)
    date.setDate(date.getDate() - i)
    days.push(date)
  }

  return (
    <div className="flex gap-1 justify-center">
      {days.map((date, i) => {
        const isActive = i >= 7 - currentStreak
        const isToday = i === 6

        return (
          <TooltipProvider key={date.toISOString()}>
            <Tooltip>
              <TooltipTrigger asChild>
                <div
                  className={`
                    h-8 w-8 rounded-lg flex items-center justify-center text-xs font-medium
                    ${isActive
                      ? 'bg-orange-100 dark:bg-orange-900/30 text-orange-600 dark:text-orange-400 border border-orange-300 dark:border-orange-700'
                      : 'bg-gray-100 dark:bg-gray-800 text-gray-400'}
                    ${isToday ? 'ring-2 ring-gold-500' : ''}
                  `}
                >
                  {date.toLocaleDateString('en', { weekday: 'short' }).charAt(0)}
                </div>
              </TooltipTrigger>
              <TooltipContent>
                <p>{date.toLocaleDateString()}</p>
                {isActive && <p className="text-green-500">Active</p>}
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>
        )
      })}
    </div>
  )
}

// ============================================================================
// MAIN COMPONENT
// ============================================================================

export function StreakDisplay({ streaks, onLogActivity, compact = false }: StreakDisplayProps) {
  const [isLogging, setIsLogging] = useState<string | null>(null)

  const handleLogActivity = async (streakType: string) => {
    if (!onLogActivity || isLogging) return

    setIsLogging(streakType)
    try {
      await onLogActivity(streakType)
    } finally {
      setIsLogging(null)
    }
  }

  if (streaks.length === 0) {
    return (
      <Card>
        <CardContent className="pt-6 text-center text-gray-500">
          <Flame className="h-12 w-12 mx-auto mb-4 opacity-30" />
          <p>No active streaks</p>
          <p className="text-sm">Start logging activities to build your streaks!</p>
        </CardContent>
      </Card>
    )
  }

  if (compact) {
    // Compact view - show summary card
    const totalDays = streaks.reduce((sum, s) => sum + s.current_streak, 0)
    const maxStreak = Math.max(...streaks.map(s => s.longest_streak))
    const allActiveToday = streaks.every(s => s.is_active_today)

    return (
      <Card>
        <CardContent className="pt-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className={`
                h-12 w-12 rounded-full flex items-center justify-center
                ${allActiveToday ? 'bg-orange-100 dark:bg-orange-900/30' : 'bg-gray-100 dark:bg-gray-800'}
              `}>
                <Flame className={`h-6 w-6 ${allActiveToday ? 'text-orange-500 fill-orange-500' : 'text-gray-400'}`} />
              </div>
              <div>
                <p className="text-2xl font-bold">{totalDays}</p>
                <p className="text-xs text-gray-500">Total streak days</p>
              </div>
            </div>

            <div className="text-right">
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Best: <span className="font-semibold">{maxStreak}</span> days
              </p>
              {!allActiveToday && (
                <Badge variant="outline" className="text-xs mt-1 text-yellow-600 border-yellow-600">
                  <AlertCircle className="h-3 w-3 mr-1" />
                  Activity needed
                </Badge>
              )}
            </div>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <div className="space-y-4">
      {streaks.map((streak) => {
        const config = STREAK_CONFIGS[streak.streak_type] || {
          icon: Flame,
          color: 'text-gray-500',
          description: 'Maintain your daily streak'
        }
        const Icon = config.icon

        // Calculate progress to next milestone
        const nextMilestone = STREAK_MILESTONES.find(m => m > streak.current_streak) || (streak.current_streak + 10)
        const prevMilestone = STREAK_MILESTONES.reverse().find(m => m <= streak.current_streak) || 0
        const progress = ((streak.current_streak - prevMilestone) / (nextMilestone - prevMilestone)) * 100

        return (
          <Card key={streak.id} className={streak.is_active_today ? 'border-orange-200 dark:border-orange-800' : ''}>
            <CardHeader className="pb-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className={`
                    h-12 w-12 rounded-full flex items-center justify-center
                    ${streak.is_active_today ? 'bg-orange-100 dark:bg-orange-900/30' : 'bg-gray-100 dark:bg-gray-800'}
                  `}>
                    <Icon className={`h-6 w-6 ${streak.is_active_today ? config.color : 'text-gray-400'}`} />
                  </div>
                  <div>
                    <CardTitle className="text-lg">{streak.name}</CardTitle>
                    <p className="text-xs text-gray-500 mt-0.5">{config.description}</p>
                  </div>
                </div>

                <div className="text-right">
                  <div className="flex items-center gap-2">
                    <StreakFlame days={streak.current_streak} isActive={streak.is_active_today} />
                    <span className="text-3xl font-bold">{streak.current_streak}</span>
                  </div>
                  <p className="text-xs text-gray-500">
                    {streak.is_active_today ? 'Active today!' : `${streak.days_until_lost} day${streak.days_until_lost !== 1 ? 's' : ''} until lost`}
                  </p>
                </div>
              </div>
            </CardHeader>

            <CardContent className="space-y-4">
              {/* Progress to next milestone */}
              <div>
                <div className="flex justify-between text-xs text-gray-500 mb-1">
                  <span>{streak.current_streak} days</span>
                  <span>Next milestone: {nextMilestone} days</span>
                </div>
                <Progress value={progress} className="h-2" />
              </div>

              {/* Weekly calendar */}
              <WeeklyStreakCalendar
                currentStreak={streak.current_streak}
              />

              {/* Milestones */}
              <StreakMilestones
                currentStreak={streak.current_streak}
                longestStreak={streak.longest_streak}
              />

              {/* Stats */}
              <div className="flex items-center justify-between pt-2 border-t">
                <div className="flex items-center gap-1 text-sm text-gray-500">
                  <TrendingUp className="h-4 w-4" />
                  <span>Best: {streak.longest_streak} days</span>
                </div>

                {onLogActivity && !streak.is_active_today && (
                  <Button
                    size="sm"
                    onClick={() => handleLogActivity(streak.streak_type)}
                    disabled={isLogging === streak.streak_type}
                  >
                    <Clock className="h-3 w-3 mr-1" />
                    Log Activity
                  </Button>
                )}
              </div>
            </CardContent>
          </Card>
        )
      })}
    </div>
  )
}

export default StreakDisplay
