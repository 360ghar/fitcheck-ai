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
        'text-center py-12 px-4 bg-card rounded-xl border border-border/60',
        className
      )}
    >
      {Icon && (
        <div className="mx-auto mb-4 flex h-16 w-16 md:h-20 md:w-20 items-center justify-center rounded-full bg-muted">
          <Icon className="h-8 w-8 md:h-10 md:w-10 text-muted-foreground" />
        </div>
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
