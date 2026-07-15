import { AnimatedSection } from '@/components/landing/AnimatedSection'
import SEO from '@/components/seo/SEO'
import { PAGE_SEO, SEO_CONFIG } from '@/components/seo/seo-config'
import { Link } from 'react-router-dom'
import { Flag, HelpCircle, Mail, Shield } from 'lucide-react'

export default function SupportPage() {
  return (
    <>
      <SEO
        title={PAGE_SEO.support.title}
        description={PAGE_SEO.support.description}
        canonicalUrl={`${SEO_CONFIG.siteUrl}/support`}
      />
      <div className="pt-20">
        <section className="py-24 bg-stone-50 dark:bg-stone-950">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
            <AnimatedSection>
              <div className="text-center mb-12">
                <h1 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
                  Support
                </h1>
                <p className="text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
                  Get help with FitCheck AI, report a problem, or contact us about
                  privacy and account requests.
                </p>
              </div>
            </AnimatedSection>
          </div>
        </section>

        <section className="py-16 bg-white dark:bg-gray-950">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
            <AnimatedSection>
              <div className="grid gap-6 md:grid-cols-2">
                <a
                  href="mailto:support@fitcheckaiapp.com"
                  className="rounded-2xl border border-gray-200 dark:border-gray-800 p-6 hover:border-indigo-400 dark:hover:border-indigo-500 transition-colors"
                >
                  <Mail className="h-8 w-8 text-indigo-600 mb-4" />
                  <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                    Email support
                  </h2>
                  <p className="text-gray-600 dark:text-gray-300 mb-3">
                    Product questions, account help, and technical issues.
                  </p>
                  <p className="font-medium text-indigo-600">
                    support@fitcheckaiapp.com
                  </p>
                </a>

                <a
                  href="mailto:support@fitcheckaiapp.com?subject=Content%20report%20%2F%20abuse"
                  className="rounded-2xl border border-gray-200 dark:border-gray-800 p-6 hover:border-indigo-400 dark:hover:border-indigo-500 transition-colors"
                >
                  <Flag className="h-8 w-8 text-indigo-600 mb-4" />
                  <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                    Report content or abuse
                  </h2>
                  <p className="text-gray-600 dark:text-gray-300 mb-3">
                    Report objectionable shared outfits or other content. We aim
                    to review reports within 24 hours.
                  </p>
                  <p className="font-medium text-indigo-600">
                    Email with subject &quot;Content report / abuse&quot;
                  </p>
                </a>

                <a
                  href="mailto:privacy@fitcheckaiapp.com"
                  className="rounded-2xl border border-gray-200 dark:border-gray-800 p-6 hover:border-indigo-400 dark:hover:border-indigo-500 transition-colors"
                >
                  <Shield className="h-8 w-8 text-indigo-600 mb-4" />
                  <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                    Privacy &amp; data requests
                  </h2>
                  <p className="text-gray-600 dark:text-gray-300 mb-3">
                    Account deletion is available in-app under Settings → Delete
                    Account. Contact us for other privacy requests.
                  </p>
                  <p className="font-medium text-indigo-600">
                    privacy@fitcheckaiapp.com
                  </p>
                </a>

                <Link
                  to="/faq"
                  className="rounded-2xl border border-gray-200 dark:border-gray-800 p-6 hover:border-indigo-400 dark:hover:border-indigo-500 transition-colors"
                >
                  <HelpCircle className="h-8 w-8 text-indigo-600 mb-4" />
                  <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
                    FAQ
                  </h2>
                  <p className="text-gray-600 dark:text-gray-300 mb-3">
                    Answers about wardrobe extraction, try-on, photoshoots, and
                    how FitCheck AI works.
                  </p>
                  <p className="font-medium text-indigo-600">View FAQ →</p>
                </Link>
              </div>
            </AnimatedSection>

            <AnimatedSection>
              <div className="rounded-2xl bg-gray-50 dark:bg-gray-900 border border-gray-200 dark:border-gray-800 p-6">
                <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-3">
                  Legal
                </h2>
                <ul className="space-y-2 text-gray-600 dark:text-gray-300">
                  <li>
                    <Link
                      to="/privacy"
                      className="text-indigo-600 hover:text-indigo-500"
                    >
                      Privacy Policy
                    </Link>
                    {' — '}
                    how we handle photos, AI processing (OpenAI),
                    Supabase, and account deletion
                  </li>
                  <li>
                    <Link
                      to="/terms"
                      className="text-indigo-600 hover:text-indigo-500"
                    >
                      Terms of Service
                    </Link>
                    {' — '}
                    acceptable use and community standards
                  </li>
                </ul>
              </div>
            </AnimatedSection>
          </div>
        </section>
      </div>
    </>
  )
}
