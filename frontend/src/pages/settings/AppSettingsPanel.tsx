/**
 * App Settings panel — notifications, theme, measurement units, language,
 * weather location, and AI settings.
 *
 * Self-contained: owns the settings state and loads/saves via the users API.
 * Extracted from ProfilePage (renders under the "App" tab). Also owns the
 * ThemeSelector which previously lived inline in ProfilePage.
 */

import { useEffect, useRef, useState } from 'react'
import { Cpu, Sun, Moon, Monitor, MapPin } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Switch } from '@/components/ui/switch'
import { useToast } from '@/components/ui/use-toast'
import { logger } from '@/lib/logger'
import { cn } from '@/lib/utils'
import { useTheme } from '@/components/theme'
import { THEMES } from '@/lib/theme'
import { AISettingsPanel, LocationInput } from '@/components/settings'
import { useGeolocation } from '@/hooks/useGeolocation'
import { useCurrentUser } from '../../stores/authStore'
import { getUserSettings, updateUserSettings } from '@/api/users'
import type { UserSettings } from '@/types'

const themeIcons = {
  light: Sun,
  dark: Moon,
  system: Monitor,
} as const

function ThemeSelector() {
  const { theme, setTheme } = useTheme()

  return (
    <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between py-3 border-b border-border">
      <div>
        <p className="text-sm font-medium text-foreground">Theme</p>
        <p className="text-sm text-muted-foreground">Choose your preferred theme</p>
      </div>
      <div className="grid w-full grid-cols-3 gap-2 sm:flex sm:w-auto sm:flex-wrap sm:items-center sm:gap-2">
        {THEMES.map((option) => {
          const Icon = themeIcons[option.value]
          return (
            <button
              key={option.value}
              type="button"
              onClick={() => setTheme(option.value)}
              aria-pressed={theme === option.value}
              className={cn(
                'px-3 py-2 text-sm rounded-md transition-colors flex items-center justify-center gap-1.5 touch-target sm:flex-none',
                theme === option.value
                  ? 'bg-primary text-primary-foreground'
                  : 'bg-muted text-muted-foreground hover:bg-muted/80'
              )}
            >
              <Icon className="h-4 w-4" />
              <span className="hidden xs:inline whitespace-nowrap">{option.label}</span>
            </button>
          )
        })}
      </div>
    </div>
  )
}

export function AppSettingsPanel() {
  const user = useCurrentUser()
  const { toast } = useToast()
  const { state: geoState, requestLocation } = useGeolocation()

  const [isLoadingSettings, setIsLoadingSettings] = useState(false)
  const [isSavingSettings, setIsSavingSettings] = useState(false)
  const [settings, setSettings] = useState<UserSettings | null>(null)
  const [locationValue, setLocationValue] = useState('')
  const [settingsDirty, setSettingsDirty] = useState(false)
  // Bumped on every edit; lets the save handler detect edits made while a
  // save request was in flight (those must not be silently overwritten).
  const settingsEditVersionRef = useRef(0)

  useEffect(() => {
    // A user switch must never show or save the previous user's data: clear
    // stale state before the per-user load so a failed (or missing) load
    // leaves nothing behind.
    setSettings(null)
    setLocationValue('')
    setSettingsDirty(false)

    if (!user) return

    // Load settings once per session.
    // (These are a separate table and may be created lazily by the backend.)
    setIsLoadingSettings(true)

    // A fast user switch must not land the previous user's data.
    let cancelled = false

    getUserSettings()
      .then((s) => {
        if (cancelled) return
        setSettings(s)
        setLocationValue(s.default_location || '')
      })
      .catch((err) => {
        logger.warn('Failed to load settings:', err)
      })
      .finally(() => {
        if (!cancelled) setIsLoadingSettings(false)
      })

    return () => {
      cancelled = true
    }
    // Keyed on the id, not the whole user object: `user` gets a new identity on
    // every profile save, which would refetch settings over the values the
    // user just wrote. The cancelled flag above handles the switch case.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user?.id])

  const handleUpdateSettings = (patch: Partial<UserSettings>) => {
    settingsEditVersionRef.current += 1
    setSettings((prev) => (prev ? { ...prev, ...patch } : prev))
    setSettingsDirty(true)
  }

  const handleSaveSettings = async () => {
    if (!settings) return
    setIsSavingSettings(true)
    const versionAtSave = settingsEditVersionRef.current
    try {
      const updated = await updateUserSettings({
        // Explicit null (not undefined) so the backend clears a stored value
        // (backend applies exclude_unset; omitted fields keep their old value).
        default_location: locationValue.trim() || null,
        timezone: settings.timezone || undefined,
        language: settings.language || undefined,
        measurement_units: settings.measurement_units,
        notifications_enabled: settings.notifications_enabled,
        email_marketing: settings.email_marketing,
      })
      if (settingsEditVersionRef.current === versionAtSave) {
        // No edits landed while saving: adopt the server snapshot.
        setSettings(updated)
        setLocationValue(updated.default_location || '')
        setSettingsDirty(false)
      } else {
        // Newer local edits landed during the request: keep them on top of the
        // server-confirmed values so they are not discarded; stay dirty.
        setSettings((prev) => (prev ? { ...prev, ...updated } : updated))
      }
      toast({ title: 'Settings saved' })
    } catch {
      // api/client interceptor already toasts the failure.
    } finally {
      setIsSavingSettings(false)
    }
  }

  return (
    <div className="space-y-6 md:space-y-8">
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
            <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between py-3 border-b border-border">
              <div>
                <p className="text-sm font-medium text-foreground">Notifications</p>
                <p className="text-sm text-muted-foreground">Enable in-app notifications</p>
              </div>
              <Switch
                checked={settings.notifications_enabled}
                onCheckedChange={(checked) => handleUpdateSettings({ notifications_enabled: checked })}
              />
            </div>

            <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between py-3 border-b border-border">
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

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 py-3">
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

            <div className="flex flex-col-reverse gap-3 sm:flex-row sm:items-center sm:justify-end pt-2">
              {settingsDirty && (
                <p className="text-xs text-amber-600 dark:text-amber-400 sm:mr-auto">
                  Unsaved changes — click Save Settings to apply.
                </p>
              )}
              <Button
                onClick={handleSaveSettings}
                disabled={isSavingSettings || !settingsDirty}
                className="w-full sm:w-auto"
              >
                {isSavingSettings ? 'Saving…' : 'Save Settings'}
              </Button>
            </div>
          </div>
        )}
      </div>

      <div className="border-t border-border pt-6 md:pt-8 space-y-4">
        <div className="flex items-center gap-2">
          <Cpu className="h-5 w-5 text-muted-foreground" />
          <h3 className="text-base md:text-lg font-medium text-foreground">AI Settings</h3>
        </div>
        <AISettingsPanel />
      </div>
    </div>
  )
}
