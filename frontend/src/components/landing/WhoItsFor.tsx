import { Link } from 'react-router-dom'
import { ArrowUpRight, LockKeyhole, ShieldCheck, Trash2 } from 'lucide-react'

import { GeneratedImage } from '@/components/ui/generated-image'

const privacyFacts = [
  {
    icon: ShieldCheck,
    title: 'Private storage',
    body: 'Wardrobe images sit in private storage. Every read and write checks that the account owns them.',
  },
  {
    icon: LockKeyhole,
    title: 'Encrypted',
    body: 'Photos and wardrobe data are encrypted in transit and at rest.',
  },
  {
    icon: Trash2,
    title: 'Delete it all',
    body: 'Deleting the account removes the profile, the wardrobe and every stored image tied to it.',
  },
]

const personas = [
  {
    title: 'Busy professionals',
    body: 'Weather-aware workday outfits from the wardrobe you already own.',
    href: '/for/busy-professionals',
  },
  {
    title: 'Content creators',
    body: 'Planned looks and studio-style images for a content schedule.',
    href: '/for/content-creators',
  },
  {
    title: 'Festive and wedding guests',
    body: 'Occasion wear catalogued and combinations ready before the next invitation.',
    href: '/for/festive-and-wedding-outfits',
  },
]

export default function WhoItsFor() {
  return (
    <section
      id="who-its-for"
      className="paper-section paper-tear stock-ink pb-24 pt-20 md:pb-32 md:pt-28"
    >
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <h2 className="paper-display text-[clamp(2.4rem,5.2vw,4.5rem)] text-paper-text">
          Your photos stay yours.
        </h2>
        <div className="mt-10 grid grid-cols-1 gap-16 lg:mt-14 lg:grid-cols-12 lg:gap-16">
          <div className="min-w-0 lg:col-span-5">
            <ul className="space-y-7">
              {privacyFacts.map((fact) => (
                <li key={fact.title} className="reveal grid grid-cols-[1.75rem_minmax(0,1fr)] gap-3">
                  <fact.icon className="mt-1 h-5 w-5 text-paper-accent" aria-hidden="true" />
                  <div>
                    <p className="paper-head text-xl text-paper-text">{fact.title}</p>
                    <p className="mt-1 text-[15px] leading-relaxed text-paper-text-2">{fact.body}</p>
                  </div>
                </li>
              ))}
            </ul>
            <Link
              to="/privacy"
              className="mt-8 inline-flex min-h-11 items-center gap-1.5 text-[15px] font-semibold text-paper-accent hover:text-paper-text"
            >
              Read the privacy policy
              <ArrowUpRight className="h-4 w-4" aria-hidden="true" />
            </Link>
          </div>

          <div className="min-w-0 lg:col-span-7">
            <h3 className="paper-head text-[1.7rem] text-paper-text">Who it is for</h3>
            <ul className="mt-4">
              {personas.map((persona) => (
                <li key={persona.title} className="reveal">
                  <Link
                    to={persona.href}
                    className="group grid min-w-0 grid-cols-[minmax(0,1fr)_1.5rem] gap-5 rounded-lg py-5"
                  >
                    <span>
                      <span className="block text-xl font-semibold text-paper-text transition-colors group-hover:text-paper-accent sm:text-2xl">
                        {persona.title}
                      </span>
                      <span className="mt-1.5 block max-w-xl text-[15px] leading-relaxed text-paper-text-2">
                        {persona.body}
                      </span>
                    </span>
                    <ArrowUpRight
                      className="mt-1 h-5 w-5 text-paper-text-3 transition-[color,transform] group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-paper-accent"
                      aria-hidden="true"
                    />
                  </Link>
                </li>
              ))}
            </ul>
            <figure className="paper-sheet mt-8 p-2 sm:rotate-[-0.6deg] sm:p-3">
              <GeneratedImage
                src="/generated/lifestyle-mumbai-3x4-640.webp"
                srcSet="/generated/lifestyle-mumbai-3x4-640.webp 640w, /generated/lifestyle-mumbai-3x4.webp 900w"
                sizes="(min-width: 1024px) 50vw, calc(100vw - 32px)"
                alt="Workday look example in a navy blazer, street style"
                className="aspect-[16/10] h-auto w-full rounded-[10px] object-cover"
                loading="lazy"
                decoding="async"
                width={900}
                height={1200}
                fallback="hide-figure"
              />
              <figcaption className="px-1 pb-1 pt-3 text-xs text-paper-text-3 sm:text-[13px]">
                Example look. People on this page are AI-generated; member photos are never shown.
              </figcaption>
            </figure>
          </div>
        </div>
      </div>
    </section>
  )
}
