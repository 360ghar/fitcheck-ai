/**
 * StatCard Component
 *
 * A compact stat card with a restrained semantic accent and hover effects.
 * Features:
 * - Solid semantic accent bar at top
 * - Horizontal layout: icon on the left, value and label on the right
 * - Loading skeleton support
 * - Hover lift animation
 * - Arrow indicator on hover (desktop only)
 *
 * @see https://docs.fitcheck.ai/features/dashboard
 */

import * as React from 'react'
import { ArrowRight, type LucideIcon } from 'lucide-react'
import { Link } from 'react-router-dom'
import { cn } from '@/lib/utils'
import { Skeleton } from '@/components/ui/skeleton'

// ============================================================================
// TYPES
// ============================================================================

export interface StatCardProps {
  /** Stat label */
  name: string
  /** Stat value */
  value: number | string
  /** Icon component */
  icon: LucideIcon
  /** Semantic tone for the accent bar and icon background. */
  gradient?: 'primary' | 'accent' | 'cool' | 'warm' | 'success'
  /** Link destination */
  link?: string
  /** Loading state */
  isLoading?: boolean
  /** Additional class names */
  className?: string
}

// ============================================================================
// HELPERS
// ============================================================================

const toneConfig = {
  primary: {
    bar: 'bg-primary',
    icon: 'bg-primary text-primary-foreground',
  },
  accent: {
    bar: 'bg-primary',
    icon: 'bg-primary/10 text-primary',
  },
  cool: {
    // Distinct from `warm` (neutral secondary) so the two stat cards remain
    // visually separable; reuses the established accent-purple pair from the
    // "AI pick" badge and OutfitCard.
    bar: 'bg-accent-purple',
    icon: 'bg-accent-purple text-white',
  },
  warm: {
    bar: 'bg-secondary',
    icon: 'bg-secondary text-secondary-foreground',
  },
  success: {
    bar: 'bg-success-pale',
    icon: 'bg-success-pale text-success-deep',
  },
}

// ============================================================================
// COMPONENT
// ============================================================================

export const StatCard = React.forwardRef<HTMLDivElement, StatCardProps>(
  (
    {
      name,
      value,
      icon: Icon,
      gradient = 'primary',
      link,
      isLoading = false,
      className,
    },
    ref
  ) => {
    const config = toneConfig[gradient]

    const content = (
      <div
        ref={ref}
        className={cn(
          'relative bg-card rounded-xl overflow-hidden',
          // No hover lift. `hover:-translate-y-0.5` moved the card against
          // nothing (every boxShadow token resolves to `none`), so it read as a
          // bare jump. A tonal edge shift is grounded and legible in both themes.
          'border border-transparent transition-colors duration-200 hover:border-border',
          'group',
          className
        )}
      >
        {/* Solid semantic accent bar */}
        <div className={cn('absolute top-0 left-0 right-0 h-1', config.bar)} />

        <div className="p-3 md:p-4">
          <div className="flex items-center gap-3">
            {/* Icon with semantic background */}
            <div
              className={cn(
                'shrink-0 p-2 md:p-2.5 rounded-lg',
                config.icon,
              )}
            >
              <Icon className="h-4 w-4 md:h-5 md:w-5" aria-hidden="true" />
            </div>

            {/* Value and label */}
            <div className="min-w-0 flex-1">
              {isLoading ? (
                <Skeleton className="h-7 w-12" />
              ) : (
                <p className="text-xl md:text-2xl font-bold leading-tight text-foreground">
                  {value}
                </p>
              )}
              <p className="text-xs text-muted-foreground truncate">{name}</p>
            </div>

            {/* Arrow indicator - visible on hover */}
            {link && (
              <ArrowRight
                className={cn(
                  'hidden md:block h-4 w-4 shrink-0 text-muted-foreground',
                  'opacity-0 group-hover:opacity-100',
                  'translate-x-2 group-hover:translate-x-0',
                  'transition-[opacity,transform] duration-200'
                )}
              />
            )}
          </div>
        </div>
      </div>
    )

    if (link) {
      return (
        <Link to={link} className="block">
          {content}
        </Link>
      )
    }

    return content
  }
)
StatCard.displayName = 'StatCard'

export default StatCard
