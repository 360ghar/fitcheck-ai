import { PLAN_LIMITS } from '@/lib/plan-limits'
import { DEMO_RATE_LIMITS } from '@/lib/demo-limits'

import { AnimatedSection } from './AnimatedSection'

/**
 * Proof-bar directly under the hero: real verifiable stats only, set as
 * pressed clay tiles (white card, stamped shadow, one small tint chip each —
 * amber for plan limits, teal for the live-demo limit; two accents max).
 *
 * Sources (never fabricate):
 * - PLAN_LIMITS.free (frontend/src/lib/plan-limits.ts, in sync with
 *   backend/app/core/config.py PLAN_FREE_*): 50 extractions/month,
 *   50 generations/month, 10 photoshoot images/day.
 * - DEMO_RATE_LIMITS (frontend/src/lib/demo-limits.ts, mirrors
 *   backend/app/core/ip_rate_limit.py): 3 extraction / 2 try-on /
 *   1 photoshoot demo runs per IP per day, no account.
 */

// Literal class map: Tailwind's JIT needs complete class names at scan time.
const CHIP_TONE = {
  amber: 'bg-tint-amber-pale text-tint-amber',
  teal: 'bg-tint-teal-pale text-tint-teal',
} as const

export default function ProofBar() {
  const tiles: Array<{
    metric: string
    label: string
    chip: string
    tone: keyof typeof CHIP_TONE
  }> = [
    {
      chip: 'Free plan',
      tone: 'amber',
      metric: `${PLAN_LIMITS.free.monthlyExtractions} / month`,
      label: 'Item extractions on Free — digitize clothes from photos',
    },
    {
      chip: 'Free plan',
      tone: 'amber',
      metric: `${PLAN_LIMITS.free.dailyPhotoshootImages} / day`,
      label: 'AI photoshoot images on Free from one selfie',
    },
    {
      chip: 'Live demo',
      tone: 'teal',
      metric: `${DEMO_RATE_LIMITS.extraction} · ${DEMO_RATE_LIMITS.tryOn} · ${DEMO_RATE_LIMITS.photoshoot} / day`,
      label: 'Free demo runs per IP, no account: extraction, try-on, photoshoot',
    },
  ]

  return (
    <section aria-label="Verified plan and demo limits" className="border-b border-border bg-background">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <AnimatedSection className="reveal">
          <ul className="grid grid-cols-1 gap-4 py-8 sm:grid-cols-3">
            {tiles.map((tile) => (
              <li
                key={tile.label}
                className="min-w-0 rounded-3xl border border-border bg-card p-5 shadow-pressed"
              >
                <span
                  className={`inline-flex rounded-full px-2.5 py-0.5 text-[11px] font-semibold uppercase tracking-[0.12em] ${CHIP_TONE[tile.tone]}`}
                >
                  {tile.chip}
                </span>
                <p className="mt-3 text-2xl font-semibold tracking-tight text-foreground">
                  {tile.metric}
                </p>
                <p className="mt-1 text-sm leading-relaxed text-muted-foreground">{tile.label}</p>
              </li>
            ))}
          </ul>
        </AnimatedSection>
      </div>
    </section>
  )
}
