import { waitFor } from '@testing-library/react'
import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it } from 'vitest'

import { useSessionStore } from './sessionStore'

import { apiGet } from '@/shared/api/client'
import { clearTokens, getTokens, setTokens } from '@/shared/api/tokens'
import type { MeResponse } from '@/shared/api/types'
import { server } from '@/test/msw/server'

beforeEach(() => {
  clearTokens()
  useSessionStore.setState({
    status: 'loading',
    user: null,
    role: null,
    permissions: [],
    permissionDenied: false,
    error: null,
    idleSince: Date.now(),
    lastLogoutReason: null,
  })
})

describe('sessionStore.bootstrap', () => {
  it('returns anon without tokens and never calls the API', async () => {
    const result = await useSessionStore.getState().bootstrap()
    expect(result).toBe('anon')
    expect(useSessionStore.getState().status).toBe('anon')
  })

  it('bootstraps authed from a valid token', async () => {
    setTokens({ access_token: 't', refresh_token: 'r' })
    const result = await useSessionStore.getState().bootstrap()
    expect(result).toBe('authed')
    const state = useSessionStore.getState()
    expect(state.status).toBe('authed')
    expect(state.role).toBe('super_admin')
    expect(state.permissions).toEqual(['*'])
    expect(state.user?.email).toBe('admin@fitcheckaiapp.com')
  })

  it('returns forbidden on 403, flags permissionDenied, clears tokens', async () => {
    server.use(
      http.get('*/api/v1/admin/me', () =>
        HttpResponse.json(
          { error: 'Forbidden', code: 'PERMISSION_DENIED', details: {} },
          { status: 403 },
        ),
      ),
    )
    setTokens({ access_token: 't', refresh_token: 'r' })
    const result = await useSessionStore.getState().bootstrap()
    expect(result).toBe('forbidden')
    expect(useSessionStore.getState().status).toBe('anon')
    expect(useSessionStore.getState().permissionDenied).toBe(true)
    expect(getTokens()).toBeNull()
  })

  it('returns anon on 401 and clears tokens', async () => {
    server.use(
      http.get('*/api/v1/admin/me', () =>
        HttpResponse.json(
          { error: 'Unauthorized', code: 'AUTH_UNAUTHORIZED', details: {} },
          { status: 401 },
        ),
      ),
    )
    setTokens({ access_token: 't', refresh_token: 'r' })
    const result = await useSessionStore.getState().bootstrap()
    expect(result).toBe('anon')
    expect(useSessionStore.getState().permissionDenied).toBe(false)
    expect(getTokens()).toBeNull()
  })
})

