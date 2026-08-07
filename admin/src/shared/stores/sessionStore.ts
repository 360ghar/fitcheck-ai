import { create } from 'zustand'

import { apiGet, apiPost } from '@/shared/api/client'
import {
  ApiError,
  isApiError,
  PERMISSION_DENIED_CODE,
  UNAUTHORIZED_CODE,
} from '@/shared/api/errors'
import { clearTokens, getTokens, setTokens } from '@/shared/api/tokens'
import type { AdminRole, AdminUser, LoginEnvelope, MeResponse } from '@/shared/api/types'
import { IDLE_CHECK_INTERVAL_MS, IDLE_TIMEOUT_MS } from '@/shared/lib/constants'

/**
 * Session store — auth lifecycle for the admin surface.
 *
 * The backend is the only trust boundary: `GET /api/v1/admin/me` drives role
 * + permissions; tokens live in localStorage (shared/api/tokens.ts) so the
 * API client and this store can never desync.
 *
 * Idle timeout (30 min, spec §4): a module-level watcher resets on
 * pointerdown/keydown and logs out with reason 'idle'. The SessionTimeout
 * provider shows the 25-min warning toast and navigates to /login.
 */

export type SessionStatus = 'loading' | 'authed' | 'anon'
export type BootstrapResult = 'authed' | 'anon' | 'forbidden'
export type LogoutReason = 'manual' | 'idle' | 'unauthorized'

export interface SessionState {
  status: SessionStatus
  user: AdminUser | null
  role: AdminRole | null
  permissions: string[]
  /** True when the user is signed in but has no admin access (403 from /me) */
  permissionDenied: boolean
  /** Last login/bootstrap error, for the login screen */
  error: ApiError | null
  /** Last idle-event timestamp (ms epoch) — reset by touch() */
  idleSince: number
  lastLogoutReason: LogoutReason | null

  bootstrap: () => Promise<BootstrapResult>
  login: (email: string, password: string) => Promise<BootstrapResult>
  logout: (reason?: LogoutReason) => void
  touch: () => void
}

let idleWatcherId: ReturnType<typeof setInterval> | null = null
let idleListenersInstalled = false

function onUserActivity(): void {
  useSessionStore.getState().touch()
}

function stopIdleWatcher(): void {
  if (idleWatcherId !== null) {
    clearInterval(idleWatcherId)
    idleWatcherId = null
  }
  if (idleListenersInstalled && typeof window !== 'undefined') {
    window.removeEventListener('pointerdown', onUserActivity)
    window.removeEventListener('keydown', onUserActivity)
    idleListenersInstalled = false
  }
}

function startIdleWatcher(): void {
  stopIdleWatcher()
  if (typeof window === 'undefined') return
  window.addEventListener('pointerdown', onUserActivity)
  window.addEventListener('keydown', onUserActivity)
  idleListenersInstalled = true
  idleWatcherId = setInterval(() => {
    const { status, idleSince } = useSessionStore.getState()
    if (status === 'authed' && Date.now() - idleSince >= IDLE_TIMEOUT_MS) {
      useSessionStore.getState().logout('idle')
    }
  }, IDLE_CHECK_INTERVAL_MS)
}

function handleUnauthorized(): void {
  const store = useSessionStore.getState()
  store.logout('unauthorized')
  // Record the reason as a store error so the login page can surface a
  // "session expired" toast (the banner itself is driven by mutation.error).
  useSessionStore.setState({
    error: new ApiError({
      status: 401,
      code: UNAUTHORIZED_CODE,
      message: 'Session expired',
    }),
  })
}

if (typeof window !== 'undefined') {
  window.addEventListener('session:unauthorized', handleUnauthorized)
}

const initialState = {
  status: 'loading' as SessionStatus,
  user: null as AdminUser | null,
  role: null as AdminRole | null,
  permissions: [] as string[],
  permissionDenied: false,
  error: null as ApiError | null,
  idleSince: Date.now(),
  lastLogoutReason: null as LogoutReason | null,
}

