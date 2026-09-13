import { Link } from 'react-router-dom'
import { ArrowRight } from 'lucide-react'

import { AnimatedSection } from './AnimatedSection'
import { SectionKicker } from './SectionKicker'
import { GeneratedImage } from '@/components/ui/generated-image'

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
    image: {
      src: '/generated/howitworks-wardrobe-4x3-640.webp',
      srcSet:
        '/generated/howitworks-wardrobe-4x3-640.webp 640w, /generated/howitworks-wardrobe-4x3.webp 1152w',
      alt: 'Phone beside folded wardrobe clothes on linen',
    },
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
    image: {
      src: '/generated/primitive-catalog-640.webp',
      srcSet:
        '/generated/primitive-catalog-640.webp 640w, /generated/primitive-catalog.webp 1024w',
      alt: 'Clay garments arranging themselves into a tidy catalog of cards',
    },
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
    image: {
      src: '/generated/primitive-preview-640.webp',
      srcSet:
        '/generated/primitive-preview-640.webp 640w, /generated/primitive-preview.webp 1024w',
      alt: 'Clay mirror showing the silhouette of a planned outfit',
    },
  },
]

export default function HowItWorks() {
  return (
    <section id="how-it-works" className="bg-surface-room py-20 md:py-28">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <AnimatedSection className="reveal">
          <div className="grid gap-6 lg:grid-cols-12 lg:items-end">
            <div className="lg:col-span-7">
              <SectionKicker tone="teal">Photograph → Catalog → Wear</SectionKicker>
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
                    {/* Pressed clay coin: the step number is stamped in, not
                        outlined — the section's one tinted room carries it. */}
                    <span className="flex h-10 w-10 items-center justify-center rounded-full border border-border bg-card text-xs font-semibold text-primary shadow-pressed">
                      {step.number}
                    </span>
                    <span className="text-xs font-semibold uppercase tracking-[0.16em] text-muted-foreground">
                      {step.verb}
                    </span>
                  </div>
                  <h3 className="mt-6 text-xl font-semibold leading-snug text-foreground">{step.title}</h3>
                  {'image' in step && step.image ? (
                    <div className="mt-5 overflow-hidden rounded-2xl border border-border bg-card shadow-pressed">
                      <GeneratedImage
                        src={step.image.src}
                        srcSet={step.image.srcSet}
                        sizes="(min-width: 768px) 28vw, calc(100vw - 32px)"
                        alt={step.image.alt}
                        className="aspect-[4/3] h-full w-full object-cover"
                        loading="lazy"
                        decoding="async"
                        fallback="hide-parent"
                      />
                    </div>
                  ) : null}
                  <p className="mt-3 flex-1 text-sm leading-relaxed text-body sm:text-[15px]">
                    {step.description}
                  </p>
                  <Link
                    to={step.href}
                    className="group/link mt-5 inline-flex min-h-11 items-center gap-2 text-sm font-medium text-primary hover:text-primary-pressed"
                  >
                    {step.linkLabel}
                    <ArrowRight
                      className="h-4 w-4 transition-transform duration-150 group-hover/link:translate-x-0.5"
                      aria-hidden="true"
                    />
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
