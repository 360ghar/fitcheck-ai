import { Link } from 'react-router-dom'
import { ArrowRight } from 'lucide-react'
import { AnimatedSection } from '@/components/landing/AnimatedSection'
import { ACCENT_CLASSES, type AccentColor, type CTAButton } from './accentColors'

export interface CtaBandProps {
  heading: string
  subtext: string
  primaryCta: CTAButton
  secondaryCta?: CTAButton
  /** Small line rendered under the buttons (e.g. "No credit card required."). */
  footnote?: string
  accentColor?: AccentColor
  /** Background style. `'dark'` (default, stone-900) or `'indigo'` (indigo-600). */
  variant?: 'dark' | 'indigo'
}

/**
 * Closing call-to-action band: heading, subtext, one or two buttons, and an
 * optional footnote. Shared by the public feature pages.
 */
export function CtaBand({
  heading,
  subtext,
  primaryCta,
  secondaryCta,
  footnote,
  accentColor = 'indigo',
  variant = 'dark',
}: CtaBandProps) {
  const accent = ACCENT_CLASSES[accentColor]
  const sectionBg = variant === 'indigo' ? 'bg-indigo-600' : 'bg-stone-900'

  return (
    <section className={`py-20 md:py-28 ${sectionBg}`}>
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <AnimatedSection>
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold text-white mb-6">
            {heading}
          </h2>
          <p className={`text-xl ${accent.text100} mb-10 max-w-2xl mx-auto`}>{subtext}</p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              to={primaryCta.to}
              className="inline-flex items-center justify-center gap-2 bg-white text-indigo-600 px-8 py-4 rounded-full font-semibold text-lg hover:bg-gray-100 transition-all hover:scale-105"
            >
              {primaryCta.text}
              <ArrowRight className="w-5 h-5" />
            </Link>
            {secondaryCta ? (
              <Link
                to={secondaryCta.to}
                className="inline-flex items-center justify-center gap-2 bg-white/10 backdrop-blur-sm text-white px-8 py-4 rounded-full font-semibold text-lg hover:bg-white/20 transition-all"
              >
                {secondaryCta.text}
              </Link>
            ) : null}
          </div>

          {footnote ? <p className={`${accent.text200} mt-6 text-sm`}>{footnote}</p> : null}
        </AnimatedSection>
      </div>
    </section>
  )
}
