import { useState } from 'react'
import { Link } from 'react-router-dom'
import { ArrowRight, CheckCircle2, Loader2 } from 'lucide-react'

import { joinWaitlist } from '@/api/waitlist'
import { AnimatedSection } from '@/components/landing/AnimatedSection'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { trackEvent } from '@/lib/analytics'
import { PLATFORM_AVAILABILITY } from '@/lib/plan-limits'
import { trialRegisterHref, TRIAL_PROMO_CODE } from '@/lib/trial-offer'

export default function CTASection() {
  const [email, setEmail] = useState('')
  const [fullName, setFullName] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [isSuccess, setIsSuccess] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault()
    setError(null)
    setIsSubmitting(true)

    try {
      await joinWaitlist({ email, full_name: fullName || undefined })
      setIsSuccess(true)
      setEmail('')
      setFullName('')
    } catch (caught) {
      const apiError = caught as { code?: string; message?: string }
      setError(
        apiError.code === 'WAITLIST_EMAIL_EXISTS'
          ? 'This email is already on the waitlist.'
          : apiError.message || 'Something went wrong. Please try again.'
      )
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <section className="bg-surface-soft py-20 md:py-28" aria-labelledby="final-cta-heading">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <AnimatedSection className="reveal">
          <div className="overflow-hidden rounded-[2rem] border border-stone-800 bg-stone-950 text-stone-50">
            <div className="grid grid-cols-1 lg:grid-cols-12">
              <div className="min-w-0 px-6 py-12 sm:px-10 sm:py-16 lg:col-span-7 lg:px-14 lg:py-20">
                <p className="text-xs font-semibold uppercase tracking-[0.16em] text-stone-400">
                  Your wardrobe, ready to work
                </p>
                <h2
                  id="final-cta-heading"
                  className="landing-display mt-5 max-w-2xl text-3xl font-semibold leading-tight text-stone-50 sm:text-4xl md:text-[2.75rem]"
                >
                  Start with your first clothing photo
                </h2>
                <p className="mt-5 max-w-xl text-base leading-relaxed text-stone-400 md:text-lg">
                  Use FitCheck on the web or Android. Your first month of Pro is free, no card is required, and the account returns to Free unless you upgrade.
                </p>
                <div className="mt-8 flex flex-col gap-3 sm:flex-row">
                  {/* The one brand-gradient CTA on the page (DESIGN.md §08):
                      hex-locked brand red by design — it rides the ink strip,
                      not a theme surface. Hover rides `filter` brightness —
                      the variant's `hover:bg-primary/90` is invisible under a
                      background-image gradient. */}
                  <Button
                    size="lg"
                    className="group h-12 bg-gradient-primary px-6 transition-[filter] duration-150 hover:brightness-110"
                    asChild
                  >
                    <Link
                      to={trialRegisterHref()}
                      onClick={() =>
                        trackEvent('landing_cta_click', {
                          location: 'bottom',
                          promo: TRIAL_PROMO_CODE,
                        })
                      }
                    >
                      Start free on web
                      <ArrowRight className="ml-2 h-4 w-4 transition-transform group-hover:translate-x-0.5" />
                    </Link>
                  </Button>
                  <Button
                    size="lg"
                    variant="outline"
                    className="h-12 border-stone-600 bg-transparent px-6 text-stone-100 hover:bg-stone-900 hover:text-white"
                    asChild
                  >
                    <a
                      href={PLATFORM_AVAILABILITY.androidStoreUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      Get Android app
                    </a>
                  </Button>
                </div>
                <p className="mt-4 text-sm text-stone-400">
                  Already have an account?{' '}
                  <Link to="/auth/login" className="text-stone-200 underline underline-offset-4">
                    Log in
                  </Link>
                </p>
              </div>

              <div className="min-w-0 border-t border-stone-800 bg-stone-900 px-6 py-10 sm:px-10 lg:col-span-5 lg:border-l lg:border-t-0 lg:px-12 lg:py-20">
                <p className="text-sm font-semibold text-stone-100">iOS and product updates</p>
                <p className="mt-2 text-sm leading-relaxed text-stone-400">
                  iOS is on the waitlist. Leave your email for availability and major product updates.
                </p>

                {isSuccess ? (
                  <div className="mt-7 flex items-start gap-3 border-t border-stone-700 pt-6">
                    <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-emerald-400" />
                    <div>
                      <p className="font-medium text-stone-50">You are on the list</p>
                      <p className="mt-1 text-sm text-stone-400">
                        We will email you about iOS availability and major updates.
                      </p>
                    </div>
                  </div>
                ) : (
                  <form onSubmit={handleSubmit} className="mt-7 space-y-3">
                    <div>
                      <Label htmlFor="waitlist-email" className="sr-only">
                        Email address
                      </Label>
                      <Input
                        id="waitlist-email"
                        type="email"
                        placeholder="Email"
                        value={email}
                        onChange={(event) => setEmail(event.target.value)}
                        required
                        disabled={isSubmitting}
                        className="h-11 border-stone-700 bg-stone-950 text-stone-50 placeholder:text-stone-500 focus-visible:ring-primary"
                      />
                    </div>
                    <div>
                      <Label htmlFor="waitlist-name" className="sr-only">
                        Full name (optional)
                      </Label>
                      <Input
                        id="waitlist-name"
                        type="text"
                        placeholder="Name (optional)"
                        value={fullName}
                        onChange={(event) => setFullName(event.target.value)}
                        disabled={isSubmitting}
                        className="h-11 border-stone-700 bg-stone-950 text-stone-50 placeholder:text-stone-500 focus-visible:ring-primary"
                      />
                    </div>
                    {error && (
                      <p className="rounded-2xl border border-red-900 bg-red-950 px-3 py-2 text-sm text-red-200">
                        {error}
                      </p>
                    )}
                    <Button
                      type="submit"
                      disabled={isSubmitting || !email}
                      className="h-11 w-full bg-white font-medium text-stone-900 hover:bg-stone-100"
                    >
                      {isSubmitting ? (
                        <>
                          <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                          Joining...
                        </>
                      ) : (
                        'Get updates'
                      )}
                    </Button>
                  </form>
                )}
              </div>
            </div>
          </div>
        </AnimatedSection>
      </div>
    </section>
  )
}
