import SEO from '@/components/seo/SEO'
import { Badge } from '@/components/ui/badge'
import { AnimatedSection } from '@/components/landing/AnimatedSection'
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible'
import { ChevronDown, Mail } from 'lucide-react'
import { Link } from 'react-router-dom'
import { cn } from '@/lib/utils'
import { useState } from 'react'
import { BreadcrumbJsonLd } from '@/components/seo/JsonLd'

const faqCategories = [
  {
    category: 'Getting Started',
    questions: [
      {
        q: 'How does FitCheck AI work?',
        a: 'FitCheck AI uses advanced computer vision and machine learning to help you organize your wardrobe and create outfits. Simply upload photos of your clothes, and our AI automatically catalogs them with details like color, category, and style. You can then create outfits, get AI-powered recommendations, and visualize looks with our virtual try-on feature.'
      },
      {
        q: 'Is FitCheck AI free to use?',
        a: 'Yes! FitCheck AI offers a free plan that includes up to 50 wardrobe items and 5 AI outfit generations per month. For unlimited items, unlimited AI generations, and premium features like virtual try-on and advanced analytics, you can upgrade to our Pro plan.'
      },
      {
        q: 'Do I need to download an app?',
        a: 'FitCheck AI works in any modern web browser on your phone, tablet, or computer. We also offer native iOS and Android apps for the best mobile experience with features like camera integration and push notifications.'
      },
      {
        q: 'What devices and browsers are supported?',
        a: 'FitCheck AI works on all modern browsers including Chrome, Safari, Firefox, and Edge. Our mobile apps support iOS 14+ and Android 8.0+. The web app is fully responsive and works on phones, tablets, and desktops.'
      }
    ]
  },
  {
    category: 'AI Features',
    questions: [
      {
        q: 'How accurate is the AI item extraction?',
        a: 'Our AI item extraction is highly accurate, correctly identifying clothing items, colors, and categories in over 95% of cases. The AI works best with clear, well-lit photos. You can always edit any details after extraction to ensure your wardrobe is perfectly cataloged.'
      },
      {
        q: 'What is the AI Photoshoot Generator?',
        a: 'The AI Photoshoot Generator creates professional-quality photos from your uploaded selfies. Choose from styles like LinkedIn professional, dating app photos, Instagram lifestyle, or model portfolio shots. Upload 1-4 reference photos, and our AI generates stunning images perfect for your needs.'
      },
      {
        q: 'How do outfit recommendations work?',
        a: 'Our AI analyzes your entire wardrobe, style preferences, past outfit choices, weather conditions, and even your calendar events to suggest perfect outfits. Recommendations consider color coordination, occasion appropriateness, weather suitability, and your personal style patterns.'
      },
      {
        q: 'What is virtual try-on?',
        a: 'Virtual try-on uses generative AI to visualize how outfit combinations would look when worn. Upload a photo of yourself or use your AI photoshoot avatar, and see realistic renderings of any outfit from your wardrobe before you wear it.'
      },
      {
        q: 'Can the AI extract multiple items from one photo?',
        a: 'Yes! Our advanced AI can detect and separate multiple clothing items from a single photograph. This makes cataloging your wardrobe much faster—you can lay out several items, take one photo, and the AI will identify each piece individually.'
      }
    ]
  },
  {
    category: 'Privacy & Security',
    questions: [
      {
        q: 'Is my wardrobe data private?',
        a: 'Absolutely. Your wardrobe data is private by default and encrypted both in transit and at rest. We never sell your data to third parties. Only you can see your wardrobe unless you explicitly choose to share specific outfits via public links.'
      },
      {
        q: 'What happens to my photos?',
        a: 'Your photos are stored securely in encrypted cloud storage. They are used solely to provide FitCheck AI services to you. You can delete your photos and account data at any time, and we will permanently remove all associated data within 30 days.'
      },
      {
        q: 'Can I export my data?',
        a: 'Yes! You can export your complete wardrobe data, including item details and photos, at any time. We provide exports in standard formats like CSV and JSON for easy portability.'
      },
      {
        q: 'Is my payment information secure?',
        a: 'We use Stripe, a PCI-compliant payment processor, to handle all payments. Your card details are never stored on our servers. All transactions are encrypted and secure.'
      }
    ]
  },
  {
    category: 'Account & Billing',
    questions: [
      {
        q: 'How do I upgrade to Pro?',
        a: 'You can upgrade to Pro from your account settings or by clicking "Upgrade" in the app. We accept all major credit cards and PayPal. Your subscription automatically renews monthly or annually depending on your chosen plan.'
      },
      {
        q: 'Can I cancel my subscription?',
        a: 'Yes, you can cancel your subscription at any time from your account settings. You will continue to have access to Pro features until the end of your current billing period, after which your account will revert to the free plan.'
      },
      {
        q: 'Do you offer refunds?',
        a: 'We offer a 14-day money-back guarantee for new Pro subscriptions. If you are not satisfied with FitCheck AI Pro, contact our support team within 14 days of your purchase for a full refund.'
      },
      {
        q: 'How does the referral program work?',
        a: 'When you refer friends to FitCheck AI, both you and your friend receive 1 month of Pro free when they sign up using your referral code. There is no limit to how many friends you can refer!'
      }
    ]
  }
]

