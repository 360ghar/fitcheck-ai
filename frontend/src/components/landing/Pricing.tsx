import { useState } from 'react'
import { Link } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { Switch } from '@/components/ui/switch'
import { AnimatedSection } from './AnimatedSection'
import { Check } from 'lucide-react'
import { cn } from '@/lib/utils'
import { freePlanFeatureBullets, proPlanFeatureBullets } from '@/lib/plan-limits'

const tiers = [
  {
    name: 'Free',
    price: { monthly: 0, yearly: 0 },
    description: 'Perfect for getting started',
    features: freePlanFeatureBullets(),
    cta: 'Start free',
    highlighted: false,
  },
  {
    name: 'Pro',
    price: { monthly: 20, yearly: 200 },
    description: 'For higher limits and deeper tools',
    features: proPlanFeatureBullets(),
    cta: 'Upgrade to Pro',
    highlighted: true,
    badge: 'Best value',
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

  return (
    <div
      className={cn(
        'relative flex h-full flex-col overflow-hidden rounded-2xl border p-6 md:p-8',
        highlighted
          ? 'border-indigo-600 bg-white dark:bg-stone-950'
          : 'border-stone-200/90 bg-white dark:border-stone-800 dark:bg-stone-950'
      )}
    >
      {badge && (
        <div className="absolute top-0 right-0 bg-indigo-600 text-white px-4 py-1 text-sm font-medium rounded-bl-lg">
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
      </div>

      <ul className="mb-8 flex-1 space-y-3">
        {features.map((feature) => (
          <li key={feature} className="flex items-start gap-3">
            <Check className="w-5 h-5 text-emerald-500 shrink-0 mt-0.5" />
            <span className="text-stone-600 dark:text-stone-300 text-[15px]">{feature}</span>
          </li>
        ))}
      </ul>

      <Button
        className={cn(
          'w-full h-12 text-base font-medium shadow-none',
          highlighted
            ? 'bg-indigo-600 hover:bg-indigo-700 text-white'
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
              Start free. Upgrade when you need higher limits for extractions, try-on, and photoshoots.
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
                <span className="text-xs font-medium text-indigo-600 dark:text-indigo-400">
                  Save $40
                </span>
              </span>
            </div>
          </div>
        </AnimatedSection>

        <div className="grid md:grid-cols-2 gap-5 md:gap-6 max-w-4xl">
          {tiers.map((tier, index) => (
            <AnimatedSection key={tier.name} delay={index * 80}>
              <PricingCard {...tier} isYearly={isYearly} />
            </AnimatedSection>
          ))}
        </div>

        <AnimatedSection delay={200}>
          <p className="mt-8 text-sm text-stone-500 dark:text-stone-400">
            No credit card required. Cancel anytime.{' '}
            <a
              href="#faq"
              className="text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300 transition-colors"
            >
              See free vs Pro details
            </a>
          </p>
        </AnimatedSection>
      </div>
    </section>
  )
}
