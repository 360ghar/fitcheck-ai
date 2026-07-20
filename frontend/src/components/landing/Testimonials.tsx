import { AnimatedSection } from './AnimatedSection'
import { PLAN_LIMITS } from '@/lib/plan-limits'

const outcomes = [
  {
    title: 'Upload once',
    body: 'Stop re-photographing the same pieces. Your closet becomes a reusable library.',
  },
  {
    title: 'Dress faster',
    body: 'Pull a weather-aware outfit from what you already own instead of starting from zero.',
  },
  {
    title: 'Waste less',
    body: 'See neglected items and cost-per-wear so new buys fill real gaps, not impulse.',
  },
]

export default function Testimonials() {
  return (
    <section className="py-20 md:py-28 bg-stone-50 dark:bg-stone-900/40">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="max-w-2xl mb-12 md:mb-14">
            <h2 className="landing-display text-3xl sm:text-4xl md:text-[2.75rem] font-semibold text-stone-900 dark:text-stone-50 leading-tight">
              Built for how people actually get dressed
            </h2>
            <p className="mt-4 text-base md:text-lg text-stone-600 dark:text-stone-400">
              Less scrolling for inspiration. More usable combinations from the clothes already in your room.
              Free includes {PLAN_LIMITS.free.monthlyExtractions} extractions and{' '}
              {PLAN_LIMITS.free.monthlyGenerations} outfit visualizations each month — upgrade when you need more.
            </p>
          </div>
        </AnimatedSection>

        <div className="grid md:grid-cols-3 gap-8 md:gap-10">
          {outcomes.map((item, index) => (
            <AnimatedSection key={item.title} delay={index * 80}>
              <div className="h-full border-t border-stone-200 dark:border-stone-800 pt-6">
                <h3 className="text-xl font-semibold text-stone-900 dark:text-stone-50">
                  {item.title}
                </h3>
                <p className="mt-2 text-stone-600 dark:text-stone-400 leading-relaxed">
                  {item.body}
                </p>
              </div>
            </AnimatedSection>
          ))}
        </div>

        <AnimatedSection delay={200}>
          <blockquote className="mt-14 md:mt-16 max-w-3xl border-l-2 border-indigo-600 pl-6 md:pl-8">
            <p className="text-lg md:text-xl text-stone-800 dark:text-stone-200 leading-relaxed font-medium">
              &ldquo;I stopped staring at a full closet wondering why nothing worked. Now I pick from outfits that already fit the weather and what I own.&rdquo;
            </p>
            <footer className="mt-4 text-sm text-stone-500 dark:text-stone-400">
              Early web user - product feedback
            </footer>
          </blockquote>
        </AnimatedSection>
      </div>
    </section>
  )
}
