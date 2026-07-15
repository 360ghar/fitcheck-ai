/**
 * Profile/Settings Page
 * User profile, preferences, and settings management
 */

import { useEffect, useRef, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import { useAuthStore, useCurrentUser, useUserDisplayName, useUserAvatar } from '../../stores/authStore'
import { User, Mail, Camera, Shield, Settings2, Palette, Cpu, Sun, Moon, Monitor, MapPin, CreditCard, MessageSquarePlus } from 'lucide-react'
import { useToast } from '@/components/ui/use-toast'
import { Switch } from '@/components/ui/switch'
import { Button } from '@/components/ui/button'
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog'
import { ScrollableTabs, ScrollableTab } from '@/components/ui/scrollable-tabs'
import { ChipGroup } from '@/components/ui/chip-group'
import { getCurrentUser, updateCurrentUser, uploadAvatar, getUserPreferences, updateUserPreferences, getUserSettings, updateUserSettings, deleteAccount } from '@/api/users'
import { requestPasswordReset } from '@/api/auth'
import { AISettingsPanel, LocationInput, SubscriptionPanel, SupportPanel } from '@/components/settings'
import { useTheme } from '@/components/theme'
import { THEMES } from '@/lib/theme'
import { cn } from '@/lib/utils'
import { useGeolocation } from '@/hooks/useGeolocation'
import type { UserPreferences, UserSettings } from '@/types'

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

const COLOR_SUGGESTIONS = ['Black', 'White', 'Navy', 'Gray', 'Beige', 'Brown', 'Red', 'Blue', 'Green', 'Pink', 'Olive']
const STYLE_SUGGESTIONS = ['Casual', 'Formal', 'Business', 'Streetwear', 'Minimalist', 'Sporty', 'Bohemian', 'Classic', 'Elegant']
const OCCASION_SUGGESTIONS = ['Work', 'Date night', 'Travel', 'Wedding', 'Gym', 'Weekend', 'Party', 'Interview']
const PATTERN_SUGGESTIONS = ['Plaid', 'Stripes', 'Polka dots', 'Floral', 'Camo', 'Animal print', 'Logo']

const themeIcons = {
  light: Sun,
  dark: Moon,
  system: Monitor,
} as const;

function ThemeSelector() {
  const { theme, setTheme } = useTheme();

  return (
    <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between py-3 border-b border-border">
      <div>
        <p className="text-sm font-medium text-foreground">Theme</p>
        <p className="text-sm text-muted-foreground">Choose your preferred theme</p>
      </div>
      <div className="flex flex-wrap items-center gap-2">
        {THEMES.map((option) => {
          const Icon = themeIcons[option.value];
          return (
            <button
              key={option.value}
              type="button"
              onClick={() => setTheme(option.value)}
              aria-pressed={theme === option.value}
              className={cn(
                'flex-1 sm:flex-none px-3 py-2 text-sm rounded-md transition-colors flex items-center gap-1.5 touch-target',
                theme === option.value
                  ? 'bg-primary text-primary-foreground'
                  : 'bg-muted text-muted-foreground hover:bg-muted/80'
              )}
            >
              <Icon className="h-4 w-4" />
              <span className="hidden xs:inline">{option.label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
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
  const userDisplayName = useUserDisplayName()
  const userAvatar = useUserAvatar()
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
  const [isUploadingAvatar, setIsUploadingAvatar] = useState(false)
  const avatarInputRef = useRef<HTMLInputElement | null>(null)

  const [isLoadingPreferences, setIsLoadingPreferences] = useState(false)
  const [isSavingPreferences, setIsSavingPreferences] = useState(false)
  const [preferences, setPreferences] = useState<UserPreferences | null>(null)
  const [favoriteColors, setFavoriteColors] = useState<string[]>([])
  const [preferredStyles, setPreferredStyles] = useState<string[]>([])
  const [preferredOccasions, setPreferredOccasions] = useState<string[]>([])
  const [likedBrands, setLikedBrands] = useState<string[]>([])
  const [dislikedPatterns, setDislikedPatterns] = useState<string[]>([])
  const [colorTemperature, setColorTemperature] = useState<string>('')
  const [stylePersonality, setStylePersonality] = useState<string>('')

  const [isLoadingSettings, setIsLoadingSettings] = useState(false)
  const [isSavingSettings, setIsSavingSettings] = useState(false)
  const [settings, setSettings] = useState<UserSettings | null>(null)
  const [locationValue, setLocationValue] = useState('')
  const [settingsDirty, setSettingsDirty] = useState(false)
  const { state: geoState, requestLocation } = useGeolocation()
  const [isDeleteAccountOpen, setIsDeleteAccountOpen] = useState(false)
  const [isDeletingAccount, setIsDeletingAccount] = useState(false)

  const { toast } = useToast()

  // Keep URL in sync when user clicks tabs, while preserving other query params
  useEffect(() => {
    const currentTab = searchParams.get('tab')
    if (currentTab === activeTab) return
    const next = new URLSearchParams(searchParams)
    next.set('tab', activeTab)
    setSearchParams(next, { replace: true })
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

  useEffect(() => {
    if (!user) return

    // Load preferences + settings once per session.
    // (These are separate tables and may be created lazily by the backend.)
    setIsLoadingPreferences(true)
    setIsLoadingSettings(true)

    getUserPreferences()
      .then((prefs) => {
        setPreferences(prefs)
        setFavoriteColors(prefs.favorite_colors || [])
        setPreferredStyles(prefs.preferred_styles || [])
        setPreferredOccasions(prefs.preferred_occasions || [])
        setLikedBrands(prefs.liked_brands || [])
        setDislikedPatterns(prefs.disliked_patterns || [])
        setColorTemperature(prefs.color_temperature || '')
        setStylePersonality(prefs.style_personality || '')
      })
      .catch((err) => {
        console.warn('Failed to load preferences:', err)
      })
      .finally(() => setIsLoadingPreferences(false))

    getUserSettings()
      .then((s) => {
        setSettings(s)
        setLocationValue(s.default_location || '')
      })
      .catch((err) => {
        console.warn('Failed to load settings:', err)
      })
      .finally(() => setIsLoadingSettings(false))
  }, [user?.id])

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
    } catch (err) {
      toast({
        title: 'Failed to update profile',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    } finally {
      setIsSavingProfile(false)
    }
  }

  const handleSavePreferences = async () => {
    if (!user) return
    setIsSavingPreferences(true)
    try {
      const updated = await updateUserPreferences({
        favorite_colors: favoriteColors,
        preferred_styles: preferredStyles,
        preferred_occasions: preferredOccasions,
        liked_brands: likedBrands,
        disliked_patterns: dislikedPatterns,
        color_temperature: colorTemperature || undefined,
        style_personality: stylePersonality || undefined,
      })
      setPreferences(updated)
      toast({ title: 'Preferences saved' })
    } catch (err) {
      toast({
        title: 'Failed to save preferences',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    } finally {
      setIsSavingPreferences(false)
    }
  }

  const handleUpdateSettings = (patch: Partial<UserSettings>) => {
    setSettings((prev) => (prev ? { ...prev, ...patch } : prev))
    setSettingsDirty(true)
  }

  const handleSaveSettings = async () => {
    if (!settings) return
    setIsSavingSettings(true)
    try {
      const updated = await updateUserSettings({
        default_location: locationValue.trim() || undefined,
        timezone: settings.timezone || undefined,
        language: settings.language || undefined,
        measurement_units: settings.measurement_units,
        notifications_enabled: settings.notifications_enabled,
        email_marketing: settings.email_marketing,
      })
      setSettings(updated)
      setLocationValue(updated.default_location || '')
      setSettingsDirty(false)
      toast({ title: 'Settings saved' })
    } catch (err) {
      toast({
        title: 'Failed to save settings',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    } finally {
      setIsSavingSettings(false)
    }
  }

  const handleSendPasswordReset = async () => {
    if (!user?.email) return
    try {
      await requestPasswordReset(user.email)
      toast({
        title: 'Password reset email sent',
        description: 'Check your inbox for a reset link.',
      })
    } catch (err) {
      toast({
        title: 'Failed to send reset email',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    }
  }

  const handleDeleteAccount = async () => {
    setIsDeletingAccount(true)
    try {
      await deleteAccount()
      await logout()
      window.location.href = '/auth/login'
    } catch (err) {
      toast({
        title: 'Failed to delete account',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
      setIsDeletingAccount(false)
    }
  }

  const handleAvatarClick = () => {
    avatarInputRef.current?.click()
  }

  const handleAvatarSelected = async (file: File | null) => {
    if (!file || !user) return
    setIsUploadingAvatar(true)
    try {
      const { avatar_url } = await uploadAvatar(file)
      setUser({ ...user, avatar_url })
      toast({ title: 'Avatar updated' })
    } catch (err) {
      toast({
        title: 'Failed to upload avatar',
        description: err instanceof Error ? err.message : 'An error occurred',
        variant: 'destructive',
      })
    } finally {
      setIsUploadingAvatar(false)
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
        <div className="px-4 py-4 md:px-6 md:py-6 lg:px-8 border-b border-border">
          <div className="flex flex-col items-center xs:flex-row xs:items-center w-full">
            <div className="relative">
              {userAvatar ? (
                <img
                  src={userAvatar}
                  alt={`${userDisplayName} avatar`}
                  className="h-16 w-16 md:h-24 md:w-24 rounded-full object-cover"
                />
              ) : (
                <div className="h-16 w-16 md:h-24 md:w-24 rounded-full bg-primary/10 flex items-center justify-center">
                  <span className="text-xl md:text-3xl font-bold text-primary">
                    {userDisplayName.charAt(0).toUpperCase()}
                  </span>
                </div>
              )}
              <input
                ref={avatarInputRef}
                type="file"
                accept="image/*"
                className="hidden"
                onChange={(e) => handleAvatarSelected(e.target.files?.[0] || null)}
              />
              <button
                type="button"
                onClick={handleAvatarClick}
                disabled={isUploadingAvatar}
                className="absolute bottom-0 right-0 p-2 md:p-2.5 bg-primary rounded-full text-primary-foreground hover:bg-primary/90 disabled:opacity-60 touch-target shadow-md"
                aria-label="Change avatar"
                title="Change avatar"
              >
                <Camera className="h-4 w-4 md:h-5 md:w-5" />
                </button>
            </div>
            <div className="mt-3 xs:mt-0 xs:ml-4 md:ml-6 min-w-0 text-center xs:text-left">
              <h2 className="text-lg md:text-xl font-medium text-foreground truncate">{userDisplayName}</h2>
              <p className="text-sm text-muted-foreground truncate">{user?.email}</p>
            </div>
          </div>
        </div>

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

              <div className="border-t border-border pt-6 space-y-4">
                <div className="flex items-center gap-2">
                  <Shield className="h-5 w-5 text-muted-foreground" />
                  <h3 className="text-base md:text-lg font-medium text-foreground">Security</h3>
                </div>
                <div className="p-4 border border-border rounded-md">
                  <h4 className="text-sm font-medium text-foreground">Password</h4>
                  <p className="text-sm text-muted-foreground mt-1">
                    Change your password to keep your account secure
                  </p>
                  <Button
                    variant="outline"
                    onClick={handleSendPasswordReset}
                    className="mt-3 w-full md:w-auto"
                  >
                    Send Password Reset Email
                  </Button>
                </div>
                <div className="p-4 border border-destructive/30 rounded-md bg-destructive/5">
                  <h4 className="text-sm font-medium text-destructive">Danger Zone</h4>
                  <p className="text-sm text-destructive/80 mt-1">
                    Once you delete your account, there is no going back
                  </p>
                  <Button
                    variant="destructive"
                    onClick={() => setIsDeleteAccountOpen(true)}
                    className="mt-3 w-full md:w-auto"
                  >
                    Delete Account
                  </Button>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'style' && (
            <div className="space-y-6">
              <div>
                <h3 className="text-base md:text-lg font-medium text-foreground">Style Preferences</h3>
                <p className="text-sm text-muted-foreground">
                  Tap suggestions or add your own chips for better recommendations.
                </p>
              </div>

              {isLoadingPreferences ? (
                <div className="p-4 bg-muted rounded-md text-center text-muted-foreground">Loading…</div>
              ) : (
                <div className="space-y-5">
                  <ChipGroup
                    label="Favorite colors"
                    value={favoriteColors}
                    onChange={setFavoriteColors}
                    suggestions={COLOR_SUGGESTIONS}
                    placeholder="Add a color"
                  />
                  <ChipGroup
                    label="Preferred styles"
                    value={preferredStyles}
                    onChange={setPreferredStyles}
                    suggestions={STYLE_SUGGESTIONS}
                    placeholder="Add a style"
                  />
                  <ChipGroup
                    label="Preferred occasions"
                    value={preferredOccasions}
                    onChange={setPreferredOccasions}
                    suggestions={OCCASION_SUGGESTIONS}
                    placeholder="Add an occasion"
                  />
                  <ChipGroup
                    label="Liked brands"
                    value={likedBrands}
                    onChange={setLikedBrands}
                    placeholder="e.g. Uniqlo"
                  />
                  <ChipGroup
                    label="Disliked patterns"
                    value={dislikedPatterns}
                    onChange={setDislikedPatterns}
                    suggestions={PATTERN_SUGGESTIONS}
                    placeholder="Add a pattern"
                  />

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label htmlFor="color-temp" className="block text-sm font-medium text-foreground">Color temperature</label>
                      <select
                        id="color-temp"
                        value={colorTemperature}
                        onChange={(e) => setColorTemperature(e.target.value)}
                        className="mt-1 block w-full h-12 px-3 pr-10 text-base md:text-sm border border-border rounded-md bg-background text-foreground focus:ring-primary focus:border-primary appearance-none"
                      >
                        <option value="">Not set</option>
                        <option value="warm">Warm</option>
                        <option value="cool">Cool</option>
                        <option value="neutral">Neutral</option>
                      </select>
                    </div>
                    <div>
                      <label htmlFor="style-personality" className="block text-sm font-medium text-foreground">Style personality</label>
                      <input
                        id="style-personality"
                        value={stylePersonality}
                        onChange={(e) => setStylePersonality(e.target.value)}
                        className="mt-1 block w-full h-12 px-3 border border-border rounded-md text-base md:text-sm bg-background text-foreground focus:ring-primary focus:border-primary appearance-none"
                        placeholder="e.g. minimalist, bold, classic"
                      />
                    </div>
                  </div>

                  <div className="flex flex-col-reverse gap-3 md:flex-row md:justify-end">
                    <Button
                      onClick={handleSavePreferences}
                      disabled={isSavingPreferences}
                      className="w-full md:w-auto"
                    >
                      {isSavingPreferences ? 'Saving…' : 'Save Preferences'}
                    </Button>
                  </div>

                  {!preferences && (
                    <p className="text-xs text-muted-foreground">
                      Preferences will be created automatically after your first save.
                    </p>
                  )}
                </div>
              )}
            </div>
          )}

          {activeTab === 'app' && (
            <div className="space-y-8">
              <div className="space-y-6">
              <h3 className="text-base md:text-lg font-medium text-foreground">App Settings</h3>

              {isLoadingSettings ? (
                <div className="p-4 bg-muted rounded-md text-center text-muted-foreground">Loading…</div>
              ) : !settings ? (
                <div className="p-4 bg-muted rounded-md text-center text-muted-foreground">
                  Settings are unavailable. Ensure the database schema is initialized.
                </div>
              ) : (
                <div className="space-y-4">
                  <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between py-3 border-b border-border">
                    <div>
                      <p className="text-sm font-medium text-foreground">Notifications</p>
                      <p className="text-sm text-muted-foreground">Enable in-app notifications</p>
                    </div>
                    <Switch
                      checked={settings.notifications_enabled}
                      onCheckedChange={(checked) => handleUpdateSettings({ notifications_enabled: checked })}
                    />
                  </div>

                  <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between py-3 border-b border-border">
                    <div>
                      <p className="text-sm font-medium text-foreground">Email Marketing</p>
                      <p className="text-sm text-muted-foreground">Receive emails about new features</p>
                    </div>
                    <Switch
                      checked={settings.email_marketing}
                      onCheckedChange={(checked) => handleUpdateSettings({ email_marketing: checked })}
                    />
                  </div>

                  <ThemeSelector />

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 py-3">
                    <div>
                      <p className="text-sm font-medium text-foreground">Measurement Units</p>
                      <p className="text-sm text-muted-foreground">Choose between metric and imperial</p>
                      <select
                        value={settings.measurement_units}
                        onChange={(e) =>
                          handleUpdateSettings({
                            measurement_units: (e.target.value as 'imperial' | 'metric') || 'imperial',
                          })
                        }
                        aria-label="Measurement units"
                        className="mt-2 block w-full h-12 px-3 pr-10 text-base border border-border rounded-md bg-background text-foreground focus:ring-primary focus:border-primary"
                      >
                        <option value="imperial">Imperial (lbs, ft)</option>
                        <option value="metric">Metric (kg, cm)</option>
                      </select>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-foreground">Language</p>
                      <p className="text-sm text-muted-foreground">Interface language</p>
                      <select
                        value={settings.language}
                        onChange={(e) => handleUpdateSettings({ language: e.target.value })}
                        aria-label="Language"
                        className="mt-2 block w-full h-12 px-3 pr-10 text-base border border-border rounded-md bg-background text-foreground focus:ring-primary focus:border-primary"
                      >
                        <option value="en">English</option>
                      </select>
                    </div>
                  </div>

                  <div className="py-3 border-b border-border">
                    <div className="mb-2">
                      <p className="text-sm font-medium text-foreground flex items-center gap-2">
                        <MapPin className="h-4 w-4" />
                        Weather Location
                      </p>
                      <p className="text-sm text-muted-foreground">
                        Used for weather-based outfit recommendations
                      </p>
                    </div>
                    <LocationInput
                      value={locationValue}
                      onChange={(val) => {
                        setLocationValue(val)
                        setSettingsDirty(true)
                      }}
                      onAutoDetect={async () => {
                        const coords = await requestLocation()
                        if (coords) {
                          const locationString = `${coords.lat.toFixed(4)},${coords.lon.toFixed(4)}`
                          setLocationValue(locationString)
                          setSettingsDirty(true)
                        }
                      }}
                      isAutoDetecting={geoState.isLoading}
                      error={geoState.error}
                      showAutoDetectButton={true}
                      placeholder="Enter city name or coordinates"
                    />
                  </div>

                  <div className="flex flex-col-reverse gap-3 md:flex-row md:items-center md:justify-end pt-2">
                    {settingsDirty && (
                      <p className="text-xs text-amber-600 dark:text-amber-400 md:mr-auto">
                        Unsaved changes — click Save Settings to apply.
                      </p>
                    )}
                    <Button
                      onClick={handleSaveSettings}
                      disabled={isSavingSettings || !settingsDirty}
                      className="w-full md:w-auto"
                    >
                      {isSavingSettings ? 'Saving…' : 'Save Settings'}
                    </Button>
                  </div>
                </div>
              )}
              </div>

              <div className="border-t border-border pt-8 space-y-4">
                <div className="flex items-center gap-2">
                  <Cpu className="h-5 w-5 text-muted-foreground" />
                  <h3 className="text-base md:text-lg font-medium text-foreground">AI Settings</h3>
                </div>
                <AISettingsPanel />
              </div>
            </div>
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

      <AlertDialog
        open={isDeleteAccountOpen}
        onOpenChange={(open) => {
          if (!isDeletingAccount) setIsDeleteAccountOpen(open)
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete your account?</AlertDialogTitle>
            <AlertDialogDescription>
              This permanently deletes your FitCheck AI account, wardrobe, and outfits.
              This cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={isDeletingAccount}>Cancel</AlertDialogCancel>
            <AlertDialogAction
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
              disabled={isDeletingAccount}
              onClick={(e) => {
                e.preventDefault()
                void handleDeleteAccount()
              }}
            >
              {isDeletingAccount ? 'Deleting…' : 'Delete account'}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
