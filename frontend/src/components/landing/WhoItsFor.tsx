import { Link } from 'react-router-dom'
import { ArrowRight, ArrowUpRight, LockKeyhole, ShieldCheck, Trash2 } from 'lucide-react'
import { cn } from '@/lib/utils'

import { AnimatedSection } from './AnimatedSection'
import { SectionKicker } from './SectionKicker'

type FactTone = 'coral' | 'teal' | 'blue'

// Literal class map: Tailwind's JIT needs complete class names at scan time.
const FACT_TILE: Record<FactTone, string> = {
  coral: 'bg-tint-coral-pale text-tint-coral',
  teal: 'bg-tint-teal-pale text-tint-teal',
  blue: 'bg-tint-blue-pale text-tint-blue',
}

const privacyFacts: Array<{
  icon: typeof ShieldCheck
  title: string
  body: string
  tone: FactTone
}> = [
  {
    icon: ShieldCheck,
    title: 'Private image storage',
    body: 'Wardrobe images use private storage with account ownership checks for reads and writes.',
    tone: 'teal',
  },
  {
    icon: LockKeyhole,
    title: 'Protected transfer and storage',
    body: 'Photos and wardrobe data are encrypted in transit and at rest.',
    tone: 'blue',
  },
  {
    icon: Trash2,
    title: 'Account data deletion',
    body: 'Account deletion removes profile, wardrobe, and stored image data tied to the account.',
    tone: 'coral',
  },
]

const personas = [
  {
    title: 'Busy professionals',
    body: 'Plan weather-aware workday outfits from the wardrobe you already own.',
    href: '/for/busy-professionals',
  },
  {
    title: 'Content creators',
    body: 'Plan looks and produce studio-style images for a content schedule.',
    href: '/for/content-creators',
  },
  {
    title: 'Festive and wedding guests',
    body: 'Catalog occasion wear and prepare combinations before the next invitation.',
    href: '/for/festive-and-wedding-outfits',
  },
]

export default function WhoItsFor() {
  return (
    <section id="who-its-for" className="bg-background py-20 md:py-28">
      <div className="mx-auto grid max-w-7xl grid-cols-1 gap-14 px-4 sm:px-6 lg:grid-cols-12 lg:gap-16 lg:px-8">
        <AnimatedSection className="reveal min-w-0 lg:col-span-5">
          <SectionKicker tone="blue">Privacy + use cases</SectionKicker>
          <h2 className="landing-display max-w-xl text-3xl font-semibold leading-tight text-foreground sm:text-4xl md:text-[2.75rem]">
            Personal photos need clear boundaries
          </h2>
          <p className="mt-4 max-w-xl text-base leading-relaxed text-body">
            Review how wardrobe data is stored, protected, and removed before you upload a personal photo.
          </p>

          <dl className="mt-8 border-t border-border">
            {privacyFacts.map((fact) => (
              <div key={fact.title} className="grid grid-cols-[2.5rem_minmax(0,1fr)] gap-4 border-b border-border py-5">
                <span
                  className={cn(
                    'flex h-10 w-10 items-center justify-center rounded-2xl border border-border',
                    FACT_TILE[fact.tone]
                  )}
                >
                  <fact.icon className="h-4 w-4" aria-hidden="true" />
                </span>
                <div>
                  <dt className="text-sm font-semibold text-foreground">{fact.title}</dt>
                  <dd className="mt-1 text-sm leading-relaxed text-muted-foreground">{fact.body}</dd>
                </div>
              </div>
            ))}
          </dl>

          <Link
            to="/privacy"
            className="mt-6 inline-flex min-h-11 items-center gap-2 text-sm font-medium text-primary hover:text-primary-pressed"
          >
            Read the Privacy Policy
            <ArrowRight className="h-4 w-4" aria-hidden="true" />
          </Link>
        </AnimatedSection>

        <div className="min-w-0 lg:col-span-7">
          <AnimatedSection className="reveal">
            <p className="text-xs font-semibold uppercase tracking-[0.16em] text-muted-foreground">
              Workflows by audience
            </p>
          </AnimatedSection>
          <div className="mt-4 border-t border-border">
            {personas.map((persona, index) => (
              <AnimatedSection key={persona.title} delay={index * 60}>
                <Link
                  to={persona.href}
                  className="group grid min-w-0 grid-cols-[minmax(0,1fr)_1.5rem] gap-5 border-b border-border py-7 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 sm:py-9"
                >
                  <span>
                    <span className="block text-xl font-semibold text-foreground group-hover:text-primary sm:text-2xl">
                      {persona.title}
                    </span>
                    <span className="mt-2 block max-w-xl text-sm leading-relaxed text-body sm:text-base">
                      {persona.body}
                    </span>
                  </span>
                  <ArrowUpRight
                    className="h-5 w-5 text-muted-foreground transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-primary"
                    aria-hidden="true"
                  />
                </Link>
              </AnimatedSection>
            ))}
          </div>
        </div>
      </div>
    </section>
  )
}
