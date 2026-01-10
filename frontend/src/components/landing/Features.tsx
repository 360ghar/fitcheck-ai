import { Badge } from '@/components/ui/badge'
import { AnimatedSection } from './AnimatedSection'
import { FeatureCard } from './FeatureCard'
import {
  Camera,
  Wand2,
  Sparkles,
  CloudSun,
  Calendar,
  BarChart3,
  Flame,
  Share2,
} from 'lucide-react'

const features = [
  {
    icon: Camera,
    title: 'AI Item Extraction',
    description:
      'Upload any photo and our AI automatically extracts and catalogs each clothing item with color, category, and style tags.',
    variant: 'gold' as const,
  },
  {
    icon: Wand2,
    title: 'Virtual Try-On',
    description:
      'See how outfits look before you wear them. Generate realistic visualizations of any outfit combination.',
    variant: 'navy' as const,
  },
  {
    icon: Sparkles,
    title: 'Smart Recommendations',
    description:
      'Get personalized outfit suggestions based on your style preferences, occasion, and wardrobe inventory.',
    variant: 'gold' as const,
  },
  {
    icon: CloudSun,
    title: 'Weather Integration',
    description:
      'Receive weather-appropriate outfit suggestions. Never be caught unprepared by the forecast again.',
    variant: 'navy' as const,
  },
  {
    icon: Calendar,
    title: 'Calendar Planning',
    description:
      'Plan your outfits for the week ahead. Sync with your calendar to dress appropriately for every event.',
    variant: 'navy' as const,
  },
  {
    icon: BarChart3,
    title: 'Wardrobe Analytics',
    description:
      'Track usage patterns, cost-per-wear metrics, and discover underutilized items in your closet.',
    variant: 'gold' as const,
  },
  {
    icon: Flame,
    title: 'Gamification',
    description:
      'Build outfit planning streaks, earn achievements, and complete style challenges to stay motivated.',
    variant: 'gold' as const,
  },
  {
    icon: Share2,
    title: 'Social Sharing',
    description:
      'Share your outfits with friends, get feedback, and discover inspiration from the community.',
    variant: 'navy' as const,
  },
]

export default function Features() {
  return (
    <section id="features" className="py-24 bg-navy-50 dark:bg-navy-900">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section header */}
        <AnimatedSection>
          <div className="text-center max-w-3xl mx-auto mb-16">
            <Badge variant="gold" className="mb-4">
              Features
            </Badge>
            <h2 className="text-3xl sm:text-4xl md:text-5xl font-display font-semibold text-navy-800 dark:text-white">
              Everything you need to{' '}
              <span className="text-gold-500 dark:text-gold-400">
                dress smarter
              </span>
            </h2>
            <p className="mt-4 text-lg md:text-xl text-navy-500 dark:text-navy-300">
              Powerful AI tools designed to transform your wardrobe experience
            </p>
          </div>
        </AnimatedSection>

        {/* Features grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          {features.map((feature, index) => (
            <AnimatedSection key={feature.title} delay={index * 100}>
              <FeatureCard {...feature} />
            </AnimatedSection>
          ))}
        </div>
      </div>
    </section>
  )
}
