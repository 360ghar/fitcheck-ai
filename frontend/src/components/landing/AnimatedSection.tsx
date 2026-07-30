import { cn } from '@/lib/utils'

interface AnimatedSectionProps {
  children: React.ReactNode
  delay?: number
  className?: string
}

export function AnimatedSection({ children, delay = 0, className }: AnimatedSectionProps) {
  // Public and product content must be visible before any JavaScript runs.
  // Keep this wrapper so its callers retain a stable layout API, but do not
  // gate readability behind an IntersectionObserver or an entrance animation.
  return (
    <div
      className={cn('motion-reduce:transform-none', className)}
      data-reveal-delay={delay || undefined}
    >
      {children}
    </div>
  )
}
