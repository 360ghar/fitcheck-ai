/**
 * Leaderboard Component
 *
 * Displays ranked leaderboard of top users.
 * Features:
 * - Top 3 podium display
 * - User ranking highlight
 * - Scrollable list
 * - Filter by time period
 *
 * @see https://docs.fitcheck.ai/features/gamification/leaderboard
 */

import { useState } from 'react'
import {
  Trophy,
  Medal,
  Crown,
  Award,
  ChevronDown,
  User,
} from 'lucide-react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from '@/components/ui/tooltip'

// ============================================================================
// TYPES
// ============================================================================

export interface LeaderboardEntry {
  rank: number
  user_id: string
  username: string
  avatar_url?: string
  level: number
  total_points: number
}

interface LeaderboardProps {
  entries: LeaderboardEntry[]
  currentUserId?: string
  userRank?: {
    rank: number
    total_points: number
    level: number
    total_users: number
    top_percentile: number
  }
  onPeriodChange?: (period: string) => void
  period?: 'all' | 'week' | 'month'
}

// ============================================================================
// COMPONENTS
// ============================================================================

function RankBadge({ rank }: { rank: number }) {
  if (rank === 1) {
    return (
      <div className="h-10 w-10 rounded-full bg-gradient-to-br from-yellow-400 to-yellow-600 flex items-center justify-center shadow-lg">
        <Crown className="h-5 w-5 text-white" />
      </div>
    )
  }

  if (rank === 2) {
    return (
      <div className="h-10 w-10 rounded-full bg-gradient-to-br from-gray-300 to-gray-500 flex items-center justify-center shadow-lg">
        <Medal className="h-5 w-5 text-white" />
      </div>
    )
  }

  if (rank === 3) {
    return (
      <div className="h-10 w-10 rounded-full bg-gradient-to-br from-amber-600 to-amber-800 flex items-center justify-center shadow-lg">
        <Medal className="h-5 w-5 text-white" />
      </div>
    )
  }

  return (
    <div className="h-10 w-10 rounded-full bg-muted flex items-center justify-center font-bold text-muted-foreground">
      {rank}
    </div>
  )
}

function Podium({ entries }: { entries: LeaderboardEntry[] }) {
  const top3 = entries.slice(0, 3)
  const [first, second, third] = [
    top3.find((e) => e.rank === 1),
    top3.find((e) => e.rank === 2),
    top3.find((e) => e.rank === 3),
  ]

  if (!first) return null

  return (
    <div className="flex items-end justify-center gap-4 h-48 mb-6">
      {/* Second place */}
      {second && (
        <div className="flex flex-col items-center">
          <Avatar className="h-16 w-16 border-4 border-gray-300">
            {second.avatar_url ? (
              <AvatarImage src={second.avatar_url} />
            ) : (
              <AvatarFallback>
                <User className="h-8 w-8" />
              </AvatarFallback>
            )}
          </Avatar>
          <p className="text-sm font-medium mt-2 max-w-20 truncate text-foreground">{second.username}</p>
          <p className="text-xs text-muted-foreground">{second.total_points.toLocaleString()} pts</p>
          <div className="w-20 h-24 bg-gradient-to-t from-gray-400 to-gray-300 rounded-t-lg mt-2 flex items-end justify-center pb-2">
            <span className="text-2xl font-bold text-white">2</span>
          </div>
        </div>
      )}

      {/* First place */}
      <div className="flex flex-col items-center">
        <div className="relative">
          <Avatar className="h-20 w-20 border-4 border-yellow-400">
            {first.avatar_url ? (
              <AvatarImage src={first.avatar_url} />
            ) : (
              <AvatarFallback>
                <User className="h-10 w-10" />
              </AvatarFallback>
            )}
          </Avatar>
          <Trophy className="h-8 w-8 text-yellow-500 absolute -bottom-2 -right-2 fill-yellow-500" />
        </div>
        <p className="text-sm font-semibold mt-2 max-w-24 truncate text-foreground">{first.username}</p>
        <p className="text-xs text-muted-foreground">{first.total_points.toLocaleString()} pts</p>
        <div className="w-24 h-32 bg-gradient-to-t from-yellow-500 to-yellow-400 rounded-t-lg mt-2 flex items-end justify-center pb-2 shadow-lg">
          <span className="text-3xl font-bold text-white">1</span>
        </div>
      </div>

      {/* Third place */}
      {third && (
        <div className="flex flex-col items-center">
          <Avatar className="h-16 w-16 border-4 border-amber-600">
            {third.avatar_url ? (
              <AvatarImage src={third.avatar_url} />
            ) : (
              <AvatarFallback>
                <User className="h-8 w-8" />
              </AvatarFallback>
            )}
          </Avatar>
          <p className="text-sm font-medium mt-2 max-w-20 truncate text-foreground">{third.username}</p>
          <p className="text-xs text-muted-foreground">{third.total_points.toLocaleString()} pts</p>
          <div className="w-20 h-16 bg-gradient-to-t from-amber-700 to-amber-600 rounded-t-lg mt-2 flex items-end justify-center pb-2">
            <span className="text-2xl font-bold text-white">3</span>
          </div>
        </div>
      )}
    </div>
  )
}

