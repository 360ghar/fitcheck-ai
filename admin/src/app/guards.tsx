import { useEffect, useRef } from 'react'
import { Navigate, useLocation } from 'react-router-dom'

import { ForbiddenPage } from '@/app/pages/ForbiddenPage'
import { usePermission } from '@/shared/hooks/usePermission'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { PageLoader } from '@/shared/ui/PageLoader'

/**
 * Auth route guard (spec §4): bootstraps the session on first mount, shows a
 * skeleton while loading, redirects anon users to /login with a returnTo
 * param, and renders the app shell for authenticated admins.
 */
export function RouteGuard({ children }: { children: React.ReactNode }) {
  const status = useSessionStore((state) => state.status)
  const location = useLocation()

  useEffect(() => {
    if (status === 'loading') {
      void useSessionStore.getState().bootstrap()
    }
  }, [status])

  if (status === 'loading') return <PageLoader />

  if (status === 'anon') {
    const returnTo = encodeURIComponent(location.pathname + location.search)
    return <Navigate to={`/login?returnTo=${returnTo}`} replace />
  }

  return children
}

/**
 * Keeps authenticated users out of public routes (login) — bounce them to
 * the dashboard instead.
 *
 * Unlike RouteGuard (which bootstraps inside the authed shell), this guard
 * is reached with the store still in `loading` when the app opens on a
 * public route, so it must bootstrap itself or a user with valid tokens
 * would sit on the login form forever.
 *
 * The bootstrap runs exactly once per mount. A later `loading` status is a
 * login attempt in progress (sessionStore.login sets it) — rendering the
 * PageLoader then would unmount the login form mid-POST and destroy the
 * mutation, silently eating the error state (failed logins showed no
 * banner).
 */
export function PublicOnlyGuard({ children }: { children: React.ReactNode }) {
  const status = useSessionStore((state) => state.status)
  const bootstrappedRef = useRef(false)

  useEffect(() => {
    if (status === 'loading' && !bootstrappedRef.current) {
      bootstrappedRef.current = true
      void useSessionStore.getState().bootstrap()
    }
  }, [status])

  if (status === 'loading' && !bootstrappedRef.current) return <PageLoader />
  if (status === 'authed') return <Navigate to="/dashboard" replace />
  return children
}

/**
 * Per-route permission gate (spec §2). The backend enforces access; this
 * only decides whether to load the page or show the typed 403 page.
 * `permission` omitted = any signed-in admin (mirrors backend require_admin).
 */
export function PermissionRoute({
  permission,
  children,
}: {
  permission?: string
  children: React.ReactNode
}) {
  const { can } = usePermission()
  if (permission && !can(permission)) return <ForbiddenPage />
  return children
}
