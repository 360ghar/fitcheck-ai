/**
 * ChallengeCard Component
 *
 * Displays time-limited challenges users can participate in.
 * Features:
 * - Challenge details and rewards
 * - Join/leave functionality
 * - Progress tracking
 * - Time remaining countdown
 * - Leaderboard preview
 *
 * @see https://docs.fitcheck.ai/features/gamification/challenges
 */

import { useState, useEffect } from 'react'
import {
  Trophy,
  Users,
  Clock,
  Target,
  Star,
  Zap,
  Crown,
  Check,
} from 'lucide-react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import { ZoomableImage } from '@/components/ui/zoomable-image'

// ============================================================================
// TYPES
// ============================================================================

export interface Challenge {
  id: string
  title: string
  description: string
  subtitle?: string
  challenge_type: string
  difficulty: 'easy' | 'medium' | 'hard' | 'expert'
  criteria: Record<string, any>
  xp_reward: number
  reward_description?: string
  start_date: Date
  end_date: Date
  is_active: boolean
  participant_count: number
  cover_image_url?: string
  featured: boolean
  user_status?: 'pending' | 'in_progress' | 'completed' | 'expired'
  user_progress?: number
  is_joined: boolean
  time_remaining?: { days: number; hours: number }
}

interface ChallengeCardProps {
  challenge: Challenge
  onJoin?: (challengeId: string) => Promise<void>
  onUpdateProgress?: (challengeId: string, progress: number) => Promise<void>
  variant?: 'default' | 'compact' | 'featured'
}

// ============================================================================
// CONSTANTS
// ============================================================================

const DIFFICULTY_STYLES: Record<string, { bg: string; text: string; label: string }> = {
  easy: { bg: 'bg-green-100 dark:bg-green-900/30', text: 'text-green-700 dark:text-green-400', label: 'Easy' },
  medium: { bg: 'bg-blue-100 dark:bg-blue-900/30', text: 'text-blue-700 dark:text-blue-400', label: 'Medium' },
  hard: { bg: 'bg-purple-100 dark:bg-purple-900/30', text: 'text-purple-700 dark:text-purple-400', label: 'Hard' },
  expert: { bg: 'bg-orange-100 dark:bg-orange-900/30', text: 'text-orange-700 dark:text-orange-400', label: 'Expert' },
}

const STATUS_STYLES: Record<string, { color: string; icon: React.ElementType }> = {
  pending: { color: 'text-gray-500', icon: Clock },
  in_progress: { color: 'text-blue-500', icon: Zap },
  completed: { color: 'text-green-500', icon: Check },
  expired: { color: 'text-red-500', icon: Clock },
}

// ============================================================================
// COMPONENTS
// ============================================================================