function LeaderboardRow({
  entry,
  isCurrentUser,
  showRank = true
}: {
  entry: LeaderboardEntry
  isCurrentUser: boolean
  showRank?: boolean
}) {
  return (
    <div
      className={`
        flex items-center gap-3 p-3 rounded-lg transition-colors
        ${isCurrentUser ? 'bg-gold-50 dark:bg-gold-900/20 border border-gold-200 dark:border-gold-800' : 'hover:bg-muted'}
      `}
    >
      {showRank && <RankBadge rank={entry.rank} />}

      <Avatar className={isCurrentUser ? 'ring-2 ring-gold-500' : ''}>
        {entry.avatar_url ? (
          <AvatarImage src={entry.avatar_url} />
        ) : (
          <AvatarFallback>
            <User className="h-5 w-5" />
          </AvatarFallback>
        )}
      </Avatar>

      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <p className="font-medium truncate text-foreground">{entry.username}</p>
          {isCurrentUser && (
            <Badge variant="secondary" className="text-xs">You</Badge>
          )}
        </div>
        <div className="flex items-center gap-2 text-sm text-muted-foreground">
          <span>Level {entry.level}</span>
          <span>•</span>
          <span className="font-semibold text-navy-700 dark:text-gold-400">{entry.total_points.toLocaleString()} pts</span>
        </div>
      </div>

      {entry.rank <= 3 && (
        <TooltipProvider>
          <Tooltip>
            <TooltipTrigger>
              <Award className={`h-5 w-5 ${
                entry.rank === 1 ? 'text-yellow-500' :
                entry.rank === 2 ? 'text-gray-400' : 'text-amber-600'
              }`} />
            </TooltipTrigger>
            <TooltipContent>
              <p>Rank #{entry.rank}</p>
            </TooltipContent>
          </Tooltip>
        </TooltipProvider>
      )}
    </div>
  )
}

// ============================================================================
// MAIN COMPONENT
// ============================================================================

export function Leaderboard({
  entries,
  currentUserId,
  userRank,
  onPeriodChange,
  period = 'all'
}: LeaderboardProps) {
  const [showAll, setShowAll] = useState(false)

  // Find if current user is in the visible list
  const visibleEntries = showAll ? entries : entries.slice(0, 10)
  const currentUserInList = entries.find((e) => e.user_id === currentUserId)
  const isCurrentUserVisible = currentUserInList && showAll
    ? true
    : currentUserInList && currentUserInList.rank <= 10

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle className="flex items-center gap-2">
            <Trophy className="h-5 w-5 text-yellow-500" />
            Leaderboard
          </CardTitle>

          {onPeriodChange && (
            <Select value={period} onValueChange={onPeriodChange}>
              <SelectTrigger className="w-32">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Time</SelectItem>
                <SelectItem value="week">This Week</SelectItem>
                <SelectItem value="month">This Month</SelectItem>
              </SelectContent>
            </Select>
          )}
        </div>
      </CardHeader>

      <CardContent className="space-y-4">
        {/* Podium for top 3 */}
        {entries.length >= 3 && !showAll && <Podium entries={entries} />}

        {/* Leaderboard list */}
        <div className="space-y-1">
          {visibleEntries.map((entry) => (
            <LeaderboardRow
              key={entry.user_id}
              entry={entry}
              isCurrentUser={entry.user_id === currentUserId}
              showRank={entries.length < 3 || showAll}
            />
          ))}
        </div>

        {/* Show more button */}
        {entries.length > 10 && !showAll && (
          <Button
            variant="outline"
            className="w-full"
            onClick={() => setShowAll(true)}
          >
            Show All ({entries.length}) <ChevronDown className="h-4 w-4 ml-2" />
          </Button>
        )}

        {/* User's own rank if not in list */}
        {userRank && !isCurrentUserVisible && (
          <div className="pt-4 border-t border-border">
            <div className="flex items-center justify-between mb-2">
              <p className="text-sm font-medium text-foreground">Your Ranking</p>
              <Badge variant="outline">
                Top {userRank.top_percentile}%
              </Badge>
            </div>
            <LeaderboardRow
              entry={{
                rank: userRank.rank,
                user_id: currentUserId || '',
                username: 'You',
                level: userRank.level,
                total_points: userRank.total_points,
              }}
              isCurrentUser={true}
              showRank={true}
            />
          </div>
        )}

        {/* User stats summary */}
        {userRank && (
          <div className="pt-4 border-t border-border">
            <div className="grid grid-cols-3 gap-4 text-center">
              <div>
                <p className="text-2xl font-bold text-navy-700 dark:text-gold-400">#{userRank.rank}</p>
                <p className="text-xs text-muted-foreground">Your Rank</p>
              </div>
              <div>
                <p className="text-2xl font-bold text-foreground">{userRank.level}</p>
                <p className="text-xs text-muted-foreground">Level</p>
              </div>
              <div>
                <p className="text-2xl font-bold text-gold-600 dark:text-gold-500">{userRank.total_points.toLocaleString()}</p>
                <p className="text-xs text-muted-foreground">Total Points</p>
              </div>
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  )
}

export default Leaderboard
