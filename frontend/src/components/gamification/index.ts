/**
 * Gamification Components Index
 *
 * Only `Leaderboard` survives. `AchievementCard`, `StreakDisplay` and
 * `ChallengeCard` (1,119 lines) were deleted: nothing imported them but this
 * barrel, and `ChallengeCard` targeted a `challenges` table and endpoint that
 * have never existed, so it could not mount as written.
 *
 * The whole feature is flag-gated behind `FEATURES.gamification`
 * (`src/lib/feature-flags.ts`), default off. `Leaderboard` is kept because
 * `pages/gamification/GamificationPage` mounts it and it works — it is what
 * the flag turns back on.
 */

export { Leaderboard } from './Leaderboard'
export type { LeaderboardEntry } from './Leaderboard'
