import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { HelmetProvider } from 'react-helmet-async'
import { PostHogProvider } from 'posthog-js/react'
import * as Sentry from '@sentry/react'
import { logger } from './lib/logger'
import App from './App'
import { Toaster } from './components/ui/toaster'
import { TooltipProvider } from './components/ui/tooltip'
import { UpgradePromptDialog } from './components/common/UpgradePromptDialog'
import ErrorBoundary from './components/errors/ErrorBoundary'
import { ThemeProvider } from './components/theme/ThemeProvider'
import '@fontsource-variable/plus-jakarta-sans'
import './index.css'

// Sentry error tracking — only initializes when a DSN is configured.
const sentryDsn = import.meta.env.VITE_SENTRY_DSN
if (sentryDsn) {
  Sentry.init({
    dsn: sentryDsn,
    tracesSampleRate: 0.1,
    environment: import.meta.env.MODE,
  })
}

// ============================================================================
// GLOBAL ERROR HANDLERS
// ============================================================================
// Catch errors that escape React's render tree (async code, timers, event
// handlers) so they are observable instead of silently swallowed. Reports to
// Sentry when a DSN is configured; always logs for local debugging.

window.addEventListener('unhandledrejection', (event: PromiseRejectionEvent) => {
  logger.error('[Unhandled Rejection]', event.reason)
  if (sentryDsn) {
    Sentry.captureException(
      event.reason instanceof Error
        ? event.reason
        : new Error(String(event.reason ?? 'Unhandled promise rejection'))
    )
  }
})

window.addEventListener('error', (event: ErrorEvent) => {
  logger.error('[Global Error]', event.error ?? event.message)
  if (sentryDsn && event.error) {
    Sentry.captureException(event.error)
  }
})

// Create a client for React Query
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      gcTime: 1000 * 60 * 10, // 10 minutes (formerly cacheTime)
      retry: 1,
      refetchOnWindowFocus: false,
    },
    mutations: {
      retry: 1,
    },
  },
})

// PostHog configuration with all features enabled
const posthogOptions = {
  api_host: import.meta.env.VITE_PUBLIC_POSTHOG_HOST,
  person_profiles: 'always' as const,
  capture_pageview: true,
  capture_pageleave: true,
  autocapture: true,
  // Persist identity + session across reloads so product sessions stay linked.
  persistence: 'localStorage+cookie' as const,
  session_recording: {
    maskAllInputs: false,
    maskInputFn: (text: string, element?: HTMLElement) => {
      // Mask password and sensitive fields
      if (element?.getAttribute('type') === 'password') {
        return '*'.repeat(text.length)
      }
      return text
    },
  },
  disable_session_recording: false,
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <PostHogProvider
      apiKey={import.meta.env.VITE_PUBLIC_POSTHOG_KEY}
      options={posthogOptions}
    >
      <HelmetProvider>
        <ErrorBoundary>
          <ThemeProvider defaultTheme="light">
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
    </PostHogProvider>
  </StrictMode>,
)

