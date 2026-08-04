/**
 * Request coalescing + freshness cache.
 *
 * Why this exists:
 *   - React StrictMode (dev) runs mount effects twice; both invocations must
 *     share ONE network request.
 *   - Multiple components can legitimately request the same read (dashboard
 *     + wardrobe for /items, ReferralBanner + SubscriptionPanel for
 *     /referral/code); they must share one in-flight promise and reuse a
 *     fresh result instead of each hitting the network.
 *   - Route transitions re-mount pages that unconditionally refetch; a
 *     freshness window lets them reuse data that is still current.
 *
 * Design:
 *   - Keyed by a stable string; callers build the key from endpoint +
 *     query + user scope.
 *   - One in-flight promise per key. Concurrent callers receive the same
 *     promise; when it settles, the entry is converted to a cached result
 *     with a `updatedAt` timestamp.
 *   - Fresh reads (within `freshnessMs`) resolve from cache without a
 *     network call. `force` bypasses freshness and re-requests.
 *   - Failures remove the in-flight entry and never poison the cache.
 *   - `invalidate(key)` drops a cached result so the next read re-fetches
 *     (call after mutations).
 *   - `clearAll()` resets everything (call on logout / user switch).
 *
 * IMPORTANT: this caches the promise of the FETCH RESULT, not the state
 * mutations. Store actions that call `request()` must still apply the
 * response to their state when the promise resolves. Coalescing only
 * dedupes the wire request; it never skips store updates.
 */

import { logger } from '@/lib/logger'

interface CacheEntry<T> {
  promise: Promise<T>
  updatedAt: number
}

const inFlight = new Map<string, CacheEntry<unknown>>()
const cached = new Map<string, { value: unknown; updatedAt: number }>()
/**
 * Keys invalidated WHILE a request was in flight. The in-flight success
 * handler checks this set before caching: if the key is dirty, the response
 * is delivered to the current caller but NOT cached, so the next read
 * re-fetches instead of receiving pre-mutation data.
 */
const dirtyKeys = new Set<string>()

const DEFAULT_FRESHNESS_MS = 30_000

export interface RequestOptions {
  /** Re-request even when a fresh cached result exists. */
  force?: boolean
  /** Treat data younger than this as fresh (ms). Default 30s. */
  freshnessMs?: number
  /** Extra context for dev logging (e.g. which component requested). */
  label?: string
}

/**
 * Coalesce + cache a data fetch.
 *
 * @param key stable request identity (endpoint + query + user scope)
 * @param fetcher network call (runs at most once per key while in flight)
 * @param options force / freshness / label
 */
export async function request<T>(
  key: string,
  fetcher: () => Promise<T>,
  options: RequestOptions = {}
): Promise<T> {
  const { force = false, freshnessMs = DEFAULT_FRESHNESS_MS, label } = options

  // Fresh cache hit — no network.
  if (!force) {
    const hit = cached.get(key)
    if (hit && Date.now() - hit.updatedAt < freshnessMs) {
      if (import.meta.env.DEV) {
        logger.info(`[request-cache] fresh hit ${key}${label ? ` (${label})` : ''}`)
      }
      return hit.value as T
    }
  }

  // In-flight coalescing — share the pending promise.
  const pending = inFlight.get(key)
  if (pending) {
    if (import.meta.env.DEV) {
      logger.info(`[request-cache] coalesced ${key}${label ? ` (${label})` : ''}`)
    }
    return pending.promise as Promise<T>
  }

  if (import.meta.env.DEV) {
    logger.info(`[request-cache] network ${key}${force ? ' (force)' : ''}${label ? ` (${label})` : ''}`)
  }

  const promise = fetcher().then(
    (value) => {
      // Convert the in-flight entry into a cached result — UNLESS the key was
      // invalidated while this request was in flight (a mutation landed
      // between dispatch and resolution). In that case the response carries
      // pre-mutation data and must not poison the cache.
      inFlight.delete(key)
      if (dirtyKeys.has(key)) {
        dirtyKeys.delete(key)
      } else {
        cached.set(key, { value, updatedAt: Date.now() })
      }
      return value
    },
    (error: unknown) => {
      // Never cache failures; allow the next caller to retry.
      inFlight.delete(key)
      dirtyKeys.delete(key)
      throw error
    }
  )

  inFlight.set(key, { promise, updatedAt: Date.now() })
  return promise
}

/** Drop a cached result so the next read re-fetches (call after mutations).
 *  Also marks the key dirty so an in-flight request that resolves AFTER this
 *  call does not write pre-mutation data into the cache. */
export function invalidateRequest(key: string): void {
  if (import.meta.env.DEV) {
    logger.info(`[request-cache] invalidate ${key}`)
  }
  cached.delete(key)
  dirtyKeys.add(key)
}

/** Drop a cached result AND any in-flight promise (logout / user switch). */
export function cancelRequest(key: string): void {
  inFlight.delete(key)
  cached.delete(key)
  dirtyKeys.delete(key)
}

/** Reset the entire cache. Call on logout / auth user change. */
export function clearRequestCache(): void {
  inFlight.clear()
  cached.clear()
  dirtyKeys.clear()
  if (import.meta.env.DEV) {
    logger.info('[request-cache] cleared')
  }
}

/** Testing/diagnostic helpers. */
export const __requestCacheInternals = {
  inFlightCount: () => inFlight.size,
  cachedCount: () => cached.size,
  /** Visible only to tests/diagnostics, not production code paths. */
  debugSnapshot: () => ({
    inFlightKeys: [...inFlight.keys()],
    cachedKeys: [...cached.keys()],
  }),
}
