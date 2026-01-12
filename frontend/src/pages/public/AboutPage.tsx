import { Link } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent } from '@/components/ui/card'
import { AnimatedSection } from '@/components/landing/AnimatedSection'
import { ArrowRight, Heart, Shield, Sparkles, Users } from 'lucide-react'

const values = [
  {
    icon: Sparkles,
    title: 'Innovation First',
    description:
      'We push the boundaries of AI and fashion technology to create tools that genuinely improve your life.',
    gradient: 'from-gold-400 to-gold-600',
  },
  {
    icon: Users,
    title: 'User-Centric',
    description:
      'Every feature we build starts with understanding your needs. Your feedback shapes our roadmap.',
    gradient: 'from-navy-600 to-navy-800',
  },
  {
    icon: Shield,
    title: 'Privacy Matters',
    description:
      'Your wardrobe data is personal. We never sell your data and give you complete control over it.',
    gradient: 'from-navy-700 to-navy-900',
  },
  {
    icon: Heart,
    title: 'Sustainability',
    description:
      "By helping you use what you own, we're reducing fashion waste and promoting conscious consumption.",
    gradient: 'from-gold-500 to-gold-700',
  },
]

const stats = [
  { value: '10K+', label: 'Active Users' },
  { value: '500K+', label: 'Outfits Created' },
  { value: '2M+', label: 'Items Cataloged' },
  { value: '98%', label: 'User Satisfaction' },
]

export default function AboutPage() {
  return (
    <div className="pt-20">
      {/* Hero */}
      <section className="py-24 bg-gradient-to-br from-navy-50 via-white to-gold-50/30 dark:from-navy-950 dark:via-navy-900 dark:to-navy-950">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <AnimatedSection>
            <div className="text-center max-w-3xl mx-auto">
              <Badge variant="gold" className="mb-6">
                About Us
              </Badge>
              <h1 className="text-4xl sm:text-5xl md:text-6xl font-display font-semibold text-foreground mb-6">
                Making fashion{' '}
                <span className="bg-gradient-to-r from-gold-400 to-gold-600 bg-clip-text text-transparent">
                  effortless
                </span>
              </h1>
              <p className="text-lg md:text-xl text-muted-foreground">
                We believe everyone deserves to feel confident in what they wear. Our mission is to
                democratize personal styling through AI, making it accessible to everyone.
              </p>
            </div>
          </AnimatedSection>
        </div>
      </section>

      {/* Story */}
      <section className="py-24 bg-background">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <AnimatedSection>
              <div>
                <Badge variant="gold" className="mb-4">
                  Our Story
                </Badge>
                <h2 className="text-3xl md:text-4xl font-display font-semibold text-foreground mb-6">
                  Born from a simple frustration
                </h2>
                <div className="space-y-4 text-muted-foreground">
                  <p>
                    Like many people, our founders stood in front of overflowing closets every morning,
                    feeling like they had nothing to wear. Despite owning hundreds of clothing items,
                    they cycled through the same 10 outfits.
                  </p>
                  <p>
                    That's when the idea for FitCheck AI was born - what if AI could help you see your
                    wardrobe with fresh eyes? What if technology could unlock the hidden potential in
                    clothes you already own?
                  </p>
                  <p>
                    Today, FitCheck AI helps thousands of users rediscover their wardrobes, save time
                    getting dressed, and make smarter fashion choices. We're just getting started.
                  </p>
                </div>
              </div>
            </AnimatedSection>

            <AnimatedSection delay={200}>
              <div className="grid grid-cols-2 gap-4">
                {stats.map((stat) => (
                  <Card key={stat.label} className="border-0 bg-muted">
                    <CardContent className="p-6 text-center">
                      <p className="text-3xl md:text-4xl font-display font-semibold bg-gradient-to-r from-navy-700 to-navy-900 dark:from-gold-400 dark:to-gold-600 bg-clip-text text-transparent">
                        {stat.value}
                      </p>
                      <p className="text-muted-foreground mt-1">{stat.label}</p>
                    </CardContent>
                  </Card>
                ))}
              </div>
            </AnimatedSection>
          </div>
        </div>
      </section>

      {/* Values */}
      <section className="py-24 bg-muted/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <AnimatedSection>
            <div className="text-center mb-16">
              <Badge variant="gold" className="mb-4">
                Our Values
              </Badge>
              <h2 className="text-3xl md:text-4xl font-display font-semibold text-foreground">
                What drives us forward
              </h2>
            </div>
          </AnimatedSection>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {values.map((value, index) => (
              <AnimatedSection key={value.title} delay={index * 100}>
                <Card className="h-full border-0 bg-card">
                  <CardContent className="p-6">
                    <div
                      className={`w-12 h-12 rounded-xl flex items-center justify-center mb-4 bg-gradient-to-br ${value.gradient}`}
                    >
                      <value.icon className="w-6 h-6 text-white" />
                    </div>
                    <h3 className="text-lg font-semibold text-foreground mb-2">
                      {value.title}
                    </h3>
                    <p className="text-muted-foreground text-sm">{value.description}</p>
                  </CardContent>
                </Card>
              </AnimatedSection>
            ))}
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-24 bg-background">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <AnimatedSection>
            <div className="text-center">
              <h2 className="text-3xl md:text-4xl font-display font-semibold text-foreground mb-6">
                Ready to join our journey?
              </h2>
              <p className="text-lg text-muted-foreground mb-8 max-w-2xl mx-auto">
                Experience the future of personal styling. Start your free trial today.
              </p>
              <Button
                size="lg"
                variant="gold"
                className="text-lg px-8 py-6"
                asChild
              >
                <Link to="/auth/register">
                  Get Started
                  <ArrowRight className="ml-2 h-5 w-5" />
                </Link>
              </Button>
            </div>
          </AnimatedSection>
        </div>
      </section>
    </div>
  )
}
