/**
 * Profile/Settings Page
 * User profile, preferences, and settings management
 */

import { useEffect, useRef, useState } from 'react'
import { useAuthStore, useCurrentUser, useUserDisplayName, useUserAvatar } from '../../stores/authStore'
import { User, Mail, Camera, Shield, Bell, Palette, Cpu, Sun, Moon, Monitor, MapPin } from 'lucide-react'
import { useToast } from '@/components/ui/use-toast'
import { Switch } from '@/components/ui/switch'
import { updateCurrentUser, uploadAvatar, getUserPreferences, updateUserPreferences, getUserSettings, updateUserSettings, deleteAccount } from '@/api/users'
import { requestPasswordReset } from '@/api/auth'
import { AISettingsPanel, LocationInput } from '@/components/settings'
import { useTheme } from '@/components/theme'
import { THEMES } from '@/lib/theme'
import { cn } from '@/lib/utils'
import { useGeolocation } from '@/hooks/useGeolocation'
import type { UserPreferences, UserSettings } from '@/types'

type TabType = 'profile' | 'preferences' | 'settings' | 'ai' | 'security'

const themeIcons = {
  light: Sun,
  dark: Moon,
  system: Monitor,
} as const;

function ThemeSelector() {
  const { theme, setTheme } = useTheme();

  return (
    <div className="flex items-center justify-between py-3 border-b border-gray-200 dark:border-gray-700">
      <div>
        <p className="text-sm font-medium text-gray-900 dark:text-gray-100">Theme</p>
        <p className="text-sm text-gray-500 dark:text-gray-400">Choose your preferred theme</p>
      </div>
      <div className="flex items-center space-x-1">
        {THEMES.map((option) => {
          const Icon = themeIcons[option.value];
          return (
            <button
              key={option.value}
              onClick={() => setTheme(option.value)}
              className={cn(
                'px-3 py-1.5 text-sm rounded-md transition-colors flex items-center gap-1.5',
                theme === option.value
                  ? 'bg-indigo-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-gray-800 dark:text-gray-300 dark:hover:bg-gray-700'
              )}
            >
              <Icon className="h-4 w-4" />
              {option.label}
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

export default function ProfilePage() {
  const user = useCurrentUser()
  const userDisplayName = useUserDisplayName()
  const userAvatar = useUserAvatar()
  const logout = useAuthStore((state) => state.logout)
  const setUser = useAuthStore((state) => state.setUser)

  const [activeTab, setActiveTab] = useState<TabType>('profile')
  const [isEditing, setIsEditing] = useState(false)
  const [fullName, setFullName] = useState(user?.full_name || '')
  const [gender, setGender] = useState<string>(user?.gender || '')
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

  const tabs = [
    { id: 'profile' as TabType, name: 'Profile', icon: User },
    { id: 'preferences' as TabType, name: 'Preferences', icon: Palette },
    { id: 'settings' as TabType, name: 'Settings', icon: Bell },
    { id: 'ai' as TabType, name: 'AI Settings', icon: Cpu },
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
  }, [user?.full_name, user?.gender])

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
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Profile & Settings</h1>
        <p className="mt-2 text-gray-600 dark:text-gray-400">Manage your account and preferences</p>
      </div>

      <div className="bg-white dark:bg-gray-800 shadow dark:shadow-gray-900/50 rounded-lg">
        {/* Avatar section */}
        <div className="px-6 py-6 border-b border-gray-200 dark:border-gray-700">
          <div className="flex items-center">
            <div className="relative">
              {userAvatar ? (
                <img
                  src={userAvatar}
                  alt=""
                  className="h-24 w-24 rounded-full object-cover"
                />
              ) : (
                <div className="h-24 w-24 rounded-full bg-indigo-100 dark:bg-indigo-900/30 flex items-center justify-center">
                  <span className="text-3xl font-bold text-indigo-600 dark:text-indigo-400">
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
                className="absolute bottom-0 right-0 p-1.5 bg-indigo-600 rounded-full text-white hover:bg-indigo-700 disabled:opacity-60"
                title="Change avatar"
              >
                <Camera className="h-4 w-4" />
              </button>
            </div>
            <div className="ml-6">
              <h2 className="text-xl font-medium text-gray-900 dark:text-white">{userDisplayName}</h2>
              <p className="text-sm text-gray-600 dark:text-gray-400">{user?.email}</p>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="border-b border-gray-200 dark:border-gray-700">
          <nav className="flex -mb-px">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center px-6 py-4 border-b-2 font-medium text-sm transition-colors ${
                  activeTab === tab.id
                    ? 'border-indigo-500 text-indigo-600 dark:text-indigo-400'
                    : 'border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300 hover:border-gray-300 dark:hover:border-gray-600'
                }`}
              >
                <tab.icon className="h-4 w-4 mr-2" />
                {tab.name}
              </button>
            ))}
          </nav>
        </div>

        {/* Tab content */}
        <div className="px-6 py-6">
          {activeTab === 'profile' && (
            <div className="space-y-6">
              <div>
                <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-4">Profile Information</h3>
                <div className="grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6">
                  <div className="sm:col-span-6">
                    <label
                      htmlFor="fullName"
                      className="block text-sm font-medium text-gray-700 dark:text-gray-300"
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
                        className="flex-1 min-w-0 block w-full px-3 py-2 rounded-md border border-gray-300 dark:border-gray-600 focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm disabled:bg-gray-100 dark:disabled:bg-gray-700 disabled:text-gray-600 dark:disabled:text-gray-400 bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                      />
                    </div>
                  </div>

                  <div className="sm:col-span-6">
                    <label
                      htmlFor="gender"
                      className="block text-sm font-medium text-gray-700 dark:text-gray-300"
                    >
                      Gender
                    </label>
                    <p className="text-xs text-gray-500 dark:text-gray-400 mb-1">
                      Used for AI-generated outfit visualizations
                    </p>
                    <select
                      id="gender"
                      value={isEditing ? gender : user?.gender || ''}
                      onChange={(e) => setGender(e.target.value)}
                      disabled={!isEditing}
                      className="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 dark:border-gray-600 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md disabled:bg-gray-100 dark:disabled:bg-gray-700 disabled:text-gray-600 dark:disabled:text-gray-400 bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                    >
                      <option value="">Prefer not to say</option>
                      <option value="male">Male</option>
                      <option value="female">Female</option>
                      <option value="non_binary">Non-binary</option>
                    </select>
                  </div>

                  <div className="sm:col-span-6">
                    <label
                      htmlFor="email"
                      className="block text-sm font-medium text-gray-700 dark:text-gray-300"
                    >
                      Email Address
                    </label>
                    <div className="mt-1 relative rounded-md shadow-sm">
                      <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <Mail className="h-5 w-5 text-gray-400 dark:text-gray-500" />
                      </div>
                      <input
                        type="email"
                        id="email"
                        value={user?.email || ''}
                        disabled
                        className="pl-10 flex-1 min-w-0 block w-full px-3 py-2 rounded-md border border-gray-300 dark:border-gray-600 bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400 sm:text-sm"
                      />
                    </div>
                    <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">
                      Contact support to change your email
                    </p>
                  </div>
                </div>

                <div className="mt-6 flex justify-end">
                  {isEditing ? (
                    <div className="flex space-x-3">
                      <button
                        onClick={() => {
                          setIsEditing(false)
                          setFullName(user?.full_name || '')
                          setGender(user?.gender || '')
                        }}
                        className="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
                      >
                        Cancel
                      </button>
                      <button
                        onClick={handleSaveProfile}
                        disabled={isSavingProfile}
                        className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700"
                      >
                        {isSavingProfile ? 'Saving...' : 'Save Changes'}
                      </button>
                    </div>
                  ) : (
                    <button
                      onClick={() => setIsEditing(true)}
                      className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700"
                    >
                      Edit Profile
                    </button>
                  )}
                </div>
              </div>
            </div>
          )}

          {activeTab === 'preferences' && (
            <div className="space-y-6">
              <h3 className="text-lg font-medium text-gray-900 dark:text-white">Style Preferences</h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Configure your style preferences to get better recommendations.
              </p>

              {isLoadingPreferences ? (
                <div className="p-4 bg-gray-50 dark:bg-gray-800 rounded-md text-center text-gray-600 dark:text-gray-400">Loading…</div>
              ) : (
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Favorite colors</label>
                    <input
                      value={favoriteColorsCsv}
                      onChange={(e) => setFavoriteColorsCsv(e.target.value)}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm sm:text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                      placeholder="e.g. black, white, navy"
                    />
                    <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">Comma-separated list.</p>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Preferred styles</label>
                    <input
                      value={preferredStylesCsv}
                      onChange={(e) => setPreferredStylesCsv(e.target.value)}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm sm:text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                      placeholder="e.g. casual, streetwear, minimalist"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Preferred occasions</label>
                    <input
                      value={preferredOccasionsCsv}
                      onChange={(e) => setPreferredOccasionsCsv(e.target.value)}
                      className="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm sm:text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                      placeholder="e.g. work, date night, travel"
                    />
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Liked brands</label>
                      <input
                        value={likedBrandsCsv}
                        onChange={(e) => setLikedBrandsCsv(e.target.value)}
                        className="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm sm:text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                        placeholder="e.g. Nike, Uniqlo"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Disliked patterns</label>
                      <input
                        value={dislikedPatternsCsv}
                        onChange={(e) => setDislikedPatternsCsv(e.target.value)}
                        className="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm sm:text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                        placeholder="e.g. plaid, polka dots"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Color temperature</label>
                      <select
                        value={colorTemperature}
                        onChange={(e) => setColorTemperature(e.target.value)}
                        className="mt-1 block w-full px-3 pr-10 py-2 text-base border-gray-300 dark:border-gray-600 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                      >
                        <option value="">Not set</option>
                        <option value="warm">Warm</option>
                        <option value="cool">Cool</option>
                        <option value="neutral">Neutral</option>
                      </select>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300">Style personality</label>
                      <input
                        value={stylePersonality}
                        onChange={(e) => setStylePersonality(e.target.value)}
                        className="mt-1 block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm sm:text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                        placeholder="e.g. minimalist, bold, classic"
                      />
                    </div>
                  </div>

                  <div className="flex justify-end">
                    <button
                      onClick={handleSavePreferences}
                      disabled={isSavingPreferences}
                      className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 disabled:opacity-60"
                    >
                      {isSavingPreferences ? 'Saving…' : 'Save Preferences'}
                    </button>
                  </div>

                  {!preferences && (
                    <p className="text-xs text-gray-500 dark:text-gray-400">
                      Preferences will be created automatically after your first save.
                    </p>
                  )}
                </div>
              )}
            </div>
          )}

          {activeTab === 'settings' && (
            <div className="space-y-6">
              <h3 className="text-lg font-medium text-gray-900 dark:text-white">App Settings</h3>

              {isLoadingSettings ? (
                <div className="p-4 bg-gray-50 dark:bg-gray-800 rounded-md text-center text-gray-600 dark:text-gray-400">Loading…</div>
              ) : !settings ? (
                <div className="p-4 bg-gray-50 dark:bg-gray-800 rounded-md text-center text-gray-600 dark:text-gray-400">
                  Settings are unavailable. Ensure the database schema is initialized.
                </div>
              ) : (
                <div className="space-y-4">
                  <div className="flex items-center justify-between py-3 border-b border-gray-200 dark:border-gray-700">
                    <div>
                      <p className="text-sm font-medium text-gray-900 dark:text-gray-100">Notifications</p>
                      <p className="text-sm text-gray-500 dark:text-gray-400">Enable in-app notifications</p>
                    </div>
                    <Switch
                      checked={settings.notifications_enabled}
                      onCheckedChange={(checked) => handleUpdateSettings({ notifications_enabled: checked })}
                    />
                  </div>

                  <div className="flex items-center justify-between py-3 border-b border-gray-200 dark:border-gray-700">
                    <div>
                      <p className="text-sm font-medium text-gray-900 dark:text-gray-100">Email Marketing</p>
                      <p className="text-sm text-gray-500 dark:text-gray-400">Receive emails about new features</p>
                    </div>
                    <Switch
                      checked={settings.email_marketing}
                      onCheckedChange={(checked) => handleUpdateSettings({ email_marketing: checked })}
                    />
                  </div>

                  <ThemeSelector />

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 py-3">
                    <div>
                      <p className="text-sm font-medium text-gray-900 dark:text-gray-100">Measurement Units</p>
                      <p className="text-sm text-gray-500 dark:text-gray-400">Choose between metric and imperial</p>
                      <select
                        value={settings.measurement_units}
                        onChange={(e) =>
                          handleUpdateSettings({
                            measurement_units: (e.target.value as 'imperial' | 'metric') || 'imperial',
                          })
                        }
                        className="mt-2 block w-full pl-3 pr-10 py-2 text-base border-gray-300 dark:border-gray-600 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                      >
                        <option value="imperial">Imperial (lbs, ft)</option>
                        <option value="metric">Metric (kg, cm)</option>
                      </select>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-900 dark:text-gray-100">Language</p>
                      <p className="text-sm text-gray-500 dark:text-gray-400">Interface language</p>
                      <select
                        value={settings.language}
                        onChange={(e) => handleUpdateSettings({ language: e.target.value })}
                        className="mt-2 block w-full pl-3 pr-10 py-2 text-base border-gray-300 dark:border-gray-600 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                      >
                        <option value="en">English</option>
                      </select>
                    </div>
                  </div>

                  <div className="py-3 border-b border-gray-200 dark:border-gray-700">
                    <div className="mb-2">
                      <p className="text-sm font-medium text-gray-900 dark:text-gray-100 flex items-center gap-2">
                        <MapPin className="h-4 w-4" />
                        Weather Location
                      </p>
                      <p className="text-sm text-gray-500 dark:text-gray-400">
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

                  <div className="flex justify-end pt-2">
                    <button
                      onClick={handleSaveSettings}
                      disabled={isSavingSettings}
                      className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 disabled:opacity-60"
                    >
                      {isSavingSettings ? 'Saving…' : 'Save Settings'}
                    </button>
                  </div>
                </div>
              )}
            </div>
          )}

          {activeTab === 'ai' && (
            <AISettingsPanel />
          )}

          {activeTab === 'security' && (
            <div className="space-y-6">
              <h3 className="text-lg font-medium text-gray-900 dark:text-white">Security</h3>

              <div className="space-y-4">
                <div className="p-4 border border-gray-200 dark:border-gray-700 rounded-md">
                  <h4 className="text-sm font-medium text-gray-900 dark:text-white">Password</h4>
                  <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                    Change your password to keep your account secure
                  </p>
                  <button
                    onClick={handleSendPasswordReset}
                    className="mt-3 px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
                  >
                    Send Password Reset Email
                  </button>
                </div>

                <div className="p-4 border border-red-200 dark:border-red-800 rounded-md">
                  <h4 className="text-sm font-medium text-red-900 dark:text-red-300">Danger Zone</h4>
                  <p className="text-sm text-red-600 dark:text-red-400 mt-1">
                    Once you delete your account, there is no going back
                  </p>
                  <button
                    onClick={handleDeleteAccount}
                    className="mt-3 px-4 py-2 border border-red-300 dark:border-red-700 rounded-md shadow-sm text-sm font-medium text-red-700 dark:text-red-300 bg-white dark:bg-gray-800 hover:bg-red-50 dark:hover:bg-red-900/20"
                  >
                    Delete Account
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Logout button */}
      <div className="mt-6 text-center">
        <button
          onClick={handleLogout}
          className="inline-flex items-center px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600"
        >
          Sign Out
        </button>
      </div>
    </div>
  )
}
