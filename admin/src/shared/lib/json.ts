/**
 * Defensive accessors for schema-typed JSON payloads. The generated OpenAPI
 * types (src/shared/api/schema.d.ts) leave nested payloads as
 * `{[key: string]: unknown}` — every feature reads them through these so a
 * missing/null/wrong-typed field degrades to a safe default instead of a
 * runtime crash.
 */

export type JsonRecord = Record<string, unknown>

/** First string-ish value for `key` inside a dict; null when absent/not a string. */
export function pickString(
  record: JsonRecord | null | undefined,
  key: string,
): string | null {
  if (!record) return null
  const value = record[key]
  return typeof value === 'string' && value !== '' ? value : null
}

/** Numeric value for `key` inside a dict; null when absent/not a number. */
export function pickNumber(record: JsonRecord | null | undefined, key: string): number | null {
  if (!record) return null
  const value = record[key]
  return typeof value === 'number' && Number.isFinite(value) ? value : null
}

/** Boolean value for `key` inside a dict; undefined when absent. */
export function pickBoolean(record: JsonRecord | null | undefined, key: string): boolean | undefined {
  if (!record) return undefined
  const value = record[key]
  return typeof value === 'boolean' ? value : undefined
}

/** Human-ish name from a dict that may carry full_name/email. */
export function displayName(record: JsonRecord | null | undefined): string {
  return pickString(record, 'full_name') ?? pickString(record, 'email') ?? '—'
}
