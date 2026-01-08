import { AnimatedSection } from '@/components/landing/AnimatedSection'

export default function PrivacyPage() {
  return (
    <div className="pt-20">
      <section className="py-24 bg-gradient-to-br from-indigo-50 via-white to-purple-50 dark:from-gray-950 dark:via-gray-900 dark:to-indigo-950">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <AnimatedSection>
            <div className="text-center mb-12">
              <h1 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
                Privacy Policy
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
              <h2>1. Introduction</h2>
              <p>
                FitCheck AI ("we," "our," or "us") is committed to protecting your privacy. This
                Privacy Policy explains how we collect, use, disclose, and safeguard your
                information when you use our Service.
              </p>

              <h2>2. Information We Collect</h2>

              <h3>2.1 Information You Provide</h3>
              <ul>
                <li><strong>Account Information:</strong> Name, email address, password</li>
                <li><strong>Profile Information:</strong> Body measurements, style preferences</li>
                <li><strong>Wardrobe Content:</strong> Photos of clothing items you upload</li>
                <li><strong>Payment Information:</strong> Billing details for paid subscriptions (processed securely by our payment provider)</li>
              </ul>

              <h3>2.2 Information Collected Automatically</h3>
              <ul>
                <li><strong>Usage Data:</strong> Features used, outfits created, time spent in app</li>
                <li><strong>Device Information:</strong> Device type, operating system, browser type</li>
                <li><strong>Log Data:</strong> IP address, access times, pages viewed</li>
                <li><strong>Location Data:</strong> General location for weather-based features (with your permission)</li>
              </ul>

              <h2>3. How We Use Your Information</h2>
              <p>We use your information to:</p>
              <ul>
                <li>Provide, maintain, and improve the Service</li>
                <li>Process your wardrobe photos using AI to extract and categorize items</li>
                <li>Generate personalized outfit recommendations</li>
                <li>Provide weather-appropriate suggestions</li>
                <li>Send you updates, newsletters, and marketing communications (with your consent)</li>
                <li>Respond to your inquiries and provide customer support</li>
                <li>Monitor and analyze usage patterns to improve user experience</li>
                <li>Detect, prevent, and address technical issues and security threats</li>
              </ul>

              <h2>4. How We Share Your Information</h2>
              <p>We do not sell your personal information. We may share your information with:</p>
              <ul>
                <li><strong>Service Providers:</strong> Third-party vendors who help us operate the Service (hosting, AI processing, analytics)</li>
                <li><strong>Legal Requirements:</strong> When required by law or to protect our rights</li>
                <li><strong>Business Transfers:</strong> In connection with a merger, acquisition, or sale of assets</li>
                <li><strong>With Your Consent:</strong> When you explicitly agree to share information</li>
              </ul>

              <h2>5. Data Security</h2>
              <p>
                We implement industry-standard security measures to protect your data, including:
              </p>
              <ul>
                <li>Encryption of data in transit (TLS/SSL) and at rest (AES-256)</li>
                <li>Regular security audits and penetration testing</li>
                <li>Access controls and authentication requirements</li>
                <li>Secure data centers with physical security measures</li>
              </ul>
              <p>
                However, no method of transmission over the Internet is 100% secure. We cannot
                guarantee absolute security of your data.
              </p>

              <h2>6. Your Rights and Choices</h2>
              <p>You have the right to:</p>
              <ul>
                <li><strong>Access:</strong> Request a copy of your personal data</li>
                <li><strong>Correction:</strong> Update or correct inaccurate information</li>
                <li><strong>Deletion:</strong> Request deletion of your data (subject to legal obligations)</li>
                <li><strong>Portability:</strong> Export your wardrobe data in a common format</li>
                <li><strong>Opt-out:</strong> Unsubscribe from marketing communications</li>
                <li><strong>Restrict Processing:</strong> Limit how we use your data</li>
              </ul>
              <p>
                To exercise these rights, contact us at{' '}
                <a href="mailto:privacy@fitcheckai.com" className="text-indigo-600 hover:text-indigo-500">
                  privacy@fitcheckai.com
                </a>
              </p>

              <h2>7. Cookies and Tracking</h2>
              <p>
                We use cookies and similar technologies to enhance your experience. You can control
                cookie settings through your browser. We use:
              </p>
              <ul>
                <li><strong>Essential Cookies:</strong> Required for the Service to function</li>
                <li><strong>Analytics Cookies:</strong> Help us understand how you use the Service</li>
                <li><strong>Preference Cookies:</strong> Remember your settings and preferences</li>
              </ul>

              <h2>8. Children's Privacy</h2>
              <p>
                The Service is not intended for children under 13. We do not knowingly collect
                information from children under 13. If we learn we have collected such information,
                we will delete it promptly.
              </p>

              <h2>9. International Data Transfers</h2>
              <p>
                Your data may be transferred to and processed in countries other than your own.
                We ensure appropriate safeguards are in place to protect your data in compliance
                with applicable laws.
              </p>

              <h2>10. Data Retention</h2>
              <p>
                We retain your data for as long as your account is active or as needed to provide
                the Service. You can request deletion of your data at any time. Some data may be
                retained for legal or legitimate business purposes.
              </p>

              <h2>11. Changes to This Policy</h2>
              <p>
                We may update this Privacy Policy periodically. We will notify you of significant
                changes via email or through the Service. Continued use after changes constitutes
                acceptance.
              </p>

              <h2>12. Contact Us</h2>
              <p>
                If you have questions about this Privacy Policy or our data practices, contact us:
              </p>
              <ul>
                <li>
                  Email:{' '}
                  <a href="mailto:privacy@fitcheckai.com" className="text-indigo-600 hover:text-indigo-500">
                    privacy@fitcheckai.com
                  </a>
                </li>
                <li>Address: 123 Fashion Street, San Francisco, CA 94102</li>
              </ul>
            </div>
          </AnimatedSection>
        </div>
      </section>
    </div>
  )
}
