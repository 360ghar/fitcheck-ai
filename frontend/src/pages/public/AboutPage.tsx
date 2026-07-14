import { Link } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent } from '@/components/ui/card'
import { AnimatedSection } from '@/components/landing/AnimatedSection'
import SEO from '@/components/seo/SEO'
import { PAGE_SEO, SEO_CONFIG } from '@/components/seo/seo-config'
import { ArrowRight, Heart, Shield, Sparkles, Users } from 'lucide-react'

const values = [
  {
    icon: Sparkles,
    title: 'Innovation first',
    description:
      'We push AI and fashion tech so everyday dressing gets easier—not more complicated.',
  },
  {
    icon: Users,
    title: 'User-centric',
    description:
      'Every feature starts with real closet friction. Your feedback shapes the roadmap.',
  },
  {
    icon: Shield,
    title: 'Privacy matters',
    description:
      'Your wardrobe is personal. We do not sell your data and you control what you share.',
  },
  {
    icon: Heart,
    title: 'Sustainability',
    description:
      'Helping you wear what you own reduces waste and impulse buys that do not fit your life.',
  },
]

export default function AboutPage() {
  return (
    <>
      <SEO
        title={PAGE_SEO.about.title}
        description={PAGE_SEO.about.description}
        canonicalUrl={`${SEO_CONFIG.siteUrl}/about`}
        keywords="about FitCheck AI, AI wardrobe company, virtual closet app"
      />
      <div className="pt-16 landing-surface">
        <section className="py-20 md:py-28 bg-stone-50 dark:bg-stone-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center max-w-3xl mx-auto">
                <Badge className="mb-6 bg-indigo-50 text-indigo-700 dark:bg-indigo-950 dark:text-indigo-300 border-0">
                  About us
                </Badge>
                <h1 className="landing-display text-4xl sm:text-5xl font-semibold text-stone-900 dark:text-stone-50 mb-6">
                  Making everyday outfits effortless
                </h1>
                <p className="text-lg text-stone-600 dark:text-stone-400 leading-relaxed">
                  We believe everyone deserves to feel confident in what they wear. FitCheck AI
                  helps you digitize the closet you already own and get AI outfit ideas that fit
                  the day.
                </p>
              </div>
            </AnimatedSection>
          </div>
        </section>

        <section className="py-20 bg-white dark:bg-stone-900">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="grid lg:grid-cols-2 gap-12 items-center">
              <AnimatedSection>
                <Badge className="mb-4 bg-indigo-50 text-indigo-700 dark:bg-indigo-950 dark:text-indigo-300 border-0">
                  Our story
                </Badge>
                <h2 className="landing-display text-3xl font-semibold text-stone-900 dark:text-stone-50 mb-6">
                  Born from a simple frustration
                </h2>
                <div className="space-y-4 text-stone-600 dark:text-stone-400">
                  <p>
                    Like many people, our founders stood in front of full closets every morning and
                    still felt like they had nothing to wear—cycling through the same few outfits.
                  </p>
                  <p>
                    FitCheck AI started as a question: what if AI could help you see and use what you
                    already own? Photograph clothes once, get outfits for weather, occasions, and
                    try-on previews when you need them.
                  </p>
                </div>
              </AnimatedSection>
              <AnimatedSection delay={100}>
                <div className="landing-panel p-8 md:p-10">
                  <h3 className="text-lg font-semibold text-stone-900 dark:text-stone-50 mb-4">
                    What we build for
                  </h3>
                  <ul className="space-y-3 text-stone-600 dark:text-stone-400 text-sm">
                    <li>· Busy people who want a faster morning decision</li>
                    <li>· Creators and professionals who need reliable looks</li>
                    <li>· Anyone trying to buy less and wear more of what fits</li>
                  </ul>
                </div>
              </AnimatedSection>
            </div>
          </div>
        </section>

        <section className="py-20 bg-stone-50 dark:bg-stone-950">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center mb-12">
                <h2 className="landing-display text-3xl font-semibold text-stone-900 dark:text-stone-50">
                  What we value
                </h2>
              </div>
            </AnimatedSection>
            <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
              {values.map((value, i) => (
                <AnimatedSection key={value.title} delay={i * 80}>
                  <Card className="h-full border-stone-200 dark:border-stone-800 bg-white dark:bg-stone-900 shadow-none">
                    <CardContent className="p-6">
                      <div className="w-11 h-11 rounded-xl bg-indigo-600 flex items-center justify-center mb-4">
                        <value.icon className="w-5 h-5 text-white" />
                      </div>
                      <h3 className="font-semibold text-stone-900 dark:text-stone-50 mb-2">
                        {value.title}
                      </h3>
                      <p className="text-sm text-stone-600 dark:text-stone-400 leading-relaxed">
                        {value.description}
                      </p>
                    </CardContent>
                  </Card>
                </AnimatedSection>
              ))}
            </div>
          </div>
        </section>

        <section className="py-20 bg-stone-900 text-stone-50">
          <div className="max-w-3xl mx-auto px-4 text-center">
            <h2 className="landing-display text-3xl font-semibold mb-4">Start free today</h2>
            <p className="text-stone-400 mb-8">
              Create an account on the web or get the Android app on Google Play.
            </p>
            <Button asChild size="lg" className="bg-indigo-600 hover:bg-indigo-700 text-white shadow-none">
              <Link to="/auth/register">
                Start free
                <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
          </div>
        </section>
      </div>
    </>
  )
}
