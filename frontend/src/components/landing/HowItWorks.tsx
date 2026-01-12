import { Badge } from '@/components/ui/badge'
import { AnimatedSection } from './AnimatedSection'
import { GlassCard } from './GlassCard'
import { cn } from '@/lib/utils'
import { Upload, Cpu, Lightbulb, TrendingUp } from 'lucide-react'

const steps = [
  {
    step: 1,
    icon: Upload,
    title: 'Upload Your Wardrobe',
    description:
      'Snap photos of your clothes or upload from your gallery. Individual items or full outfit shots - our AI handles it all.',
    variant: 'gold' as const,
  },
  {
    step: 2,
    icon: Cpu,
    title: 'AI Organizes Everything',
    description:
      'Our AI automatically extracts items, detects colors, categories, and styles. Your entire wardrobe, digitized in minutes.',
    variant: 'navy' as const,
  },
  {
    step: 3,
    icon: Lightbulb,
    title: 'Get Daily Recommendations',
    description:
      'Receive personalized outfit suggestions based on weather, your calendar, and style preferences. Decision fatigue, solved.',
    variant: 'gold' as const,
  },
  {
    step: 4,
    icon: TrendingUp,
    title: 'Track & Improve',
    description:
      'Analyze your wardrobe usage, discover underutilized gems, and make smarter fashion decisions with data-driven insights.',
    variant: 'navy' as const,
  },
]

export default function HowItWorks() {
  return (
    <section id="how-it-works" className="py-24 bg-white dark:bg-navy-950">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="text-center mb-16">
            <Badge variant="gold" className="mb-4">
              How It Works
            </Badge>
            <h2 className="text-3xl sm:text-4xl md:text-5xl font-display font-semibold text-navy-800 dark:text-white">
              Get started in{' '}
              <span className="text-gold-500 dark:text-gold-400">
                minutes
              </span>
            </h2>
            <p className="mt-4 text-lg md:text-xl text-navy-500 dark:text-navy-300">
              Four simple steps to transform your wardrobe experience
            </p>
          </div>
        </AnimatedSection>

        <div className="space-y-16 md:space-y-24">
          {steps.map((step, index) => (
            <AnimatedSection key={step.step}>
              <div
                className={cn(
                  'grid lg:grid-cols-2 gap-8 md:gap-12 items-center',
                  index % 2 === 1 && 'lg:flex-row-reverse'
                )}
              >
                {/* Text side */}
                <div className={index % 2 === 1 ? 'lg:order-2' : ''}>
                  <div className="flex items-center gap-4 mb-4">
                    <span
                      className={cn(
                        'flex items-center justify-center w-12 h-12 rounded-full font-bold text-lg',
                        step.variant === 'gold'
                          ? 'bg-gradient-to-br from-gold-400 to-gold-600 text-navy-900'
                          : 'bg-navy-800 text-white dark:bg-navy-700'
                      )}
                    >
                      {step.step}
                    </span>
                    <div className="h-px flex-1 bg-gradient-to-r from-gold-400/50 to-transparent dark:from-gold-400/30" />
                  </div>
                  <h3 className="text-2xl md:text-3xl font-display font-semibold text-navy-800 dark:text-white mb-4">
                    {step.title}
                  </h3>
                  <p className="text-lg text-navy-500 dark:text-navy-300">{step.description}</p>
                </div>

                {/* Visual side */}
                <div className={index % 2 === 1 ? 'lg:order-1' : ''}>
                  <GlassCard className="p-6 md:p-8">
                    <div
                      className={cn(
                        'aspect-video rounded-xl flex items-center justify-center',
                        step.variant === 'gold'
                          ? 'bg-gradient-to-br from-gold-400 to-gold-600'
                          : 'bg-gradient-to-br from-navy-700 to-navy-900'
                      )}
                    >
                      <step.icon className={cn(
                        'w-16 h-16 md:w-24 md:h-24',
                        step.variant === 'gold' ? 'text-navy-900/80' : 'text-white/90'
                      )} />
                    </div>
                  </GlassCard>
                </div>
              </div>
            </AnimatedSection>
          ))}
        </div>
      </div>
    </section>
  )
}
