import { Link } from 'react-router-dom'
import {
  ArrowUpRight,
  BarChart3,
  Calendar,
  Camera,
  CloudSun,
  Eye,
  Images,
  Tags,
} from 'lucide-react'

import { AnimatedSection } from './AnimatedSection'
import { SectionKicker } from './SectionKicker'
import { cn } from '@/lib/utils'

type VerbTone = 'coral' | 'amber' | 'teal' | 'violet' | 'blue'

// Literal class map: Tailwind's JIT needs complete class names at scan time.
const VERB_TONE: Record<VerbTone, string> = {
  coral: 'text-tint-coral',
  amber: 'text-tint-amber',
  teal: 'text-tint-teal',
  violet: 'text-tint-violet',
  blue: 'text-tint-blue',
}

const capabilities: Array<{
  number: string
  verb: string
  title: string
  description: string
  href: string
  icon: typeof Tags
  tone: VerbTone
}> = [
  {
    number: '01',
    verb: 'Catalog',
    title: 'Turn clothing photos into a searchable wardrobe',
    description:
      'Extract color, category, and style details from single items, full hangs, and flat lays. Review the result before it enters your closet.',
    href: '/features/ai-wardrobe-extraction',
    icon: Tags,
    tone: 'teal',
  },
  {
    number: '02',
    verb: 'Plan',
    title: 'Build outfits around weather and occasion',
    description:
      'Use clothes you already own to plan daily looks and calendar-ready outfits for the conditions ahead.',
    href: '/features/outfit-recommendations',
    icon: CloudSun,
    tone: 'blue',
  },
  {
    number: '03',
    verb: 'Preview',
    title: 'See combinations on you before you commit',
    description:
      'Use virtual try-on to compare wardrobe combinations before changing clothes or buying something new.',
    href: '/features/virtual-try-on',
    icon: Eye,
    tone: 'violet',
  },
  {
    number: '04',
    verb: 'Create',
    title: 'Produce studio-style images from one selfie',
    description:
      'Choose wardrobe pieces and a setting for LinkedIn, dating, social, or portfolio images.',
    href: '/features/ai-photoshoot-generator',
    icon: Camera,
    tone: 'coral',
  },
  {
    number: '05',
    verb: 'Understand',
    title: 'See what earns a place in your wardrobe',
    description:
      'Review wear patterns, underused items, wardrobe gaps, and cost per wear before the next purchase.',
    href: '/features/wardrobe-analytics',
    icon: BarChart3,
    tone: 'amber',
  },
]

const alsoInApp = [
  {
    title: 'Bulk and Instagram import',
    body: 'Move many clothing photos into one review queue. Instagram import appears where enabled.',
  },
  {
    title: 'Calendar week planning',
    body: 'Assign outfits to events and prepare the week before the morning rush.',
  },
  {
    title: 'Trip packing lists',
    body: 'Build packing lists from your real wardrobe for the destination and weather.',
  },
  {
    title: 'Outfit sharing and feedback',
    body: 'Share a look by link and collect feedback before you wear it.',
  },
  {
    title: 'Gaps and smarter shopping',
    body: 'Find wardrobe gaps so new purchases solve a real need.',
  },
  {
    title: 'Referrals',
    body: 'Invite a friend. Both accounts receive one month of Pro when they join.',
  },
]

const secondaryLinks = [
  { icon: CloudSun, title: 'Weather-aware picks', href: '/features/outfit-recommendations' },
  { icon: Calendar, title: 'Calendar planning', href: '/features' },
  { icon: Images, title: 'All product features', href: '/features' },
]

