import { Link } from 'react-router-dom'
import { ArrowUpRight } from 'lucide-react'
import { AnimatedSection } from './AnimatedSection'

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

export default function GuidesStrip() {
  return (
    <section id="guides" className="border-y border-border bg-surface-soft py-16 md:py-20">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <AnimatedSection className="reveal">
          <div className="mb-8 flex flex-col gap-6 md:flex-row md:items-end md:justify-between">
            <div className="max-w-2xl">
              <h2 className="landing-display text-2xl sm:text-3xl font-semibold text-foreground leading-tight">
                Guides and comparisons
              </h2>
              <p className="mt-2 text-body">
                Practical reading if you are comparing virtual closet apps or building a digital wardrobe.
              </p>
            </div>
            <Link
              to="/blog"
              className="group inline-flex min-h-11 items-center gap-1.5 text-sm font-medium text-primary hover:text-primary-pressed transition-colors shrink-0"
            >
              Read the blog
              <ArrowUpRight className="h-4 w-4 transition-transform duration-300 group-hover:translate-x-0.5 group-hover:-translate-y-0.5" />
            </Link>
          </div>
        </AnimatedSection>

        <ul className="grid border-t border-border lg:grid-cols-5">
          {/* AnimatedSection renders a <div> — it must wrap the <li> from
              inside, never sit between <ul> and <li>. A <div> directly inside
              <ul> is invalid markup that breaks the accessibility tree
              ("Lists do not contain only <li> elements") and the semantic
              list for screen readers. */}
          {links.map((link, index) => (
            <li key={link.href} className="border-b border-border lg:border-r lg:last:border-r-0">
              <AnimatedSection delay={index * 40}>
                <Link
                  to={link.href}
                  className="group flex min-h-16 items-center justify-between gap-4 px-1 py-4 text-foreground transition-colors hover:text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 lg:px-5"
                >
                  <span className="text-[15px] md:text-base font-medium">{link.title}</span>
                  <ArrowUpRight className="h-4 w-4 shrink-0 text-muted-foreground transition-transform duration-300 group-hover:translate-x-0.5 group-hover:-translate-y-0.5 group-hover:text-primary" />
                </Link>
              </AnimatedSection>
            </li>
          ))}
        </ul>
      </div>
    </section>
  )
}
