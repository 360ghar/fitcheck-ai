import { Loader2 } from 'lucide-react'
import { useEffect, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useNavigate } from 'react-router-dom'

import { consumeOAuthReturnTo, getSafeReturnTo } from '@/features/auth/lib/oauthReturnTo'
import { isApiError } from '@/shared/api/errors'
import { STORAGE_KEYS } from '@/shared/lib/constants'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { Button } from '@/shared/ui/button'

/**
 * Google OAuth callback (supabase.auth.getSession → /api/v1/auth/oauth/sync
 * → bootstrap). Rendered at /auth/callback after Supabase redirects back.
 *
 * Success: navigate to the stashed returnTo (or /dashboard).
 * Non-admin (403 from /me): navigate to /login — permissionDenied is set, so
 * the login page renders its "no admin access" banner.
 * Failure (including the user cancelling at Google's consent screen): show a
 * compact error with a way back to the sign-in form; the returnTo stash is
 * left in place so a retry still lands where the user intended.
 */

export function OAuthCallbackPage() {
  const { t } = useTranslation('auth')
  const navigate = useNavigate()
  const handleOAuthCallback = useSessionStore((state) => state.handleOAuthCallback)
  const [failed, setFailed] = useState(false)
  const [isCancelled, setIsCancelled] = useState(false)
  // StrictMode runs effects twice in dev; a second oauth/sync would fire
  // after the session was already consumed. Run exactly once per mount.
  const hasStartedRef = useRef(false)

  useEffect(() => {
    if (hasStartedRef.current) return
    hasStartedRef.current = true

    void (async () => {
      try {
        const result = await handleOAuthCallback()
        if (result === 'forbidden') {
          void navigate('/login', { replace: true })
          return
        }
        if (result !== 'authed') {
          setFailed(true)
          return
        }
        void navigate(consumeOAuthReturnTo() ?? '/dashboard', { replace: true })
      } catch (err: unknown) {
        if (isApiError(err) && err.code === 'OAUTH_NO_SESSION') {
          setIsCancelled(true)
        }
        setFailed(true)
      }
    })()
  }, [handleOAuthCallback, navigate, t])

  if (failed) {
    const pendingReturnTo = getSafeReturnTo(localStorage.getItem(STORAGE_KEYS.oauthReturnTo))
    const loginHref = pendingReturnTo
      ? `/login?returnTo=${encodeURIComponent(pendingReturnTo)}`
      : '/login'
    return (
      <div className="flex min-h-dvh items-center justify-center bg-soft-surface px-4 py-12">
        <div className="w-full max-w-md text-center">
          <h1 className="text-2xl font-bold tracking-tight text-ink">{t('login.title')}</h1>
          <div
            role="alert"
            className="mt-6 rounded-md border border-destructive/30 bg-destructive/10 px-3 py-2.5 text-sm text-destructive"
          >
            <p>{isCancelled ? t('callback.cancelled') : t('callback.failed')}</p>
          </div>
          <Button asChild variant="secondary" className="mt-6">
            <a href={loginHref}>{t('callback.backToLogin')}</a>
          </Button>
        </div>
      </div>
    )
  }

  return (
    <div
      className="flex min-h-dvh items-center justify-center bg-soft-surface px-4 py-12"
      role="status"
      aria-live="polite"
    >
      <div className="text-center">
        <Loader2 className="mx-auto mb-4 size-8 animate-spin text-primary" aria-hidden="true" />
        <p className="text-sm text-muted-foreground">{t('callback.completing')}</p>
      </div>
    </div>
  )
}