export const useSessionStore = create<SessionState>()((set, get) => ({
  ...initialState,

  bootstrap: async () => {
    if (!getTokens()?.access_token) {
      set({
        status: 'anon',
        user: null,
        role: null,
        permissions: [],
        permissionDenied: false,
        error: null,
      })
      return 'anon'
    }
    set({ status: 'loading', error: null })
    try {
      const me = await apiGet<MeResponse>('/api/v1/admin/me')
      set({
        status: 'authed',
        user: me.user,
        role: me.role,
        permissions: me.permissions,
        permissionDenied: false,
        error: null,
        idleSince: Date.now(),
      })
      startIdleWatcher()
      return 'authed'
    } catch (error) {
      stopIdleWatcher()
      const apiError = isApiError(error) ? error : null
      const forbidden = isApiError(error) && error.status === 403
      clearTokens()
      set({
        status: 'anon',
        user: null,
        role: null,
        permissions: [],
        permissionDenied: forbidden,
        error: apiError,
      })
      return forbidden ? 'forbidden' : 'anon'
    }
  },

  login: async (email, password) => {
    set({ status: 'loading', permissionDenied: false, error: null })
    try {
      const envelope = await apiPost<LoginEnvelope>('/api/v1/auth/login', { email, password })
      const { access_token, refresh_token } = envelope.data
      if (access_token && refresh_token) {
        setTokens({ access_token, refresh_token })
      }
      const result = await get().bootstrap()
      if (result === 'forbidden') {
        // Signed in, but this account has no admin access — surface it and
        // drop the session so we never loop on a useless token.
        throw new ApiError({
          status: 403,
          code: PERMISSION_DENIED_CODE,
          message: 'Account does not have admin access',
        })
      }
      if (result !== 'authed') {
        // Credentials were accepted but the admin session could not be
        // established (e.g. /admin/me failed after a successful login POST).
        // Never treat this as a successful sign-in: surface the bootstrap
        // error (or a generic one) so the login page renders it instead of
        // silently bouncing back through the route guard.
        throw (
          get().error ??
          new ApiError({
            status: 0,
            code: 'INTERNAL_ERROR',
            message: 'Sign-in could not be completed',
          })
        )
      }
      return result
    } catch (error) {
      clearTokens()
      stopIdleWatcher()
      const apiError = isApiError(error) ? error : null
      set({
        status: 'anon',
        user: null,
        role: null,
        permissions: [],
        permissionDenied: isApiError(error) && error.status === 403,
        error: apiError,
      })
      throw error
    }
  },

  logout: (reason = 'manual') => {
    stopIdleWatcher()
    // Capture tokens BEFORE clearing so the revocation call can present
    // them; the request fires after state reset, fire-and-forget.
    const tokens = getTokens()
    clearTokens()
    set({
      status: 'anon',
      user: null,
      role: null,
      permissions: [],
      permissionDenied: false,
      error: null,
      lastLogoutReason: reason,
      idleSince: Date.now(),
    })
    // Best-effort server-side refresh-token revocation; never block on it.
    // The access token rides the Authorization header (the API client no
    // longer has tokens after the clear above) and the refresh token goes
    // in the body — the backend revokes both.
    if (tokens?.access_token || tokens?.refresh_token) {
      void apiPost(
        '/api/v1/auth/logout',
        { ...(tokens.refresh_token ? { refresh_token: tokens.refresh_token } : {}) },
        {
          skipUnauthorizedEvent: true,
          ...(tokens.access_token
            ? { headers: { Authorization: `Bearer ${tokens.access_token}` } }
            : {}),
        },
      ).catch(() => undefined)
    }
  },

  touch: () => {
    if (get().status === 'authed') {
      set({ idleSince: Date.now() })
    }
  },
}))
