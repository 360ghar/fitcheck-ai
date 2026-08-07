import { Component, ErrorInfo, ReactNode } from 'react'
import { AlertTriangle, RefreshCw } from 'lucide-react'
import { captureException } from '../../lib/error-reporting'
import { logger } from '../../lib/logger'

interface Props {
  /** Human-readable feature name shown in the error message. */
  featureName: string
  children: ReactNode
  /** Optional fully custom fallback. When omitted, an inline error card renders. */
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error: Error | null
}

/**
 * A lightweight error boundary for individual feature sections.
 *
 * Unlike the top-level `ErrorBoundary` (full-screen), this renders a compact
 * inline card so a failure in one feature (e.g. recommendations) does not take
 * down the whole page. "Try Again" resets the boundary and re-mounts children.
 */
class FeatureErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false, error: null }
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo): void {
    logger.error(`[FeatureErrorBoundary:${this.props.featureName}]`, error, errorInfo)
    captureException(error, {
      extra: { feature: this.props.featureName, componentStack: errorInfo.componentStack },
    })
  }

  handleRetry = (): void => {
    this.setState({ hasError: false, error: null })
  }

  render(): ReactNode {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback
      }

      const isDevelopment = import.meta.env.DEV

      return (
        <div
          role="alert"
          className="my-4 rounded-xl border border-destructive/30 bg-destructive/5 p-6"
        >
          <div className="flex items-start gap-3">
            <div className="shrink-0 rounded-full bg-destructive/10 p-2">
              <AlertTriangle className="h-5 w-5 text-destructive" />
            </div>
            <div className="min-w-0 flex-1">
              <h3 className="font-semibold text-foreground">
                Something went wrong in {this.props.featureName}
              </h3>
              <p className="mt-1 text-sm text-muted-foreground">
                This section hit an unexpected error. The rest of the app is still
                working — you can try loading it again.
              </p>

              {isDevelopment && this.state.error && (
                <pre className="mt-3 overflow-x-auto rounded-lg bg-muted p-3 text-xs text-destructive whitespace-pre-wrap break-all">
                  {this.state.error.message}
                </pre>
              )}

              <button
                type="button"
                onClick={this.handleRetry}
                className="mt-4 inline-flex items-center gap-2 rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
              >
                <RefreshCw className="h-4 w-4" />
                Try Again
              </button>
            </div>
          </div>
        </div>
      )
    }

    return this.props.children
  }
}

export default FeatureErrorBoundary
