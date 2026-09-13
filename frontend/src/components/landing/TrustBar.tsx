import { Link } from 'react-router-dom'
import { CreditCard, LockKeyhole, ShieldCheck, Trash2 } from 'lucide-react'
import { cn } from '@/lib/utils'
import { GeneratedImage } from '@/components/ui/generated-image'

type FactTone = 'coral' | 'amber' | 'teal' | 'blue'

// Literal class map: Tailwind's JIT needs complete class names at scan time.
const FACT_TILE: Record<FactTone, string> = {
  coral: 'bg-tint-coral-pale text-tint-coral',
  amber: 'bg-tint-amber-pale text-tint-amber',
  teal: 'bg-tint-teal-pale text-tint-teal',
  blue: 'bg-tint-blue-pale text-tint-blue',
}

const trustFacts: Array<{
  icon: typeof ShieldCheck
  title: string
  body: string
  href: string
  tone: FactTone
}> = [
  {
    icon: ShieldCheck,
    title: 'Private by default',
    body: 'Wardrobe photos and account data stay tied to your account.',
    href: '/privacy',
    tone: 'teal',
  },
  {
    icon: LockKeyhole,
    title: 'Encrypted',
    body: 'Photos and wardrobe data are encrypted in transit and at rest.',
    href: '/privacy',
    tone: 'blue',
  },
  {
    icon: Trash2,
    title: 'Delete account data',
    body: 'You can delete your account and stored wardrobe data.',
    href: '/privacy',
    tone: 'coral',
  },
  {
    icon: CreditCard,
    title: 'No-card trial',
    body: 'The first month returns to Free unless you choose to upgrade.',
    href: '#faq',
    tone: 'amber',
  },
]

/**
 * Trust facts as pressed clay tiles on the section's cream room (the one
 * tinted room in this viewport). `.card-interactive` gives the resting
 * pressed shadow plus the offset hover/focus signature.
 */
export default function TrustBar() {
  return (
    <section aria-label="Verified privacy and billing facts" className="border-y border-border bg-surface-room">
      <div className="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
        <ul className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {trustFacts.map((fact) => {
            const content = (
              <>
                <span
                  className={cn(
                    'flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-soft',
                    FACT_TILE[fact.tone]
                  )}
                >
                  <fact.icon className="h-4 w-4" aria-hidden="true" />
                </span>
                <span>
                  <span className="block text-sm font-semibold text-foreground group-hover:text-primary">
                    {fact.title}
                  </span>
                  <span className="mt-1.5 block text-sm leading-relaxed text-muted-foreground">
                    {fact.body}
                  </span>
                </span>
              </>
            )
            const className =
              'card-interactive group flex min-h-32 items-start gap-4 rounded-3xl border border-border bg-card p-5 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2'

            return (
              <li key={fact.title} className="min-w-0">
                {fact.href.startsWith('#') ? (
                  <a href={fact.href} className={className}>
                    {content}
                  </a>
                ) : (
                  <Link to={fact.href} className={className}>
                    {content}
                  </Link>
                )}
              </li>
            )
          })}
        </ul>
        {/* Avatar honesty pill: a finished, contained close to the trust
            section — illustration only, never a testimonial (no names,
            quotes, or claims). */}
        <div className="mt-8 flex justify-center">
          <div className="flex items-center gap-4 rounded-full border border-border bg-card py-2 pl-2 pr-6 shadow-pressed">
            <GeneratedImage
              src="/generated/avatar-diverse-1x1-640.webp"
              srcSet="/generated/avatar-diverse-1x1-640.webp 640w, /generated/avatar-diverse-1x1.webp 1080w"
              sizes="48px"
              alt=""
              width={96}
              height={96}
              loading="lazy"
              decoding="async"
              className="h-12 w-12 shrink-0 rounded-full border border-border object-cover"
            />
            <p className="min-w-0 text-sm leading-snug">
              <span className="block font-semibold text-foreground">
                Avatars are AI-generated examples
              </span>
              <span className="block text-muted-foreground">
                Real member photos are never shown without consent.
              </span>
            </p>
          </div>
        </div>
      </div>
    </section>
  )
}
