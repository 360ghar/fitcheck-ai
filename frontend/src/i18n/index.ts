/**
 * The i18n entry point. Import `t` from here.
 *
 *     const { t, locale, isRtl } = useTranslation()
 *     <h1>{t('auth.signInTitle')}</h1>
 *     <p>{t('common.itemsCount', { count: items.length })}</p>
 *
 * Pure formatters (`formatDate`, `formatCurrency`) are exported from `runtime`
 * and read the active locale from a module-level value, so they work in plain
 * helpers and event callbacks as well as in render.
 */

export { I18nProvider, useI18n, useLocaleChoices } from './I18nProvider'
export { preloadInitialLocale } from './preload'
export { initialResolve, type ResolvedLocale } from './initialResolve'
export {
  DEFAULT_LOCALE,
  LOCALES,
  isRtlLocale,
  isSupportedLocale,
  localeMeta,
  normalizeLocaleTag,
  type LocaleMeta,
} from './localeMeta'
export { SOURCE_MESSAGES, loadMessages, hasCatalog, type Messages } from './loadLocale'
export { resolveLocale, readBrowserLanguages, type ResolveInput } from './resolveLocale'
export {
  PRODUCT_CURRENCY,
  formatCurrency,
  formatCurrencyFromCents,
  formatDate,
  formatDateTime,
  formatList,
  formatLongDate,
  formatMonth,
  formatNumber,
  formatPercent,
  formatRelativeTime,
  formatTime,
  getActiveLocale,
  getFormattingLocale,
  isRtl,
  pluralCategory,
  subscribeLocale,
  type DateInput,
} from './runtime'
export { useLocaleStore } from '@/stores/localeStore'
export {
  categoryLabel,
  colorLabel,
  conditionLabel,
  seasonLabel,
  styleLabel,
  describeUseCase,
  TAXONOMY,
} from './taxonomy'

import { useCallback, useContext, type ReactElement, type ReactNode } from 'react'
import { IntlContext, createIntl, createIntlCache, type IntlShape } from 'react-intl'
import { SOURCE_MESSAGES } from './loadLocale'
import { DEFAULT_LOCALE } from './localeMeta'

/**
 * English-only formatter used when there is no `<I18nProvider>` above.
 *
 * This exists for unit tests: a component test that mounts one page should not
 * have to build the whole provider tree, and it must not throw
 * "Could not find required `intl` object" either. Falling back to the English
 * source keeps the test asserting on real copy, which is what it did before the
 * page was localized. In the running app the provider is mounted in main.tsx
 * above every route, so this path is unreachable there.
 */
const fallbackIntl: IntlShape = createIntl(
  { locale: 'en', defaultLocale: 'en', messages: SOURCE_MESSAGES, onError: () => {} },
  createIntlCache()
)

/**
 * The full BCP-47 tag (`hi-IN`, `pt-BR`) for cases that format outside
 * `Intl`'s own helpers — `String.prototype.toLocaleUpperCase` takes a locale
 * argument, and it matters: Turkish "i" uppercases to "İ", and a `toUpperCase()`
 * shows the user a different letter than they typed.
 *
 * Reads react-intl's own context (which the provider sets to the full tag) and
 * falls back to `en` outside a provider, for the same reason `useTranslation`
 * does: a single-component test must not need the whole tree.
 */
export function useFormattingLocale(): string {
  const intl = useContext(IntlContext)
  return intl?.locale ?? DEFAULT_LOCALE
}

/** Values an ICU message can interpolate. */
export type TValues = Record<
  string,
  string | number | boolean | Date | null | undefined | ReactElement | ReactElement[]
>

export type Translate = (id: string, values?: TValues) => string

/**
 * `t` plus the active locale.
 *
 * `t('auth.signIn')` rather than `t({ id: 'auth.signIn' })`: FormatJS types
 * `formatMessage` as taking a `MessageDescriptor`, so the wrapper puts the id
 * in one for the caller. Message ids are plain strings rather than a generated
 * typed union because the catalog is regenerated per locale and per edit by
 * `scripts/i18n/translate_web.py`; a generated `.d.ts` would have to be rebuilt
 * inside every edit loop. `check_web_locales.py` covers the same ground (no
 * missing keys, no orphans, ICU parity) without a codegen step.
 *
 * Every id used in the app appears verbatim in `locales/en.json`. A typo renders
 * the id itself at runtime (`settings.languageDescrption`), which is ugly on
 * purpose: the gate fails on the orphan id, and a silent English fallback would
 * ship the typo instead.
 */
export function useTranslation() {
  // `useContext` rather than `useIntl`: `useIntl` throws when no provider is
  // mounted, and a per-component unit test should not need the full app tree.
  const intl = useContext(IntlContext) ?? fallbackIntl

  const t = useCallback(
    (id: string, values?: TValues) => intl.formatMessage({ id }, values as never),
    [intl]
  ) as Translate

  /**
   * Same as `t`, but returns React nodes so a message can embed components:
   *
   *     tRich('auth.agreeToTerms', {
   *       terms: <Link to="/terms">…</Link>,
   *       privacy: <Link to="/privacy">…</Link>,
   *     })
   *
   * This is why a sentence is one message id and never five concatenated JSX
   * fragments: "I agree to the X and Y" puts X and Y in the opposite order in
   * Japanese, and a fragment-joined sentence cannot move them.
   */
  const tRich = useCallback(
    (id: string, values?: TValues) =>
      intl.formatMessage({ id }, values as never) as unknown as ReactNode,
    [intl]
  )

  return {
    t,
    tRich,
    formatNumber: intl.formatNumber,
    formatDate: intl.formatDate,
    formatTime: intl.formatTime,
    formatRelativeTime: intl.formatRelativeTime,
    formatList: intl.formatList,
    locale: intl.locale,
  }
}
