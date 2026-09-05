/**
 * DemoSection - interactive product demos on the landing page.
 */

import { AnimatedSection } from './AnimatedSection'
import { SectionKicker } from './SectionKicker'
import { ExtractionDemo } from './ExtractionDemo'
import { TryOnDemo } from './TryOnDemo'
import { PhotoshootDemo } from './PhotoshootDemo'

export default function DemoSection() {
  return (
    <section id="demo" className="scroll-mt-16 bg-surface-soft py-20 md:py-28">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <AnimatedSection className="reveal">
          <div className="mb-12 max-w-2xl md:mb-16">
            <SectionKicker tone="coral">Live demo</SectionKicker>
            <h2 className="landing-display text-3xl font-semibold leading-tight text-foreground sm:text-4xl md:text-[2.75rem]">
              Product proof you can run yourself
            </h2>
            <p className="mt-4 text-base leading-relaxed text-body md:text-lg">
              Try extraction, virtual try-on, and Photoshoot Studio without an account. Demo limits are about 3 extraction, 2 try-on, and 1 photoshoot run per IP each day.
            </p>
          </div>
        </AnimatedSection>

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

        <p className="mt-4 text-xs text-muted-foreground lg:hidden">
          Swipe to test all three demos.
        </p>
      </div>
    </section>
  )
}
