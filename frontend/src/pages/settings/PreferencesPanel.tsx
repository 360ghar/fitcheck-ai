/**
 * Preferences panel — style preferences (colors, styles, occasions, brands, etc.).
 *
 * Self-contained: owns the preferences state and loads/saves via the users API.
 * Extracted from ProfilePage (renders under the "Style" tab).
 */

import { useEffect, useState } from 'react'
import { Button } from '@/components/ui/button'
import { ChipGroup } from '@/components/ui/chip-group'
import { useToast } from '@/components/ui/use-toast'
import { logger } from '@/lib/logger'
import { useCurrentUser } from '../../stores/authStore'
import { getUserPreferences, updateUserPreferences } from '@/api/users'
import type { UserPreferences } from '@/types'

const COLOR_SUGGESTIONS = ['Black', 'White', 'Navy', 'Gray', 'Beige', 'Brown', 'Red', 'Blue', 'Green', 'Pink', 'Olive']
const STYLE_SUGGESTIONS = ['Casual', 'Formal', 'Business', 'Streetwear', 'Minimalist', 'Sporty', 'Bohemian', 'Classic', 'Elegant']
const OCCASION_SUGGESTIONS = ['Work', 'Date night', 'Travel', 'Wedding', 'Gym', 'Weekend', 'Party', 'Interview']
const PATTERN_SUGGESTIONS = ['Plaid', 'Stripes', 'Polka dots', 'Floral', 'Camo', 'Animal print', 'Logo']

export function PreferencesPanel() {
  const user = useCurrentUser()
  const { toast } = useToast()

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

  useEffect(() => {
    if (!user) return

    // Load preferences once per session.
    // (These are a separate table and may be created lazily by the backend.)
    setIsLoadingPreferences(true)

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
  }, [user?.id])

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
    } catch {
      // api/client interceptor already toasts the failure.
    } finally {
      setIsSavingPreferences(false)
    }
  }

  return (
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
  )
}
