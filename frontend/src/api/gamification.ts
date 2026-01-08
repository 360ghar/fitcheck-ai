/**
 * Gamification API endpoints
 */

import { apiClient, getApiError } from './client'
import type { ApiEnvelope } from '../types'

export interface NextMilestone {
  days: number
  name: string
  badge: string
}

export interface StreakData {
  current_streak: number
  longest_streak: number
  last_planned: string | null
  streak_freezes_remaining: number
  streak_skips_remaining: number
  next_milestone: NextMilestone | null
}

export interface AchievementsData {
  earned: Array<{
    id: string
    user_id: string
    achievement_id: string
    earned_at: string
    reward_claimed: boolean
  }>
  available: Array<{
    id: string
    name: string
    description: string
    xp_reward?: number
  }>
}

export interface LeaderboardEntryData {
  rank: number
  user_id: string
  username: string
  avatar_url?: string
  level: number
  total_points: number
  current_streak?: number
}

export interface UserRankData {
  rank: number
  total_points: number
  level: number
  total_users: number
  top_percentile: number
}

export interface LeaderboardData {
  entries: LeaderboardEntryData[]
  user_rank?: UserRankData | null
}

export async function getStreak(): Promise<StreakData> {
  try {
    const response = await apiClient.get<ApiEnvelope<StreakData>>('/api/v1/gamification/streak')
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

export async function getAchievements(): Promise<AchievementsData> {
  try {
    const response = await apiClient.get<ApiEnvelope<AchievementsData>>('/api/v1/gamification/achievements')
    return response.data.data
  } catch (error) {
    throw getApiError(error)
  }
}

export async function getLeaderboard(): Promise<LeaderboardData> {
  try {
    const response = await apiClient.get<ApiEnvelope<{ entries: LeaderboardEntryData[]; user_rank?: UserRankData | null }>>(
      '/api/v1/gamification/leaderboard'
    )
    const data = response.data.data
    return {
      entries: (data.entries || []).map((entry) => ({
        ...entry,
        avatar_url: entry.avatar_url ?? undefined,
      })),
      user_rank: data.user_rank ?? null,
    }
  } catch (error) {
    throw getApiError(error)
  }
}
