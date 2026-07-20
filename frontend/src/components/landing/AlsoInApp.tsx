import { Link } from 'react-router-dom'
import { ArrowUpRight } from 'lucide-react'
import { AnimatedSection } from './AnimatedSection'

const items = [
  {
    title: 'Batch wardrobe digitizing',
    body: 'Upload many photos at once and extract items in a progress-tracked pipeline.',
  },
  {
    title: 'Instagram import',
    body: 'Pull OOTD photos into a review queue and extract pieces into your closet where enabled.',
  },
  {
    title: 'Calendar week planning',
    body: 'Assign outfits to events and dress for the day without rethinking every morning.',
  },
  {
    title: 'Trip packing lists',
    body: 'Build packing lists from your real wardrobe for travel, style, and weather.',
  },
  {
    title: 'Outfit sharing and feedback',
    body: 'Share a look with a link and collect feedback before you wear it.',
  },
  {
    title: 'Streaks and rewards',
    body: 'Stay in the habit of planning outfits with streaks, milestones, and XP.',
  },
  {
    title: 'Gaps and smarter shopping',
    body: 'See wardrobe gaps and get AI shopping suggestions that fill real holes.',
  },
  {
    title: 'Referrals',
    body: 'Invite a friend and both earn a month of Pro when they join.',
  },
]

export default function AlsoInApp() {
  return (
    <section id="also-in-app" className="py-20 md:py-28 bg-white dark:bg-stone-950">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="max-w-2xl mb-12 md:mb-14">
            <h2 className="landing-display text-3xl sm:text-4xl md:text-[2.75rem] font-semibold text-stone-900 dark:text-stone-50 leading-tight">
              Also in the app
            </h2>
            <p className="mt-4 text-base md:text-lg text-stone-600 dark:text-stone-400">
              Beyond the five tools that get you dressed, FitCheck covers planning, import, sharing, and habits.
            </p>
          </div>
        </AnimatedSection>

        <div className="grid sm:grid-cols-2 gap-x-10 gap-y-0">
          {items.map((item, index) => (
            <AnimatedSection key={item.title} delay={index * 40}>
              <div className="border-t border-stone-200 dark:border-stone-800 py-6">
                <h3 className="text-base font-semibold text-stone-900 dark:text-stone-50">
                  {item.title}
                </h3>
                <p className="mt-1.5 text-sm text-stone-600 dark:text-stone-400 leading-relaxed">
                  {item.body}
                </p>
              </div>
            </AnimatedSection>
          ))}
        </div>

        <AnimatedSection delay={200}>
          <Link
            to="/features"
            className="mt-10 inline-flex items-center gap-1.5 text-sm font-medium text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300 transition-colors"
          >
            See all product features
            <ArrowUpRight className="h-4 w-4" />
          </Link>
        </AnimatedSection>
      </div>
    </section>
  )
}
