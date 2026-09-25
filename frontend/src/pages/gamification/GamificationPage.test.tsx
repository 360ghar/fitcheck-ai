import { act, render, screen } from '@testing-library/react'
import { StrictMode } from 'react'
import { MemoryRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import GamificationPage from './GamificationPage'
import { getAchievements, getLeaderboard, getStreak } from '@/api/gamification'
import { logger } from '@/lib/logger'

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

    expect(
      screen.getByRole('status', { name: 'Loading streak' }),
    ).toBeInTheDocument()
    expect(
      screen.getByRole('status', { name: 'Loading achievements' }),
    ).toBeInTheDocument()
  })

  it('does not expose a raw backend error in the retry state', async () => {
    const errorSpy = vi.spyOn(logger, 'error').mockImplementation(() => undefined)
    vi.mocked(getStreak).mockRejectedValue(new Error('relation reward_ledger does not exist'))
    render(<MemoryRouter><GamificationPage /></MemoryRouter>)

    expect(await screen.findByText(/couldn't load your rewards right now/i)).toBeInTheDocument()
    expect(screen.queryByText(/reward_ledger/i)).not.toBeInTheDocument()
    // The diagnostic is preserved in telemetry even though it never renders.
    expect(errorSpy).toHaveBeenCalledWith(
      'Gamification load failed',
      expect.objectContaining({ message: 'relation reward_ledger does not exist' }),
    )
    errorSpy.mockRestore()
  })

  it('keeps the live region mounted and announces the loaded result', async () => {
    render(<MemoryRouter><GamificationPage /></MemoryRouter>)

    expect(await screen.findByText(/day streak/)).toBeInTheDocument()
    expect(
      screen.getByRole('status', { name: 'Streak loaded' }),
    ).toBeInTheDocument()
    expect(
      screen.getByRole('status', { name: 'Achievements loaded' }),
    ).toBeInTheDocument()
  })

  it('renders the loaded content after the requests resolve', async () => {
    render(<MemoryRouter><GamificationPage /></MemoryRouter>)

    expect(await screen.findByText(/day streak/)).toBeInTheDocument()
    expect(screen.getByText('Best: 4 days')).toBeInTheDocument()
    expect(screen.getByText('Earned 0')).toBeInTheDocument()
    expect(screen.queryByLabelText('Loading streak')).not.toBeInTheDocument()
  })

  it('logs a stale failure without replacing the current result', async () => {
    const errorSpy = vi.spyOn(logger, 'error').mockImplementation(() => undefined)
    let rejectFirst!: (error: Error) => void
    vi.mocked(getStreak).mockReturnValueOnce(new Promise((_, reject) => { rejectFirst = reject }))
    render(<StrictMode><MemoryRouter><GamificationPage /></MemoryRouter></StrictMode>)
    expect(await screen.findByText('Best: 4 days')).toBeInTheDocument()
    const error = new Error('late backend failure')
    await act(async () => { rejectFirst(error) })
    expect(errorSpy).toHaveBeenCalledWith('Gamification load failed', error)
    expect(screen.getByText('Best: 4 days')).toBeInTheDocument()
    expect(screen.queryByText(/couldn't load/)).not.toBeInTheDocument()
    errorSpy.mockRestore()
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
