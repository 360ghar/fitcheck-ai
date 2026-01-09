import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { HelmetProvider } from 'react-helmet-async'
import { PostHogProvider } from 'posthog-js/react'
import App from './App'
import { Toaster } from './components/ui/toaster'
import { TooltipProvider } from './components/ui/tooltip'
import ErrorBoundary from './components/errors/ErrorBoundary'
import { ThemeProvider } from './components/theme'
import './index.css'

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
          <ThemeProvider defaultTheme="system">
            <QueryClientProvider client={queryClient}>
              <BrowserRouter>
                <TooltipProvider delayDuration={0}>
                  <App />
                  <Toaster />
                </TooltipProvider>
              </BrowserRouter>
            </QueryClientProvider>
          </ThemeProvider>
        </ErrorBoundary>
      </HelmetProvider>
    </PostHogProvider>
  </StrictMode>,
)

