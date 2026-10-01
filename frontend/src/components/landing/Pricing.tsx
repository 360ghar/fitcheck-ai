import { useState } from 'react'
import { Link } from 'react-router-dom'
import { Check, Minus } from 'lucide-react'

import { Switch } from '@/components/ui/switch'
import { trackEvent } from '@/lib/analytics'
import {
  PLAN_LIMITS,
  PLAN_PRICES,
  freePlanFeatureBullets,
  plusPlanFeatureBullets,
  proPlanFeatureBullets,
  yearlySavings,
} from '@/lib/plan-limits'
import { cn } from '@/lib/utils'
import { trialPlanHref, TRIAL_PROMO_CODE } from '@/lib/trial-offer'
import { AnimatedSection } from './AnimatedSection'
import { scrollToSectionId } from '@/lib/scroll'

type PlanKey = keyof typeof PLAN_PRICES

const tiers = [
  {
    key: 'free' as const,
    name: 'Free',
    description: 'Start a useful wardrobe at no cost',
    features: freePlanFeatureBullets(),
    mobileCta: 'Start free',
  },
  {
    key: 'plus' as const,
    name: 'Plus',
    description: 'Every paid feature with everyday limits',
    features: plusPlanFeatureBullets(),
    mobileCta: 'Get Plus',
  },
  {
    key: 'pro' as const,
    name: 'Pro',
    description: 'The same features at the highest limits',
    features: proPlanFeatureBullets(),
    mobileCta: 'Upgrade to Pro',
  },
]

const comparisonRows = [
  {
    label: 'Item extractions / month',
    values: tiers.map(({ key }) => PLAN_LIMITS[key].monthlyExtractions.toLocaleString('en-US')),
  },
  {
    label: 'Outfit visualizations / month',
    values: tiers.map(({ key }) => PLAN_LIMITS[key].monthlyGenerations.toLocaleString('en-US')),
  },
  {
    label: 'Photoshoot images / day',
    values: tiers.map(({ key }) => PLAN_LIMITS[key].dailyPhotoshootImages.toLocaleString('en-US')),
  },
  {
    label: 'Virtual try-on',
    values: ['Not included', 'Included', 'Included'],
  },
  {
    label: 'Advanced wardrobe analytics',
    values: ['Not included', 'Included', 'Included'],
  },
  {
    label: 'Calendar planning and priority support',
    values: ['Not included', 'Included', 'Included'],
  },
]

function planHref(plan: PlanKey, isYearly: boolean) {
  return plan === 'free' ? '/auth/register' : trialPlanHref(plan, isYearly)
}

function displayPrice(plan: PlanKey, isYearly: boolean) {
  const price = PLAN_PRICES[plan]
  return isYearly ? price.yearly : price.monthly
}

function Price({ plan, isYearly }: { plan: PlanKey; isYearly: boolean }) {
  const price = displayPrice(plan, isYearly)

  return (
    <>
      <span className="text-4xl font-bold tabular-nums text-paper-text">
        ${price.toFixed(price % 1 === 0 ? 0 : 2)}
      </span>
      {price > 0 && (
        <span className="ml-1 text-sm font-normal text-paper-text-3">
          /{isYearly ? 'year' : 'month'}
        </span>
      )}
    </>
  )
}

