import { Link } from 'react-router-dom'
import { ArrowRight, Camera, Check } from 'lucide-react'

import { Button } from '@/components/ui/button'
import { GeneratedImage } from '@/components/ui/generated-image'
import { PLAN_LIMITS } from '@/lib/plan-limits'

const facts = [
  'Uses clothes selected from your wardrobe',
  'Supports professional, dating, social, and custom settings',
  `${PLAN_LIMITS.free.dailyPhotoshootImages} photoshoot images per day on Free`,
]

export default function PhotoshootShowcase() {
  return (
    // The page's one sanctioned dark break: stone-950 is warm and keeps the
    // drama of the photoshoot moment (clay.com keeps dark sections rare).
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
          <Button
            size="lg"
            // The black `shadow-offset` hover is invisible on the dark break;
            // this section is the sanctioned home of the white offset variant.
            className="mt-8 h-12 px-6 hover:shadow-[7px_7px_0_0_rgba(255,255,255,0.9)]"
            asChild
          >
            <Link to="/features/ai-photoshoot-generator">
              Explore Photoshoot Studio
              <ArrowRight className="ml-2 h-4 w-4" aria-hidden="true" />
            </Link>
          </Button>
        </div>

        <div className="grid min-w-0 gap-6 sm:grid-cols-2 lg:col-span-6">
          <figure className="group min-w-0">
            <div className="overflow-hidden rounded-[2rem] border border-stone-800 bg-stone-900 transition-[box-shadow,transform] duration-150 ease-out group-hover:shadow-[7px_7px_0_0_rgba(255,255,255,0.9)] motion-safe:group-hover:-translate-x-0.5 motion-safe:group-hover:-translate-y-0.5">
              <img
                src="/generated/lifestyle-jaipur-3x4-640.webp"
                srcSet="/generated/lifestyle-jaipur-3x4-640.webp 640w, /generated/lifestyle-jaipur-3x4.webp 900w"
                sizes="(min-width: 1024px) 21vw, (min-width: 640px) calc(50vw - 32px), calc(100vw - 32px)"
                alt="Golden-hour portrait example in a rust slip dress"
                className="aspect-[4/5] h-full w-full object-cover object-top"
                loading="lazy"
                width={900}
                height={1200}
              />
            </div>
            <figcaption className="mt-4 flex items-center justify-between gap-4 border-t border-stone-800 pt-4 text-xs uppercase tracking-[0.14em] text-stone-400">
              <span>Example result</span>
              <span>AI-generated example</span>
            </figcaption>
          </figure>

          <figure className="group min-w-0">
            <div className="overflow-hidden rounded-[2rem] border border-stone-800 bg-stone-900 transition-[box-shadow,transform] duration-150 ease-out group-hover:shadow-[7px_7px_0_0_rgba(255,255,255,0.9)] motion-safe:group-hover:-translate-x-0.5 motion-safe:group-hover:-translate-y-0.5">
              <GeneratedImage
                src="/generated/photoshoot-studio-3x4-640.webp"
                srcSet="/generated/photoshoot-studio-3x4-640.webp 640w, /generated/photoshoot-studio-3x4.webp 1728w"
                sizes="(min-width: 1024px) 21vw, (min-width: 640px) calc(50vw - 32px), calc(100vw - 32px)"
                alt="Studio-style portrait example generated from a phone selfie"
                className="aspect-[3/4] h-full w-full object-cover object-top"
                loading="lazy"
                width={1728}
                height={2304}
                fallback="hide-figure"
              />
            </div>
            <figcaption className="mt-4 flex items-center justify-between gap-4 border-t border-stone-800 pt-4 text-xs uppercase tracking-[0.14em] text-stone-400">
              <span>Example result, not before/after</span>
              <span>AI-generated example</span>
            </figcaption>
          </figure>
        </div>
      </div>
    </section>
  )
}
