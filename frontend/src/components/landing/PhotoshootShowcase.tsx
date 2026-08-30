import { Link } from 'react-router-dom'
import { ArrowRight, Camera, Check } from 'lucide-react'

import { Button } from '@/components/ui/button'
import { PLAN_LIMITS } from '@/lib/plan-limits'

const facts = [
  'Uses clothes selected from your wardrobe',
  'Supports professional, dating, social, and custom settings',
  `${PLAN_LIMITS.free.dailyPhotoshootImages} photoshoot images per day on Free`,
]

export default function PhotoshootShowcase() {
  return (
    <section
      id="photoshoot-showcase"
      aria-labelledby="photoshoot-showcase-heading"
      className="bg-stone-950 text-stone-50"
    >
      <div className="mx-auto grid max-w-7xl grid-cols-1 gap-12 px-4 py-20 sm:px-6 md:py-28 lg:grid-cols-12 lg:items-center lg:gap-16 lg:px-8">
        <div className="min-w-0 lg:col-span-6">
          <p className="flex items-center gap-3 text-xs font-semibold uppercase tracking-[0.16em] text-stone-400">
            <Camera className="h-4 w-4 text-primary" aria-hidden="true" />
            Photoshoot Studio
          </p>
          <h2
            id="photoshoot-showcase-heading"
            className="landing-display mt-5 max-w-xl text-3xl font-semibold leading-tight text-stone-50 sm:text-4xl md:text-[2.75rem]"
          >
            Studio-style output without a full production setup
          </h2>
          <p className="mt-5 max-w-xl text-base leading-relaxed text-stone-400 md:text-lg">
            Choose your wardrobe pieces and a setting, then generate studio-style images from one selfie. The result is shown as an example, not as a before-and-after claim.
          </p>
          <ul className="mt-7 space-y-3">
            {facts.map((fact) => (
              <li key={fact} className="flex items-start gap-3 text-sm leading-relaxed text-stone-300">
                <Check className="mt-0.5 h-4 w-4 shrink-0 text-primary" aria-hidden="true" />
                {fact}
              </li>
            ))}
          </ul>
          <Button size="lg" className="mt-8 h-12 px-6" asChild>
            <Link to="/features/ai-photoshoot-generator">
              Explore Photoshoot Studio
              <ArrowRight className="ml-2 h-4 w-4" aria-hidden="true" />
            </Link>
          </Button>
        </div>

        <figure className="min-w-0 lg:col-span-6 lg:justify-self-end">
          <div className="overflow-hidden rounded-[2rem] border border-stone-800 bg-stone-900">
            <img
              src="/landing/outfit.webp"
              srcSet="/landing/outfit-640.webp 640w, /landing/outfit.webp 864w"
              sizes="(min-width: 1024px) 42vw, calc(100vw - 32px)"
              alt="Studio-style full-length portrait in a green shirt and brown trousers"
              className="aspect-[4/5] h-full w-full object-cover object-top"
              loading="lazy"
              width={864}
              height={1152}
            />
          </div>
          <figcaption className="mt-4 flex items-center justify-between gap-4 border-t border-stone-800 pt-4 text-xs uppercase tracking-[0.14em] text-stone-400">
            <span>Example result</span>
            <span>Studio-style portrait</span>
          </figcaption>
        </figure>
      </div>
    </section>
  )
}
