import * as React from 'react'

import { cn } from '@/shared/lib/cn'

/**
 * Card — flat surface, hairline edge, no elevation (DESIGN.md §06). Large
 * cards use rounded-lg (32px) per DESIGN.md §05.
 */
const Card = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn('rounded-lg border border-border bg-card text-card-foreground', className)}
      {...props}
    />
  ),
)
Card.displayName = 'Card'

interface CardSectionProps extends React.HTMLAttributes<HTMLDivElement> {
  /** Compact padding for dense panels (dashboard grid) */
  dense?: boolean
}

const CardHeader = React.forwardRef<HTMLDivElement, CardSectionProps>(
  ({ className, dense, ...props }, ref) => (
    <div
      ref={ref}
      className={cn('flex flex-col space-y-1.5', dense ? 'p-4 pb-1.5' : 'p-6', className)}
      {...props}
    />
  ),
)
CardHeader.displayName = 'CardHeader'

const CardTitle = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn('font-semibold leading-none tracking-tight', className)}
      {...props}
    />
  ),
)
CardTitle.displayName = 'CardTitle'

const CardDescription = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn('text-sm text-muted-foreground', className)} {...props} />
  ),
)
CardDescription.displayName = 'CardDescription'

const CardContent = React.forwardRef<HTMLDivElement, CardSectionProps>(
  ({ className, dense, ...props }, ref) => (
    <div ref={ref} className={cn(dense ? 'p-4 pt-0' : 'p-6 pt-0', className)} {...props} />
  ),
)
CardContent.displayName = 'CardContent'

const CardFooter = React.forwardRef<HTMLDivElement, CardSectionProps>(
  ({ className, dense, ...props }, ref) => (
    <div ref={ref} className={cn('flex items-center', dense ? 'p-4 pt-0' : 'p-6 pt-0', className)} {...props} />
  ),
)
CardFooter.displayName = 'CardFooter'

export { Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent }
