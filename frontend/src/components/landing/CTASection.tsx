import { useState } from 'react'
import { Link } from 'react-router-dom'
import { CheckCircle2, Loader2 } from 'lucide-react'

import { joinWaitlist } from '@/api/waitlist'
import StoreBadges from '@/components/landing/StoreBadges'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { trackEvent } from '@/lib/analytics'
import { trialRegisterHref, TRIAL_PROMO_CODE } from '@/lib/trial-offer'

/*
 * The app's washing line (flutter/lib/core/widgets/paper_scene.dart:
 * paperTee, paperDress, paperTrousers), as SVG paths in a 100-wide box.
 * Each piece hangs from its pin and swings a little on hover.
 */
const TEE = 'M64 0L90 9L100 33L84 41L78 33L78 100L22 100L22 33L16 41L0 33L10 9L36 0Q50 15 64 0Z'
const DRESS = 'M66 0L72 37.2L62 55.8L100 155L0 155L38 55.8L28 37.2L34 0Q50 21.7 66 0Z'
const TROUSERS = 'M0 0L100 0L98 170L58 170L50 51L42 170L2 170Z'

const LINE: Array<{ x: number; path: string; w: number; fill: string }> = [
  { x: 150, path: TEE, w: 92, fill: 'var(--paper-clay-slab)' },
  { x: 330, path: DRESS, w: 70, fill: 'var(--paper-moss-slab)' },
  { x: 500, path: TROUSERS, w: 56, fill: 'var(--paper-ink-slab)' },
  { x: 680, path: TEE, w: 92, fill: 'var(--paper-marigold-slab)' },
  { x: 860, path: DRESS, w: 70, fill: 'var(--paper-ink-slab)' },
  { x: 1040, path: TEE, w: 92, fill: 'var(--paper-clay-slab)' },
]

/* y of the sagging line at x (quadratic from (0,24) via (600,64) to (1200,24)). */
const lineY = (x: number) => {
  const t = x / 1200
  return (1 - t) * (1 - t) * 24 + 2 * (1 - t) * t * 64 + t * t * 24
}

function WashingLine() {
  return (
    <svg
      viewBox="0 0 1200 230"
      className="wash-line h-auto w-full overflow-visible"
      aria-hidden="true"
      focusable="false"
    >
      <path
        d="M-20 24Q600 64 1220 24"
        fill="none"
        strokeWidth="3"
        strokeLinecap="round"
        style={{ stroke: 'hsl(var(--s-slab))' }}
      />
      {LINE.map((piece) => {
        const y = lineY(piece.x) - 2
        const scale = piece.w / 100
        return (
          <g key={piece.x} className="wash-piece" style={{ transformOrigin: `${piece.x}px ${y}px` }}>
            <path
              d={piece.path}
              transform={`translate(${piece.x - piece.w / 2} ${y}) scale(${scale})`}
              style={{ fill: `hsl(${piece.fill})` }}
            />
          </g>
        )
      })}
    </svg>
  )
}

/**
 * The page close, on moss paper: the app's washing line, one sentence, one
 * red action, the store badges, and the product-updates form. Waitlist
 * mechanics (joinWaitlist, field ids, labels, error and success states) are
 * unchanged.
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
    <section
      className="paper-section paper-tear stock-moss pb-28 pt-14 md:pb-36 md:pt-16"
      aria-labelledby="final-cta-heading"
    >
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <WashingLine />

        <div className="mt-10 grid grid-cols-1 gap-12 lg:mt-14 lg:grid-cols-12 lg:items-end lg:gap-16">
          <div className="min-w-0 lg:col-span-7">
            <h2
              id="final-cta-heading"
              className="paper-display text-[clamp(2.6rem,6vw,4.75rem)] text-paper-text"
            >
              Start with one photo.
            </h2>
            <p className="mt-5 max-w-xl text-base leading-relaxed text-paper-text-2 sm:text-[17px]">
              On the web, iPhone or Android. Your first month of Pro is free with no card, and the
              account returns to Free unless you upgrade.
            </p>
            <div className="mt-8 flex flex-wrap items-center gap-4">
              <Link
                to={trialRegisterHref()}
                className="paper-btn"
                onClick={() =>
                  trackEvent('landing_cta_click', { location: 'bottom', promo: TRIAL_PROMO_CODE })
                }
              >
                Start free on web
              </Link>
              <StoreBadges location="bottom" />
            </div>
            <p className="mt-5 text-sm text-paper-text-3">
              Already have an account?{' '}
              <Link to="/auth/login" className="font-semibold text-paper-accent hover:text-paper-text">
                Log in
              </Link>
            </p>
          </div>

          <div className="paper-sheet min-w-0 p-6 sm:p-8 lg:col-span-5">
            <p className="paper-head text-2xl text-paper-text">Product updates</p>
            <p className="mt-2 text-[15px] leading-relaxed text-paper-text-2">
              One email when something big ships.
            </p>

            {isSuccess ? (
              <div className="mt-6 flex items-start gap-3">
                <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-paper-accent" aria-hidden="true" />
                <div>
                  <p className="font-semibold text-paper-text">You are on the list</p>
                  <p className="mt-1 text-sm text-paper-text-2">
                    We will email you about major product updates.
                  </p>
                </div>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="mt-6 space-y-3">
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
                    className="h-12 rounded-xl border-paper-edge bg-paper-card text-paper-text placeholder:text-paper-text-3"
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
                    className="h-12 rounded-xl border-paper-edge bg-paper-card text-paper-text placeholder:text-paper-text-3"
                  />
                </div>
                {error && (
                  <p className="rounded-xl bg-error-pale px-3 py-2 text-sm text-error">{error}</p>
                )}
                <button
                  type="submit"
                  disabled={isSubmitting || !email}
                  className="paper-btn-sheet w-full disabled:cursor-not-allowed disabled:text-paper-text-3"
                >
                  {isSubmitting ? (
                    <>
                      <Loader2 className="h-4 w-4 animate-spin" aria-hidden="true" />
                      Joining...
                    </>
                  ) : (
                    'Get updates'
                  )}
                </button>
              </form>
            )}
          </div>
        </div>
      </div>
    </section>
  )
}
