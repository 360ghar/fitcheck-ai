import { zodResolver } from '@hookform/resolvers/zod'
import { useEffect, useMemo, useRef, useState } from 'react'
import { useForm } from 'react-hook-form'
import { useTranslation } from 'react-i18next'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { toast } from 'sonner'

import { isGoogleAuthConfigured } from '@/config/env'
import { loginSchema, useLogin, type LoginFormValues } from '@/features/auth/hooks/useLogin'
import { loginErrorKey } from '@/features/auth/lib/loginError'
import { stashOAuthReturnTo } from '@/features/auth/lib/oauthReturnTo'
import { isApiError } from '@/shared/api/errors'
import { cn } from '@/shared/lib/cn'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { Button } from '@/shared/ui/button'
import { Card, CardContent } from '@/shared/ui/card'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/shared/ui/form'
import { Input } from '@/shared/ui/input'

/**
 * Admin login (spec §4). Centered card on the soft-surface wash; zod
 * validation; distinct error banners for invalid credentials / unconfirmed
 * email / non-admin / network failures; returnTo redirect after success.
 * Also surfaces "session expired" toasts when the user lands here after an
 * idle logout (`?reason=idle`) or a token-refresh failure (store
 * `lastLogoutReason === 'unauthorized'`).
 */
export function LoginPage() {
  const { t } = useTranslation('auth')
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  const permissionDenied = useSessionStore((state) => state.permissionDenied)
  const lastLogoutReason = useSessionStore((state) => state.lastLogoutReason)
  const signInWithGoogle = useSessionStore((state) => state.signInWithGoogle)
  const loginMutation = useLogin()
  const [googleLoading, setGoogleLoading] = useState(false)
  const [googleError, setGoogleError] = useState<string | null>(null)

  const schema = useMemo(() => loginSchema(t), [t])
  const form = useForm<LoginFormValues>({
    resolver: zodResolver(schema),
    defaultValues: { email: '', password: '' },
  })

  const returnTo = searchParams.get('returnTo') || '/dashboard'

  // Session-expiry toast, exactly once per page visit: consume the reason so
  // a refresh of the login page (or a failed login attempt) never re-toasts.
  // The ref guards against searchParams identity churn on re-renders.
  const sessionToastShown = useRef(false)
  useEffect(() => {
    if (sessionToastShown.current) return
    if (searchParams.get('reason') === 'idle') {
      sessionToastShown.current = true
      toast.error(t('session.expiredTitle'), { description: t('session.expiredMessage') })
      return
    }
    if (lastLogoutReason === 'unauthorized') {
      sessionToastShown.current = true
      toast.error(t('session.expiredTitle'), { description: t('errors:sessionExpired') })
      useSessionStore.setState({ lastLogoutReason: null })
    }
  }, [lastLogoutReason, searchParams, t])

  async function onSubmit(values: LoginFormValues): Promise<void> {
    try {
      await loginMutation.mutateAsync(values)
      void navigate(returnTo, { replace: true })
    } catch {
      // Banner renders from mutation.error — stay on the page.
    }
  }

  async function handleGoogleSignIn(): Promise<void> {
    setGoogleLoading(true)
    setGoogleError(null)
    try {
      // Stash the target path so the /auth/callback round-trip can restore
      // it; the browser leaves the app for Google's consent screen here.
      stashOAuthReturnTo(returnTo)
      await signInWithGoogle()
    } catch {
      setGoogleLoading(false)
      setGoogleError(t('login.googleError'))
    }
  }

  const errorKey = loginMutation.error ? loginErrorKey(loginMutation.error) : null

  // Server-side failures (backend envelope / 5xx) carry a correlation id the
  // support team can look up — surface it as a reference line, mirroring the
  // ErrorState pattern. Credential/validation errors never show it.
  const loginApiError =
    loginMutation.error && isApiError(loginMutation.error) ? loginMutation.error : null
  const correlationReference =
    loginApiError?.correlationId &&
    (loginApiError.code === 'HTTP_ERROR' || loginApiError.status >= 500)
      ? loginApiError.correlationId
      : null

  return (
    <div className="flex min-h-dvh items-center justify-center bg-soft-surface px-4 py-12">
      <div className="w-full max-w-md">
        <div className="mb-8 flex flex-col items-center gap-3 text-center">
          <img src="/favicon.svg" alt="" className="size-12" aria-hidden="true" />
          <h1 className="text-2xl font-bold tracking-tight text-ink">{t('login.title')}</h1>
          <p className="text-sm text-muted-foreground">{t('login.subtitle')}</p>
        </div>

        <Card>
          <CardContent className="pt-6">
            <Form {...form}>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4" noValidate>
                <FormField
                  control={form.control}
                  name="email"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>{t('login.email')}</FormLabel>
                      <FormControl>
                        <Input
                          type="email"
                          autoComplete="email"
                          placeholder={t('login.emailPlaceholder')}
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="password"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>{t('login.password')}</FormLabel>
                      <FormControl>
                        <Input
                          type="password"
                          autoComplete="current-password"
                          {...field}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                {errorKey ? (
                  <div
                    role="alert"
                    className={cn(
                      'rounded-md border border-destructive/30 bg-destructive/10 px-3 py-2.5 text-sm text-destructive',
                    )}
                  >
                    <p>{t(errorKey)}</p>
                    {correlationReference ? (
                      <p className="mt-1 text-xs text-destructive/80">
                        <span className="font-medium">{t('errors:correlationId')}:</span>{' '}
                        {correlationReference}
                      </p>
                    ) : null}
                  </div>
                ) : null}
                {permissionDenied && !errorKey ? (
                  <div
                    role="alert"
                    className="rounded-md border border-destructive/30 bg-destructive/10 px-3 py-2.5 text-sm text-destructive"
                  >
                    {t('errors.notAdmin')}
                  </div>
                ) : null}

                <Button type="submit" className="w-full" loading={loginMutation.isPending}>
                  {t('login.submit')}
                </Button>
              </form>
            </Form>

            {isGoogleAuthConfigured() ? (
              <>
                <div className="relative my-4" aria-hidden="true">
                  <div className="absolute inset-0 flex items-center">
                    <div className="w-full border-t border-border" />
                  </div>
                  <div className="relative flex justify-center text-xs text-muted-foreground">
                    <span className="bg-card px-2">{t('login.or')}</span>
                  </div>
                </div>
                <Button
                  type="button"
                  variant="outline"
                  className="w-full"
                  onClick={handleGoogleSignIn}
                  loading={googleLoading}
                >
                  <GoogleIcon />
                  {t('login.google')}
                </Button>
                {googleError ? (
                  <div
                    role="alert"
                    className="mt-2 rounded-md border border-destructive/30 bg-destructive/10 px-3 py-2.5 text-sm text-destructive"
                  >
                    <p>{googleError}</p>
                  </div>
                ) : null}
              </>
            ) : null}
          </CardContent>
        </Card>

        <p className="mt-6 text-center text-sm">
          <a
            href="https://fitcheckaiapp.com"
            className="font-medium text-primary transition-colors hover:text-primary-pressed hover:underline focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
          >
            {t('login.backToApp')}
          </a>
        </p>
      </div>
    </div>
  )
}

/** Official Google "G" mark (single-color paths, aria-hidden — decorative). */
function GoogleIcon() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true">
      <path
        fill="#4285F4"
        d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
      />
      <path
        fill="#34A853"
        d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
      />
      <path
        fill="#FBBC05"
        d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
      />
      <path
        fill="#EA4335"
        d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
      />
    </svg>
  )
}
