import { Link } from 'react-router-dom'
import { ArrowUpRight } from 'lucide-react'

import { GeneratedImage } from '@/components/ui/generated-image'
import { PLAN_LIMITS } from '@/lib/plan-limits'

const facts = [
  { term: 'Try-on', detail: 'A combination from your closet, on your own photo.' },
  { term: 'Photoshoot', detail: 'LinkedIn, dating, social or a custom scene, from one selfie.' },
  {
    term: 'On Free',
    detail: `${PLAN_LIMITS.free.dailyPhotoshootImages} photoshoot images a day.`,
  },
]

/* Two example prints, laid on the clay sheet at a slight angle. */
const PRINTS = [
  {
    src: '/generated/lifestyle-jaipur-3x4-640.webp',
    srcSet: '/generated/lifestyle-jaipur-3x4-640.webp 640w, /generated/lifestyle-jaipur-3x4.webp 900w',
    alt: 'Golden-hour portrait example in a rust slip dress on a market street',
    width: 900,
    height: 1200,
    frame: 'sm:-rotate-2 sm:translate-y-6',
  },
  {
    src: '/generated/photoshoot-studio-3x4-640.webp',
    srcSet: '/generated/photoshoot-studio-3x4-640.webp 640w, /generated/photoshoot-studio-3x4.webp 1728w',
    alt: 'Studio-style portrait example in a navy blazer, generated from a phone selfie',
    width: 1728,
    height: 2304,
    frame: 'sm:rotate-[1.5deg]',
  },
]

export default function PhotoshootShowcase() {
  return (
    <section
      id="photoshoot-showcase"
      aria-labelledby="photoshoot-showcase-heading"
      className="paper-section paper-tear stock-clay pb-24 pt-20 md:pb-32 md:pt-28"
    >
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <h2
          id="photoshoot-showcase-heading"
          className="paper-display text-[clamp(2.4rem,5.2vw,4.5rem)] text-paper-text"
        >
          See it before you wear it.
        </h2>
        <div className="mt-10 grid grid-cols-1 gap-14 lg:mt-14 lg:grid-cols-12 lg:items-center lg:gap-16">
          <div className="min-w-0 lg:col-span-5">
            <p className="max-w-md text-base leading-relaxed text-paper-text-2 sm:text-[17px]">
              Preview an outfit on yourself, or shoot it like a campaign. The pictures on the right
              are AI-generated examples.
            </p>
            <dl className="mt-8 grid gap-4">
              {facts.map((fact) => (
                <div key={fact.term} className="grid grid-cols-[7rem_minmax(0,1fr)] gap-4">
                  <dt className="paper-head text-xl text-paper-accent">{fact.term}</dt>
                  <dd className="pt-1 text-[15px] leading-relaxed text-paper-text-2">{fact.detail}</dd>
                </div>
              ))}
            </dl>
            <Link to="/features/ai-photoshoot-generator" className="paper-btn-sheet mt-9">
              Explore Photoshoot Studio
              <ArrowUpRight className="h-4 w-4" aria-hidden="true" />
            </Link>
          </div>

          <div className="grid min-w-0 grid-cols-2 gap-4 sm:gap-8 lg:col-span-7">
            {PRINTS.map((print) => (
              <figure key={print.src} className={`paper-sheet min-w-0 p-2 sm:p-3 ${print.frame}`}>
                <GeneratedImage
                  src={print.src}
                  srcSet={print.srcSet}
                  sizes="(min-width: 1024px) 28vw, 45vw"
                  alt={print.alt}
                  className="aspect-[4/5] h-auto w-full rounded-[10px] object-cover object-top"
                  loading="lazy"
                  decoding="async"
                  width={print.width}
                  height={print.height}
                  fallback="hide-figure"
                />
                <figcaption className="flex items-baseline justify-between gap-2 px-1 pb-1 pt-3 text-xs text-paper-text-3 sm:text-[13px]">
                  <span className="font-semibold text-paper-text-2">Example result</span>
                  <span>AI-generated</span>
                </figcaption>
              </figure>
            ))}
          </div>
        </div>
      </div>
    </section>
  )
}
