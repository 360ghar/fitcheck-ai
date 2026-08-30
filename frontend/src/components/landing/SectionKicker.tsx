import { cn } from '@/lib/utils'

interface SectionKickerProps {
  children: React.ReactNode
  className?: string
}

/**
 * SectionKicker — the landing page's repeated signature beat above each H2:
 * one Brand Red dot + a small uppercase label (caption-md per DESIGN.md §02).
 * Gives the long page a scannable rhythm without adding a second type system.
 */
export function SectionKicker({ children, className }: SectionKickerProps) {
  return (
    <p
      className={cn(
        'mb-4 flex items-center gap-2 text-xs font-medium uppercase tracking-[0.14em] text-muted-foreground',
        className
      )}
    >
      <span className="h-1.5 w-1.5 rounded-full bg-primary" aria-hidden="true" />
      {children}
    </p>
  )
}
