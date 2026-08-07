import { useCallback } from 'react'

import { can, ROLE_PERMISSIONS, type AdminRole } from '@/shared/lib/permissions'
import { useSessionStore } from '@/shared/stores/sessionStore'

/**
 * Permission gating for UI shaping. The backend is the trust boundary — this
 * only decides what the interface shows. `permissions` comes from the live
 * `/admin/me` response; `roleCan` is the fallback role map for the login
 * screen and tests.
 */
export function usePermission(): {
  role: AdminRole | null
  permissions: string[]
  /** Check one (or any-of) permissions against the live /me list */
  can: (required: string | readonly string[]) => boolean
  /** Check against the static role→permission map (fallback) */
  roleCan: (required: string | readonly string[]) => boolean
} {
  const role = useSessionStore((state) => state.role)
  const permissions = useSessionStore((state) => state.permissions)

  const checkCan = useCallback(
    (required: string | readonly string[]) => can(permissions, required),
    [permissions],
  )
  const checkRoleCan = useCallback(
    (required: string | readonly string[]) =>
      can(role ? ROLE_PERMISSIONS[role] : undefined, required),
    [role],
  )

  return { role, permissions, can: checkCan, roleCan: checkRoleCan }
}