describe('sessionStore.login', () => {
  it('stores tokens and bootstraps on success', async () => {
    const result = await useSessionStore.getState().login('admin@fitcheckaiapp.com', 'correct-horse')
    expect(result).toBe('authed')
    expect(getTokens()?.access_token).toBe('test-access-token')
    expect(useSessionStore.getState().status).toBe('authed')
    expect(useSessionStore.getState().role).toBe('super_admin')
  })

  it('rejects with a typed ApiError on invalid credentials', async () => {
    await expect(
      useSessionStore.getState().login('admin@fitcheckaiapp.com', 'wrong-password'),
    ).rejects.toMatchObject({ code: 'AUTH_INVALID_CREDENTIALS', status: 401 })
    expect(useSessionStore.getState().status).toBe('anon')
    expect(getTokens()).toBeNull()
  })

  it('rejects PERMISSION_DENIED when /me 403s after a successful login', async () => {
    server.use(
      http.get('*/api/v1/admin/me', () =>
        HttpResponse.json(
          { error: 'Forbidden', code: 'PERMISSION_DENIED', details: {} },
          { status: 403 },
        ),
      ),
    )
    await expect(
      useSessionStore.getState().login('admin@fitcheckaiapp.com', 'correct-horse'),
    ).rejects.toMatchObject({ code: 'PERMISSION_DENIED', status: 403 })
    expect(useSessionStore.getState().permissionDenied).toBe(true)
    expect(getTokens()).toBeNull()
  })

  it('rejects when /me 404s after a successful login (surfaces the bootstrap error)', async () => {
    server.use(
      http.get('*/api/v1/admin/me', () =>
        HttpResponse.json(
          { error: 'Not Found', code: 'HTTP_ERROR', details: {}, correlation_id: 'me-404-cid' },
          { status: 404 },
        ),
      ),
    )
    await expect(
      useSessionStore.getState().login('admin@fitcheckaiapp.com', 'correct-horse'),
    ).rejects.toMatchObject({ code: 'HTTP_ERROR', status: 404, correlationId: 'me-404-cid' })
    expect(useSessionStore.getState().status).toBe('anon')
    expect(useSessionStore.getState().permissionDenied).toBe(false)
    expect(getTokens()).toBeNull()
  })

  it('rejects with a client-side INTERNAL_ERROR when the envelope carries no tokens', async () => {
    server.use(
      http.post('*/api/v1/auth/login', () =>
        HttpResponse.json({ data: {}, message: 'OK' }, { status: 200 }),
      ),
    )
    await expect(
      useSessionStore.getState().login('admin@fitcheckaiapp.com', 'correct-horse'),
    ).rejects.toMatchObject({ code: 'INTERNAL_ERROR', status: 0 })
    expect(useSessionStore.getState().status).toBe('anon')
    expect(getTokens()).toBeNull()
  })

  it('rejects with the ACCOUNT_SUSPENDED ApiError when /me 401s after a successful login', async () => {
    server.use(
      http.get('*/api/v1/admin/me', () =>
        HttpResponse.json(
          { error: 'Account is suspended', code: 'ACCOUNT_SUSPENDED', details: {} },
          { status: 401 },
        ),
      ),
    )
    await expect(
      useSessionStore.getState().login('admin@fitcheckaiapp.com', 'correct-horse'),
    ).rejects.toMatchObject({ code: 'ACCOUNT_SUSPENDED', status: 401 })
    expect(useSessionStore.getState().status).toBe('anon')
    expect(useSessionStore.getState().permissionDenied).toBe(false)
    expect(useSessionStore.getState().error?.code).toBe('ACCOUNT_SUSPENDED')
    expect(getTokens()).toBeNull()
  })

  it('rejects with the ApiError when /me 5xxs after a successful login (no silent loop)', async () => {
    server.use(
      http.get('*/api/v1/admin/me', () =>
        HttpResponse.json(
          { error: 'Internal Server Error', code: 'INTERNAL_ERROR', details: {} },
          { status: 500 },
        ),
      ),
    )
    await expect(
      useSessionStore.getState().login('admin@fitcheckaiapp.com', 'correct-horse'),
    ).rejects.toMatchObject({ code: 'INTERNAL_ERROR', status: 500 })
    expect(useSessionStore.getState().status).toBe('anon')
    expect(useSessionStore.getState().permissionDenied).toBe(false)
    expect(useSessionStore.getState().error?.code).toBe('INTERNAL_ERROR')
    expect(getTokens()).toBeNull()
  })

  it('rejects with a client-side NETWORK_ERROR when /me is unreachable after login', async () => {
    server.use(http.get('*/api/v1/admin/me', () => HttpResponse.error()))
    await expect(
      useSessionStore.getState().login('admin@fitcheckaiapp.com', 'correct-horse'),
    ).rejects.toMatchObject({ code: 'NETWORK_ERROR', status: 0 })
    expect(useSessionStore.getState().status).toBe('anon')
    expect(useSessionStore.getState().error?.code).toBe('NETWORK_ERROR')
  })
})

describe('sessionStore unauthorized event', () => {
  it('logs out with reason unauthorized when session:unauthorized fires', () => {
    setTokens({ access_token: 't', refresh_token: 'r' })
    useSessionStore.setState({
      status: 'authed',
      user: null,
      role: 'super_admin',
      permissions: ['*'],
    })
    window.dispatchEvent(new CustomEvent('session:unauthorized'))
    const state = useSessionStore.getState()
    expect(state.status).toBe('anon')
    expect(state.lastLogoutReason).toBe('unauthorized')
    expect(getTokens()).toBeNull()
  })
})

