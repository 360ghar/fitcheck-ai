/**
 * Promo code store actions: validate → redeem → subscription refresh.
 */
import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../../api/subscription', () => ({
  validatePromoCode: vi.fn(),
  redeemPromoCode: vi.fn(),
  getSubscription: vi.fn(),
}))

import { useSubscriptionStore } from '@/stores/subscriptionStore'
import * as subscriptionApi from '../../api/subscription'

describe('subscriptionStore promo actions', () => {
  beforeEach(() => {
    vi.clearAllMocks()
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
})
