/**
 * DemoSection Component
 *
 * Interactive demo section for the landing page featuring:
 * - Try Extraction: Upload photo to see AI item extraction
 * - Try On: Upload person + outfit photos for virtual try-on
 * - AI Photoshoot: Generate professional-styled images
 */

import { Badge } from '@/components/ui/badge'
import { AnimatedSection } from './AnimatedSection'
import { ExtractionDemo } from './ExtractionDemo'
import { TryOnDemo } from './TryOnDemo'
import { PhotoshootDemo } from './PhotoshootDemo'
import { Sparkles } from 'lucide-react'

export default function DemoSection() {
  return (
    <section id="demo" className="py-24 bg-white dark:bg-gray-950">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="text-center max-w-3xl mx-auto mb-16">
            <Badge className="mb-4 bg-purple-100 text-purple-700 dark:bg-purple-900/50 dark:text-purple-300 border-0">
              <Sparkles className="w-3 h-3 mr-2" />
              Try It Now
            </Badge>
            <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-gray-900 dark:text-white">
              Experience the{' '}
              <span className="bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
                AI Magic
              </span>
            </h2>
            <p className="mt-4 text-lg md:text-xl text-gray-600 dark:text-gray-300">
              No signup required. See what FitCheck AI can do for your wardrobe.
            </p>
          </div>
        </AnimatedSection>

        {/* Three-column layout for demos */}
        <div className="grid md:grid-cols-3 gap-8">
          <AnimatedSection delay={100}>
            <ExtractionDemo />
          </AnimatedSection>

          <AnimatedSection delay={200}>
            <TryOnDemo />
          </AnimatedSection>

          <AnimatedSection delay={300}>
            <PhotoshootDemo />
          </AnimatedSection>
        </div>
      </div>
    </section>
  )
}
