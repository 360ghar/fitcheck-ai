/**
 * A paid subscriber must always have a way to see and cancel what they pay for.
 *
 * The management branch was gated on `isPro && plans?.billing_configured !==
 * false`, which dropped existing paid subscribers into the FREE-user "card
 * payments are being set up" copy on any deployment without Stripe configured —
 * including everyone billed through the App Store / Play and every promo-code
 * upgrade — leaving no in-app path to view or cancel an active subscription.
 * `billing_configured` may gate the upgrade CTA and nothing else.
 *
 * Store-billed plans get their own treatment: the Stripe portal has no record of
 * them and `POST /subscription/cancel` cannot revoke a store entitlement, so
 * offering those controls would be a dead end.
 */
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'

const state: {
  isPro: boolean
  planName: string
  subscription: Record<string, unknown> | null
  plans: Record<string, unknown> | null
} = {
  isPro: true,
  planName: 'Pro',
  subscription: { plan_type: 'pro_monthly', cancel_at_period_end: false },
  plans: { plans: [], billing_configured: false },
}

const storeMock = {
  get subscription() {
    return state.subscription
  },
  usage: null,
  referralCode: null,
  referralStats: null,
  get plans() {
    return state.plans
  },
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
  clearPromo: vi.fn(() => {}),
}

vi.mock('@/stores/subscriptionStore', () => ({
  useSubscriptionStore: () => storeMock,
  usePlanName: () => state.planName,
  useIsPro: () => state.isPro,
  useIsProTier: () => state.isPro,
  useCanUpgrade: () => !state.isPro,
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

const SETUP_COPY = /Card payments are being set up/i

describe('SubscriptionPanel billing controls', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    state.isPro = true
    state.planName = 'Pro'
    state.subscription = { plan_type: 'pro_monthly', cancel_at_period_end: false }
    state.plans = { plans: [], billing_configured: false }
    localStorage.clear()
  })

  it('keeps management controls for a Stripe-billed Pro user when billing is unconfigured', () => {
    state.subscription = {
      plan_type: 'pro_monthly',
      cancel_at_period_end: false,
      billing_provider: 'stripe',
    }

    renderPanel()

    expect(screen.getByRole('button', { name: /Manage Billing/i })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /Cancel Subscription/i })).toBeInTheDocument()
    // The free-user setup copy must never be what a paying user sees.
    expect(screen.queryAllByText(SETUP_COPY)).toHaveLength(0)
  })

  it('points an Apple-billed subscriber at the App Store instead of the Stripe portal', () => {
    state.subscription = {
      plan_type: 'pro_monthly',
      cancel_at_period_end: false,
      billing_provider: 'apple',
    }

    renderPanel()

    expect(screen.getByText(/Billed through the App Store/i)).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: /Manage Billing/i })).toBeNull()
    expect(screen.queryByRole('button', { name: /Cancel Subscription/i })).toBeNull()
    expect(screen.queryAllByText(SETUP_COPY)).toHaveLength(0)
  })

  it('points a Google-billed subscriber at Google Play', () => {
    state.subscription = {
      plan_type: 'pro_monthly',
      cancel_at_period_end: false,
      billing_provider: 'google',
    }

    renderPanel()

    expect(screen.getByText(/Billed through Google Play/i)).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: /Manage Billing/i })).toBeNull()
  })

  it('still shows the unconfigured-billing notice to a FREE user', () => {
    // The copy is correct for its intended audience; only the audience was wrong.
    state.isPro = false
    state.planName = 'Free'
    state.subscription = { plan_type: 'free', cancel_at_period_end: false }

    renderPanel()

    // Free users see this notice in more than one place on the page.
    expect(screen.getAllByText(SETUP_COPY).length).toBeGreaterThan(0)
    expect(screen.queryByRole('button', { name: /Upgrade to Pro/i })).toBeNull()
  })

  it('offers the upgrade CTA to a free user once billing IS configured', () => {
    state.isPro = false
    state.planName = 'Free'
    state.subscription = { plan_type: 'free', cancel_at_period_end: false }
    state.plans = { plans: [], billing_configured: true }

    renderPanel()

    expect(screen.getByRole('button', { name: /Upgrade to Pro/i })).toBeInTheDocument()
    expect(screen.queryAllByText(SETUP_COPY)).toHaveLength(0)
  })
})
