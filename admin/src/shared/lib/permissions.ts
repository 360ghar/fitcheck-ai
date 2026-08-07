/**
 * Permission registry — mirrors the backend's ROLE_PERMISSIONS map.
 *
 * ⚠️ THE BACKEND IS AUTHORITATIVE. This file only shapes the UI: nav items,
 * buttons, and routes. Every admin endpoint enforces its own
 * require_admin / require_permission check server-side; a mismatch here can
 * only hide or show UI, never grant access. Keep this in step with
 * `backend/app/core/permissions.py` (or wherever ROLE_PERMISSIONS lands) by
 * hand — the `/api/v1/admin/me` response drives what the app actually trusts.
 */

export type AdminRole =
  | 'super_admin'
  | 'admin'
  | 'ops'
  | 'support'
  | 'content_editor'

export const ADMIN_ROLES: readonly AdminRole[] = [
  'super_admin',
  'admin',
  'ops',
  'support',
  'content_editor',
]

/**
 * '*' means every permission (super_admin / admin). Vocabulary must match
 * `backend/app/core/permissions.py` EXACTLY (endpoint → permission map is
 * the contract; see `GET /api/v1/admin/me`). Drift here only hides/shows UI.
 */
export const ROLE_PERMISSIONS: Record<AdminRole, readonly string[]> = {
  super_admin: ['*'],
  admin: ['*'],
  ops: [
    'dashboards.read',
    'users.read',
    'users.write',
    'subscriptions.read',
    'subscriptions.refund',
    'iap.read',
    'ops.read',
    'storage.cleanup',
    'audit.read',
    'search',
  ],
  support: [
    'dashboards.read',
    'users.read',
    'users.write',
    'subscriptions.read',
    'iap.read',
    'quotas.read',
    'feedback.read',
    'feedback.write',
    'audit.read',
    'search',
  ],
  content_editor: [
    'dashboards.read',
    'content.read',
    'content.write',
    'promo.read',
    'search',
  ],
}

/**
 * Whether a permission list (from `/admin/me`) grants `required`.
 * `'*'` in the list grants everything. `required` may be a single permission
 * or a list where ANY match is sufficient.
 */
export function can(
  permissions: readonly string[] | undefined | null,
  required: string | readonly string[],
): boolean {
  if (!permissions) return false
  if (permissions.includes('*')) return true
  const wanted: readonly string[] = Array.isArray(required) ? required : [required]
  return wanted.some((perm) => permissions.includes(perm))
}

/**
 * Role → permission check for UI shaping when `/admin/me` is unavailable
 * (e.g. login screen or tests). Prefer `can()` with the live permission list.
 */
export function roleCan(
  role: string | null | undefined,
  required: string | readonly string[],
): boolean {
  if (!role) return false
  const perms = ROLE_PERMISSIONS[role as AdminRole]
  if (!perms) return false
  return can(perms, required)
}
