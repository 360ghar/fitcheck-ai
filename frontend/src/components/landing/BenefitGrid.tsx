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
 * presentation — rendered visibly without JavaScript-dependent reveals.
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
    background === 'stone' ? 'bg-stone-50 dark:bg-stone-950' : 'bg-white dark:bg-stone-950'

  return (
    <section className={`py-20 md:py-28 ${sectionBg}`}>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {heading || subheading ? (
          <AnimatedSection>
            <div className="text-center max-w-3xl mx-auto mb-16">
              {heading ? (
                <h2 className="landing-display text-3xl md:text-4xl font-semibold text-stone-900 dark:text-stone-50 mb-4">
                  {heading}
                </h2>
              ) : null}
              {subheading ? (
                <p className="text-lg text-stone-600 dark:text-stone-400">{subheading}</p>
              ) : null}
            </div>
          </AnimatedSection>
        ) : null}

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {items.map((item, index) => {
            const Icon = item.icon
            return (
              <AnimatedSection key={item.title} delay={index * 100}>
                <div className={`group rounded-2xl border border-stone-200 bg-white p-7 transition-colors dark:border-stone-800 dark:bg-stone-900 ${accent.cardHoverBorder}`}>
                  <div
                    className={`w-14 h-14 ${accent.iconBg} rounded-xl flex items-center justify-center mb-6`}
                  >
                    <Icon className={`w-7 h-7 ${accent.iconText}`} />
                  </div>
                  <h3 className="text-xl font-semibold text-stone-900 dark:text-stone-50 mb-3">
                    {item.title}
                  </h3>
                  <p className="text-stone-600 dark:text-stone-400 leading-relaxed">
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
