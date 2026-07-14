import { AnimatedSection } from '@/components/landing/AnimatedSection'
import SEO from '@/components/seo/SEO'
import { PAGE_SEO, SEO_CONFIG } from '@/components/seo/seo-config'

export default function TermsPage() {
  return (
    <>
      <SEO
        title={PAGE_SEO.terms.title}
        description={PAGE_SEO.terms.description}
        canonicalUrl={`${SEO_CONFIG.siteUrl}/terms`}
      />
    <div className="pt-20">
      <section className="py-24 bg-stone-50 dark:bg-stone-950">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <AnimatedSection>
            <div className="text-center mb-12">
              <h1 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
                Terms of Service
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
              <h2>1. Acceptance of Terms</h2>
              <p>
                By accessing or using FitCheck AI ("Service"), you agree to be bound by these Terms
                of Service ("Terms"). If you disagree with any part of these terms, you may not
                access the Service.
              </p>

              <h2>2. Description of Service</h2>
              <p>
                FitCheck AI is an AI-powered virtual wardrobe and personal-styling platform that
                allows users to catalog clothing, receive outfit recommendations, visualize
                outfits, and generate AI photoshoot images. The Service includes web and mobile
                applications that connect to our cloud backend.
              </p>

              <h2>3. User Accounts</h2>
              <p>
                When you create an account with us, you must provide accurate, complete, and current
                information. Failure to do so constitutes a breach of the Terms. You are responsible
                for safeguarding your credentials and for all activities that occur under your
                account. You may delete your account at any time from Settings in the app or web
                app.
              </p>

              <h2>4. User Content and Community Standards</h2>
              <p>
                You retain ownership of any content you upload to the Service, including photos of
                your clothing and profile media. By uploading content, you grant us a license to
                use, process, and store this content solely to provide the Service to you,
                including sending content to third-party AI processors as described in our Privacy
                Policy.
              </p>
              <p>
                You are solely responsible for the content you upload or share. You agree not to
                upload or share content that is illegal, infringing, harassing, sexually explicit,
                or otherwise objectionable. You may report objectionable content in-app (Report)
                or by emailing{' '}
                <a
                  href="mailto:support@fitcheckaiapp.com"
                  className="text-indigo-600 hover:text-indigo-500"
                >
                  support@fitcheckaiapp.com
                </a>
                . We aim to review reports and remove violating content within 24 hours where
                practical. We may suspend or terminate accounts that repeatedly violate these
                standards.
              </p>

              <h2>5. Acceptable Use</h2>
              <p>You agree not to:</p>
              <ul>
                <li>Use the Service for any unlawful purpose</li>
                <li>Attempt to gain unauthorized access to the Service</li>
                <li>Interfere with or disrupt the Service</li>
                <li>Upload viruses or malicious code</li>
                <li>Collect user information without consent</li>
                <li>Use the Service to harass, abuse, or harm others</li>
                <li>Misuse AI features to generate prohibited or harmful content</li>
              </ul>

              <h2>6. Subscriptions and Pricing</h2>
              <p>
                The FitCheck AI iOS app is free to download and use in its free v1 release. There
                are no in-app purchases or subscriptions offered through the iOS App Store in this
                version.
              </p>
              <p>
                On web or other platforms where paid plans are offered, fees, renewal, and refund
                terms will be disclosed at purchase. Those purchases are processed by our payment
                provider and are not available as external payment links from the iOS app for
                digital content.
              </p>

              <h2>7. AI-Generated Content</h2>
              <p>
                Features such as wardrobe extraction, virtual try-on, recommendations, and
                photoshoot generation produce AI-assisted output. Results may be imperfect and are
                provided for personal styling convenience, not as professional fashion, medical, or
                fit guarantees. You are responsible for how you use generated images.
              </p>

              <h2>8. Intellectual Property</h2>
              <p>
                The Service and its original content (excluding user content) remain the exclusive
                property of FitCheck AI. Our trademarks, logos, and service marks may not be used
                without our prior written consent.
              </p>

              <h2>9. Disclaimer of Warranties</h2>
              <p>
                The Service is provided "as is" and "as available" without warranties of any kind.
                We do not guarantee that the Service will be uninterrupted, secure, or error-free.
                AI-generated recommendations and images are suggestions only.
              </p>

              <h2>10. Limitation of Liability</h2>
              <p>
                To the maximum extent permitted by law, FitCheck AI shall not be liable for any
                indirect, incidental, special, consequential, or punitive damages resulting from
                your use of the Service.
              </p>

              <h2>11. Changes to Terms</h2>
              <p>
                We reserve the right to modify these Terms at any time. We will notify users of
                significant changes via email or through the Service. Continued use after changes
                constitutes acceptance of the new Terms.
              </p>

              <h2>12. Termination</h2>
              <p>
                We may terminate or suspend your account immediately, without prior notice, for
                conduct that we believe violates these Terms or is harmful to other users, us, or
                third parties. You may stop using the Service and delete your account at any time.
              </p>

              <h2>13. Governing Law</h2>
              <p>
                These Terms shall be governed by the laws of the State of California, United States,
                without regard to its conflict of law provisions.
              </p>

              <h2>14. Contact Us</h2>
              <p>
                If you have any questions about these Terms, please contact us at:
                <br />
                <a href="mailto:legal@fitcheckaiapp.com" className="text-indigo-600 hover:text-indigo-500">
                  legal@fitcheckaiapp.com
                </a>
                {' '}or{' '}
                <a href="mailto:support@fitcheckaiapp.com" className="text-indigo-600 hover:text-indigo-500">
                  support@fitcheckaiapp.com
                </a>
              </p>
            </div>
          </AnimatedSection>
        </div>
      </section>
    </div>
    </>
  )
}
