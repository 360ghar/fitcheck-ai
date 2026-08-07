/**
 * ProfilePage responsive contracts.
 *
 * Mobile (<md) presents sections as full-screen subpages with a back bar (iOS
 * Settings pattern) over a root section list; desktop (≥md) keeps the tab
 * strip with inline panels. jsdom ships no `matchMedia`, so the guard in
 * `useMediaQuery` renders the MOBILE layout by default — the desktop tests
 * stub `matchMedia` explicitly. Tailwind classes are not evaluated in jsdom,
 * so layout state is asserted structurally (presence) and via `hidden` class
 * on the known wrappers, matching the repo's other responsive-contract tests.
 */
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { render, screen, waitFor, act } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter, useLocation } from 'react-router-dom'
import ProfilePage from '../ProfilePage'

const h = vi.hoisted(() => ({
  user: {
    id: 'u1',
    full_name: 'Test User',
    email: 'test@fitcheck.ai',
    gender: null,
    birth_date: null,
    birth_time: null,
    birth_place: null,
  },
  logout: vi.fn(),
  setUser: vi.fn(),
  getCurrentUser: vi.fn(),
  updateCurrentUser: vi.fn(),
  uploadAvatar: vi.fn(),
  getUserPreferences: vi.fn(),
  updateUserPreferences: vi.fn(),
  getUserSettings: vi.fn(),
  updateUserSettings: vi.fn(),
  requestPasswordReset: vi.fn(),
  deleteAccount: vi.fn(),
}))

vi.mock('@/stores/authStore', () => ({
  useAuthStore: (selector: (state: Record<string, unknown>) => unknown) =>
    selector({ logout: h.logout, setUser: h.setUser }),
  useCurrentUser: () => h.user,
  useUserDisplayName: () => h.user.full_name,
  useUserAvatar: () => null,
}))

vi.mock('@/api/users', () => ({
  getCurrentUser: h.getCurrentUser,
  updateCurrentUser: h.updateCurrentUser,
  uploadAvatar: h.uploadAvatar,
  getUserPreferences: h.getUserPreferences,
  updateUserPreferences: h.updateUserPreferences,
  getUserSettings: h.getUserSettings,
  updateUserSettings: h.updateUserSettings,
  deleteAccount: h.deleteAccount,
}))

vi.mock('@/api/auth', () => ({
  requestPasswordReset: h.requestPasswordReset,
}))

vi.mock('@/components/ui/use-toast', () => ({
  useToast: () => ({ toast: vi.fn() }),
}))

const subscriptionActions = vi.hoisted(() => ({
  fetchSubscription: vi.fn(async () => {}),
  fetchReferralCode: vi.fn(async () => {}),
  fetchReferralStats: vi.fn(async () => {}),
  fetchPlans: vi.fn(async () => {}),
}))

vi.mock('@/stores/subscriptionStore', () => ({
  useSubscriptionStore: () => ({
    subscription: null,
    usage: null,
    referralCode: null,
    referralStats: null,
    plans: null,
    isLoading: false,
    isCheckingOut: false,
    error: null,
    promoValidation: null,
    isPromoValidating: false,
    isRedeemingPromo: false,
    promoError: null,
    fetchSubscription: subscriptionActions.fetchSubscription,
    fetchReferralCode: subscriptionActions.fetchReferralCode,
    fetchReferralStats: subscriptionActions.fetchReferralStats,
    fetchPlans: subscriptionActions.fetchPlans,
    startCheckout: vi.fn(async () => {}),
    openBillingPortal: vi.fn(async () => {}),
    cancelSubscription: vi.fn(async () => {}),
    copyReferralLink: vi.fn(async () => true),
    validatePromo: vi.fn(async () => null),
    redeemPromo: vi.fn(async () => null),
    clearPromo: vi.fn(() => {}),
  }),
  usePlanName: () => 'Free',
  useIsPro: () => false,
  useIsProTier: () => false,
  useCanUpgrade: () => true,
  useIsNearLimit: () => ({ extractions: false, generations: false }),
}))

const EMPTY_PREFS = {
  favorite_colors: [],
  preferred_styles: [],
  preferred_occasions: [],
  liked_brands: [],
  disliked_patterns: [],
  color_temperature: '',
  style_personality: '',
}

