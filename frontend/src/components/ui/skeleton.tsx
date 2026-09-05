/**
 * Base skeleton loader — animated placeholder for loading states.
 *
 * The shimmer lives in the `.skeleton` class (src/index.css): a transform-only
 * sweep pseudo-element. It replaces the old flat `animate-pulse`, which gave
 * loading states no sense of direction.
 */

import { cn } from '@/lib/utils'

interface SkeletonProps {
  className?: string
}

/**
 * Base skeleton component - animated placeholder
 */
export function Skeleton({ className }: SkeletonProps) {
  return (
    <div
      className={cn(
        'skeleton rounded-md bg-muted',
        className
      )}
    />
  )
}