// Generate FAQ schema
function generateFaqSchema() {
  const allQuestions = faqCategories.flatMap(cat =>
    cat.questions.map(q => ({
      '@type': 'Question',
      name: q.q,
      acceptedAnswer: {
        '@type': 'Answer',
        text: q.a
      }
    }))
  )

  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: allQuestions
  }
}

function FAQItem({ question, answer }: { question: string; answer: string }) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <Collapsible open={isOpen} onOpenChange={setIsOpen}>
      <CollapsibleTrigger className="flex items-center justify-between w-full p-6 bg-white dark:bg-gray-800 rounded-lg text-left hover:bg-gray-50 dark:hover:bg-gray-750 transition-colors group border border-gray-200 dark:border-gray-700">
        <span className="font-medium text-gray-900 dark:text-white pr-4">{question}</span>
        <ChevronDown
          className={cn(
            'w-5 h-5 text-gray-500 transition-transform shrink-0',
            isOpen && 'rotate-180'
          )}
        />
      </CollapsibleTrigger>
      <CollapsibleContent>
        <div className="px-6 pb-6 pt-2 bg-white dark:bg-gray-800 rounded-b-lg border-x border-b border-gray-200 dark:border-gray-700 -mt-2">
          <p className="text-gray-600 dark:text-gray-400">{answer}</p>
        </div>
      </CollapsibleContent>
    </Collapsible>
  )
}

export default function FAQPage() {
  const faqSchema = generateFaqSchema()
  const breadcrumbs = [
    { name: 'Home', url: 'https://fitcheckaiapp.com/' },
    { name: 'FAQ', url: 'https://fitcheckaiapp.com/faq' }
  ]

  return (
    <>
      <SEO
        title="Frequently Asked Questions | FitCheck AI"
        description="Find answers to common questions about FitCheck AI's wardrobe management, AI features, privacy, and billing. Get help with virtual try-on, outfit recommendations, and more."
        canonicalUrl="https://fitcheckaiapp.com/faq"
        jsonLd={faqSchema}
      />
      <BreadcrumbJsonLd items={breadcrumbs} />

      <div className="pt-20">
        <section className="py-16 md:py-24 bg-gradient-to-br from-indigo-50 via-white to-purple-50 dark:from-gray-950 dark:via-gray-900 dark:to-indigo-950">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center mb-16">
                <Badge className="mb-4 bg-indigo-100 text-indigo-700 dark:bg-indigo-900/50 dark:text-indigo-300 border-0">
                  FAQ
                </Badge>
                <h1 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-6">
                  Frequently Asked Questions
                </h1>
                <p className="text-lg text-gray-600 dark:text-gray-300">
                  Everything you need to know about FitCheck AI
                </p>
              </div>
            </AnimatedSection>

            <div className="space-y-12">
              {faqCategories.map((category, catIndex) => (
                <AnimatedSection key={category.category} delay={catIndex * 100}>
                  <div>
                    <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-6">
                      {category.category}
                    </h2>
                    <div className="space-y-4">
                      {category.questions.map((q, qIndex) => (
                        <FAQItem key={qIndex} question={q.q} answer={q.a} />
                      ))}
                    </div>
                  </div>
                </AnimatedSection>
              ))}
            </div>

            <AnimatedSection delay={400}>
              <div className="mt-16 text-center p-8 bg-indigo-50 dark:bg-indigo-900/20 rounded-2xl">
                <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
                  Still have questions?
                </h3>
                <p className="text-gray-600 dark:text-gray-300 mb-4">
                  Our support team is here to help you get the most out of FitCheck AI.
                </p>
                <a
                  href="mailto:support@fitcheckaiapp.com"
                  className="inline-flex items-center gap-2 text-indigo-600 dark:text-indigo-400 font-medium hover:underline"
                >
                  <Mail className="w-4 h-4" />
                  Contact Support
                </a>
              </div>
            </AnimatedSection>
          </div>
        </section>

        {/* CTA Section */}
        <section className="py-16 md:py-24 bg-gradient-to-br from-indigo-600 to-purple-600">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <AnimatedSection>
              <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
                Ready to transform your wardrobe?
              </h2>
              <p className="text-xl text-indigo-100 mb-8">
                Join thousands using AI to organize and optimize their style
              </p>
              <Link
                to="/auth/register"
                className="inline-flex items-center gap-2 bg-white text-indigo-600 px-8 py-4 rounded-full font-semibold text-lg hover:bg-gray-100 transition-colors"
              >
                Get Started Free
              </Link>
            </AnimatedSection>
          </div>
        </section>
      </div>
    </>
  )
}
