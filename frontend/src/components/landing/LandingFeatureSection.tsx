import type { ReactNode } from 'react'
import { Link } from 'react-router-dom'
import { ArrowRight } from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import { AnimatedSection } from '@/components/landing/AnimatedSection'
import { ACCENT_CLASSES, type AccentColor, type CTAButton } from './accentColors'

export interface LandingFeatureSectionProps {
  /** Optional pill badge shown above the title (e.g. "AI Style Assistant"). */
  badge?: { icon: LucideIcon; text: string }
  title: string
  subtitle: string
  description: string
  accentColor?: AccentColor
  /** Optional image/media node rendered between the description and CTAs. */
  image?: ReactNode
  primaryCta: CTAButton
  secondaryCta?: CTAButton
}

/**
 * Hero section shared by the public feature pages: dark stone backdrop with
 * soft blurred orbs, centered badge + title + subtitle + description, and a
 * primary/secondary CTA button pair.
 */
export function LandingFeatureSection({
  badge,
  title,
  subtitle,
  description,
  accentColor = 'indigo',
  image,
  primaryCta,
  secondaryCta,
}: LandingFeatureSectionProps) {
  const accent = ACCENT_CLASSES[accentColor]
  const BadgeIcon = badge?.icon

  return (
    <section className="relative overflow-hidden bg-stone-900 dark:bg-stone-950">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute top-20 left-1/4 w-72 h-72 bg-white rounded-full blur-3xl" />
        <div className="absolute bottom-20 right-1/4 w-96 h-96 bg-white rounded-full blur-3xl" />
      </div>

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24 md:py-32">
        <AnimatedSection>
          <div className="text-center max-w-4xl mx-auto">
            {badge && BadgeIcon && (
              <div className="inline-flex items-center gap-2 px-4 py-2 bg-white/10 backdrop-blur-sm rounded-full text-white/90 text-sm font-medium mb-6">
                <BadgeIcon className="w-4 h-4" />
                {badge.text}
              </div>
            )}

            <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-white mb-6 leading-tight">
              {title}
            </h1>

            <p className={`text-xl md:text-2xl ${accent.text100} mb-4 max-w-3xl mx-auto`}>
              {subtitle}
            </p>

            <p className={`text-lg ${accent.text200} mb-10 max-w-2xl mx-auto`}>
              {description}
            </p>

            {image ? <div className="mb-10">{image}</div> : null}

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
          </div>
        </AnimatedSection>
      </div>
    </section>
  )
}
