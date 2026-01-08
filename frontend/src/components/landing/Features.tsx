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
    gradient: 'from-blue-500 to-cyan-500',
  },
  {
    icon: Wand2,
    title: 'Virtual Try-On',
    description:
      'See how outfits look before you wear them. Generate realistic visualizations of any outfit combination.',
    gradient: 'from-purple-500 to-pink-500',
  },
  {
    icon: Sparkles,
    title: 'Smart Recommendations',
    description:
      'Get personalized outfit suggestions based on your style preferences, occasion, and wardrobe inventory.',
    gradient: 'from-yellow-500 to-orange-500',
  },
  {
    icon: CloudSun,
    title: 'Weather Integration',
    description:
      'Receive weather-appropriate outfit suggestions. Never be caught unprepared by the forecast again.',
    gradient: 'from-sky-500 to-blue-500',
  },
  {
    icon: Calendar,
    title: 'Calendar Planning',
    description:
      'Plan your outfits for the week ahead. Sync with your calendar to dress appropriately for every event.',
    gradient: 'from-green-500 to-teal-500',
  },
  {
    icon: BarChart3,
    title: 'Wardrobe Analytics',
    description:
      'Track usage patterns, cost-per-wear metrics, and discover underutilized items in your closet.',
    gradient: 'from-violet-500 to-purple-500',
  },
  {
    icon: Flame,
    title: 'Gamification',
    description:
      'Build outfit planning streaks, earn achievements, and complete style challenges to stay motivated.',
    gradient: 'from-red-500 to-orange-500',
  },
  {
    icon: Share2,
    title: 'Social Sharing',
    description:
      'Share your outfits with friends, get feedback, and discover inspiration from the community.',
    gradient: 'from-indigo-500 to-blue-500',
  },
]

export default function Features() {
  return (
    <section id="features" className="py-24 bg-gray-50 dark:bg-gray-900">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section header */}
        <AnimatedSection>
          <div className="text-center max-w-3xl mx-auto mb-16">
            <Badge className="mb-4 bg-indigo-100 text-indigo-700 dark:bg-indigo-900/50 dark:text-indigo-300 border-0">
              Features
            </Badge>
            <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-gray-900 dark:text-white">
              Everything you need to{' '}
              <span className="bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
                dress smarter
              </span>
            </h2>
            <p className="mt-4 text-lg md:text-xl text-gray-600 dark:text-gray-300">
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
