import { useState } from 'react'
import { Badge } from '@/components/ui/badge'
import { AnimatedSection } from './AnimatedSection'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'
import { ChevronDown } from 'lucide-react'
import { cn } from '@/lib/utils'

const faqs = [
  {
    question: 'How does the AI item extraction work?',
    answer:
      'Simply upload a photo of your clothes - individually or as a flat lay. Our AI uses advanced computer vision to identify each item, extract its colors, categorize it (tops, bottoms, shoes, etc.), and add relevant style tags automatically. The entire process takes just seconds.',
  },
  {
    question: 'Is my wardrobe data private and secure?',
    answer:
      'Absolutely. Your privacy is our top priority. All your wardrobe photos and data are encrypted both in transit and at rest. We never share or sell your data to third parties. You have full control over your data and can delete it at any time.',
  },
  {
    question: 'Can I use FitCheck AI on mobile?',
    answer:
      'Yes! FitCheck AI works seamlessly on all devices. You can access it through any modern web browser on your phone, tablet, or computer. We also offer native iOS and Android apps for the best mobile experience.',
  },
  {
    question: "What's the difference between Free and Pro?",
    answer:
      'The Free plan lets you manage up to 50 items and get 5 AI outfit generations per month - perfect for trying out the platform. Pro unlocks unlimited items, unlimited AI generations, virtual try-on visualization, advanced analytics, calendar integration, and priority support.',
  },
  {
    question: 'How do outfit recommendations work?',
    answer:
      'Our AI analyzes your wardrobe, style preferences, past outfit choices, and external factors like weather and calendar events. It then suggests complete outfits that match your personal style while ensuring variety and appropriateness for the occasion.',
  },
  {
    question: 'Can I cancel my subscription anytime?',
    answer:
      "Yes, you can cancel your subscription at any time with no questions asked. If you cancel, you'll continue to have access to Pro features until the end of your billing period. After that, your account will automatically switch to the Free plan.",
  },
]

function FAQItem({ question, answer }: { question: string; answer: string }) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <Collapsible open={isOpen} onOpenChange={setIsOpen}>
      <CollapsibleTrigger className="flex items-center justify-between w-full p-6 bg-white dark:bg-gray-800 rounded-lg text-left hover:bg-gray-50 dark:hover:bg-gray-750 transition-colors group">
        <span className="font-medium text-gray-900 dark:text-white pr-4">{question}</span>
        <ChevronDown
          className={cn(
            'w-5 h-5 text-gray-500 transition-transform shrink-0',
            isOpen && 'rotate-180'
          )}
        />
      </CollapsibleTrigger>
      <CollapsibleContent>
        <div className="px-6 pb-6 pt-2">
          <p className="text-gray-600 dark:text-gray-400">{answer}</p>
        </div>
      </CollapsibleContent>
    </Collapsible>
  )
}

export default function FAQ() {
  return (
    <section id="faq" className="py-24 bg-gray-50 dark:bg-gray-900">
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="text-center mb-16">
            <Badge className="mb-4 bg-indigo-100 text-indigo-700 dark:bg-indigo-900/50 dark:text-indigo-300 border-0">
              FAQ
            </Badge>
            <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-gray-900 dark:text-white">
              Frequently asked{' '}
              <span className="bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
                questions
              </span>
            </h2>
            <p className="mt-4 text-lg text-gray-600 dark:text-gray-300">
              Everything you need to know about FitCheck AI
            </p>
          </div>
        </AnimatedSection>

        <div className="space-y-4">
          {faqs.map((faq, index) => (
            <AnimatedSection key={index} delay={index * 100}>
              <FAQItem {...faq} />
            </AnimatedSection>
          ))}
        </div>
      </div>
    </section>
  )
}
