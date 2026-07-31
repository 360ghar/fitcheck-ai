import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import MockAdapter from 'axios-mock-adapter'

// Silence toast side-effects triggered by the error interceptor.
vi.mock('@/lib/toast-utils', () => ({
  showApiError: vi.fn(),
  showWarning: vi.fn(),
  showNetworkError: vi.fn(),
}))

// Import after mocks so the client picks them up.
import { apiClient } from '@/api/client'
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
})
