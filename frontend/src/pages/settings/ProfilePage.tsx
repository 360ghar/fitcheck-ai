/**
 * Profile/Settings Page
 * User profile, preferences, and settings management
 */

import { useEffect, useRef, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import { useAuthStore, useCurrentUser, useUserDisplayName, useUserAvatar } from '../../stores/authStore'
import { User, Mail, Camera, Shield, Bell, Palette, Cpu, Sun, Moon, Monitor, MapPin, CreditCard, MessageSquarePlus } from 'lucide-react'
import { useToast } from '@/components/ui/use-toast'
import { Switch } from '@/components/ui/switch'
import { Button } from '@/components/ui/button'
import { ScrollableTabs } from '@/components/ui/scrollable-tabs'
import { updateCurrentUser, uploadAvatar, getUserPreferences, updateUserPreferences, getUserSettings, updateUserSettings, deleteAccount } from '@/api/users'
import { requestPasswordReset } from '@/api/auth'
import { AISettingsPanel, LocationInput, SubscriptionPanel, SupportPanel } from '@/components/settings'
import { useTheme } from '@/components/theme'
import { THEMES } from '@/lib/theme'
import { cn } from '@/lib/utils'
import { useGeolocation } from '@/hooks/useGeolocation'
import type { UserPreferences, UserSettings } from '@/types'

type TabType = 'profile' | 'preferences' | 'settings' | 'ai' | 'subscription' | 'support' | 'security'

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
              onClick={() => setTheme(option.value)}
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

function parseCsv(value: string): string[] {
  return value
    .split(',')
    .map((v) => v.trim())
    .filter(Boolean)
}

function toCsv(value: string[] | undefined | null): string {
  return (value || []).join(', ')
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

const isValidTab = (value: string): value is TabType =>
  ['profile', 'preferences', 'settings', 'ai', 'subscription', 'support', 'security'].includes(value)

export default function ProfilePage() {
  const user = useCurrentUser()
  const userDisplayName = useUserDisplayName()
  const userAvatar = useUserAvatar()
  const logout = useAuthStore((state) => state.logout)
  const setUser = useAuthStore((state) => state.setUser)
  const [searchParams, setSearchParams] = useSearchParams()

  // Initialize activeTab from URL or default to 'profile'
  const [activeTab, setActiveTab] = useState<TabType>(() => {
    const tabParam = searchParams.get('tab')
    return tabParam && isValidTab(tabParam) ? tabParam : 'profile'
  })
  const [isEditing, setIsEditing] = useState(false)
  const [fullName, setFullName] = useState(user?.full_name || '')
  const [gender, setGender] = useState<string>(user?.gender || '')
  const [birthDate, setBirthDate] = useState(user?.birth_date || '')
  const [birthTime, setBirthTime] = useState(normalizeBirthTimeForInput(user?.birth_time))
  const [birthPlace, setBirthPlace] = useState(user?.birth_place || '')
  const [isSavingProfile, setIsSavingProfile] = useState(false)
  const [isUploadingAvatar, setIsUploadingAvatar] = useState(false)
  const avatarInputRef = useRef<HTMLInputElement | null>(null)

  const [isLoadingPreferences, setIsLoadingPreferences] = useState(false)
  const [isSavingPreferences, setIsSavingPreferences] = useState(false)
  const [preferences, setPreferences] = useState<UserPreferences | null>(null)
  const [favoriteColorsCsv, setFavoriteColorsCsv] = useState('')
  const [preferredStylesCsv, setPreferredStylesCsv] = useState('')
  const [preferredOccasionsCsv, setPreferredOccasionsCsv] = useState('')
  const [likedBrandsCsv, setLikedBrandsCsv] = useState('')
  const [dislikedPatternsCsv, setDislikedPatternsCsv] = useState('')
  const [colorTemperature, setColorTemperature] = useState<string>('')
  const [stylePersonality, setStylePersonality] = useState<string>('')

  const [isLoadingSettings, setIsLoadingSettings] = useState(false)
  const [isSavingSettings, setIsSavingSettings] = useState(false)
  const [settings, setSettings] = useState<UserSettings | null>(null)
  const [locationValue, setLocationValue] = useState('')
  const { state: geoState, requestLocation } = useGeolocation()

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

  const tabs = [
    { id: 'profile' as TabType, name: 'Profile', icon: User },
    { id: 'preferences' as TabType, name: 'Preferences', icon: Palette },
    { id: 'settings' as TabType, name: 'Settings', icon: Bell },
    { id: 'ai' as TabType, name: 'AI Settings', icon: Cpu },
    { id: 'subscription' as TabType, name: 'Subscription', icon: CreditCard },
    { id: 'support' as TabType, name: 'Support', icon: MessageSquarePlus },
    { id: 'security' as TabType, name: 'Security', icon: Shield },
  ]

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
        setFavoriteColorsCsv(toCsv(prefs.favorite_colors))
        setPreferredStylesCsv(toCsv(prefs.preferred_styles))
        setPreferredOccasionsCsv(toCsv(prefs.preferred_occasions))
        setLikedBrandsCsv(toCsv(prefs.liked_brands))
        setDislikedPatternsCsv(toCsv(prefs.disliked_patterns))
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
      const updated = await updateCurrentUser({
        full_name: fullName.trim() || undefined,
        gender: gender || null,
        birth_date: birthDate || null,
        birth_time: normalizeBirthTimeForApi(birthTime) || null,
        birth_place: birthPlace.trim() || null,
      })
      setUser(updated)
      setIsEditing(false)
      toast({ title: 'Profile updated' })
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
        favorite_colors: parseCsv(favoriteColorsCsv),
        preferred_styles: parseCsv(preferredStylesCsv),
        preferred_occasions: parseCsv(preferredOccasionsCsv),
        liked_brands: parseCsv(likedBrandsCsv),
        disliked_patterns: parseCsv(dislikedPatternsCsv),
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

  const handleUpdateSettings = async (patch: Partial<UserSettings>) => {
    setSettings((prev) => (prev ? { ...prev, ...patch } : prev))
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
    if (!confirm('Delete your FitCheck AI account? This cannot be undone.')) return

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
                  alt=""
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
                onClick={handleAvatarClick}
                disabled={isUploadingAvatar}
                className="absolute bottom-0 right-0 p-2 md:p-2.5 bg-primary rounded-full text-primary-foreground hover:bg-primary/90 disabled:opacity-60 touch-target shadow-md"
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
        <ScrollableTabs className="border-b border-border px-0 md:px-6 lg:px-8 w-full sticky top-[calc(var(--mobile-header-height)+var(--safe-area-top))] z-20 bg-card/95 backdrop-blur-sm md:static">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={cn(
                'flex items-center gap-2 px-4 py-3 md:py-4 text-sm font-medium whitespace-nowrap transition-colors touch-target border-b-2 scroll-snap-start min-w-[100px] justify-center',
                activeTab === tab.id
                  ? 'border-primary text-primary'
                  : 'border-transparent text-muted-foreground hover:text-foreground hover:border-border'
              )}
            >
              <tab.icon className="h-4 w-4" />
              <span className="hidden xs:inline">{tab.name}</span>
              <span className="xs:hidden">{tab.name.split(' ')[0]}</span>
            </button>
          ))}
        </ScrollableTabs>

        {/* Tab content */}
        <div className="px-4 py-4 md:px-6 md:py-6 lg:px-8">
          {activeTab === 'profile' && (
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
            </div>
          )}

          {activeTab === 'preferences' && (
            <div className="space-y-6">
              <div>
                <h3 className="text-base md:text-lg font-medium text-foreground">Style Preferences</h3>
                <p className="text-sm text-muted-foreground">
                  Configure your style preferences to get better recommendations.
                </p>
              </div>

              {isLoadingPreferences ? (
                <div className="p-4 bg-muted rounded-md text-center text-muted-foreground">Loading…</div>
              ) : (
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-foreground">Favorite colors</label>
                    <input
                      value={favoriteColorsCsv}
                      onChange={(e) => setFavoriteColorsCsv(e.target.value)}
                        className="mt-1 block w-full h-12 px-3 border border-border rounded-md text-base md:text-sm bg-background text-foreground focus:ring-primary focus:border-primary appearance-none"
                      placeholder="e.g. black, white, navy"
                    />
                    <p className="mt-1 text-xs text-muted-foreground">Comma-separated list.</p>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-foreground">Preferred styles</label>
                    <input
                      value={preferredStylesCsv}
                      onChange={(e) => setPreferredStylesCsv(e.target.value)}
                        className="mt-1 block w-full h-12 px-3 border border-border rounded-md text-base md:text-sm bg-background text-foreground focus:ring-primary focus:border-primary appearance-none"
                      placeholder="e.g. casual, streetwear, minimalist"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-foreground">Preferred occasions</label>
                    <input
                      value={preferredOccasionsCsv}
                      onChange={(e) => setPreferredOccasionsCsv(e.target.value)}
                        className="mt-1 block w-full h-12 px-3 border border-border rounded-md text-base md:text-sm bg-background text-foreground focus:ring-primary focus:border-primary appearance-none"
                      placeholder="e.g. work, date night, travel"
                    />
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-foreground">Liked brands</label>
                      <input
                        value={likedBrandsCsv}
                        onChange={(e) => setLikedBrandsCsv(e.target.value)}
                        className="mt-1 block w-full h-12 px-3 border border-border rounded-md text-base md:text-sm bg-background text-foreground focus:ring-primary focus:border-primary appearance-none"
                        placeholder="e.g. Nike, Uniqlo"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-foreground">Disliked patterns</label>
                      <input
                        value={dislikedPatternsCsv}
                        onChange={(e) => setDislikedPatternsCsv(e.target.value)}
                        className="mt-1 block w-full h-12 px-3 border border-border rounded-md text-base md:text-sm bg-background text-foreground focus:ring-primary focus:border-primary appearance-none"
                        placeholder="e.g. plaid, polka dots"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-foreground">Color temperature</label>
                      <select
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
                      <label className="block text-sm font-medium text-foreground">Style personality</label>
                      <input
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

          {activeTab === 'settings' && (
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
                      onChange={(val) => setLocationValue(val)}
                      onAutoDetect={async () => {
                        const coords = await requestLocation()
                        if (coords) {
                          const locationString = `${coords.lat.toFixed(4)},${coords.lon.toFixed(4)}`
                          setLocationValue(locationString)
                        }
                      }}
                      isAutoDetecting={geoState.isLoading}
                      error={geoState.error}
                      showAutoDetectButton={true}
                      placeholder="Enter city name or coordinates"
                    />
                  </div>

                  <div className="flex flex-col-reverse gap-3 md:flex-row md:justify-end pt-2">
                    <Button
                      onClick={handleSaveSettings}
                      disabled={isSavingSettings}
                      className="w-full md:w-auto"
                    >
                      {isSavingSettings ? 'Saving…' : 'Save Settings'}
                    </Button>
                  </div>
                </div>
              )}
            </div>
          )}

          {activeTab === 'ai' && (
            <AISettingsPanel />
          )}

          {activeTab === 'subscription' && (
            <SubscriptionPanel />
          )}

          {activeTab === 'support' && (
            <SupportPanel />
          )}

          {activeTab === 'security' && (
            <div className="space-y-6">
              <h3 className="text-base md:text-lg font-medium text-foreground">Security</h3>

              <div className="space-y-4">
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
                    onClick={handleDeleteAccount}
                    className="mt-3 w-full md:w-auto"
                  >
                    Delete Account
                  </Button>
                </div>
              </div>
            </div>
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
