/**
 * AchievementCard Component
 *
 * Displays individual achievement badges with progress tracking.
 * Features:
 * - Locked/unlocked states
 * - Progress indicators
 * - XP rewards
 * - Achievement categories
 *
 * @see https://docs.fitcheck.ai/features/gamification/achievements
 */

import { useState } from 'react'
import {
  Trophy,
  Lock,
  Star,
  TrendingUp,
  Eye,
  Sparkles,
} from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
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

export interface Achievement {
  id: string
  slug: string
  name: string
  description: string
  achievement_type: string
  difficulty: 'easy' | 'medium' | 'hard' | 'expert'
  target_value?: number
  xp_reward: number
  badge_url?: string
  custom_icon?: string
  is_hidden: boolean
}

export interface UserAchievement {
  achievement: Achievement
  progress: number
  is_completed: boolean
  completed_at?: Date
  percent_complete: number
}

interface AchievementCardProps {
  achievement: UserAchievement | Achievement
  size?: 'sm' | 'md' | 'lg'
  showProgress?: boolean
  onClick?: () => void
}

// ============================================================================
// CONSTANTS
// ============================================================================

const DIFFICULTY_COLORS: Record<string, { bg: string; text: string; border: string }> = {
  easy: { bg: 'bg-green-100 dark:bg-green-900/30', text: 'text-green-700 dark:text-green-400', border: 'border-green-200 dark:border-green-800' },
  medium: { bg: 'bg-navy-100 dark:bg-navy-900/30', text: 'text-navy-700 dark:text-navy-400', border: 'border-navy-200 dark:border-navy-800' },
  hard: { bg: 'bg-gold-100 dark:bg-gold-900/30', text: 'text-gold-700 dark:text-gold-400', border: 'border-gold-200 dark:border-gold-800' },
  expert: { bg: 'bg-orange-100 dark:bg-orange-900/30', text: 'text-orange-700 dark:text-orange-400', border: 'border-orange-200 dark:border-orange-800' },
}

const TYPE_ICONS: Record<string, React.ElementType> = {
  wardrobe: TrendingUp,
  outfit: Sparkles,
  social: Star,
  streak: Trophy,
  calendar: Eye,
  community: Eye,
}

// ============================================================================
// COMPONENTS
// ============================================================================

