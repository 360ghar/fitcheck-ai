import * as React from 'react'
import { cn } from '@/lib/utils'

export interface PinGridProps extends React.HTMLAttributes<HTMLDivElement> {}

/**
 * Column masonry intentionally preserves source image proportions. Children are
 * blocks rather than CSS-grid items, so portrait garment imagery is never cropped.
 */
export function PinGrid({ className, ...props }: PinGridProps) {
  return (
    <div
      className={cn(
        'columns-2 gap-xs sm:columns-3 md:columns-4 lg:columns-5 xl:columns-6 2xl:columns-7',
        '[&>*]:mb-xs [&>*]:break-inside-avoid',
        className,
      )}
      {...props}
    />
  )
}

export interface PinOverlayPillProps extends React.HTMLAttributes<HTMLSpanElement> {}

export function PinOverlayPill({ className, ...props }: PinOverlayPillProps) {
  // Floats over garment imagery, so it uses the theme-invariant on-image pair
  // rather than the page surface — see the note in src/index.css.
  return <span className={cn('rounded-full bg-on-image px-3 py-2 text-xs font-bold leading-none text-on-image-foreground', className)} {...props} />
}

export interface PinCreatorProps {
  name: string
  avatarUrl?: string
}

export function PinCreator({ name, avatarUrl }: PinCreatorProps) {
  return (
    <span className="flex min-w-0 items-center gap-2 bg-on-image/95 px-2 py-1.5 text-xs font-bold text-on-image-foreground">
      {avatarUrl ? <img src={avatarUrl} alt="" width={32} height={32} className="h-8 w-8 rounded-full object-cover" /> : <span className="flex h-8 w-8 items-center justify-center rounded-full bg-on-image-foreground/10">{name.slice(0, 1)}</span>}
      <span className="truncate">{name}</span>
    </span>
  )
}
