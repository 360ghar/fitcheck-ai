import { renderToString } from 'react-dom/server'
import type { ReactNode } from 'react'
import { render, screen, waitFor } from '@testing-library/react'
import { beforeEach, describe, expect, it, vi } from 'vitest'

const noop = vi.fn()

function TestRouter({ children }: { children: ReactNode }) {
  return <>{children}</>
}

vi.mock('react-router-dom', () => ({
  Link: ({ children }: { children: ReactNode }) => <a>{children}</a>,
  useNavigate: () => noop,
}))

vi.mock('@/stores/wardrobeStore', () => ({
  useClosetStore: (selector: (state: Record<string, unknown>) => unknown) =>
    selector({
      items: [],
      fetchItems: noop,
      isLoading: false,
      error: null,
      totalItems: 0,
    }),
}))

vi.mock('@/stores/outfitStore', () => ({
  useOutfitStore: (selector: (state: Record<string, unknown>) => unknown) =>
    selector({
      outfits: [],
      fetchOutfits: noop,
      isLoading: false,
      error: null,
      totalOutfits: 0,
    }),
}))

vi.mock('@/stores/authStore', () => ({
  useCurrentUser: () => ({
    id: 'user-1',
    email: 'taylor@example.com',
    email_verified: true,
    full_name: 'Taylor',
  }),
  useUserAvatar: () => null,
  useUserDisplayName: () => 'Taylor',
}))

vi.mock('@/stores/subscriptionStore', () => ({
  useIsNearLimit: () => ({ extractions: false, generations: false }),
  useSubscriptionStore: (selector: (state: Record<string, unknown>) => unknown) =>
    selector({ fetchUsage: noop }),
}))

vi.mock('@/stores/jobUiStore', () => ({
  useJobUiStore: (selector: (state: Record<string, unknown>) => unknown) =>
    selector({ setJob: noop, clearJob: noop }),
}))

vi.mock('@/components/dashboard/ReferralBanner', () => ({
  ReferralBanner: () => <div data-testid="referral-banner">Referral</div>,
  useReferralBannerDismissal: () => ({ isDismissed: false, dismiss: noop }),
}))

vi.mock('@/components/dashboard/GiftPriorityCard', () => ({
  GiftPriorityCard: () => <div data-testid="gift-priority">Gift priority</div>,
  resolveGiftPriority: () => null,
}))

vi.mock('@/components/dashboard/ActivationChecklist', () => ({
  ActivationChecklist: () => <div />,
}))

vi.mock('@/components/dashboard/StatCard', () => ({
  StatCard: () => <div />,
}))

vi.mock('@/components/wardrobe/BatchExtractionFlow', () => ({
  BatchExtractionFlow: () => <div />,
}))

vi.mock('@/components/ui/button', () => ({
  Button: ({ children }: { children: React.ReactNode }) => <button>{children}</button>,
}))

vi.mock('@/components/ui/error-state', () => ({
  ErrorState: () => <div />,
}))

vi.mock('@/hooks/useImageWithFallback', () => ({
  thumbnailErrorFallback: () => noop,
}))

vi.mock('@/api/gifts', () => ({
  getGiftDashboardSummary: vi.fn(),
}))

vi.mock('@/lib/feature-flags', () => ({
  FEATURES: { gifts: true },
}))

import DashboardPage from '../DashboardPage'
import { getGiftDashboardSummary } from '@/api/gifts'

describe('DashboardPage gift priority', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('does not render referral before the initial gift summary resolves', () => {
    const markup = renderToString(
      <TestRouter>
        <DashboardPage />
      </TestRouter>,
    )

    expect(markup).not.toContain('referral-banner')
  })

  it('falls back to referral when the gift summary request fails', async () => {
    vi.mocked(getGiftDashboardSummary).mockRejectedValueOnce(new Error('summary unavailable'))

    render(
      <TestRouter>
        <DashboardPage />
      </TestRouter>,
    )

    expect(screen.queryByTestId('referral-banner')).not.toBeInTheDocument()
    await waitFor(() => expect(screen.getByTestId('referral-banner')).toBeInTheDocument())
  })
})
