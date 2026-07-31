import { Link } from 'react-router-dom'
import { ArrowUpRight } from 'lucide-react'
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
  /** Background style. `'dark'` is editorial; `'indigo'` is retained for API compatibility and renders brand red. */
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
  const sectionBg = variant === 'indigo' ? 'bg-primary' : 'bg-stone-900'

  return (
    <section className={`py-20 md:py-28 ${sectionBg}`}>
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <AnimatedSection>
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold text-white mb-6">
            {heading}
          </h2>
          <p className={`text-xl ${accent.text100} mb-10 max-w-2xl mx-auto`}>{subtext}</p>

          {/* Both pills sit on a fixed dark / brand-red band that does NOT follow
              the page theme, so their colours must not either. The light pill
              carries the theme-invariant `on-image` pair (white fill, black
              label in BOTH themes) — it previously said `text-ink
              hover:bg-surface-card`, and once `ink` started resolving through
              `--foreground` that painted near-white text on a white pill in
              dark mode. The ghost pill's white/N literals are already
              theme-invariant for the same reason; do not "tokenise" them to
              page-theme vars. */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              to={primaryCta.to}
              className="inline-flex min-h-11 items-center justify-center gap-2 rounded-full bg-on-image px-8 py-4 text-lg font-semibold text-on-image-foreground transition-colors hover:bg-on-image/90 focus-visible:outline-none"
            >
              {primaryCta.text}
              <ArrowUpRight className="w-5 h-5" />
            </Link>
            {secondaryCta ? (
              <Link
                to={secondaryCta.to}
                className="inline-flex min-h-11 items-center justify-center gap-2 rounded-full border border-white/20 bg-white/10 px-8 py-4 text-lg font-semibold text-white transition-colors hover:bg-white/20 focus-visible:outline-none"
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
