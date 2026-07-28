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

import { useEffect, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import { useAuthStore, useCurrentUser } from '../../stores/authStore'
import { User, Mail, Settings2, Palette, CreditCard, MessageSquarePlus } from 'lucide-react'
import { useToast } from '@/components/ui/use-toast'
import { Button } from '@/components/ui/button'
import { ScrollableTabs, ScrollableTab } from '@/components/ui/scrollable-tabs'
import { getCurrentUser, updateCurrentUser } from '@/api/users'
import { SubscriptionPanel, SupportPanel } from '@/components/settings'
import { AvatarSection } from './AvatarSection'
import { PreferencesPanel } from './PreferencesPanel'
import { AppSettingsPanel } from './AppSettingsPanel'
import { SecurityPanel } from './SecurityPanel'

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

const PROFILE_TABS = [
  { id: 'account' as TabType, name: 'Account', icon: User },
  { id: 'style' as TabType, name: 'Style', icon: Palette },
  { id: 'app' as TabType, name: 'App', icon: Settings2 },
  { id: 'plan' as TabType, name: 'Plan', icon: CreditCard },
  { id: 'help' as TabType, name: 'Help', icon: MessageSquarePlus },
]

export default function ProfilePage() {
  const user = useCurrentUser()
  const logout = useAuthStore((state) => state.logout)
  const setUser = useAuthStore((state) => state.setUser)
  const [searchParams, setSearchParams] = useSearchParams()

  const [activeTab, setActiveTab] = useState<TabType>(() => resolveTab(searchParams.get('tab')))
  const [isEditing, setIsEditing] = useState(false)
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
    const next = new URLSearchParams(searchParams)
    next.set('tab', activeTab)
    setSearchParams(next, { replace: true })
  // searchParams/setSearchParams change identity on every navigation; adding them
  // re-runs this one-shot tab sync and fights the user's own tab clicks.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeTab]) // Only react to activeTab changes, not searchParams

  const tabs = PROFILE_TABS

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
    <div className="w-full max-w-7xl mx-auto px-4 md:px-6 lg:px-8 py-4 md:py-8">
      {/* Header */}
      <div className="mb-4 md:mb-8">
        <h1 className="text-lg md:text-2xl font-bold text-foreground">Profile & Settings</h1>
        <p className="mt-1 md:mt-2 text-xs md:text-sm text-muted-foreground">Manage your account and preferences</p>
      </div>

      <div className="bg-card shadow rounded-lg">
        {/* Avatar section */}
        <AvatarSection />

        {/* Scrollable Tabs */}
        <ScrollableTabs
          aria-label="Profile sections"
          className="border-b border-border px-0 md:px-6 lg:px-8 w-full sticky top-[calc(var(--mobile-header-height)+var(--safe-area-top))] z-20 bg-card/95 backdrop-blur-sm md:static"
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

        {/* Tab content */}
        <div className="px-4 py-4 md:px-6 md:py-6 lg:px-8">
          {activeTab === 'account' && (
            <div className="space-y-6">
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

                <div className="mt-6 flex flex-col-reverse gap-3 md:flex-row md:justify-end">
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
                        className="w-full md:w-auto"
                      >
                        Cancel
                      </Button>
                      <Button
                        onClick={handleSaveProfile}
                        disabled={isSavingProfile}
                        className="w-full md:w-auto"
                      >
                        {isSavingProfile ? 'Saving...' : 'Save Changes'}
                      </Button>
                    </>
                  ) : (
                    <Button onClick={() => setIsEditing(true)} className="w-full md:w-auto">
                      Edit Profile
                    </Button>
                  )}
                </div>
              </div>

              <SecurityPanel />
            </div>
          )}

          {activeTab === 'style' && (
            <PreferencesPanel />
          )}

          {activeTab === 'app' && (
            <AppSettingsPanel />
          )}

          {activeTab === 'plan' && (
            <SubscriptionPanel />
          )}

          {activeTab === 'help' && (
            <SupportPanel />
          )}
        </div>
      </div>

      {/* Logout button */}
      <div className="mt-6 mb-4 text-center">
        <Button
          variant="outline"
          onClick={handleLogout}
          className="w-full md:w-auto"
        >
          Sign Out
        </Button>
      </div>
    </div>
  )
}
