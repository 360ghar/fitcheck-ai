import { Badge } from '@/components/ui/badge'
import { Card, CardContent } from '@/components/ui/card'
import { AnimatedSection } from './AnimatedSection'
import { Star, Quote } from 'lucide-react'

const testimonials = [
  {
    quote:
      "FitCheck AI completely transformed my morning routine. I used to spend 20 minutes deciding what to wear - now it takes 2 minutes. The AI recommendations are surprisingly accurate!",
    author: 'Sarah Chen',
    role: 'Marketing Manager',
    rating: 5,
    initials: 'SC',
    gradient: 'from-pink-500 to-rose-500',
  },
  {
    quote:
      "As someone with a massive wardrobe, I was shocked to discover I only wore 20% of my clothes. FitCheck AI helped me rediscover forgotten pieces and create 50+ new outfit combinations.",
    author: 'Marcus Johnson',
    role: 'Creative Director',
    rating: 5,
    initials: 'MJ',
    gradient: 'from-blue-500 to-cyan-500',
  },
  {
    quote:
      "The virtual try-on feature is a game changer for my content creation. I can plan and visualize outfits before shooting. My engagement has increased by 40% since I started using it!",
    author: 'Priya Sharma',
    role: 'Fashion Influencer',
    rating: 5,
    initials: 'PS',
    gradient: 'from-purple-500 to-indigo-500',
  },
]

function TestimonialCard({
  quote,
  author,
  role,
  rating,
  initials,
  gradient,
}: (typeof testimonials)[0]) {
  return (
    <Card className="relative overflow-hidden border-0 bg-white dark:bg-gray-800 h-full">
      <CardContent className="p-6 md:p-8 flex flex-col h-full">
        {/* Quote icon */}
        <div className="mb-4">
          <Quote className="w-8 h-8 text-indigo-500/20" />
        </div>

        {/* Rating */}
        <div className="flex gap-1 mb-4">
          {Array.from({ length: rating }).map((_, i) => (
            <Star key={i} className="w-5 h-5 fill-yellow-400 text-yellow-400" />
          ))}
        </div>

        {/* Quote */}
        <p className="text-gray-600 dark:text-gray-300 flex-1 mb-6">{quote}</p>

        {/* Author */}
        <div className="flex items-center gap-3">
          <div
            className={`w-12 h-12 rounded-full bg-gradient-to-br ${gradient} flex items-center justify-center text-white font-bold`}
          >
            {initials}
          </div>
          <div>
            <p className="font-semibold text-gray-900 dark:text-white">{author}</p>
            <p className="text-sm text-gray-500 dark:text-gray-400">{role}</p>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

export default function Testimonials() {
  return (
    <section className="py-24 bg-gradient-to-b from-gray-50 to-white dark:from-gray-900 dark:to-gray-950">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="text-center mb-16">
            <Badge className="mb-4 bg-indigo-100 text-indigo-700 dark:bg-indigo-900/50 dark:text-indigo-300 border-0">
              Testimonials
            </Badge>
            <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-gray-900 dark:text-white">
              Loved by{' '}
              <span className="bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
                fashion-forward
              </span>{' '}
              people
            </h2>
            <p className="mt-4 text-lg md:text-xl text-gray-600 dark:text-gray-300">
              Join thousands who have transformed their daily dressing routine
            </p>
          </div>
        </AnimatedSection>

        <div className="grid md:grid-cols-3 gap-8">
          {testimonials.map((testimonial, index) => (
            <AnimatedSection key={testimonial.author} delay={index * 150}>
              <TestimonialCard {...testimonial} />
            </AnimatedSection>
          ))}
        </div>

        {/* Trust badges */}
        <AnimatedSection delay={500}>
          <div className="mt-16 text-center">
            <p className="text-sm text-gray-500 dark:text-gray-400 mb-6">Trusted by users from</p>
            <div className="flex items-center justify-center gap-8 md:gap-12 opacity-50 flex-wrap">
              {['Google', 'Apple', 'Meta', 'Amazon', 'Netflix'].map((company) => (
                <span
                  key={company}
                  className="text-xl md:text-2xl font-bold text-gray-400 dark:text-gray-600"
                >
                  {company}
                </span>
              ))}
            </div>
          </div>
        </AnimatedSection>
      </div>
    </section>
  )
}
