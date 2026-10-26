/**
 * Forgot Password Page
 * Requests a password reset email via backend (Supabase Auth)
 */

import { useState } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { Mail, AlertCircle, CheckCircle } from 'lucide-react'
import { requestPasswordReset } from '@/api/auth'
import { Button } from '@/components/ui/button'
import SEO from '@/components/seo/SEO'
import { useTranslation } from '@/i18n'
import { withAuthContext } from './authRedirect'

export default function ForgotPasswordPage() {
  const { t } = useTranslation()
  const [searchParams] = useSearchParams()
  const returnTo = searchParams.get('returnTo')
  const [email, setEmail] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)
    setSuccess(null)
    setIsLoading(true)
    try {
      const resp = await requestPasswordReset(email)
      setSuccess(resp.message || t('auth.forgotSent'))
    } catch (err) {
      const msg = err instanceof Error ? err.message : t('auth.forgotFailed')
      setError(msg)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <>
      <SEO
        title="Reset Password | FitCheck AI"
        description="Reset your FitCheck AI account password. Enter your email to receive a password reset link."
        noIndex={true}
      />
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <h1 className="text-xl md:text-2xl font-extrabold text-foreground">{t('auth.forgotTitle')}</h1>
        <p className="mt-2 text-sm text-muted-foreground">
          {t('auth.forgotSubtitle')}
        </p>
      </div>

      <div className="mt-6 md:mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="rounded-2xl border border-border bg-card py-6 px-4 sm:py-8 sm:px-10">
          {error && (
            <div role="alert" className="mb-4 p-3 bg-destructive/10 border border-destructive/30 rounded-md flex items-start">
              <AlertCircle className="h-5 w-5 text-destructive mt-0.5 me-2 flex-shrink-0" />
              <p className="text-sm text-destructive">{error}</p>
            </div>
          )}

          {success && (
            <div role="status" aria-live="polite" className="mb-4 p-3 bg-success/10 border border-success/30 rounded-md flex items-start">
              <CheckCircle className="h-5 w-5 text-green-500 mt-0.5 me-2 flex-shrink-0" />
              <p className="text-sm text-green-800 dark:text-green-300">{success}</p>
            </div>
          )}

          <form className="space-y-5" onSubmit={handleSubmit}>
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-foreground">
                {t('auth.emailLabel')}
              </label>
              <div className="mt-1 relative rounded-md shadow-sm">
                <div className="absolute inset-y-0 start-0 ps-3 flex items-center pointer-events-none">
                  <Mail className="h-5 w-5 text-muted-foreground" />
                </div>
                <input
                  id="email"
                  name="email"
                  type="email"
                  autoComplete="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="block w-full h-12 ps-10 pe-3 text-base border border-border rounded-md bg-background text-foreground placeholder:text-muted-foreground focus:ring-primary focus:border-primary"
                  placeholder={t('auth.emailPlaceholder')}
                />
              </div>
            </div>

            <div>
              <Button
                type="submit"
                disabled={isLoading}
                className="w-full h-12"
              >
                {isLoading ? t('auth.sending') : t('auth.forgotSubmit')}
              </Button>
            </div>
          </form>

          <div className="mt-6 text-center">
            <Link to={withAuthContext('/auth/login', undefined, returnTo)} className="text-sm font-medium text-primary hover:text-primary/80">
              {t('auth.backToSignIn')}
            </Link>
          </div>
        </div>
      </div>
    </>
  )
}
