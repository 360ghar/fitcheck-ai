import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import MockAdapter from 'axios-mock-adapter'
import axios from 'axios'

// Silence toast side-effects triggered by the error interceptor.
vi.mock('@/lib/toast-utils', () => ({
  showApiError: vi.fn(),
  showWarning: vi.fn(),
  showNetworkError: vi.fn(),
}))

// Import after mocks so the client picks them up.
import { apiClient, resetForcedLogoutFlag, setTokens } from '@/api/client'
// The toast helpers come from the mock above; importing them here lets the
// tests assert exactly how many times each fires for one logical failure.
import { showApiError, showWarning, showNetworkError } from '@/lib/toast-utils'

describe('apiClient retry logic', () => {
  let mock: MockAdapter
  let warnSpy: ReturnType<typeof vi.spyOn>
  let errorSpy: ReturnType<typeof vi.spyOn>

  beforeEach(() => {
    mock = new MockAdapter(apiClient)
    localStorage.clear()
    vi.useFakeTimers()
    vi.clearAllMocks()
    warnSpy = vi.spyOn(console, 'warn').mockImplementation(() => {})
    errorSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
  })

  afterEach(() => {
    mock.restore()
    vi.useRealTimers()
    warnSpy.mockRestore()
    errorSpy.mockRestore()
  })

  it('retries a 502 and resolves when a later attempt succeeds', async () => {
    mock
      .onGet('/flaky')
      .replyOnce(502)
      .onGet('/flaky')
      .replyOnce(502)
      .onGet('/flaky')
      .replyOnce(200, { ok: true })

    const promise = apiClient.get('/flaky')
    // Drain the two backoff timers (1s then 2s) plus their microtask chains.
    await vi.advanceTimersByTimeAsync(1000)
    await vi.advanceTimersByTimeAsync(2000)

    const res = await promise
    expect(res.status).toBe(200)
    expect(res.data).toEqual({ ok: true })
    // 1 initial + 2 retries
    expect(mock.history.get.length).toBe(3)
  })

  it('does not retry a 400 client error', async () => {
    mock.onGet('/bad').reply(400, { error: 'bad request' })

    const promise = apiClient.get('/bad').catch((e) => e)
    await vi.advanceTimersByTimeAsync(5000)

    const err = await promise
    expect(err.response?.status).toBe(400)
    expect(mock.history.get.length).toBe(1)
  })

  it('does not retry a 404 client error', async () => {
    mock.onGet('/missing').reply(404, { error: 'not found' })

    const promise = apiClient.get('/missing').catch((e) => e)
    await vi.advanceTimersByTimeAsync(5000)

    const err = await promise
    expect(err.response?.status).toBe(404)
    expect(mock.history.get.length).toBe(1)
  })

  it('stops after MAX_RETRIES (3 total attempts) for a persistent 500', async () => {
    mock.onGet('/down').reply(500, { error: 'boom' })

    const promise = apiClient.get('/down').catch((e) => e)
    await vi.advanceTimersByTimeAsync(1000)
    await vi.advanceTimersByTimeAsync(2000)
    await vi.advanceTimersByTimeAsync(4000)

    const err = await promise
    expect(err.response?.status).toBe(500)
    expect(mock.history.get.length).toBe(3)
  })

  it('retries a 429 then resolves', async () => {
    mock
      .onGet('/limited')
      .replyOnce(429)
      .onGet('/limited')
      .replyOnce(200, { ok: true })

    const promise = apiClient.get('/limited')
    await vi.advanceTimersByTimeAsync(1000)

    const res = await promise
    expect(res.status).toBe(200)
    expect(mock.history.get.length).toBe(2)
  })

  it('never retries auth endpoints even on a 500', async () => {
    mock.onPost('/api/v1/auth/login').reply(500, { error: 'boom' })

    const promise = apiClient.post('/api/v1/auth/login', {}).catch((e) => e)
    await vi.advanceTimersByTimeAsync(5000)

    const err = await promise
    expect(err.response?.status).toBe(500)
    expect(mock.history.post.length).toBe(1)
  })

  it('does not retry a BILLING_NOT_CONFIGURED 503 (permanent, not an outage)', async () => {
    // Stripe env vars are unset for this deployment, so /checkout and /portal
    // fail closed with a 503 that can never succeed on retry. 503 is otherwise
    // transient, so the interceptor used to burn 3 requests per click — the
    // burst seen in the 2026-08-05 logs. The distinct backend error_code is
    // what makes this permanent case distinguishable.
    mock
      .onPost('/api/v1/subscription/checkout')
      .reply(503, {
        error: 'Web billing is not available yet. Use a promo code to upgrade.',
        code: 'BILLING_NOT_CONFIGURED',
      })

    const promise = apiClient
      .post('/api/v1/subscription/checkout', {})
      .catch((e) => e)
    await vi.advanceTimersByTimeAsync(5000)

    const err = await promise
    expect(err.response?.status).toBe(503)
    // Exactly one attempt: no retry storm.
    expect(mock.history.post.length).toBe(1)
  })

  it('still retries a generic 503 with no billing code (real transient outage)', async () => {
    // Guards the fix above from over-reaching: an ordinary 503 must keep its
    // retry behavior.
    mock.onPost('/api/v1/subscription/checkout').reply(503, { error: 'upstream down' })

    const promise = apiClient
      .post('/api/v1/subscription/checkout', {})
      .catch((e) => e)
    await vi.advanceTimersByTimeAsync(1000)
    await vi.advanceTimersByTimeAsync(2000)
    await vi.advanceTimersByTimeAsync(4000)

    const err = await promise
    expect(err.response?.status).toBe(503)
    // 1 initial + 2 retries, unchanged.
    expect(mock.history.post.length).toBe(3)
  })
})

