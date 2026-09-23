import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import GamificationPage from './GamificationPage'
import { getAchievements, getLeaderboard, getStreak } from '@/api/gamification'

vi.mock('@/api/gamification', () => ({
  getStreak: vi.fn(),
  getAchievements: vi.fn(),
  getLeaderboard: vi.fn(),
}))

vi.mock('@/stores/authStore', () => ({
  useAuthStore: (selector: (state: { user: { id: string } }) => unknown) =>
    selector({ user: { id: 'user-1' } }),
}))

const streak = { current_streak: 2, longest_streak: 4, next_milestone: null }
const achievements = { earned: [], available: [] }
const leaderboard = { entries: [], user_rank: null }

describe('GamificationPage reliability states', () => {
  beforeEach(() => {
    vi.mocked(getStreak).mockResolvedValue(streak as never)
    vi.mocked(getAchievements).mockResolvedValue(achievements as never)
    vi.mocked(getLeaderboard).mockResolvedValue(leaderboard as never)
  })

  it('renders content-shaped skeletons while the first request is pending', () => {
    vi.mocked(getStreak).mockReturnValue(new Promise(() => undefined))
    render(<MemoryRouter><GamificationPage /></MemoryRouter>)

    expect(screen.getByLabelText('Loading streak')).toBeInTheDocument()
    expect(screen.getByLabelText('Loading achievements')).toBeInTheDocument()
  })

  it('does not expose a raw backend error in the retry state', async () => {
    vi.mocked(getStreak).mockRejectedValue(new Error('relation reward_ledger does not exist'))
    render(<MemoryRouter><GamificationPage /></MemoryRouter>)

    expect(await screen.findByText(/couldn't load your rewards right now/i)).toBeInTheDocument()
    expect(screen.queryByText(/reward_ledger/i)).not.toBeInTheDocument()
  })
})
