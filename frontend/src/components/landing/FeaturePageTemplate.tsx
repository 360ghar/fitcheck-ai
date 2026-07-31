import { Link } from 'react-router-dom'
import type { LucideIcon } from 'lucide-react'
import { ArrowRight, Check, Sparkles } from 'lucide-react'
import SEO from '@/components/seo/SEO'
import { BreadcrumbJsonLd, buildHowToSchema } from '@/components/seo/JsonLd'
import { SEO_CONFIG } from '@/components/seo/seo-config'
import { Button } from '@/components/ui/button'
import { AnimatedSection } from './AnimatedSection'

export interface FeaturePageItem {
  icon: LucideIcon
  title: string
  description: string
}

export interface FeaturePageStep {
  title: string
  description: string
}

export interface RelatedFeature {
  title: string
  description: string
  href: string
}

export interface FeaturePageTemplateProps {
  title: string
  description: string
  canonicalPath: string
  keywords: string
  eyebrow: string
  heroImage: string
  heroImageAlt: string
  preparationTitle: string
  preparation: string[]
  features: FeaturePageItem[]
  steps: FeaturePageStep[]
  contextTitle: string
  contextDescription: string
  contextItems: string[]
  relatedFeatures: RelatedFeature[]
}

/**
 * Shared public feature-page structure. It keeps the five capability pages
 * comparable and avoids publishing performance or accuracy assertions unless
 * product has supplied approved evidence for them.
 */
