import { beforeEach, describe, expect, it, vi } from 'vitest'

vi.mock('@/lib/auth', () => ({
  getAccessToken: () => 'user-1',
}))

import { request, clearRequestCache, __requestCacheInternals } from '@/lib/requestCache'
import { invalidateUsageCache } from '@/stores/subscriptionStore'

describe('invalidateUsageCache (F1-10)', () => {
  beforeEach(() => {
    clearRequestCache()
  })

  it('drops only the current user\'s cached usage read', async () => {
    // Prime the cache exactly like the store's subKey() would.
    const fetcher = vi.fn().mockResolvedValue({ used_today: 1 })
    await request('subscription:usage:user-1', fetcher)
    await request('subscription:subscription:user-1', fetcher)
    await request('subscription:usage:user-2', fetcher)
    await request('referral:code:user-1', fetcher)

    invalidateUsageCache()

    const { cachedKeys } = __requestCacheInternals.debugSnapshot()
    // The quota read for THIS user is gone; everything else survives.
    expect(cachedKeys).not.toContain('subscription:usage:user-1')
    expect(cachedKeys).toContain('subscription:subscription:user-1')
    expect(cachedKeys).toContain('subscription:usage:user-2')
    expect(cachedKeys).toContain('referral:code:user-1')
  })
})
