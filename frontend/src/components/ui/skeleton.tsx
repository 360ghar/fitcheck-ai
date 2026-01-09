/**
 * Skeleton loading components for various UI elements
 *
 * Provides consistent loading states across the app
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

/**
 * Skeleton for wardrobe item cards
 */
export function ItemCardSkeleton({ className }: SkeletonProps) {
  return (
    <div className={cn('rounded-lg overflow-hidden bg-card', className)}>
      <Skeleton className="aspect-square w-full" />
      <div className="p-2.5 md:p-3 space-y-2">
        <Skeleton className="h-4 w-3/4" />
        <Skeleton className="h-3 w-1/2" />
      </div>
    </div>
  )
}

/**
 * Skeleton for outfit cards
 */
export function OutfitCardSkeleton({ className }: SkeletonProps) {
  return (
    <div className={cn('rounded-lg overflow-hidden bg-card shadow', className)}>
      <Skeleton className="aspect-[4/3] w-full" />
      <div className="p-2.5 md:p-4 space-y-2">
        <Skeleton className="h-4 w-2/3" />
        <div className="flex items-center justify-between">
          <Skeleton className="h-3 w-16" />
          <Skeleton className="h-5 w-16 rounded-full" />
        </div>
      </div>
    </div>
  )
}

/**
 * Skeleton for dashboard stat cards
 */
export function StatCardSkeleton({ className }: SkeletonProps) {
  return (
    <div className={cn('rounded-lg bg-card p-4 md:p-6 shadow', className)}>
      <div className="flex items-center gap-3">
        <Skeleton className="h-10 w-10 md:h-12 md:w-12 rounded-full" />
        <div className="flex-1 space-y-2">
          <Skeleton className="h-3 w-20" />
          <Skeleton className="h-6 w-12" />
        </div>
      </div>
    </div>
  )
}

/**
 * Grid of stat card skeletons
 */
export function DashboardStatsSkeleton() {
  return (
    <div className="grid grid-cols-2 gap-3 md:gap-4">
      <StatCardSkeleton />
      <StatCardSkeleton />
      <StatCardSkeleton />
      <StatCardSkeleton />
    </div>
  )
}

/**
 * Grid of item card skeletons
 */
export function ItemGridSkeleton({ count = 8 }: { count?: number }) {
  return (
    <div className="grid grid-cols-2 xs:grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3 md:gap-4">
      {Array.from({ length: count }).map((_, i) => (
        <ItemCardSkeleton key={i} />
      ))}
    </div>
  )
}

/**
 * Grid of outfit card skeletons
 */
export function OutfitGridSkeleton({ count = 6 }: { count?: number }) {
  return (
    <div className="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-3 md:gap-4">
      {Array.from({ length: count }).map((_, i) => (
        <OutfitCardSkeleton key={i} />
      ))}
    </div>
  )
}

/**
 * Skeleton for calendar events
 */
export function CalendarEventSkeleton({ className }: SkeletonProps) {
  return (
    <div className={cn('rounded-lg bg-card p-3 space-y-2', className)}>
      <div className="flex items-center gap-2">
        <Skeleton className="h-3 w-3 rounded-full" />
        <Skeleton className="h-4 w-24" />
      </div>
      <Skeleton className="h-3 w-32" />
    </div>
  )
}

/**
 * Skeleton for recommendation cards
 */
export function RecommendationCardSkeleton({ className }: SkeletonProps) {
  return (
    <div className={cn('rounded-lg bg-card p-4 shadow', className)}>
      <Skeleton className="aspect-[4/3] w-full rounded-lg mb-3" />
      <div className="space-y-2">
        <Skeleton className="h-4 w-3/4" />
        <Skeleton className="h-3 w-full" />
        <Skeleton className="h-3 w-2/3" />
      </div>
    </div>
  )
}

/**
 * Skeleton for achievement/gamification cards
 */
export function AchievementCardSkeleton({ className }: SkeletonProps) {
  return (
    <div className={cn('rounded-lg bg-card p-4 flex items-center gap-3', className)}>
      <Skeleton className="h-12 w-12 rounded-full flex-shrink-0" />
      <div className="flex-1 space-y-2">
        <Skeleton className="h-4 w-24" />
        <Skeleton className="h-3 w-36" />
      </div>
    </div>
  )
}

/**
 * Skeleton for profile/user avatar section
 */
export function ProfileHeaderSkeleton() {
  return (
    <div className="flex items-center gap-4 p-4 md:p-6">
      <Skeleton className="h-16 w-16 md:h-24 md:w-24 rounded-full" />
      <div className="space-y-2">
        <Skeleton className="h-5 w-32" />
        <Skeleton className="h-4 w-48" />
      </div>
    </div>
  )
}

/**
 * Text line skeleton with configurable width
 */
export function TextSkeleton({ lines = 1, className }: SkeletonProps & { lines?: number }) {
  return (
    <div className={cn('space-y-2', className)}>
      {Array.from({ length: lines }).map((_, i) => (
        <Skeleton
          key={i}
          className={cn(
            'h-4',
            i === lines - 1 ? 'w-3/4' : 'w-full'
          )}
        />
      ))}
    </div>
  )
}

/**
 * Button skeleton
 */
export function ButtonSkeleton({ size = 'default' }: { size?: 'sm' | 'default' | 'lg' }) {
  const sizeClasses = {
    sm: 'h-10 w-20',
    default: 'h-11 w-24',
    lg: 'h-12 w-28',
  }

  return <Skeleton className={cn('rounded-md', sizeClasses[size])} />
}

/**
 * Input field skeleton
 */
export function InputSkeleton({ className }: SkeletonProps) {
  return (
    <div className={cn('space-y-1.5', className)}>
      <Skeleton className="h-4 w-20" />
      <Skeleton className="h-12 w-full rounded-md" />
    </div>
  )
}
