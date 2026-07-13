import { Link } from 'react-router-dom'
import { AnimatedSection } from './AnimatedSection'
import {
  Camera,
  Wand2,
  Sparkles,
  ImageIcon,
  BarChart3,
  CloudSun,
  Calendar,
  ArrowUpRight,
} from 'lucide-react'
import { cn } from '@/lib/utils'

const primaryFeatures = [
  {
    icon: Camera,
    title: 'Item extraction',
    description: 'Upload a photo. FitCheck tags each piece with color, category, and style.',
    href: '/features/ai-wardrobe-extraction',
    span: 'md:col-span-4 md:row-span-2',
    image: '/landing/flatlay.jpg',
    imageAlt: 'Clothing flat lay ready for cataloging',
  },
  {
    icon: Wand2,
    title: 'Virtual try-on',
    description: 'Preview combinations on you before they hit the floor.',
    href: '/features/virtual-try-on',
    span: 'md:col-span-2',
  },
  {
    icon: Sparkles,
    title: 'Daily outfits',
    description: 'Suggestions that respect weather, occasion, and what you own.',
    href: '/features/outfit-recommendations',
    span: 'md:col-span-2',
  },
  {
    icon: ImageIcon,
    title: 'AI photoshoot',
    description: 'Studio-style looks from a single phone photo.',
    href: '/features/ai-photoshoot-generator',
    span: 'md:col-span-3',
  },
  {
    icon: BarChart3,
    title: 'Wardrobe analytics',
    description: 'See what you wear, what you ignore, and cost per wear.',
    href: '/features/wardrobe-analytics',
    span: 'md:col-span-3',
  },
]

const secondary = [
  { icon: CloudSun, title: 'Weather-aware picks' },
  { icon: Calendar, title: 'Calendar planning' },
]

export default function Features() {
  return (
    <section id="features" className="py-20 md:py-28 bg-stone-50 dark:bg-stone-900/40">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <AnimatedSection>
          <div className="max-w-2xl mb-12 md:mb-14">
            <h2 className="landing-display text-3xl sm:text-4xl md:text-[2.75rem] font-semibold text-stone-900 dark:text-stone-50 leading-tight">
              Tools that actually get you dressed
            </h2>
            <p className="mt-4 text-base md:text-lg text-stone-600 dark:text-stone-400">
              Five features that matter every morning. Everything else stays out of the way.
            </p>
          </div>
        </AnimatedSection>

        <div className="grid md:grid-cols-6 gap-4 md:gap-5 md:auto-rows-fr">
          {primaryFeatures.map((feature, index) => {
            const Icon = feature.icon
            const isHero = Boolean(feature.image)
            return (
              <AnimatedSection
                key={feature.title}
                delay={index * 60}
                className={cn(feature.span, 'h-full min-h-0 flex')}
              >
                <Link
                  to={feature.href}
                  className={cn(
                    'group relative flex w-full h-full flex-col overflow-hidden rounded-2xl border border-stone-200/90 bg-white transition-colors hover:border-indigo-300 dark:border-stone-800 dark:bg-stone-950 dark:hover:border-indigo-700',
                    isHero ? 'min-h-[280px] md:min-h-[360px]' : 'min-h-[160px] p-6'
                  )}
                >
                  {isHero && feature.image ? (
                    <>
                      <img
                        src={feature.image}
                        alt={feature.imageAlt}
                        className="absolute inset-0 h-full w-full object-cover transition-transform duration-500 group-hover:scale-[1.02]"
                        loading="lazy"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-stone-950 via-stone-950/55 to-stone-950/10" />
                      <div className="relative mt-auto p-6 md:p-8 text-white">
                        <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-lg bg-white/10 ring-1 ring-white/20">
                          <Icon className="h-5 w-5" />
                        </div>
                        <div className="flex items-start justify-between gap-3">
                          <h3 className="text-xl md:text-2xl font-semibold tracking-tight">
                            {feature.title}
                          </h3>
                          <ArrowUpRight className="h-5 w-5 shrink-0 opacity-70 transition group-hover:opacity-100" />
                        </div>
                        <p className="mt-2 text-sm md:text-base text-stone-200 max-w-md leading-relaxed">
                          {feature.description}
                        </p>
                      </div>
                    </>
                  ) : (
                    <>
                      <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-lg bg-indigo-50 text-indigo-600 dark:bg-indigo-950/60 dark:text-indigo-400">
                        <Icon className="h-5 w-5" />
                      </div>
                      <div className="flex items-start justify-between gap-2">
                        <h3 className="text-lg font-semibold text-stone-900 dark:text-stone-50">
                          {feature.title}
                        </h3>
                        <ArrowUpRight className="h-4 w-4 shrink-0 text-stone-400 transition group-hover:text-indigo-600 dark:group-hover:text-indigo-400" />
                      </div>
                      <p className="mt-2 text-sm text-stone-600 dark:text-stone-400 leading-relaxed">
                        {feature.description}
                      </p>
                    </>
                  )}
                </Link>
              </AnimatedSection>
            )
          })}
        </div>

        <AnimatedSection delay={200}>
          <ul className="mt-8 flex flex-wrap gap-x-8 gap-y-3 text-sm text-stone-600 dark:text-stone-400">
            {secondary.map((item) => (
              <li key={item.title} className="inline-flex items-center gap-2">
                <item.icon className="h-4 w-4 text-indigo-600 dark:text-indigo-400" />
                {item.title}
              </li>
            ))}
            <li className="text-stone-500">Plus streaks, sharing, and packing helpers in the app.</li>
          </ul>
        </AnimatedSection>
      </div>
    </section>
  )
}