describe('apiClient global error toasts — one toast per logical failure', () => {
  let mock: MockAdapter
  let warnSpy: ReturnType<typeof vi.spyOn>
  let errorSpy: ReturnType<typeof vi.spyOn>

  beforeEach(() => {
    mock = new MockAdapter(apiClient)
    localStorage.clear()
    vi.useFakeTimers()
    vi.clearAllMocks()
    warnSpy = vi.spyOn(console, 'warn').mockImplementation(() => {})
    errorSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
  })

  afterEach(() => {
    mock.restore()
    vi.useRealTimers()
    warnSpy.mockRestore()
    errorSpy.mockRestore()
  })

  it('toasts exactly once when a retryable 500 exhausts all retries', async () => {
    mock.onGet('/down').reply(500, { error: 'boom' })

    const promise = apiClient.get('/down').catch((e) => e)
    await vi.advanceTimersByTimeAsync(1000)
    await vi.advanceTimersByTimeAsync(2000)
    await vi.advanceTimersByTimeAsync(4000)

    const err = await promise
    expect(err.response?.status).toBe(500)
    expect(mock.history.get.length).toBe(3)
    expect(showApiError).toHaveBeenCalledTimes(1)
  })

  it('does not toast when a retry succeeds', async () => {
    mock
      .onGet('/flaky')
      .replyOnce(502)
      .onGet('/flaky')
      .replyOnce(200, { ok: true })

    const promise = apiClient.get('/flaky')
    await vi.advanceTimersByTimeAsync(1000)

    const res = await promise
    expect(res.status).toBe(200)
    expect(showApiError).not.toHaveBeenCalled()
    expect(showWarning).not.toHaveBeenCalled()
    expect(showNetworkError).not.toHaveBeenCalled()
  })

  it('toasts a non-retryable client error exactly once', async () => {
    mock.onGet('/bad').reply(400, { error: 'bad request' })

    const promise = apiClient.get('/bad').catch((e) => e)
    await vi.advanceTimersByTimeAsync(5000)

    const err = await promise
    expect(err.response?.status).toBe(400)
    expect(showApiError).toHaveBeenCalledTimes(1)
  })

  it('toasts a persistent 429 as a rate-limit warning exactly once', async () => {
    mock.onGet('/limited').reply(429, { message: 'slow down' })

    const promise = apiClient.get('/limited').catch((e) => e)
    await vi.advanceTimersByTimeAsync(1000)
    await vi.advanceTimersByTimeAsync(2000)
    await vi.advanceTimersByTimeAsync(4000)

    const err = await promise
    expect(err.response?.status).toBe(429)
    expect(mock.history.get.length).toBe(3)
    expect(showWarning).toHaveBeenCalledTimes(1)
  })

  it('toasts a persistent network error exactly once', async () => {
    // axios-mock-adapter's networkError() has no request object, so the
    // retry interceptor treats it as non-transient here. The single-toast
    // guarantee is what this locks in regardless.
    mock.onGet('/net').networkError()

    const promise = apiClient.get('/net').catch((e) => e)
    await vi.advanceTimersByTimeAsync(1000)
    await vi.advanceTimersByTimeAsync(2000)
    await vi.advanceTimersByTimeAsync(4000)

    const err = await promise
    expect(err.response).toBeUndefined()
    expect(showNetworkError).toHaveBeenCalledTimes(1)
  })

  it('respects skipToast on an exhausted retryable error', async () => {
    mock.onGet('/down').reply(500, { error: 'boom' })

    const promise = apiClient.get('/down', { _skipToast: true }).catch((e) => e)
    await vi.advanceTimersByTimeAsync(1000)
    await vi.advanceTimersByTimeAsync(2000)
    await vi.advanceTimersByTimeAsync(4000)

    const err = await promise
    expect(err.response?.status).toBe(500)
    expect(mock.history.get.length).toBe(3)
    expect(showApiError).not.toHaveBeenCalled()
    expect(showWarning).not.toHaveBeenCalled()
    expect(showNetworkError).not.toHaveBeenCalled()
  })

  it('toasts a 5xx from an auth endpoint exactly once (no retry)', async () => {
    mock.onPost('/api/v1/auth/login').reply(500, { error: 'boom' })

    const promise = apiClient.post('/api/v1/auth/login', {}).catch((e) => e)
    await vi.advanceTimersByTimeAsync(5000)

    const err = await promise
    expect(err.response?.status).toBe(500)
    expect(mock.history.post.length).toBe(1)
    expect(showApiError).toHaveBeenCalledTimes(1)
  })

  it('opens the upgrade prompt (no toast) for a quota-exhausted 429', async () => {
    mock
      .onGet('/quota')
      .reply(429, { code: 'RATE_LIMIT_EXCEEDED', message: 'plan limit reached' })

    const promise = apiClient.get('/quota').catch((e) => e)
    await vi.advanceTimersByTimeAsync(5000)

    const err = await promise
    expect(err.response?.status).toBe(429)
    // Never retried, never toasted — surfaced by the upgrade prompt instead.
    expect(mock.history.get.length).toBe(1)
    expect(showApiError).not.toHaveBeenCalled()
    expect(showWarning).not.toHaveBeenCalled()
    expect(showNetworkError).not.toHaveBeenCalled()
  })

  it('does not transport-retry a request marked _skipTransportRetry', async () => {
    // withRetry-owned AI calls set _skipTransportRetry so the interceptor
    // does not multiply retry layers. A 500 must surface immediately (the
    // app-level retry loop handles it) and toast exactly once.
    mock.onGet('/ai-own-retry').reply(500, { error: 'boom' })

    const promise = apiClient
      .get('/ai-own-retry', { _skipTransportRetry: true } as never)
      .catch((e) => e)
    await vi.advanceTimersByTimeAsync(5000)

    const err = await promise
    expect(err.response?.status).toBe(500)
    expect(mock.history.get.length).toBe(1)
    expect(showApiError).toHaveBeenCalledTimes(1)
  })

  it('resolves same-origin relative URLs against the shared base (no /api/api)', async () => {
    // With VITE_API_BASE_URL unset, the client base is '' (same-origin), so
    // a request to '/api/v1/items' hits exactly that path.
    mock.onGet('/api/v1/items').reply(200, { ok: true })

    const res = await apiClient.get('/api/v1/items')
    expect(res.data).toEqual({ ok: true })
    // Exactly one request for the full path — no doubled prefix.
    expect(mock.history.get.length).toBe(1)
    expect(mock.history.get[0].url).toBe('/api/v1/items')
  })
})

