import { Link } from 'react-router-dom'
import { ArrowRight } from 'lucide-react'

import { AnimatedSection } from './AnimatedSection'
import { SectionKicker } from './SectionKicker'

const steps = [
  {
    id: 'step-photograph',
    number: '01',
    verb: 'Photograph',
    title: 'Capture what you own',
    description:
      'Take photos of single pieces, a full rail, or a flat lay. The source image stays connected to the items it contains.',
    href: '/features/ai-wardrobe-extraction',
    linkLabel: 'See extraction',
  },
  {
    id: 'step-catalog',
    number: '02',
    verb: 'Catalog',
    title: 'Review the wardrobe record',
    description:
      'FitCheck proposes color, category, and style details. Review them before saving a searchable wardrobe.',
    href: '/features/wardrobe-analytics',
    linkLabel: 'See wardrobe analytics',
  },
  {
    id: 'step-wear',
    number: '03',
    verb: 'Wear',
    title: 'Decide with context',
    description:
      'Use the saved wardrobe for weather-aware recommendations, try-on, calendar planning, and photoshoot images.',
    href: '/features/outfit-recommendations',
    linkLabel: 'See outfit planning',
  },
]

export default function HowItWorks() {
  return (
    <section id="how-it-works" className="bg-surface-soft py-20 md:py-28">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <AnimatedSection className="reveal">
          <div className="grid gap-6 lg:grid-cols-12 lg:items-end">
            <div className="lg:col-span-7">
              <SectionKicker>Photograph → Catalog → Wear</SectionKicker>
              <h2 className="landing-display text-3xl font-semibold leading-tight text-foreground sm:text-4xl md:text-[2.75rem]">
                One sequence from camera roll to morning plan
              </h2>
            </div>
            <p className="max-w-xl text-base leading-relaxed text-body lg:col-span-5 lg:justify-self-end">
              Start with a few clothing photos. Keep control at the review step. Use the result across the product.
            </p>
          </div>
        </AnimatedSection>

        <ol className="mt-12 grid border-y border-border md:grid-cols-3">
          {steps.map((step, index) => (
            <li
              key={step.id}
              id={step.id}
              className="relative min-w-0 border-b border-border py-8 last:border-b-0 md:border-b-0 md:border-r md:px-8 md:last:border-r-0 md:first:pl-0 md:last:pr-0"
            >
              <AnimatedSection delay={index * 80} className="h-full">
                <div className="flex h-full flex-col">
                  <div className="flex items-center gap-3">
                    <span className="flex h-10 w-10 items-center justify-center rounded-full border border-primary text-xs font-semibold text-primary">
                      {step.number}
                    </span>
                    <span className="text-xs font-semibold uppercase tracking-[0.16em] text-muted-foreground">
                      {step.verb}
                    </span>
                  </div>
                  <h3 className="mt-6 text-xl font-semibold leading-snug text-foreground">{step.title}</h3>
                  <p className="mt-3 flex-1 text-sm leading-relaxed text-body sm:text-[15px]">
                    {step.description}
                  </p>
                  <Link
                    to={step.href}
                    className="mt-5 inline-flex min-h-11 items-center gap-2 text-sm font-medium text-primary hover:text-primary-pressed"
                  >
                    {step.linkLabel}
                    <ArrowRight className="h-4 w-4" aria-hidden="true" />
                  </Link>
                </div>
              </AnimatedSection>
            </li>
          ))}
        </ol>
      </div>
    </section>
  )
}
