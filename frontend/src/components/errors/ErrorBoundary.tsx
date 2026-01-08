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
        <div className="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 flex items-center justify-center p-4">
          <div className="max-w-lg w-full bg-gray-800/50 backdrop-blur-xl rounded-2xl shadow-2xl border border-gray-700/50 p-8">
            {/* Error Icon */}
            <div className="flex justify-center mb-6">
              <div className="w-20 h-20 rounded-full bg-red-500/20 flex items-center justify-center">
                <AlertTriangle className="w-10 h-10 text-red-400" />
              </div>
            </div>

            {/* Error Message */}
            <h1 className="text-2xl font-bold text-white text-center mb-2">
              Something went wrong
            </h1>
            <p className="text-gray-400 text-center mb-8">
              We're sorry, but something unexpected happened. Please try again or return to the home page.
            </p>

            {/* Action Buttons */}
            <div className="flex flex-col sm:flex-row gap-3 mb-6">
              <button
                onClick={this.handleReset}
                className="flex-1 flex items-center justify-center gap-2 px-6 py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-medium rounded-xl transition-all duration-200 hover:shadow-lg hover:shadow-indigo-500/25"
              >
                <RefreshCw className="w-5 h-5" />
                Try Again
              </button>
              <button
                onClick={this.handleGoHome}
                className="flex-1 flex items-center justify-center gap-2 px-6 py-3 bg-gray-700 hover:bg-gray-600 text-white font-medium rounded-xl transition-all duration-200 hover:shadow-lg"
              >
                <Home className="w-5 h-5" />
                Go Home
              </button>
            </div>

            {/* Development Error Details */}
            {isDevelopment && error && (
              <div className="border-t border-gray-700/50 pt-6">
                <button
                  onClick={this.toggleDetails}
                  className="flex items-center justify-between w-full text-left text-sm text-gray-400 hover:text-gray-300 transition-colors"
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
                      <h3 className="text-xs font-semibold text-red-400 uppercase tracking-wide mb-2">
                        Error Message
                      </h3>
                      <div className="bg-gray-900/50 rounded-lg p-3 overflow-x-auto">
                        <code className="text-sm text-red-300 break-all">
                          {error.message}
                        </code>
                      </div>
                    </div>

                    {/* Stack Trace */}
                    {error.stack && (
                      <div>
                        <h3 className="text-xs font-semibold text-orange-400 uppercase tracking-wide mb-2">
                          Stack Trace
                        </h3>
                        <div className="bg-gray-900/50 rounded-lg p-3 overflow-x-auto max-h-48 overflow-y-auto">
                          <pre className="text-xs text-gray-400 whitespace-pre-wrap break-all">
                            {error.stack}
                          </pre>
                        </div>
                      </div>
                    )}

                    {/* Component Stack */}
                    {errorInfo?.componentStack && (
                      <div>
                        <h3 className="text-xs font-semibold text-yellow-400 uppercase tracking-wide mb-2">
                          Component Stack
                        </h3>
                        <div className="bg-gray-900/50 rounded-lg p-3 overflow-x-auto max-h-48 overflow-y-auto">
                          <pre className="text-xs text-gray-400 whitespace-pre-wrap break-all">
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
