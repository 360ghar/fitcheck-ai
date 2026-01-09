/**
 * Responsive Grid Component
 * A flexible grid that adapts to container size using CSS container queries
 * Supports auto-fit columns with configurable min/max widths
 */

import * as React from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const gridVariants = cva(
  'grid gap-4',
  {
    variants: {
      columns: {
        auto: 'grid-cols-[repeat(auto-fit,minmax(var(--grid-min,280px),1fr))]',
        1: 'grid-cols-1',
        2: 'grid-cols-1 sm:grid-cols-2',
        3: 'grid-cols-1 sm:grid-cols-2 lg:grid-cols-3',
        4: 'grid-cols-2 sm:grid-cols-3 lg:grid-cols-4',
        5: 'grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5',
        6: 'grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6',
      },
      gap: {
        none: 'gap-0',
        sm: 'gap-2',
        md: 'gap-4',
        lg: 'gap-6',
        xl: 'gap-8',
      },
      layout: {
        grid: '',
        list: 'grid-cols-1',
        masonry: '', // Note: CSS masonry is not widely supported yet
      },
    },
    defaultVariants: {
      columns: 'auto',
      gap: 'md',
      layout: 'grid',
    },
  }
)

export interface ResponsiveGridProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof gridVariants> {
  /** Minimum width for auto-fit columns (e.g., '200px', '15rem') */
  minItemWidth?: string
  /** Enable container query mode for intrinsic sizing */
  containerQuery?: boolean
}

const ResponsiveGrid = React.forwardRef<HTMLDivElement, ResponsiveGridProps>(
  (
    {
      className,
      columns,
      gap,
      layout,
      minItemWidth = '280px',
      containerQuery = false,
      style,
      ...props
    },
    ref
  ) => {
    const gridStyle: React.CSSProperties = {
      ...style,
      '--grid-min': minItemWidth,
    } as React.CSSProperties

    return (
      <div
        ref={ref}
        className={cn(
          gridVariants({ columns, gap, layout }),
          containerQuery && 'container-query',
          className
        )}
        style={gridStyle}
        {...props}
      />
    )
  }
)
ResponsiveGrid.displayName = 'ResponsiveGrid'

/**
 * A responsive grid optimized for card layouts
 * - 2 columns on mobile (< 640px)
 * - 3 columns on tablet (640px - 1024px)
 * - 4-5 columns on desktop (> 1024px)
 */
const CardGrid = React.forwardRef<
  HTMLDivElement,
  Omit<ResponsiveGridProps, 'columns' | 'minItemWidth'>
>(({ className, ...props }, ref) => (
  <ResponsiveGrid
    ref={ref}
    columns="auto"
    minItemWidth="160px"
    className={cn(
      // Override auto-fit for more control
      'grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5',
      className
    )}
    {...props}
  />
))
CardGrid.displayName = 'CardGrid'

/**
 * A responsive grid optimized for list/item views
 * - 1 column on mobile
 * - 2 columns on tablet and up
 */
const ListGrid = React.forwardRef<
  HTMLDivElement,
  Omit<ResponsiveGridProps, 'columns'>
>(({ className, ...props }, ref) => (
  <ResponsiveGrid
    ref={ref}
    columns={2}
    className={cn('md:grid-cols-2', className)}
    {...props}
  />
))
ListGrid.displayName = 'ListGrid'

export { ResponsiveGrid, CardGrid, ListGrid, gridVariants }