export function FeaturePageTemplate({
  title,
  description,
  canonicalPath,
  keywords,
  eyebrow,
  heroImage,
  heroImageAlt,
  preparationTitle,
  preparation,
  features,
  steps,
  contextTitle,
  contextDescription,
  contextItems,
  relatedFeatures,
}: FeaturePageTemplateProps) {
  const breadcrumbs = [
    { name: 'Home', url: `${SEO_CONFIG.siteUrl}/` },
    { name: 'Features', url: `${SEO_CONFIG.siteUrl}/features` },
    { name: title, url: `${SEO_CONFIG.siteUrl}${canonicalPath}` },
  ]
  const howToSchema = buildHowToSchema({
    name: `${title}: how it works`,
    description,
    steps: steps.map((step) => ({ name: step.title, text: step.description })),
  })

  return (
    <>
      <SEO
        title={`${title} | FitCheck AI`}
        description={description}
        canonicalUrl={`${SEO_CONFIG.siteUrl}${canonicalPath}`}
        keywords={keywords}
        jsonLd={howToSchema}
      />
      <BreadcrumbJsonLd items={breadcrumbs} />

      <div className="pt-16 landing-surface">
        <section className="border-b border-stone-200 bg-stone-50 py-14 dark:border-stone-800 dark:bg-stone-950 md:py-20">
          <div className="mx-auto grid max-w-7xl gap-10 px-4 sm:px-6 lg:grid-cols-[1fr_0.9fr] lg:items-center lg:px-8">
            <AnimatedSection>
              <p className="mb-4 flex items-center gap-2 text-sm font-semibold text-primary">
                <Sparkles className="h-4 w-4" aria-hidden />
                {eyebrow}
              </p>
              <h1 className="landing-display max-w-3xl text-3xl font-semibold leading-tight text-stone-900 dark:text-stone-50 sm:text-4xl md:text-5xl">
                {title}
              </h1>
              <p className="mt-5 max-w-2xl text-base leading-relaxed text-stone-600 dark:text-stone-400 md:text-lg">
                {description}
              </p>
              <div className="mt-8 flex flex-col gap-3 sm:flex-row">
                <Button asChild size="lg" className="h-12 px-6">
                  <Link to="/auth/register">
                    Start free
                    <ArrowRight className="ml-2 h-4 w-4" />
                  </Link>
                </Button>
                <Button asChild size="lg" variant="outline" className="h-12 px-6">
                  <Link to="/features">Explore all features</Link>
                </Button>
              </div>
            </AnimatedSection>

            <AnimatedSection>
              <figure className="overflow-hidden rounded-2xl border border-stone-200 bg-white dark:border-stone-800 dark:bg-stone-900">
                <img
                  src={heroImage}
                  alt={heroImageAlt}
                  className="aspect-[4/3] h-full w-full object-cover"
                  loading="eager"
                  decoding="async"
                />
              </figure>
            </AnimatedSection>
          </div>
        </section>

        <section className="bg-white py-12 dark:bg-stone-950 md:py-16">
          <div className="mx-auto grid max-w-7xl gap-px overflow-hidden rounded-2xl border border-stone-200 bg-stone-200 dark:border-stone-800 dark:bg-stone-800 md:grid-cols-3">
            {[
              ['Your inputs stay in context', 'Use your photos, wardrobe, and choices to guide the flow.'],
              ['Review before the next step', 'Keep control of what is saved, shared, or retried.'],
              ['Clear status while work runs', 'Queued, processing, completed, and failed states stay explicit.'],
            ].map(([heading, detail]) => (
              <div key={heading} className="bg-white p-6 dark:bg-stone-950">
                <h2 className="text-base font-semibold text-stone-900 dark:text-stone-50">{heading}</h2>
                <p className="mt-2 text-sm leading-relaxed text-stone-600 dark:text-stone-400">{detail}</p>
              </div>
            ))}
          </div>
        </section>

        <section className="bg-stone-50 py-16 dark:bg-stone-900/40 md:py-20">
          <div className="mx-auto grid max-w-7xl gap-10 px-4 sm:px-6 lg:grid-cols-[0.8fr_1.2fr] lg:px-8">
            <div>
              <h2 className="landing-display text-3xl font-semibold text-stone-900 dark:text-stone-50">
                {preparationTitle}
              </h2>
              <p className="mt-3 text-stone-600 dark:text-stone-400">
                A focused start produces more useful results and makes review easier.
              </p>
              <ul className="mt-6 space-y-3">
                {preparation.map((item) => (
                  <li key={item} className="flex gap-3 text-sm leading-relaxed text-stone-700 dark:text-stone-300">
                    <Check className="mt-0.5 h-4 w-4 shrink-0 text-primary" aria-hidden />
                    {item}
                  </li>
                ))}
              </ul>
            </div>
            <div className="grid gap-4 sm:grid-cols-2">
              {features.map((feature) => {
                const Icon = feature.icon
                return (
                  <article key={feature.title} className="rounded-2xl border border-stone-200 bg-white p-6 dark:border-stone-800 dark:bg-stone-950">
                    <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-secondary text-primary">
                      <Icon className="h-5 w-5" aria-hidden />
                    </div>
                    <h3 className="mt-5 text-lg font-semibold text-stone-900 dark:text-stone-50">{feature.title}</h3>
                    <p className="mt-2 text-sm leading-relaxed text-stone-600 dark:text-stone-400">{feature.description}</p>
                  </article>
                )
              })}
            </div>
          </div>
        </section>

        <section className="bg-white py-16 dark:bg-stone-950 md:py-20">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="max-w-2xl">
              <h2 className="landing-display text-3xl font-semibold text-stone-900 dark:text-stone-50">How it works</h2>
              <p className="mt-3 text-stone-600 dark:text-stone-400">A deliberate flow from input to a next useful action.</p>
            </div>
            <ol className="mt-10 grid overflow-hidden rounded-2xl border border-stone-200 dark:border-stone-800 md:grid-cols-4">
              {steps.map((step, index) => (
                <li key={step.title} className="border-b border-stone-200 p-6 last:border-b-0 dark:border-stone-800 md:border-b-0 md:border-r md:last:border-r-0">
                  <p className="text-xs font-semibold tracking-[0.14em] text-primary">0{index + 1}</p>
                  <h3 className="mt-4 text-lg font-semibold text-stone-900 dark:text-stone-50">{step.title}</h3>
                  <p className="mt-2 text-sm leading-relaxed text-stone-600 dark:text-stone-400">{step.description}</p>
                </li>
              ))}
            </ol>
          </div>
        </section>

        <section className="bg-stone-50 py-16 dark:bg-stone-900/40 md:py-20">
          <div className="mx-auto grid max-w-7xl gap-8 px-4 sm:px-6 lg:grid-cols-2 lg:px-8">
            <div className="rounded-2xl border border-stone-200 bg-white p-7 dark:border-stone-800 dark:bg-stone-950 md:p-9">
              <p className="text-sm font-semibold text-primary">In context</p>
              <h2 className="landing-display mt-3 text-3xl font-semibold text-stone-900 dark:text-stone-50">{contextTitle}</h2>
              <p className="mt-4 leading-relaxed text-stone-600 dark:text-stone-400">{contextDescription}</p>
              <ul className="mt-6 space-y-3 text-sm text-stone-700 dark:text-stone-300">
                {contextItems.map((item) => <li key={item}>• {item}</li>)}
              </ul>
            </div>
            <div className="rounded-2xl border border-stone-200 bg-stone-900 p-7 text-stone-50 dark:border-stone-800 md:p-9">
              <h2 className="landing-display text-3xl font-semibold">Make the next choice easier</h2>
              <p className="mt-4 leading-relaxed text-stone-300">Create an account to use this capability with your wardrobe. You can keep working while supported tasks run and return to clear results or recovery actions.</p>
              <Button asChild size="lg" className="mt-7 h-12 bg-white px-6 text-stone-900 hover:bg-stone-100">
                <Link to="/auth/register">Create your free account <ArrowRight className="ml-2 h-4 w-4" /></Link>
              </Button>
            </div>
          </div>
        </section>

        <section className="bg-white py-16 dark:bg-stone-950 md:py-20">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <h2 className="landing-display text-3xl font-semibold text-stone-900 dark:text-stone-50">Continue building your wardrobe system</h2>
            <div className="mt-8 grid gap-4 md:grid-cols-3">
              {relatedFeatures.map((feature) => (
                <Link key={feature.href} to={feature.href} className="group rounded-2xl border border-stone-200 p-6 transition-colors hover:border-primary/40 dark:border-stone-800">
                  <h3 className="text-lg font-semibold text-stone-900 dark:text-stone-50">{feature.title}</h3>
                  <p className="mt-2 text-sm leading-relaxed text-stone-600 dark:text-stone-400">{feature.description}</p>
                  <span className="mt-5 inline-flex min-h-11 items-center text-sm font-semibold text-primary group-hover:text-primary-pressed">Explore <ArrowRight className="ml-1 h-4 w-4" /></span>
                </Link>
              ))}
            </div>
          </div>
        </section>
      </div>
    </>
  )
}
