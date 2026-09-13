import { cn } from '@/lib/utils'

export type SectionKickerTone = 'primary' | 'coral' | 'amber' | 'teal' | 'violet' | 'blue'

// Literal class map: Tailwind's JIT needs complete class names at scan time,
// so dot colors are selected from a record, never interpolated.
const TONE_DOT: Record<SectionKickerTone, string> = {
  primary: 'bg-primary',
  coral: 'bg-tint-coral',
  amber: 'bg-tint-amber',
  teal: 'bg-tint-teal',
  violet: 'bg-tint-violet',
  blue: 'bg-tint-blue',
}

interface SectionKickerProps {
  children: React.ReactNode
  className?: string
  /** Editorial tint for the leading dot (DESIGN.md 01). Default: Brand Red. */
  tone?: SectionKickerTone
}

/**
 * SectionKicker — the landing page's repeated signature beat above each H2:
 * one accent dot + a small uppercase label (caption-md per DESIGN.md §02).
 * Gives the long page a scannable rhythm without adding a second type system.
 * Dots rotate through the editorial tints section by section so the long page
 * reads as a sequence, not a wall of identical reds.
 */
export function SectionKicker({ children, className, tone = 'primary' }: SectionKickerProps) {
  return (
    <p
      className={cn(
        'mb-4 flex items-center gap-2 text-xs font-medium uppercase tracking-[0.14em] text-muted-foreground',
        className
      )}
    >
      <span className={cn('h-1.5 w-1.5 rounded-full', TONE_DOT[tone])} aria-hidden="true" />
      {children}
    </p>
  )
}
