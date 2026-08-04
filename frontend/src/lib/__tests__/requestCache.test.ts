/**
 * Tests for the shared request coalescing + freshness cache (lib/requestCache).
 */

import { describe, it, expect, beforeEach, vi, afterEach } from 'vitest'
import {
  request,
  invalidateRequest,
  cancelRequest,
  clearRequestCache,
  __requestCacheInternals,
} from '../requestCache'

describe('requestCache', () => {
  beforeEach(() => {
    clearRequestCache()
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.useRealTimers()
    clearRequestCache()
  })

  it('runs the network once for concurrent callers of the same key', async () => {
    let resolveFetch: (v: string) => void = () => {}
    const fetchSpy = vi.fn(
      () =>
        new Promise<string>((resolve) => {
          resolveFetch = resolve
        })
    )

    const p1 = request('key-1', fetchSpy)
    const p2 = request('key-1', fetchSpy)

    expect(fetchSpy).toHaveBeenCalledTimes(1)
    expect(__requestCacheInternals.inFlightCount()).toBe(1)

    resolveFetch('data')
    await expect(p1).resolves.toBe('data')
    await expect(p2).resolves.toBe('data')

    expect(fetchSpy).toHaveBeenCalledTimes(1)
    expect(__requestCacheInternals.inFlightCount()).toBe(0)
  })

  it('serves a fresh cached result without hitting the network again', async () => {
    const fetchSpy = vi.fn(async () => 'v1')
    await request('key-2', fetchSpy)
    await request('key-2', fetchSpy)

    expect(fetchSpy).toHaveBeenCalledTimes(1)
  })

  it('re-fetches when force is set', async () => {
    const fetchSpy = vi.fn(async () => 'v1')
    await request('key-3', fetchSpy)
    await request('key-3', fetchSpy, { force: true })

    expect(fetchSpy).toHaveBeenCalledTimes(2)
  })

  it('re-fetches after the freshness window expires', async () => {
    const fetchSpy = vi.fn(async () => 'v1')
    await request('key-4', fetchSpy, { freshnessMs: 10_000 })

    vi.advanceTimersByTime(10_001)
    await request('key-4', fetchSpy, { freshnessMs: 10_000 })

    expect(fetchSpy).toHaveBeenCalledTimes(2)
  })

  it('does not cache failures and allows a retry', async () => {
    const fetchSpy = vi
      .fn()
      .mockRejectedValueOnce(new Error('boom'))
      .mockResolvedValueOnce('ok')

    await expect(request('key-5', fetchSpy)).rejects.toThrow('boom')
    await expect(request('key-5', fetchSpy)).resolves.toBe('ok')

    expect(fetchSpy).toHaveBeenCalledTimes(2)
  })

  it('invalidate drops the cached value so the next read re-fetches', async () => {
    const fetchSpy = vi.fn(async () => 'v1')
    await request('key-6', fetchSpy)
    invalidateRequest('key-6')
    await request('key-6', fetchSpy)

    expect(fetchSpy).toHaveBeenCalledTimes(2)
  })

  it('clearAll resets both in-flight and cached entries (logout / user switch)', async () => {
    const fetchSpy = vi.fn(async () => 'v1')
    await request('key-7', fetchSpy)
    clearRequestCache()
    await request('key-7', fetchSpy)

    expect(fetchSpy).toHaveBeenCalledTimes(2)
    expect(__requestCacheInternals.inFlightCount()).toBe(0)
    expect(__requestCacheInternals.cachedCount()).toBe(1)
  })

  it('cancelRequest drops a pending in-flight entry', () => {
    let resolveFetch: (v: string) => void = () => {}
    const fetchSpy = vi.fn(
      () =>
        new Promise<string>((resolve) => {
          resolveFetch = resolve
        })
    )

    const p = request('key-8', fetchSpy)
    cancelRequest('key-8')
    expect(__requestCacheInternals.inFlightCount()).toBe(0)

    resolveFetch('data')
    return expect(p).resolves.toBe('data')
  })

  it('scopes keys: different keys do not share promises', async () => {
    const fetchSpy = vi.fn(async (v: string) => v)
    const p1 = request('a', () => fetchSpy('a'))
    const p2 = request('b', () => fetchSpy('b'))

    await expect(p1).resolves.toBe('a')
    await expect(p2).resolves.toBe('b')
    expect(fetchSpy).toHaveBeenCalledTimes(2)
  })

  it('does not cache an in-flight result that was invalidated mid-flight', async () => {
    // Simulates: fetchItems() starts → deleteItem() invalidates → fetchItems()
    // resolves with pre-delete data. The stale response must NOT be cached.
    let resolveFetch: (v: string) => void = () => {}
    const fetchSpy = vi.fn(
      () =>
        new Promise<string>((resolve) => {
          resolveFetch = resolve
        })
    )

    const p1 = request('race-key', fetchSpy)

    // While the request is in flight, a mutation invalidates the key.
    invalidateRequest('race-key')

    // The in-flight request completes with pre-mutation data.
    resolveFetch('stale-data')
    await p1

    // The stale response was delivered to p1 but NOT cached, so the next
    // read re-fetches from the network.
    const fetchSpy2 = vi.fn(async () => 'fresh-data')
    const result = await request('race-key', fetchSpy2)
    expect(result).toBe('fresh-data')
    expect(fetchSpy2).toHaveBeenCalledTimes(1)
  })
})
