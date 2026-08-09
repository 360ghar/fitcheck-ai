/**
 * Locks in `refreshUser`: the auth store re-reads /users/me so the
 * session-cached user (and its expiring presigned `avatar_url`, TTL 1h) stays
 * fresh without a re-login. Rules:
 *  - success applies the fresh user and persists it;
 *  - failure is silent and never clobbers the existing user (a stale URL is
 *    cosmetic; the next trigger retries);
 *  - responses landing after the session changed mid-flight are dropped;
 *  - concurrent refreshes coalesce into one request via the shared cache.
 */
import { beforeEach, describe, expect, it, vi } from 'vitest'

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

vi.mock('@/components/ui/use-toast', () => ({
  toast: vi.fn(),
}))

vi.mock('@/lib/auth', () => ({
  setTokens: vi.fn(),
  resetForcedLogoutFlag: vi.fn(),
}))

import * as authApi from '@/api/auth'
import * as usersApi from '@/api/users'
import { clearRequestCache } from '@/lib/requestCache'
import { useAuthStore } from '@/stores/authStore'
import type { User } from '@/types'

const TOKEN_A = 'access-token-a'
const TOKEN_B = 'access-token-b'

const staleUser = {
  id: 'user-1',
  email: 'person@example.com',
  full_name: 'Old Name',
  avatar_url: 'https://expired.example.com/avatar.png',
  is_active: true,
  email_verified: true,
  created_at: '2026-01-01T00:00:00Z',
} as User

const freshUser = {
  ...staleUser,
  full_name: 'Fresh Name',
  avatar_url: 'https://fresh.example.com/avatar.png',
} as User

function seedSession(token: string = TOKEN_A) {
  useAuthStore.setState({
    user: staleUser,
    tokens: { access_token: token, refresh_token: 'refresh-token' },
    isAuthenticated: true,
    isLoading: false,
    error: null,
  })
}

beforeEach(() => {
  vi.clearAllMocks()
  localStorage.clear()
  clearRequestCache()
  useAuthStore.setState({
    user: null,
    tokens: null,
    isAuthenticated: false,
    isLoading: false,
    error: null,
  })
})

describe('authStore.refreshUser', () => {
  it('applies the fresh user and persists it', async () => {
    seedSession()
    vi.mocked(usersApi.getCurrentUser).mockResolvedValue(freshUser)

    await useAuthStore.getState().refreshUser()

    expect(usersApi.getCurrentUser).toHaveBeenCalledTimes(1)
    expect(useAuthStore.getState().user).toBe(freshUser)
    expect(authApi.storeUser).toHaveBeenCalledWith(freshUser)
  })

  it('keeps the existing user when the refresh fails', async () => {
    seedSession()
    vi.mocked(usersApi.getCurrentUser).mockRejectedValue(new Error('network down'))

    await expect(useAuthStore.getState().refreshUser()).resolves.toBeUndefined()

    expect(useAuthStore.getState().user).toBe(staleUser)
    expect(authApi.storeUser).not.toHaveBeenCalled()
  })

  it('is a no-op when not authenticated', async () => {
    await useAuthStore.getState().refreshUser()

    expect(usersApi.getCurrentUser).not.toHaveBeenCalled()
    expect(useAuthStore.getState().user).toBeNull()
  })

  it('drops the response when the session changes mid-flight', async () => {
    seedSession(TOKEN_A)
    let resolveRefresh!: (u: User) => void
    vi.mocked(usersApi.getCurrentUser).mockReturnValue(
      new Promise<User>((resolve) => {
        resolveRefresh = resolve
      })
    )

    const pending = useAuthStore.getState().refreshUser()
    // Session changes (logout / re-login) while the request is in flight.
    useAuthStore.setState({
      tokens: { access_token: TOKEN_B, refresh_token: 'refresh-token-2' },
    })
    resolveRefresh(freshUser)
    await pending

    expect(useAuthStore.getState().user).toBe(staleUser)
    expect(authApi.storeUser).not.toHaveBeenCalled()
  })

  it('coalesces concurrent refreshes into one /users/me request', async () => {
    seedSession()
    vi.mocked(usersApi.getCurrentUser).mockResolvedValue(freshUser)

    await Promise.all([
      useAuthStore.getState().refreshUser(),
      useAuthStore.getState().refreshUser(),
    ])

    expect(usersApi.getCurrentUser).toHaveBeenCalledTimes(1)
    expect(useAuthStore.getState().user).toBe(freshUser)
  })
})
