import { useState } from 'react'
import { AnimatedSection } from './AnimatedSection'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'
import { ChevronDown } from 'lucide-react'
import { cn } from '@/lib/utils'
import { freeVsProSummary, platformsSummary } from '@/lib/plan-limits'

/** Shared with LandingPage FAQ schema so visible copy and JSON-LD stay in sync. */
export const LANDING_FAQS = [
  {
    question: 'How does item extraction work?',
    answer:
      'Upload a photo of your clothes - individually or as a flat lay. FitCheck identifies each item, extracts colors, categorizes it (tops, bottoms, shoes, and more), and adds style tags. It usually finishes in seconds.',
  },
  {
    question: 'Is my wardrobe data private?',
    answer:
      'Yes. Photos and wardrobe data are encrypted in transit and at rest. We do not sell your data. You can delete your account and data at any time.',
  },
  {
    question: 'Can I use FitCheck on mobile?',
    answer: platformsSummary(),
  },
  {
    question: "What's free vs Pro?",
    answer: freeVsProSummary(),
  },
  {
    question: 'How do outfit recommendations work?',
    answer:
      'FitCheck looks at your wardrobe, preferences, and context like weather and calendar events, then suggests complete outfits that stay true to your style while keeping variety.',
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
          <p className="pb-5 text-stone-600 dark:text-stone-400 leading-relaxed pr-8">
            {answer}
          </p>
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
              Straight answers about privacy, plans, and how FitCheck works.
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
      </div>
    </section>
  )
}
