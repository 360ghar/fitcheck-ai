/**
 * Promo code store actions: validate → redeem → subscription refresh.
 */
import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../../api/subscription', () => ({
  validatePromoCode: vi.fn(),
  redeemPromoCode: vi.fn(),
  getSubscription: vi.fn(),
  getUsage: vi.fn(),
  getReferralCode: vi.fn(),
  getReferralStats: vi.fn(),
  getPlans: vi.fn(),
}))

import { useSubscriptionStore } from '@/stores/subscriptionStore'
import { clearRequestCache } from '@/lib/requestCache'
import * as subscriptionApi from '../../api/subscription'
import type { ReferralCode } from '@/types'

describe('subscriptionStore promo actions', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    // Reset the shared request cache so cached reads do not leak between tests.
    clearRequestCache()
    useSubscriptionStore.getState().reset()
  })

  it('stores a valid promo validation result', async () => {
    vi.mocked(subscriptionApi.validatePromoCode).mockResolvedValue({
      valid: true,
      plan_type: 'pro_monthly',
      months: 1,
      plan_name: 'Pro',
      message: 'Get Pro free for 1 month!',
      share_url: 'https://fitcheckaiapp.com/auth/register?promo=launch30',
    })

    const result = await useSubscriptionStore.getState().validatePromo('LAUNCH30')

    expect(result?.valid).toBe(true)
    const state = useSubscriptionStore.getState()
    expect(state.promoValidation?.plan_name).toBe('Pro')
    expect(state.isPromoValidating).toBe(false)
    expect(state.promoError).toBeNull()
  })

  it('surfaces API errors during validation', async () => {
    vi.mocked(subscriptionApi.validatePromoCode).mockRejectedValue(new Error('Network down'))

    const result = await useSubscriptionStore.getState().validatePromo('CODE')

    expect(result).toBeNull()
    const state = useSubscriptionStore.getState()
    expect(state.promoError).toContain('Network down')
  })

  it('redeems a promo and refreshes the subscription on success', async () => {
    vi.mocked(subscriptionApi.redeemPromoCode).mockResolvedValue({
      success: true,
      message: 'Promo code applied',
      plan_type: 'pro_monthly',
      months: 1,
    })
    vi.mocked(subscriptionApi.getSubscription).mockResolvedValue({
      subscription: { plan_type: 'pro_monthly' } as never,
      usage: null,
    } as never)

    const result = await useSubscriptionStore.getState().redeemPromo('LAUNCH30')

    expect(result?.success).toBe(true)
    expect(subscriptionApi.getSubscription).toHaveBeenCalledOnce()
    const state = useSubscriptionStore.getState()
    expect(state.promoValidation).toBeNull()
    expect(state.isRedeemingPromo).toBe(false)
    expect(state.subscription?.plan_type).toBe('pro_monthly')
  })

  it('keeps the server rejection message as the inline promo error', async () => {
    vi.mocked(subscriptionApi.redeemPromoCode).mockResolvedValue({
      success: false,
      message: 'This promo code has expired',
      plan_type: null,
      months: 0,
    })

    const result = await useSubscriptionStore.getState().redeemPromo('OLD')

    expect(result?.success).toBe(false)
    const state = useSubscriptionStore.getState()
    expect(state.promoError).toBe('This promo code has expired')
    // No subscription refresh on a rejected redemption.
    expect(subscriptionApi.getSubscription).not.toHaveBeenCalled()
  })

  it('coalesces concurrent referral-code reads into one API call', async () => {
    let resolveFetch: (value: ReferralCode) => void = () => {}
    vi.mocked(subscriptionApi.getReferralCode).mockImplementation(
      () =>
        new Promise<ReferralCode>((resolve) => {
          resolveFetch = resolve
        })
    )

    // ReferralBanner + SubscriptionPanel can both request the code on mount.
    const p1 = useSubscriptionStore.getState().fetchReferralCode()
    const p2 = useSubscriptionStore.getState().fetchReferralCode()
    expect(subscriptionApi.getReferralCode).toHaveBeenCalledTimes(1)

    resolveFetch({ code: 'SHARE', share_url: 'https://fitcheckaiapp.com/r/SHARE', times_used: 0, created_at: '2026-01-01T00:00:00.000Z' })
    await Promise.all([p1, p2])

    expect(subscriptionApi.getReferralCode).toHaveBeenCalledTimes(1)
    expect(useSubscriptionStore.getState().referralCode?.share_url).toContain('SHARE')
  })

  it('reuses a fresh cached referral code instead of re-fetching', async () => {
    vi.mocked(subscriptionApi.getReferralCode).mockResolvedValue({
      code: 'SHARE',
      share_url: 'https://fitcheckaiapp.com/r/SHARE',
      times_used: 0,
      created_at: '2026-01-01T00:00:00.000Z',
    })

    await useSubscriptionStore.getState().fetchReferralCode()
    await useSubscriptionStore.getState().fetchReferralCode()

    expect(subscriptionApi.getReferralCode).toHaveBeenCalledTimes(1)
  })

  it('a subscription mutation invalidates the cache so the next read re-fetches', async () => {
    vi.mocked(subscriptionApi.getSubscription).mockResolvedValue({
      subscription: { plan_type: 'free' } as never,
      usage: null,
    } as never)

    await useSubscriptionStore.getState().fetchSubscription()
    // Entitlement-changing mutation (e.g. cancel) drops the cached read.
    useSubscriptionStore.getState().reset()
    await useSubscriptionStore.getState().fetchSubscription()

    expect(subscriptionApi.getSubscription).toHaveBeenCalledTimes(2)
  })
})
