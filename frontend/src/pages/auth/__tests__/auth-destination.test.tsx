import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

const { navigate, login, signInWithGoogle, clearError } = vi.hoisted(() => ({
  navigate: vi.fn(),
  login: vi.fn(),
  signInWithGoogle: vi.fn(),
  clearError: vi.fn(),
}))

vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual<typeof import('react-router-dom')>('react-router-dom')
  return { ...actual, useNavigate: () => navigate }
})

vi.mock('@/stores/authStore', () => ({
  useAuthStore: (selector: (state: unknown) => unknown) =>
    selector({ login, signInWithGoogle, isLoading: false, error: null, clearError }),
}))
vi.mock('@/components/seo/SEO', () => ({ default: () => null }))

import LoginPage from '@/pages/auth/LoginPage'

describe('auth destination preservation', () => {
  beforeEach(() => {
    navigate.mockReset()
    login.mockReset()
    signInWithGoogle.mockReset()
    clearError.mockReset()
    login.mockResolvedValue(undefined)
    signInWithGoogle.mockResolvedValue(undefined)
    localStorage.clear()
  })

  it('returns email sign-in to the requested internal destination', async () => {
    render(
      <MemoryRouter initialEntries={['/auth/login?returnTo=%2Foutfits%2Foutfit-1'] }>
        <LoginPage />
      </MemoryRouter>
    )

    fireEvent.change(screen.getByLabelText('Email address'), { target: { value: 'user@example.com' } })
    fireEvent.change(screen.getByLabelText('Password'), { target: { value: 'password' } })
    fireEvent.submit(screen.getByRole('button', { name: 'Sign in' }).closest('form')!)

    await waitFor(() => expect(navigate).toHaveBeenCalledWith('/outfits/outfit-1'))
  })

  it('persists the requested internal destination before Google OAuth', async () => {
    render(
      <MemoryRouter initialEntries={['/auth/login?returnTo=%2Foutfits%2Foutfit-1'] }>
        <LoginPage />
      </MemoryRouter>
    )

    fireEvent.click(screen.getByRole('button', { name: /Continue with Google/i }))

    await waitFor(() => expect(signInWithGoogle).toHaveBeenCalled())
    expect(localStorage.getItem('pending_auth_return_to')).toBe('/outfits/outfit-1')
  })

  it('lands email sign-in on the plan page when a promo code is in the URL', async () => {
    render(
      <MemoryRouter initialEntries={['/auth/login?promo=LAUNCH30'] }>
        <LoginPage />
      </MemoryRouter>
    )

    fireEvent.change(screen.getByLabelText('Email address'), { target: { value: 'user@example.com' } })
    fireEvent.change(screen.getByLabelText('Password'), { target: { value: 'password' } })
    fireEvent.submit(screen.getByRole('button', { name: 'Sign in' }).closest('form')!)

    await waitFor(() => expect(navigate).toHaveBeenCalledWith('/profile?tab=plan'))
    // The promo is stashed so the plan page can pre-fill and redeem it.
    expect(localStorage.getItem('pending_promo_code')).toBe('LAUNCH30')
  })

  it('stashes the promo code before Google OAuth so the callback can land on the plan page', async () => {
    render(
      <MemoryRouter initialEntries={['/auth/login?promo=LAUNCH30'] }>
        <LoginPage />
      </MemoryRouter>
    )

    fireEvent.click(screen.getByRole('button', { name: /Continue with Google/i }))

    await waitFor(() => expect(signInWithGoogle).toHaveBeenCalled())
    expect(localStorage.getItem('pending_promo_code')).toBe('LAUNCH30')
  })

  it('clears a stale plan intent when Google is started without a plan param', async () => {
    // A failed OAuth attempt can leave `pending_plan_type` behind. A later
    // plain Google sign-in must not be hijacked into the plan page by it.
    localStorage.setItem('pending_plan_type', 'pro_monthly')

    render(
      <MemoryRouter initialEntries={['/auth/login'] }>
        <LoginPage />
      </MemoryRouter>
    )

    fireEvent.click(screen.getByRole('button', { name: /Continue with Google/i }))

    await waitFor(() => expect(signInWithGoogle).toHaveBeenCalled())
    expect(localStorage.getItem('pending_plan_type')).toBeNull()
  })

  it('keeps plan_type alongside a promo when both are in the URL', async () => {
    render(
      <MemoryRouter initialEntries={['/auth/login?plan_type=pro_monthly&promo=LAUNCH30'] }>
        <LoginPage />
      </MemoryRouter>
    )

    fireEvent.change(screen.getByLabelText('Email address'), { target: { value: 'user@example.com' } })
    fireEvent.change(screen.getByLabelText('Password'), { target: { value: 'password' } })
    fireEvent.submit(screen.getByRole('button', { name: 'Sign in' }).closest('form')!)

    await waitFor(() =>
      expect(navigate).toHaveBeenCalledWith('/profile?tab=plan&plan_type=pro_monthly')
    )
    // The promo survives so the plan page can pre-fill and redeem it.
    expect(localStorage.getItem('pending_promo_code')).toBe('LAUNCH30')
  })
})
