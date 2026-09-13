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

/**
 * Final CTA — the page close. The PhotoshootShowcase above is the page's one
 * dark break; this section stays light so the page closes warm (clay.com
 * pattern): one pressed, page-width white card on the cream canvas, with the
 * sanctioned hex-locked `gradient-primary` CTA as the finale. All waitlist
 * mechanics (joinWaitlist, field ids, labels, error/success states) are
 * unchanged — only the surface moved off the old dark panel.
 */
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
    <section className="bg-background py-20 md:py-28" aria-labelledby="final-cta-heading">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <AnimatedSection className="reveal">
          <div className="overflow-hidden rounded-[2.5rem] border border-border bg-card shadow-pressed">
            <div className="grid grid-cols-1 lg:grid-cols-12">
              <div className="min-w-0 px-6 py-12 sm:px-10 sm:py-16 lg:col-span-7 lg:px-14 lg:py-20">
                <p className="text-xs font-semibold uppercase tracking-[0.16em] text-muted-foreground">
                  Your wardrobe, ready to work
                </p>
                <h2
                  id="final-cta-heading"
                  className="landing-display mt-5 max-w-2xl text-3xl font-semibold leading-tight text-foreground sm:text-4xl md:text-[2.75rem]"
                >
                  Start with your first clothing photo
                </h2>
                <p className="mt-5 max-w-xl text-base leading-relaxed text-body md:text-lg">
                  Use FitCheck on the web or Android. Your first month of Pro is free, no card is required, and the account returns to Free unless you upgrade.
                </p>
                <div className="mt-8 flex flex-col gap-3 sm:flex-row">
                  {/* The one brand-gradient CTA on the page (DESIGN.md §08):
                      hex-locked brand red by design. It rides the final pressed
                      card, not a theme surface, so it reads identically in both
                      themes. Hover rides `filter` brightness — the variant's
                      `hover:bg-primary/90` is invisible under a background-image
                      gradient. */}
                  <Button
                    size="lg"
                    className="group h-12 bg-gradient-primary px-6 text-white transition-[filter] duration-150 hover:brightness-110"
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
                    className="h-12 px-6"
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
                <p className="mt-4 text-sm text-muted-foreground">
                  Already have an account?{' '}
                  <Link to="/auth/login" className="font-medium text-primary hover:text-primary-pressed">
                    Log in
                  </Link>
                </p>
              </div>

              {/* Waitlist column: a quiet oat wash on the white card so the two
                  jobs (convert vs. leave-an-email) read as separate rooms. */}
              <div className="min-w-0 border-t border-border bg-secondary/40 px-6 py-10 sm:px-10 lg:col-span-5 lg:border-l lg:border-t-0 lg:px-12 lg:py-20">
                <p className="text-sm font-semibold text-foreground">iOS and product updates</p>
                <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
                  iOS is on the waitlist. Leave your email for availability and major product updates.
                </p>

                {isSuccess ? (
                  <div className="mt-7 flex items-start gap-3 border-t border-border pt-6">
                    <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-success" aria-hidden="true" />
                    <div>
                      <p className="font-medium text-foreground">You are on the list</p>
                      <p className="mt-1 text-sm text-muted-foreground">
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
                      />
                    </div>
                    {error && (
                      <p className="rounded-2xl border border-error/30 bg-error-pale px-3 py-2 text-sm text-error">
                        {error}
                      </p>
                    )}
                    {/* Quiet secondary submit: the red gradient belongs to the
                        conversion CTA on the left, not the waitlist form. */}
                    <Button
                      type="submit"
                      variant="secondary"
                      disabled={isSubmitting || !email}
                      className="h-11 w-full"
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
