/**
 * Base skeleton loader — animated placeholder for loading states.
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
        'animate-pulse rounded-md bg-muted',
        className
      )}
    />
  )
}
