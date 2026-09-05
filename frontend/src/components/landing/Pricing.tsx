import { useState } from 'react'
import { Link } from 'react-router-dom'
import { Check, Minus } from 'lucide-react'

import { Button } from '@/components/ui/button'
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
import { SectionKicker } from './SectionKicker'

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
      <span className="landing-display text-4xl font-semibold text-foreground">
        ${price.toFixed(price % 1 === 0 ? 0 : 2)}
      </span>
      {price > 0 && (
        <span className="ml-1 text-sm font-normal text-muted-foreground">
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
    <article
      className={cn(
        'flex h-full flex-col overflow-hidden rounded-[2rem] border bg-card',
        highlighted ? 'border-primary' : 'border-border'
      )}
    >
      <div className={cn('border-b px-6 py-5', highlighted ? 'border-primary bg-primary' : 'border-border')}>
        <div className="flex items-start justify-between gap-4">
          <div>
            <h3 className={cn('text-xl font-semibold', highlighted ? 'text-primary-foreground' : 'text-foreground')}>
              {tier.name}
            </h3>
            <p className={cn('mt-1 text-sm', highlighted ? 'text-primary-foreground/90' : 'text-muted-foreground')}>
              {tier.description}
            </p>
          </div>
          {highlighted && (
            <span className="rounded-full border border-primary-foreground/30 px-2.5 py-1 text-xs font-semibold text-primary-foreground">
              Everyday
            </span>
          )}
        </div>
      </div>

      <div className="px-6 pt-6">
        <Price plan={tier.key} isYearly={isYearly} />
        <p className="mt-2 min-h-5 text-sm text-muted-foreground">
          {isYearly && saving > 0 ? `Save $${saving} each year` : 'No contract'}
        </p>
      </div>

      <ul className="mt-6 flex-1 space-y-3 px-6">
        {tier.features.map((feature) => (
          <li key={feature} className="flex items-start gap-3 text-sm leading-relaxed text-body">
            <Check className="mt-0.5 h-4 w-4 shrink-0 text-success" aria-hidden="true" />
            {feature}
          </li>
        ))}
      </ul>

      <div className="p-6">
        <Button variant={highlighted ? 'default' : 'outline'} size="lg" className="h-12 w-full" asChild>
          <Link
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
        </Button>
      </div>
    </article>
  )
}

function ComparisonValue({ value }: { value: string }) {
  const included = value === 'Included'
  const unavailable = value === 'Not included'

  return (
    <span className="inline-flex items-center justify-center gap-2">
      {included && <Check className="h-4 w-4 text-success" aria-hidden="true" />}
      {unavailable && <Minus className="h-4 w-4 text-muted-foreground" aria-hidden="true" />}
      <span className={unavailable ? 'sr-only' : undefined}>{value}</span>
    </span>
  )
}

export default function Pricing() {
  const [isYearly, setIsYearly] = useState(false)

  return (
    <section id="pricing" className="scroll-mt-16 bg-surface-soft py-20 md:py-28">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <AnimatedSection className="reveal">
          <div className="grid gap-8 lg:grid-cols-12 lg:items-end">
            <div className="max-w-2xl lg:col-span-7">
              <SectionKicker>Pricing matrix</SectionKicker>
              <h2 className="landing-display text-3xl font-semibold leading-tight text-foreground sm:text-4xl md:text-[2.75rem]">
                Compare limits without decoding the fine print
              </h2>
              <p className="mt-4 text-base leading-relaxed text-body md:text-lg">
                Start on Free. Plus and Pro contain the same paid capabilities; only their usage limits differ.
              </p>
            </div>

            <div className="min-w-0 lg:col-span-5 lg:justify-self-end">
              <p className="text-sm font-medium text-primary">
                First month of Pro free · No credit card · Returns to Free
              </p>
              <div className="mt-5 flex min-h-11 items-center gap-4">
                <span className={cn('text-sm font-medium', !isYearly ? 'text-foreground' : 'text-muted-foreground')}>
                  Monthly
                </span>
                <Switch checked={isYearly} onCheckedChange={setIsYearly} aria-label="Billing period" />
                <span className={cn('text-sm font-medium', isYearly ? 'text-foreground' : 'text-muted-foreground')}>
                  Yearly <span className="ml-1 text-primary">2 months free</span>
                </span>
              </div>
            </div>
          </div>
        </AnimatedSection>

        <div className="mt-12 hidden overflow-hidden rounded-[2rem] border border-border bg-card lg:block">
          <table className="w-full table-fixed border-collapse text-left">
            <caption className="sr-only">FitCheck plan and usage limit comparison</caption>
            <thead>
              <tr className="border-b border-border align-top">
                <th scope="col" className="w-[28%] px-7 py-8 text-sm font-semibold text-muted-foreground">
                  Plan comparison
                </th>
                {tiers.map((tier) => (
                  <th
                    key={tier.key}
                    scope="col"
                    className={cn(
                      'w-[24%] border-l border-border px-6 py-8',
                      tier.key === 'plus' && 'bg-primary/5'
                    )}
                  >
                    <p className="text-lg font-semibold text-foreground">{tier.name}</p>
                    <p className="mt-1 min-h-10 text-sm font-normal leading-relaxed text-muted-foreground">
                      {tier.description}
                    </p>
                    <div className="mt-5">
                      <Price plan={tier.key} isYearly={isYearly} />
                    </div>
                    <p className="mt-2 min-h-5 text-xs font-normal text-muted-foreground">
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
                <tr key={row.label} className="border-b border-border last:border-b-0">
                  <th scope="row" className="px-7 py-5 text-sm font-medium text-foreground">
                    {row.label}
                  </th>
                  {row.values.map((value, index) => (
                    <td
                      key={`${row.label}-${tiers[index].key}`}
                      className={cn(
                        'border-l border-border px-6 py-5 text-center text-sm text-body',
                        tiers[index].key === 'plus' && 'bg-primary/5'
                      )}
                    >
                      <ComparisonValue value={value} />
                    </td>
                  ))}
                </tr>
              ))}
              <tr>
                <th scope="row" className="px-7 py-6 text-sm font-medium text-foreground">
                  Next step
                </th>
                {tiers.map((tier) => (
                  <td
                    key={tier.key}
                    className={cn(
                      'border-l border-border px-6 py-6',
                      tier.key === 'plus' && 'bg-primary/5'
                    )}
                  >
                    <Button variant={tier.key === 'plus' ? 'default' : 'outline'} className="w-full" asChild>
                      <Link
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
                    </Button>
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

          <p className="mt-4 text-xs text-muted-foreground lg:hidden">Swipe to compare plans.</p>
        </div>

        <p className="mt-6 text-sm text-muted-foreground">
          No credit card is required for the free month. Cancel paid plans at any time.{' '}
          <a href="#faq" className="text-primary hover:text-primary-pressed">
            Read billing answers
          </a>
        </p>
      </div>
    </section>
  )
}
