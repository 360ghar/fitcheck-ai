import { useState } from 'react'
import { Link } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { Switch } from '@/components/ui/switch'
import { AnimatedSection } from './AnimatedSection'
import { Check } from 'lucide-react'
import { cn } from '@/lib/utils'
import {
  PLAN_PRICES,
  freePlanFeatureBullets,
  plusPlanFeatureBullets,
  proPlanFeatureBullets,
} from '@/lib/plan-limits'

const tiers = [
  {
    name: 'Free',
    price: PLAN_PRICES.free,
    description: 'Perfect for getting started',
    features: freePlanFeatureBullets(),
    cta: 'Start free',
    highlighted: false,
  },
  {
    name: 'Plus',
    price: PLAN_PRICES.plus,
    description: 'Every paid feature, everyday limits',
    features: plusPlanFeatureBullets(),
    cta: 'Get Plus',
    highlighted: true,
    badge: 'Most popular',
  },
  {
    name: 'Pro',
    price: PLAN_PRICES.pro,
    description: 'The same features at the highest limits',
    features: proPlanFeatureBullets(),
    cta: 'Upgrade to Pro',
    highlighted: false,
  },
]

interface PricingCardProps {
  name: string
  price: { monthly: number; yearly: number }
  description: string
  features: string[]
  cta: string
  highlighted: boolean
  badge?: string
  isYearly: boolean
}

function PricingCard({
  name,
  price,
  description,
  features,
  cta,
  highlighted,
  badge,
  isYearly,
}: PricingCardProps) {
  const displayPrice = isYearly ? price.yearly : price.monthly
  // Each tier states its own real saving rather than one hardcoded figure.
  const savings = price.monthly * 12 - price.yearly

  return (
    <div
      className={cn(
        'relative flex h-full flex-col overflow-hidden rounded-2xl border p-6 md:p-8',
        highlighted
          ? 'border-primary bg-white dark:bg-stone-950'
          : 'border-stone-200/90 bg-white dark:border-stone-800 dark:bg-stone-950'
      )}
    >
      {badge && (
        <div className="absolute top-0 right-0 bg-primary text-white px-4 py-1 text-sm font-medium rounded-bl-lg">
          {badge}
        </div>
      )}

      <div className="mb-6">
        <h3 className="text-2xl font-semibold text-stone-900 dark:text-stone-50">{name}</h3>
        <p className="mt-1 text-sm text-stone-500 dark:text-stone-400">{description}</p>
      </div>

      <div className="mb-6">
        <span className="landing-display text-5xl font-semibold text-stone-900 dark:text-stone-50">
          ${displayPrice.toFixed(displayPrice % 1 === 0 ? 0 : 2)}
        </span>
        {displayPrice > 0 && (
          <span className="text-stone-500 dark:text-stone-400">
            /{isYearly ? 'year' : 'month'}
          </span>
        )}
        {/* Reserve the line in every card so the feature lists and CTAs stay
            on a shared baseline across all three columns. */}
        <p className="mt-1 h-5 text-sm text-stone-500 dark:text-stone-400">
          {isYearly && savings > 0 ? `Saves $${savings} a year` : ''}
        </p>
      </div>

      <ul className="mb-8 flex-1 space-y-3">
        {features.map((feature) => (
          <li key={feature} className="flex items-start gap-3">
            <Check className="w-5 h-5 text-success shrink-0 mt-0.5" />
            <span className="text-stone-600 dark:text-stone-300 text-[15px]">{feature}</span>
          </li>
        ))}
      </ul>

      <Button
        className={cn(
          'w-full h-12 text-base font-medium shadow-none',
          highlighted
            ? 'bg-primary hover:bg-primary-pressed text-white'
            : 'border-stone-300 dark:border-stone-700'
        )}
        variant={highlighted ? 'default' : 'outline'}
        size="lg"
        asChild
      >
        <Link to="/auth/register">{cta}</Link>
      </Button>
    </div>
  )
}

export default function Pricing() {
  const [isYearly, setIsYearly] = useState(false)

  return (
    <section id="pricing" className="py-20 md:py-28 bg-stone-50 dark:bg-stone-900/40">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="max-w-2xl mb-12 md:mb-14">
            <h2 className="landing-display text-3xl sm:text-4xl md:text-[2.75rem] font-semibold text-stone-900 dark:text-stone-50 leading-tight">
              Simple, transparent pricing
            </h2>
            <p className="mt-4 text-base md:text-lg text-stone-600 dark:text-stone-400">
              Start free. Plus and Pro unlock the same features — pick the limits that match how much you generate.
            </p>

            <div className="mt-8 flex items-center gap-4">
              <span
                className={cn(
                  'font-medium transition-colors text-sm',
                  !isYearly
                    ? 'text-stone-900 dark:text-stone-50'
                    : 'text-stone-500 dark:text-stone-400'
                )}
              >
                Monthly
              </span>
              <Switch checked={isYearly} onCheckedChange={setIsYearly} />
              <span
                className={cn(
                  'font-medium transition-colors text-sm flex items-center gap-2',
                  isYearly
                    ? 'text-stone-900 dark:text-stone-50'
                    : 'text-stone-500 dark:text-stone-400'
                )}
              >
                Yearly
                <span className="text-xs font-medium text-primary">
                  2 months free
                </span>
              </span>
            </div>
          </div>
        </AnimatedSection>

        {/* items-stretch + h-full cards keep every row (price, features, CTA)
            on one baseline regardless of copy length. */}
        <div className="grid items-stretch gap-5 md:grid-cols-3 md:gap-6 max-w-6xl">
          {tiers.map((tier, index) => (
            <AnimatedSection key={tier.name} delay={index * 80} className="h-full">
              <PricingCard {...tier} isYearly={isYearly} />
            </AnimatedSection>
          ))}
        </div>

        <AnimatedSection delay={200}>
          <p className="mt-8 text-sm text-stone-500 dark:text-stone-400">
            No credit card required. Cancel anytime.{' '}
            <a
              href="#faq"
              className="text-primary hover:text-primary-pressed transition-colors"
            >
              Compare plan details
            </a>
          </p>
        </AnimatedSection>
      </div>
    </section>
  )
}
