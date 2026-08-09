/**
 * Tests for the worker-mode auth cookie + credential rules (lib/sessionCookie).
 *
 * The images Worker serves stable R2 URLs that require the app token; the web
 * presents it as the `sb-<ref>-auth-token` cookie (TD-068). These tests pin
 * the cookie write/clear behavior and the URL-based credential rules that keep
 * presigned R2 URLs credential-free (their bucket CORS policy has no
 * Access-Control-Allow-Credentials, so a credentialed fetch is rejected).
 */

import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import {
  authCookieName,
  setAuthSessionCookie,
  clearAuthSessionCookie,
  isOurImageHost,
  urlAcceptsCredentials,
  imageFetchOptions,
  imageCrossOrigin,
} from '../sessionCookie'
import { setTokens, clearTokens } from '../auth'

const REF = (import.meta.env.VITE_SUPABASE_URL || '').match(
  /^https:\/\/([a-z0-9]+)\.supabase\.co(?:\/|$)/i
)?.[1]?.toLowerCase()

function makeJwt(expSecondsFromNow: number): string {
  const header = btoa(JSON.stringify({ alg: 'HS256', typ: 'JWT' }))
    .replace(/=+$/, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
  const payload = btoa(
    JSON.stringify({ sub: 'u1', exp: Math.floor(Date.now() / 1000) + expSecondsFromNow })
  )
    .replace(/=+$/, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
  return `${header}.${payload}.signature`
}

describe('authCookieName', () => {
  it('derives the sb-<ref>-auth-token name from the Supabase URL', () => {
    if (!REF) return // env not loaded; nothing to pin
    expect(authCookieName()).toBe(`sb-${REF}-auth-token`)
  })

  it('returns null without a derivable project ref', () => {
    const env = import.meta.env as Record<string, unknown>
    const saved = env.VITE_SUPABASE_URL
    env.VITE_SUPABASE_URL = ''
    try {
      expect(authCookieName()).toBeNull()
    } finally {
      env.VITE_SUPABASE_URL = saved
    }
  })
})

describe('URL credential rules', () => {
  const workerUrl = 'https://images.fitcheckaiapp.com/u1/items/abc.webp'
  const presignedUrl =
    'https://acct.r2.cloudflarestorage.com/bucket/u1/items/abc.webp?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=deadbeef'
  const thirdParty = 'https://images.unsplash.com/photo-abc'

  it('recognizes only our own hosts as credential-eligible', () => {
    expect(isOurImageHost(workerUrl)).toBe(true)
    expect(isOurImageHost('https://www.fitcheckaiapp.com/x')).toBe(true)
    expect(isOurImageHost(presignedUrl)).toBe(false)
    expect(isOurImageHost(thirdParty)).toBe(false)
    expect(isOurImageHost('not a url')).toBe(false)
  })

  it('never attaches credentials to presigned or third-party URLs', () => {
    expect(urlAcceptsCredentials(workerUrl)).toBe(true)
    expect(urlAcceptsCredentials(presignedUrl)).toBe(false)
    expect(urlAcceptsCredentials(thirdParty)).toBe(false)
  })

  it('imageFetchOptions includes credentials only for worker-mode URLs', () => {
    expect(imageFetchOptions(workerUrl)).toEqual({ credentials: 'include' })
    expect(imageFetchOptions(presignedUrl)).toEqual({})
    expect(imageFetchOptions(thirdParty)).toEqual({})
  })

  it('imageCrossOrigin branches the same way', () => {
    expect(imageCrossOrigin(workerUrl)).toBe('use-credentials')
    expect(imageCrossOrigin(presignedUrl)).toBe('anonymous')
    expect(imageCrossOrigin('blob:mock-1')).toBe('anonymous')
  })
})

describe('cookie lifecycle', () => {
  let setCookieSpy: ReturnType<typeof vi.spyOn>

  beforeEach(() => {
    localStorage.clear()
    setCookieSpy = vi.spyOn(document, 'cookie', 'set')
  })

  afterEach(() => {
    setCookieSpy.mockRestore()
  })

  it('writes the token with a Max-Age derived from the exp claim', () => {
    if (!REF) return
    const token = makeJwt(7200)
    setAuthSessionCookie(token)

    expect(setCookieSpy).toHaveBeenCalledTimes(1)
    const [raw] = setCookieSpy.mock.calls[0] as [string]
    expect(raw).toContain(`sb-${REF}-auth-token=${token}`)
    expect(raw).toContain('SameSite=Lax')
    expect(raw).toContain('Path=/')
    const maxAge = Number(raw.match(/Max-Age=(\d+)/)?.[1])
    expect(maxAge).toBeGreaterThan(6800)
    expect(maxAge).toBeLessThanOrEqual(7200)
  })

  it('floors the lifetime at 60s for a token expiring sooner', () => {
    if (!REF) return
    setAuthSessionCookie(makeJwt(10))
    const [raw] = setCookieSpy.mock.calls[0] as [string]
    expect(raw).toMatch(/Max-Age=60/)
  })

  it('expires the cookie on clear', () => {
    if (!REF) return
    clearAuthSessionCookie()
    const [raw] = setCookieSpy.mock.calls[0] as [string]
    expect(raw).toContain(`sb-${REF}-auth-token=;`)
    expect(raw).toContain('Max-Age=0')
  })

  it('setTokens/clearTokens keep the cookie in sync with the token store', () => {
    if (!REF) return
    const token = makeJwt(3600)
    setTokens({ access_token: token, refresh_token: 'rt' })
    expect(setCookieSpy).toHaveBeenCalledTimes(1)
    const [raw] = setCookieSpy.mock.calls[0] as [string]
    expect(raw).toContain(`sb-${REF}-auth-token=${token}`)

    setCookieSpy.mockClear()
    clearTokens()
    expect(setCookieSpy).toHaveBeenCalledTimes(1)
    const [cleared] = setCookieSpy.mock.calls[0] as [string]
    expect(cleared).toContain(`sb-${REF}-auth-token=;`)
    expect(localStorage.getItem('fitcheck_auth_tokens')).toBeNull()
  })
})
