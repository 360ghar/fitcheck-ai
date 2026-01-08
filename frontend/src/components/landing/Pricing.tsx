import { useState } from 'react'
import { Link } from 'react-router-dom'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card'
import { Switch } from '@/components/ui/switch'
import { AnimatedSection } from './AnimatedSection'
import { Check } from 'lucide-react'
import { cn } from '@/lib/utils'

const tiers = [
  {
    name: 'Free',
    price: { monthly: 0, yearly: 0 },
    description: 'Perfect for getting started',
    features: [
      'Up to 50 clothing items',
      '5 AI generations/month',
      'Basic wardrobe management',
      'Weather-based suggestions',
      'Mobile app access',
    ],
    cta: 'Get Started Free',
    highlighted: false,
  },
  {
    name: 'Pro',
    price: { monthly: 9.99, yearly: 89.99 },
    description: 'For the fashion-forward',
    features: [
      'Unlimited clothing items',
      'Unlimited AI generations',
      'Virtual try-on visualization',
      'Advanced wardrobe analytics',
      'Calendar integration',
      'Priority support',
      'Style recommendations',
      'Social sharing features',
    ],
    cta: 'Start Free Trial',
    highlighted: true,
    badge: 'Most Popular',
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
    <Card
      className={cn(
        'relative overflow-hidden h-full',
        highlighted && 'border-2 border-indigo-600 shadow-xl shadow-indigo-500/10'
      )}
    >
      {badge && (
        <div className="absolute top-0 right-0 bg-gradient-to-r from-indigo-600 to-purple-600 text-white px-4 py-1 text-sm font-medium rounded-bl-lg">
          {badge}
        </div>
      )}

      <CardHeader>
        <CardTitle className="text-2xl">{name}</CardTitle>
        <CardDescription>{description}</CardDescription>
      </CardHeader>

      <CardContent className="space-y-6">
        <div>
          <span className="text-5xl font-bold text-gray-900 dark:text-white">
            ${displayPrice.toFixed(displayPrice % 1 === 0 ? 0 : 2)}
          </span>
          {displayPrice > 0 && (
            <span className="text-gray-500 dark:text-gray-400">/{isYearly ? 'year' : 'month'}</span>
          )}
        </div>

        <ul className="space-y-3">
          {features.map((feature) => (
            <li key={feature} className="flex items-start gap-3">
              <Check className="w-5 h-5 text-green-500 shrink-0 mt-0.5" />
              <span className="text-gray-600 dark:text-gray-300">{feature}</span>
            </li>
          ))}
        </ul>

        <Button
          className={cn(
            'w-full',
            highlighted &&
              'bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700'
          )}
          variant={highlighted ? 'default' : 'outline'}
          size="lg"
          asChild
        >
          <Link to="/auth/register">{cta}</Link>
        </Button>
      </CardContent>
    </Card>
  )
}

export default function Pricing() {
  const [isYearly, setIsYearly] = useState(false)

  return (
    <section id="pricing" className="py-24 bg-white dark:bg-gray-950">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="text-center mb-16">
            <Badge className="mb-4 bg-indigo-100 text-indigo-700 dark:bg-indigo-900/50 dark:text-indigo-300 border-0">
              Pricing
            </Badge>
            <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4">
              Simple,{' '}
              <span className="bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
                transparent
              </span>{' '}
              pricing
            </h2>
            <p className="text-lg md:text-xl text-gray-600 dark:text-gray-300 mb-8">
              Start free, upgrade when you need more
            </p>

            {/* Toggle */}
            <div className="flex items-center justify-center gap-4">
              <span
                className={cn(
                  'font-medium transition-colors',
                  !isYearly ? 'text-gray-900 dark:text-white' : 'text-gray-500'
                )}
              >
                Monthly
              </span>
              <Switch checked={isYearly} onCheckedChange={setIsYearly} />
              <span
                className={cn(
                  'font-medium transition-colors flex items-center gap-2',
                  isYearly ? 'text-gray-900 dark:text-white' : 'text-gray-500'
                )}
              >
                Yearly
                <Badge className="bg-green-100 text-green-700 dark:bg-green-900/50 dark:text-green-300 border-0">
                  Save 25%
                </Badge>
              </span>
            </div>
          </div>
        </AnimatedSection>

        <div className="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
          {tiers.map((tier, index) => (
            <AnimatedSection key={tier.name} delay={index * 150}>
              <PricingCard {...tier} isYearly={isYearly} />
            </AnimatedSection>
          ))}
        </div>

        <AnimatedSection delay={400}>
          <p className="text-center text-gray-500 dark:text-gray-400 mt-8">
            No credit card required. Cancel anytime.
          </p>
        </AnimatedSection>
      </div>
    </section>
  )
}
