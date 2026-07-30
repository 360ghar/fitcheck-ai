import * as React from 'react'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const filterChipVariants = cva(
  'inline-flex min-h-11 items-center justify-center rounded-full px-4 text-xs font-bold leading-none transition-colors',
  {
    variants: {
      active: {
        true: 'bg-ink text-on-dark',
        false: 'bg-surface-card text-ink hover:bg-secondary',
      },
    },
    defaultVariants: { active: false },
  },
)

export interface FilterChipProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>, VariantProps<typeof filterChipVariants> {}

export const FilterChip = React.forwardRef<HTMLButtonElement, FilterChipProps>(
  ({ className, active, ...props }, ref) => (
    <button ref={ref} type="button" className={cn(filterChipVariants({ active }), className)} {...props} aria-pressed={Boolean(active)} />
  ),
)
FilterChip.displayName = 'FilterChip'

export { filterChipVariants }