let scrollToMock: ReturnType<typeof vi.fn>

function renderPage(initialEntry = '/profile') {
  return render(
    <MemoryRouter initialEntries={[initialEntry]}>
      <ProfilePage />
    </MemoryRouter>
  )
}

/** Location probe so tests can assert the router URL after pushes/pops. */
function LocationProbe() {
  const location = useLocation()
  return <div data-testid="location">{location.pathname}{location.search}</div>
}

function renderPageWithProbe(initialEntry = '/profile') {
  return render(
    <MemoryRouter initialEntries={[initialEntry]}>
      <LocationProbe />
      <ProfilePage />
    </MemoryRouter>
  )
}

/** Desktop viewport: `useMediaQuery` sees a real `matchMedia` matching ≥md. */
function stubMatchMedia() {
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    configurable: true,
    value: vi.fn().mockImplementation((query: string) => ({
      matches: true,
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })),
  })
}

beforeEach(() => {
  vi.clearAllMocks()
  scrollToMock = vi.fn()
  Object.defineProperty(window, 'scrollTo', { writable: true, configurable: true, value: scrollToMock })
})

afterEach(() => {
  // Restore the no-matchMedia jsdom state so the next test renders mobile.
  // @ts-expect-error - jsdom has no matchMedia; only the desktop test stubs it.
  delete window.matchMedia
})

