/**
 * DemoSection - interactive product demos on the landing page.
 */

import { AnimatedSection } from './AnimatedSection'
import { ExtractionDemo } from './ExtractionDemo'
import { TryOnDemo } from './TryOnDemo'
import { PhotoshootDemo } from './PhotoshootDemo'
import { DEMO_RATE_LIMITS } from '@/lib/demo-limits'

export default function DemoSection() {
  return (
    <section
      id="demo"
      aria-labelledby="demo-heading"
      className="paper-section paper-tear stock-stone pb-24 pt-20 md:pb-32 md:pt-28"
    >
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mb-12 grid gap-6 md:mb-14 lg:grid-cols-[minmax(0,1fr)_24rem] lg:items-end lg:gap-12">
          <h2
            id="demo-heading"
            tabIndex={-1}
            className="paper-display text-[clamp(2.4rem,5.4vw,4.25rem)] text-paper-text outline-none"
          >
            Try it on your own photos.
          </h2>
          <p className="max-w-md text-base leading-relaxed text-paper-text-2 sm:text-[17px]">
            No account needed. About {DEMO_RATE_LIMITS.extraction} extractions,{' '}
            {DEMO_RATE_LIMITS.tryOn} try-ons and {DEMO_RATE_LIMITS.photoshoot} photoshoot a day.
          </p>
        </div>

        <div className="min-w-0 max-w-full overflow-hidden [contain:paint]">
          <div
            data-testid="demo-rail"
            className="reveal-steps flex w-full snap-x snap-mandatory gap-4 overflow-x-auto pb-4 pr-4 lg:grid lg:grid-cols-3 lg:gap-6 lg:overflow-visible lg:pb-0 lg:pr-0"
          >
            <AnimatedSection
              delay={80}
              className="w-full min-w-0 shrink-0 snap-start sm:w-[24rem] lg:w-auto lg:shrink"
            >
              <ExtractionDemo />
            </AnimatedSection>
            <AnimatedSection
              delay={140}
              className="w-full min-w-0 shrink-0 snap-start sm:w-[24rem] lg:w-auto lg:shrink"
            >
              <TryOnDemo />
            </AnimatedSection>
            <AnimatedSection
              delay={200}
              className="w-full min-w-0 shrink-0 snap-start sm:w-[24rem] lg:w-auto lg:shrink"
            >
              <PhotoshootDemo />
            </AnimatedSection>
          </div>
        </div>

        <p className="mt-4 text-xs text-paper-text-3 lg:hidden">
          Swipe to test all three demos.
        </p>
      </div>
    </section>
  )
}
