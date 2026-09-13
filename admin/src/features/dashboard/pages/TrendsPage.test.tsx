import { cleanup, screen } from '@testing-library/react'
import type { RouteObject } from 'react-router-dom'
import { describe, expect, it } from 'vitest'

import { TrendsPage } from './TrendsPage'

import { useSessionStore } from '@/shared/stores/sessionStore'
import { renderWithProviders } from '@/test/utils'

function authedAs(permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions })
}

describe('TrendsPage (redirect to single-page dashboard)', () => {
  it('redirects /dashboard/trends to /dashboard?section=trends', async () => {
    authedAs(['*'])
    const routes: RouteObject[] = [
      { path: '/dashboard/trends', element: <TrendsPage /> },
      { path: '/dashboard', element: <div>dashboard-marker</div> },
    ]
    const { router } = renderWithProviders(<TrendsPage />, {
      routes,
      initialEntries: ['/dashboard/trends'],
    })

    // Navigate (replace) should land on /dashboard?section=trends
    expect(await screen.findByText('dashboard-marker')).toBeInTheDocument()
    expect(router.state.location.pathname).toBe('/dashboard')
    expect(router.state.location.search).toContain('section=trends')
  })

  it('preserves valid ?days param when redirecting', async () => {
    authedAs(['*'])
    const routes: RouteObject[] = [
      { path: '/dashboard/trends', element: <TrendsPage /> },
      { path: '/dashboard', element: <div>dashboard-marker</div> },
    ]
    const { router } = renderWithProviders(<TrendsPage />, {
      routes,
      initialEntries: ['/dashboard/trends?days=90'],
    })

    expect(await screen.findByText('dashboard-marker')).toBeInTheDocument()
    expect(router.state.location.search).toContain('days=90')
    expect(router.state.location.search).toContain('section=trends')
  })

  it('preserves days=7/15/30 and drops invalid days', async () => {
    authedAs(['*'])
    const routes: RouteObject[] = [
      { path: '/dashboard/trends', element: <TrendsPage /> },
      { path: '/dashboard', element: <div>dashboard-marker</div> },
    ]
    const { router: router7 } = renderWithProviders(<TrendsPage />, {
      routes,
      initialEntries: ['/dashboard/trends?days=7'],
    })
    expect(await screen.findByText('dashboard-marker')).toBeInTheDocument()
    expect(router7.state.location.search).toContain('days=7')

    // Unmount the first tree so the two renders cannot interfere.
    cleanup()

    // Invalid days should be stripped, only section remains
    const routes2: RouteObject[] = [
      { path: '/dashboard/trends', element: <TrendsPage /> },
      { path: '/dashboard', element: <div>dashboard-marker-2</div> },
    ]
    const { router: routerInvalid } = renderWithProviders(<TrendsPage />, {
      routes: routes2,
      initialEntries: ['/dashboard/trends?days=999'],
    })
    expect(await screen.findByText('dashboard-marker-2')).toBeInTheDocument()
    expect(routerInvalid.state.location.search).not.toContain('days=999')
    expect(routerInvalid.state.location.search).toContain('section=trends')
  })
})
