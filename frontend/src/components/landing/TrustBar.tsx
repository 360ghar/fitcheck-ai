import { Link } from 'react-router-dom'
import { CreditCard, LockKeyhole, ShieldCheck, Trash2 } from 'lucide-react'
import { cn } from '@/lib/utils'

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

export default function TrustBar() {
  return (
    <section aria-label="Verified privacy and billing facts" className="border-y border-border bg-surface-soft">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <ul className="grid grid-cols-1 divide-y divide-border sm:grid-cols-2 sm:gap-x-8 sm:divide-y-0 lg:grid-cols-4 lg:gap-x-0 lg:divide-x">
          {trustFacts.map((fact) => {
            const content = (
              <>
                <span
                  className={cn(
                    'flex h-10 w-10 shrink-0 items-center justify-center rounded-2xl border border-border',
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
              'group flex min-h-32 items-start gap-4 py-6 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2'

            return (
              <li key={fact.title} className="min-w-0 lg:px-6 lg:first:pl-0 lg:last:pr-0">
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
      </div>
    </section>
  )
}
