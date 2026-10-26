/**
 * The user's language choice, persisted across sessions.
 *
 * `explicit` is the whole point of this store: it is the only thing that can
 * outrank the browser's own languages, and it survives until the user changes
 * it. Stored under its own localStorage key (not inside the auth store) so that
 * signing out — which clears tokens and cached user data — does not also throw
 * away the fact that this person reads Tamil. A signed-out visitor and the same
 * person after signing in must see the same language.
 *
 * `formattingTag` keeps the full BCP-47 tag the browser reported (`pt-BR`,
 * `hi-IN`, `zh-Hans-CN`) when the choice came from device detection, because
 * region decides date order and decimal separators. It is deliberately *not*
 * what we send to the backend: `user_settings.language` takes base codes.
 */

import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import { isSupportedLocale } from '../i18n/localeMeta'

interface LocaleState {
  /** Base language explicitly chosen by the user, or null when they never chose. */
  explicit: string | null
  /** Full tag used for Intl formatting when the locale was detected from the device. */
  formattingTag: string | null
  /** True once localStorage has been read; guards a first-paint flash in the wrong language. */
  hasHydrated: boolean

  setExplicit: (code: string, formattingTag?: string | null) => void
  setHasHydrated: (hydrated: boolean) => void
  /** Clear the explicit choice and fall back to detection (device + account). */
  clearExplicit: () => void
}

export const useLocaleStore = create<LocaleState>()(
  persist(
    (set) => ({
      explicit: null,
      formattingTag: null,
      hasHydrated: false,

      setExplicit: (code, formattingTag) => {
        if (!isSupportedLocale(code)) return
        set({ explicit: code, formattingTag: formattingTag ?? null })
      },

      clearExplicit: () => set({ explicit: null, formattingTag: null }),

      setHasHydrated: (hydrated) => set({ hasHydrated: hydrated }),
    }),
    {
      name: 'fitcheck.locale',
      // `hasHydrated` is runtime state, not a preference: persisting it would
      // make the next page load believe it had already read storage.
      partialize: (state) => ({ explicit: state.explicit, formattingTag: state.formattingTag }),
      onRehydrateStorage: () => (state) => {
        state?.setHasHydrated(true)
      },
    }
  )
)

export const selectExplicitLocale = (state: LocaleState) => state.explicit
export const selectLocaleHydrated = (state: LocaleState) => state.hasHydrated
