/**
 * The i18n provider: resolves a language, lazy-loads its catalog, applies
 * document direction, and keeps the account in sync.
 *
 * Why `react-intl` (FormatJS) and not `i18next`: this app needs ICU
 * MessageFormat, not key/value substitution. Every plural, every "3 items"
 * and every "{count} pts" has to pick a category — English has 2 categories,
 * Polish 4, Arabic 6 — and Russian "1 файл / 2 файла / 5 файлов" cannot be
 * expressed as text concatenation at all. FormatJS implements ICU natively
 * (`{count, plural, =0 {…} one {…} few {…} many {…} other {…}}`), so plural
 * selection comes from `Intl.PluralRules` for all 43 languages with no
 * per-language code, and the message text a translator edits is the same text
 * that ships. i18next reaches the same place only with an ICU plugin plus a
 * formatter, which is more to configure and one more thing to get wrong on the
 * one screen (a paywall price, an item count) where being wrong is expensive.
 * FormatJS also gives `{items, list}` via `Intl.ListFormat`; the cost is ~11 kB
 * gzip of runtime in the entry chunk.
 */

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
  type ReactNode,
} from 'react'
import { IntlProvider } from 'react-intl'
import { useAuthStore } from '@/stores/authStore'
import { useLocaleStore } from '@/stores/localeStore'
import { updateUserSettings } from '@/api/users'
import { logger } from '@/lib/logger'
import { fetchAccountLanguage, resetAccountLanguage } from './accountLanguage'
import { initialResolve, type ResolvedLocale } from './initialResolve'
import { SOURCE_MESSAGES, getLoadedMessages, loadMessages, type Messages } from './loadLocale'
import { DEFAULT_LOCALE, LOCALES, isRtlLocale, localeMeta, normalizeLocaleTag } from './localeMeta'
import { setActiveLocale } from './runtime'

interface I18nContextValue {
  /** Base language for the active UI, e.g. `hi`. This is what the backend stores. */
  locale: string
  /** Full BCP-47 tag used for Intl formatting, e.g. `hi-IN`. */
  formattingLocale: string
  /** True while a newly selected catalog is still downloading. */
  isSwitching: boolean
  isRtl: boolean
  /** Explicitly choose a language. Persists locally and syncs to the account. */
  setLocale: (code: string) => Promise<void>
  /** True when the active locale came from an explicit choice (not detection). */
  hasExplicitChoice: boolean
}

const I18nContext = createContext<I18nContextValue | null>(null)

