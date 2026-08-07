import { RotateCcw, TriangleAlert } from 'lucide-react'
import { useTranslation } from 'react-i18next'

import { cn } from '@/shared/lib/cn'
import { Button } from '@/shared/ui/button'

/**
 * Error state — retry + support context (correlation ID), per spec §5.
 */
export interface ErrorStateProps {
  title?: string
  message?: string
  /** Show a retry button */
  onRetry?: () => void
  /** Correlation id shown as support context */
  correlationId?: string
  /** Extra actions next to Retry */
  action?: React.ReactNode
  className?: string
}

export function ErrorState({
  title,
  message,
  onRetry,
  correlationId,
  action,
  className,
}: ErrorStateProps) {
  const { t } = useTranslation('errors')
  return (
    <div
      role="alert"
      className={cn(
        'flex flex-col items-center gap-2 rounded-md border border-destructive/30 bg-destructive/5 px-6 py-10 text-center',
        className,
      )}
    >
      <TriangleAlert className="size-8 text-destructive" aria-hidden="true" />
      <h3 className="text-base font-semibold text-foreground">{title ?? t('generic.title')}</h3>
      {message ? <p className="max-w-md text-sm text-muted-foreground">{message}</p> : null}
      {correlationId ? (
        <p className="text-xs text-muted-foreground">
          <span className="font-medium">{t('correlationId')}:</span> {correlationId}
        </p>
      ) : null}
      {(onRetry || action) && (
        <div className="mt-2 flex items-center gap-2">
          {onRetry ? (
            <Button variant="secondary" onClick={onRetry}>
              <RotateCcw aria-hidden="true" />
              {t('retry')}
            </Button>
          ) : null}
          {action}
        </div>
      )}
    </div>
  )
}
