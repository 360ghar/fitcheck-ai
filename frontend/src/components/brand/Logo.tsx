/** Shared Facet F mark. Master: docs/brand/mark.svg. */

import { cn } from '@/lib/utils'

interface BrandMarkProps {
  /** Rendered width and height in pixels. */
  size?: number
  className?: string
}

export function BrandMark({ size = 32, className }: BrandMarkProps) {
  return (
    <img
      src="/brand-mark.svg?v=facet-f-1"
      width={size}
      height={size}
      className={cn('shrink-0', className)}
      alt=""
      aria-hidden="true"
    />
  )
}

interface LogoProps {
  markSize?: number
  /** Hide the wordmark text visually (collapsed sidebar); it stays readable. */
  compact?: boolean
  className?: string
  wordmarkClassName?: string
}

export function Logo({ markSize = 32, compact = false, className, wordmarkClassName }: LogoProps) {
  return (
    <span className={cn('flex items-center gap-2 transition-[gap] duration-200 motion-reduce:transition-none', compact && 'gap-0', className)}>
      <BrandMark size={markSize} />
      <span
        className={cn(
          'whitespace-nowrap font-semibold tracking-tight text-foreground',
          'overflow-hidden transition-[max-width,opacity] duration-200 motion-reduce:transition-none',
          compact ? 'max-w-0 opacity-0' : 'max-w-48 opacity-100',
          wordmarkClassName,
        )}
      >
        FitCheck<span className="font-normal text-muted-foreground"> AI</span>
      </span>
    </span>
  )
}
