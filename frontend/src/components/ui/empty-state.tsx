import type { LucideIcon } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'

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
}: EmptyStateProps) {
  return (
    <div
      className={cn(
        'text-center py-12 px-4 bg-card rounded-2xl border border-border/60',
        className
      )}
    >
      {/* Bare mark, no tile behind it. A filled circle around an icon is the
          component-kit default; the icon carries itself at this size. */}
      {Icon && (
        <Icon
          className="mx-auto mb-4 h-10 w-10 md:h-12 md:w-12 text-muted-foreground/70"
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