function TimeRemaining({ endDate, timeRemaining }: { endDate: Date; timeRemaining?: { days: number; hours: number } }) {
  const [now, setNow] = useState(new Date())

  useEffect(() => {
    const interval = setInterval(() => setNow(new Date()), 1000 * 60) // Update every minute
    return () => clearInterval(interval)
  }, [])

  const remaining = timeRemaining || (() => {
    const diffMs = Math.max(0, endDate.getTime() - now.getTime())
    const days = Math.floor(diffMs / (1000 * 60 * 60 * 24))
    const hours = Math.floor((diffMs % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    return { days, hours }
  })()
  const isUrgent = remaining.days === 0 && remaining.hours < 24

  return (
    <div className={`flex items-center gap-1 text-sm ${isUrgent ? 'text-red-500' : 'text-gray-500'}`}>
      <Clock className="h-4 w-4" />
      <span>
        {remaining.days > 0 && `${remaining.days}d `}
        {remaining.hours}h left
      </span>
    </div>
  )
}

function ChallengeProgress({
  progress,
  target
}: {
  progress: number
  target: number
}) {
  const percentComplete = Math.min(100, (progress / target) * 100)
  const isComplete = progress >= target

  return (
    <div className="space-y-2">
      <div className="flex justify-between text-sm">
        <span className="text-gray-600 dark:text-gray-400">Progress</span>
        <span className={`font-medium ${isComplete ? 'text-green-600' : ''}`}>
          {progress} / {target}
        </span>
      </div>
      <Progress value={percentComplete} className="h-2" />
      {isComplete && (
        <Badge className="bg-green-100 text-green-700 border-green-200">
          <Check className="h-3 w-3 mr-1" />
          Completed!
        </Badge>
      )}
    </div>
  )
}

function FeaturedBanner() {
  return (
    <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500" />
  )
}

// ============================================================================
// MAIN COMPONENT
// ============================================================================

export function ChallengeCard({
  challenge,
  onJoin,
  onUpdateProgress,
  variant = 'default'
}: ChallengeCardProps) {
  const [isJoining, setIsJoining] = useState(false)
  const [isUpdating, setIsUpdating] = useState(false)

  const difficultyStyle = DIFFICULTY_STYLES[challenge.difficulty] || DIFFICULTY_STYLES.medium
  const statusStyle = challenge.user_status ? STATUS_STYLES[challenge.user_status] : null
  const StatusIcon = statusStyle ? statusStyle.icon : Clock

  const target = challenge.criteria?.target || challenge.criteria?.outfits_to_create || 1
  const progress = challenge.user_progress || 0
  const percentComplete = target > 0 ? Math.min(100, (progress / target) * 100) : 0

  const handleJoin = async () => {
    if (!onJoin || isJoining) return

    setIsJoining(true)
    try {
      await onJoin(challenge.id)
    } finally {
      setIsJoining(false)
    }
  }

  const handleQuickUpdate = async (increment: number) => {
    if (!onUpdateProgress || isUpdating) return

    setIsUpdating(true)
    try {
      await onUpdateProgress(challenge.id, progress + increment)
    } finally {
      setIsUpdating(false)
    }
  }

  // Compact variant
  if (variant === 'compact') {
    return (
      <Card className={`hover:shadow-md transition-shadow ${challenge.featured ? 'border-purple-200 dark:border-purple-800' : ''}`}>
        {challenge.featured && <FeaturedBanner />}
        <CardContent className="p-4">
          <div className="flex items-center gap-3">
            {/* Cover image or icon */}
            <div className="h-14 w-14 rounded-lg overflow-hidden bg-gray-100 dark:bg-gray-800 flex-shrink-0">
              {challenge.cover_image_url ? (
                <img src={challenge.cover_image_url} alt={challenge.title} className="h-full w-full object-cover" />
              ) : (
                <div className="h-full w-full flex items-center justify-center">
                  <Trophy className="h-6 w-6 text-gray-400" />
                </div>
              )}
            </div>

            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 mb-1">
                <h4 className="font-semibold truncate">{challenge.title}</h4>
                {challenge.featured && (
                  <Badge className="bg-purple-100 text-purple-700 border-purple-200">
                    <Crown className="h-3 w-3 mr-1" />
                    Featured
                  </Badge>
                )}
              </div>
              <div className="flex items-center gap-3 text-xs text-gray-500">
                <span className={`px-2 py-0.5 rounded-full ${difficultyStyle.bg} ${difficultyStyle.text}`}>
                  {difficultyStyle.label}
                </span>
                <div className="flex items-center gap-1">
                  <Star className="h-3 w-3 text-yellow-500" />
                  {challenge.xp_reward} XP
                </div>
                <div className="flex items-center gap-1">
                  <Users className="h-3 w-3" />
                  {challenge.participant_count}
                </div>
              </div>
            </div>

            <div className="flex flex-col items-end gap-2">
              <TimeRemaining endDate={new Date(challenge.end_date)} timeRemaining={challenge.time_remaining} />
              {!challenge.is_joined && onJoin ? (
                <Button size="sm" onClick={handleJoin} disabled={isJoining}>
                  {isJoining ? 'Joining...' : 'Join'}
                </Button>
              ) : statusStyle ? (
                <Badge variant="outline" className={statusStyle.color}>
                  <StatusIcon className="h-3 w-3 mr-1" />
                  {challenge.user_status}
                </Badge>
              ) : null}
            </div>
          </div>
        </CardContent>
      </Card>
    )
  }

  // Featured variant (larger, more prominent)
  if (variant === 'featured') {
    return (
      <Card className={`overflow-hidden ${challenge.featured ? 'border-purple-200 dark:border-purple-800' : ''}`}>
        {challenge.featured && <FeaturedBanner />}

        {/* Cover image */}
        {challenge.cover_image_url && (
          <div className="h-48 w-full overflow-hidden">
            <ZoomableImage
              src={challenge.cover_image_url}
              alt={challenge.title}
              className="w-full h-full object-cover"
            />
          </div>
        )}

        <CardHeader>
          <div className="flex items-start justify-between">
            <div className="space-y-1">
              <div className="flex items-center gap-2">
                <CardTitle className="text-xl">{challenge.title}</CardTitle>
                {challenge.featured && (
                  <Badge className="bg-purple-100 text-purple-700 border-purple-200">
                    <Crown className="h-3 w-3 mr-1" />
                    Featured
                  </Badge>
                )}
              </div>
              {challenge.subtitle && (
                <p className="text-sm text-gray-500">{challenge.subtitle}</p>
              )}
            </div>

            <div className="flex items-center gap-1 bg-yellow-100 dark:bg-yellow-900/30 px-3 py-1 rounded-full">
              <Star className="h-4 w-4 text-yellow-600 dark:text-yellow-400 fill-yellow-600" />
              <span className="font-semibold text-yellow-700 dark:text-yellow-400">{challenge.xp_reward} XP</span>
            </div>
          </div>
        </CardHeader>

        <CardContent className="space-y-4">
          <p className="text-gray-600 dark:text-gray-400">{challenge.description}</p>

          {/* Challenge details */}
          <div className="grid grid-cols-3 gap-4">
            <div className="text-center">
              <Users className="h-5 w-5 mx-auto mb-1 text-gray-400" />
              <p className="text-lg font-semibold">{challenge.participant_count}</p>
              <p className="text-xs text-gray-500">Participants</p>
            </div>
            <div className="text-center">
              <Target className="h-5 w-5 mx-auto mb-1 text-gray-400" />
              <p className="text-lg font-semibold">{target}</p>
              <p className="text-xs text-gray-500">Target</p>
            </div>
            <div className="text-center">
              <Clock className="h-5 w-5 mx-auto mb-1 text-gray-400" />
              <p className="text-lg font-semibold">
                {challenge.time_remaining?.days || 0}d
              </p>
              <p className="text-xs text-gray-500">Remaining</p>
            </div>
          </div>

          {/* Progress for joined users */}
          {challenge.is_joined && (
            <ChallengeProgress
              progress={progress}
              target={target}
            />
          )}

          {/* Action buttons */}
          <div className="flex items-center gap-2 pt-2">
            {!challenge.is_joined && onJoin ? (
              <Button onClick={handleJoin} disabled={isJoining} className="flex-1">
                {isJoining ? 'Joining...' : 'Join Challenge'}
              </Button>
            ) : (
              <>
                {challenge.user_status !== 'completed' && onUpdateProgress && (
                  <div className="flex gap-2 flex-1">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => handleQuickUpdate(1)}
                      disabled={isUpdating}
                    >
                      +1 Progress
                    </Button>
                    <Button
                      size="sm"
                      onClick={() => handleQuickUpdate(target - progress)}
                      disabled={isUpdating}
                    >
                      Complete
                    </Button>
                  </div>
                )}
                {challenge.user_status === 'completed' && (
                  <Badge className="bg-green-100 text-green-700 border-green-200 flex-1 justify-center py-2">
                    <Trophy className="h-4 w-4 mr-2" />
                    Challenge Completed!
                  </Badge>
                )}
              </>
            )}
          </div>
        </CardContent>
      </Card>
    )
  }

  // Default variant
  return (
    <Card className={`hover:shadow-md transition-shadow ${challenge.featured ? 'border-purple-200 dark:border-purple-800' : ''}`}>
      {challenge.featured && <FeaturedBanner />}

      <CardHeader className="pb-3">
        <div className="flex items-start justify-between">
          <div className="flex items-start gap-3">
            {/* Thumbnail */}
            <div className="h-16 w-16 rounded-lg overflow-hidden bg-gray-100 dark:bg-gray-800 flex-shrink-0">
              {challenge.cover_image_url ? (
                <img src={challenge.cover_image_url} alt={challenge.title} className="h-full w-full object-cover" />
              ) : (
                <div className="h-full w-full flex items-center justify-center">
                  <Trophy className="h-8 w-8 text-gray-400" />
                </div>
              )}
            </div>

            <div className="space-y-1">
              <div className="flex items-center gap-2">
                <CardTitle className="text-lg">{challenge.title}</CardTitle>
                {challenge.featured && (
                  <Crown className="h-4 w-4 text-purple-500" />
                )}
              </div>
              <p className="text-sm text-gray-500 line-clamp-2">{challenge.description}</p>
            </div>
          </div>

          <div className="flex flex-col items-end gap-2">
            <div className={`px-3 py-1 rounded-full text-sm font-medium ${difficultyStyle.bg} ${difficultyStyle.text}`}>
              {difficultyStyle.label}
            </div>
            <div className="flex items-center gap-1 text-sm">
              <Star className="h-4 w-4 text-yellow-500 fill-yellow-500" />
              {challenge.xp_reward} XP
            </div>
          </div>
        </div>
      </CardHeader>

      <CardContent className="space-y-3">
        {/* Info bar */}
        <div className="flex items-center justify-between text-sm">
          <div className="flex items-center gap-3 text-gray-500">
            <div className="flex items-center gap-1">
              <Users className="h-4 w-4" />
              <span>{challenge.participant_count}</span>
            </div>
            <TimeRemaining endDate={new Date(challenge.end_date)} timeRemaining={challenge.time_remaining} />
          </div>

          {statusStyle && challenge.user_status !== 'in_progress' && (
            <Badge variant="outline" className={statusStyle.color}>
              <StatusIcon className="h-3 w-3 mr-1" />
              {challenge.user_status}
            </Badge>
          )}
        </div>

        {/* Progress bar for joined challenges */}
        {challenge.is_joined && (
          <div className="space-y-2">
            <Progress value={percentComplete} className="h-2" />
            <div className="flex justify-between text-xs text-gray-500">
              <span>{progress} / {target} {target === 1 ? 'item' : 'items'}</span>
              <span>{Math.round(percentComplete)}%</span>
            </div>
          </div>
        )}

        {/* Action */}
        {!challenge.is_joined && onJoin ? (
          <Button onClick={handleJoin} disabled={isJoining} className="w-full">
            {isJoining ? 'Joining...' : 'Join Challenge'}
          </Button>
        ) : challenge.user_status === 'completed' ? (
          <div className="flex items-center justify-center gap-2 text-green-600 font-medium">
            <Trophy className="h-5 w-5" />
            <span>Completed!</span>
          </div>
        ) : onUpdateProgress ? (
          <Button
            variant="outline"
            size="sm"
            onClick={() => handleQuickUpdate(1)}
            disabled={isUpdating}
            className="w-full"
          >
            <Zap className="h-4 w-4 mr-2" />
            {isUpdating ? 'Updating...' : 'Add Progress'}
          </Button>
        ) : null}
      </CardContent>
    </Card>
  )
}

interface ChallengeListProps {
  challenges: Challenge[]
  onJoin?: (challengeId: string) => Promise<void>
  onUpdateProgress?: (challengeId: string, progress: number) => Promise<void>
  variant?: 'default' | 'compact' | 'featured'
  title?: string
}

export function ChallengeList({
  challenges,
  onJoin,
  onUpdateProgress,
  variant = 'default',
  title
}: ChallengeListProps) {
  if (challenges.length === 0) {
    return (
      <Card>
        <CardContent className="pt-6 text-center text-gray-500">
          <Trophy className="h-12 w-12 mx-auto mb-4 opacity-30" />
          <p>No active challenges</p>
          <p className="text-sm">Check back soon for new challenges!</p>
        </CardContent>
      </Card>
    )
  }

  return (
    <div className="space-y-4">
      {title && <h3 className="text-lg font-semibold">{title}</h3>}
      <div className="space-y-4">
        {challenges.map((challenge) => (
          <ChallengeCard
            key={challenge.id}
            challenge={challenge}
            onJoin={onJoin}
            onUpdateProgress={onUpdateProgress}
            variant={variant}
          />
        ))}
      </div>
    </div>
  )
}

export default ChallengeCard
