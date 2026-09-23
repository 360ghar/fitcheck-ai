import { act, render, screen } from '@testing-library/react'
import { StrictMode } from 'react'
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

  it('renders the loaded content after the requests resolve', async () => {
    render(<MemoryRouter><GamificationPage /></MemoryRouter>)

    expect(await screen.findByText(/day streak/)).toBeInTheDocument()
    expect(screen.getByText('Best: 4 days')).toBeInTheDocument()
    expect(screen.getByText('Earned 0')).toBeInTheDocument()
    expect(screen.queryByLabelText('Loading streak')).not.toBeInTheDocument()
  })

  it('keeps the newer StrictMode load when the first load settles later', async () => {
    let resolveFirst!: (value: typeof streak) => void
    const first = new Promise<typeof streak>((resolve) => {
      resolveFirst = resolve
    })
    const newerStreak = { current_streak: 9, longest_streak: 9, next_milestone: null }
    vi.mocked(getStreak)
      .mockReturnValueOnce(first as never)
      .mockResolvedValueOnce(newerStreak as never)

    render(
      <StrictMode>
        <MemoryRouter><GamificationPage /></MemoryRouter>
      </StrictMode>,
    )

    expect(await screen.findByText('Best: 9 days')).toBeInTheDocument()

    await act(async () => {
      resolveFirst(streak)
    })

    expect(screen.getByText('Best: 9 days')).toBeInTheDocument()
    expect(screen.queryByText('Best: 4 days')).not.toBeInTheDocument()
  })
})