describe('apiClient token-refresh failure latch — one refresh attempt per 401 burst', () => {
  let mock: MockAdapter
  let postSpy: ReturnType<typeof vi.fn>
  let warnSpy: ReturnType<typeof vi.spyOn>
  let errorSpy: ReturnType<typeof vi.spyOn>

  const makeToken = (expOffsetSeconds: number) => {
    const payload = btoa(
      JSON.stringify({ sub: 'u1', exp: Math.floor(Date.now() / 1000) + expOffsetSeconds })
    )
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=+$/, '')
    return `header.${payload}.sig`
  }

  beforeEach(() => {
    mock = new MockAdapter(apiClient)
    localStorage.clear()
    // forceLogout's hasForcedLogout is module state in lib/auth and leaks
    // between tests in this file; reset it so each scenario starts clean.
    resetForcedLogoutFlag()
    vi.useFakeTimers()
    vi.clearAllMocks()
    // The refresh call uses the RAW axios instance (not apiClient), so it is
    // mocked directly; the 401 responses come from the MockAdapter.
    postSpy = vi.spyOn(axios, 'post') as unknown as ReturnType<typeof vi.fn>
    warnSpy = vi.spyOn(console, 'warn').mockImplementation(() => {})
    errorSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
  })

  afterEach(() => {
    mock.restore()
    vi.useRealTimers()
    postSpy.mockRestore()
    warnSpy.mockRestore()
    errorSpy.mockRestore()
  })

  it('fires exactly one refresh attempt for a parallel 401 burst with a dead token', async () => {
    // Client-side expired token: the request interceptor's PROACTIVE refresh
    // fires first and fails; without the latch the first 401 handler would
    // re-present the same rotated-out token as a second refresh (observed
    // 2026-08-04: pairs of "Refresh token already used" 401s ~100-300ms
    // apart). The latch caps the whole burst at one refresh attempt.
    setTokens({
      access_token: makeToken(-3600),
      refresh_token: 'refresh-token-r1',
    })

    postSpy.mockRejectedValueOnce(
      Object.assign(new Error('Request failed with status code 401'), {
        response: { status: 401 },
      })
    )
    mock.onGet('/a').reply(401, {})
    mock.onGet('/b').reply(401, {})
    mock.onGet('/c').reply(401, {})

    const results = await Promise.allSettled([
      apiClient.get('/a'),
      apiClient.get('/b'),
      apiClient.get('/c'),
    ])

    expect(results.every((r) => r.status === 'rejected')).toBe(true)
    // ONE refresh attempt for the whole burst — not one per 401 handler.
    expect(postSpy).toHaveBeenCalledTimes(1)
  })

  it('allows refresh again after a fresh login issues a new refresh token', async () => {
    // First session: refresh is definitively rejected and latched. Token
    // strings are unique at runtime — the latch is module state and
    // correctly remembers a REJECTED token across calls, so a reused string
    // would fail fast by design.
    const deadRefresh = `refresh-token-${Date.now()}-dead`
    setTokens({
      access_token: makeToken(-3600),
      refresh_token: deadRefresh,
    })
    postSpy.mockRejectedValueOnce(
      Object.assign(new Error('Request failed with status code 401'), {
        response: { status: 401 },
      })
    )
    mock.onGet('/dead').reply(401, {})
    await apiClient.get('/dead').catch(() => {})
    expect(postSpy).toHaveBeenCalledTimes(1)

    // Second session: new refresh token -> the latch no longer matches, and
    // the refresh succeeds, so the 401'd request replays with the fresh token.
    resetForcedLogoutFlag()
    setTokens({
      // Keep the access token valid so this scenario exercises the 401
      // handler's refresh path, rather than proactive refresh first.
      access_token: makeToken(3600),
      refresh_token: `refresh-token-${Date.now()}-fresh`,
    })
    postSpy.mockResolvedValueOnce({
      data: {
        access_token: makeToken(3600),
        refresh_token: `refresh-token-${Date.now()}-rotated`,
      },
    })
    mock.onGet('/alive').replyOnce(401)
    mock.onGet('/alive').reply(200, { ok: true })

    const res = await apiClient.get('/alive')
    expect(res.data).toEqual({ ok: true })
    expect(postSpy).toHaveBeenCalledTimes(2)
  })
})
