import { cn } from '@/lib/utils'

interface GlassCardProps {
  children: React.ReactNode
  className?: string
}

/** Solid editorial panel used by landing demos (name kept for API stability). */
export function GlassCard({ children, className }: GlassCardProps) {
  return (
    <div
      className={cn(
        'rounded-2xl border border-stone-200/90 bg-white shadow-sm dark:border-stone-800 dark:bg-stone-900',
        className
      )}
    >
      {children}
    </div>
  )
}
