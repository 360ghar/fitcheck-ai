/**
 * Gamification Page
 *
 * MVP view backed by `/api/v1/gamification/*` endpoints.
 */

import { useEffect, useState } from 'react'
import { Flame, Trophy, RefreshCw } from 'lucide-react'

import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'
import { useToast } from '@/components/ui/use-toast'

import { getAchievements, getLeaderboard, getStreak } from '@/api/gamification'
import type { AchievementsData, LeaderboardData, LeaderboardEntryData, StreakData, UserRankData } from '@/api/gamification'
import { Leaderboard } from '@/components/gamification'
import { useAuthStore } from '@/stores/authStore'

export default function GamificationPage() {
  const [isLoading, setIsLoading] = useState(true)
  const [streak, setStreak] = useState<StreakData | null>(null)
  const [achievements, setAchievements] = useState<AchievementsData | null>(null)
  const [leaderboard, setLeaderboard] = useState<LeaderboardEntryData[]>([])
  const [userRank, setUserRank] = useState<UserRankData | null>(null)
  const currentUserId = useAuthStore((s) => s.user?.id)

  const { toast } = useToast()

  useEffect(() => {
    const load = async () => {
      setIsLoading(true)
      try {
        const [streakRes, achievementsRes, leaderboardRes]: [StreakData, AchievementsData, LeaderboardData] =
          await Promise.all([
          getStreak(),
          getAchievements(),
          getLeaderboard(),
        ])
        setStreak(streakRes)
        setAchievements(achievementsRes)
        setLeaderboard(leaderboardRes.entries)
        setUserRank(leaderboardRes.user_rank ?? null)
      } catch (err) {
        toast({
          title: 'Failed to load gamification',
          description: err instanceof Error ? err.message : 'An error occurred',
          variant: 'destructive',
        })
      } finally {
        setIsLoading(false)
      }
    }

    load()
  }, [toast])

  const nextMilestoneDays = streak?.next_milestone?.days
  const nextMilestoneProgress = nextMilestoneDays
    ? Math.min(100, ((streak?.current_streak ?? 0) / nextMilestoneDays) * 100)
    : 0

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 md:py-8 space-y-6">
      <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div>
          <h1 className="text-xl md:text-2xl font-display font-semibold text-foreground">Gamification</h1>
          <p className="text-sm text-muted-foreground">Streaks, achievements, and leaderboard</p>
        </div>
        <Button
          variant="outline"
          onClick={() => window.location.reload()}
          disabled={isLoading}
          className="w-full md:w-auto"
        >
          <RefreshCw className={`h-4 w-4 mr-2 ${isLoading ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Flame className="h-5 w-5 text-orange-500" />
              Streak
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-2">
            <p className="text-sm text-muted-foreground">Current: {streak?.current_streak ?? 0} days</p>
            <p className="text-sm text-muted-foreground">Best: {streak?.longest_streak ?? 0} days</p>
            {streak?.next_milestone && (
              <div className="pt-2">
                <div className="flex justify-between text-xs text-muted-foreground mb-1">
                  <span>Next milestone</span>
                  <span>{streak.next_milestone.days} days</span>
                </div>
                <Progress value={nextMilestoneProgress} className="h-2" />
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Trophy className="h-5 w-5 text-yellow-500" />
              Achievements
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-2">
            <p className="text-sm text-muted-foreground">Earned: {achievements?.earned?.length ?? 0}</p>
            <p className="text-sm text-muted-foreground">Available: {achievements?.available?.length ?? 0}</p>
            <div className="pt-2 space-y-1">
              {(achievements?.available || []).slice(0, 3).map((a) => (
                <div key={a.id} className="text-xs text-foreground">
                  <span className="font-medium">{a.name}</span>: {a.description}
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      <Leaderboard
        entries={leaderboard}
        currentUserId={currentUserId}
        userRank={userRank || undefined}
      />
    </div>
  )
}
