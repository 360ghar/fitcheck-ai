import { Link } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { AnimatedSection } from '@/components/landing/AnimatedSection'
import SEO from '@/components/seo/SEO'
import { BreadcrumbJsonLd, buildFaqSchema } from '@/components/seo/JsonLd'
import { SEO_CONFIG } from '@/components/seo/seo-config'
import { ArrowRight, Check, Play } from 'lucide-react'
import { cn } from '@/lib/utils'

export interface SeoFaq {
  question: string
  answer: string
}

export interface SeoSection {
  heading: string
  body: string | string[]
  bullets?: string[]
}

export interface SeoRelatedLink {
  label: string
  href: string
}

export interface SeoPageContent {
  path: string
  title: string
  description: string
  h1: string
  /** Answer-first lede (40–80 words ideal) */
  lede: string
  breadcrumbs: Array<{ name: string; path: string }>
  sections: SeoSection[]
  faqs: SeoFaq[]
  relatedLinks?: SeoRelatedLink[]
  keywords?: string
  ctaPrimary?: { label: string; href: string }
  ctaSecondary?: { label: string; href: string; external?: boolean }
}

const PLAY_STORE =
  'https://play.google.com/store/apps/details?id=com.fitcheckaiapp.fitcheckai&hl=en_IN'

