/**
 * Reset Password Page
 * Completes password recovery using the Supabase recovery session in the URL hash.
 */

import { useEffect, useMemo, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { AlertCircle, CheckCircle, Eye, EyeOff, Lock } from 'lucide-react'
import { confirmPasswordReset } from '@/api/auth'
import { Button } from '@/components/ui/button'
import SEO from '@/components/seo/SEO'
import { useTranslation, type Translate } from '@/i18n'

function getHashParams(): URLSearchParams {
  const raw = typeof window !== 'undefined' ? window.location.hash : ''
  const hash = raw.startsWith('#') ? raw.slice(1) : raw
  return new URLSearchParams(hash)
}

function getSearchParams(): URLSearchParams {
  const raw = typeof window !== 'undefined' ? window.location.search : ''
  const search = raw.startsWith('?') ? raw.slice(1) : raw
  return new URLSearchParams(search)
}

/**
 * Mirror of the backend `verify_password_strength` policy so a weak password
 * gets a clear inline reason instead of a generic "Failed to reset password"
 * 422. Returns the first unmet requirement, or null when the password is valid.
 */
function getPasswordStrengthError(pwd: string, t: Translate): string | null {
  if (pwd.length < 8) return t('auth.pwdMin8')
  if (!/[A-Z]/.test(pwd)) return t('auth.pwdUpper')
  if (!/[a-z]/.test(pwd)) return t('auth.pwdLower')
  if (!/\d/.test(pwd)) return t('auth.pwdDigit')
  if (!/[1!@#$%^&*(),.?":{}|<>]/.test(pwd)) return t('auth.pwdSpecial')
  return null
}

export default function ResetPasswordPage() {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)

  const { accessToken, refreshToken } = useMemo(() => {
    const hash = getHashParams()
    const search = getSearchParams()
    return {
      accessToken: hash.get('access_token') || search.get('access_token') || '',
      refreshToken: hash.get('refresh_token') || search.get('refresh_token') || '',
    }
  }, [])

  useEffect(() => {
    // Remove tokens from URL after we read them (avoid leaking via screenshots/history).
    try {
      window.history.replaceState(null, document.title, window.location.pathname)
    } catch {
      // no-op
    }
  }, [])

  const passwordsMatch = password === confirmPassword && password.length > 0

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    // A success already scheduled the redirect to /auth/login; a second click
    // during that window would re-POST the same (now-signed-out) recovery
    // session and overwrite the success banner with an error.
    if (success) return
    setError(null)
    setSuccess(null)

    if (!accessToken || !refreshToken) {
      setError(t('auth.missingResetSession'))
      return
    }

    if (!passwordsMatch) {
      setError(t('auth.passwordMismatch'))
      return
    }

    const strengthError = getPasswordStrengthError(password, t)
    if (strengthError) {
      setError(strengthError)
      return
    }

    setIsLoading(true)
    try {
      const resp = await confirmPasswordReset({
        access_token: accessToken,
        refresh_token: refreshToken,
        new_password: password,
      })
      setSuccess(resp.message || t('auth.passwordUpdated'))
      setTimeout(() => navigate('/auth/login'), 800)
    } catch (err) {
      const msg = err instanceof Error ? err.message : t('auth.resetFailed')
      setError(msg)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <>
      <SEO
        title="Set New Password | FitCheck AI"
        description="Set a new password for your FitCheck AI account."
        noIndex={true}
      />
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <h1 className="text-xl md:text-2xl font-extrabold text-foreground">{t('auth.resetTitle')}</h1>
        <p className="mt-2 text-sm text-muted-foreground">{t('auth.resetSubtitle')}</p>
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
              <label htmlFor="password" className="block text-sm font-medium text-foreground">
                {t('auth.newPasswordLabel')}
              </label>
              <div className="mt-1 relative rounded-md">
                <div className="absolute inset-y-0 start-0 ps-3 flex items-center pointer-events-none">
                  <Lock className="h-5 w-5 text-muted-foreground" />
                </div>
                <input
                  id="password"
                  name="password"
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="new-password"
                  required
                  minLength={8}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="block w-full h-12 ps-10 pe-12 text-base border border-border rounded-md bg-background text-foreground placeholder:text-muted-foreground focus:ring-primary focus:border-primary"
                  placeholder={t('auth.passwordPlaceholder')}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((visible) => !visible)}
                  className="absolute inset-y-0 end-0 flex items-center pe-3 text-muted-foreground hover:text-foreground touch-target"
                  aria-label={showPassword ? t('auth.hidePassword') : t('auth.showPassword')}
                >
                  {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                </button>
              </div>
            </div>

            <div>
              <label htmlFor="confirmPassword" className="block text-sm font-medium text-foreground">
                {t('auth.confirmPasswordLabel')}
              </label>
              <div className="mt-1 relative rounded-md">
                <div className="absolute inset-y-0 start-0 ps-3 flex items-center pointer-events-none">
                  <Lock className="h-5 w-5 text-muted-foreground" />
                </div>
                <input
                  id="confirmPassword"
                  name="confirmPassword"
                  type={showConfirmPassword ? 'text' : 'password'}
                  autoComplete="new-password"
                  required
                  minLength={8}
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  className="block w-full h-12 ps-10 pe-10 text-base border border-border rounded-md bg-background text-foreground placeholder:text-muted-foreground focus:ring-primary focus:border-primary"
                  placeholder="••••••••"
                />
                {confirmPassword.length > 0 ? (
                  <div className="absolute inset-y-0 end-10 flex items-center">
                    {passwordsMatch ? (
                      <CheckCircle className="h-5 w-5 text-green-500" />
                    ) : (
                      <AlertCircle className="h-5 w-5 text-destructive" />
                    )}
                  </div>
                ) : null}
                <button
                  type="button"
                  onClick={() => setShowConfirmPassword((visible) => !visible)}
                  className="absolute inset-y-0 end-0 flex items-center pe-3 text-muted-foreground hover:text-foreground touch-target"
                  aria-label={showConfirmPassword ? t('auth.hideConfirmPassword') : t('auth.showConfirmPassword')}
                >
                  {showConfirmPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                </button>
              </div>
              {!passwordsMatch && confirmPassword.length > 0 && (
                <p className="mt-1 text-sm text-destructive">{t('auth.passwordMismatch')}</p>
              )}
            </div>

            <div>
              <Button
                type="submit"
                disabled={isLoading || !!success}
                className="w-full h-12"
              >
                {isLoading ? t('auth.updating') : success ? t('auth.updated') : t('auth.resetSubmit')}
              </Button>
            </div>
          </form>

          <div className="mt-6 text-center">
            <Link to="/auth/login" className="text-sm font-medium text-primary hover:text-primary/80">
              {t('auth.backToSignIn')}
            </Link>
          </div>
        </div>
      </div>
    </>
  )
}
