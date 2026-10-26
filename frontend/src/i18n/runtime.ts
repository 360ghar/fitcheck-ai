/**
 * The active locale, outside React.
 *
 * `Intl` formatters live here rather than in a hook because a lot of this app
 * formats dates and numbers in plain helper functions (`lib/utils.ts
 * formatDate`, `formatUsd`) and in event callbacks, not only in render. A hook
 * cannot reach those. So the provider writes the active locale into this
 * module, and everything formats against it.
 *
 * Every formatter is `Intl.*` bound to the active locale. Nothing concatenates
 * `"$" + amount`, and nothing pins `en-US`: `1,234.5` is `1 234,5` in French,
 * `1.234,5` in German and `١٬٢٣٤٫٥` in Arabic, and `Intl` gets all of them
 * right for free. Formatter instances are memoized because constructing an
 * `Intl.DateTimeFormat` is ~100x more expensive than calling `format` on one.
 */

import { DEFAULT_LOCALE, isRtlLocale } from './localeMeta'

/**
 * The locale used for catalogs and for the backend — always a base code
 * (`hi`, `pt`), because `user_settings.language` only accepts base codes and a
 * region variant would make the phone and web disagree about which language is
 * selected.
 */
let activeLocale: string = DEFAULT_LOCALE

/**
 * The locale used for `Intl` formatting — the *full* tag the user's browser
 * reported when we have one (`pt-BR`, `hi-IN`, `zh-Hans-CN`). Region changes
 * date order, decimal separators and currency placement, so throwing the region
 * away would format a Brazilian's date the Portuguese way. When the user picks
 * a language from the in-app list we only know the base code, so formatting
 * falls back to Intl's own default for that language, which is correct enough
 * and never `en-US` by accident.
 */
let activeFormattingLocale: string = DEFAULT_LOCALE

type Listener = (locale: string) => void
const listeners = new Set<Listener>()

export function getActiveLocale(): string {
  return activeLocale
}

export function getFormattingLocale(): string {
  return activeFormattingLocale
}

export function setActiveLocale(locale: string, formattingLocale?: string): void {
  if (locale === activeLocale && (formattingLocale ?? locale) === activeFormattingLocale) {
    return
  }
  activeLocale = locale
  activeFormattingLocale = formattingLocale || locale
  formatterCache.clear()
  for (const listener of listeners) listener(activeLocale)
}

/** Subscribe outside React (used by `lib/utils.ts` formatter invalidation). */
export function subscribeLocale(listener: Listener): () => void {
  listeners.add(listener)
  return () => listeners.delete(listener)
}

export function isRtl(): boolean {
  return isRtlLocale(activeLocale)
}

// ---------------------------------------------------------------------------
// Memoized Intl formatters
// ---------------------------------------------------------------------------

const formatterCache = new Map<string, Intl.DateTimeFormat | Intl.NumberFormat | Intl.ListFormat | Intl.RelativeTimeFormat | Intl.PluralRules>()

function cached<T extends Intl.DateTimeFormat | Intl.NumberFormat | Intl.ListFormat | Intl.RelativeTimeFormat | Intl.PluralRules>(
  key: string,
  // `Intl` constructors are typed per-class; this factory is the seam.
  build: () => T
): T {
  const hit = formatterCache.get(key)
  if (hit) return hit as T
  const made = build()
  formatterCache.set(key, made)
  return made
}

export type DateInput = Date | string | number

function toDate(value: DateInput): Date {
  return value instanceof Date ? value : new Date(value)
}

/** Short date: "Mar 4, 2025" / "4 mars 2025" / "٤ مارس ٢٠٢٥". */
export function formatDate(value: DateInput, options?: Intl.DateTimeFormatOptions): string {
  const opts = options ?? { year: 'numeric', month: 'short', day: 'numeric' }
  const key = `d:${JSON.stringify(opts)}`
  return cached(key, () => new Intl.DateTimeFormat(activeFormattingLocale, opts)).format(toDate(value))
}

/** Long date with weekday: "Tuesday, March 4, 2025". */
export function formatLongDate(value: DateInput): string {
  return formatDate(value, { year: 'numeric', month: 'long', day: 'numeric' })
}

