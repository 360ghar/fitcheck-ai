import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { apiGet, refreshAccessToken } from './client'

import { clearTokens, getTokens, setTokens } from '@/shared/api/tokens'
import type { MeResponse } from '@/shared/api/types'
import { server } from '@/test/msw/server'

/**
 * Silent token refresh (spec §4 hardening): a 401 on a non-auth endpoint
 * must refresh the token once (single-flight) and retry the original
 * request exactly once — never loop, never fire multiple refreshes.
 */

const mePayload: MeResponse = {
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
}

function unauthorized() {
  return HttpResponse.json(
    { error: 'Unauthorized', code: 'AUTH_UNAUTHORIZED', details: {} },
    { status: 401 },
  )
}

function refreshOk() {
  return HttpResponse.json({
    data: {
      access_token: 'refreshed-access-token',
      refresh_token: 'refreshed-refresh-token',
      user: { id: 'admin_1', email: 'admin@fitcheckaiapp.com' },
    },
    message: 'OK',
  })
}

beforeEach(() => {
  clearTokens()
})

describe('client silent token refresh', () => {
  it('refreshes and retries the original request once with the new token', async () => {
    let meCalls = 0
    server.use(
      http.get('*/api/v1/admin/me', ({ request }) => {
        meCalls += 1
        const auth = request.headers.get('authorization')
        if (meCalls === 1) {
          expect(auth).toBe('Bearer stale-access-token')
          return unauthorized()
        }
        // The retry must carry the REFRESHED token.
        expect(auth).toBe('Bearer refreshed-access-token')
        return HttpResponse.json(mePayload)
      }),
    )
    setTokens({ access_token: 'stale-access-token', refresh_token: 'valid-refresh-token' })

    const result = await apiGet<MeResponse>('/api/v1/admin/me')

    expect(meCalls).toBe(2)
    expect(result.role).toBe('super_admin')
    expect(getTokens()?.access_token).toBe('refreshed-access-token')
    expect(getTokens()?.refresh_token).toBe('refreshed-refresh-token')
  })

  it('dispatches session:unauthorized and never loops when the refreshed request still 401s', async () => {
    let meCalls = 0
    let refreshCalls = 0
    server.use(
      http.get('*/api/v1/admin/me', () => {
        meCalls += 1
        return unauthorized()
      }),
      http.post('*/api/v1/auth/refresh', () => {
        refreshCalls += 1
        return refreshOk()
      }),
    )
    const unauthorizedSpy = vi.fn()
    window.addEventListener('session:unauthorized', unauthorizedSpy)
    setTokens({ access_token: 'stale-access-token', refresh_token: 'valid-refresh-token' })

    await expect(apiGet<MeResponse>('/api/v1/admin/me')).rejects.toMatchObject({ status: 401 })

    // Original request + exactly one retry; exactly one refresh; the retried
    // 401 is terminal (no second refresh, no second retry).
    expect(meCalls).toBe(2)
    expect(refreshCalls).toBe(1)
    expect(unauthorizedSpy).toHaveBeenCalledTimes(1)
    window.removeEventListener('session:unauthorized', unauthorizedSpy)
  })

  it('single-flights concurrent 401s: one refresh, every request retried with the new token', async () => {
    let meCalls = 0
    let refreshCalls = 0
    server.use(
      http.get('*/api/v1/admin/me', ({ request }) => {
        meCalls += 1
        if (request.headers.get('authorization') === 'Bearer refreshed-access-token') {
          return HttpResponse.json(mePayload)
        }
        return unauthorized()
      }),
      http.post('*/api/v1/auth/refresh', () => {
        refreshCalls += 1
        return refreshOk()
      }),
    )
    setTokens({ access_token: 'stale-access-token', refresh_token: 'valid-refresh-token' })

    const results = await Promise.all([
      apiGet<MeResponse>('/api/v1/admin/me'),
      apiGet<MeResponse>('/api/v1/admin/me'),
      apiGet<MeResponse>('/api/v1/admin/me'),
    ])

    expect(refreshCalls).toBe(1)
    expect(meCalls).toBe(6) // 3 original + 3 retries
    expect(results.every((result) => result.role === 'super_admin')).toBe(true)
  })

  it('fails fast after the server rejects the refresh token (no repeat refresh)', async () => {
    let refreshCalls = 0
    server.use(
      http.get('*/api/v1/admin/me', () => unauthorized()),
      http.post('*/api/v1/auth/refresh', () => {
        refreshCalls += 1
        return HttpResponse.json(
          { error: 'Invalid or expired refresh token', code: 'AUTH_TOKEN_EXPIRED', details: {} },
          { status: 401 },
        )
      }),
    )
    setTokens({ access_token: 'stale-access-token', refresh_token: 'dead-refresh-token' })

    await expect(apiGet<MeResponse>('/api/v1/admin/me')).rejects.toMatchObject({ status: 401 })
    await expect(apiGet<MeResponse>('/api/v1/admin/me')).rejects.toMatchObject({ status: 401 })

    // The second burst must NOT re-present the latched dead token.
    expect(refreshCalls).toBe(1)
  })

  it('does not refresh without a stored refresh token', async () => {
    let refreshCalls = 0
    server.use(
      http.get('*/api/v1/admin/me', () => unauthorized()),
      http.post('*/api/v1/auth/refresh', () => {
        refreshCalls += 1
        return refreshOk()
      }),
    )
    const unauthorizedSpy = vi.fn()
    window.addEventListener('session:unauthorized', unauthorizedSpy)
    // No tokens at all — the client has nothing to refresh with.
    await expect(apiGet<MeResponse>('/api/v1/admin/me')).rejects.toMatchObject({ status: 401 })

    expect(refreshCalls).toBe(0)
    expect(unauthorizedSpy).toHaveBeenCalledTimes(1)
    window.removeEventListener('session:unauthorized', unauthorizedSpy)
  })

  it('refreshAccessToken resolves false for a malformed refresh envelope', async () => {
    server.use(
      http.post('*/api/v1/auth/refresh', () =>
        HttpResponse.json({ data: { access_token: 'only-access' }, message: 'OK' }),
      ),
    )
    setTokens({ access_token: 'stale', refresh_token: 'valid-refresh-token' })
    await expect(refreshAccessToken()).resolves.toBe(false)
    // Tokens must NOT be overwritten with a partial envelope.
    expect(getTokens()?.access_token).toBe('stale')
  })
})
