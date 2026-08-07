import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, type RenderOptions, type RenderResult } from '@testing-library/react'
import { ThemeProvider } from 'next-themes'
import type { ReactElement, ReactNode } from 'react'
import { createMemoryRouter, RouterProvider, type RouteObject } from 'react-router-dom'

import { STORAGE_KEYS } from '@/shared/lib/constants'
import { Toaster } from '@/shared/ui/sonner'
import { TooltipProvider } from '@/shared/ui/tooltip'

/**
 * Test render utilities. Renders inside the real provider stack (Query +
 * Theme + Tooltip + Toaster) and a memory router, so components exercise the
 * same context they get in production.
 */

export function createTestQueryClient(): QueryClient {
  return new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
        // Some queries pass an explicit `retry` (e.g. QUERY_RETRY.get) which
        // overrides this default — keep those retries instant in tests so
        // error states surface immediately instead of after the 1s backoff.
        retryDelay: 0,
      },
    },
  })
}

/** Shared client cleared after each test (spec §7). */
export const sharedTestQueryClient = createTestQueryClient()

export interface RenderWithProvidersOptions extends Omit<RenderOptions, 'wrapper'> {
  /** Router routes; defaults to a single `*` route rendering `ui` */
  routes?: RouteObject[]
  initialEntries?: string[]
}

export function renderWithProviders(
  ui: ReactElement,
  options: RenderWithProvidersOptions = {},
): RenderResult & { router: ReturnType<typeof createMemoryRouter>; queryClient: QueryClient } {
  const queryClient = createTestQueryClient()
  const routes: RouteObject[] = options.routes ?? [{ path: '*', element: ui }]
  const router = createMemoryRouter(routes, {
    initialEntries: options.initialEntries ?? ['/'],
  })

  function Providers(): ReactNode {
    return (
      <QueryClientProvider client={queryClient}>
        <ThemeProvider
          attribute="class"
          defaultTheme="light"
          enableSystem={false}
          storageKey={STORAGE_KEYS.theme}
        >
          <TooltipProvider delayDuration={0}>
            <Toaster />
            <RouterProvider router={router} />
          </TooltipProvider>
        </ThemeProvider>
      </QueryClientProvider>
    )
  }

  const result = render(<Providers />, options)
  return { ...result, router, queryClient }
}
