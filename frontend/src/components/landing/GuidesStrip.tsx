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
    title: 'Cost per wear explained',
    href: '/guides/cost-per-wear-calculator-explained',
  },
  {
    title: 'FitCheck AI vs Acloset',
    href: '/compare/fitcheck-vs-acloset',
  },
]

export default function GuidesStrip() {
  return (
    <section id="guides" className="py-16 md:py-20 bg-white dark:bg-stone-950">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-6 mb-8">
            <div className="max-w-2xl">
              <h2 className="landing-display text-2xl sm:text-3xl font-semibold text-stone-900 dark:text-stone-50 leading-tight">
                Guides and comparisons
              </h2>
              <p className="mt-2 text-stone-600 dark:text-stone-400">
                Practical reading if you are comparing virtual closet apps or building a digital wardrobe.
              </p>
            </div>
            <Link
              to="/blog"
              className="inline-flex items-center gap-1.5 text-sm font-medium text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300 transition-colors shrink-0"
            >
              Read the blog
              <ArrowUpRight className="h-4 w-4" />
            </Link>
          </div>
        </AnimatedSection>

        <ul className="divide-y divide-stone-200 dark:divide-stone-800 border-y border-stone-200 dark:border-stone-800">
          {links.map((link, index) => (
            <AnimatedSection key={link.href} delay={index * 40}>
              <li>
                <Link
                  to={link.href}
                  className="group flex items-center justify-between gap-4 py-4 text-stone-900 dark:text-stone-50 hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors"
                >
                  <span className="text-[15px] md:text-base font-medium">{link.title}</span>
                  <ArrowUpRight className="h-4 w-4 shrink-0 text-stone-400 group-hover:text-indigo-600 dark:group-hover:text-indigo-400" />
                </Link>
              </li>
            </AnimatedSection>
          ))}
        </ul>
      </div>
    </section>
  )
}
