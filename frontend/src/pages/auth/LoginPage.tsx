/**
 * Login Page
 * User authentication with email and password
 */

import { useState, useEffect } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import { useAuthStore } from '../../stores/authStore'
import { Mail, Lock, AlertCircle, Loader2, Eye, EyeOff } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { PENDING_PROMO_KEY, stashPromoCode } from '@/lib/promo'
import SEO from '@/components/seo/SEO'
import { getPostAuthDestination, persistAuthReturnTo, withAuthContext } from './authRedirect'

export default function LoginPage() {
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  const selectedPlan = searchParams.get('plan_type')
  const returnTo = searchParams.get('returnTo')
  // Promo code from a shared campaign URL (e.g. /auth/login?promo=LAUNCH30).
  // Stashed to localStorage so it survives login and is consumed by the plan
  // page (which also validates it).
  const promoCode = searchParams.get('promo')
  const login = useAuthStore((state) => state.login)
  const signInWithGoogle = useAuthStore((state) => state.signInWithGoogle)
  const isLoading = useAuthStore((state) => state.isLoading)
  const error = useAuthStore((state) => state.error)
  const clearError = useAuthStore((state) => state.clearError)

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [googleLoading, setGoogleLoading] = useState(false)
  const [showPassword, setShowPassword] = useState(false)

  // Stash a promo code from a shared URL before either login path (email or
  // Google) navigates away, so the plan page can redeem it after login.
  useEffect(() => {
    stashPromoCode(promoCode)
  }, [promoCode])

  // The store error is global across auth pages. A failed login on this page
  // would otherwise still be shown after navigating to /auth/register (and an
  // OAuth failure shown on the callback page would linger here). Clear it once
  // on mount so each auth page starts clean.
  useEffect(() => {
    clearError()
  }, [clearError])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    clearError()

    try {
      await login(email, password)
      // The URL's plan_type (if any) has been handled by the destination;
      // clear any stale key left behind by an aborted Google sign-in so it
      // cannot hijack a later Google login.
      localStorage.removeItem('pending_plan_type')
      // A promo may have been stashed earlier (e.g. a failed OAuth attempt
      // redirected here); carry it into the destination so the plan page is
      // still reached when the URL no longer has the param.
      const promoFromStorage = localStorage.getItem(PENDING_PROMO_KEY)
      navigate(getPostAuthDestination(returnTo, selectedPlan, promoCode || promoFromStorage))
    } catch {
      // Error is handled by the store
    }
  }

  const handleGoogleSignIn = async () => {
    setGoogleLoading(true)
    clearError()
    try {
      // Keep `pending_plan_type` idempotent: set it when the URL carries a plan
      // intent, remove it when it does not. A stale value left behind by an
      // aborted Google attempt would otherwise hijack a later plain Google
      // sign-in into the plan page.
      if (selectedPlan) {
        localStorage.setItem('pending_plan_type', selectedPlan)
      } else {
        localStorage.removeItem('pending_plan_type')
      }
      // A promo code from a shared URL must survive the OAuth round-trip.
      stashPromoCode(promoCode)
      persistAuthReturnTo(returnTo)
      await signInWithGoogle()
      // User will be redirected to Google
    } catch {
      // Drop the pending plan so a later plain Google sign-in cannot be
      // hijacked by a stale plan intent from this aborted attempt.
      localStorage.removeItem('pending_plan_type')
      setGoogleLoading(false)
    }
  }

  return (
    <>
      <SEO
        title="Sign In | FitCheck AI"
        description="Sign in to your FitCheck AI account to access your virtual wardrobe and outfit recommendations."
        noIndex={true}
      />
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <h1 className="text-xl md:text-2xl font-extrabold text-foreground">
          Sign in to your account
        </h1>
      </div>

      <div className="mt-6 md:mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="rounded-2xl border border-border bg-card py-6 px-4 sm:py-8 sm:px-10">
          {error && (
            <div
              role="alert"
              className="mb-4 p-3 bg-destructive/10 border border-destructive/30 rounded-md flex items-start"
            >
              <AlertCircle className="h-5 w-5 text-destructive mt-0.5 mr-2 flex-shrink-0" />
              <p className="text-sm text-destructive">{error}</p>
            </div>
          )}

          {/* Google Sign In Button - Primary Option */}
          <Button
            type="button"
            variant="outline"
            className="w-full h-12"
            onClick={handleGoogleSignIn}
            disabled={googleLoading || isLoading}
          >
            {googleLoading ? (
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            ) : (
              <svg className="mr-2 h-4 w-4" viewBox="0 0 24 24">
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
            )}
            Continue with Google
          </Button>

          {/* Divider */}
          <div className="relative my-6">
            <div className="absolute inset-0 flex items-center">
              <span className="w-full border-t border-border" />
            </div>
            <div className="relative flex justify-center text-xs uppercase">
              <span className="bg-card px-2 text-muted-foreground">Or continue with email</span>
            </div>
          </div>

          <form className="space-y-5" onSubmit={handleSubmit}>
            {/* Email */}
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-foreground">
                Email address
              </label>
              <div className="mt-1 relative rounded-md">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
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
                  className="block w-full h-12 pl-10 pr-3 text-base border border-border rounded-md bg-background text-foreground placeholder:text-muted-foreground focus:ring-primary focus:border-primary"
                  placeholder="you@example.com"
                />
              </div>
            </div>

            {/* Password */}
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-foreground">
                Password
              </label>
              <div className="mt-1 relative rounded-md">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Lock className="h-5 w-5 text-muted-foreground" />
                </div>
                <input
                  id="password"
                  name="password"
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="current-password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="block w-full h-12 pl-10 pr-12 text-base border border-border rounded-md bg-background text-foreground placeholder:text-muted-foreground focus:ring-primary focus:border-primary"
                  placeholder="••••••••"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((v) => !v)}
                  className="absolute inset-y-0 right-0 pr-3 flex items-center text-muted-foreground hover:text-foreground touch-target"
                  aria-label={showPassword ? 'Hide password' : 'Show password'}
                >
                  {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                </button>
              </div>
            </div>

            {/* Forgot password */}
            <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-end">
              <div className="text-sm">
                <Link
                  to={withAuthContext('/auth/forgot-password', undefined, returnTo)}
                  className="font-medium text-primary hover:text-primary/80"
                >
                  Forgot password?
                </Link>
              </div>
            </div>

            {/* Submit button */}
            <div>
              <Button
                type="submit"
                disabled={isLoading}
                className="w-full h-12"
              >
                {isLoading ? 'Signing in...' : 'Sign in'}
              </Button>
            </div>
          </form>

          {/* Sign up link */}
          <div className="mt-6 text-center">
            <p className="text-sm text-muted-foreground">
              Don't have an account?{' '}
              <Link
                to={withAuthContext('/auth/register', selectedPlan, returnTo)}
                className="font-medium text-primary hover:text-primary/80"
              >
                Sign up
              </Link>
            </p>
          </div>
        </div>
      </div>
    </>
  )
}
