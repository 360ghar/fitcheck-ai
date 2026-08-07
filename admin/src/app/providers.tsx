import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ThemeProvider } from 'next-themes'
import { RouterProvider } from 'react-router-dom'

import { createAppRouter } from '@/routes'
import { QUERY_RETRY, QUERY_STALE_TIMES, STORAGE_KEYS } from '@/shared/lib/constants'
import { Toaster } from '@/shared/ui/sonner'
import { TooltipProvider } from '@/shared/ui/tooltip'

/**
 * App providers (spec §6). Query defaults: 30s staleness for lists, retry 2
 * on GET (idempotent), never auto-retry mutations, no window-focus refetch
 * except critical lists (ops health overrides it per-query).
 */
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: QUERY_STALE_TIMES.lists,
      retry: QUERY_RETRY.get,
      refetchOnWindowFocus: false,
    },
    mutations: {
      retry: QUERY_RETRY.mutations,
    },
  },
})

const router = createAppRouter()

export function Providers() {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider
        attribute="class"
        defaultTheme="light"
        enableSystem
        storageKey={STORAGE_KEYS.theme}
        disableTransitionOnChange
      >
        <TooltipProvider delayDuration={200}>
          <Toaster />
          <RouterProvider router={router} />
        </TooltipProvider>
      </ThemeProvider>
    </QueryClientProvider>
  )
}
