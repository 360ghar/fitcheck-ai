/**
 * Shared constants — page sizes, stale times, session/idle timings, storage
 * keys. Keep table defaults here so every feature table behaves identically.
 */

export const PAGE_SIZES = [10, 20, 50, 100] as const
export const DEFAULT_PAGE_SIZE = 20

/** TanStack Query staleness per data kind (spec §6). */
export const QUERY_STALE_TIMES = {
  /** List/table data: 30s */
  lists: 30_000,
  /** Static reference data (roles, settings, options): 5min */
  static: 300_000,
} as const

export const QUERY_RETRY = {
  /** Idempotent GETs are safe to retry */
  get: 2,
  /** Mutations are never auto-retried (spec §6) */
  mutations: 0,
} as const

/** Admin session idle timeout: warn at 25min, hard logout at 30min. */
export const IDLE_WARNING_MS = 25 * 60 * 1000
export const IDLE_TIMEOUT_MS = 30 * 60 * 1000
export const IDLE_CHECK_INTERVAL_MS = 30_000

export const SEARCH_DEBOUNCE_MS = 300

/** localStorage keys (namespaced per app). */
export const STORAGE_KEYS = {
  tokens: 'fitcheck_admin_tokens',
  ui: 'fitcheck-admin-ui',
  theme: 'fitcheck-admin-theme',
  /** returnTo stashed before the Google OAuth redirect, consumed by /auth/callback */
  oauthReturnTo: 'fitcheck-admin-oauth-return-to',
} as const

/** Date-range presets for filters (days). */
export const DATE_RANGE_OPTIONS = [
  { key: '7d', labelKey: 'dateRanges.last7d', days: 7 },
  { key: '30d', labelKey: 'dateRanges.last30d', days: 30 },
  { key: '90d', labelKey: 'dateRanges.last90d', days: 90 },
  { key: 'all', labelKey: 'dateRanges.all', days: null },
] as const

export type DateRangeKey = (typeof DATE_RANGE_OPTIONS)[number]['key']
