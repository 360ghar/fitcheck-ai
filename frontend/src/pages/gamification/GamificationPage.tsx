/**
 * Gamification Page
 *
 * MVP view backed by `/api/v1/gamification/*` endpoints.
 */

import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { Flame, Trophy, RefreshCw, Lock, Award } from 'lucide-react'

import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'
import { Badge } from '@/components/ui/badge'
import { useToast } from '@/components/ui/use-toast'
import { EmptyState } from '@/components/ui/empty-state'

import { getAchievements, getLeaderboard, getStreak } from '@/api/gamification'
import type { AchievementsData, LeaderboardData, LeaderboardEntryData, StreakData, UserRankData } from '@/api/gamification'
import { Leaderboard } from '@/components/gamification'
import { useAuthStore } from '@/stores/authStore'

export default function GamificationPage() {
  const [isLoading, setIsLoading] = useState(true)
  const [loadError, setLoadError] = useState<string | null>(null)
  const [streak, setStreak] = useState<StreakData | null>(null)
  const [achievements, setAchievements] = useState<AchievementsData | null>(null)
  const [leaderboard, setLeaderboard] = useState<LeaderboardEntryData[]>([])
  const [userRank, setUserRank] = useState<UserRankData | null>(null)
  const currentUserId = useAuthStore((s) => s.user?.id)

  const { toast } = useToast()

  const load = async () => {
    setIsLoading(true)
    setLoadError(null)
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
      const message = err instanceof Error ? err.message : 'An error occurred'
      setLoadError(message)
      setStreak(null)
      setAchievements(null)
      setLeaderboard([])
      setUserRank(null)
      toast({
        title: 'Failed to load streaks & rewards',
        description: message,
        variant: 'destructive',
      })
    } finally {
      setIsLoading(false)
    }
  }

  useEffect(() => {
    void load()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [toast])

  const nextMilestoneDays = streak?.next_milestone?.days
  const nextMilestoneProgress = nextMilestoneDays
    ? Math.min(100, ((streak?.current_streak ?? 0) / nextMilestoneDays) * 100)
    : 0

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 md:py-8 space-y-6">
      <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Streaks &amp; Rewards</h1>
          <p className="text-sm text-muted-foreground">Streaks, achievements, and leaderboard</p>
        </div>
        <Button
          variant="outline"
          onClick={() => void load()}
          disabled={isLoading}
          className="w-full md:w-auto"
        >
          <RefreshCw className={`h-4 w-4 mr-2 ${isLoading ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      </div>

      {loadError ? (
        <Card className="border-destructive/30">
          <CardContent className="py-10 text-center space-y-3">
            <Trophy className="h-10 w-10 mx-auto text-destructive/60" />
            <p className="text-lg font-medium text-foreground">Couldn&apos;t load gamification</p>
            <p className="text-sm text-muted-foreground">{loadError}</p>
            <Button onClick={() => void load()} disabled={isLoading}>
              Try again
            </Button>
          </CardContent>
        </Card>
      ) : (
        <>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Flame className="h-5 w-5 text-orange-500" />
              Streak
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {isLoading ? (
              <p className="text-sm text-muted-foreground">Loading streak…</p>
            ) : (streak?.current_streak ?? 0) === 0 && (streak?.longest_streak ?? 0) === 0 ? (
              <div className="space-y-3">
                <p className="text-sm text-muted-foreground">
                  Plan or mark an outfit as worn today to start a streak.
                </p>
                <Button asChild size="sm" variant="outline">
                  <Link to="/outfits">Mark an outfit worn</Link>
                </Button>
              </div>
            ) : (
              <>
                <p className="text-3xl font-bold text-foreground">
                  {streak?.current_streak ?? 0}
                  <span className="text-base font-normal text-muted-foreground ml-1">day streak</span>
                </p>
                <p className="text-sm text-muted-foreground">Best: {streak?.longest_streak ?? 0} days</p>
                {streak?.next_milestone && (
                  <div className="pt-1">
                    <div className="flex justify-between text-xs text-muted-foreground mb-1">
                      <span>Next: {streak.next_milestone.name || 'milestone'}</span>
                      <span>{streak.next_milestone.days} days</span>
                    </div>
                    <Progress value={nextMilestoneProgress} className="h-2" />
                  </div>
                )}
              </>
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
          <CardContent className="space-y-3">
            {isLoading ? (
              <p className="text-sm text-muted-foreground">Loading achievements…</p>
            ) : (
              <>
                <div className="flex gap-2">
                  <Badge variant="secondary">Earned {achievements?.earned?.length ?? 0}</Badge>
                  <Badge variant="outline">Available {achievements?.available?.length ?? 0}</Badge>
                </div>
                <div className="space-y-2 max-h-48 overflow-y-auto">
                  {(() => {
                    const earned = achievements?.earned || []
                    const catalog = achievements?.available || []
                    const earnedIds = new Set(earned.map((e) => e.achievement_id))
                    const locked = catalog.filter((a) => !earnedIds.has(a.id))
                    if (earned.length === 0 && locked.length === 0) {
                      return (
                        <EmptyState
                          className="border-0 shadow-none py-6"
                          icon={Trophy}
                          title="No achievements yet"
                          description="Wear outfits and build your wardrobe to unlock rewards."
                        />
                      )
                    }
                    return (
                      <>
                        {earned.slice(0, 4).map((a) => {
                          const meta = catalog.find((av) => av.id === a.achievement_id)
                          const title = a.name || meta?.name || 'Achievement unlocked'
                          const detail =
                            a.description ||
                            meta?.description ||
                            `Earned ${new Date(a.earned_at).toLocaleDateString()}`
                          return (
                            <div
                              key={a.id}
                              className="flex items-start gap-2 p-2 rounded-lg bg-primary/5 border border-primary/10"
                            >
                              <Award className="h-4 w-4 text-primary mt-0.5 shrink-0" />
                              <div className="text-xs min-w-0">
                                <p className="font-medium text-foreground">{title}</p>
                                <p className="text-muted-foreground">{detail}</p>
                              </div>
                            </div>
                          )
                        })}
                        {locked.slice(0, 4).map((a) => (
                          <div
                            key={a.id}
                            className="flex items-start gap-2 p-2 rounded-lg border border-border"
                          >
                            <Lock className="h-4 w-4 text-muted-foreground mt-0.5 shrink-0" />
                            <div className="text-xs min-w-0">
                              <p className="font-medium text-foreground">{a.name}</p>
                              <p className="text-muted-foreground">{a.description}</p>
                            </div>
                          </div>
                        ))}
                      </>
                    )
                  })()}
                </div>
              </>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Period filter omitted: backend leaderboard is all-time only */}
      <Leaderboard
        entries={leaderboard}
        currentUserId={currentUserId}
        userRank={userRank || undefined}
      />
        </>
      )}
    </div>
  )
}
