import { Link } from 'react-router-dom'
import { ArrowUpRight } from 'lucide-react'
import { AnimatedSection } from './AnimatedSection'

/**
 * SIX entries, and the count is load-bearing: six tiles fill every row at 1, 2
 * and 3 columns, so there is never a half-populated last row. This was seven
 * after the streaks entry came out (gamification is flagged off and never
 * worked — do NOT re-add a streaks/XP claim), and seven in a 2-column grid left
 * one filled cell beside one empty one with the row rule stopping halfway
 * across the container. The fix was not padding the list back to eight: the two
 * intake paths, bulk upload and Instagram, are one capability — "get what you
 * already own into the closet" — and they always shared the same review queue,
 * so stating them as one truthful card is more accurate than splitting them.
 */
const items = [
  {
    // Kept to 25 characters on purpose: at the narrowest real two-column width
    // (~284px) a longer title wrapped to two lines and pushed its own body a
    // line below its neighbour's, which is the ragged-column tell. No title
    // here exceeds "Outfit sharing and feedback", which holds one line well
    // below that width.
    title: 'Bulk and Instagram import',
    body: 'Extract items from many photos at once in a progress-tracked pipeline. Where enabled, pull OOTD posts from Instagram into the same review queue.',
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
              Beyond the five tools that get you dressed, FitCheck covers planning, import, sharing, and what to buy next.
            </p>
          </div>
        </AnimatedSection>

        {/* Rhythm, not rules. Each tile used to carry its own `border-t`, which
            in a 2-column grid drew a comb of short hairlines and — on an odd
            count — left one of them hanging half-way across the container. Real
            spacing and type hierarchy separate the rows instead, which cannot
            go ragged at any count or breakpoint.
            Alignment does not depend on content length here: the title is
            height-reserved so a wrap cannot shove its own body down relative to
            its neighbours, and the body is the LAST element in the tile, so an
            uneven body length has nothing below it to push out of step. */}
        <div className="grid gap-x-10 gap-y-10 sm:grid-cols-2 lg:grid-cols-3">
          {items.map((item) => (
            <AnimatedSection key={item.title} className="h-full">
              <div className="flex h-full flex-col">
                <h3 className="min-h-7 text-base font-semibold leading-7 text-stone-900 dark:text-stone-50">
                  {item.title}
                </h3>
                <p className="mt-2 text-sm leading-relaxed text-stone-600 dark:text-stone-400">
                  {item.body}
                </p>
              </div>
            </AnimatedSection>
          ))}
        </div>

        <AnimatedSection delay={200}>
          <Link
            to="/features"
            className="mt-10 inline-flex min-h-11 items-center gap-1.5 text-sm font-medium text-primary hover:text-primary-pressed transition-colors"
          >
            See all product features
            <ArrowUpRight className="h-4 w-4" />
          </Link>
        </AnimatedSection>
      </div>
    </section>
  )
}