describe('ProfilePage mobile drill-down (<md, no matchMedia)', () => {
  it('renders the section-list root: hero, five rows, and sign out — no inline form', () => {
    renderPage()

    expect(screen.getByRole('heading', { name: 'Profile & Settings' })).toBeInTheDocument()
    // Avatar hero
    expect(screen.getByText('Test User')).toBeInTheDocument()
    // Section list (drill-down index)
    expect(screen.getByRole('navigation', { name: 'Profile sections' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /^Account/ })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /^Style/ })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /^App/ })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /^Plan/ })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /^Help/ })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Sign Out' })).toBeInTheDocument()
    // No back bar, no inline account form (the container is CSS-hidden).
    expect(screen.queryByRole('button', { name: 'Back to profile settings' })).toBeNull()
    expect(screen.getByLabelText('Full Name').closest('div.px-4')).toHaveClass('hidden')
    // The desktop tab strip stays mounted but is CSS-hidden below md.
    expect(screen.getByRole('tablist').parentElement).toHaveClass('hidden', 'md:block')
  })

  it('opens the Style subpage from a row and the back bar returns to the root', async () => {
    const user = userEvent.setup()
    h.getUserPreferences.mockResolvedValue(EMPTY_PREFS)
    renderPage()

    await user.click(screen.getByRole('button', { name: /^Style/ }))

    // Subpage chrome: back bar with the section title; list unmounted.
    expect(screen.getByRole('button', { name: 'Back to profile settings' })).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Style' })).toBeInTheDocument()
    expect(screen.queryByRole('navigation', { name: 'Profile sections' })).toBeNull()
    // Preferences panel is mounted and visible.
    expect(await screen.findByRole('heading', { name: 'Style Preferences' })).toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: 'Back to profile settings' }))

    // Root is back; the panel stays mounted (hidden) so unsaved edits survive.
    expect(screen.getByRole('heading', { name: 'Profile & Settings' })).toBeInTheDocument()
    expect(screen.getByRole('navigation', { name: 'Profile sections' })).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Style Preferences' }).closest('div.space-y-4')?.parentElement).toHaveClass('hidden')
  })

  it('drills into the Account subpage and back', async () => {
    const user = userEvent.setup()
    renderPage()

    await user.click(screen.getByRole('button', { name: /^Account/ }))

    expect(screen.getByRole('button', { name: 'Back to profile settings' })).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Account' })).toBeInTheDocument()
    // The profile form is the subpage content now — container no longer hidden.
    expect(screen.getByLabelText('Full Name').closest('div.px-4')).not.toHaveClass('hidden')
    expect(screen.queryByRole('navigation', { name: 'Profile sections' })).toBeNull()

    await user.click(screen.getByRole('button', { name: 'Back to profile settings' }))

    expect(screen.getByRole('navigation', { name: 'Profile sections' })).toBeInTheDocument()
    expect(screen.getByLabelText('Full Name').closest('div.px-4')).toHaveClass('hidden')
  })

  it('renders a deep-linked subpage directly and resets to the root on back', async () => {
    const user = userEvent.setup()
    h.getUserPreferences.mockResolvedValue(EMPTY_PREFS)
    renderPage('/profile?tab=style')

    // Deep link lands on the Style subpage, not the root.
    expect(screen.getByRole('button', { name: 'Back to profile settings' })).toBeInTheDocument()
    expect(await screen.findByRole('heading', { name: 'Style Preferences' })).toBeInTheDocument()

    // No pushed history entry exists, so back resets state instead of popping.
    await user.click(screen.getByRole('button', { name: 'Back to profile settings' }))
    expect(screen.getByRole('navigation', { name: 'Profile sections' })).toBeInTheDocument()
  })

  it('pushes a ?tab= entry when a subpage opens and pops it on back', async () => {
    const user = userEvent.setup()
    h.getUserPreferences.mockResolvedValue(EMPTY_PREFS)
    renderPageWithProbe()

    await user.click(screen.getByRole('button', { name: /^Style/ }))
    await waitFor(() => expect(screen.getByTestId('location')).toHaveTextContent('/profile?tab=style'))

    await user.click(screen.getByRole('button', { name: 'Back to profile settings' }))
    await waitFor(() => expect(screen.getByTestId('location')).toHaveTextContent('/profile?tab=account'))
  })

  it('scrolls to the top when opening a section', async () => {
    const user = userEvent.setup()
    renderPage()

    await user.click(screen.getByRole('button', { name: /^Style/ }))
    expect(scrollToMock).toHaveBeenCalledWith(0, 0)
  })

  it('clears the account drill when the URL resolves to another section (rotation)', async () => {
    const user = userEvent.setup()
    h.getUserPreferences.mockResolvedValue(EMPTY_PREFS)
    let mediaListener: ((e: { matches: boolean }) => void) | null = null
    Object.defineProperty(window, 'matchMedia', {
      writable: true,
      configurable: true,
      value: vi.fn().mockImplementation((query: string) => ({
        matches: false,
        media: query,
        onchange: null,
        addEventListener: (_event: string, cb: (e: { matches: boolean }) => void) => {
          mediaListener = cb
        },
        removeEventListener: vi.fn(),
        addListener: vi.fn(),
        removeListener: vi.fn(),
        dispatchEvent: vi.fn(),
      })),
    })
    renderPage()

    // Mobile: drill into the Account subpage.
    await user.click(screen.getByRole('button', { name: /^Account/ }))
    expect(screen.getByRole('heading', { name: 'Account' })).toBeInTheDocument()

    // Rotate to desktop: the strip appears; click the Style tab.
    act(() => mediaListener?.({ matches: true }))
    await user.click(screen.getByRole('tab', { name: /Style/ }))

    // Rotate back to mobile: the subpage must be STYLE (title + content agree),
    // not the stale account drill.
    act(() => mediaListener?.({ matches: false }))
    expect(screen.getByRole('button', { name: 'Back to profile settings' })).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Style' })).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Style Preferences' })).toBeInTheDocument()
    expect(screen.queryByLabelText('Full Name')).toBeNull()
    // Cleanup so later tests keep the no-matchMedia mobile default.
    // @ts-expect-error - jsdom has no matchMedia; the afterEach restores it.
    delete window.matchMedia
  })

  it('does not resurrect Stripe ack params when navigating sections', async () => {
    const user = userEvent.setup()
    renderPageWithProbe('/profile?tab=plan&success=true')

    // Plan subpage (SubscriptionPanel mounts with the mocked store).
    expect(screen.getByRole('heading', { name: 'Plan' })).toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: 'Back to profile settings' }))
    await waitFor(() => expect(screen.getByTestId('location')).toHaveTextContent('/profile?tab=account'))
    // The ack param must not come back with the rewritten URL.
    expect(screen.getByTestId('location').textContent).not.toContain('success')
  })

  it('refetches plan data each time the plan section becomes active again', async () => {
    const user = userEvent.setup()
    renderPage()

    await user.click(screen.getByRole('button', { name: /^Plan/ }))
    expect(subscriptionActions.fetchSubscription).toHaveBeenCalledTimes(1)

    await user.click(screen.getByRole('button', { name: 'Back to profile settings' }))
    await user.click(screen.getByRole('button', { name: /^Plan/ }))
    expect(subscriptionActions.fetchSubscription).toHaveBeenCalledTimes(2)
  })

  it('moves focus to the back button on open and restores it to the row on close', async () => {
    const user = userEvent.setup()
    h.getUserPreferences.mockResolvedValue(EMPTY_PREFS)
    renderPage()

    await user.click(screen.getByRole('button', { name: /^Style/ }))
    expect(screen.getByRole('button', { name: 'Back to profile settings' })).toHaveFocus()

    await user.click(screen.getByRole('button', { name: 'Back to profile settings' }))
    expect(screen.getByRole('button', { name: /^Style/ })).toHaveFocus()
  })

  it('closes the subpage with Escape', async () => {
    const user = userEvent.setup()
    h.getUserPreferences.mockResolvedValue(EMPTY_PREFS)
    renderPage()

    await user.click(screen.getByRole('button', { name: /^Style/ }))
    await user.keyboard('{Escape}')

    expect(screen.getByRole('navigation', { name: 'Profile sections' })).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Back to profile settings' })).toBeNull()
  })

  it('normalizes a legacy deep link to its section', async () => {
    renderPageWithProbe('/profile?tab=subscription')

    expect(screen.getByRole('button', { name: 'Back to profile settings' })).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Plan' })).toBeInTheDocument()
    await waitFor(() => expect(screen.getByTestId('location')).toHaveTextContent('/profile?tab=plan'))
  })

  it('does not scroll on mount, and scrolls to top on open and close', async () => {
    const user = userEvent.setup()
    h.getUserPreferences.mockResolvedValue(EMPTY_PREFS)
    renderPage()

    expect(scrollToMock).not.toHaveBeenCalled()

    await user.click(screen.getByRole('button', { name: /^Style/ }))
    expect(scrollToMock).toHaveBeenCalledTimes(1)

    await user.click(screen.getByRole('button', { name: 'Back to profile settings' }))
    expect(scrollToMock).toHaveBeenCalledTimes(2)
  })

  it('preserves unrelated query params through subpage push and back', async () => {
    const user = userEvent.setup()
    h.getUserPreferences.mockResolvedValue(EMPTY_PREFS)
    renderPageWithProbe('/profile?promo=SAVE20')

    await user.click(screen.getByRole('button', { name: /^Style/ }))
    await waitFor(() => expect(screen.getByTestId('location')).toHaveTextContent('/profile?promo=SAVE20&tab=style'))

    await user.click(screen.getByRole('button', { name: 'Back to profile settings' }))
    await waitFor(() => expect(screen.getByTestId('location')).toHaveTextContent('/profile?promo=SAVE20&tab=account'))
  })
})