export function I18nProvider({ children }: { children: ReactNode }) {
  // Resolved once, synchronously: persist's localStorage hydration runs when the
  // store module is created, so the stored choice is already readable on the
  // first render and a warm visit never double-paints. `preloadInitialLocale()`
  // in main.tsx has usually already fetched this catalog by now.
  const initial = useRef<ResolvedLocale | null>(null)
  if (initial.current === null) initial.current = initialResolve()

  const [resolved, setResolved] = useState<ResolvedLocale>(initial.current)
  const [messages, setMessages] = useState<Messages>(
    () => getLoadedMessages(initial.current!.locale) ?? SOURCE_MESSAGES
  )
  const [isSwitching, setIsSwitching] = useState(false)

  const explicit = useLocaleStore((state) => state.explicit)
  const hasExplicitChoice = explicit !== null
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated)

  /** The locale whose catalog is already in `messages`. */
  const loadedFor = useRef(initial.current.locale)

  // Keep the non-React runtime in step with React state so `lib/utils.ts` and
  // event handlers format against the same locale the UI renders. Done during
  // render, not in an effect: an effect runs *after* children paint, so the
  // first render after a language switch would format dates in the old locale
  // and never repaint them. Setting an idempotent module value keyed on
  // `resolved` is safe to repeat.
  useMemo(() => {
    setActiveLocale(resolved.locale, resolved.formattingLocale)
    return resolved.locale
  }, [resolved])

  useEffect(() => {
    if (typeof document === 'undefined') return
    document.documentElement.lang = resolved.formattingLocale
    document.documentElement.dir = isRtlLocale(resolved.locale) ? 'rtl' : 'ltr'
  }, [resolved])

  // Download the catalog for whatever locale we are rendering. The swap is in
  // place: the previous messages stay on screen until the new ones arrive, so
  // switching language never blanks a page.
  useEffect(() => {
    if (loadedFor.current === resolved.locale) return
    let cancelled = false
    const target = resolved.locale
    setIsSwitching(true)
    loadMessages(target).then((next) => {
      if (cancelled) return
      loadedFor.current = target
      setMessages(next)
      setIsSwitching(false)
    })
    return () => {
      cancelled = true
    }
  }, [resolved.locale])

  // Adopt the account's language when the user has never chosen on this browser.
  // This is what keeps web and phone agreeing: the phone writes
  // `user_settings.language`, and the web reads it back on the next visit.
  useEffect(() => {
    if (!isAuthenticated) {
      resetAccountLanguage()
      return
    }
    let cancelled = false
    fetchAccountLanguage().then((accountLanguage) => {
      if (cancelled) return
      // A deliberate local choice outranks the account value.
      if (useLocaleStore.getState().explicit) return
      const account = normalizeLocaleTag(accountLanguage)
      if (!account) return
      setResolved((current) =>
        current.locale === account ? current : { locale: account, formattingLocale: account }
      )
    })
    return () => {
      cancelled = true
    }
  }, [isAuthenticated])

  const setLocale = useCallback(async (code: string) => {
    const base = normalizeLocaleTag(code)
    if (!base) return
    // Persist first: the choice is the user's, and a failed network call must
    // not cost them the language they just picked.
    useLocaleStore.getState().setExplicit(base, null)
    setResolved({ locale: base, formattingLocale: base })

    // Mirror the choice to the backend so the phone app picks it up. Base code
    // only: `user_settings.language` is validated against
    // `backend/app/core/i18n.SUPPORTED_LANGUAGES`, which holds no region
    // variants, so sending `hi-IN` would be normalized back to `en`.
    if (useAuthStore.getState().isAuthenticated) {
      try {
        await updateUserSettings({ language: base })
      } catch (error) {
        // The local choice already applied. Never roll the UI back over a
        // network failure — the user would watch their language revert.
        logger.warn('i18n: could not sync language to account', error)
      }
    }
  }, [])

  const value = useMemo<I18nContextValue>(
    () => ({
      locale: resolved.locale,
      formattingLocale: resolved.formattingLocale,
      isSwitching,
      isRtl: isRtlLocale(resolved.locale),
      setLocale,
      hasExplicitChoice,
    }),
    [resolved, isSwitching, setLocale, hasExplicitChoice]
  )

  return (
    <I18nContext.Provider value={value}>
      <IntlProvider
        locale={resolved.formattingLocale}
        defaultLocale={DEFAULT_LOCALE}
        messages={messages}
        // A missing key is a build bug the checker catches; at runtime the
        // English source is shown instead, so this must not throw or spam.
        onError={(error) => {
          if (error.code === 'MISSING_TRANSLATION') return
          logger.warn('i18n:', error.message)
        }}
      >
        {children}
      </IntlProvider>
    </I18nContext.Provider>
  )
}

export function useI18n(): I18nContextValue {
  const context = useContext(I18nContext)
  if (!context) throw new Error('useI18n must be used inside <I18nProvider>')
  return context
}

/**
 * The picker's data, plus the current selection. Sorted by English name so the
 * order is stable across languages — sorting by native name produces a different
 * order in every script and makes the list impossible to learn.
 */
export function useLocaleChoices() {
  const { locale, setLocale, hasExplicitChoice } = useI18n()
  return {
    locale,
    setLocale,
    hasExplicitChoice,
    current: localeMeta(locale),
    locales: useMemo(
      () => [...LOCALES].sort((a, b) => a.english.localeCompare(b.english, 'en')),
      []
    ),
  }
}
