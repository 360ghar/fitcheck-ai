import type { CSSProperties } from 'react'
import { Link } from 'react-router-dom'
import { ArrowRight, Check } from 'lucide-react'

import { Button } from '@/components/ui/button'
import { GeneratedImage } from '@/components/ui/generated-image'
import { trackEvent } from '@/lib/analytics'
import { trialRegisterHref, TRIAL_PROMO_CODE } from '@/lib/trial-offer'

const heroDelay = (ms: number) => ({ '--hero-delay': `${ms}ms` }) as CSSProperties

/** Shared clay frame for the calm supporting-UI cards under the machine. */
const supportCard =
  'min-w-0 rounded-3xl border border-border bg-card p-5 shadow-pressed'

/**
 * Illustration-led clay hero: a thesis headline, dual CTAs, the claymation
 * wardrobe-machine as the emotional centerpiece, then calm, credible product
 * UI beneath it (weather input, one reasoned outfit, saved-wardrobe proof).
 * Photography stays in proof slots only; the brand moment is the machine.
 */
export default function Hero() {
  return (
    <section
      aria-labelledby="landing-hero-heading"
      className="relative overflow-x-clip bg-background pt-16"
    >
      {/* The one sanctioned warm wash (DESIGN.md §08): a flat var-backed radial
          that fades before mid-page. No blur, no glass, always painted — the
          prerendered hero never depends on it for visibility. */}
      <div
        aria-hidden="true"
        className="pointer-events-none absolute inset-x-0 top-0 h-[520px] bg-[radial-gradient(60%_100%_at_50%_0%,hsl(var(--primary)/0.07),transparent_70%)]"
      />
      <div className="relative mx-auto w-full max-w-7xl px-4 pb-16 pt-12 sm:px-6 sm:pt-16 lg:px-8 lg:pb-20 lg:pt-20">
        <div className="grid grid-cols-1 items-end gap-8 lg:grid-cols-12 lg:gap-12">
          <div className="min-w-0 lg:col-span-7">
            <p
              className="hero-in flex items-center gap-3 text-xs font-semibold uppercase tracking-[0.16em] text-muted-foreground"
              style={heroDelay(0)}
            >
              <span className="h-px w-8 bg-primary" aria-hidden="true" />
              AI wardrobe workspace · Web + Android
            </p>
            <h1
              id="landing-hero-heading"
              className="hero-in landing-display type-display-xl mt-6 max-w-3xl text-foreground"
              style={heroDelay(60)}
            >
              Put your wardrobe to work every morning
            </h1>
            <p
              className="hero-in mt-6 max-w-2xl text-base leading-relaxed text-body sm:text-lg"
              style={heroDelay(120)}
            >
              FitCheck turns clothing photos into a private digital wardrobe. Plan weather-aware
              outfits, preview combinations, and create studio-style images from what you already
              own.
            </p>
          </div>

          <div className="hero-in min-w-0 lg:col-span-5" style={heroDelay(180)}>
            <div className="flex flex-col gap-3 sm:flex-row lg:flex-col xl:flex-row">
              <Button
                size="lg"
                className="group h-12 rounded-full px-6 text-base font-medium"
                asChild
              >
                <Link
                  to={trialRegisterHref()}
                  onClick={() =>
                    trackEvent('landing_cta_click', {
                      location: 'hero',
                      promo: TRIAL_PROMO_CODE,
                    })
                  }
                >
                  Start free
                  <ArrowRight className="ml-2 h-4 w-4 transition-transform group-hover:translate-x-0.5" />
                </Link>
              </Button>
              <Button
                size="lg"
                variant="outline"
                className="h-12 rounded-full px-6 text-base font-medium"
                asChild
              >
                <a href="#demo">Try the live demo</a>
              </Button>
            </div>
            <p className="mt-4 flex items-start gap-2 text-sm leading-relaxed text-muted-foreground">
              <Check className="mt-0.5 h-4 w-4 shrink-0 text-primary" aria-hidden="true" />
              First month free · No card · Returns to Free unless upgraded
            </p>
          </div>
        </div>

        {/* The centerpiece: the clay wardrobe-machine on its rolling hills.
            It is the LCP — the only fetchpriority=high image on the page. */}
        <figure
          className="hero-in-frame mt-12 overflow-hidden rounded-[2rem] border border-border bg-card shadow-pressed lg:mt-16"
          style={heroDelay(240)}
          aria-labelledby="wardrobe-machine-title"
        >
          <div className="flex flex-col gap-2 border-b border-border px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-6">
            <figcaption
              id="wardrobe-machine-title"
              className="text-xs font-semibold uppercase tracking-[0.16em] text-foreground"
            >
              The wardrobe machine
            </figcaption>
            <span className="text-xs text-muted-foreground">
              Weather-aware outfits · From your saved wardrobe
            </span>
          </div>
          <GeneratedImage
            src="/generated/hero-machine-640.webp"
            srcSet="/generated/hero-machine-640.webp 640w, /generated/hero-machine.webp 2624w"
            sizes="(min-width: 1280px) 1216px, calc(100vw - 32px)"
            alt="Claymation wardrobe machine on rolling green hills, holding a rail of tiny sweaters under a paper-cloud sky"
            className="aspect-[16/9] h-full w-full object-cover"
            width={2624}
            height={1472}
            decoding="async"
            fallback="hide-parent"
            {...{ fetchpriority: 'high' }}
          />
        </figure>

        {/* Calm supporting UI under the whimsy — the clay.com pairing: the
            illustration carries the brand moment, these cards carry credibility. */}
        <div className="mt-4 grid grid-cols-1 gap-4 md:grid-cols-3">
          <div className={`hero-in flex flex-col justify-center ${supportCard}`} style={heroDelay(300)}>
            <div className="flex items-center gap-4">
              <GeneratedImage
                src="/generated/weather-sun-cloud-640.webp"
                srcSet="/generated/weather-sun-cloud-640.webp 640w, /generated/weather-sun-cloud.webp 1024w"
                sizes="56px"
                alt=""
                width={1024}
                height={1024}
                loading="lazy"
                decoding="async"
                className="h-14 w-14 shrink-0 rounded-2xl border border-soft object-cover"
              />
              <div className="min-w-0">
                <p className="text-xs font-semibold uppercase tracking-[0.14em] text-muted-foreground">
                  Weather input
                </p>
                <p className="mt-1 text-xl font-semibold tracking-tight text-foreground">
                  24° Clear
                </p>
              </div>
            </div>
            <p className="mt-4 text-sm leading-relaxed text-muted-foreground">
              Today's forecast shapes every outfit plan before you ask for one.
            </p>
          </div>

          <div className={`hero-in ${supportCard}`} style={heroDelay(340)}>
            <div className="overflow-hidden rounded-2xl border border-border">
              <GeneratedImage
                src="/generated/outfit-flatlay-4x3-640.webp"
                srcSet="/generated/outfit-flatlay-4x3-640.webp 640w, /generated/outfit-flatlay-4x3.webp 1200w"
                sizes="(min-width: 768px) 30vw, calc(100vw - 32px)"
                alt="Curated outfit flat lay with a cream knit, indigo jeans, white sneakers, and gold hoops"
                className="aspect-[16/7] h-full w-full object-cover"
                width={1200}
                height={900}
                loading="lazy"
                decoding="async"
                fallback="hide-parent"
              />
            </div>
            <p className="mt-4 text-xs font-semibold uppercase tracking-[0.14em] text-primary">
              Selected workday outfit
            </p>
            <p className="mt-2 text-sm font-semibold leading-snug text-foreground">
              Clear-day structure without the guesswork
            </p>
            <dl className="mt-3 border-t border-soft pt-3 text-sm">
              <div className="flex items-center justify-between gap-4 py-1">
                <dt className="text-muted-foreground">Context</dt>
                <dd className="font-medium text-foreground">Workday</dd>
              </div>
              <div className="flex items-center justify-between gap-4 py-1">
                <dt className="text-muted-foreground">Source</dt>
                <dd className="font-medium text-foreground">Saved wardrobe</dd>
              </div>
            </dl>
          </div>

          <div className={`hero-in flex flex-col justify-center ${supportCard}`} style={heroDelay(380)}>
            <div className="grid grid-cols-3 gap-2">
              {[
                {
                  file: 'office',
                  alt: 'Office outfit example from saved wardrobe pieces',
                },
                {
                  file: 'evening',
                  alt: 'Evening outfit example from saved wardrobe pieces',
                },
                {
                  file: 'festive',
                  alt: 'Festive outfit example from saved wardrobe pieces',
                },
              ].map((frame) => (
                <div
                  key={frame.file}
                  className="min-w-0 overflow-hidden rounded-2xl border border-border"
                >
                  <GeneratedImage
                    src={`/generated/outfit-carousel-${frame.file}-4x3-640.webp`}
                    srcSet={`/generated/outfit-carousel-${frame.file}-4x3-640.webp 640w, /generated/outfit-carousel-${frame.file}-4x3.webp 1600w`}
                    sizes="(min-width: 768px) 12vw, 30vw"
                    alt={frame.alt}
                    className="aspect-[4/3] h-full w-full object-cover"
                    width={1600}
                    height={1200}
                    loading="lazy"
                    decoding="async"
                    fallback="hide-parent"
                  />
                </div>
              ))}
            </div>
            <p className="mt-4 text-xs font-semibold uppercase tracking-[0.14em] text-muted-foreground">
              Saved wardrobe
            </p>
            <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
              Workday, evening, and festive options, built only from clothes you already own.
            </p>
          </div>
        </div>
      </div>
    </section>
  )
}