describe('ProfilePage desktop layout (≥md, matchMedia stubbed)', () => {
  it('renders the tab strip with inline account content and no section list', () => {
    stubMatchMedia()
    renderPage()

    // Tab strip is the desktop surface: CSS contract hides it below md and
    // shows it at md+, and the account tab is selected by default.
    expect(screen.getByRole('tablist').parentElement).toHaveClass('hidden', 'md:block')
    expect(screen.getByRole('tab', { name: /Account/ })).toHaveAttribute('aria-selected', 'true')
    // Inline account form, no back bar, no section list.
    expect(screen.getByLabelText('Full Name').closest('div.px-4')).not.toHaveClass('hidden')
    expect(screen.queryByRole('button', { name: 'Back to profile settings' })).toBeNull()
    expect(screen.queryByRole('navigation', { name: 'Profile sections' })).toBeNull()
    expect(screen.getByRole('button', { name: 'Sign Out' })).toBeInTheDocument()
  })

  it('switches panels inline when a tab is clicked', async () => {
    const user = userEvent.setup()
    stubMatchMedia()
    h.getUserPreferences.mockResolvedValue(EMPTY_PREFS)
    renderPage()

    await user.click(screen.getByRole('tab', { name: /Style/ }))
    expect(await screen.findByRole('heading', { name: 'Style Preferences' })).toBeInTheDocument()
    // No back bar appears on desktop.
    expect(screen.queryByRole('button', { name: 'Back to profile settings' })).toBeNull()
  })
})
