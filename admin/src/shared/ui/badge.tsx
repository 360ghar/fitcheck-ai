import { cva, type VariantProps } from 'class-variance-authority'
import * as React from 'react'

import { cn } from '@/shared/lib/cn'

/**
 * Badge — flat pills. Success/warning/danger/info tones map to the status
 * palette in index.css (see StatusBadge for the status-string → tone logic).
 */
const badgeVariants = cva(
  'inline-flex items-center gap-1.5 whitespace-nowrap rounded-full border border-transparent px-2.5 py-0.5 text-xs font-medium transition-colors',
  {
    variants: {
      variant: {
        default: 'bg-surface-card text-body',
        secondary: 'bg-secondary-bg text-secondary-foreground',
        outline: 'border-border bg-transparent text-foreground',
        success: 'bg-success-pale text-success-deep',
        warning: 'bg-warning-pale text-warning-deep',
        danger: 'bg-destructive/10 text-destructive',
        info: 'bg-info-pale text-info-deep',
      },
    },
    defaultVariants: {
      variant: 'default',
    },
  },
)

export interface BadgeProps
  extends React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof badgeVariants> {}

function Badge({ className, variant, ...props }: BadgeProps) {
  return <span className={cn(badgeVariants({ variant }), className)} {...props} />
}

export { Badge, badgeVariants }
