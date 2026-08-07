import { ADMIN_ROLES, type AdminRole } from '@/shared/lib/permissions'

/**
 * Pure helpers for the users feature. The schema types fields like
 * `subscription` as `{[key: string]: unknown} | null`, so every read goes
 * through a defensive accessor here (no non-null assertions in components).
 */

/** A backend row/dict that may carry nested objects. */
export type JsonRecord = Record<string, unknown>

/** First string-ish value for `key` inside a dict; null when absent/not a string. */
export function stringValue(record: JsonRecord | null | undefined, key: string): string | null {
  if (!record) return null
  const value = record[key]
  return typeof value === 'string' && value !== '' ? value : null
}

/** Numeric value for `key` inside a dict; null when absent/not a number. */
export function numberValue(record: JsonRecord | null | undefined, key: string): number | null {
  if (!record) return null
  const value = record[key]
  return typeof value === 'number' && Number.isFinite(value) ? value : null
}

/** Boolean value for `key` inside a dict; undefined when absent. */
export function booleanValue(record: JsonRecord | null | undefined, key: string): boolean | undefined {
  if (!record) return undefined
  const value = record[key]
  return typeof value === 'boolean' ? value : undefined
}

/** Plan type from an embedded subscription dict (null when absent). */
export function subscriptionPlan(
  subscription: JsonRecord | null | undefined,
): string | null {
  return stringValue(subscription, 'plan_type')
}

/** Subscription status from an embedded subscription dict (null when absent). */
export function subscriptionStatus(
  subscription: JsonRecord | null | undefined,
): string | null {
  return stringValue(subscription, 'status')
}

/**
 * i18n key for a role label. Admin roles reuse the layout namespace
 * (`layout:roles.<role>`); `user` and unknown roles fall back to the users
 * namespace. Pages render with `t(key, { defaultValue: rawRole })`.
 */
export function roleLabelKey(role: string | null | undefined): string {
  if (!role) return 'users:roles.unknown'
  if (role === 'user') return 'users:roles.user'
  if ((ADMIN_ROLES as readonly string[]).includes(role)) return `layout:roles.${role}`
  return 'users:roles.unknown'
}

/** i18n key for a plan_type label; unknown plans fall back to the raw value. */
export function planLabelKey(plan: string | null | undefined): string | null {
  if (!plan) return null
  if (['free', 'plus_monthly', 'plus_yearly', 'pro_monthly', 'pro_yearly'].includes(plan)) {
    return `users:plans.${plan}`
  }
  return null
}

/** The admin roles a detail page can assign (backend accepts these + 'user'). */
export function assignableRoles(): readonly (AdminRole | 'user')[] {
  return [...ADMIN_ROLES, 'user']
}

/** Human-ish name for a user dict (detail/activity rows). */
export function displayName(record: JsonRecord | null | undefined): string {
  return stringValue(record, 'full_name') ?? stringValue(record, 'email') ?? '—'
}
