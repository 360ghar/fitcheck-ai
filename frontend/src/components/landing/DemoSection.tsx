/**
 * DemoSection Component
 *
 * Interactive demo section for the landing page featuring:
 * - Try Extraction: Upload photo to see AI item extraction
 * - Try On: Upload person + outfit photos for virtual try-on
 */

import { Badge } from '@/components/ui/badge'
import { AnimatedSection } from './AnimatedSection'
import { ExtractionDemo } from './ExtractionDemo'
import { TryOnDemo } from './TryOnDemo'
import { Sparkles } from 'lucide-react'

export default function DemoSection() {
  return (
    <section id="demo" className="py-24 bg-white dark:bg-navy-950">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="text-center max-w-3xl mx-auto mb-16">
            <Badge variant="gold" className="mb-4">
              <Sparkles className="w-3 h-3 mr-2" />
              Try It Now
            </Badge>
            <h2 className="text-3xl sm:text-4xl md:text-5xl font-display font-semibold text-navy-800 dark:text-white">
              Experience the{' '}
              <span className="text-gold-500 dark:text-gold-400">
                AI Magic
              </span>
            </h2>
            <p className="mt-4 text-lg md:text-xl text-navy-500 dark:text-navy-300">
              No signup required. See what FitCheck AI can do for your wardrobe.
            </p>
          </div>
        </AnimatedSection>

        {/* Two-column layout for demos */}
        <div className="grid md:grid-cols-2 gap-8">
          <AnimatedSection delay={100}>
            <ExtractionDemo />
          </AnimatedSection>

          <AnimatedSection delay={200}>
            <TryOnDemo />
          </AnimatedSection>
        </div>
      </div>
    </section>
  )
}
