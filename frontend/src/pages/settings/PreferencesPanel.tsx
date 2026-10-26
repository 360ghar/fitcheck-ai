/**
 * Preferences panel — style preferences (colors, styles, occasions, brands, etc.).
 *
 * Self-contained: owns the preferences state and loads/saves via the users API.
 * Extracted from ProfilePage (renders under the "Style" tab).
 */

import { useEffect, useState } from 'react'
import { Button } from '@/components/ui/button'
import { ErrorState } from '@/components/ui/error-state'
import { ChipGroup } from '@/components/ui/chip-group'
import { useToast } from '@/components/ui/use-toast'
import { logger } from '@/lib/logger'
import { useCurrentUser } from '../../stores/authStore'
import { getUserPreferences, updateUserPreferences } from '@/api/users'
import type { UserPreferences } from '@/types'
import { OCCASION_SUGGESTIONS, STYLE_SUGGESTIONS } from '@/lib/style-options'
import { useTranslation } from '@/i18n'

const COLOR_SUGGESTIONS = ['Black', 'White', 'Navy', 'Gray', 'Beige', 'Brown', 'Red', 'Blue', 'Green', 'Pink', 'Olive']
const PATTERN_SUGGESTIONS = ['Plaid', 'Stripes', 'Polka dots', 'Floral', 'Camo', 'Animal print', 'Logo']

export function PreferencesPanel() {
  const { t } = useTranslation()
  const user = useCurrentUser()
  const { toast } = useToast()

  const [isLoadingPreferences, setIsLoadingPreferences] = useState(false)
  const [isSavingPreferences, setIsSavingPreferences] = useState(false)
  const [preferencesError, setPreferencesError] = useState<string | null>(null)
  const [preferencesRetryKey, setPreferencesRetryKey] = useState(0)
  const [preferences, setPreferences] = useState<UserPreferences | null>(null)
  const [favoriteColors, setFavoriteColors] = useState<string[]>([])
  const [preferredStyles, setPreferredStyles] = useState<string[]>([])
  const [preferredOccasions, setPreferredOccasions] = useState<string[]>([])
  const [likedBrands, setLikedBrands] = useState<string[]>([])
  const [dislikedPatterns, setDislikedPatterns] = useState<string[]>([])
  const [colorTemperature, setColorTemperature] = useState<string>('')
  const [stylePersonality, setStylePersonality] = useState<string>('')

  useEffect(() => {
    if (!user) return

    // Load preferences once per session.
    // (These are a separate table and may be created lazily by the backend.)
    setIsLoadingPreferences(true)
    setPreferencesError(null)

    // A fast user switch must not land the previous user's data.
    let cancelled = false

    getUserPreferences()
      .then((prefs) => {
        if (cancelled) return
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
        logger.warn('Failed to load preferences:', err)
        setPreferencesError(
          err instanceof Error ? err.message : t('preferences.loadErrorFallback')
        )
      })
      .finally(() => {
        if (!cancelled) setIsLoadingPreferences(false)
      })

    return () => {
      cancelled = true
    }
    // Keyed on the id, not the whole user object: `user` gets a new identity on
    // every profile save, which would refetch preferences over the values the
    // user just wrote. The cancelled flag above handles the switch case.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user?.id, preferencesRetryKey])

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
        color_temperature: colorTemperature || null,
        style_personality: stylePersonality || null,
      })
      setPreferences(updated)
      toast({ title: t('preferences.saved') })
    } catch {
      // api/client interceptor already toasts the failure.
    } finally {
      setIsSavingPreferences(false)
    }
  }

  return (
    <div className="space-y-4 md:space-y-6">
      <div>
        <h3 className="text-base md:text-lg font-medium text-foreground">{t('preferences.title')}</h3>
        <p className="text-sm text-muted-foreground">
          {t('preferences.subtitle')}
        </p>
      </div>

      {preferencesError ? (
        <ErrorState
          title={t('preferences.loadError')}
          description={preferencesError}
          onRetry={() => setPreferencesRetryKey((key) => key + 1)}
        />
      ) : isLoadingPreferences ? (
        <div className="p-4 bg-muted rounded-md text-center text-muted-foreground">{t('common.loading')}</div>
      ) : (
        <div className="space-y-5">
          <ChipGroup
            label={t('preferences.favoriteColors')}
            value={favoriteColors}
            onChange={setFavoriteColors}
            suggestions={COLOR_SUGGESTIONS}
            placeholder={t('preferences.favoriteColorsPlaceholder')}
          />
          <ChipGroup
            label={t('preferences.preferredStyles')}
            value={preferredStyles}
            onChange={setPreferredStyles}
            suggestions={STYLE_SUGGESTIONS}
            placeholder={t('preferences.preferredStylesPlaceholder')}
          />
          <ChipGroup
            label={t('preferences.preferredOccasions')}
            value={preferredOccasions}
            onChange={setPreferredOccasions}
            suggestions={OCCASION_SUGGESTIONS}
            placeholder={t('preferences.preferredOccasionsPlaceholder')}
          />
          <ChipGroup
            label={t('preferences.likedBrands')}
            value={likedBrands}
            onChange={setLikedBrands}
            placeholder={t('preferences.likedBrandsPlaceholder')}
          />
          <ChipGroup
            label={t('preferences.dislikedPatterns')}
            value={dislikedPatterns}
            onChange={setDislikedPatterns}
            suggestions={PATTERN_SUGGESTIONS}
            placeholder={t('preferences.dislikedPatternsPlaceholder')}
          />

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label htmlFor="color-temp" className="block text-sm font-medium text-foreground">{t('preferences.colorTemperature')}</label>
              <select
                id="color-temp"
                value={colorTemperature}
                onChange={(e) => setColorTemperature(e.target.value)}
                className="mt-1 block w-full h-12 px-3 pe-10 text-base md:text-sm border border-border rounded-md bg-background text-foreground focus:ring-primary focus:border-primary appearance-none"
              >
                <option value="">{t('preferences.colorTempNotSet')}</option>
                <option value="warm">{t('preferences.colorTempWarm')}</option>
                <option value="cool">{t('preferences.colorTempCool')}</option>
                <option value="neutral">{t('preferences.colorTempNeutral')}</option>
              </select>
            </div>
            <div>
              <label htmlFor="style-personality" className="block text-sm font-medium text-foreground">{t('preferences.stylePersonality')}</label>
              <input
                id="style-personality"
                value={stylePersonality}
                onChange={(e) => setStylePersonality(e.target.value)}
                className="mt-1 block w-full h-12 px-3 border border-border rounded-md text-base md:text-sm bg-background text-foreground focus:ring-primary focus:border-primary appearance-none"
                placeholder={t('preferences.stylePersonalityPlaceholder')}
              />
            </div>
          </div>

          <div className="flex flex-col-reverse gap-3 sm:flex-row sm:justify-end">
            <Button
              onClick={handleSavePreferences}
              disabled={isSavingPreferences}
              className="w-full sm:w-auto"
            >
              {isSavingPreferences ? t('common.saving') : t('preferences.save')}
            </Button>
          </div>

          {!preferences && (
            <p className="text-xs text-muted-foreground">
              {t('preferences.autoCreated')}
            </p>
          )}
        </div>
      )}
    </div>
  )
}
