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

export default function ResetPasswordPage() {
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
    setError(null)
    setSuccess(null)

    if (!accessToken || !refreshToken) {
      setError('Missing reset session. Please re-open the link from your email.')
      return
    }

    if (!passwordsMatch) {
      setError('Passwords do not match.')
      return
    }

    setIsLoading(true)
    try {
      const resp = await confirmPasswordReset({
        access_token: accessToken,
        refresh_token: refreshToken,
        new_password: password,
      })
      setSuccess(resp.message || 'Password updated. You can sign in now.')
      setTimeout(() => navigate('/auth/login'), 800)
    } catch (err) {
      const msg = err instanceof Error ? err.message : 'Failed to reset password'
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
        <h1 className="text-xl md:text-2xl font-extrabold text-foreground">Choose a new password</h1>
        <p className="mt-2 text-sm text-muted-foreground">Your new password must be at least 8 characters.</p>
      </div>

      <div className="mt-6 md:mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="rounded-2xl border border-border bg-card py-6 px-4 sm:py-8 sm:px-10">
          {error && (
            <div role="alert" aria-live="polite" className="mb-4 p-3 bg-destructive/10 border border-destructive/30 rounded-md flex items-start">
              <AlertCircle className="h-5 w-5 text-destructive mt-0.5 mr-2 flex-shrink-0" />
              <p className="text-sm text-destructive">{error}</p>
            </div>
          )}

          {success && (
            <div role="status" aria-live="polite" className="mb-4 p-3 bg-success/10 border border-success/30 rounded-md flex items-start">
              <CheckCircle className="h-5 w-5 text-green-500 mt-0.5 mr-2 flex-shrink-0" />
              <p className="text-sm text-green-800 dark:text-green-300">{success}</p>
            </div>
          )}

          <form className="space-y-5" onSubmit={handleSubmit}>
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-foreground">
                New password
              </label>
              <div className="mt-1 relative rounded-md shadow-sm">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Lock className="h-5 w-5 text-muted-foreground" />
                </div>
                <input
                  id="password"
                  name="password"
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="new-password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="block w-full h-12 pl-10 pr-12 text-base border border-border rounded-md bg-background text-foreground placeholder:text-muted-foreground focus:ring-primary focus:border-primary"
                  placeholder="••••••••"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((visible) => !visible)}
                  className="absolute inset-y-0 right-0 flex items-center pr-3 text-muted-foreground hover:text-foreground touch-target"
                  aria-label={showPassword ? 'Hide new password' : 'Show new password'}
                >
                  {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                </button>
              </div>
            </div>

            <div>
              <label htmlFor="confirmPassword" className="block text-sm font-medium text-foreground">
                Confirm password
              </label>
              <div className="mt-1 relative rounded-md shadow-sm">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Lock className="h-5 w-5 text-muted-foreground" />
                </div>
                <input
                  id="confirmPassword"
                  name="confirmPassword"
                  type={showConfirmPassword ? 'text' : 'password'}
                  autoComplete="new-password"
                  required
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  className="block w-full h-12 pl-10 pr-10 text-base border border-border rounded-md bg-background text-foreground placeholder:text-muted-foreground focus:ring-primary focus:border-primary"
                  placeholder="••••••••"
                />
                {confirmPassword.length > 0 ? (
                  <div className="absolute inset-y-0 right-10 flex items-center">
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
                  className="absolute inset-y-0 right-0 flex items-center pr-3 text-muted-foreground hover:text-foreground touch-target"
                  aria-label={showConfirmPassword ? 'Hide confirm password' : 'Show confirm password'}
                >
                  {showConfirmPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                </button>
              </div>
              {!passwordsMatch && confirmPassword.length > 0 && (
                <p className="mt-1 text-sm text-destructive">Passwords do not match</p>
              )}
            </div>

            <div>
              <Button
                type="submit"
                disabled={isLoading}
                className="w-full h-12"
              >
                {isLoading ? 'Updating…' : 'Update password'}
              </Button>
            </div>
          </form>

          <div className="mt-6 text-center">
            <Link to="/auth/login" className="text-sm font-medium text-primary hover:text-primary/80">
              Back to sign in
            </Link>
          </div>
        </div>
      </div>
    </>
  )
}
