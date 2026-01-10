import { useState } from 'react'
import { Link } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { AnimatedSection } from './AnimatedSection'
import { ArrowRight, Mail, User, CheckCircle2, Loader2 } from 'lucide-react'
import { joinWaitlist } from '@/api/waitlist'

export default function CTASection() {
  // Form state
  const [email, setEmail] = useState('')
  const [fullName, setFullName] = useState('')

  // UI state
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [isSuccess, setIsSuccess] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)
    setIsSubmitting(true)

    try {
      await joinWaitlist({
        email,
        full_name: fullName || undefined,
      })

      setIsSuccess(true)

      // Clear form
      setEmail('')
      setFullName('')
    } catch (err) {
      const apiError = err as { code?: string; message?: string }

      // Handle specific error codes
      if (apiError.code === 'WAITLIST_EMAIL_EXISTS') {
        setError('This email is already on the waitlist.')
      } else {
        setError(apiError.message || 'Something went wrong. Please try again.')
      }
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <section className="py-24 bg-white dark:bg-navy-950">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-navy-800 to-navy-950 px-8 py-16 md:px-16 md:py-24">
            {/* Background decoration */}
            <div className="absolute inset-0 overflow-hidden">
              <div className="absolute -top-40 -right-40 w-80 h-80 rounded-full bg-gold-400/10" />
              <div className="absolute -bottom-40 -left-40 w-80 h-80 rounded-full bg-gold-400/5" />
              <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] rounded-full bg-gold-400/5" />
            </div>

            <div className="relative text-center text-white">
              <h2 className="text-3xl sm:text-4xl md:text-5xl font-display font-semibold mb-6">
                Ready to transform your wardrobe?
              </h2>
              <p className="text-lg md:text-xl text-navy-200 max-w-2xl mx-auto mb-10">
                Join the waitlist to be the first to try our mobile application. Get early access and exclusive features when we launch.
              </p>

              {/* Waitlist Form */}
              {isSuccess ? (
                <div className="max-w-md mx-auto bg-gold-400/10 backdrop-blur-sm rounded-xl p-6 border border-gold-400/20">
                  <div className="flex items-center justify-center gap-3 text-white">
                    <CheckCircle2 className="h-8 w-8 text-gold-400" />
                    <div className="text-left">
                      <p className="font-semibold text-lg">You're on the list!</p>
                      <p className="text-sm text-navy-200">We'll email you when the app launches.</p>
                    </div>
                  </div>
                </div>
              ) : (
                <form onSubmit={handleSubmit} className="max-w-md mx-auto space-y-4">
                  {/* Email Field */}
                  <div className="relative">
                    <Label htmlFor="waitlist-email" className="sr-only">
                      Email address
                    </Label>
                    <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-navy-400" />
                    <Input
                      id="waitlist-email"
                      type="email"
                      placeholder="Enter your email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      required
                      disabled={isSubmitting}
                      className="pl-10 h-12 bg-white text-navy-800 placeholder:text-navy-400 border-0 focus-visible:ring-2 focus-visible:ring-gold-400/50"
                    />
                  </div>

                  {/* Full Name Field (Optional) */}
                  <div className="relative">
                    <Label htmlFor="waitlist-name" className="sr-only">
                      Full name (optional)
                    </Label>
                    <User className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-navy-400" />
                    <Input
                      id="waitlist-name"
                      type="text"
                      placeholder="Full name (optional)"
                      value={fullName}
                      onChange={(e) => setFullName(e.target.value)}
                      disabled={isSubmitting}
                      className="pl-10 h-12 bg-white text-navy-800 placeholder:text-navy-400 border-0 focus-visible:ring-2 focus-visible:ring-gold-400/50"
                    />
                  </div>

                  {/* Error Message */}
                  {error && (
                    <p className="text-red-200 text-sm bg-red-500/20 rounded-lg px-4 py-2">
                      {error}
                    </p>
                  )}

                  {/* Submit Button */}
                  <Button
                    type="submit"
                    disabled={isSubmitting || !email}
                    size="lg"
                    variant="gold"
                    className="w-full text-lg h-12 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isSubmitting ? (
                      <>
                        <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                        Joining...
                      </>
                    ) : (
                      <>
                        Join the Waitlist
                        <ArrowRight className="ml-2 h-5 w-5" />
                      </>
                    )}
                  </Button>

                  <p className="text-xs text-navy-300">
                    No spam. We'll only email you about the mobile app launch.
                  </p>
                </form>
              )}

              {/* Separator */}
              <div className="mt-10 pt-10 border-t border-navy-700">
                <p className="text-sm text-navy-300 mb-4">
                  Already have an account? Access the web app now:
                </p>
                <Button
                  size="lg"
                  variant="outline"
                  className="border-gold-400/50 text-gold-400 hover:bg-gold-400/10 bg-transparent"
                  asChild
                >
                  <Link to="/auth/login">
                    Sign In to Web App
                    <ArrowRight className="ml-2 h-5 w-5" />
                  </Link>
                </Button>
              </div>
            </div>
          </div>
        </AnimatedSection>
      </div>
    </section>
  )
}
