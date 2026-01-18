import { AnimatedSection } from '@/components/landing/AnimatedSection'

export default function TermsPage() {
  return (
    <div className="pt-20">
      <section className="py-24 bg-gradient-to-br from-indigo-50 via-white to-purple-50 dark:from-gray-950 dark:via-gray-900 dark:to-indigo-950">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <AnimatedSection>
            <div className="text-center mb-12">
              <h1 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
                Terms of Service
              </h1>
              <p className="text-gray-600 dark:text-gray-300">
                Last updated: January 1, 2026
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
                FitCheck AI is an AI-powered virtual wardrobe management platform that allows users
                to catalog their clothing, receive outfit recommendations, and visualize outfit
                combinations. The Service includes web and mobile applications.
              </p>

              <h2>3. User Accounts</h2>
              <p>
                When you create an account with us, you must provide accurate, complete, and current
                information. Failure to do so constitutes a breach of the Terms. You are responsible
                for safeguarding the password and for all activities that occur under your account.
              </p>

              <h2>4. User Content</h2>
              <p>
                You retain ownership of any content you upload to the Service, including photos of
                your clothing. By uploading content, you grant us a license to use, process, and
                store this content solely to provide the Service to you.
              </p>
              <p>
                You are solely responsible for the content you upload. You agree not to upload
                content that infringes on any third party's intellectual property rights or violates
                any applicable laws.
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
              </ul>

              <h2>6. Subscription and Billing</h2>
              <p>
                Some features of the Service require a paid subscription. By subscribing, you agree
                to pay the applicable fees. Subscriptions automatically renew unless cancelled
                before the renewal date.
              </p>
              <p>
                Refunds are available within 14 days of initial purchase if you are not satisfied
                with the Service. After this period, refunds are at our discretion.
              </p>

              <h2>7. Intellectual Property</h2>
              <p>
                The Service and its original content (excluding user content) remain the exclusive
                property of FitCheck AI. Our trademarks, logos, and service marks may not be used
                without our prior written consent.
              </p>

              <h2>8. Disclaimer of Warranties</h2>
              <p>
                The Service is provided "as is" and "as available" without warranties of any kind.
                We do not guarantee that the Service will be uninterrupted, secure, or error-free.
                AI-generated recommendations are suggestions only and may not be suitable for all
                situations.
              </p>

              <h2>9. Limitation of Liability</h2>
              <p>
                To the maximum extent permitted by law, FitCheck AI shall not be liable for any
                indirect, incidental, special, consequential, or punitive damages resulting from
                your use of the Service.
              </p>

              <h2>10. Changes to Terms</h2>
              <p>
                We reserve the right to modify these Terms at any time. We will notify users of
                significant changes via email or through the Service. Continued use after changes
                constitutes acceptance of the new Terms.
              </p>

              <h2>11. Termination</h2>
              <p>
                We may terminate or suspend your account immediately, without prior notice, for
                conduct that we believe violates these Terms or is harmful to other users, us, or
                third parties.
              </p>

              <h2>12. Governing Law</h2>
              <p>
                These Terms shall be governed by the laws of the State of California, United States,
                without regard to its conflict of law provisions.
              </p>

              <h2>13. Contact Us</h2>
              <p>
                If you have any questions about these Terms, please contact us at:
                <br />
                <a href="mailto:legal@fitcheckaiapp.com" className="text-indigo-600 hover:text-indigo-500">
                  legal@fitcheckaiapp.com
                </a>
              </p>
            </div>
          </AnimatedSection>
        </div>
      </section>
    </div>
  )
}