function PricingCard({
  tier,
  isYearly,
}: {
  tier: (typeof tiers)[number]
  isYearly: boolean
}) {
  const highlighted = tier.key === 'plus'
  const saving = yearlySavings(tier.key)

  return (
    // Paper sheet per plan. Plus carries the accent ring; the only red on
    // the card is its button.
    <article
      className={cn(
        'paper-sheet flex h-full flex-col overflow-hidden',
        highlighted && 'ring-2 ring-paper-accent'
      )}
    >
      <div className="px-6 pt-6">
        <div className="flex items-baseline justify-between gap-4">
          <h3 className="paper-head text-2xl text-paper-text">{tier.name}</h3>
          {highlighted && <span className="text-sm font-semibold text-paper-accent">Everyday</span>}
        </div>
        <p className="mt-1 min-h-10 text-sm text-paper-text-3">{tier.description}</p>
      </div>

      <div className="px-6 pt-6">
        <Price plan={tier.key} isYearly={isYearly} />
        <p className="mt-2 min-h-5 text-sm text-paper-text-3">
          {isYearly && saving > 0 ? `Save $${saving} each year` : 'No contract'}
        </p>
      </div>

      <ul className="mt-6 flex-1 space-y-3 px-6">
        {tier.features.map((feature) => (
          <li key={feature} className="flex items-start gap-3 text-sm leading-relaxed text-paper-text-2">
            <Check className="mt-0.5 h-4 w-4 shrink-0 text-paper-accent" aria-hidden="true" />
            {feature}
          </li>
        ))}
      </ul>

      <div className="p-6">
        <Link
            className={cn(highlighted ? 'paper-btn' : 'paper-btn-sheet', 'w-full')}
            to={planHref(tier.key, isYearly)}
            onClick={() =>
              trackEvent('landing_cta_click', {
                location: 'pricing',
                plan: tier.key,
                promo: TRIAL_PROMO_CODE,
              })
            }
          >
            {tier.mobileCta}
        </Link>
      </div>
    </article>
  )
}

function ComparisonValue({ value }: { value: string }) {
  const included = value === 'Included'
  const unavailable = value === 'Not included'

  return (
    <span className="inline-flex items-center justify-center gap-2">
      {included && <Check className="h-4 w-4 text-paper-accent" aria-hidden="true" />}
      {unavailable && <Minus className="h-4 w-4 text-paper-text-3" aria-hidden="true" />}
      <span className={unavailable ? 'sr-only' : undefined}>{value}</span>
    </span>
  )
}

