import { AnimatedSection } from '@/components/landing/AnimatedSection'
import SEO from '@/components/seo/SEO'
import { PAGE_SEO, SEO_CONFIG } from '@/components/seo/seo-config'

export default function PrivacyPage() {
  return (
    <>
      <SEO
        title={PAGE_SEO.privacy.title}
        description={PAGE_SEO.privacy.description}
        canonicalUrl={`${SEO_CONFIG.siteUrl}/privacy`}
      />
    <div className="pt-20">
      <section className="py-24 bg-stone-50 dark:bg-stone-950">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <AnimatedSection>
            <div className="text-center mb-12">
              <h1 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
                Privacy Policy
              </h1>
              <p className="text-gray-600 dark:text-gray-300">
                Last updated: July 13, 2026
              </p>
            </div>
          </AnimatedSection>
        </div>
      </section>

      <section className="py-16 bg-white dark:bg-gray-950">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <AnimatedSection>
            <div className="prose prose-gray dark:prose-invert max-w-none">
              <h2>1. Introduction</h2>
              <p>
                FitCheck AI ("we," "our," or "us") is committed to protecting
                your privacy. This Privacy Policy explains how we collect, use,
                disclose, and safeguard your information when you use our
                website, web app, and mobile applications (the "Service").
              </p>

              <h2>2. Information We Collect</h2>

              <h3>2.1 Information You Provide</h3>
              <ul>
                <li>
                  <strong>Account Information:</strong> Name, email address,
                  and authentication credentials (including Sign in with Apple
                  or Google)
                </li>
                <li>
                  <strong>Profile Information:</strong> Body measurements
                  (height, weight, body shape, skin tone), style preferences
                </li>
                <li>
                  <strong>Wardrobe &amp; Media Content:</strong> Photos of
                  clothing, selfies or body photos for try-on and AI
                  photoshoot, outfits you create, and content you choose to
                  share
                </li>
                <li>
                  <strong>Support Content:</strong> Messages, bug reports, and
                  content reports you submit to our team
                </li>
                <li>
                  <strong>Payment Information (web/Android where offered):</strong>{' '}
                  Billing is processed by our payment provider (e.g. Stripe).
                  We do not store full card numbers. The iOS app free v1 does
                  not offer in-app purchases or subscriptions.
                </li>
              </ul>

              <h3>2.2 Information Collected Automatically</h3>
              <ul>
                <li>
                  <strong>Usage Data:</strong> Features used, outfits created,
                  product interactions
                </li>
                <li>
                  <strong>Device Information:</strong> Device type, operating
                  system, app version
                </li>
                <li>
                  <strong>Log &amp; Diagnostic Data:</strong> IP address, access
                  times, crash reports, and performance diagnostics
                </li>
                <li>
                  <strong>Location Data:</strong> Approximate location for
                  weather-based outfit suggestions when you use those features
                </li>
              </ul>

              <h2>3. How We Use Your Information</h2>
              <p>We use your information to:</p>
              <ul>
                <li>Provide, maintain, and improve the Service</li>
                <li>
                  Process photos with AI to extract and catalog wardrobe items,
                  generate try-on visualizations, photoshoot images, and
                  recommendations
                </li>
                <li>Generate personalized outfit recommendations</li>
                <li>Provide weather-appropriate suggestions</li>
                <li>
                  Authenticate you and sync your wardrobe across devices
                </li>
                <li>
                  Send service-related notices; marketing only with your consent
                </li>
                <li>Respond to support requests and content reports</li>
                <li>
                  Monitor reliability, prevent abuse, and secure the Service
                </li>
              </ul>

              <h2>4. AI Processing and Third-Party Service Providers</h2>
              <p>
                We do not sell your personal information. To operate the
                Service we use trusted third-party processors. When you use AI
                features, relevant content (for example clothing photos,
                selfies, or text prompts) is sent through our backend to these
                processors solely to fulfill your request. On mobile, we ask
                for consent before the first AI use that shares data with
                third-party AI providers.
              </p>
              <ul>
                <li>
                  <strong>Supabase:</strong> Authentication, database, and
                  file storage for your account, wardrobe, and media
                </li>
                <li>
                  <strong>OpenAI:</strong> AI models used for selected
                  generation and styling features when configured by our
                  backend
                </li>
                <li>
                  <strong>PostHog:</strong> Product analytics (feature usage).
                  We do not use the advertising identifier (IDFA) for tracking
                  across apps or websites
                </li>
                <li>
                  <strong>Sentry:</strong> Crash reporting and performance
                  diagnostics to improve app stability
                </li>
                <li>
                  <strong>Hosting &amp; infrastructure:</strong> Cloud hosts
                  that run our API and website
                </li>
                <li>
                  <strong>Payment processors</strong> (where paid plans are
                  offered outside iOS free v1): e.g. Stripe for web billing
                </li>
              </ul>
              <p>
                These providers process data under their own privacy policies
                and contractual safeguards. We may also share information when
                required by law, to protect our rights, or in connection with a
                business transfer.
              </p>

              <h2>5. Data Security</h2>
              <p>
                We implement industry-standard security measures to protect your
                data, including:
              </p>
              <ul>
                <li>
                  Encryption of data in transit (TLS/SSL) and at rest where
                  supported by our providers
                </li>
                <li>Access controls and authentication requirements</li>
                <li>Monitoring for technical issues and abuse</li>
              </ul>
              <p>
                No method of transmission over the Internet is 100% secure. We
                cannot guarantee absolute security of your data.
              </p>

              <h2>6. Account Deletion and Your Rights</h2>
              <p>You have the right to:</p>
              <ul>
                <li>
                  <strong>Access:</strong> Request a copy of your personal data
                </li>
                <li>
                  <strong>Correction:</strong> Update or correct inaccurate
                  information in Settings or by contacting us
                </li>
                <li>
                  <strong>Deletion:</strong> Delete your account and associated
                  data in the app or web app via{' '}
                  <strong>Settings → Delete Account</strong>. This removes your
                  user record and associated wardrobe, outfits, photos, and
                  profile data from our systems, subject to short-term backups
                  and legal retention requirements. You may also email{' '}
                  <a
                    href="mailto:privacy@fitcheckaiapp.com"
                    className="text-indigo-600 hover:text-indigo-500"
                  >
                    privacy@fitcheckaiapp.com
                  </a>
                </li>
                <li>
                  <strong>Portability:</strong> Request a data export from
                  Settings (where available)
                </li>
                <li>
                  <strong>Opt-out:</strong> Unsubscribe from marketing
                  communications
                </li>
              </ul>
              <p>
                We aim to complete deletion requests promptly. Residual copies
                in encrypted backups may persist for a limited period (typically
                up to 30 days) before automatic purge.
              </p>

              <h2>7. Cookies and Similar Technologies</h2>
              <p>
                On the website we use cookies and similar technologies for
                essential functionality, preferences, and analytics. You can
                control cookies through your browser. The mobile apps use
                platform storage and first-party analytics as described above;
                they are not used to track you across other companies&apos; apps
                or websites for advertising.
              </p>

              <h2>8. Children&apos;s Privacy</h2>
              <p>
                The Service is not intended for children under 13. We do not
                knowingly collect information from children under 13. If we
                learn we have collected such information, we will delete it
                promptly.
              </p>

              <h2>9. International Data Transfers</h2>
              <p>
                Your data may be transferred to and processed in countries other
                than your own, including where our AI and infrastructure
                providers operate. We use appropriate safeguards consistent with
                applicable law.
              </p>

              <h2>10. Data Retention</h2>
              <p>
                We retain your data for as long as your account is active or as
                needed to provide the Service. After account deletion, we remove
                personal data as described in Section 6, except where retention
                is required for legal, security, or legitimate business
                purposes (for example, fraud prevention logs).
              </p>

              <h2>11. Changes to This Policy</h2>
              <p>
                We may update this Privacy Policy periodically. We will notify
                you of significant changes via email or through the Service.
                Continued use after changes constitutes acceptance.
              </p>

              <h2>12. Contact Us</h2>
              <p>
                If you have questions about this Privacy Policy or our data
                practices, contact us:
              </p>
              <ul>
                <li>
                  Privacy:{' '}
                  <a
                    href="mailto:privacy@fitcheckaiapp.com"
                    className="text-indigo-600 hover:text-indigo-500"
                  >
                    privacy@fitcheckaiapp.com
                  </a>
                </li>
                <li>
                  Support:{' '}
                  <a
                    href="mailto:support@fitcheckaiapp.com"
                    className="text-indigo-600 hover:text-indigo-500"
                  >
                    support@fitcheckaiapp.com
                  </a>
                </li>
                <li>
                  Web:{' '}
                  <a
                    href="https://fitcheckaiapp.com/support"
                    className="text-indigo-600 hover:text-indigo-500"
                  >
                    fitcheckaiapp.com/support
                  </a>
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
