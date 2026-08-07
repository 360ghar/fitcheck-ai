import type { JsonRecord } from '@/shared/lib/json'

/**
 * Pure helpers for rendering schema-typed search results defensively. The
 * backend search service selects specific columns per entity kind:
 *
 *   users:       id, email, full_name, avatar_url, is_active, role, created_at
 *   posts:       id, slug, title, category, is_published, created_at
 *   tickets:     id, subject, category, status, created_at
 *   promo_codes: id, code, plan_type, active, used_count, expires_at, created_at
 *
 * But the OpenAPI type is `{[key: string]: unknown}[]` — so components never
 * trust the shape; they use these accessors with fallbacks.
 */

/** String-ish value for `key`; null when absent/empty/not a string. */
export function resultString(record: JsonRecord | undefined | null, key: string): string | null {
  if (!record) return null
  const value = record[key]
  return typeof value === 'string' && value.trim() !== '' ? value : null
}

/** Stable row id: `id` key first, then a stringified index fallback. */
export function resultKey(record: JsonRecord | undefined | null, index: number): string {
  return resultString(record, 'id') ?? `result-${index}`
}

/** First non-null string among `keys` (heuristic label extraction). */
export function firstString(record: JsonRecord | undefined | null, keys: readonly string[]): string | null {
  for (const key of keys) {
    const value = resultString(record, key)
    if (value) return value
  }
  return null
}

/** Group headings for each entity kind — one entry per non-empty array. */
export function groupHasResults(
  results: Record<'users' | 'posts' | 'tickets' | 'promo_codes', readonly JsonRecord[] | undefined>,
): boolean {
  return (
    (results.users?.length ?? 0) > 0 ||
    (results.posts?.length ?? 0) > 0 ||
    (results.tickets?.length ?? 0) > 0 ||
    (results.promo_codes?.length ?? 0) > 0
  )
}
