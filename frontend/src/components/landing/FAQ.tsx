import { useState } from 'react'
import { Link } from 'react-router-dom'
import { AnimatedSection } from './AnimatedSection'
import { SectionKicker } from './SectionKicker'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'
import { ChevronDown } from 'lucide-react'
import { cn } from '@/lib/utils'
import { freeVsProSummary, platformsSummary, PLAN_LIMITS } from '@/lib/plan-limits'

/** Shared with LandingPage FAQ schema so visible copy and JSON-LD stay in sync. */
export const LANDING_FAQS = [
  {
    question: 'What is FitCheck AI?',
    answer:
      'FitCheck AI is an AI virtual closet and outfit planner. Photograph your clothes to build a digital wardrobe, then get weather-aware outfit ideas, virtual try-on, AI photoshoots, and wardrobe analytics from the clothes you already own — on web and Android, with iOS on the waitlist.',
  },
  {
    question: 'What is a virtual closet app?',
    answer:
      'A virtual closet app digitizes your real clothes so you can browse, mix, and plan outfits without digging through a physical wardrobe. FitCheck goes further with AI item extraction from photos, generative try-on and photoshoots, and daily recommendations grounded in your inventory.',
  },
  {
    question: 'How does AI wardrobe extraction work?',
    answer:
      'Upload a photo of your clothes — individually or as a flat lay or hang. FitCheck identifies each item, extracts colors, categorizes it (tops, bottoms, shoes, and more), and adds style tags. Review the extracted details before saving. Multi-item photos and batch uploads are supported in the app.',
  },
  {
    question: 'Is FitCheck AI free?',
    answer: freeVsProSummary(),
  },
  {
    question: 'How does the first month of Pro free work?',
    answer:
      'Every new account can claim its first month of Pro free — no credit card required. Sign up through the offer link (or enter the code at signup) and Pro is applied to your account. After the free month, the account returns to the Free plan unless you choose to upgrade, so nothing is charged automatically.',
  },
  {
    question: 'How is FitCheck different from Acloset or Whering?',
    answer:
      'FitCheck focuses on photo-to-wardrobe AI extraction, generative virtual try-on, AI photoshoot generation, weather-aware recommendations, and cost-per-wear analytics in one product. Side-by-side comparisons: https://fitcheckaiapp.com/compare/fitcheck-vs-acloset and https://fitcheckaiapp.com/compare/fitcheck-vs-whering. Also see https://fitcheckaiapp.com/best/virtual-closet-apps.',
  },
  {
    question: 'Does virtual try-on use my real clothes?',
    answer:
      'Yes. Try-on is built around pieces in your wardrobe or photos you provide, so you visualize combinations of clothes you actually own — not only brand catalog garments. Limits apply on Free and Pro based on monthly AI generations.',
  },
  {
    question: 'What can I use the AI photoshoot for?',
    answer: `Create professional-looking images from selfies for LinkedIn, dating apps, Instagram, portfolios, or a custom prompt. Free includes ${PLAN_LIMITS.free.dailyPhotoshootImages} photoshoot images per day; Pro raises that to ${PLAN_LIMITS.pro.dailyPhotoshootImages}. A short unauthenticated demo is available on the homepage.`,
  },
  {
    question: 'Who is FitCheck for?',
    answer:
      'Busy professionals who want faster mornings, content creators planning looks, festive and wedding guests digitizing occasion wear, and anyone with a full closet who still feels stuck. More at https://fitcheckaiapp.com/for/busy-professionals, https://fitcheckaiapp.com/for/content-creators, and https://fitcheckaiapp.com/for/festive-and-wedding-outfits.',
  },
  {
    question: 'Is my wardrobe data private?',
    answer:
      'Yes. Photos and wardrobe data are encrypted in transit and at rest. We do not sell your data. You can delete your account and data at any time. Full details: https://fitcheckaiapp.com/privacy.',
  },
  {
    question: 'Can I use FitCheck on mobile?',
    answer: platformsSummary(),
  },
  {
    question: 'Do you have a referral program?',
    answer:
      'Yes. Share your referral link from the app. When a friend joins, you both get one month of Pro. Details appear in your dashboard after you sign up.',
  },
  {
    question: 'Can I cancel anytime?',
    answer:
      'Yes. Cancel whenever you want. Pro access continues through the end of the billing period, then the account returns to Free.',
  },
]

