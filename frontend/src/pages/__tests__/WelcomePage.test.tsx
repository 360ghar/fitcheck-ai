import { act, fireEvent, render, screen, waitFor } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import type { ReactNode } from 'react'
import userEvent from '@testing-library/user-event'

let search = ''
const getUserPreferences = vi.fn()
const navigate = vi.fn()
const setUser = vi.fn()
const updateCurrentUser = vi.fn()
const updateUserPreferences = vi.fn()

vi.mock('react-router-dom', () => ({
  Link: ({ children }: { children: ReactNode }) => <a>{children}</a>,
  useNavigate: () => navigate,
  useLocation: () => ({ search }),
}))

vi.mock('@/components/seo/SEO', () => ({ default: () => null }))

vi.mock('@/stores/authStore', () => ({
  useCurrentUser: () => ({ id: 'u1', email: 'a@b.c', gender: null, created_at: new Date().toISOString() }),
  useAuthStore: (selector: (s: { setUser: typeof setUser }) => unknown) => selector({ setUser }),
}))

vi.mock('@/api/users', () => ({
  getUserPreferences: (...args: unknown[]) => getUserPreferences(...args),
  updateCurrentUser: (...args: unknown[]) => updateCurrentUser(...args),
  updateUserPreferences: (...args: unknown[]) => updateUserPreferences(...args),
}))

import WelcomePage from '../WelcomePage'

describe('WelcomePage', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    localStorage.clear()
    search = ''
    getUserPreferences.mockResolvedValue({ preferred_styles: [], preferred_occasions: [] })
    updateCurrentUser.mockResolvedValue({ user: { id: 'u1', gender: 'female' }, skippedFields: [] })
    updateUserPreferences.mockResolvedValue({})
  })

  it('uses one tab stop and arrow keys for gender choices', async () => {
    const user = userEvent.setup()
    render(<WelcomePage />)
    await user.click(screen.getByRole('radio', { name: 'Women' }))
    await user.keyboard('{ArrowRight}')
    expect(screen.getByRole('radio', { name: 'Men' })).toBeChecked()
    expect(screen.getByRole('radio', { name: 'Men' })).toHaveFocus()
    await user.tab()
    expect(screen.getByRole('button', { name: 'Skip' })).toHaveFocus()
  })

  it('keeps edits when preferences arrive late', async () => {
    let resolve!: (value: unknown) => void
    getUserPreferences.mockReturnValue(new Promise((done) => { resolve = done }))
    render(<WelcomePage />)
    fireEvent.click(screen.getByRole('button', { name: 'Skip' }))
    fireEvent.click(screen.getByRole('button', { name: 'Casual' }))
    fireEvent.click(screen.getByRole('button', { name: 'Weekend' }))
    await act(async () => { resolve({ preferred_styles: ['Formal'], preferred_occasions: ['Work'] }) })
    fireEvent.click(screen.getByRole('button', { name: 'Continue' }))
    await waitFor(() => expect(updateUserPreferences).toHaveBeenCalledWith({
      preferred_styles: ['Casual'], preferred_occasions: ['Weekend'],
    }))
  })

  it.each(['Skip setup', 'Later'])('resumes the protected URL on %s', async (action) => {
    search = '?returnTo=' + encodeURIComponent('/outfits/look-1?tab=details#items')
    render(<WelcomePage />)
    if (action === 'Later') {
      fireEvent.click(screen.getByRole('button', { name: 'Skip' }))
      fireEvent.click(screen.getByRole('button', { name: 'Skip' }))
    }
    fireEvent.click(screen.getByRole('button', { name: action }))
    await waitFor(() => expect(navigate).toHaveBeenCalledWith('/outfits/look-1?tab=details#items', { replace: true }))
  })

  it.each(['https://evil.test', '//evil.test', '/welcome?again=1', '/auth/login'])('rejects unsafe or looping return URL %s', async (target) => {
    search = '?returnTo=' + encodeURIComponent(target)
    render(<WelcomePage />)
    fireEvent.click(screen.getByRole('button', { name: 'Skip setup' }))
    await waitFor(() => expect(navigate).toHaveBeenCalledWith('/dashboard', { replace: true }))
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
