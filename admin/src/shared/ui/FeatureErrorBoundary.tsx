import { ErrorBoundary } from '@/shared/ui/ErrorBoundary'

/**
 * Per-feature error boundary (spec §2) — same fallback as the global
 * boundary but tagged with the feature name for Sentry. Remount it with a
 * changing `resetKey` (e.g. the route location) to recover from a feature
 * crash without reloading the whole app.
 */
export interface FeatureErrorBoundaryProps {
  feature: string
  resetKey?: string
  children: React.ReactNode
}

export function FeatureErrorBoundary({ feature, resetKey, children }: FeatureErrorBoundaryProps) {
  return (
    <ErrorBoundary key={resetKey} label={feature}>
      {children}
    </ErrorBoundary>
  )
}