const faqs = LANDING_FAQS

function FAQItem({ question, answer }: { question: string; answer: string }) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <Collapsible open={isOpen} onOpenChange={setIsOpen}>
      <div className="border-b border-border">
        <CollapsibleTrigger className="group flex min-h-14 w-full items-center justify-between py-5 text-left focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2">
          <span className="pr-4 text-[15px] font-medium text-foreground md:text-base">
            {question}
          </span>
          <ChevronDown
            className={cn(
              'h-5 w-5 shrink-0 text-muted-foreground transition-transform',
              isOpen && 'rotate-180 text-primary'
            )}
          />
        </CollapsibleTrigger>
        {/* Height animation rides on Radix's --radix-collapsible-content-height
            var via the accordion-down/up keyframes in tailwind.config.ts. */}
        <CollapsibleContent className="overflow-hidden data-[state=open]:animate-accordion-down data-[state=closed]:animate-accordion-up">
          <div className="space-y-2 pb-5 pr-8 leading-relaxed text-body [overflow-wrap:anywhere]">
            <p>{answer}</p>
            {question.includes('Acloset') && (
              <p className="text-sm">
                <Link
                  to="/compare/fitcheck-vs-acloset"
                  className="text-primary hover:text-primary-pressed"
                >
                  FitCheck vs Acloset
                </Link>
                {' · '}
                <Link
                  to="/compare/fitcheck-vs-whering"
                  className="text-primary hover:text-primary-pressed"
                >
                  FitCheck vs Whering
                </Link>
                {' · '}
                <Link
                  to="/best/virtual-closet-apps"
                  className="text-primary hover:text-primary-pressed"
                >
                  Best virtual closet apps
                </Link>
              </p>
            )}
            {question.includes('Who is FitCheck') && (
              <p className="text-sm">
                <Link
                  to="/for/busy-professionals"
                  className="text-primary hover:text-primary-pressed"
                >
                  Professionals
                </Link>
                {' · '}
                <Link
                  to="/for/content-creators"
                  className="text-primary hover:text-primary-pressed"
                >
                  Creators
                </Link>
                {' · '}
                <Link
                  to="/for/festive-and-wedding-outfits"
                  className="text-primary hover:text-primary-pressed"
                >
                  Festive & wedding
                </Link>
              </p>
            )}
            {question.includes('private') && (
              <p className="text-sm">
                <Link
                  to="/privacy"
                  className="text-primary hover:text-primary-pressed"
                >
                  Privacy Policy
                </Link>
              </p>
            )}
          </div>
        </CollapsibleContent>
      </div>
    </Collapsible>
  )
}

export default function FAQ() {
  return (
    <section id="faq" className="scroll-mt-16 bg-background py-20 md:py-28">
      <div className="mx-auto grid max-w-7xl grid-cols-1 gap-12 px-4 sm:px-6 lg:grid-cols-12 lg:gap-16 lg:px-8">
        <AnimatedSection className="reveal min-w-0 lg:col-span-4">
          <div className="lg:sticky lg:top-24">
            <SectionKicker tone="amber">FAQ</SectionKicker>
            <h2 className="landing-display text-3xl font-semibold leading-tight text-foreground sm:text-4xl">
              Clear answers before you upload
            </h2>
            <p className="mt-4 text-body">
              Product, privacy, billing, and platform details in one place.
            </p>
            <p className="mt-6 text-sm text-muted-foreground">
              Need more detail?{' '}
              <Link to="/faq" className="text-primary hover:text-primary-pressed">
                Open the full FAQ
              </Link>
            </p>
          </div>
        </AnimatedSection>

        <div className="min-w-0 border-t border-border lg:col-span-8">
          {faqs.map((faq, index) => (
            <AnimatedSection key={faq.question} delay={index * 40}>
              <FAQItem {...faq} />
            </AnimatedSection>
          ))}
        </div>
      </div>
    </section>
  )
}
