/**
 * Brand mark and wordmark. The mark is three paper tees fanned from the hem;
 * the collar cut is a check mark. Master: docs/brand/mark.svg. The mark is
 * always bare: never set it on a tile or a circle.
 */

import { useId } from 'react'
import { cn } from '@/lib/utils'

const TEE =
  'M36 18 L45 31 L67 18 L77 19.5 L93 35 L83 46.5 L74.5 40.5 L73 86 L27 86 L25.5 40.5 L17 46.5 L7 35 L23 19.5 Z'

/** Paper colours shared with the mobile app (docs/brand/README.md). */
const LAYERS = [
  { rotate: -13, slab: '#1B2E47', sheet: '#2E4A6E' },
  { rotate: 13, slab: '#6E510C', sheet: '#F2C75C' },
  { rotate: 0, slab: '#9E0010', sheet: '#E00016' },
] as const

interface BrandMarkProps {
  /** Rendered width in px; the height follows the mark's aspect ratio. */
  size?: number
  className?: string
}

export function BrandMark({ size = 32, className }: BrandMarkProps) {
  const id = useId()
  return (
    <svg
      viewBox="-9.5 10.5 120 88.7"
      width={size}
      height={Math.round((size * 88.7) / 120)}
      className={cn('shrink-0', className)}
      aria-hidden="true"
      focusable="false"
    >
      <defs>
        <path id={id} d={TEE} strokeLinejoin="round" strokeWidth={1.4} />
      </defs>
      {LAYERS.map((layer) => (
        <g key={layer.sheet} transform={`rotate(${layer.rotate} 50 92)`}>
          <use href={`#${id}`} transform="translate(1.6 2.8)" fill={layer.slab} stroke={layer.slab} />
          <use href={`#${id}`} fill={layer.sheet} stroke={layer.sheet} />
        </g>
      ))}
    </svg>
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
    <span className={cn('flex items-center gap-2', className)}>
      <BrandMark size={markSize} />
      <span
        className={cn(
          'whitespace-nowrap font-semibold tracking-tight text-foreground',
          compact && 'sr-only',
          wordmarkClassName,
        )}
      >
        FitCheck<span className="font-normal text-muted-foreground"> AI</span>
      </span>
    </span>
  )
}
