import { Link } from 'react-router-dom'
import { ArrowUpRight } from 'lucide-react'
import { AnimatedSection } from './AnimatedSection'

const personas = [
  {
    title: 'Busy professionals',
    body: 'Spend less time deciding what to wear. Weather-aware outfits from your real wardrobe, planned around the week.',
    href: '/for/busy-professionals',
  },
  {
    title: 'Content creators',
    body: 'Plan looks, visualize outfits, and generate photoshoot-style images for content calendars from clothes you own.',
    href: '/for/content-creators',
  },
  {
    title: 'Festive and wedding guests',
    body: 'Digitize ethnic and formal wear, then mix occasion looks without buying a new outfit every invitation.',
    href: '/for/festive-and-wedding-outfits',
  },
]

export default function WhoItsFor() {
  return (
    <section id="who-its-for" className="py-20 md:py-28 bg-white dark:bg-stone-950">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="max-w-2xl mb-12 md:mb-14">
            <h2 className="landing-display text-3xl sm:text-4xl md:text-[2.75rem] font-semibold text-stone-900 dark:text-stone-50 leading-tight">
              Built for how you dress
            </h2>
            <p className="mt-4 text-base md:text-lg text-stone-600 dark:text-stone-400">
              Same wardrobe tools, different mornings. Pick the path that matches your routine.
            </p>
          </div>
        </AnimatedSection>

        <div className="grid md:grid-cols-3 gap-0 border border-stone-200 dark:border-stone-800 rounded-2xl overflow-hidden bg-white dark:bg-stone-950">
          {personas.map((persona, index) => (
            <AnimatedSection key={persona.title} delay={index * 60} className="h-full">
              <Link
                to={persona.href}
                className={
                  index < personas.length - 1
                    ? 'group flex h-full flex-col p-7 md:p-9 border-b md:border-b-0 md:border-r border-stone-200 dark:border-stone-800 transition-colors hover:bg-stone-50 dark:hover:bg-stone-900/50'
                    : 'group flex h-full flex-col p-7 md:p-9 transition-colors hover:bg-stone-50 dark:hover:bg-stone-900/50'
                }
              >
                <div className="flex items-start justify-between gap-3">
                  <h3 className="text-xl font-semibold text-stone-900 dark:text-stone-50 tracking-tight">
                    {persona.title}
                  </h3>
                  <ArrowUpRight className="h-4 w-4 shrink-0 text-stone-400 transition group-hover:text-indigo-600 dark:group-hover:text-indigo-400" />
                </div>
                <p className="mt-3 text-sm md:text-[15px] text-stone-600 dark:text-stone-400 leading-relaxed">
                  {persona.body}
                </p>
              </Link>
            </AnimatedSection>
          ))}
        </div>
      </div>
    </section>
  )
}
