import type { CSSProperties } from 'react'
import { Link } from 'react-router-dom'

import StoreBadges from '@/components/landing/StoreBadges'
import { GeneratedImage } from '@/components/ui/generated-image'
import { trackEvent } from '@/lib/analytics'
import { trialRegisterHref, TRIAL_PROMO_CODE } from '@/lib/trial-offer'

import { SIGNATURE_ITEMS, cutoutStart } from './signature-data'

const STEPS = [
  {
    id: 'step-photograph',
    title: 'Photograph',
    body: 'One photo of a pile. FitCheck found six pieces in it.',
  },
  {
    id: 'step-catalog',
    title: 'Catalog',
    body: 'Each piece cut out, named and colour-tagged. You check it before it saves.',
  },
  {
    id: 'step-wear',
    title: 'Wear',
    body: 'Today is 24° and clear: the tee, the trousers, the white sneakers.',
  },
]

/**
 * The landing signature, "Snap your closet once".
 *
 * Default render (no JS, reduced motion, Firefox, the prerender, phones) is
 * the finished frame: the photo, the six cut-outs in a closet grid, and the
 * outfit. On wide screens with scroll timelines, the section grows tall, the
 * stage sticks, and the same elements play the pipeline from the start
 * frame (the big photo) to the end frame. Transform-only; see `.sig-*` in
 * index.css. Data and provenance: ./signature-data.ts.
 */
export default function Hero() {
  return (
    <section
      id="how-it-works"
      aria-labelledby="landing-hero-heading"
      className="sig paper-section stock-moss"
    >
      <div className="sig-top sig-frame px-4 sm:px-6 lg:px-8">
        <div className="sig-head">
          <h1 id="landing-hero-heading" className="sig-title paper-display text-paper-text">
            Snap your closet once.
          </h1>
          <div className="sig-pitch">
            <p className="text-base leading-relaxed text-paper-text-2 sm:text-[17px]">
              Photograph a pile of clothes. FitCheck cuts out every piece, labels it, files it,
              then dresses you from it.
            </p>
            <div className="mt-5 flex flex-wrap items-center gap-x-4 gap-y-3">
              <Link
                to={trialRegisterHref()}
                className="paper-btn"
                onClick={() =>
                  trackEvent('landing_cta_click', { location: 'hero', promo: TRIAL_PROMO_CODE })
                }
              >
                Start free
              </Link>
              <p className="text-sm text-paper-text-2">First month of Pro free. No card.</p>
            </div>
            <StoreBadges location="hero" className="mt-4" />
          </div>
        </div>
      </div>

      <div className="sig-track">
        <div className="sig-sticky sig-frame px-4 sm:px-6 lg:px-8">
          <div className="sig-stage">
            <div className="sig-canvas">
              <figure className="sig-photo paper-sheet">
                <GeneratedImage
                  src="/signature/pile-800.webp"
                  srcSet="/signature/pile-800.webp 800w, /signature/pile-1200.webp 1200w, /signature/pile-1600.webp 1600w"
                  sizes="(min-width: 768px) 640px, calc(100vw - 32px)"
                  alt="A phone photo of six clothes on a bed: a denim jacket, a white t-shirt, a striped top, a mustard sweater, rust trousers and white sneakers"
                  width={1600}
                  height={1200}
                  decoding="async"
                  fallback="hide-figure"
                  {...{ fetchpriority: 'high' }}
                />
              </figure>

              <ul className="sig-grid" aria-label="Pieces FitCheck found in the photo">
                {SIGNATURE_ITEMS.map((item, index) => {
                  const start = cutoutStart(item, index)
                  return (
                    <li
                      key={item.key}
                      className={`sig-cell paper-sheet${item.inOutfit ? ' sig-picked' : ''}`}
                      style={
                        {
                          '--dx': `${start.dx}cqw`,
                          '--dy': `${start.dy}cqw`,
                          '--s': start.scale,
                          '--i': index,
                        } as CSSProperties
                      }
                    >
                      <GeneratedImage
                        src={`/signature/${item.key}.webp`}
                        alt=""
                        width={item.width}
                        height={item.height}
                        loading="lazy"
                        decoding="async"
                        className="sig-cut paper-cutout"
                      />
                      <p className="sig-label">
                        <span className="flex items-center gap-1.5 font-semibold text-paper-text">
                          <span
                            aria-hidden="true"
                            className="sig-swatch"
                            style={{ backgroundColor: item.swatch }}
                          />
                          {item.name}
                        </span>
                        <span className="block text-paper-text-3">{item.colors}</span>
                      </p>
                    </li>
                  )
                })}
              </ul>

              <figure className="sig-outfit paper-sheet">
                <GeneratedImage
                  src="/signature/outfit-480.webp"
                  srcSet="/signature/outfit-480.webp 480w, /signature/outfit-768.webp 768w"
                  sizes="(min-width: 768px) 280px, 70vw"
                  alt="The outfit FitCheck put together from those pieces, worn: white t-shirt, rust trousers, white sneakers"
                  width={768}
                  height={1024}
                  loading="lazy"
                  decoding="async"
                  fallback="hide-figure"
                />
                <figcaption className="sig-outfit-caption">
                  <span className="font-semibold text-paper-text">Today</span>
                  <span className="text-paper-text-3">24° clear</span>
                </figcaption>
              </figure>

              <ol className="sig-steps" role="list">
                {STEPS.map((step) => (
                  <li key={step.id} id={step.id} className="sig-step">
                    <h2 className="sig-step-title paper-head">{step.title}</h2>
                    <p className="mt-1 text-sm leading-snug text-paper-text-2">{step.body}</p>
                  </li>
                ))}
              </ol>
            </div>
            <p className="sig-note">
              Example photo. The labels, cut-outs and outfit are FitCheck output from it.
            </p>
          </div>
        </div>
      </div>
    </section>
  )
}
