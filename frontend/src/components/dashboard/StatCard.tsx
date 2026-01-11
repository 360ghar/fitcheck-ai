/**
 * StatCard Component
 *
 * A modern stat card with gradient accent and hover effects.
 * Features:
 * - Gradient accent bar at top
 * - Icon with gradient background and glow
 * - Loading skeleton support
 * - Hover lift animation
 * - Arrow indicator on hover
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
  /** Gradient for accent bar and icon background */
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

const gradientConfig = {
  primary: {
    bar: 'bg-gradient-primary',
    icon: 'bg-gradient-to-br from-indigo-500 to-purple-600',
    shadow: 'shadow-indigo-500/25',
  },
  accent: {
    bar: 'bg-gradient-accent',
    icon: 'bg-gradient-to-br from-amber-500 to-red-500',
    shadow: 'shadow-amber-500/25',
  },
  cool: {
    bar: 'bg-gradient-cool',
    icon: 'bg-gradient-to-br from-cyan-500 to-blue-500',
    shadow: 'shadow-cyan-500/25',
  },
  warm: {
    bar: 'bg-gradient-warm',
    icon: 'bg-gradient-to-br from-orange-500 to-pink-500',
    shadow: 'shadow-orange-500/25',
  },
  success: {
    bar: 'bg-gradient-success',
    icon: 'bg-gradient-to-br from-emerald-500 to-cyan-500',
    shadow: 'shadow-emerald-500/25',
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
    const config = gradientConfig[gradient]

    const content = (
      <div
        ref={ref}
        className={cn(
          'relative bg-card rounded-xl overflow-hidden',
          'transition-all duration-300',
          'hover:shadow-elevated hover:-translate-y-0.5',
          'group',
          className
        )}
      >
        {/* Gradient accent bar */}
        <div className={cn('absolute top-0 left-0 right-0 h-1', config.bar)} />

        <div className="p-4 md:p-5 lg:p-6">
          <div className="flex items-start justify-between">
            {/* Icon with gradient background */}
            <div
              className={cn(
                'p-2.5 md:p-3 rounded-xl',
                config.icon,
                'shadow-lg',
                config.shadow
              )}
            >
              <Icon className="h-5 w-5 md:h-6 md:w-6 text-white" />
            </div>

            {/* Arrow indicator - visible on hover */}
            {link && (
              <ArrowRight
                className={cn(
                  'h-5 w-5 text-muted-foreground',
                  'opacity-0 group-hover:opacity-100',
                  'translate-x-2 group-hover:translate-x-0',
                  'transition-all duration-200'
                )}
              />
            )}
          </div>

          {/* Value and label */}
          <div className="mt-4">
            {isLoading ? (
              <Skeleton className="h-8 w-16 mb-1" />
            ) : (
              <p className="text-2xl md:text-3xl font-bold text-foreground">
                {value}
              </p>
            )}
            <p className="text-xs md:text-sm text-muted-foreground mt-0.5">
              {name}
            </p>
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