/** Time only: "14:30" / "2:30 PM". */
export function formatTime(value: DateInput, options?: Intl.DateTimeFormatOptions): string {
  const opts = options ?? { hour: 'numeric', minute: '2-digit' }
  const key = `t:${JSON.stringify(opts)}`
  return cached(key, () => new Intl.DateTimeFormat(activeFormattingLocale, opts)).format(toDate(value))
}

/** Date and time together, in the user's own date/time order. */
export function formatDateTime(value: DateInput, options?: Intl.DateTimeFormatOptions): string {
  const opts = options ?? {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  }
  const key = `dt:${JSON.stringify(opts)}`
  return cached(key, () => new Intl.DateTimeFormat(activeFormattingLocale, opts)).format(toDate(value))
}

/** A month name on its own, for calendar headers. */
export function formatMonth(year: number, monthIndex: number, width: 'long' | 'short' = 'long'): string {
  return formatDate(new Date(year, monthIndex, 1), { month: width })
}

export function formatNumber(value: number, options?: Intl.NumberFormatOptions): string {
  const opts = options ?? {}
  const key = `n:${JSON.stringify(opts)}`
  return cached(key, () => new Intl.NumberFormat(activeFormattingLocale, opts)).format(value)
}

/** Percent from a 0..1 ratio, e.g. `formatPercent(0.42)` → "42%". */
export function formatPercent(ratio: number, fractionDigits = 0): string {
  return formatNumber(ratio, { style: 'percent', maximumFractionDigits: fractionDigits })
}

/**
 * Product prices are USD — the card is charged in USD by Stripe and there is no
 * currency-selection feature. So the currency is fixed while the *formatting* is
 * localized: `$1,299` becomes `1 299 $US` in French and `US$ 1.299` in Italian.
 * Formatting a USD amount as the user's local currency would be a lie; that is
 * a pricing feature, not a localization one.
 */
export const PRODUCT_CURRENCY = 'USD'

export function formatCurrency(
  amount: number,
  options?: Intl.NumberFormatOptions & { currency?: string }
): string {
  const { currency = PRODUCT_CURRENCY, ...rest } = options ?? {}
  const opts: Intl.NumberFormatOptions = { style: 'currency', currency, ...rest }
  const key = `c:${JSON.stringify(opts)}`
  return cached(key, () => new Intl.NumberFormat(activeFormattingLocale, opts)).format(amount)
}

/** Cents → localized whole-currency string, e.g. `formatCurrencyFromCents(1300)` → "$13". */
export function formatCurrencyFromCents(
  cents: number,
  options?: Intl.NumberFormatOptions & { currency?: string }
): string {
  return formatCurrency(cents / 100, { maximumFractionDigits: 0, ...options })
}

/** "a, b and c" with the locale's own conjunction and serial comma. */
export function formatList(items: readonly string[], type: 'conjunction' | 'disjunction' = 'conjunction'): string {
  const key = `l:${type}`
  return cached(key, () => new Intl.ListFormat(activeFormattingLocale, { type, style: 'long' })).format(
    items as string[]
  )
}

/** "3 days ago" / "il y a 3 jours". */
export function formatRelativeTime(
  value: DateInput,
  unit: Intl.RelativeTimeFormatUnit,
  options?: Intl.RelativeTimeFormatOptions
): string {
  const opts = options ?? { numeric: 'auto' }
  const key = `r:${JSON.stringify(opts)}`
  return cached(key, () => new Intl.RelativeTimeFormat(activeFormattingLocale, opts)).format(
    typeof value === 'number' ? value : toDate(value).getTime(),
    unit
  )
}

/**
 * The plural category a count falls into in the active language.
 *
 * This is what keeps a hand-written count string honest: English has two
 * categories, Polish has four, Arabic has six. Call it when a UI needs the
 * count to pick a word *outside* an ICU message; inside a message, let
 * `{count, plural, ...}` do the work.
 */
export function pluralCategory(count: number): Intl.LDMLPluralRule {
  const key = 'p:'
  return cached(key, () => new Intl.PluralRules(activeFormattingLocale)).select(count)
}
