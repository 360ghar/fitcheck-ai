import { useState } from 'react'
import type { FormEvent } from 'react'
import { Link } from 'react-router-dom'
import { ArrowRight } from 'lucide-react'

import { Button } from '@/components/ui/button'
import { GeneratedImage } from '@/components/ui/generated-image'
import { trackEvent } from '@/lib/analytics'
import { trialRegisterHref, TRIAL_PROMO_CODE } from '@/lib/trial-offer'

import { AnimatedSection } from './AnimatedSection'

const OCCASION_CHIPS = ['Workday', 'Evening', 'Festive'] as const

// Literal class map: Tailwind's JIT needs complete class names at scan time.
const CHIP_INACTIVE =
  'min-h-11 rounded-full border border-border bg-background px-5 text-sm font-medium text-foreground transition-colors hover:bg-surface-card'
const CHIP_ACTIVE =
  'min-h-11 rounded-full bg-primary px-5 text-sm font-medium text-primary-foreground shadow-pressed'

/**
 * Above-the-fold demo strip — the prompt box. `What occasion?` pill input +
 * 3 pressed chips + Generate (solid CTA rides the built-in offset hover).
 * A stitched-doodle sticker keeps it playful without cluttering the form.
 * Generate smooth-scrolls to #demo and moves focus to the demo heading so
 * keyboard and screen-reader users land on the demos. Reduced-motion users
 * get an instant jump (behavior auto).
 */
export default function DemoStrip() {
  const [occasion, setOccasion] = useState('')

  const goToDemo = () => {
    const reduceMotion =
      typeof window !== 'undefined' &&
      window.matchMedia('(prefers-reduced-motion: reduce)').matches
    document
      .querySelector('#demo')
      ?.scrollIntoView({ behavior: reduceMotion ? 'auto' : 'smooth', block: 'start' })
    // Focus after the scroll starts; preventScroll keeps the smooth scroll
    // target stable while still moving AT/keyboard focus to the heading.
    window.setTimeout(() => {
      document.getElementById('demo-heading')?.focus({ preventScroll: true })
    }, reduceMotion ? 0 : 450)
  }

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    trackEvent('landing_demo_strip_submit', { occasion: occasion.trim() || 'unspecified' })
    goToDemo()
  }

  return (
    <section aria-label="Try an occasion in the live demo" className="bg-background">
      <div className="mx-auto max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
        <AnimatedSection className="reveal">
          <form
            onSubmit={handleSubmit}
            className="relative rounded-[2rem] border border-border bg-card p-5 shadow-pressed sm:p-8"
          >
            <GeneratedImage
              src="/generated/doodle-stitch-640.webp"
              srcSet="/generated/doodle-stitch-640.webp 640w, /generated/doodle-stitch.webp 1024w"
              sizes="128px"
              alt=""
              width={1024}
              height={1024}
              loading="lazy"
              decoding="async"
              aria-hidden="true"
              className="absolute bottom-6 right-8 hidden h-14 w-32 rounded-full border border-soft object-cover lg:block"
            />
            <label
              htmlFor="demo-occasion-input"
              className="block text-sm font-semibold text-foreground"
            >
              What occasion?
            </label>
            <div className="mt-3 flex flex-col gap-3 lg:flex-row">
              <input
                id="demo-occasion-input"
                name="occasion"
                type="text"
                autoComplete="off"
                maxLength={80}
                value={occasion}
                onChange={(event) => setOccasion(event.target.value)}
                placeholder="Workday, wedding, date night…"
                className="min-h-12 w-full flex-1 rounded-full border border-border bg-background px-5 text-base text-foreground placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
              />
              <Button
                type="submit"
                size="lg"
                className="h-12 min-h-12 rounded-full px-6 text-base font-medium"
              >
                Generate
                <ArrowRight className="ml-2 h-4 w-4" aria-hidden="true" />
              </Button>
            </div>
            <div className="mt-3 flex flex-wrap gap-2" role="group" aria-label="Occasion shortcuts">
              {OCCASION_CHIPS.map((chip) => {
                const active = occasion.trim().toLowerCase() === chip.toLowerCase()
                return (
                  <button
                    key={chip}
                    type="button"
                    aria-pressed={active}
                    onClick={() => setOccasion(chip)}
                    className={active ? CHIP_ACTIVE : CHIP_INACTIVE}
                  >
                    {chip}
                  </button>
                )
              })}
            </div>
            <p className="mt-4 text-sm leading-relaxed text-muted-foreground">
              Ready to save looks?{' '}
              <Link
                to={trialRegisterHref()}
                onClick={() =>
                  trackEvent('landing_cta_click', {
                    location: 'demo-strip',
                    promo: TRIAL_PROMO_CODE,
                  })
                }
                className="font-medium text-primary"
              >
                Start free
              </Link>{' '}
              — first month free, no card.
            </p>
          </form>
        </AnimatedSection>
      </div>
    </section>
  )
}
