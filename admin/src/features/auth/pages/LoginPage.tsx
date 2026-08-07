import { zodResolver } from '@hookform/resolvers/zod'
import { useEffect, useMemo, useRef } from 'react'
import { useForm } from 'react-hook-form'
import { useTranslation } from 'react-i18next'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { toast } from 'sonner'

import { loginSchema, useLogin, type LoginFormValues } from '@/features/auth/hooks/useLogin'
import { loginErrorKey } from '@/features/auth/lib/loginError'
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
  const loginMutation = useLogin()

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
