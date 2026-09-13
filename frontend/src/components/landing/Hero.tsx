import type { CSSProperties } from 'react'
import { Link } from 'react-router-dom'
import { ArrowRight, Check, Sun } from 'lucide-react'

import { Button } from '@/components/ui/button'
import { trackEvent } from '@/lib/analytics'
import { trialRegisterHref, TRIAL_PROMO_CODE } from '@/lib/trial-offer'

const heroDelay = (ms: number) => ({ '--hero-delay': `${ms}ms` }) as CSSProperties

const closetCrops = [
  'object-[center_24%]',
  'object-[center_52%]',
  'object-[center_78%]',
]

/**
 * The landing signature is a factual decision canvas, not a device mockup.
 * It combines existing wardrobe photography, one selected flat lay, and the
 * inputs FitCheck can use to explain an outfit recommendation.
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
          <div className="min-w-0 lg:col-span-8">
            <p
              className="hero-in flex items-center gap-3 text-xs font-semibold uppercase tracking-[0.16em] text-muted-foreground"
              style={heroDelay(0)}
            >
              <span className="h-px w-8 bg-primary" aria-hidden="true" />
              AI wardrobe workspace · Web + Android
            </p>
            <h1
              id="landing-hero-heading"
              className="hero-in landing-display mt-6 max-w-4xl text-4xl font-semibold leading-[1.04] text-foreground sm:text-5xl lg:text-6xl xl:text-[4.25rem]"
              style={heroDelay(60)}
            >
              AI virtual closet for better outfits every day
            </h1>
            <p
              className="hero-in mt-6 max-w-2xl text-base leading-relaxed text-body sm:text-lg"
              style={heroDelay(120)}
            >
              Turn clothing photos into a private digital wardrobe. Plan weather-aware outfits,
              preview combinations, and create studio-style images from what you already own.
            </p>
          </div>

          <div className="hero-in min-w-0 lg:col-span-4" style={heroDelay(180)}>
            <div className="flex flex-col gap-3 sm:flex-row lg:flex-col xl:flex-row">
              <Button
                size="lg"
                className="group h-12 px-6 text-base font-medium transition-[color,background-color,border-color,transform] active:scale-[0.98]"
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
                className="h-12 px-6 text-base font-medium text-ink transition-[color,background-color,border-color,transform] active:scale-[0.98]"
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

        <figure
          className="hero-in-frame mt-12 overflow-hidden rounded-[2rem] border border-border bg-card lg:mt-16"
          style={heroDelay(240)}
          aria-labelledby="decision-canvas-title"
        >
          <div className="flex flex-col gap-2 border-b border-border px-5 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-6">
            <figcaption
              id="decision-canvas-title"
              className="text-xs font-semibold uppercase tracking-[0.16em] text-foreground"
            >
              Outfit decision canvas
            </figcaption>
            <span className="text-xs text-muted-foreground">From your saved wardrobe</span>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-12">
            <div className="order-2 min-w-0 border-t border-border p-4 sm:p-5 lg:order-1 lg:col-span-3 lg:border-r lg:border-t-0">
              <p className="text-xs font-semibold uppercase tracking-[0.14em] text-muted-foreground">
                Closet rail
              </p>
              <div className="mt-4 grid grid-cols-3 gap-2 lg:grid-cols-1">
                {closetCrops.map((position, index) => (
                  <div
                    key={position}
                    className="min-w-0 overflow-hidden rounded-2xl border border-border bg-surface-soft lg:aspect-[16/7]"
                  >
                    <img
                      src="/landing/wardrobe-640.webp"
                      alt={index === 0 ? 'Neutral clothes arranged on a wardrobe rail' : ''}
                      className={`aspect-square h-full w-full object-cover lg:aspect-auto ${position}`}
                      width={640}
                      height={480}
                      loading="lazy"
                      aria-hidden={index > 0 ? true : undefined}
                    />
                  </div>
                ))}
              </div>
              <p className="mt-4 text-sm leading-relaxed text-muted-foreground">
                Clothing references stay connected to the outfit decision.
              </p>
            </div>

            <div className="order-1 min-w-0 bg-surface-soft p-3 sm:p-5 lg:order-2 lg:col-span-5">
              <div className="overflow-hidden rounded-2xl border border-border bg-card">
                <img
                  src="/landing/flatlay-640.webp"
                  srcSet="/landing/flatlay-640.webp 640w, /landing/flatlay.webp 1024w"
                  sizes="(min-width: 1024px) 42vw, calc(100vw - 32px)"
                  alt="Workday outfit flat lay with a white shirt, navy trousers, brown shoes, and a watch"
                  className="aspect-square h-full w-full object-cover"
                  width={1024}
                  height={1024}
                  decoding="async"
                  {...{ fetchpriority: 'high' }}
                />
              </div>
            </div>

            <div className="order-3 min-w-0 border-t border-border p-6 sm:p-8 lg:col-span-4 lg:border-l lg:border-t-0 lg:p-10">
              <div className="flex items-center justify-between gap-4 border-b border-border pb-5">
                <div>
                  <p className="text-xs font-semibold uppercase tracking-[0.14em] text-muted-foreground">
                    Weather input
                  </p>
                  <p className="mt-2 text-xl font-semibold text-foreground">24° Clear</p>
                </div>
                <Sun className="h-6 w-6 text-primary" aria-hidden="true" />
              </div>

              <div className="py-6">
                <p className="text-xs font-semibold uppercase tracking-[0.14em] text-primary">
                  Selected workday outfit
                </p>
                <h2 className="landing-display mt-3 text-2xl font-semibold leading-tight text-foreground">
                  Clear-day structure without the guesswork
                </h2>
                <p className="mt-4 text-sm leading-relaxed text-body sm:text-base">
                  A white shirt, navy trousers, and brown shoes form a focused workday option.
                  The reason stays visible beside the clothes that support it.
                </p>
              </div>

              <dl className="border-t border-border pt-5 text-sm">
                <div className="flex items-center justify-between gap-4 py-2">
                  <dt className="text-muted-foreground">Context</dt>
                  <dd className="font-medium text-foreground">Workday</dd>
                </div>
                <div className="flex items-center justify-between gap-4 py-2">
                  <dt className="text-muted-foreground">Source</dt>
                  <dd className="font-medium text-foreground">Saved wardrobe</dd>
                </div>
              </dl>
            </div>
          </div>
        </figure>
      </div>
    </section>
  )
}