export function AchievementCard({
  achievement,
  size = 'md',
  showProgress = true,
  onClick,
}: AchievementCardProps) {
  const [isRevealed, setIsRevealed] = useState(false)

  const isUserAchievement = 'is_completed' in achievement
  const data = isUserAchievement ? achievement.achievement : achievement
  const progress = isUserAchievement ? achievement.progress : 0
  const isCompleted = isUserAchievement ? achievement.is_completed : false
  const percentComplete = isUserAchievement ? achievement.percent_complete : 0
  const completedAt = isUserAchievement ? achievement.completed_at : undefined

  const colors = DIFFICULTY_COLORS[data.difficulty] || DIFFICULTY_COLORS.easy
  const TypeIcon = TYPE_ICONS[data.achievement_type] || Trophy

  const sizeClasses = {
    sm: 'p-3',
    md: 'p-4',
    lg: 'p-6'
  }

  const iconSizes = {
    sm: 'h-8 w-8',
    md: 'h-12 w-12',
    lg: 'h-16 w-16'
  }

  const isHidden = data.is_hidden && !isCompleted && !isRevealed

  const handleClick = () => {
    if (data.is_hidden && !isCompleted) {
      setIsRevealed(true)
    }
    onClick?.()
  }

  return (
    <TooltipProvider>
      <Card
        onClick={handleClick}
        className={`
          cursor-pointer transition-all hover:shadow-md
          ${colors.border} border-2
          ${isCompleted ? colors.bg : 'bg-card'}
          ${onClick ? 'hover:scale-[1.02]' : ''}
        `}
      >
        <CardContent className={`${sizeClasses[size]} space-y-3`}>
          <div className="flex items-start gap-3">
            {/* Icon/Badge */}
            <div className={`
              ${iconSizes[size]} rounded-full flex items-center justify-center
              ${isCompleted ? 'bg-gradient-to-br from-gold-400 to-gold-600' : 'bg-muted'}
              flex-shrink-0
            `}>
              {isHidden ? (
                <Lock className="h-1/2 w-1/2 text-gray-400" />
              ) : data.badge_url ? (
                <img src={data.badge_url} alt={data.name} className="w-full h-full object-cover rounded-full" />
              ) : (
                <TypeIcon className={`h-1/2 w-1/2 ${isCompleted ? 'text-white' : 'text-gray-400'}`} />
              )}
            </div>

            {/* Content */}
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 flex-wrap">
                {isHidden ? (
                  <span className="font-medium text-gray-500">???</span>
                ) : (
                  <>
                    <h4 className={`font-semibold ${isCompleted ? colors.text : ''}`}>
                      {data.name}
                    </h4>
                    <Badge variant="outline" className={`text-xs ${colors.text} ${colors.border}`}>
                      {data.difficulty}
                    </Badge>
                  </>
                )}
              </div>

              {!isHidden && (
                <>
                  <p className="text-sm text-muted-foreground line-clamp-2">
                    {data.description}
                  </p>

                  {/* XP Reward */}
                  <div className="flex items-center gap-1 text-xs">
                    <Star className="h-3 w-3 text-yellow-500 fill-yellow-500" />
                    <span className="font-medium">{data.xp_reward} XP</span>
                  </div>
                </>
              )}
            </div>

            {/* Completion indicator */}
            {isCompleted && (
              <Tooltip>
                <TooltipTrigger>
                  <div className="h-8 w-8 rounded-full bg-green-500 flex items-center justify-center">
                    <Trophy className="h-4 w-4 text-white" />
                  </div>
                </TooltipTrigger>
                <TooltipContent>
                  <p>Unlocked{completedAt ? ` on ${new Date(completedAt).toLocaleDateString()}` : ''}</p>
                </TooltipContent>
              </Tooltip>
            )}
          </div>

          {/* Progress bar */}
          {showProgress && isUserAchievement && !isCompleted && !isHidden && data.target_value && (
            <div className="space-y-1">
              <div className="flex justify-between text-xs text-muted-foreground">
                <span>Progress</span>
                <span>{progress} / {data.target_value}</span>
              </div>
              <Progress value={percentComplete} className="h-2" />
            </div>
          )}
        </CardContent>
      </Card>
    </TooltipProvider>
  )
}

interface AchievementGridProps {
  achievements: (UserAchievement | Achievement)[]
  size?: 'sm' | 'md' | 'lg'
  onAchievementClick?: (achievement: UserAchievement | Achievement) => void
}

export function AchievementGrid({
  achievements,
  size = 'md',
  onAchievementClick,
}: AchievementGridProps) {
  // Sort: completed first, then by difficulty
  const sortedAchievements = [...achievements].sort((a, b) => {
    const aCompleted = 'is_completed' in a ? a.is_completed : false
    const bCompleted = 'is_completed' in b ? b.is_completed : false
    if (aCompleted !== bCompleted) return aCompleted ? -1 : 1

    const aData = 'achievement' in a ? a.achievement : a
    const bData = 'achievement' in b ? b.achievement : b
    const difficultyOrder = ['easy', 'medium', 'hard', 'expert']
    return difficultyOrder.indexOf(aData.difficulty) - difficultyOrder.indexOf(bData.difficulty)
  })

  const gridCols = {
    sm: 'grid-cols-4 sm:grid-cols-6 md:grid-cols-8',
    md: 'grid-cols-2 sm:grid-cols-3 md:grid-cols-4',
    lg: 'grid-cols-1 sm:grid-cols-2 md:grid-cols-3'
  }

  return (
    <div className={`grid gap-4 ${gridCols[size]}`}>
      {sortedAchievements.map((achievement) => (
        <AchievementCard
          key={'achievement' in achievement ? achievement.achievement.id : achievement.id}
          achievement={achievement}
          size={size}
          onClick={() => onAchievementClick?.(achievement)}
        />
      ))}
    </div>
  )
}

export default AchievementCard
