import { Skeleton } from '@/components/ui/skeleton'
import { cn } from '@/lib/utils'

export interface LoadingGridProps {
  count?: number
  /** Card aspect for grid tiles */
  variant?: 'card' | 'list' | 'square' | 'masonry'
  columns?: string
  /**
   * Explicit masonry column count. When set, the masonry variant uses inline
   * CSS columns instead of the class ladder, so skeletons can mirror a JS
   * masonry driven by `useColumnCount()` without relying on Tailwind's
   * arbitrary-value conflict resolution.
   */
  columnCount?: number
  className?: string
}

export function LoadingGrid({
  count = 8,
  variant = 'card',
  columns = 'grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6',
  columnCount,
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

  if (variant === 'masonry') {
    const heights = ['h-48', 'h-64', 'h-56', 'h-72', 'h-52']
    return (
      <div
        className={cn(
          'columns-2 gap-xs sm:columns-3 md:columns-4 lg:columns-5 xl:columns-6 2xl:columns-7 [&>*]:mb-xs [&>*]:break-inside-avoid',
          className
        )}
        style={columnCount ? { columnCount } : undefined}
      >
        {Array.from({ length: count }).map((_, i) => (
          <Skeleton key={i} className={cn('w-full rounded-md', heights[i % heights.length])} />
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
