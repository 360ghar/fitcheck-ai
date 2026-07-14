import Hero from '@/components/landing/Hero'
import DemoSection from '@/components/landing/DemoSection'
import Features from '@/components/landing/Features'
import HowItWorks from '@/components/landing/HowItWorks'
import Testimonials from '@/components/landing/Testimonials'
import Pricing from '@/components/landing/Pricing'
import FAQ, { LANDING_FAQS } from '@/components/landing/FAQ'
import CTASection from '@/components/landing/CTASection'
import SEO from '@/components/seo/SEO'
import { PAGE_SEO, SEO_CONFIG } from '@/components/seo/seo-config'
import { buildFaqSchema } from '@/components/seo/JsonLd'

export default function LandingPage() {
  const faqSchema = buildFaqSchema(LANDING_FAQS)

  return (
    <>
      <SEO
        title={PAGE_SEO.landing.title}
        description={PAGE_SEO.landing.description}
        canonicalUrl={`${SEO_CONFIG.siteUrl}/`}
        keywords="virtual closet app, AI wardrobe organizer, AI outfit planner, digital wardrobe, virtual try-on, AI fashion"
        jsonLd={faqSchema}
      />
      <Hero />
      <DemoSection />
      <Features />
      <HowItWorks />
      <Testimonials />
      <Pricing />
      <FAQ />
      <CTASection />
    </>
  )
}
