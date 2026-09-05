import type { LucideIcon } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'

export type EmptyStateTone = 'coral' | 'amber' | 'teal' | 'violet' | 'blue' | 'neutral'

export interface EmptyStateProps {
  icon?: LucideIcon
  title: string
  description?: string
  actionLabel?: string
  onAction?: () => void
  secondaryLabel?: string
  onSecondary?: () => void
  className?: string
  children?: React.ReactNode
  /** Editorial tint for the mark. `neutral` keeps the old muted look. */
  tone?: EmptyStateTone
}

// Literal class map: Tailwind's JIT needs complete class names at scan time.
const TONE_ICON: Record<EmptyStateTone, string> = {
  coral: 'text-tint-coral',
  amber: 'text-tint-amber',
  teal: 'text-tint-teal',
  violet: 'text-tint-violet',
  blue: 'text-tint-blue',
  neutral: 'text-muted-foreground/70',
}

// Faint wash of the same tint behind the panel (30% over the card surface —
// near-invisible tint, not a flooded fill). `neutral` keeps the plain card.
const TONE_WASH: Record<EmptyStateTone, string> = {
  coral: 'bg-tint-coral-pale/30',
  amber: 'bg-tint-amber-pale/30',
  teal: 'bg-tint-teal-pale/30',
  violet: 'bg-tint-violet-pale/30',
  blue: 'bg-tint-blue-pale/30',
  neutral: 'bg-card',
}

export function EmptyState({
  icon: Icon,
  title,
  description,
  actionLabel,
  onAction,
  secondaryLabel,
  onSecondary,
  className,
  children,
  tone = 'teal',
}: EmptyStateProps) {
  return (
    <div
      className={cn(
        'text-center py-12 px-4 rounded-2xl border border-border/60',
        TONE_WASH[tone],
        className
      )}
    >
      {/* Bare mark, no tile behind it. A filled circle around an icon is the
          component-kit default; the icon carries itself at this size. The
          editorial tint gives the mark warmth without adding a chip. */}
      {Icon && (
        <Icon
          className={cn('mx-auto mb-4 h-10 w-10 md:h-12 md:w-12', TONE_ICON[tone])}
          strokeWidth={1.25}
          aria-hidden
        />
      )}
      <h3 className="text-base md:text-lg font-medium text-foreground">{title}</h3>
      {description && (
        <p className="mt-2 text-sm text-muted-foreground max-w-sm mx-auto">{description}</p>
      )}
      {children}
      {(actionLabel || secondaryLabel) && (
        <div className="mt-6 flex flex-col sm:flex-row items-center justify-center gap-2">
          {actionLabel && onAction && (
            <Button onClick={onAction}>{actionLabel}</Button>
          )}
          {secondaryLabel && onSecondary && (
            <Button variant="outline" onClick={onSecondary}>
              {secondaryLabel}
            </Button>
          )}
        </div>
      )}
    </div>
  )
}
