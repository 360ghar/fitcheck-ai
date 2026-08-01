/**
 * Promo code UI on the plan page (SubscriptionPanel):
 * - the input card is only shown to free users,
 * - a valid code flips the card into a redeemable banner,
 * - redemption calls the store action with the entered code.
 */
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import type { ValidatePromoResponse } from '@/types'

// Scripted store module: the panel reads these values at render time, so the
// tests mutate `storeMock` between renders and re-render to see the change.
const storeMock: {
  [key: string]: unknown
  subscription: { plan_type: string } | null
  usage: unknown
  referralCode: unknown
  referralStats: unknown
  plans: unknown
  isLoading: boolean
  isCheckingOut: boolean
  error: unknown
  promoValidation: ValidatePromoResponse | null
  isPromoValidating: boolean
  isRedeemingPromo: boolean
  promoError: string | null
  fetchSubscription: ReturnType<typeof vi.fn>
  fetchReferralCode: ReturnType<typeof vi.fn>
  fetchReferralStats: ReturnType<typeof vi.fn>
  fetchPlans: ReturnType<typeof vi.fn>
  startCheckout: ReturnType<typeof vi.fn>
  openBillingPortal: ReturnType<typeof vi.fn>
  cancelSubscription: ReturnType<typeof vi.fn>
  copyReferralLink: ReturnType<typeof vi.fn>
  validatePromo: ReturnType<typeof vi.fn>
  redeemPromo: ReturnType<typeof vi.fn>
  clearPromo: ReturnType<typeof vi.fn>
} = {
  subscription: { plan_type: 'free' },
  usage: null,
  referralCode: null,
  referralStats: null,
  plans: { plans: [] },
  isLoading: false,
  isCheckingOut: false,
  error: null,
  promoValidation: null,
  isPromoValidating: false,
  isRedeemingPromo: false,
  promoError: null,
  fetchSubscription: vi.fn(async () => {}),
  fetchReferralCode: vi.fn(async () => {}),
  fetchReferralStats: vi.fn(async () => {}),
  fetchPlans: vi.fn(async () => {}),
  startCheckout: vi.fn(async () => {}),
  openBillingPortal: vi.fn(async () => {}),
  cancelSubscription: vi.fn(async () => {}),
  copyReferralLink: vi.fn(async () => true),
  validatePromo: vi.fn(async () => null),
  redeemPromo: vi.fn(async () => null),
  clearPromo: vi.fn(() => {
    storeMock.promoValidation = null
    storeMock.promoError = null
  }),
}

vi.mock('@/stores/subscriptionStore', () => ({
  useSubscriptionStore: () => storeMock,
  usePlanName: () => 'Free',
  useIsPro: () => false,
  useIsProTier: () => false,
  useCanUpgrade: () => true,
  useIsNearLimit: () => ({ extractions: false, generations: false }),
}))

vi.mock('@/components/ui/use-toast', () => ({
  useToast: () => ({ toast: vi.fn() }),
}))

import { SubscriptionPanel } from '@/components/settings/SubscriptionPanel'

function renderPanel() {
  return render(
    <MemoryRouter initialEntries={['/profile?tab=plan']}>
      <SubscriptionPanel />
    </MemoryRouter>
  )
}

describe('SubscriptionPanel promo code', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    storeMock.promoValidation = null
    storeMock.isPromoValidating = false
    storeMock.isRedeemingPromo = false
    storeMock.promoError = null
    localStorage.clear()
  })

  it('shows the promo code input to free users', () => {
    renderPanel()

    expect(screen.getByText('Have a promo code?')).toBeInTheDocument()
    expect(screen.getByLabelText('Promo code')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Apply' })).toBeInTheDocument()
  })

  it('validates the entered code and shows a redeemable banner', async () => {
    const { rerender } = renderPanel()

    fireEvent.change(screen.getByLabelText('Promo code'), {
      target: { value: 'LAUNCH30' },
    })
    fireEvent.click(screen.getByRole('button', { name: 'Apply' }))

    await waitFor(() => {
      expect(storeMock.validatePromo).toHaveBeenCalledWith('LAUNCH30')
    })

    storeMock.promoValidation = {
      valid: true,
      plan_type: 'pro_monthly',
      months: 1,
      plan_name: 'Pro',
      message: 'Get Pro free for 1 month!',
    }
    rerender(
      <MemoryRouter initialEntries={['/profile?tab=plan']}>
        <SubscriptionPanel />
      </MemoryRouter>
    )

    expect(screen.getByText('Get Pro free for 1 month!')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Get Pro free' })).toBeInTheDocument()
  })

  it('redeems with the entered code', async () => {
    const { rerender } = renderPanel()

    // Type the code into the input, then the validation result flips the card
    // into the redeemable banner (mirrors the real flow).
    fireEvent.change(screen.getByLabelText('Promo code'), {
      target: { value: 'PLUS3' },
    })
    storeMock.promoValidation = {
      valid: true,
      plan_type: 'plus_monthly',
      months: 3,
      plan_name: 'Plus',
      message: 'Get Plus free for 3 months!',
    }
    rerender(
      <MemoryRouter initialEntries={['/profile?tab=plan']}>
        <SubscriptionPanel />
      </MemoryRouter>
    )

    fireEvent.click(screen.getByRole('button', { name: 'Get Plus free' }))

    await waitFor(() => {
      expect(storeMock.redeemPromo).toHaveBeenCalledWith('PLUS3')
    })
  })

  it('shows the server rejection message inline', () => {
    storeMock.promoValidation = {
      valid: false,
      plan_type: null,
      months: 0,
      message: 'This promo code has expired',
    }
    renderPanel()

    expect(screen.getByText('This promo code has expired')).toBeInTheDocument()
    // No redeem banner for an invalid code.
    expect(screen.queryByText(/Get .* free/)).not.toBeInTheDocument()
  })
})