export default function Pricing() {
  const [isYearly, setIsYearly] = useState(false)

  return (
    <section
      id="pricing"
      aria-labelledby="pricing-heading"
      className="paper-section paper-tear stock-stone pb-24 pt-20 md:pb-32 md:pt-28"
    >
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="grid gap-8 lg:grid-cols-12 lg:items-end">
          <div className="max-w-2xl lg:col-span-7">
            <h2 id="pricing-heading" className="paper-display text-[clamp(2rem,5.4vw,4.25rem)] text-paper-text">
              Start free. Pay for more room.
            </h2>
            <p className="mt-5 text-base leading-relaxed text-paper-text-2 sm:text-[17px]">
              Plus and Pro unlock the same features. Only the limits differ.
            </p>
          </div>

          <div className="min-w-0 lg:col-span-5 lg:justify-self-end">
            <p className="text-sm font-semibold text-paper-accent">
              First month of Pro free. No card. It returns to Free unless you upgrade.
            </p>
            <div className="mt-5 flex min-h-11 items-center gap-4">
              <span className={cn('text-sm font-medium', !isYearly ? 'text-paper-text' : 'text-paper-text-3')}>
                Monthly
              </span>
              <Switch
                checked={isYearly}
                onCheckedChange={setIsYearly}
                aria-label="Billing period"
                className="data-[state=checked]:bg-paper-accent data-[state=unchecked]:bg-paper-edge"
              />
              <span className={cn('text-sm font-medium', isYearly ? 'text-paper-text' : 'text-paper-text-3')}>
                Yearly <span className="ml-1 text-paper-accent">2 months free</span>
              </span>
            </div>
          </div>
        </div>

        <div className="paper-sheet mt-12 hidden overflow-hidden lg:block">
          <table className="w-full table-fixed border-collapse text-left">
            <caption className="sr-only">FitCheck plan and usage limit comparison</caption>
            <thead>
              <tr className="border-b border-paper-edge align-top">
                <th scope="col" className="w-[28%] px-7 py-8 text-sm font-semibold text-paper-text-3">
                  Plan comparison
                </th>
                {tiers.map((tier) => (
                  <th
                    key={tier.key}
                    scope="col"
                    className={cn(
                      'w-[24%] border-l border-paper-edge px-6 py-8',
                      tier.key === 'plus' && 'bg-paper-tint/50'
                    )}
                  >
                    <div className="flex items-baseline justify-between gap-3">
                      <p className="paper-head text-2xl font-normal text-paper-text">{tier.name}</p>
                      {tier.key === 'plus' && (
                        <span className="text-sm font-semibold text-paper-accent">Everyday</span>
                      )}
                    </div>
                    <p className="mt-1 min-h-10 text-sm font-normal leading-relaxed text-paper-text-3">
                      {tier.description}
                    </p>
                    <div className="mt-5">
                      <Price plan={tier.key} isYearly={isYearly} />
                    </div>
                    <p className="mt-2 min-h-5 text-xs font-normal text-paper-text-3">
                      {isYearly && yearlySavings(tier.key) > 0
                        ? `Save $${yearlySavings(tier.key)} each year`
                        : 'No contract'}
                    </p>
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {comparisonRows.map((row) => (
                <tr key={row.label} className="border-b border-paper-edge last:border-b-0">
                  <th scope="row" className="px-7 py-5 text-sm font-medium text-paper-text">
                    {row.label}
                  </th>
                  {row.values.map((value, index) => (
                    <td
                      key={`${row.label}-${tiers[index].key}`}
                      className={cn(
                        'border-l border-paper-edge px-6 py-5 text-center text-sm tabular-nums text-paper-text-2',
                        tiers[index].key === 'plus' && 'bg-paper-tint/50'
                      )}
                    >
                      <ComparisonValue value={value} />
                    </td>
                  ))}
                </tr>
              ))}
              <tr>
                <th scope="row" className="px-7 py-6 text-sm font-medium text-paper-text">
                  Next step
                </th>
                {tiers.map((tier) => (
                  <td
                    key={tier.key}
                    className={cn(
                      'border-l border-paper-edge px-6 py-6',
                      tier.key === 'plus' && 'bg-paper-tint/50'
                    )}
                  >
                      <Link
                        className={cn(tier.key === 'plus' ? 'paper-btn' : 'paper-btn-sheet', 'w-full')}
                        to={planHref(tier.key, isYearly)}
                        onClick={() =>
                          trackEvent('landing_cta_click', {
                            location: 'pricing',
                            plan: tier.key,
                            promo: TRIAL_PROMO_CODE,
                          })
                        }
                      >
                        Choose {tier.name}
                      </Link>
                  </td>
                ))}
              </tr>
            </tbody>
          </table>
        </div>

        <div className="min-w-0 max-w-full overflow-hidden [contain:paint] lg:hidden">
          <div
            data-testid="mobile-pricing-rail"
            className="mt-12 flex w-full snap-x snap-mandatory gap-4 overflow-x-auto pb-4 pr-4"
          >
            {tiers.map((tier, index) => (
              <AnimatedSection
                key={tier.key}
                delay={index * 80}
                className="w-full min-w-0 shrink-0 snap-start sm:w-[24rem]"
              >
                <PricingCard tier={tier} isYearly={isYearly} />
              </AnimatedSection>
            ))}
          </div>

          <p className="mt-4 text-xs text-paper-text-3 lg:hidden">Swipe to compare plans.</p>
        </div>

        <p className="mt-6 text-sm text-paper-text-3">
          No credit card is required for the free month. Cancel paid plans at any time.{' '}
          <a
            href="#faq"
            onClick={(event) => {
              event.preventDefault()
              scrollToSectionId('faq')
            }}
            className="font-semibold text-paper-accent hover:text-paper-text"
          >
            Read billing answers
          </a>
        </p>
      </div>
    </section>
  )
}
