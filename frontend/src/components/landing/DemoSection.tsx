/**
 * DemoSection - interactive product demos on the landing page.
 */

import { AnimatedSection } from './AnimatedSection'
import { ExtractionDemo } from './ExtractionDemo'
import { TryOnDemo } from './TryOnDemo'
import { PhotoshootDemo } from './PhotoshootDemo'

export default function DemoSection() {
  return (
    <section id="demo" className="py-20 md:py-28 bg-white dark:bg-stone-950">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="max-w-2xl mb-12 md:mb-16">
            <h2 className="landing-display text-3xl sm:text-4xl md:text-[2.75rem] font-semibold text-stone-900 dark:text-stone-50 leading-tight">
              Try it without signing up
            </h2>
            <p className="mt-4 text-base md:text-lg text-stone-600 dark:text-stone-400 leading-relaxed">
              Run extraction, try-on, and photoshoot demos on real photos. Limits apply; create a free account to keep your work.
            </p>
          </div>
        </AnimatedSection>

        <div className="grid md:grid-cols-3 gap-5 md:gap-6">
          <AnimatedSection delay={80}>
            <ExtractionDemo />
          </AnimatedSection>
          <AnimatedSection delay={140}>
            <TryOnDemo />
          </AnimatedSection>
          <AnimatedSection delay={200}>
            <PhotoshootDemo />
          </AnimatedSection>
        </div>
      </div>
    </section>
  )
}
