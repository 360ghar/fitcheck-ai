/**
 * Profile/Settings Page
 *
 * Layout/wiring shell for the settings surface. Owns the cross-panel state
 * (active tab + URL sync, the profile-information editing form) and composes
 * the extracted sections:
 *   - AvatarSection        (avatar display + upload)
 *   - PreferencesPanel     (Style tab)
 *   - AppSettingsPanel     (App tab)
 *   - SecurityPanel        (Account tab — password reset + delete account)
 *   - SubscriptionPanel    (Plan tab)
 *   - SupportPanel         (Help tab)
 */

import { useCallback, useEffect, useRef, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { useAuthStore, useCurrentUser } from '../../stores/authStore'
import {
  ChevronLeft,
  ChevronRight,
  CreditCard,
  Mail,
  MessageSquarePlus,
  Palette,
  Settings2,
  User,
} from 'lucide-react'
import { useToast } from '@/components/ui/use-toast'
import { Button } from '@/components/ui/button'
import { ScrollableTabs, ScrollableTab } from '@/components/ui/scrollable-tabs'
import { getCurrentUser, updateCurrentUser } from '@/api/users'
import { SubscriptionPanel, SupportPanel } from '@/components/settings'
import { AvatarSection } from './AvatarSection'
import { PreferencesPanel } from './PreferencesPanel'
import { AppSettingsPanel } from './AppSettingsPanel'
import { SecurityPanel } from './SecurityPanel'
import { useIsSplitViewport } from '@/hooks/useMediaQuery'
import { cn } from '@/lib/utils'

/** Grouped settings IA (legacy ?tab= values still resolve). */
type TabType = 'account' | 'style' | 'app' | 'plan' | 'help'

const LEGACY_TAB_MAP: Record<string, TabType> = {
  account: 'account',
  style: 'style',
  app: 'app',
  plan: 'plan',
  help: 'help',
  profile: 'account',
  security: 'account',
  preferences: 'style',
  settings: 'app',
  ai: 'app',
  subscription: 'plan',
  support: 'help',
}

function normalizeBirthTimeForInput(value?: string | null): string {
  if (!value) return ''
  return value.length >= 5 ? value.slice(0, 5) : value
}

function normalizeBirthTimeForApi(value: string): string | undefined {
  const trimmed = value.trim()
  if (!trimmed) return undefined
  if (trimmed.length === 5) return `${trimmed}:00`
  return trimmed
}

function resolveTab(value: string | null): TabType {
  if (!value) return 'account'
  return LEGACY_TAB_MAP[value] ?? 'account'
}

/** Copy params minus the one-shot Stripe ack keys (SubscriptionPanel strips them via history.replaceState). */
function nextSearchParams(params: URLSearchParams): URLSearchParams {
  const next = new URLSearchParams(params)
  next.delete('success')
  next.delete('cancelled')
  return next
}

const PROFILE_TABS = [
  { id: 'account' as TabType, name: 'Account', description: 'Profile info and security', icon: User },
  { id: 'style' as TabType, name: 'Style', description: 'Colors, styles, occasions, brands', icon: Palette },
  { id: 'app' as TabType, name: 'App', description: 'Notifications, theme, units, location', icon: Settings2 },
  { id: 'plan' as TabType, name: 'Plan', description: 'Subscription, usage, referral code', icon: CreditCard },
  { id: 'help' as TabType, name: 'Help', description: 'Feedback, tickets, legal', icon: MessageSquarePlus },
]

export default function ProfilePage() {
  const user = useCurrentUser()
  const logout = useAuthStore((state) => state.logout)
  const setUser = useAuthStore((state) => state.setUser)
  const [searchParams, setSearchParams] = useSearchParams()
  // <md (phones): sections are full-screen subpages with a back bar (iOS
  // Settings pattern). ≥md: the tab strip with inline panels.
  const isMobile = !useIsSplitViewport()
  const navigate = useNavigate()

  const [activeTab, setActiveTab] = useState<TabType>(() => resolveTab(searchParams.get('tab')))
  const [isEditing, setIsEditing] = useState(false)
  // Mobile drill-down into the Account subpage. Pure state: the root view is
  // already `tab=account`, so the drill has no URL form of its own.
  const [showAccountSub, setShowAccountSub] = useState(false)
  // True when the current subpage was opened by a row tap (a pushed history
  // entry the back bar can pop); false for deep links, which reset state
  // instead. Cleared whenever the URL lands back on the root view.
  const subpagePushedRef = useRef(false)
  const backButtonRef = useRef<HTMLButtonElement | null>(null)
  // Row that opened the current (or last) subpage, for focus restoration.
  const lastOpenedSectionRef = useRef<TabType>('account')
  // True only for tap-driven opens; deep links must not steal focus.
  const openedByTapRef = useRef(false)
  // Tracks tabs the user has actually opened so a hidden panel mounts once,
  // on first activation, and then stays mounted (unsaved edits survive tab
  // switches and root ⇄ subpage navigation without ever fetching for a tab
  // the user never opened).
  const [hasVisited, setHasVisited] = useState<{
    style: boolean
    app: boolean
    plan: boolean
    help: boolean
  }>(() => {
    const initial = resolveTab(searchParams.get('tab'))
    return {
      style: initial === 'style',
      app: initial === 'app',
      plan: initial === 'plan',
      help: initial === 'help',
    }
  })

  // Record first-time activation for lazily-mounted panels.
  useEffect(() => {
    if (activeTab === 'style' || activeTab === 'app' || activeTab === 'plan' || activeTab === 'help') {
      setHasVisited((prev) => (prev[activeTab] ? prev : { ...prev, [activeTab]: true }))
    }
  }, [activeTab])
  const [fullName, setFullName] = useState(user?.full_name || '')
  const [gender, setGender] = useState<string>(user?.gender || '')
  const [birthDate, setBirthDate] = useState(user?.birth_date || '')
  const [birthTime, setBirthTime] = useState(() => normalizeBirthTimeForInput(user?.birth_time))
  const [birthPlace, setBirthPlace] = useState(user?.birth_place || '')
  const [isSavingProfile, setIsSavingProfile] = useState(false)

  const { toast } = useToast()

  // Keep URL in sync when user clicks tabs, while preserving other query params
  useEffect(() => {
    const currentTab = searchParams.get('tab')
    if (currentTab === activeTab) return
    const next = nextSearchParams(searchParams)
    next.set('tab', activeTab)
    setSearchParams(next, { replace: true })
  // searchParams/setSearchParams change identity on every navigation; adding them
  // re-runs this one-shot tab sync and fights the user's own tab clicks.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeTab]) // Only react to activeTab changes, not searchParams

  // URL → state: browser back/forward and deep links must open (or close) the
  // matching view. Runs on every navigation; setting the same tab is a no-op
  // for React, so this cannot loop with the write-effect above.
  useEffect(() => {
    const tab = resolveTab(searchParams.get('tab'))
    setActiveTab(tab)
    if (tab === 'account') {
      subpagePushedRef.current = false
      // The bare root URL (no explicit tab param — e.g. the mobile bottom nav
      // landing back on /profile) must close the account drill so the back
      // bar, the rendered panel, and the URL all agree. An explicit
      // `?tab=account` must NOT reset: deep links and the Stripe ack-param
      // flow (SubscriptionPanel strips success/cancelled via raw
      // replaceState while the user sits in the subpage) would otherwise
      // close the panel under the user.
      if (!searchParams.get('tab')) setShowAccountSub(false)
    } else {
      // The account drill is a pure-state view of `tab=account`; any URL that
      // points at another section must close it so the back-bar title, the
      // rendered panel, and the URL all agree (e.g. rotate to desktop, click a
      // tab, rotate back to mobile).
      setShowAccountSub(false)
    }
  }, [searchParams])

  // Switching sections (tab ⇄ tab, root ⇄ subpage) while scrolled must land at
  // the top of the new section — dropping mid-content is jarring on mobile,
  // where panels are tall. Skipped on first render so mount doesn't fight the
  // browser's own scroll restoration.
  const isFirstRender = useRef(true)
  useEffect(() => {
    if (isFirstRender.current) {
      isFirstRender.current = false
      return
    }
    window.scrollTo(0, 0)
  }, [activeTab, showAccountSub])

  const handleBack = useCallback(() => {
    if (showAccountSub) {
      // The account subpage is pure state; nothing to pop or rewrite.
      setShowAccountSub(false)
      return
    }
    if (subpagePushedRef.current) {
      // Row-tap subpage: pop the pushed entry; the URL→state effect lands on
      // the root view.
      subpagePushedRef.current = false
      navigate(-1)
      return
    }
    // Deep link (or already at root): no history entry to pop.
    setActiveTab('account')
  }, [showAccountSub, navigate])

  // Mobile section rows. Account opens its subpage in pure state; every other
  // section pushes a `?tab=` history entry so the browser back button closes
  // the subpage instead of leaving settings.
  const handleSectionClick = (tab: TabType) => {
    lastOpenedSectionRef.current = tab
    openedByTapRef.current = true
    if (tab === 'account') {
      setShowAccountSub(true)
      return
    }
    subpagePushedRef.current = true
    setActiveTab(tab)
    const next = nextSearchParams(searchParams)
    next.set('tab', tab)
    setSearchParams(next, { replace: false })
  }

  const tabs = PROFILE_TABS

  // Mobile: a section is "open" whenever the user is not on the root view
  // (root = `tab=account` with no account drill). Desktop: everything is
  // inline, so there are no subpages.
  const mobileSubpageOpen = isMobile && (activeTab !== 'account' || showAccountSub)
  const subpageTab: TabType | null = mobileSubpageOpen ? (showAccountSub ? 'account' : activeTab) : null
  const subpageTabDef = subpageTab ? tabs.find((t) => t.id === subpageTab) : null

  // Focus management for the drill-down: tapping a row unmounts it, so focus
  // must move to the back bar on open and back to the originating row on
  // close (including browser-back). Deep links skip the open-focus; desktop
  // has no rows, so the restore query safely no-ops there.
  const wasSubpageOpenRef = useRef(false)
  useEffect(() => {
    const isOpen = Boolean(subpageTab)
    if (isOpen && openedByTapRef.current) {
      backButtonRef.current?.focus()
    }
    if (wasSubpageOpenRef.current && !isOpen) {
      document
        .querySelector<HTMLButtonElement>(`[data-section="${lastOpenedSectionRef.current}"]`)
        ?.focus({ preventScroll: true })
    }
    wasSubpageOpenRef.current = isOpen
    openedByTapRef.current = false
  }, [subpageTab])

  // Escape anywhere in a subpage closes it. Document-level (not the back
  // bar's container) so the key still works once focus moves into subpage
  // content; active only while a subpage is open, cleaned up on close.
  useEffect(() => {
    if (!subpageTab) return
    const onKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        e.preventDefault()
        handleBack()
      }
    }
    document.addEventListener('keydown', onKeyDown)
    return () => document.removeEventListener('keydown', onKeyDown)
  }, [subpageTab, handleBack])

  const handleLogout = async () => {
    await logout()
    window.location.href = '/auth/login'
  }

  useEffect(() => {
    // Keep edit input in sync if user changes (e.g. refresh profile)
    setFullName(user?.full_name || '')
    setGender(user?.gender || '')
    setBirthDate(user?.birth_date || '')
    setBirthTime(normalizeBirthTimeForInput(user?.birth_time))
    setBirthPlace(user?.birth_place || '')
  }, [user?.birth_date, user?.birth_place, user?.birth_time, user?.full_name, user?.gender])

  const handleSaveProfile = async () => {
    if (!user) return
    setIsSavingProfile(true)
    try {
      const result = await updateCurrentUser({
        full_name: fullName.trim() || undefined,
        gender: gender || null,
        birth_date: birthDate || null,
        birth_time: normalizeBirthTimeForApi(birthTime) || null,
        birth_place: birthPlace.trim() || null,
      })
      const refreshedUser = await getCurrentUser().catch(() => result.user)
      setUser(refreshedUser)
      setIsEditing(false)

      const skippedBirthFields = result.skippedFields.filter(
        (field) => field === 'birth_date' || field === 'birth_time' || field === 'birth_place'
      )

      if (skippedBirthFields.length > 0) {
        toast({
          title: 'Profile partially updated',
          description:
            'Some birth details could not be saved. Please try again or contact support if this continues.',
          variant: 'destructive',
        })
      } else {
        toast({ title: 'Profile updated' })
      }
    } catch {
      // api/client interceptor already toasts the failure.
    } finally {
      setIsSavingProfile(false)
    }
  }

  return (
    <div className="app-page max-w-7xl">
      {/* Header — hidden on mobile subpages, where the back bar carries the title */}
      <div className={cn('mb-4 md:mb-4', mobileSubpageOpen && 'hidden')}>
        <h1 className="text-lg md:text-2xl font-bold text-foreground">Profile & Settings</h1>
        <p className="mt-1 md:mt-2 text-xs md:text-sm text-muted-foreground">Manage your account and preferences</p>
      </div>

      <div className="bg-card rounded-lg">
        {/* Avatar section — the mobile root's hero; hidden on subpages */}
        <div className={cn(mobileSubpageOpen && 'hidden')}>
          <AvatarSection />
        </div>

        {/* Desktop tab strip (≥md) */}
        <ScrollableTabs
          aria-label="Profile sections"
          fadeClassName="bg-card/95"
          className="hidden md:block w-full border-b border-border px-0 md:px-6 lg:px-8"
        >
          {tabs.map((tab) => (
            <ScrollableTab
              key={tab.id}
              isActive={activeTab === tab.id}
              onClick={() => setActiveTab(tab.id)}
              className="min-w-[100px] justify-center"
            >
              <tab.icon className="h-4 w-4" />
              <span className="hidden xs:inline">{tab.name}</span>
              <span className="xs:hidden">{tab.name.split(' ')[0]}</span>
            </ScrollableTab>
          ))}
        </ScrollableTabs>

        {/* Mobile subpage chrome: sticky back bar with the section title */}
        {subpageTab && (
          <div className="sticky top-[calc(var(--mobile-header-height)+var(--safe-area-top))] z-20 flex items-center gap-2 border-b border-border bg-card px-4 py-2">
            <Button
              ref={backButtonRef}
              variant="ghost"
              size="icon"
              onClick={handleBack}
              aria-label="Back to profile settings"
              className="shrink-0"
            >
              <ChevronLeft className="h-5 w-5" />
            </Button>
            <h1 className="flex min-w-0 flex-1 items-center gap-2 truncate text-base font-semibold text-foreground">
              {subpageTabDef?.icon && <subpageTabDef.icon className="h-4 w-4 shrink-0 text-muted-foreground" aria-hidden="true" />}
              <span className="truncate">{subpageTabDef?.name ?? 'Account'}</span>
            </h1>
          </div>
        )}

        {/* Mobile root chrome: section list (drill-down index) */}
        {isMobile && !mobileSubpageOpen && (
          <nav aria-label="Profile sections" className="md:hidden">
            <ul className="m-0 list-none divide-y divide-border p-0">
              {tabs.map((tab) => (
                <li key={tab.id}>
                  <button
                    data-section={tab.id}
                    type="button"
                    onClick={() => handleSectionClick(tab.id)}
                    className="flex w-full items-center gap-3 px-4 py-3.5 text-left transition-colors hover:bg-muted/60 focus-visible:bg-muted/60 active:bg-muted/60"
                  >
                    <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md bg-muted">
                      <tab.icon className="h-5 w-5 text-foreground" aria-hidden="true" />
                    </span>
                    <span className="min-w-0 flex-1">
                      <span className="block text-sm font-medium text-foreground">{tab.name}</span>
                      <span className="block truncate text-xs text-muted-foreground">{tab.description}</span>
                    </span>
                    <ChevronRight className="h-4 w-4 shrink-0 text-muted-foreground" aria-hidden="true" />
                  </button>
                </li>
              ))}
            </ul>
          </nav>
        )}

        {/* Content container — one stable mount point shared by the desktop
            inline panels and the mobile subpages, so a panel never unmounts
            (unsaved edits survive root ⇄ subpage switches). Hidden on the
            mobile root, where the section list is the content. */}
        <div className={cn('px-4 py-4 md:px-6 md:py-6 lg:px-8', isMobile && !mobileSubpageOpen && 'hidden')}>
          {activeTab === 'account' && (
            <div className="space-y-4 md:space-y-6">
              <div>
                <h3 className="text-base md:text-lg font-medium text-foreground mb-4">Profile Information</h3>
                <div className="grid grid-cols-1 gap-y-4 md:gap-y-6 gap-x-4 md:grid-cols-6">
                  <div className="md:col-span-6">
                    <label
                      htmlFor="fullName"
                      className="block text-sm font-medium text-foreground"
                    >
                      Full Name
                    </label>
                    <div className="mt-1 flex rounded-md shadow-sm">
                      <input
                        type="text"
                        id="fullName"
                        value={isEditing ? fullName : user?.full_name || ''}
                        onChange={(e) => setFullName(e.target.value)}
                        disabled={!isEditing}
                        className="flex-1 min-w-0 block w-full h-12 px-3 rounded-md border border-border focus:ring-primary focus:border-primary text-base md:text-sm disabled:bg-muted disabled:text-muted-foreground bg-background text-foreground appearance-none"
                      />
                    </div>
                  </div>

                  <div className="md:col-span-6">
                    <label
                      htmlFor="gender"
                      className="block text-sm font-medium text-foreground"
                    >
                      Gender
                    </label>
                    <p className="text-xs text-muted-foreground mb-1">
                      Used for AI-generated outfit visualizations
                    </p>
                    <select
                      id="gender"
                      value={isEditing ? gender : user?.gender || ''}
                      onChange={(e) => setGender(e.target.value)}
                      disabled={!isEditing}
                      className="mt-1 block w-full h-12 px-3 pr-10 text-base md:text-sm border border-border focus:outline-none focus:ring-primary focus:border-primary rounded-md disabled:bg-muted disabled:text-muted-foreground bg-background text-foreground appearance-none"
                    >
                      <option value="">Prefer not to say</option>
                      <option value="male">Male</option>
                      <option value="female">Female</option>
                      <option value="non_binary">Non-binary</option>
                    </select>
                  </div>

                  <div className="md:col-span-6">
                    <label
                      htmlFor="email"
                      className="block text-sm font-medium text-foreground"
                    >
                      Email Address
                    </label>
                    <div className="mt-1 relative rounded-md shadow-sm">
                      <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <Mail className="h-5 w-5 text-muted-foreground" />
                      </div>
                      <input
                        type="email"
                        id="email"
                        value={user?.email || ''}
                        disabled
                        className="pl-10 flex-1 min-w-0 block w-full h-12 px-3 rounded-md border border-border bg-muted text-muted-foreground text-base"
                      />
                    </div>
                    <p className="mt-1 text-xs text-muted-foreground">
                      Contact support to change your email
                    </p>
                  </div>

                  <div className="md:col-span-3">
                    <label htmlFor="birthDate" className="block text-sm font-medium text-foreground">
                      Date of Birth (Optional)
                    </label>
                    <p className="text-xs text-muted-foreground mb-1">
                      Needed for astrology color recommendations
                    </p>
                    <input
                      type="date"
                      id="birthDate"
                      value={isEditing ? birthDate : user?.birth_date || ''}
                      onChange={(e) => setBirthDate(e.target.value)}
                      disabled={!isEditing}
                      className="mt-1 block w-full h-12 px-3 border border-border rounded-md text-base md:text-sm bg-background text-foreground focus:ring-primary focus:border-primary disabled:bg-muted disabled:text-muted-foreground"
                    />
                  </div>

                  <div className="md:col-span-3">
                    <label htmlFor="birthTime" className="block text-sm font-medium text-foreground">
                      Birth Time (Optional)
                    </label>
                    <p className="text-xs text-muted-foreground mb-1">
                      Optional: improves Vedic accuracy when available
                    </p>
                    <input
                      type="time"
                      id="birthTime"
                      value={isEditing ? birthTime : normalizeBirthTimeForInput(user?.birth_time)}
                      onChange={(e) => setBirthTime(e.target.value)}
                      disabled={!isEditing}
                      className="mt-1 block w-full h-12 px-3 border border-border rounded-md text-base md:text-sm bg-background text-foreground focus:ring-primary focus:border-primary disabled:bg-muted disabled:text-muted-foreground"
                    />
                  </div>

                  <div className="md:col-span-6">
                    <label htmlFor="birthPlace" className="block text-sm font-medium text-foreground">
                      Birth Place (Optional)
                    </label>
                    <p className="text-xs text-muted-foreground mb-1">
                      City and country helps timezone-accurate calculations
                    </p>
                    <input
                      type="text"
                      id="birthPlace"
                      value={isEditing ? birthPlace : user?.birth_place || ''}
                      onChange={(e) => setBirthPlace(e.target.value)}
                      disabled={!isEditing}
                      className="mt-1 block w-full h-12 px-3 border border-border rounded-md text-base md:text-sm bg-background text-foreground focus:ring-primary focus:border-primary disabled:bg-muted disabled:text-muted-foreground"
                      placeholder="e.g. New Delhi, India"
                    />
                  </div>
                </div>

                <div className="mt-4 md:mt-6 flex flex-col-reverse gap-3 sm:flex-row sm:justify-end">
                  {isEditing ? (
                    <>
                      <Button
                        variant="outline"
                        onClick={() => {
                          setIsEditing(false)
                          setFullName(user?.full_name || '')
                          setGender(user?.gender || '')
                          setBirthDate(user?.birth_date || '')
                          setBirthTime(normalizeBirthTimeForInput(user?.birth_time))
                          setBirthPlace(user?.birth_place || '')
                        }}
                        className="w-full sm:w-auto"
                      >
                        Cancel
                      </Button>
                      <Button
                        onClick={handleSaveProfile}
                        disabled={isSavingProfile}
                        className="w-full sm:w-auto"
                      >
                        {isSavingProfile ? 'Saving...' : 'Save Changes'}
                      </Button>
                    </>
                  ) : (
                    <Button onClick={() => setIsEditing(true)} className="w-full sm:w-auto">
                      Edit Profile
                    </Button>
                  )}
                </div>
              </div>

              <SecurityPanel />
            </div>
          )}

          {/* Panels mount lazily on first activation so hidden sections never
              issue network reads for a surface the user has not opened.
              Switching away hides (not unmounts) so unsaved edits survive. */}
          {activeTab === 'style' || hasVisited.style ? (
            <div className={activeTab === 'style' ? '' : 'hidden'}>
              <PreferencesPanel />
            </div>
          ) : null}

          {activeTab === 'app' || hasVisited.app ? (
            <div className={activeTab === 'app' ? '' : 'hidden'}>
              <AppSettingsPanel />
            </div>
          ) : null}

          {activeTab === 'plan' || hasVisited.plan ? (
            <div className={activeTab === 'plan' ? '' : 'hidden'}>
              <SubscriptionPanel isActive={activeTab === 'plan'} />
            </div>
          ) : null}

          {activeTab === 'help' || hasVisited.help ? (
            <div className={activeTab === 'help' ? '' : 'hidden'}>
              <SupportPanel />
            </div>
          ) : null}
        </div>

        {/* Mobile sign out — the last row of the root card */}
        {isMobile && !mobileSubpageOpen && (
          <div className="border-t border-border px-4 py-4">
            <Button variant="outline" onClick={handleLogout} className="w-full">
              Sign Out
            </Button>
          </div>
        )}
      </div>

      {/* Desktop sign out */}
      {!isMobile && (
        <div className="mt-6 mb-4 text-center">
          <Button
            variant="outline"
            onClick={handleLogout}
            className="w-full sm:w-auto"
          >
            Sign Out
          </Button>
        </div>
      )}
    </div>
  )
}