export default function Features() {
  return (
    <section id="features" className="scroll-mt-16 bg-background py-20 md:py-28">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 gap-12 lg:grid-cols-12 lg:gap-16">
          <AnimatedSection className="reveal min-w-0 lg:col-span-4">
            <div className="lg:sticky lg:top-24">
              <SectionKicker tone="violet">Capability ledger</SectionKicker>
              <h2 className="landing-display text-3xl font-semibold leading-tight text-foreground sm:text-4xl md:text-[2.75rem]">
                One wardrobe record. Five useful decisions.
              </h2>
              <p className="mt-4 max-w-md text-base leading-relaxed text-body md:text-lg">
                FitCheck keeps the source clothes, the outfit context, and the result connected.
                Each capability builds on the same private wardrobe.
              </p>
              <Link
                to="/features"
                className="mt-6 inline-flex min-h-11 items-center gap-1.5 text-sm font-medium text-primary hover:text-primary-pressed"
              >
                Review every feature
                <ArrowUpRight className="h-4 w-4" aria-hidden="true" />
              </Link>
            </div>
          </AnimatedSection>

          <div className="min-w-0 border-t border-border lg:col-span-8">
            {capabilities.map((capability, index) => (
              <AnimatedSection key={capability.verb} delay={index * 60}>
                <Link
                  to={capability.href}
                  className="group grid min-w-0 grid-cols-[2.5rem_minmax(0,1fr)] gap-x-4 gap-y-3 border-b border-border py-7 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 sm:grid-cols-[3rem_8rem_minmax(0,1fr)_1.5rem] sm:items-start sm:gap-x-5 sm:py-8"
                >
                  <span className="text-xs font-semibold text-muted-foreground">{capability.number}</span>
                  <span className={cn('flex items-center gap-2 text-sm font-semibold', VERB_TONE[capability.tone])}>
                    <capability.icon className="h-4 w-4" aria-hidden="true" />
                    {capability.verb}
                  </span>
                  <span className="col-start-2 min-w-0 sm:col-start-3">
                    <span className="block text-lg font-semibold leading-snug text-foreground group-hover:text-primary sm:text-xl">
                      {capability.title}
                    </span>
                    <span className="mt-2 block text-sm leading-relaxed text-muted-foreground sm:text-[15px]">
                      {capability.description}
                    </span>
                  </span>
                  <ArrowUpRight
                    className="col-start-2 h-4 w-4 text-muted-foreground transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-primary sm:col-start-4 sm:row-start-1"
                    aria-hidden="true"
                  />
                </Link>
              </AnimatedSection>
            ))}
          </div>
        </div>

        <div id="also-in-app" className="mt-20 scroll-mt-24 border-t border-border pt-14 md:mt-28 md:pt-16">
          <AnimatedSection className="reveal">
            <div className="grid gap-4 md:grid-cols-12 md:items-end">
              <div className="md:col-span-5">
                <p className="text-xs font-semibold uppercase tracking-[0.16em] text-primary">
                  Also in the app
                </p>
                <h3 className="landing-display mt-3 text-2xl font-semibold text-foreground sm:text-3xl">
                  The operational details are covered
                </h3>
              </div>
              <p className="max-w-2xl text-sm leading-relaxed text-muted-foreground md:col-span-7 md:justify-self-end md:text-base">
                Import, schedule, pack, share, and make buying decisions without moving the wardrobe record between tools.
              </p>
            </div>
          </AnimatedSection>

          <div className="mt-10 grid gap-x-8 sm:grid-cols-2 lg:grid-cols-3">
            {alsoInApp.map((item, index) => (
              <AnimatedSection key={item.title} delay={index * 40}>
                <div className="h-full border-t border-border py-6">
                  <h4 className="text-base font-semibold text-foreground">{item.title}</h4>
                  <p className="mt-2 text-sm leading-relaxed text-muted-foreground">{item.body}</p>
                </div>
              </AnimatedSection>
            ))}
          </div>

          <ul className="mt-4 flex flex-wrap gap-x-8 gap-y-2 text-sm">
            {secondaryLinks.map((item) => (
              <li key={item.title}>
                <Link
                  to={item.href}
                  className="inline-flex min-h-11 items-center gap-2 text-body transition-colors hover:text-primary"
                >
                  <item.icon className="h-4 w-4 text-primary" aria-hidden="true" />
                  {item.title}
                </Link>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  )
}
