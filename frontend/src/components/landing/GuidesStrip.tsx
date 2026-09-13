import { Link } from 'react-router-dom'
import { ArrowUpRight } from 'lucide-react'
import { AnimatedSection } from './AnimatedSection'
import { SectionKicker } from './SectionKicker'

const links = [
  {
    title: 'How to digitize your wardrobe',
    href: '/guides/how-to-digitize-your-wardrobe',
  },
  {
    title: 'What to wear today',
    href: '/guides/what-to-wear-today',
  },
  {
    title: 'Cost per wear calculator',
    href: '/tools/cost-per-wear-calculator',
  },
  {
    title: 'What is a capsule wardrobe?',
    href: '/guides/what-is-a-capsule-wardrobe',
  },
  {
    title: 'FitCheck AI vs Acloset',
    href: '/compare/fitcheck-vs-acloset',
  },
]

/**
 * GuidesStrip — the reading strip above Pricing. Clay treatment: each link is
 * a pressed card (`.card-interactive`) that rises into the hard offset shadow
 * on hover/focus, matching the TrustBar tiles above. The anchor `guides` and
 * every href stay put — only the surface changed.
 */
export default function GuidesStrip() {
  return (
    <section
      id="guides"
      aria-labelledby="guides-heading"
      className="border-y border-border bg-surface-soft py-16 md:py-20"
    >
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <AnimatedSection className="reveal">
          <div className="mb-8 flex flex-col gap-6 md:flex-row md:items-end md:justify-between">
            <div className="max-w-2xl">
              <SectionKicker tone="amber">Guides</SectionKicker>
              <h2
                id="guides-heading"
                className="landing-display text-2xl font-semibold leading-tight text-foreground sm:text-3xl"
              >
                Learn how a digital wardrobe works
              </h2>
              <p className="mt-2 text-body">
                Practical reading if you are comparing virtual closet apps or building a digital wardrobe.
              </p>
            </div>
            {/* Exploration CTA: the conversion CTAs live in Pricing below. */}
            <Link
              to="/blog"
              className="group inline-flex min-h-11 shrink-0 items-center gap-1.5 text-sm font-medium text-primary transition-colors hover:text-primary-pressed"
            >
              Read the blog
              <ArrowUpRight className="h-4 w-4 transition-transform duration-300 group-hover:translate-x-0.5 group-hover:-translate-y-0.5" />
            </Link>
          </div>
        </AnimatedSection>

        <ul className="grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
          {/* AnimatedSection renders a <div> — it must wrap the <li> from
              inside, never sit between <ul> and <li>. A <div> directly inside
              <ul> is invalid markup that breaks the accessibility tree
              ("Lists do not contain only <li> elements") and the semantic
              list for screen readers. */}
          {links.map((link, index) => (
            <li key={link.href} className="min-w-0">
              <AnimatedSection delay={index * 40} className="h-full">
                <Link
                  to={link.href}
                  className="card-interactive group flex h-full min-h-32 flex-col justify-between gap-6 rounded-3xl border border-border bg-card p-5 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                >
                  <span className="text-[15px] font-medium leading-snug text-foreground transition-colors group-hover:text-primary md:text-base">
                    {link.title}
                  </span>
                  <ArrowUpRight className="h-4 w-4 shrink-0 text-muted-foreground transition-all duration-300 group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-primary" />
                </Link>
              </AnimatedSection>
            </li>
          ))}
        </ul>
      </div>
    </section>
  )
}
