import Hero from '@/components/landing/Hero'
import DemoSection from '@/components/landing/DemoSection'
import Features from '@/components/landing/Features'
import AlsoInApp from '@/components/landing/AlsoInApp'
import HowItWorks from '@/components/landing/HowItWorks'
import WhoItsFor from '@/components/landing/WhoItsFor'
import Testimonials from '@/components/landing/Testimonials'
import GuidesStrip from '@/components/landing/GuidesStrip'
import Pricing from '@/components/landing/Pricing'
import FAQ, { LANDING_FAQS } from '@/components/landing/FAQ'
import CTASection from '@/components/landing/CTASection'
import SEO from '@/components/seo/SEO'
import { PAGE_SEO, SEO_CONFIG } from '@/components/seo/seo-config'
import { buildFaqSchema, buildHowToSchema, buildFeatureItemListSchema } from '@/components/seo/JsonLd'

const HOW_TO_STEPS = [
  {
    name: 'Photograph',
    text: 'Snap singles or full hangs of clothes you own. FitCheck reads each image and prepares items for cataloging.',
    url: `${SEO_CONFIG.siteUrl}/#step-photograph`,
  },
  {
    name: 'Catalog',
    text: 'AI tags colors, categories, and styles so your closet becomes searchable without manual data entry.',
    url: `${SEO_CONFIG.siteUrl}/#step-catalog`,
  },
  {
    name: 'Wear',
    text: 'Get recommendations, try looks on, plan the week, and generate photoshoot-style images from your wardrobe.',
    url: `${SEO_CONFIG.siteUrl}/#step-wear`,
  },
]

const FEATURE_LIST = [
  {
    name: 'AI wardrobe extraction',
    url: `${SEO_CONFIG.siteUrl}/features/ai-wardrobe-extraction`,
    description: 'Digitize clothes from photos with automatic color, category, and style tags.',
  },
  {
    name: 'Virtual try-on',
    url: `${SEO_CONFIG.siteUrl}/features/virtual-try-on`,
    description: 'Preview outfits on you before you wear them.',
  },
  {
    name: 'AI outfit recommendations',
    url: `${SEO_CONFIG.siteUrl}/features/outfit-recommendations`,
    description: 'Daily, weather-aware outfit ideas from clothes you own.',
  },
  {
    name: 'AI photoshoot generator',
    url: `${SEO_CONFIG.siteUrl}/features/ai-photoshoot-generator`,
    description: 'LinkedIn, dating, and social photos from a phone selfie.',
  },
  {
    name: 'Wardrobe analytics',
    url: `${SEO_CONFIG.siteUrl}/features/wardrobe-analytics`,
    description: 'Cost-per-wear and utilization insights for smarter buying.',
  },
]

export default function LandingPage() {
  const faqSchema = buildFaqSchema(LANDING_FAQS)
  const howToSchema = buildHowToSchema({
    name: 'How to use FitCheck AI as a virtual closet',
    description:
      'Photograph your clothes, catalog them with AI, and wear better outfits every day with FitCheck AI.',
    steps: HOW_TO_STEPS,
  })
  const featureListSchema = buildFeatureItemListSchema(FEATURE_LIST)

  return (
    <>
      <SEO
        title={PAGE_SEO.landing.title}
        description={PAGE_SEO.landing.description}
        canonicalUrl={`${SEO_CONFIG.siteUrl}/`}
        keywords="virtual closet app, AI wardrobe organizer, AI outfit planner, digital wardrobe, virtual try-on, AI fashion, AI photoshoot, cost per wear"
        jsonLd={[faqSchema, howToSchema, featureListSchema]}
      />
      <Hero />
      <DemoSection />
      <Features />
      <AlsoInApp />
      <HowItWorks />
      <WhoItsFor />
      <Testimonials />
      <GuidesStrip />
      <Pricing />
      <FAQ />
      <CTASection />
    </>
  )
}