export function SeoPageLayout({ content }: { content: SeoPageContent }) {
  const canonical = `${SEO_CONFIG.siteUrl}${content.path}`
  const breadcrumbItems = content.breadcrumbs.map((b) => ({
    name: b.name,
    url: b.path.startsWith('http') ? b.path : `${SEO_CONFIG.siteUrl}${b.path}`,
  }))

  const faqSchema = content.faqs.length ? buildFaqSchema(content.faqs) : undefined
  const primary = content.ctaPrimary || { label: 'Start free', href: '/auth/register' }
  const secondary = content.ctaSecondary || {
    label: 'Get the app',
    href: PLAY_STORE,
    external: true,
  }

  return (
    <>
      <SEO
        title={content.title}
        description={content.description}
        canonicalUrl={canonical}
        keywords={content.keywords}
        jsonLd={faqSchema}
      />
      <BreadcrumbJsonLd items={breadcrumbItems} />

      <div className="pt-20">
        <section className="py-12 md:py-16 bg-stone-50 dark:bg-stone-950 border-b border-stone-200 dark:border-stone-800">
          <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
            <nav className="mb-6 text-sm text-stone-500 dark:text-stone-400 flex flex-wrap gap-1.5">
              {content.breadcrumbs.map((b, i) => (
                <span key={b.path} className="flex items-center gap-1.5">
                  {i > 0 && <span aria-hidden>/</span>}
                  {i < content.breadcrumbs.length - 1 ? (
                    <Link to={b.path} className="hover:text-indigo-600 dark:hover:text-indigo-400">
                      {b.name}
                    </Link>
                  ) : (
                    <span className="text-stone-700 dark:text-stone-300">{b.name}</span>
                  )}
                </span>
              ))}
            </nav>

            <AnimatedSection>
              <h1 className="landing-display text-3xl sm:text-4xl md:text-[2.75rem] font-semibold text-stone-900 dark:text-stone-50 leading-tight">
                {content.h1}
              </h1>
              <p className="mt-5 text-lg text-stone-600 dark:text-stone-400 leading-relaxed">
                {content.lede}
              </p>
              <div className="mt-8 flex flex-col sm:flex-row gap-3">
                <Button
                  size="lg"
                  className="bg-indigo-600 hover:bg-indigo-700 text-white h-12 px-6 shadow-none"
                  asChild
                >
                  <Link to={primary.href}>
                    {primary.label}
                    <ArrowRight className="ml-2 h-4 w-4" />
                  </Link>
                </Button>
                <Button
                  size="lg"
                  variant="outline"
                  className="h-12 px-6 border-stone-300 dark:border-stone-700"
                  asChild
                >
                  {secondary.external ? (
                    <a href={secondary.href} target="_blank" rel="noopener noreferrer">
                      <Play className="mr-2 h-4 w-4 fill-current" />
                      {secondary.label}
                    </a>
                  ) : (
                    <Link to={secondary.href}>{secondary.label}</Link>
                  )}
                </Button>
              </div>
              <p className="mt-3 text-sm text-stone-500 dark:text-stone-500">
                Free plan available. No credit card required to start.
              </p>
            </AnimatedSection>
          </div>
        </section>

        <article className="py-12 md:py-16 bg-white dark:bg-stone-950">
          <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
            {content.sections.map((section, idx) => (
              <AnimatedSection key={section.heading} delay={idx * 30}>
                <h2 className="text-2xl font-semibold text-stone-900 dark:text-stone-50 mb-4">
                  {section.heading}
                </h2>
                {Array.isArray(section.body) ? (
                  section.body.map((p) => (
                    <p
                      key={p.slice(0, 40)}
                      className="text-stone-600 dark:text-stone-400 leading-relaxed mb-3"
                    >
                      {p}
                    </p>
                  ))
                ) : (
                  <p className="text-stone-600 dark:text-stone-400 leading-relaxed mb-3">
                    {section.body}
                  </p>
                )}
                {section.bullets && section.bullets.length > 0 && (
                  <ul className="mt-4 space-y-2.5">
                    {section.bullets.map((item) => (
                      <li key={item} className="flex gap-3 text-stone-700 dark:text-stone-300">
                        <Check className="w-5 h-5 text-indigo-600 dark:text-indigo-400 shrink-0 mt-0.5" />
                        <span>{item}</span>
                      </li>
                    ))}
                  </ul>
                )}
              </AnimatedSection>
            ))}

            {content.faqs.length > 0 && (
              <AnimatedSection>
                <h2 className="text-2xl font-semibold text-stone-900 dark:text-stone-50 mb-6">
                  Frequently asked questions
                </h2>
                <div className="space-y-5">
                  {content.faqs.map((faq) => (
                    <div
                      key={faq.question}
                      className="border-b border-stone-200 dark:border-stone-800 pb-5"
                    >
                      <h3 className="font-medium text-stone-900 dark:text-stone-50 mb-2">
                        {faq.question}
                      </h3>
                      <p className="text-stone-600 dark:text-stone-400 leading-relaxed">
                        {faq.answer}
                      </p>
                    </div>
                  ))}
                </div>
              </AnimatedSection>
            )}

            {content.relatedLinks && content.relatedLinks.length > 0 && (
              <AnimatedSection>
                <h2 className="text-xl font-semibold text-stone-900 dark:text-stone-50 mb-4">
                  Related
                </h2>
                <ul className="flex flex-wrap gap-3">
                  {content.relatedLinks.map((link) => (
                    <li key={link.href}>
                      <Link
                        to={link.href}
                        className={cn(
                          'inline-flex text-sm font-medium px-3 py-1.5 rounded-full',
                          'bg-stone-100 dark:bg-stone-900 text-indigo-700 dark:text-indigo-300',
                          'hover:bg-indigo-50 dark:hover:bg-indigo-950/50 transition-colors'
                        )}
                      >
                        {link.label}
                      </Link>
                    </li>
                  ))}
                </ul>
              </AnimatedSection>
            )}
          </div>
        </article>

        <section className="py-14 md:py-20 bg-indigo-600 text-white">
          <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <h2 className="landing-display text-2xl sm:text-3xl font-semibold leading-tight">
              Ready to try FitCheck AI?
            </h2>
            <p className="mt-3 text-indigo-100 max-w-xl mx-auto">
              Photograph a few pieces, build your digital closet, and see an outfit idea in minutes.
            </p>
            <div className="mt-8 flex flex-col sm:flex-row gap-3 justify-center">
              <Button
                size="lg"
                className="bg-white text-indigo-700 hover:bg-stone-100 h-12 px-6 shadow-none"
                asChild
              >
                <Link to="/auth/register">
                  Start free
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </Button>
              <Button
                size="lg"
                variant="outline"
                className="h-12 px-6 border-white/40 text-white hover:bg-white/10 hover:text-white"
                asChild
              >
                <Link to="/features">Explore features</Link>
              </Button>
            </div>
          </div>
        </section>
      </div>
    </>
  )
}

export default SeoPageLayout
