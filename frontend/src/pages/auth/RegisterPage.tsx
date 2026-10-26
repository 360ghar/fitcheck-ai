/**
 * Register Page
 * New user registration with referral code support
 */

import { useState, useEffect } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import { useAuthStore } from '../../stores/authStore'
import { Mail, Lock, User, AlertCircle, CheckCircle, Loader2, Gift, Check, Eye, EyeOff } from 'lucide-react'
import { useToast } from '@/components/ui/use-toast'
import { Button } from '@/components/ui/button'
import { validateReferralCode } from '@/api/subscription'
import { PENDING_PROMO_KEY, stashPromoCode } from '@/lib/promo'
import { trackEvent } from '@/lib/analytics'
import SEO from '@/components/seo/SEO'
import { useTranslation } from '@/i18n'
import { getPostAuthDestination, persistAuthReturnTo, withAuthContext } from './authRedirect'

function getPasswordStrength(pwd: string) {
  let strength = 0
  if (pwd.length >= 8) strength++
  if (/[A-Z]/.test(pwd)) strength++
  if (/[a-z]/.test(pwd)) strength++
  if (/\d/.test(pwd)) strength++
  if (/[!@#$%^&*(),.?":{}|<>]/.test(pwd)) strength++
  return strength
}

export default function RegisterPage() {
  const { t, tRich } = useTranslation()
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  const selectedPlan = searchParams.get('plan_type')
  const returnTo = searchParams.get('returnTo')
  // Promo code from a shared campaign URL (e.g. /auth/register?promo=LAUNCH30).
  // Stashed to localStorage so it survives signup (incl. the Google OAuth
  // round-trip) and is consumed by the plan page after login.
  const promoCode = searchParams.get('promo')
  const register = useAuthStore((state) => state.register)
  const signInWithGoogle = useAuthStore((state) => state.signInWithGoogle)
  const isLoading = useAuthStore((state) => state.isLoading)
  const error = useAuthStore((state) => state.error)
  const clearError = useAuthStore((state) => state.clearError)
  const { toast } = useToast()

  const [fullName, setFullName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [agreedToTerms, setAgreedToTerms] = useState(false)
  const [googleLoading, setGoogleLoading] = useState(false)
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)

  // Referral code state
  const [referralCode, setReferralCode] = useState('')
  const [referralValid, setReferralValid] = useState<boolean | null>(null)
  const [referralReferrer, setReferralReferrer] = useState<string | null>(null)
  const [validatingReferral, setValidatingReferral] = useState(false)

  // Check for referral code in URL or localStorage on mount
  useEffect(() => {
    const refParam = searchParams.get('ref')
    const storedRef = localStorage.getItem('pending_referral_code')

    if (refParam) {
      setReferralCode(refParam)
      validateReferral(refParam)
    } else if (storedRef) {
      setReferralCode(storedRef)
      validateReferral(storedRef)
    }

    // Stash a promo code from a shared URL so the plan page can redeem it
    // after signup (survives the Google OAuth round-trip via localStorage).
    if (promoCode) {
      stashPromoCode(promoCode)
    }
  }, [searchParams, promoCode])

  // The store error is global across auth pages. A failed login on this page
  // would otherwise still be shown after navigating to /auth/login (and an
  // OAuth failure shown on the callback page would linger here). Clear it once
  // on mount so each auth page starts clean.
  useEffect(() => {
    clearError()
  }, [clearError])

  // Funnel instrumentation: which registrations arrive with the trial offer
  // attached vs plain organic signups.
  useEffect(() => {
    trackEvent('register_view', { has_promo: Boolean(promoCode) })
  }, [promoCode])

  // Validate referral code
  const validateReferral = async (code: string) => {
    if (code.trim().length < 3) {
      setReferralValid(null)
      setReferralReferrer(null)
      return
    }

    setValidatingReferral(true)
    try {
      const result = await validateReferralCode(code.trim())
      setReferralValid(result.valid)
      setReferralReferrer(result.referrer_name || null)
    } catch {
      setReferralValid(false)
      setReferralReferrer(null)
    } finally {
      setValidatingReferral(false)
    }
  }

  // Handle referral code input change with debounce
  const handleReferralChange = (value: string) => {
    setReferralCode(value)
    setReferralValid(null)
    setReferralReferrer(null)
  }

  // Validate referral on blur
  const handleReferralBlur = () => {
    if (referralCode.trim()) {
      validateReferral(referralCode)
    }
  }

  const passwordStrength = getPasswordStrength(password)
  const passwordsMatch = password === confirmPassword && password.length > 0
  // Require 8+ chars only; strength checklist is guidance, not a hard gate
  const isFormValid =
    email.length > 0 &&
    password.length >= 8 &&
    passwordsMatch &&
    agreedToTerms

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    clearError()

    if (!isFormValid) return

    try {
      const auth = await register(
        email,
        password,
        fullName,
        referralCode.trim() || undefined
      )

      if (!auth?.access_token) {
        // Email confirmation required
        toast({
          title: t('auth.confirmEmailTitle'),
          description: t('auth.confirmEmailBody'),
        })
        navigate(withAuthContext('/auth/login', selectedPlan, returnTo))
        return
      }

      // Show toast if referral was processed by backend
      if (auth?.referral) {
        toast({
          title: auth.referral.success ? t('auth.welcome') : t('auth.referralNotApplied'),
          description: auth.referral.message,
          variant: auth.referral.success ? undefined : 'destructive',
        })
      }

      // The URL's plan_type (if any) has been handled by the destination;
      // clear any stale key left behind by an aborted Google sign-in so it
      // cannot hijack a later Google login.
      localStorage.removeItem('pending_plan_type')
      // A promo may have been stashed earlier (e.g. a failed OAuth attempt
      // redirected here); carry it into the destination so the plan page is
      // still reached when the URL no longer has the param. Mirrors LoginPage.
      const promoFromStorage = localStorage.getItem(PENDING_PROMO_KEY)
      trackEvent('signup_success', { has_promo: Boolean(promoCode || promoFromStorage) })
      navigate(getPostAuthDestination(returnTo, selectedPlan, promoCode || promoFromStorage))
    } catch {
      // Registration error is handled by the store and displayed in UI
    }
  }

  const handleGoogleSignIn = async () => {
    setGoogleLoading(true)
    clearError()

    // Save referral code before OAuth redirect. Keep both intent keys
    // idempotent: set when present, clear when absent, so a stale value from
    // an aborted attempt can never be applied to a later plain Google sign-in.
    if (referralCode.trim()) {
      localStorage.setItem('pending_referral_code', referralCode.trim())
    } else {
      localStorage.removeItem('pending_referral_code')
    }
    if (selectedPlan) {
      localStorage.setItem('pending_plan_type', selectedPlan)
    } else {
      localStorage.removeItem('pending_plan_type')
    }
    persistAuthReturnTo(returnTo)

    try {
      await signInWithGoogle()
      // User will be redirected to Google
    } catch {
      // Drop the pending plan intent (it survives in the URL) so a later plain
      // sign-in cannot be hijacked by stale intent from this aborted attempt.
      // The referral stays stashed so the round-trip restores it into the form.
      localStorage.removeItem('pending_plan_type')
      setGoogleLoading(false)
    }
  }

  return (
    <>
      <SEO
        title="Create Account | FitCheck AI"
        description="Create a free FitCheck AI account and start organizing your wardrobe with AI-powered tools."
        noIndex={true}
      />
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <h1 className="text-xl md:text-2xl font-extrabold text-foreground">
          {t('auth.registerTitle')}
        </h1>
        {promoCode ? (
          <p className="mt-2 text-sm font-medium text-primary">
            {t('auth.promoFirstMonthFree', { code: promoCode })}
          </p>
        ) : (
          <p className="mt-2 text-sm text-muted-foreground">
            {t('auth.firstMonthFree')}
          </p>
        )}
      </div>

      <div className="mt-6 md:mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="rounded-2xl border border-border bg-card py-6 px-4 sm:py-8 sm:px-10">
          {error && (
            <div
              role="alert"
              className="mb-4 p-3 bg-destructive/10 border border-destructive/30 rounded-md flex items-start"
            >
              <AlertCircle className="h-5 w-5 text-destructive mt-0.5 me-2 flex-shrink-0" />
              <p className="text-sm text-destructive">{error}</p>
            </div>
          )}

          {/* Google Sign Up Button - Primary Option */}
          <Button
            type="button"
            variant="outline"
            className="w-full h-12"
            onClick={handleGoogleSignIn}
            disabled={googleLoading || isLoading}
          >
            {googleLoading ? (
              <Loader2 className="me-2 h-4 w-4 animate-spin" />
            ) : (
              <svg className="me-2 h-4 w-4" viewBox="0 0 24 24">
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
            {t('auth.continueWithGoogle')}
          </Button>

          {/* Divider */}
          <div className="relative my-4 sm:my-6">
            <div className="absolute inset-0 flex items-center">
              <span className="w-full border-t border-border" />
            </div>
            <div className="relative flex justify-center text-xs uppercase">
              <span className="bg-card px-2 text-muted-foreground">{t('auth.orRegisterWithEmail')}</span>
            </div>
          </div>

          <form className="space-y-5" onSubmit={handleSubmit}>
            {/* Full Name */}
            <div>
              <label htmlFor="fullName" className="block text-sm font-medium text-foreground">
                {t('auth.fullNameOptional')}
              </label>
              <div className="mt-1 relative rounded-md shadow-sm">
                <div className="absolute inset-y-0 start-0 ps-3 flex items-center pointer-events-none">
                  <User className="h-5 w-5 text-muted-foreground" />
                </div>
                <input
                  id="fullName"
                  name="fullName"
                  type="text"
                  autoComplete="name"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className="block w-full h-12 ps-10 pe-3 text-base border border-border rounded-md bg-background text-foreground placeholder:text-muted-foreground focus:ring-primary focus:border-primary"
                  placeholder={t('auth.fullNamePlaceholder')}
                />
              </div>
            </div>

            {/* Email */}
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

            {/* Password */}
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-foreground">
                {t('auth.passwordLabel')}
              </label>
              <div className="mt-1 relative rounded-md shadow-sm">
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
                  placeholder="••••••••"
                  aria-describedby="password-hint"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((v) => !v)}
                  className="absolute inset-y-0 end-0 pe-3 flex items-center text-muted-foreground hover:text-foreground touch-target"
                  aria-label={showPassword ? t('auth.hidePassword') : t('auth.showPassword')}
                >
                  {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                </button>
              </div>

              {/* Password strength indicator (guidance only) */}
              {password.length > 0 && (
                <div className="mt-2" id="password-hint">
                  <div className="flex items-center space-x-2">
                    <div className="flex-1 bg-muted rounded-full h-2">
                      <div
                        className={`h-2 rounded-full transition-colors ${
                          passwordStrength <= 2
                            ? 'bg-destructive'
                            : passwordStrength <= 3
                            ? 'bg-yellow-500'
                            : 'bg-green-500'
                        }`}
                        style={{ width: `${(passwordStrength / 5) * 100}%` }}
                      />
                    </div>
                    <span className="text-xs text-muted-foreground">
                      {passwordStrength <= 2
                        ? t('auth.passwordStrengthWeak')
                        : passwordStrength <= 3
                          ? t('auth.passwordStrengthFair')
                          : t('auth.passwordStrengthStrong')}
                    </span>
                  </div>
                  <p className="mt-1.5 text-xs text-muted-foreground">
                    {t('auth.passwordHintMin')}{' '}
                    {password.length < 8
                      ? t('auth.passwordHintKeepTyping')
                      : t('auth.passwordHintOptional')}
                  </p>
                </div>
              )}
            </div>

            {/* Confirm Password */}
            <div>
              <label htmlFor="confirmPassword" className="block text-sm font-medium text-foreground">
                {t('auth.confirmPasswordLabel')}
              </label>
              <div className="mt-1 relative rounded-md shadow-sm">
                <div className="absolute inset-y-0 start-0 ps-3 flex items-center pointer-events-none">
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
                  className="block w-full h-12 ps-10 pe-20 text-base border border-border rounded-md bg-background text-foreground placeholder:text-muted-foreground focus:ring-primary focus:border-primary"
                  placeholder="••••••••"
                />
                <div className="absolute inset-y-0 end-0 pe-2 flex items-center gap-1">
                  {confirmPassword.length > 0 && (
                    passwordsMatch ? (
                      <CheckCircle className="h-5 w-5 text-green-500" />
                    ) : (
                      <AlertCircle className="h-5 w-5 text-destructive" />
                    )
                  )}
                  <button
                    type="button"
                    onClick={() => setShowConfirmPassword((v) => !v)}
                    className="p-1.5 text-muted-foreground hover:text-foreground touch-target"
                    aria-label={showConfirmPassword ? t('auth.hidePassword') : t('auth.showPassword')}
                  >
                    {showConfirmPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                  </button>
                </div>
              </div>
              {!passwordsMatch && confirmPassword.length > 0 && (
                <p className="mt-1 text-sm text-destructive">{t('auth.passwordMismatch')}</p>
              )}
            </div>

            {/* Referral Code (Optional) */}
            <div>
              <label htmlFor="referralCode" className="block text-sm font-medium text-foreground">
                {t('auth.referralCodeLabel')} <span className="text-muted-foreground">({t('common.optional')})</span>
              </label>
              <div className="mt-1 relative rounded-md shadow-sm">
                <div className="absolute inset-y-0 start-0 ps-3 flex items-center pointer-events-none">
                  <Gift className="h-5 w-5 text-muted-foreground" />
                </div>
                <input
                  id="referralCode"
                  name="referralCode"
                  type="text"
                  value={referralCode}
                  onChange={(e) => handleReferralChange(e.target.value)}
                  onBlur={handleReferralBlur}
                  className="block w-full h-12 ps-10 pe-10 text-base border border-border rounded-md bg-background text-foreground placeholder:text-muted-foreground focus:ring-primary focus:border-primary"
                  placeholder={t('auth.referralPlaceholder')}
                />
                {(validatingReferral || referralValid !== null) && (
                  <div className="absolute inset-y-0 end-0 pe-3 flex items-center">
                    {validatingReferral ? (
                      <Loader2 className="h-5 w-5 text-muted-foreground animate-spin" />
                    ) : referralValid ? (
                      <Check className="h-5 w-5 text-green-500" />
                    ) : (
                      <AlertCircle className="h-5 w-5 text-destructive" />
                    )}
                  </div>
                )}
              </div>
              {referralValid && referralReferrer && (
                <p className="mt-1 text-sm text-green-600 dark:text-green-400">
                  {t('auth.referralApplied', { name: referralReferrer })}
                </p>
              )}
              {referralValid === false && referralCode.length > 0 && (
                <p className="mt-1 text-sm text-destructive">{t('auth.referralInvalid')}</p>
              )}
            </div>

            {/* Promo code notice - shown when arriving via a shared campaign URL */}
            {promoCode && (
              <div className="rounded-md border border-green-200 dark:border-green-800 bg-green-50 dark:bg-green-900/20 px-3 py-2">
                <p className="text-sm text-green-700 dark:text-green-300">
                  {t('auth.promoFound', { code: promoCode })}
                </p>
              </div>
            )}

            {/* Terms agreement */}
            <div className="flex items-start touch-target">
              <div className="flex items-center h-5">
                <input
                  id="terms"
                  name="terms"
                  type="checkbox"
                  required
                  checked={agreedToTerms}
                  onChange={(e) => setAgreedToTerms(e.target.checked)}
                  className="h-5 w-5 text-primary focus:ring-primary border-border rounded bg-background"
                />
              </div>
              <div className="ms-3 text-sm">
                <label htmlFor="terms" className="text-foreground">
                  {tRich('auth.agreeToTerms', {
                    terms: (
                      <Link to="/terms" target="_blank" rel="noopener noreferrer" className="font-medium text-primary hover:text-primary/80">
                        {t('common.termsOfService')}
                      </Link>
                    ),
                    privacy: (
                      <Link to="/privacy" target="_blank" rel="noopener noreferrer" className="font-medium text-primary hover:text-primary/80">
                        {t('common.privacyPolicy')}
                      </Link>
                    ),
                  })}
                </label>
              </div>
            </div>

            {/* Submit button */}
            <div>
              <Button
                type="submit"
                disabled={!isFormValid || isLoading}
                className="w-full h-12"
              >
                {isLoading ? t('auth.creatingAccount') : t('auth.createAccount')}
              </Button>
            </div>
          </form>

          {/* Sign in link */}
          <div className="mt-6">
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-border" />
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-2 bg-card text-muted-foreground">{t('auth.or')}</span>
              </div>
            </div>

            <div className="mt-6 text-center">
              <p className="text-sm text-muted-foreground">
                {t('auth.haveAccount')}{' '}
                <Link
                  to={withAuthContext('/auth/login', selectedPlan, returnTo)}
                  className="font-medium text-primary hover:text-primary/80"
                >
                  {t('auth.signIn')}
                </Link>
              </p>
            </div>
          </div>
        </div>
      </div>
    </>
  )
}
