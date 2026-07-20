import { useState } from 'react'
import { Link } from 'react-router-dom'
import { AnimatedSection } from './AnimatedSection'
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
      'Upload a photo of your clothes — individually or as a flat lay or hang. FitCheck identifies each item, extracts colors, categorizes it (tops, bottoms, shoes, and more), and adds style tags. It usually finishes in seconds. Multi-item photos and batch uploads are supported in the app.',
  },
  {
    question: 'Is FitCheck AI free?',
    answer: freeVsProSummary(),
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
      <div className="border-b border-stone-200 dark:border-stone-800">
        <CollapsibleTrigger className="flex items-center justify-between w-full py-5 text-left group">
          <span className="font-medium text-stone-900 dark:text-stone-50 pr-4 text-[15px] md:text-base">
            {question}
          </span>
          <ChevronDown
            className={cn(
              'w-5 h-5 text-stone-400 transition-transform shrink-0',
              isOpen && 'rotate-180 text-indigo-600 dark:text-indigo-400'
            )}
          />
        </CollapsibleTrigger>
        <CollapsibleContent>
          <div className="pb-5 text-stone-600 dark:text-stone-400 leading-relaxed pr-8 space-y-2">
            <p>{answer}</p>
            {question.includes('Acloset') && (
              <p className="text-sm">
                <Link
                  to="/compare/fitcheck-vs-acloset"
                  className="text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300"
                >
                  FitCheck vs Acloset
                </Link>
                {' · '}
                <Link
                  to="/compare/fitcheck-vs-whering"
                  className="text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300"
                >
                  FitCheck vs Whering
                </Link>
                {' · '}
                <Link
                  to="/best/virtual-closet-apps"
                  className="text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300"
                >
                  Best virtual closet apps
                </Link>
              </p>
            )}
            {question.includes('Who is FitCheck') && (
              <p className="text-sm">
                <Link
                  to="/for/busy-professionals"
                  className="text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300"
                >
                  Professionals
                </Link>
                {' · '}
                <Link
                  to="/for/content-creators"
                  className="text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300"
                >
                  Creators
                </Link>
                {' · '}
                <Link
                  to="/for/festive-and-wedding-outfits"
                  className="text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300"
                >
                  Festive & wedding
                </Link>
              </p>
            )}
            {question.includes('private') && (
              <p className="text-sm">
                <Link
                  to="/privacy"
                  className="text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300"
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
    <section id="faq" className="py-20 md:py-28 bg-white dark:bg-stone-950">
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="mb-10 md:mb-12">
            <h2 className="landing-display text-3xl sm:text-4xl font-semibold text-stone-900 dark:text-stone-50 leading-tight">
              Questions
            </h2>
            <p className="mt-3 text-stone-600 dark:text-stone-400">
              Straight answers about what FitCheck is, how it works, privacy, and plans.
            </p>
          </div>
        </AnimatedSection>

        <div>
          {faqs.map((faq, index) => (
            <AnimatedSection key={faq.question} delay={index * 40}>
              <FAQItem {...faq} />
            </AnimatedSection>
          ))}
        </div>

        <AnimatedSection delay={120}>
          <p className="mt-8 text-sm text-stone-500 dark:text-stone-400">
            Need more detail?{' '}
            <Link
              to="/faq"
              className="text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300"
            >
              Full FAQ
            </Link>
          </p>
        </AnimatedSection>
      </div>
    </section>
  )
}
