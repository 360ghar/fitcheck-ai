import { Skeleton } from '@/components/ui/skeleton'
import { cn } from '@/lib/utils'

export interface LoadingGridProps {
  count?: number
  /** Card aspect for grid tiles */
  variant?: 'card' | 'list' | 'square'
  columns?: string
  className?: string
}

export function LoadingGrid({
  count = 8,
  variant = 'card',
  columns = 'grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5',
  className,
}: LoadingGridProps) {
  if (variant === 'list') {
    return (
      <div className={cn('grid grid-cols-1 gap-3', className)}>
        {Array.from({ length: count }).map((_, i) => (
          <Skeleton key={i} className="h-20 w-full rounded-xl" />
        ))}
      </div>
    )
  }

  return (
    <div className={cn('grid gap-3 md:gap-4', columns, className)}>
      {Array.from({ length: count }).map((_, i) => (
        <Skeleton
          key={i}
          className={cn(
            'w-full rounded-xl',
            variant === 'square' ? 'aspect-square' : 'aspect-[3/4]'
          )}
        />
      ))}
    </div>
  )
}
