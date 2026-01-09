import Hero from '@/components/landing/Hero'
import DemoSection from '@/components/landing/DemoSection'
import Features from '@/components/landing/Features'
import HowItWorks from '@/components/landing/HowItWorks'
import Testimonials from '@/components/landing/Testimonials'
import Pricing from '@/components/landing/Pricing'
import FAQ from '@/components/landing/FAQ'
import CTASection from '@/components/landing/CTASection'

export default function LandingPage() {
  return (
    <>
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
