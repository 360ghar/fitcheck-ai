import type { CSSProperties, ReactNode } from 'react'
import { cn } from '@/lib/utils'

interface AnimatedSectionProps {
  children: ReactNode
  delay?: number
  className?: string
}

/**
 * Scroll-reveal wrapper backed by native CSS scroll-driven animations
 * (see the "Landing motion system" block in index.css).
 *
 * Laws this preserves:
 * - No IntersectionObserver and no JS gating: content is fully visible in
 *   prerendered HTML; motion only exists where `@supports
 *   (animation-timeline: view())` passes.
 * - Reveal keyframes are transform-only, so text remains fully painted while
 *   motion runs. Reduced-motion users get a static page via the global
 *   kill-switch.
 *
 * `delay` maps to a stagger step for use inside `.reveal-steps` grids;
 * callers pass multiples of 60ms as before. On its own (`className="reveal"`)
 * the element reveals as one unit.
 */
export function AnimatedSection({ children, delay = 0, className }: AnimatedSectionProps) {
  const step = Math.round(delay / 60)
  return (
    <div
      className={cn('motion-reduce:transform-none', className)}
      style={{ '--reveal-step': step } as CSSProperties}
    >
      {children}
    </div>
  )
}