describe('sessionStore silent token refresh', () => {
  it('bootstraps authed after a 401 + successful refresh (retries /me)', async () => {
    let meCalls = 0
    server.use(
      http.get('*/api/v1/admin/me', ({ request }) => {
        meCalls += 1
        const auth = request.headers.get('authorization')
        if (meCalls === 1) {
          expect(auth).toBe('Bearer stale-token')
          return HttpResponse.json(
            { error: 'Unauthorized', code: 'AUTH_UNAUTHORIZED', details: {} },
            { status: 401 },
          )
        }
        expect(auth).toBe('Bearer refreshed-access-token')
        return HttpResponse.json({
          user: {
            id: 'admin_1',
            email: 'admin@fitcheckaiapp.com',
            full_name: 'Ada Admin',
            avatar_url: null,
            is_active: true,
            role: 'super_admin',
            created_at: '2026-01-01T00:00:00Z',
            last_login_at: '2026-08-01T00:00:00Z',
          },
          role: 'super_admin',
          permissions: ['*'],
        })
      }),
    )
    setTokens({ access_token: 'stale-token', refresh_token: 'valid-refresh-token' })

    const result = await useSessionStore.getState().bootstrap()

    expect(result).toBe('authed')
    expect(useSessionStore.getState().status).toBe('authed')
    expect(useSessionStore.getState().role).toBe('super_admin')
    expect(meCalls).toBe(2)
    expect(getTokens()?.access_token).toBe('refreshed-access-token')
  })

  it('logs out with reason unauthorized + session-expired error when refresh fails', async () => {
    server.use(
      http.get('*/api/v1/admin/me', () =>
        HttpResponse.json(
          { error: 'Unauthorized', code: 'AUTH_UNAUTHORIZED', details: {} },
          { status: 401 },
        ),
      ),
      http.post('*/api/v1/auth/refresh', () =>
        HttpResponse.json(
          { error: 'Invalid or expired refresh token', code: 'AUTH_TOKEN_EXPIRED', details: {} },
          { status: 401 },
        ),
      ),
    )
    setTokens({ access_token: 'stale-token', refresh_token: 'dead-refresh-token' })

    const result = await useSessionStore.getState().bootstrap()

    expect(result).toBe('anon')
    expect(useSessionStore.getState().status).toBe('anon')
    expect(useSessionStore.getState().lastLogoutReason).toBe('unauthorized')
    expect(useSessionStore.getState().error?.code).toBe('AUTH_UNAUTHORIZED')
    expect(getTokens()).toBeNull()
  })

  it('keeps an in-session user authed across a mid-flight refresh', async () => {
    let meCalls = 0
    server.use(
      http.get('*/api/v1/admin/me', ({ request }) => {
        meCalls += 1
        if (request.headers.get('authorization') === 'Bearer refreshed-access-token') {
          return HttpResponse.json({
            user: {
              id: 'admin_1',
              email: 'admin@fitcheckaiapp.com',
              full_name: 'Ada Admin',
              avatar_url: null,
              is_active: true,
              role: 'ops',
              created_at: '2026-01-01T00:00:00Z',
              last_login_at: '2026-08-01T00:00:00Z',
            },
            role: 'ops',
            permissions: ['users.read'],
          })
        }
        return HttpResponse.json(
          { error: 'Unauthorized', code: 'AUTH_UNAUTHORIZED', details: {} },
          { status: 401 },
        )
      }),
    )
    setTokens({ access_token: 'stale-token', refresh_token: 'valid-refresh-token' })
    useSessionStore.setState({
      status: 'authed',
      user: null,
      role: 'super_admin',
      permissions: ['*'],
    })

    await expect(apiGet<MeResponse>('/api/v1/admin/me')).resolves.toMatchObject({
      role: 'ops',
    })

    // The refresh must not have torn the session down.
    expect(useSessionStore.getState().status).toBe('authed')
    expect(useSessionStore.getState().lastLogoutReason).toBeNull()
    expect(getTokens()?.access_token).toBe('refreshed-access-token')
    expect(meCalls).toBe(2) // original 401 + single retry with the fresh token
  })
})

describe('sessionStore.logout', () => {
  it('clears state and tokens, records the reason', () => {
    setTokens({ access_token: 't', refresh_token: 'r' })
    useSessionStore.setState({
      status: 'authed',
      user: null,
      role: 'ops',
      permissions: ['users.view'],
    })
    useSessionStore.getState().logout('idle')
    const state = useSessionStore.getState()
    expect(state.status).toBe('anon')
    expect(state.lastLogoutReason).toBe('idle')
    expect(state.permissions).toEqual([])
    expect(getTokens()).toBeNull()
  })

  it('revocation call carries refresh_token + Bearer access token captured BEFORE clearing', async () => {
    let capturedBody: { refresh_token?: string } | null = null
    let capturedAuth: string | null = null
    server.use(
      http.post('*/api/v1/auth/logout', async ({ request }) => {
        capturedBody = (await request.json()) as { refresh_token?: string }
        capturedAuth = request.headers.get('authorization')
        return new HttpResponse(null, { status: 204 })
      }),
    )
    setTokens({ access_token: 'access-123', refresh_token: 'refresh-456' })
    useSessionStore.setState({
      status: 'authed',
      user: null,
      role: 'ops',
      permissions: ['users.view'],
    })

    useSessionStore.getState().logout('manual')

    // The request must carry the token snapshot taken before the store
    // cleared them — by request time local tokens are already gone, so a
    // post-clear getTokens() implementation would send neither header nor
    // body values.
    await waitFor(() => {
      expect(capturedBody?.refresh_token).toBe('refresh-456')
      expect(capturedAuth).toBe('Bearer access-123')
    })
    expect(useSessionStore.getState().status).toBe('anon')
    expect(useSessionStore.getState().lastLogoutReason).toBe('manual')
    expect(getTokens()).toBeNull()
  })

  it('skips the revocation call entirely when there are no tokens to revoke', async () => {
    let logoutCalls = 0
    server.use(
      http.post('*/api/v1/auth/logout', () => {
        logoutCalls += 1
        return new HttpResponse(null, { status: 204 })
      }),
    )
    useSessionStore.getState().logout('manual')
    await new Promise((resolve) => setTimeout(resolve, 10))
    expect(logoutCalls).toBe(0)
  })

  it('touch updates idleSince only while authed', () => {
    useSessionStore.setState({ status: 'authed', idleSince: 1000 })
    useSessionStore.getState().touch()
    expect(useSessionStore.getState().idleSince).toBeGreaterThan(1000)
    useSessionStore.setState({ status: 'anon', idleSince: 1000 })
    useSessionStore.getState().touch()
    expect(useSessionStore.getState().idleSince).toBe(1000)
  })
})
