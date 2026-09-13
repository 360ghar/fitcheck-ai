import { Link } from 'react-router-dom'
import { ArrowRight, Camera, Shirt, Sun } from 'lucide-react'

import { Button } from '@/components/ui/button'
import { GeneratedImage } from '@/components/ui/generated-image'
import { trackLandingCta } from '@/lib/analytics'
import { trialRegisterHref, TRIAL_PROMO_CODE } from '@/lib/trial-offer'
import { AnimatedSection } from './AnimatedSection'
import { SectionKicker } from './SectionKicker'
import { scrollToSectionId } from '@/lib/scroll'

const outcomes = [
  {
    icon: Shirt,
    title: 'Photo to wardrobe record',
    description:
      'Clothing photos become searchable items with color, category, and style tags.',
  },
  {
    icon: Sun,
    title: 'Weather-aware outfit pick',
    description: 'A recommendation drawn from clothes already in the closet.',
  },
  {
    icon: Camera,
    title: 'Photoshoot-style portrait',
    description: 'A studio-style image generated from a phone selfie.',
  },
]

/**
 * ProofBand — one example-labeled outcome band between Pricing and FAQ.
 * Tiles describe real product flows and are badged "Example": no customer
 * quotes, no metrics, no fabrication — so no Review JSON-LD is emitted.
 * The avatar asset is delivered under public/generated (Agent C); the img
 * hides itself until that file exists so the band never shows a broken image.
 */
export default function ProofBand() {
  return (
    <section aria-labelledby="proof-heading" className="bg-background py-20 md:py-28">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <AnimatedSection className="reveal">
          <div className="max-w-2xl">
            <SectionKicker tone="teal">Proof</SectionKicker>
            <h2
              id="proof-heading"
              className="landing-display text-3xl font-semibold leading-tight text-foreground sm:text-4xl md:text-[2.75rem]"
            >
              Outcomes you can check in minutes
            </h2>
            <p className="mt-4 text-base leading-relaxed text-body md:text-lg">
              Three real product flows, shown as illustrative examples. Run each
              one yourself in the live demo or on the free plan.
            </p>
          </div>
        </AnimatedSection>

        <div className="mt-12 grid gap-4 md:grid-cols-3 md:gap-6">
          {outcomes.map((outcome, index) => (
            <AnimatedSection key={outcome.title} delay={index * 60}>
              {/* Pressed clay card. Tiles stay static (they are not links);
                  the section's one accent is teal — the kicker's dot color. */}
              <article className="flex h-full flex-col rounded-3xl border border-border bg-card p-6 shadow-pressed">
                <div className="flex items-center justify-between gap-3">
                  <span className="flex h-11 w-11 items-center justify-center rounded-xl border border-soft bg-tint-teal-pale">
                    <outcome.icon className="h-5 w-5 text-tint-teal" aria-hidden="true" />
                  </span>
                  <span className="rounded-full border border-border px-2.5 py-1 text-xs font-semibold text-muted-foreground">
                    Example
                  </span>
                </div>
                <h3 className="mt-5 text-lg font-semibold text-foreground">{outcome.title}</h3>
                <p className="mt-2 text-sm leading-relaxed text-body">{outcome.description}</p>
              </article>
            </AnimatedSection>
          ))}
        </div>

        <AnimatedSection className="reveal">
          {/* Clay-ified CTA bar: pressed white card, conversion + exploration
              pair. The demo link scrolls without a reload, same as the
              Pricing → FAQ anchor. */}
          <div className="mt-10 flex flex-col gap-6 rounded-[2rem] border border-border bg-card p-6 shadow-pressed sm:flex-row sm:items-center sm:justify-between sm:p-8">
            <figure className="flex min-w-0 items-center gap-4">
              <GeneratedImage
                src="/generated/avatar-diverse-1x1-640.webp"
                alt="FitCheck users — AI-generated example"
                className="h-12 w-12 shrink-0 rounded-full object-cover"
                loading="lazy"
              />
              <figcaption className="text-xs uppercase tracking-[0.14em] text-muted-foreground">
                AI-generated example
              </figcaption>
            </figure>
            <div className="flex shrink-0 flex-col gap-3 sm:flex-row sm:items-center">
              <Button
                variant="outline"
                size="lg"
                className="h-12 px-6"
                asChild
              >
                <a
                  href="#demo"
                  onClick={(event) => {
                    event.preventDefault()
                    scrollToSectionId('demo')
                    trackLandingCta('proof-demo')
                  }}
                >
                  Try the live demo
                </a>
              </Button>
              <Button size="lg" className="h-12 px-6" asChild>
                <Link
                  to={trialRegisterHref()}
                  onClick={() =>
                    trackLandingCta('proof', { promo: TRIAL_PROMO_CODE })
                  }
                >
                  Start free
                  <ArrowRight className="ml-2 h-4 w-4" aria-hidden="true" />
                </Link>
              </Button>
            </div>
          </div>
        </AnimatedSection>
      </div>
    </section>
  )
}
