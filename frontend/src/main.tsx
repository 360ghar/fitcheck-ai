import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { HelmetProvider } from 'react-helmet-async'
import { initAnalytics } from './lib/analytics'
import { captureException, initErrorReporting } from './lib/error-reporting'
import { preloadRoute } from './routes/publicRoutes'
import App from './App'
import { Toaster } from './components/ui/toaster'
import { TooltipProvider } from './components/ui/tooltip'
import { UpgradePromptDialog } from './components/common/UpgradePromptDialog'
import ErrorBoundary from './components/errors/ErrorBoundary'
import { ThemeProvider } from './components/theme/ThemeProvider'
// Fonts are declared directly in index.css against the family names
// tailwind.config.ts uses, and preloaded from index.html. See the comment at
// the top of index.css for why the @fontsource-variable packages were dropped.
import './index.css'

// Sentry and PostHog are both loaded lazily, after first paint. Statically
// importing them here put ~370 kB (PostHog) plus the Sentry SDK into the entry
// chunk, on the critical path of every marketing pageview. See
// lib/error-reporting.ts and lib/analytics.ts.
initErrorReporting()
initAnalytics()

// ============================================================================
// GLOBAL ERROR HANDLERS
// ============================================================================
// Catch errors that escape React's render tree (async code, timers, event
// handlers) so they are observable instead of silently swallowed.
// `captureException` always logs locally and forwards to Sentry when a DSN is
// configured.

window.addEventListener('unhandledrejection', (event: PromiseRejectionEvent) => {
  captureException(event.reason ?? new Error('Unhandled promise rejection'))
})

window.addEventListener('error', (event: ErrorEvent) => {
  captureException(event.error ?? event.message)
})

// Create a client for React Query
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      gcTime: 1000 * 60 * 10, // 10 minutes (formerly cacheTime)
      // Transport-level retries live in the axios error interceptor
      // (network + 408/429/5xx, up to 3 attempts with backoff). Do NOT add a
      // second retry layer here — a React Query retry re-runs the whole axios
      // chain (and its toasts) for the same logical failure.
      retry: 0,
      refetchOnWindowFocus: false,
    },
    mutations: {
      retry: 0,
    },
  },
})

// PostHog's init options (autocapture, session recording, masking) moved into
// lib/analytics.ts alongside the lazy import. There is no <PostHogProvider>
// any more — PostHogIdentify subscribes to the deferred load directly.
const tree = (
  <StrictMode>
    <HelmetProvider>
      <ErrorBoundary>
        {/* Must match the pre-hydration script in index.html, which resolves
            `system`. A `light` default here repainted over the script's dark
            class on mount — the dark→light flash, and the reason a
            system-dark user never got dark mode. */}
        <ThemeProvider defaultTheme="system">
          <QueryClientProvider client={queryClient}>
            <BrowserRouter>
              <TooltipProvider delayDuration={0}>
                <App />
                <Toaster />
                <UpgradePromptDialog />
              </TooltipProvider>
            </BrowserRouter>
          </QueryClientProvider>
        </ThemeProvider>
      </ErrorBoundary>
    </HelmetProvider>
  </StrictMode>
)

function mount() {
  createRoot(document.getElementById('root')!).render(tree)
}

// The public routes are prerendered into #root at build time, so real content
// is already painted before this script runs. createRoot() clears that markup
// and renders fresh — which would flash the Suspense spinner if the matched
// page were still an unresolved lazy chunk. Resolving it first means React
// swaps the prerendered DOM for the real one in a single commit, with no blank
// or spinner frame in between. preloadRoute never rejects and no-ops on routes
// that are not public, so a failure here still renders through Suspense.
//
// The race is load-bearing, not a nicety. A chunk request that STALLS without
// rejecting (flaky mobile connection, captive portal) never settles the promise,
// so `.finally(mount)` alone left React unmounted forever: the prerendered HTML
// looks like a finished page while the nav toggle, theme toggle, consent
// controls and every button are inert, with no spinner or error to explain it.
// Mounting is never gated on the network — the preload is an optimisation, and
// past this deadline Suspense + ErrorBoundary handle the chunk as usual.
const PRELOAD_BUDGET_MS = 1500

Promise.race([
  preloadRoute(window.location.pathname),
  new Promise((resolve) => setTimeout(resolve, PRELOAD_BUDGET_MS)),
]).finally(mount)
