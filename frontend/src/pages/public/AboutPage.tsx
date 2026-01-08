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
    gradient: 'from-purple-500 to-pink-500',
  },
  {
    icon: Users,
    title: 'User-Centric',
    description:
      'Every feature we build starts with understanding your needs. Your feedback shapes our roadmap.',
    gradient: 'from-blue-500 to-cyan-500',
  },
  {
    icon: Shield,
    title: 'Privacy Matters',
    description:
      'Your wardrobe data is personal. We never sell your data and give you complete control over it.',
    gradient: 'from-green-500 to-teal-500',
  },
  {
    icon: Heart,
    title: 'Sustainability',
    description:
      "By helping you use what you own, we're reducing fashion waste and promoting conscious consumption.",
    gradient: 'from-red-500 to-orange-500',
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
      <section className="py-24 bg-gradient-to-br from-indigo-50 via-white to-purple-50 dark:from-gray-950 dark:via-gray-900 dark:to-indigo-950">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <AnimatedSection>
            <div className="text-center max-w-3xl mx-auto">
              <Badge className="mb-6 bg-indigo-100 text-indigo-700 dark:bg-indigo-900/50 dark:text-indigo-300 border-0">
                About Us
              </Badge>
              <h1 className="text-4xl sm:text-5xl md:text-6xl font-bold text-gray-900 dark:text-white mb-6">
                Making fashion{' '}
                <span className="bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
                  effortless
                </span>
              </h1>
              <p className="text-lg md:text-xl text-gray-600 dark:text-gray-300">
                We believe everyone deserves to feel confident in what they wear. Our mission is to
                democratize personal styling through AI, making it accessible to everyone.
              </p>
            </div>
          </AnimatedSection>
        </div>
      </section>

      {/* Story */}
      <section className="py-24 bg-white dark:bg-gray-950">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <AnimatedSection>
              <div>
                <Badge className="mb-4 bg-indigo-100 text-indigo-700 dark:bg-indigo-900/50 dark:text-indigo-300 border-0">
                  Our Story
                </Badge>
                <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-6">
                  Born from a simple frustration
                </h2>
                <div className="space-y-4 text-gray-600 dark:text-gray-300">
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
                  <Card key={stat.label} className="border-0 bg-gray-50 dark:bg-gray-800">
                    <CardContent className="p-6 text-center">
                      <p className="text-3xl md:text-4xl font-bold bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
                        {stat.value}
                      </p>
                      <p className="text-gray-600 dark:text-gray-400 mt-1">{stat.label}</p>
                    </CardContent>
                  </Card>
                ))}
              </div>
            </AnimatedSection>
          </div>
        </div>
      </section>

      {/* Values */}
      <section className="py-24 bg-gray-50 dark:bg-gray-900">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <AnimatedSection>
            <div className="text-center mb-16">
              <Badge className="mb-4 bg-indigo-100 text-indigo-700 dark:bg-indigo-900/50 dark:text-indigo-300 border-0">
                Our Values
              </Badge>
              <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white">
                What drives us forward
              </h2>
            </div>
          </AnimatedSection>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {values.map((value, index) => (
              <AnimatedSection key={value.title} delay={index * 100}>
                <Card className="h-full border-0 bg-white dark:bg-gray-800">
                  <CardContent className="p-6">
                    <div
                      className={`w-12 h-12 rounded-xl flex items-center justify-center mb-4 bg-gradient-to-br ${value.gradient}`}
                    >
                      <value.icon className="w-6 h-6 text-white" />
                    </div>
                    <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
                      {value.title}
                    </h3>
                    <p className="text-gray-600 dark:text-gray-400 text-sm">{value.description}</p>
                  </CardContent>
                </Card>
              </AnimatedSection>
            ))}
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-24 bg-white dark:bg-gray-950">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <AnimatedSection>
            <div className="text-center">
              <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white mb-6">
                Ready to join our journey?
              </h2>
              <p className="text-lg text-gray-600 dark:text-gray-300 mb-8 max-w-2xl mx-auto">
                Experience the future of personal styling. Start your free trial today.
              </p>
              <Button
                size="lg"
                className="bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 text-lg px-8 py-6"
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
