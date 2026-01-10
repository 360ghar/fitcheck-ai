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
        highlighted && 'border-2 border-gold-400 shadow-xl shadow-gold-500/10'
      )}
    >
      {badge && (
        <div className="absolute top-0 right-0 bg-gradient-to-r from-gold-400 to-gold-600 text-navy-900 px-4 py-1 text-sm font-medium rounded-bl-lg">
          {badge}
        </div>
      )}

      <CardHeader>
        <CardTitle className="text-2xl">{name}</CardTitle>
        <CardDescription>{description}</CardDescription>
      </CardHeader>

      <CardContent className="space-y-6">
        <div>
          <span className="text-5xl font-display font-semibold text-foreground">
            ${displayPrice.toFixed(displayPrice % 1 === 0 ? 0 : 2)}
          </span>
          {displayPrice > 0 && (
            <span className="text-muted-foreground">/{isYearly ? 'year' : 'month'}</span>
          )}
        </div>

        <ul className="space-y-3">
          {features.map((feature) => (
            <li key={feature} className="flex items-start gap-3">
              <Check className="w-5 h-5 text-gold-500 shrink-0 mt-0.5" />
              <span className="text-muted-foreground">{feature}</span>
            </li>
          ))}
        </ul>

        <Button
          className="w-full"
          variant={highlighted ? 'gold' : 'outline'}
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
    <section id="pricing" className="py-24 bg-background">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="text-center mb-16">
            <Badge variant="gold" className="mb-4">
              Pricing
            </Badge>
            <h2 className="text-3xl sm:text-4xl md:text-5xl font-display font-semibold text-foreground mb-4">
              Simple,{' '}
              <span className="bg-gradient-to-r from-gold-400 to-gold-600 bg-clip-text text-transparent">
                transparent
              </span>{' '}
              pricing
            </h2>
            <p className="text-lg md:text-xl text-muted-foreground mb-8">
              Start free, upgrade when you need more
            </p>

            {/* Toggle */}
            <div className="flex items-center justify-center gap-4">
              <span
                className={cn(
                  'font-medium transition-colors',
                  !isYearly ? 'text-foreground' : 'text-muted-foreground'
                )}
              >
                Monthly
              </span>
              <Switch checked={isYearly} onCheckedChange={setIsYearly} />
              <span
                className={cn(
                  'font-medium transition-colors flex items-center gap-2',
                  isYearly ? 'text-foreground' : 'text-muted-foreground'
                )}
              >
                Yearly
                <Badge variant="gold">
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
          <p className="text-center text-muted-foreground mt-8">
            No credit card required. Cancel anytime.
          </p>
        </AnimatedSection>
      </div>
    </section>
  )
}
