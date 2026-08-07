import { format, formatDistanceToNow, parseISO } from 'date-fns'

/**
 * Pure formatting helpers. All user-visible strings come from i18n; these
 * produce locale-shaped output. date-fns is tree-shakeable and immutable.
 *
 * NOTE (i18n): date-fns locale-aware output (e.g. formatDistanceToNow) uses
 * English until a locale is wired in. The en locale is the product language
 * today; adding locales means passing `locale` through here — do not call
 * `toLocaleString` inline in components (spec §12).
 */

const DATE_FORMAT = 'MMM d, yyyy'
const DATETIME_FORMAT = 'MMM d, yyyy, h:mm a'

/** Format an ISO date string as "Aug 1, 2026". Invalid input → "—". */
export function formatDate(iso: string | null | undefined): string {
  if (!iso) return '—'
  const date = parseISO(iso)
  if (Number.isNaN(date.getTime())) return '—'
  return format(date, DATE_FORMAT)
}

/** Format an ISO datetime as "Aug 1, 2026, 10:30 AM". Invalid input → "—". */
export function formatDateTime(iso: string | null | undefined): string {
  if (!iso) return '—'
  const date = parseISO(iso)
  if (Number.isNaN(date.getTime())) return '—'
  return format(date, DATETIME_FORMAT)
}

/** Human-relative time ("5 minutes ago"). Invalid input → "—". */
export function relativeTime(iso: string | null | undefined): string {
  if (!iso) return '—'
  const date = parseISO(iso)
  if (Number.isNaN(date.getTime())) return '—'
  return formatDistanceToNow(date, { addSuffix: true })
}

const moneyFormatterCache = new Map<string, Intl.NumberFormat>()

function moneyFormatter(currency: string): Intl.NumberFormat {
  const cached = moneyFormatterCache.get(currency)
  if (cached) return cached
  const formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
  })
  moneyFormatterCache.set(currency, formatter)
  return formatter
}

/** Format a monetary amount ("$1,234.50"). */
export function formatMoney(amount: number, currency = 'USD'): string {
  return moneyFormatter(currency).format(amount)
}

const numberFormatter = new Intl.NumberFormat('en-US')

/** Format a number with thousands separators ("1,234,567"). */
export function formatNumber(value: number): string {
  return numberFormatter.format(value)
}

/**
 * Format a byte count ("1.5 KB", "3.2 MB"). Uses 1024-based units.
 */
export function formatBytes(bytes: number): string {
  if (!Number.isFinite(bytes) || bytes < 0) return '—'
  if (bytes < 1024) return `${bytes} B`
  const units = ['KB', 'MB', 'GB', 'TB'] as const
  let value = bytes
  let unitIndex = -1
  do {
    value /= 1024
    unitIndex += 1
  } while (value >= 1024 && unitIndex < units.length - 1)
  const decimals = value >= 100 ? 0 : value >= 10 ? 1 : 2
  const rounded = Number(value.toFixed(decimals)).toString()
  return `${rounded} ${units[unitIndex]}`
}

/** Truncate a string to `maxLength` chars, appending an ellipsis. */
export function truncate(value: string, maxLength: number): string {
  if (value.length <= maxLength) return value
  if (maxLength <= 1) return '…'
  return `${value.slice(0, maxLength - 1)}…`
}

/**
 * Safe date parser for schema-typed values. The generated OpenAPI types type
 * every date field as `unknown` (the backend may emit ISO strings, epoch
 * numbers, or raw DB values), so features parse defensively instead of
 * calling parseISO directly. Returns null for anything unusable.
 */
export function toDate(value: unknown): Date | null {
  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value
  }
  if (typeof value === 'number') {
    const date = new Date(value)
    return Number.isNaN(date.getTime()) ? null : date
  }
  if (typeof value === 'string' && value.trim() !== '') {
    const date = parseISO(value)
    return Number.isNaN(date.getTime()) ? null : date
  }
  return null
}

/** Like `formatDate` but accepts any schema-typed value (unknown). */
export function formatDateValue(value: unknown): string {
  const date = toDate(value)
  return date ? format(date, DATE_FORMAT) : '—'
}

/** Like `formatDateTime` but accepts any schema-typed value (unknown). */
export function formatDateTimeValue(value: unknown): string {
  const date = toDate(value)
  return date ? format(date, DATETIME_FORMAT) : '—'
}

/** Like `relativeTime` but accepts any schema-typed value (unknown). */
export function relativeTimeValue(value: unknown): string {
  const date = toDate(value)
  return date ? formatDistanceToNow(date, { addSuffix: true }) : '—'
}
