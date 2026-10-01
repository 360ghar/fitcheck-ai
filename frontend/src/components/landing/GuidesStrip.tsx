import { Link } from 'react-router-dom'
import { ArrowUpRight } from 'lucide-react'

const links = [
  { title: 'How to digitize your wardrobe', href: '/guides/how-to-digitize-your-wardrobe' },
  { title: 'What to wear today', href: '/guides/what-to-wear-today' },
  { title: 'Cost per wear calculator', href: '/tools/cost-per-wear-calculator' },
  { title: 'What is a capsule wardrobe?', href: '/guides/what-is-a-capsule-wardrobe' },
  { title: 'FitCheck AI vs Acloset', href: '/compare/fitcheck-vs-acloset' },
]

/**
 * GuidesStrip: the reading list between Pricing and the FAQ, set as plain
 * links on marigold paper. The `guides` anchor and every href stay put.
 */
export default function GuidesStrip() {
  return (
    <section
      id="guides"
      aria-labelledby="guides-heading"
      className="paper-section paper-tear stock-marigold pb-20 pt-16 md:pb-24 md:pt-20"
    >
      <div className="mx-auto grid max-w-7xl gap-8 px-4 sm:px-6 lg:grid-cols-12 lg:gap-16 lg:px-8">
        <div className="lg:col-span-4">
          <h2 id="guides-heading" className="paper-head text-[clamp(1.9rem,3.4vw,2.6rem)] text-paper-text">
            Reading for the curious
          </h2>
          <p className="mt-3 text-[15px] leading-relaxed text-paper-text-2">
            Guides for anyone comparing closet apps or building a digital wardrobe.
          </p>
          <Link
            to="/blog"
            className="mt-4 inline-flex min-h-11 items-center gap-1.5 text-[15px] font-semibold text-paper-accent hover:text-paper-text"
          >
            Read the blog
            <ArrowUpRight className="h-4 w-4" aria-hidden="true" />
          </Link>
        </div>
        <ul className="grid gap-x-10 sm:grid-cols-2 lg:col-span-8">
          {links.map((link) => (
            <li key={link.href} className="min-w-0">
              <Link
                to={link.href}
                className="group flex min-h-14 items-center justify-between gap-4 rounded-lg py-3"
              >
                <span className="text-[17px] font-semibold leading-snug text-paper-text transition-colors group-hover:text-paper-accent">
                  {link.title}
                </span>
                <ArrowUpRight
                  className="h-4 w-4 shrink-0 text-paper-text-3 transition-[color,transform] group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-paper-accent"
                  aria-hidden="true"
                />
              </Link>
            </li>
          ))}
        </ul>
      </div>
    </section>
  )
}
