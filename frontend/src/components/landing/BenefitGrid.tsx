import { AnimatedSection } from '@/components/landing/AnimatedSection'
import { ACCENT_CLASSES, type AccentColor, type BenefitItem } from './accentColors'

export interface BenefitGridProps {
  items: BenefitItem[]
  /** Optional section heading rendered centered above the grid. */
  heading?: string
  /** Optional supporting line under the heading. */
  subheading?: string
  accentColor?: AccentColor
  /** Section background. `'white'` (default) or `'stone'` for the warm variant. */
  background?: 'white' | 'stone'
}

/**
 * Responsive grid of `{ icon, title, description }` cards used for the
 * "Features" section on every public feature page. Cards are pure
 * presentation — animated on scroll via `AnimatedSection`.
 */
export function BenefitGrid({
  items,
  heading,
  subheading,
  accentColor = 'indigo',
  background = 'white',
}: BenefitGridProps) {
  const accent = ACCENT_CLASSES[accentColor]
  const sectionBg =
    background === 'stone' ? 'bg-stone-50 dark:bg-stone-950' : 'bg-white dark:bg-gray-950'

  return (
    <section className={`py-20 md:py-28 ${sectionBg}`}>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {heading || subheading ? (
          <AnimatedSection>
            <div className="text-center max-w-3xl mx-auto mb-16">
              {heading ? (
                <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-4">
                  {heading}
                </h2>
              ) : null}
              {subheading ? (
                <p className="text-lg text-gray-600 dark:text-gray-400">{subheading}</p>
              ) : null}
            </div>
          </AnimatedSection>
        ) : null}

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {items.map((item, index) => {
            const Icon = item.icon
            return (
              <AnimatedSection key={item.title} delay={index * 100}>
                <div
                  className={`group p-8 bg-white dark:bg-gray-800 rounded-2xl hover:shadow-lg transition-all duration-300 border border-gray-100 dark:border-gray-700 ${accent.cardHoverBorder}`}
                >
                  <div
                    className={`w-14 h-14 ${accent.iconBg} rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform`}
                  >
                    <Icon className={`w-7 h-7 ${accent.iconText}`} />
                  </div>
                  <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-3">
                    {item.title}
                  </h3>
                  <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                    {item.description}
                  </p>
                </div>
              </AnimatedSection>
            )
          })}
        </div>
      </div>
    </section>
  )
}
