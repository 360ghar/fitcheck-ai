import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import type { ReactNode } from 'react'

const navigate = vi.fn()
const setUser = vi.fn()
const updateCurrentUser = vi.fn()
const updateUserPreferences = vi.fn()

vi.mock('react-router-dom', () => ({
  Link: ({ children }: { children: ReactNode }) => <a>{children}</a>,
  useNavigate: () => navigate,
}))

vi.mock('@/components/seo/SEO', () => ({ default: () => null }))

vi.mock('@/stores/authStore', () => ({
  useCurrentUser: () => ({ id: 'u1', email: 'a@b.c', gender: null, created_at: new Date().toISOString() }),
  useAuthStore: (selector: (s: { setUser: typeof setUser }) => unknown) => selector({ setUser }),
}))

vi.mock('@/api/users', () => ({
  getUserPreferences: () => Promise.resolve({ preferred_styles: [], preferred_occasions: [] }),
  updateCurrentUser: (...args: unknown[]) => updateCurrentUser(...args),
  updateUserPreferences: (...args: unknown[]) => updateUserPreferences(...args),
}))

import WelcomePage from '../WelcomePage'

describe('WelcomePage', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    localStorage.clear()
    updateCurrentUser.mockResolvedValue({ user: { id: 'u1', gender: 'female' }, skippedFields: [] })
    updateUserPreferences.mockResolvedValue({})
  })

  it('saves each step and ends on the upload', async () => {
    render(<WelcomePage />)
    const next = screen.getByRole('button', { name: 'Continue' })
    expect(next).toBeDisabled()

    fireEvent.click(screen.getByRole('radio', { name: 'Women' }))
    fireEvent.click(next)
    await screen.findByRole('heading', { name: 'What do you wear most?' })
    expect(updateCurrentUser).toHaveBeenCalledWith({ gender: 'female' })
    expect(setUser).toHaveBeenCalled()

    fireEvent.click(screen.getByRole('button', { name: 'Casual' }))
    fireEvent.click(screen.getByRole('button', { name: 'Weekend' }))
    fireEvent.click(screen.getByRole('button', { name: 'Continue' }))
    await screen.findByRole('heading', { name: 'Add your first pieces.' })
    expect(updateUserPreferences).toHaveBeenCalledWith({
      preferred_styles: ['Casual'],
      preferred_occasions: ['Weekend'],
    })

    fireEvent.click(screen.getByRole('button', { name: 'Add clothes' }))
    expect(navigate).toHaveBeenCalledWith('/wardrobe?action=add', { replace: true })
    expect(localStorage.getItem('fitcheck_setup_done_u1')).toBe('1')
  })

  it('skip setup marks it done and goes to the dashboard', async () => {
    render(<WelcomePage />)
    fireEvent.click(screen.getByRole('button', { name: 'Skip setup' }))
    await waitFor(() => expect(navigate).toHaveBeenCalledWith('/dashboard', { replace: true }))
    expect(localStorage.getItem('fitcheck_setup_done_u1')).toBe('1')
    expect(updateCurrentUser).not.toHaveBeenCalled()
  })
})
