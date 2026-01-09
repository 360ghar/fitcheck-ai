/**
 * Scrollable Tabs Component
 * Horizontal scrolling tabs with snap behavior for mobile
 * Includes gradient fade indicators on edges
 */

import * as React from 'react'
import { cn } from '@/lib/utils'

interface ScrollableTabsProps extends React.HTMLAttributes<HTMLDivElement> {
  children: React.ReactNode
  /** Show gradient fade indicators on edges */
  showFade?: boolean
}

export function ScrollableTabs({
  children,
  className,
  showFade = true,
  ...props
}: ScrollableTabsProps) {
  const scrollRef = React.useRef<HTMLDivElement>(null)
  const [canScrollLeft, setCanScrollLeft] = React.useState(false)
  const [canScrollRight, setCanScrollRight] = React.useState(false)

  const checkScroll = React.useCallback(() => {
    const el = scrollRef.current
    if (!el) return

    setCanScrollLeft(el.scrollLeft > 0)
    setCanScrollRight(el.scrollLeft < el.scrollWidth - el.clientWidth - 1)
  }, [])

  React.useEffect(() => {
    const el = scrollRef.current
    if (!el) return

    checkScroll()
    el.addEventListener('scroll', checkScroll)
    window.addEventListener('resize', checkScroll)

    return () => {
      el.removeEventListener('scroll', checkScroll)
      window.removeEventListener('resize', checkScroll)
    }
  }, [checkScroll])

  return (
    <div className={cn('relative', className)} {...props}>
      {/* Scrollable container */}
      <div
        ref={scrollRef}
        className="overflow-x-auto scrollbar-hide scroll-snap-x px-4 md:px-0"
      >
        <div className="flex gap-1 w-max">{children}</div>
      </div>

      {/* Left fade indicator */}
      {showFade && canScrollLeft && (
        <div
          className="absolute left-0 top-0 bottom-0 w-8 bg-gradient-to-r from-background to-transparent pointer-events-none"
          aria-hidden="true"
        />
      )}

      {/* Right fade indicator */}
      {showFade && canScrollRight && (
        <div
          className="absolute right-0 top-0 bottom-0 w-8 bg-gradient-to-l from-background to-transparent pointer-events-none"
          aria-hidden="true"
        />
      )}
    </div>
  )
}

interface ScrollableTabProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  isActive?: boolean
  children: React.ReactNode
}

export function ScrollableTab({
  isActive,
  children,
  className,
  ...props
}: ScrollableTabProps) {
  return (
    <button
      className={cn(
        // Base styles
        'flex items-center gap-2 px-4 py-3 border-b-2 font-medium text-sm whitespace-nowrap',
        // Touch target
        'touch-target',
        // Scroll snap
        'scroll-snap-start',
        // Transitions
        'transition-colors duration-200',
        // Active/inactive states
        isActive
          ? 'border-primary text-primary'
          : 'border-transparent text-muted-foreground hover:text-foreground hover:border-muted',
        className
      )}
      {...props}
    >
      {children}
    </button>
  )
}

export default ScrollableTabs
