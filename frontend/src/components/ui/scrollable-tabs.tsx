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
  /** Tailwind class for the edge fade overlays. Defaults to the page
   *  background; pass the strip's own surface (e.g. `bg-card/95`) when the
   *  tabs sit on a card so the fades don't show a tonal seam. */
  fadeClassName?: string
  /** Accessible name for the tablist */
  'aria-label'?: string
}

export function ScrollableTabs({
  children,
  className,
  showFade = true,
  fadeClassName = 'bg-background/90',
  'aria-label': ariaLabel = 'Tabs',
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
        role="tablist"
        aria-label={ariaLabel}
        aria-orientation="horizontal"
        className="overflow-x-auto scrollbar-hide scroll-snap-x px-4 md:px-0 touch-pan-x overscroll-x-contain"
      >
        <div className="flex gap-1 w-max">{children}</div>
      </div>

      {/* Left fade indicator */}
      {showFade && canScrollLeft && (
        <div
          className={cn('pointer-events-none absolute bottom-0 left-0 top-0 w-8', fadeClassName)}
          aria-hidden="true"
        />
      )}

      {/* Right fade indicator */}
      {showFade && canScrollRight && (
        <div
          className={cn('pointer-events-none absolute bottom-0 right-0 top-0 w-8', fadeClassName)}
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
  onKeyDown,
  ...props
}: ScrollableTabProps) {
  const handleKeyDown = (event: React.KeyboardEvent<HTMLButtonElement>) => {
    onKeyDown?.(event)
    if (event.defaultPrevented) return

    const direction = event.key === 'ArrowRight' ? 1 : event.key === 'ArrowLeft' ? -1 : 0
    const tablist = event.currentTarget.closest('[role="tablist"]')
    if (!tablist || direction === 0 && event.key !== 'Home' && event.key !== 'End') return

    const tabs = Array.from(
      tablist.querySelectorAll<HTMLButtonElement>('[role="tab"]:not(:disabled)')
    )
    const currentIndex = tabs.indexOf(event.currentTarget)
    if (currentIndex < 0 || tabs.length === 0) return

    const nextIndex = event.key === 'Home'
      ? 0
      : event.key === 'End'
        ? tabs.length - 1
        : (currentIndex + direction + tabs.length) % tabs.length

    event.preventDefault()
    tabs[nextIndex]?.focus()
    tabs[nextIndex]?.click()
  }

  return (
    <button
      type="button"
      role="tab"
      aria-selected={Boolean(isActive)}
      tabIndex={isActive ? 0 : -1}
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
      onKeyDown={handleKeyDown}
      {...props}
    >
      {children}
    </button>
  )
}

export default ScrollableTabs
