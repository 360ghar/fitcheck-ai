import { Link } from 'react-router-dom'
import { ArrowUpRight } from 'lucide-react'

import { GeneratedImage } from '@/components/ui/generated-image'

import { SIGNATURE_ITEMS } from './signature-data'

const SIZE = Object.fromEntries(SIGNATURE_ITEMS.map((item) => [item.key, item]))

/*
 * An example week, dressed only from the six pieces in the hero photo (same
 * cut-outs, /signature/*.webp). The weather values are an illustration.
 */
const WEEK: Array<{ day: string; weather: string; pieces: string[]; today?: boolean }> = [
  { day: 'Mon', weather: '24° clear', pieces: ['tee', 'trousers', 'sneakers'], today: true },
  { day: 'Tue', weather: '19° cloud', pieces: ['stripe', 'trousers', 'sneakers'] },
  { day: 'Wed', weather: '16° wind', pieces: ['jacket', 'tee', 'trousers'] },
  { day: 'Thu', weather: '14° rain', pieces: ['sweater', 'jacket', 'trousers'] },
  { day: 'Fri', weather: '21° sun', pieces: ['stripe', 'jacket', 'sneakers'] },
]

const capabilities = [
  {
    verb: 'Catalog',
    body: 'Colour, category and material from single pieces, hangs and piles. You review before it saves.',
    href: '/features/ai-wardrobe-extraction',
  },
  {
    verb: 'Plan',
    body: 'Daily outfits and calendar events matched to the forecast and the occasion.',
    href: '/features/outfit-recommendations',
  },
  {
    verb: 'Preview',
    body: 'Try a combination on your own photo before you change or buy.',
    href: '/features/virtual-try-on',
  },
  {
    verb: 'Create',
    body: 'Studio-style images for LinkedIn, dating or social from one selfie.',
    href: '/features/ai-photoshoot-generator',
  },
  {
    verb: 'Understand',
    body: 'Wear counts, cost per wear and the gaps worth filling next.',
    href: '/features/wardrobe-analytics',
  },
]

const alsoInApp = [
  { title: 'Bulk and Instagram import', body: 'Many photos into one review queue. Instagram import where enabled.' },
  { title: 'Week planning', body: 'Assign outfits to events before the morning rush.' },
  { title: 'Packing lists', body: 'Packing lists from your real wardrobe, for the trip and its weather.' },
  { title: 'Sharing and feedback', body: 'Share a look by link and collect opinions before you wear it.' },
  { title: 'Smarter shopping', body: 'Find the gaps, so a new purchase solves a real need.' },
  { title: 'Referrals', body: 'Invite a friend. Both accounts get one month of Pro when they join.' },
]

/* Where each piece sits in a day's little collage (percent of the tile). */
const COLLAGE = [
  'left-[4%] top-[4%] w-[58%] rotate-[-4deg]',
  'right-[2%] top-[18%] w-[56%] rotate-[3deg]',
  'left-[22%] bottom-[2%] w-[50%] rotate-[-1deg]',
]

export default function Features() {
  return (
    <section id="features" className="paper-section paper-tear stock-marigold pb-24 pt-20 md:pb-32 md:pt-28">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_22rem] lg:items-end lg:gap-12">
          <h2 className="paper-display text-[clamp(2.4rem,6vw,4.75rem)] text-paper-text">
            Get dressed faster.
          </h2>
          <p className="max-w-md text-base leading-relaxed text-paper-text-2 sm:text-[17px]">
            Outfits from what you own, matched to the weather and your plans. Here is a week from
            the six pieces above.
          </p>
        </div>

        <ol
          aria-label="An example week of outfits"
          className="scroll-rail -mx-4 mt-12 flex snap-x gap-4 overflow-x-auto px-4 pb-4 sm:mx-0 sm:grid sm:grid-cols-5 sm:overflow-visible sm:px-0 md:gap-5"
        >
          {WEEK.map((day) => (
            <li
              key={day.day}
              className={`paper-sheet w-[46vw] max-w-[220px] shrink-0 snap-start p-3 sm:w-auto sm:max-w-none ${
                day.today ? 'ring-2 ring-paper-accent' : ''
              }`}
            >
              <p className="flex items-baseline justify-between gap-2">
                <span className="paper-head text-xl text-paper-text">{day.today ? 'Today' : day.day}</span>
                <span className="text-xs tabular-nums text-paper-text-3">{day.weather}</span>
              </p>
              <div className="relative mt-2 aspect-[4/5]">
                {day.pieces.map((piece, index) => (
                  <GeneratedImage
                    key={piece}
                    src={`/signature/${piece}.webp`}
                    alt={SIZE[piece].name}
                    width={SIZE[piece].width}
                    height={SIZE[piece].height}
                    loading="lazy"
                    decoding="async"
                    className={`paper-cutout absolute h-auto ${COLLAGE[index]}`}
                  />
                ))}
              </div>
            </li>
          ))}
        </ol>
        <p className="mt-3 text-xs text-paper-text-3">Example week. The weather is illustrative.</p>

        <ul className="mt-16 grid gap-x-8 gap-y-10 sm:grid-cols-2 lg:grid-cols-5 md:mt-20">
          {capabilities.map((capability) => (
            <li key={capability.verb} className="reveal">
              <Link to={capability.href} className="group block rounded-lg">
                <span className="flex items-center gap-1.5">
                  <span className="paper-head text-[1.7rem] text-paper-text transition-colors group-hover:text-paper-accent">
                    {capability.verb}
                  </span>
                  <ArrowUpRight
                    className="h-5 w-5 text-paper-text-3 transition-[color,transform] group-hover:translate-x-0.5 group-hover:-translate-y-0.5 group-hover:text-paper-accent"
                    aria-hidden="true"
                  />
                </span>
                <span className="mt-2 block text-[15px] leading-relaxed text-paper-text-2">
                  {capability.body}
                </span>
              </Link>
            </li>
          ))}
        </ul>

        <div id="also-in-app" className="mt-20 md:mt-24">
          <h3 className="paper-head text-[1.7rem] text-paper-text">Also in the app</h3>
          <ul className="mt-6 grid gap-x-8 gap-y-6 sm:grid-cols-2 lg:grid-cols-3">
            {alsoInApp.map((item) => (
              <li key={item.title}>
                <p className="text-[15px] font-semibold text-paper-text">{item.title}</p>
                <p className="mt-1 text-[15px] leading-relaxed text-paper-text-2">{item.body}</p>
              </li>
            ))}
          </ul>
          <Link
            to="/features"
            className="mt-8 inline-flex min-h-11 items-center gap-1.5 text-[15px] font-semibold text-paper-accent hover:text-paper-text"
          >
            Every feature
            <ArrowUpRight className="h-4 w-4" aria-hidden="true" />
          </Link>
        </div>
      </div>
    </section>
  )
}
