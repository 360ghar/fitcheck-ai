/**
 * The authenticated shell (AppLayout) must keep the session-cached user's
 * presigned `avatar_url` (1h TTL) fresh. `useUserRefresh` re-reads /users/me
 * on mount, on route change, and when the tab becomes visible again — all
 * coalesced through the request cache, so the network cost is one request per
 * freshness window. The 5-minute poll with the 50-minute guard is covered by
 * the guard logic; these tests lock in the user-visible behavior.
 */
import { act, fireEvent, render, screen, waitFor } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { MemoryRouter, useNavigate } from 'react-router-dom'

vi.mock('@/api/users', () => ({
  getCurrentUser: vi.fn(),
}))

vi.mock('@/api/auth', () => ({
  login: vi.fn(),
  register: vi.fn(),
  logout: vi.fn(),
  refreshAccessToken: vi.fn(),
  syncOAuthProfile: vi.fn(),
  storeUser: vi.fn(),
  clearUser: vi.fn(),
}))

import * as usersApi from '@/api/users'
import { useUserRefresh } from '@/hooks/useUserRefresh'
import { clearRequestCache } from '@/lib/requestCache'
import { useAuthStore } from '@/stores/authStore'
import type { User } from '@/types'

const TOKEN = 'access-token'

const initialUser = {
  id: 'user-1',
  email: 'person@example.com',
  full_name: 'Old Name',
  avatar_url: 'https://expired.example.com/avatar.png',
  is_active: true,
  email_verified: true,
  created_at: '2026-01-01T00:00:00Z',
} as User

const refreshedUser = {
  ...initialUser,
  full_name: 'Fresh Name',
  avatar_url: 'https://fresh.example.com/avatar.png',
} as User

function Probe() {
  useUserRefresh()
  const navigate = useNavigate()
  return (
    <button type="button" onClick={() => navigate('/wardrobe')}>
      navigate
    </button>
  )
}

beforeEach(() => {
  vi.clearAllMocks()
  localStorage.clear()
  clearRequestCache()
  useAuthStore.setState({
    user: initialUser,
    tokens: { access_token: TOKEN, refresh_token: 'refresh-token' },
    isAuthenticated: true,
    isLoading: false,
    error: null,
  })
})

describe('useUserRefresh', () => {
  it('refreshes the user on mount and applies the fresh profile', async () => {
    vi.mocked(usersApi.getCurrentUser).mockResolvedValue(refreshedUser)

    render(
      <MemoryRouter initialEntries={['/try-on']}>
        <Probe />
      </MemoryRouter>
    )

    await waitFor(() => expect(useAuthStore.getState().user).toBe(refreshedUser))
    expect(usersApi.getCurrentUser).toHaveBeenCalledTimes(1)
  })

  it('re-fetches on route change once the cached copy is stale', async () => {
    vi.mocked(usersApi.getCurrentUser).mockResolvedValue(refreshedUser)

    render(
      <MemoryRouter initialEntries={['/try-on']}>
        <Probe />
      </MemoryRouter>
    )
    await waitFor(() => expect(usersApi.getCurrentUser).toHaveBeenCalledTimes(1))

    // Route changes inside the 30s freshness window are cache hits; simulate
    // an expired cache (the URL is stale after ~1h anyway) and navigate.
    act(() => clearRequestCache())
    fireEvent.click(screen.getByRole('button', { name: 'navigate' }))

    await waitFor(() => expect(usersApi.getCurrentUser).toHaveBeenCalledTimes(2))
    expect(useAuthStore.getState().user).toBe(refreshedUser)
  })

  it('re-fetches when the tab becomes visible again', async () => {
    vi.mocked(usersApi.getCurrentUser).mockResolvedValue(refreshedUser)

    render(
      <MemoryRouter initialEntries={['/try-on']}>
        <Probe />
      </MemoryRouter>
    )
    await waitFor(() => expect(usersApi.getCurrentUser).toHaveBeenCalledTimes(1))

    // jsdom reports the tab as visible, so a visibilitychange event is enough
    // to trigger the refresh handler.
    act(() => clearRequestCache())
    act(() => {
      document.dispatchEvent(new Event('visibilitychange'))
    })

    await waitFor(() => expect(usersApi.getCurrentUser).toHaveBeenCalledTimes(2))
  })
})
