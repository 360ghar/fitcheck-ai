import { Component, ErrorInfo, ReactNode } from 'react'
import { AlertTriangle, ChevronDown, ChevronUp, Home, RefreshCw } from 'lucide-react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error: Error | null
  errorInfo: ErrorInfo | null
  isDetailsExpanded: boolean
}

class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null,
      isDetailsExpanded: false,
    }
  }

  static getDerivedStateFromError(error: Error): Partial<State> {
    // Update state so the next render will show the fallback UI
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo): void {
    // Log the error to console (could also log to an error reporting service)
    console.error('ErrorBoundary caught an error:', error)
    console.error('Error info:', errorInfo)

    this.setState({ errorInfo })
  }

  handleReset = (): void => {
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null,
      isDetailsExpanded: false,
    })
  }

  handleGoHome = (): void => {
    // Reset state and navigate to home
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null,
      isDetailsExpanded: false,
    })
    window.location.href = '/'
  }

  toggleDetails = (): void => {
    this.setState((prevState) => ({
      isDetailsExpanded: !prevState.isDetailsExpanded,
    }))
  }

  render(): ReactNode {
    if (this.state.hasError) {
      // Custom fallback UI if provided
      if (this.props.fallback) {
        return this.props.fallback
      }

      const isDevelopment = import.meta.env.DEV
      const { error, errorInfo, isDetailsExpanded } = this.state

      return (
        <div className="min-h-screen bg-background flex items-center justify-center p-4">
          <div className="max-w-lg w-full bg-card rounded-2xl shadow-lg border border-border p-8">
            {/* Error Icon */}
            <div className="flex justify-center mb-6">
              <div className="w-20 h-20 rounded-full bg-destructive/10 flex items-center justify-center">
                <AlertTriangle className="w-10 h-10 text-destructive" />
              </div>
            </div>

            {/* Error Message */}
            <h1 className="text-2xl font-bold text-foreground text-center mb-2">
              Something went wrong
            </h1>
            <p className="text-muted-foreground text-center mb-8">
              We&apos;re sorry, but something unexpected happened. Please try again or return to the home page.
            </p>

            {/* Action Buttons */}
            <div className="flex flex-col sm:flex-row gap-3 mb-6">
              <button
                type="button"
                onClick={this.handleReset}
                className="flex-1 flex items-center justify-center gap-2 px-6 py-3 bg-primary hover:bg-primary/90 text-primary-foreground font-medium rounded-xl transition-colors touch-target"
              >
                <RefreshCw className="w-5 h-5" />
                Try Again
              </button>
              <button
                type="button"
                onClick={this.handleGoHome}
                className="flex-1 flex items-center justify-center gap-2 px-6 py-3 bg-muted hover:bg-muted/80 text-foreground font-medium rounded-xl transition-colors touch-target"
              >
                <Home className="w-5 h-5" />
                Go Home
              </button>
            </div>

            {/* Development Error Details */}
            {isDevelopment && error && (
              <div className="border-t border-border pt-6">
                <button
                  type="button"
                  onClick={this.toggleDetails}
                  className="flex items-center justify-between w-full text-left text-sm text-muted-foreground hover:text-foreground transition-colors"
                >
                  <span className="font-medium">Error Details (Development Only)</span>
                  {isDetailsExpanded ? (
                    <ChevronUp className="w-4 h-4" />
                  ) : (
                    <ChevronDown className="w-4 h-4" />
                  )}
                </button>

                {isDetailsExpanded && (
                  <div className="mt-4 space-y-4">
                    {/* Error Message */}
                    <div>
                      <h3 className="text-xs font-semibold text-destructive uppercase tracking-wide mb-2">
                        Error Message
                      </h3>
                      <div className="bg-muted rounded-lg p-3 overflow-x-auto">
                        <code className="text-sm text-destructive break-all">
                          {error.message}
                        </code>
                      </div>
                    </div>

                    {/* Stack Trace */}
                    {error.stack && (
                      <div>
                        <h3 className="text-xs font-semibold text-muted-foreground uppercase tracking-wide mb-2">
                          Stack Trace
                        </h3>
                        <div className="bg-muted rounded-lg p-3 overflow-x-auto max-h-48 overflow-y-auto">
                          <pre className="text-xs text-muted-foreground whitespace-pre-wrap break-all">
                            {error.stack}
                          </pre>
                        </div>
                      </div>
                    )}

                    {/* Component Stack */}
                    {errorInfo?.componentStack && (
                      <div>
                        <h3 className="text-xs font-semibold text-muted-foreground uppercase tracking-wide mb-2">
                          Component Stack
                        </h3>
                        <div className="bg-muted rounded-lg p-3 overflow-x-auto max-h-48 overflow-y-auto">
                          <pre className="text-xs text-muted-foreground whitespace-pre-wrap break-all">
                            {errorInfo.componentStack}
                          </pre>
                        </div>
                      </div>
                    )}
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      )
    }

    return this.props.children
  }
}

export default ErrorBoundary
