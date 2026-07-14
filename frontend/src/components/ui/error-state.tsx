import type { LucideIcon } from 'lucide-react'
import { AlertTriangle, RefreshCw } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'

export interface ErrorStateProps {
  icon?: LucideIcon
  title?: string
  description?: string
  onRetry?: () => void
  retryLabel?: string
  className?: string
}

export function ErrorState({
  icon: Icon = AlertTriangle,
  title = 'Something went wrong',
  description,
  onRetry,
  retryLabel = 'Try again',
  className,
}: ErrorStateProps) {
  return (
    <div
      className={cn(
        'text-center py-12 px-4 bg-card rounded-xl border border-destructive/20',
        className
      )}
      role="alert"
    >
      <Icon className="mx-auto h-12 w-12 md:h-14 md:w-14 text-destructive/60" />
      <h3 className="mt-4 text-lg font-medium text-foreground">{title}</h3>
      {description && (
        <p className="mt-2 text-sm text-muted-foreground max-w-md mx-auto">{description}</p>
      )}
      {onRetry && (
        <Button className="mt-6" onClick={onRetry}>
          <RefreshCw className="h-4 w-4 mr-2" />
          {retryLabel}
        </Button>
      )}
    </div>
  )
}
