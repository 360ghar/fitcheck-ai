/**
 * Locks in the RATE_LIMIT_EXCEEDED retry exclusion.
 *
 * A 429 carrying RATE_LIMIT_EXCEEDED is the user's OWN deterministic plan
 * limit (the backend raises it pre-flight), so it cannot clear within
 * seconds. Retrying it only multiplies duplicate requests and delays the
 * upgrade prompt; the interceptor in `api/client.ts` also skips it, so the
 * two retry layers must agree.
 */
import { describe, it, expect, vi } from 'vitest'
import { withRetry } from '@/lib/retry'

function axiosLikeError(status: number, code?: string) {
  return Object.assign(new Error(`Request failed with status code ${status}`), {
    isAxiosError: true,
    response: {
      status,
      data: code ? { code } : undefined,
    },
  })
}

describe('withRetry RATE_LIMIT_EXCEEDED handling', () => {
  it('does not retry a 429 that carries RATE_LIMIT_EXCEEDED', async () => {
    const fn = vi.fn().mockRejectedValue(axiosLikeError(429, 'RATE_LIMIT_EXCEEDED'))

    const result = await withRetry(fn, { maxRetries: 3, jitter: false })

    expect(result.success).toBe(false)
    expect(fn).toHaveBeenCalledTimes(1)
  })

  it('still retries a plain 429 (upstream capacity) up to the retry budget', async () => {
    const fn = vi
      .fn()
      .mockRejectedValueOnce(axiosLikeError(429))
      .mockResolvedValueOnce('ok')

    const result = await withRetry(fn, { maxRetries: 3, jitter: false, initialDelayMs: 1 })

    expect(result.success).toBe(true)
    expect(result.data).toBe('ok')
    expect(fn).toHaveBeenCalledTimes(2)
  })

  it('still retries 5xx errors', async () => {
    const fn = vi
      .fn()
      .mockRejectedValueOnce(axiosLikeError(503))
      .mockResolvedValueOnce('ok')

    const result = await withRetry(fn, { maxRetries: 3, jitter: false, initialDelayMs: 1 })

    expect(result.success).toBe(true)
    expect(fn).toHaveBeenCalledTimes(2)
  })
})
