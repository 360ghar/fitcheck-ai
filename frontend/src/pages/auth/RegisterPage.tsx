/**
 * Register Page
 * New user registration with referral code support
 */

import { useState, useEffect } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import { useAuthStore } from '../../stores/authStore'
import { Mail, Lock, User, AlertCircle, CheckCircle, Loader2, Gift, Check } from 'lucide-react'
import { useToast } from '@/components/ui/use-toast'
import { Button } from '@/components/ui/button'
import { validateReferralCode } from '@/api/subscription'

export default function RegisterPage() {
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
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
  }, [searchParams])

  // Validate referral code
  const validateReferral = async (code: string) => {
    if (!code.trim()) {
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

  // Password strength validation
  const getPasswordStrength = (pwd: string) => {
    let strength = 0
    if (pwd.length >= 8) strength++
    if (/[A-Z]/.test(pwd)) strength++
    if (/[a-z]/.test(pwd)) strength++
    if (/\d/.test(pwd)) strength++
    if (/[!@#$%^&*(),.?":{}|<>]/.test(pwd)) strength++
    return strength
  }

  const passwordStrength = getPasswordStrength(password)
  const passwordsMatch = password === confirmPassword && password.length > 0
  const isFormValid =
    email.length > 0 &&
    passwordStrength === 5 &&
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
          title: 'Confirm your email',
          description: 'Check your inbox for a confirmation email, then sign in to continue.',
        })
        navigate('/auth/login')
        return
      }

      // Show toast if referral was processed by backend
      if (auth?.referral) {
        toast({
          title: auth.referral.success ? 'Welcome!' : 'Referral not applied',
          description: auth.referral.message,
          variant: auth.referral.success ? undefined : 'destructive',
        })
      }

      navigate('/dashboard')
    } catch {
      // Registration error is handled by the store and displayed in UI
    }
  }

  const handleGoogleSignIn = async () => {
    setGoogleLoading(true)
    clearError()

    // Save referral code before OAuth redirect
    if (referralCode.trim()) {
      localStorage.setItem('pending_referral_code', referralCode.trim())
    }

    try {
      await signInWithGoogle()
      // User will be redirected to Google
    } catch {
      setGoogleLoading(false)
    }
  }

  return (
    <>
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <h2 className="text-xl md:text-2xl font-extrabold text-foreground">
          Create your account
        </h2>
      </div>

      <div className="mt-6 md:mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-card py-6 px-4 shadow rounded-lg sm:py-8 sm:px-10">
          {error && (
            <div className="mb-4 p-3 bg-destructive/10 border border-destructive/30 rounded-md flex items-start">
              <AlertCircle className="h-5 w-5 text-destructive mt-0.5 mr-2 flex-shrink-0" />
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
              <span className="bg-card px-2 text-muted-foreground">Or register with email</span>
            </div>
          </div>

          <form className="space-y-5" onSubmit={handleSubmit}>
            {/* Full Name */}
            <div>
              <label htmlFor="fullName" className="block text-sm font-medium text-foreground">
                Full name
              </label>
              <div className="mt-1 relative rounded-md shadow-sm">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <User className="h-5 w-5 text-muted-foreground" />
                </div>
                <input
                  id="fullName"
                  name="fullName"
                  type="text"
                  autoComplete="name"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className="block w-full h-12 pl-10 pr-3 text-base border border-border rounded-md bg-background text-foreground placeholder:text-muted-foreground focus:ring-primary focus:border-primary"
                  placeholder="John Doe"
                />
              </div>
            </div>

            {/* Email */}
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-foreground">
                Email address
              </label>
              <div className="mt-1 relative rounded-md shadow-sm">
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
              <div className="mt-1 relative rounded-md shadow-sm">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Lock className="h-5 w-5 text-muted-foreground" />
                </div>
                <input
                  id="password"
                  name="password"
                  type="password"
                  autoComplete="new-password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="block w-full h-12 pl-10 pr-3 text-base border border-border rounded-md bg-background text-foreground placeholder:text-muted-foreground focus:ring-primary focus:border-primary"
                  placeholder="••••••••"
                />
              </div>

              {/* Password strength indicator */}
              {password.length > 0 && (
                <div className="mt-2">
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
                      {passwordStrength <= 2 ? 'Weak' : passwordStrength <= 3 ? 'Fair' : 'Strong'}
                    </span>
                  </div>
                  <ul className="mt-1 text-xs text-muted-foreground space-y-1">
                    <li className={password.length >= 8 ? 'text-green-600 dark:text-green-400 flex items-center' : 'flex items-center'}>
                      {password.length >= 8 ? (
                        <CheckCircle className="w-3 h-3 mr-1" />
                      ) : (
                        <span className="w-3 h-3 mr-1" />
                      )}
                      At least 8 characters
                    </li>
                    <li className={/[A-Z]/.test(password) ? 'text-green-600 dark:text-green-400 flex items-center' : 'flex items-center'}>
                      {/[A-Z]/.test(password) ? (
                        <CheckCircle className="w-3 h-3 mr-1" />
                      ) : (
                        <span className="w-3 h-3 mr-1" />
                      )}
                      Uppercase letter
                    </li>
                    <li className={/[a-z]/.test(password) ? 'text-green-600 dark:text-green-400 flex items-center' : 'flex items-center'}>
                      {/[a-z]/.test(password) ? (
                        <CheckCircle className="w-3 h-3 mr-1" />
                      ) : (
                        <span className="w-3 h-3 mr-1" />
                      )}
                      Lowercase letter
                    </li>
                    <li className={/\d/.test(password) ? 'text-green-600 dark:text-green-400 flex items-center' : 'flex items-center'}>
                      {/\d/.test(password) ? (
                        <CheckCircle className="w-3 h-3 mr-1" />
                      ) : (
                        <span className="w-3 h-3 mr-1" />
                      )}
                      Number
                    </li>
                    <li className={/[!@#$%^&*(),.?":{}|<>]/.test(password) ? 'text-green-600 dark:text-green-400 flex items-center' : 'flex items-center'}>
                      {/[!@#$%^&*(),.?":{}|<>]/.test(password) ? (
                        <CheckCircle className="w-3 h-3 mr-1" />
                      ) : (
                        <span className="w-3 h-3 mr-1" />
                      )}
                      Special character
                    </li>
                  </ul>
                </div>
              )}
            </div>

            {/* Confirm Password */}
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
                  type="password"
                  autoComplete="new-password"
                  required
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  className="block w-full h-12 pl-10 pr-10 text-base border border-border rounded-md bg-background text-foreground placeholder:text-muted-foreground focus:ring-primary focus:border-primary"
                  placeholder="••••••••"
                />
                {confirmPassword.length > 0 && (
                  <div className="absolute inset-y-0 right-0 pr-3 flex items-center">
                    {passwordsMatch ? (
                      <CheckCircle className="h-5 w-5 text-green-500" />
                    ) : (
                      <AlertCircle className="h-5 w-5 text-destructive" />
                    )}
                  </div>
                )}
              </div>
              {!passwordsMatch && confirmPassword.length > 0 && (
                <p className="mt-1 text-sm text-destructive">Passwords do not match</p>
              )}
            </div>

            {/* Referral Code (Optional) */}
            <div>
              <label htmlFor="referralCode" className="block text-sm font-medium text-foreground">
                Referral code <span className="text-muted-foreground">(optional)</span>
              </label>
              <div className="mt-1 relative rounded-md shadow-sm">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Gift className="h-5 w-5 text-muted-foreground" />
                </div>
                <input
                  id="referralCode"
                  name="referralCode"
                  type="text"
                  value={referralCode}
                  onChange={(e) => handleReferralChange(e.target.value)}
                  onBlur={handleReferralBlur}
                  className="block w-full h-12 pl-10 pr-10 text-base border border-border rounded-md bg-background text-foreground placeholder:text-muted-foreground focus:ring-primary focus:border-primary"
                  placeholder="e.g., john-abc123"
                />
                {(validatingReferral || referralValid !== null) && (
                  <div className="absolute inset-y-0 right-0 pr-3 flex items-center">
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
                  Referred by {referralReferrer} - you both get 1 month of Pro free!
                </p>
              )}
              {referralValid === false && referralCode.length > 0 && (
                <p className="mt-1 text-sm text-destructive">Invalid referral code</p>
              )}
            </div>

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
              <div className="ml-3 text-sm">
                <label htmlFor="terms" className="text-foreground">
                  I agree to the{' '}
                  <Link to="/terms" className="font-medium text-primary hover:text-primary/80">
                    Terms of Service
                  </Link>{' '}
                  and{' '}
                  <Link to="/privacy" className="font-medium text-primary hover:text-primary/80">
                    Privacy Policy
                  </Link>
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
                {isLoading ? 'Creating account...' : 'Create account'}
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
                <span className="px-2 bg-card text-muted-foreground">Or</span>
              </div>
            </div>

            <div className="mt-6 text-center">
              <p className="text-sm text-muted-foreground">
                Already have an account?{' '}
                <Link
                  to="/auth/login"
                  className="font-medium text-primary hover:text-primary/80"
                >
                  Sign in
                </Link>
              </p>
            </div>
          </div>
        </div>
      </div>
    </>
  )
}
