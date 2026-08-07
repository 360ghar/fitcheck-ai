import * as Sentry from '@sentry/react'
import * as React from 'react'
import { useTranslation } from 'react-i18next'

import { env } from '@/config/env'
import { generateCorrelationId } from '@/shared/lib/correlation'
import { ErrorState } from '@/shared/ui/ErrorState'

/**
 * Global error boundary — catches render/effect errors, reports to Sentry
 * (when a DSN is configured), and shows a themed fallback with a correlation
 * id and a reload action.
 */
export interface ErrorBoundaryProps {
  children: React.ReactNode
  /** Extra context reported to Sentry (e.g. feature name) */
  label?: string
  /** Called with the error after it is caught (tests spy on this) */
  onError?: (error: Error, info: React.ErrorInfo) => void
}

interface ErrorBoundaryState {
  hasError: boolean
  error: Error | null
  correlationId: string
}

export class ErrorBoundary extends React.Component<ErrorBoundaryProps, ErrorBoundaryState> {
  state: ErrorBoundaryState = {
    hasError: false,
    error: null,
    correlationId: generateCorrelationId(),
  }

  static getDerivedStateFromError(error: Error): Partial<ErrorBoundaryState> {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, info: React.ErrorInfo): void {
    const { label, onError } = this.props
    if (env.VITE_SENTRY_DSN) {
      Sentry.captureException(error, {
        tags: { boundary: label ?? 'global' },
        extra: { correlationId: this.state.correlationId, componentStack: info.componentStack },
      })
    }
    onError?.(error, info)
  }

  private handleReset = (): void => {
    this.setState({ hasError: false, error: null, correlationId: generateCorrelationId() })
  }

  render(): React.ReactNode {
    if (!this.state.hasError) return this.props.children
    return <ErrorBoundaryFallback error={this.state.error} correlationId={this.state.correlationId} onReset={this.handleReset} />
  }
}

function ErrorBoundaryFallback({
  error,
  correlationId,
  onReset,
}: {
  error: Error | null
  correlationId: string
  onReset: () => void
}) {
  const { t } = useTranslation('errors')
  return (
    <div className="flex min-h-dvh items-center justify-center bg-background p-6">
      <div className="w-full max-w-lg">
        <ErrorState
          title={t('boundary.title')}
          message={t('boundary.message')}
          correlationId={correlationId}
          onRetry={() => {
            onReset()
          }}
          action={
            <button
              type="button"
              onClick={() => window.location.reload()}
              className="rounded-md border border-border px-4 py-2 text-sm font-semibold transition-colors hover:bg-surface-card focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50"
            >
              {t('boundary.reload')}
            </button>
          }
        />
        {error && import.meta.env.DEV ? (
          <pre className="mt-4 max-h-48 overflow-auto rounded-md border border-border bg-surface-card p-3 text-xs text-muted-foreground">
            {String(error.message)}
          </pre>
        ) : null}
      </div>
    </div>
  )
}
