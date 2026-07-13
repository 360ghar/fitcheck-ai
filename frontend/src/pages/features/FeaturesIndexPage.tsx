import { Link } from 'react-router-dom'
import SEO from '@/components/seo/SEO'
import { BreadcrumbJsonLd } from '@/components/seo/JsonLd'
import { PAGE_SEO, SEO_CONFIG } from '@/components/seo/seo-config'
import { AnimatedSection } from '@/components/landing/AnimatedSection'
import { Button } from '@/components/ui/button'
import {
  ArrowRight,
  Camera,
  Shirt,
  Sparkles,
  Sun,
  BarChart3,
  User,
} from 'lucide-react'

const features = [
  {
    icon: Camera,
    title: 'AI Wardrobe Extraction',
    description:
      'Photograph clothes and let AI detect items, colors, and categories for a digital closet in minutes.',
    href: '/features/ai-wardrobe-extraction',
    keyword: 'AI wardrobe organizer',
  },
  {
    icon: User,
    title: 'Virtual Try-On',
    description:
      'See outfits on yourself with AI visualization before you leave the house or buy something new.',
    href: '/features/virtual-try-on',
    keyword: 'AI virtual try-on',
  },
  {
    icon: Sparkles,
    title: 'AI Photoshoot Generator',
    description:
      'Create LinkedIn, dating, and social-ready images from your selfies without a studio session.',
    href: '/features/ai-photoshoot-generator',
    keyword: 'AI photoshoot',
  },
  {
    icon: Sun,
    title: 'Outfit Recommendations',
    description:
      'Daily “what to wear” ideas from clothes you own, with weather and occasion context.',
    href: '/features/outfit-recommendations',
    keyword: 'AI outfit planner',
  },
  {
    icon: BarChart3,
    title: 'Wardrobe Analytics',
    description:
      'Cost-per-wear style insights and utilization so you buy less and wear more of what you own.',
    href: '/features/wardrobe-analytics',
    keyword: 'wardrobe analytics',
  },
]

export default function FeaturesIndexPage() {
  const breadcrumbs = [
    { name: 'Home', url: `${SEO_CONFIG.siteUrl}/` },
    { name: 'Features', url: `${SEO_CONFIG.siteUrl}/features` },
  ]

  return (
    <>
      <SEO
        title={PAGE_SEO.features.title}
        description={PAGE_SEO.features.description}
        canonicalUrl={`${SEO_CONFIG.siteUrl}/features`}
        keywords="AI wardrobe features, virtual try-on, outfit planner, digital closet app"
      />
      <BreadcrumbJsonLd items={breadcrumbs} />

      <div className="pt-20">
        <section className="py-14 md:py-20 bg-stone-50 dark:bg-stone-950 border-b border-stone-200 dark:border-stone-800">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <AnimatedSection>
              <div className="inline-flex items-center gap-2 text-sm text-indigo-600 dark:text-indigo-400 mb-4">
                <Shirt className="w-4 h-4" />
                Product features
              </div>
              <h1 className="landing-display text-3xl sm:text-4xl md:text-5xl font-semibold text-stone-900 dark:text-stone-50 leading-tight">
                Everything in your AI virtual closet
              </h1>
              <p className="mt-5 text-lg text-stone-600 dark:text-stone-400 max-w-2xl mx-auto leading-relaxed">
                {SEO_CONFIG.positioning} Explore each capability below — then start free with a few
                photos of clothes you already own.
              </p>
              <div className="mt-8 flex flex-col sm:flex-row gap-3 justify-center">
                <Button
                  size="lg"
                  className="bg-indigo-600 hover:bg-indigo-700 text-white h-12 px-6 shadow-none"
                  asChild
                >
                  <Link to="/auth/register">
                    Use free
                    <ArrowRight className="ml-2 h-4 w-4" />
                  </Link>
                </Button>
                <Button size="lg" variant="outline" className="h-12 px-6" asChild>
                  <Link to="/best/virtual-closet-apps">Compare virtual closet apps</Link>
                </Button>
              </div>
            </AnimatedSection>
          </div>
        </section>

        <section className="py-14 md:py-20 bg-white dark:bg-stone-950">
          <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid md:grid-cols-2 gap-6">
              {features.map((feature, i) => (
                <AnimatedSection key={feature.href} delay={i * 40}>
                  <Link
                    to={feature.href}
                    className="block h-full rounded-2xl border border-stone-200 dark:border-stone-800 p-6 hover:border-indigo-300 dark:hover:border-indigo-700 transition-colors bg-stone-50/50 dark:bg-stone-900/40"
                  >
                    <div className="w-10 h-10 rounded-lg bg-indigo-600/10 dark:bg-indigo-400/10 flex items-center justify-center mb-4">
                      <feature.icon className="w-5 h-5 text-indigo-600 dark:text-indigo-400" />
                    </div>
                    <h2 className="text-xl font-semibold text-stone-900 dark:text-stone-50">
                      {feature.title}
                    </h2>
                    <p className="mt-2 text-sm text-indigo-600/80 dark:text-indigo-400/80">
                      {feature.keyword}
                    </p>
                    <p className="mt-3 text-stone-600 dark:text-stone-400 leading-relaxed">
                      {feature.description}
                    </p>
                    <span className="mt-4 inline-flex items-center text-sm font-medium text-indigo-600 dark:text-indigo-400">
                      Learn more
                      <ArrowRight className="ml-1 w-4 h-4" />
                    </span>
                  </Link>
                </AnimatedSection>
              ))}
            </div>

            <div className="mt-14 rounded-2xl border border-stone-200 dark:border-stone-800 p-8 text-center">
              <h2 className="text-xl font-semibold text-stone-900 dark:text-stone-50">
                Guides & comparisons
              </h2>
              <p className="mt-2 text-stone-600 dark:text-stone-400 max-w-xl mx-auto">
                Researching the category? Start here before you commit a full wardrobe to any app.
              </p>
              <div className="mt-6 flex flex-wrap justify-center gap-3">
                <Button variant="outline" asChild>
                  <Link to="/guides/how-to-digitize-your-wardrobe">Digitize your wardrobe</Link>
                </Button>
                <Button variant="outline" asChild>
                  <Link to="/guides/what-to-wear-today">What to wear today</Link>
                </Button>
                <Button variant="outline" asChild>
                  <Link to="/compare/fitcheck-vs-acloset">FitCheck vs Acloset</Link>
                </Button>
                <Button variant="outline" asChild>
                  <Link to="/for/busy-professionals">For professionals</Link>
                </Button>
              </div>
            </div>
          </div>
        </section>
      </div>
    </>
  )
}
