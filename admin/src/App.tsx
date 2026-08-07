import { Providers } from '@/app/providers'
import { ErrorBoundary } from '@/shared/ui/ErrorBoundary'


/**
 * Root component: global error boundary around the provider stack.
 * Feature-level boundaries (FeatureErrorBoundary) sit closer to the data.
 */
export default function App() {
  return (
    <ErrorBoundary label="app">
      <Providers />
    </ErrorBoundary>
  )
}
