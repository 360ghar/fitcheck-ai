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
  ({ className, active, role, ...props }, ref) => (
    <button
      ref={ref}
      type="button"
      role={role}
      className={cn(filterChipVariants({ active }), className)}
      // A tab-role chip reports state via aria-selected; aria-pressed is only
      // valid for toggle buttons (role="button"), so suppress it there.
      {...(role === 'tab'
        ? { 'aria-selected': Boolean(active) }
        : { 'aria-pressed': Boolean(active) })}
      {...props}
    />
  ),
)
FilterChip.displayName = 'FilterChip'

export { filterChipVariants }
