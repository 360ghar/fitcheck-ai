import { Link } from 'react-router-dom'
import { AnimatedSection } from './AnimatedSection'

const steps = [
  {
    id: 'step-photograph',
    verb: 'Photograph',
    title: 'Snap what you own',
    description:
      'Shoot singles or full hangs. FitCheck reads the image and files each piece for you.',
    href: '/features/ai-wardrobe-extraction',
    linkLabel: 'How extraction works',
  },
  {
    id: 'step-catalog',
    verb: 'Catalog',
    title: 'Your closet, searchable',
    description:
      'Colors, categories, and styles land automatically so you stop hunting for that one shirt.',
    href: '/features/wardrobe-analytics',
    linkLabel: 'Wardrobe analytics',
  },
  {
    id: 'step-wear',
    verb: 'Wear',
    title: 'Outfits that fit the day',
    description:
      'Get recommendations, try looks on, and plan the week without decision fatigue.',
    href: '/features/outfit-recommendations',
    linkLabel: 'Daily outfit ideas',
  },
]

export default function HowItWorks() {
  return (
    <section id="how-it-works" className="py-20 md:py-28 bg-stone-50 dark:bg-stone-900/40">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="max-w-2xl mb-12 md:mb-16">
            <h2 className="landing-display text-3xl sm:text-4xl md:text-[2.75rem] font-semibold text-stone-900 dark:text-stone-50 leading-tight">
              Three moves. Morning solved.
            </h2>
            <p className="mt-4 text-base md:text-lg text-stone-600 dark:text-stone-400">
              No multi-day setup. Upload a few photos and start getting useful outfits the same day.
            </p>
          </div>
        </AnimatedSection>

        <div className="grid md:grid-cols-3 gap-0 md:gap-0 border border-stone-200 dark:border-stone-800 rounded-2xl overflow-hidden">
          {steps.map((step, index) => (
            <AnimatedSection key={step.verb} delay={index * 80} className="h-full">
              <div
                id={step.id}
                className={
                  index < steps.length - 1
                    ? 'h-full border-b md:border-b-0 md:border-r border-stone-200 dark:border-stone-800 p-7 md:p-9'
                    : 'h-full p-7 md:p-9'
                }
              >
                <p className="text-xs font-semibold uppercase tracking-[0.16em] text-indigo-600 dark:text-indigo-400">
                  {step.verb}
                </p>
                <h3 className="mt-4 text-xl font-semibold text-stone-900 dark:text-stone-50 tracking-tight">
                  {step.title}
                </h3>
                <p className="mt-3 text-sm md:text-[15px] text-stone-600 dark:text-stone-400 leading-relaxed">
                  {step.description}
                </p>
                <Link
                  to={step.href}
                  className="mt-4 inline-block text-sm font-medium text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300 transition-colors"
                >
                  {step.linkLabel}
                </Link>
              </div>
            </AnimatedSection>
          ))}
        </div>

        <AnimatedSection delay={160}>
          <div className="mt-10 md:mt-12 relative rounded-2xl overflow-hidden border border-stone-200 dark:border-stone-800 aspect-[16/10] sm:aspect-[21/9] max-h-[360px]">
            <img
              src="/landing/outfit.jpg"
              alt="A complete everyday outfit ready to wear"
              className="w-full h-full object-cover object-[center_20%]"
              loading="lazy"
            />
            <div className="absolute inset-0 bg-stone-950/20" />
            <div className="absolute bottom-4 left-4 md:bottom-6 md:left-6 flex flex-wrap items-center gap-3">
              <div className="rounded-lg bg-white/95 dark:bg-stone-950/90 px-4 py-2.5 text-sm font-medium text-stone-900 dark:text-stone-50 border border-stone-200/60 dark:border-stone-800">
                From catalog to wear in one flow
              </div>
              <a
                href="#demo"
                className="rounded-lg bg-indigo-600 px-4 py-2.5 text-sm font-medium text-white hover:bg-indigo-700 transition-colors"
              >
                Try extraction free
              </a>
            </div>
          </div>
        </AnimatedSection>
      </div>
    </section>
  )
}
