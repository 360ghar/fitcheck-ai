import { screen } from '@testing-library/react'
import type { RouteObject } from 'react-router-dom'
import { describe, expect, it } from 'vitest'

import { IapTransactionsPage } from './IapTransactionsPage'

import { useSessionStore } from '@/shared/stores/sessionStore'
import { renderWithProviders } from '@/test/utils'

function authedAs(permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions })
}

describe('IapTransactionsPage (redirect to Subscriptions)', () => {
  it('redirects /iap to the unfiltered subscriptions view by default', async () => {
    authedAs(['*'])
    const routes: RouteObject[] = [
      { path: '/iap', element: <IapTransactionsPage /> },
      { path: '/subscriptions', element: <div>subscriptions-marker</div> },
    ]
    const { router } = renderWithProviders(<IapTransactionsPage />, {
      routes,
      initialEntries: ['/iap'],
    })

    expect(await screen.findByText('subscriptions-marker')).toBeInTheDocument()
    expect(router.state.location.pathname).toBe('/subscriptions')
    // No platform requested → no provider filter, so every provider stays visible.
    expect(router.state.location.search).not.toContain('provider=')
  })

  it('maps platform=apple to provider=apple and platform=google to provider=google', async () => {
    authedAs(['*'])
    const routes: RouteObject[] = [
      { path: '/iap', element: <IapTransactionsPage /> },
      { path: '/subscriptions', element: <div>subscriptions-marker</div> },
    ]
    const { router: routerApple } = renderWithProviders(<IapTransactionsPage />, {
      routes,
      initialEntries: ['/iap?platform=apple'],
    })
    expect(await screen.findByText('subscriptions-marker')).toBeInTheDocument()
    expect(routerApple.state.location.search).toContain('provider=apple')

    const routes2: RouteObject[] = [
      { path: '/iap', element: <IapTransactionsPage /> },
      { path: '/subscriptions', element: <div>subscriptions-marker-2</div> },
    ]
    const { router: routerGoogle } = renderWithProviders(<IapTransactionsPage />, {
      routes: routes2,
      initialEntries: ['/iap?platform=google'],
    })
    expect(await screen.findByText('subscriptions-marker-2')).toBeInTheDocument()
    expect(routerGoogle.state.location.search).toContain('provider=google')
  })

  it('preserves status param when redirecting', async () => {
    authedAs(['*'])
    const routes: RouteObject[] = [
      { path: '/iap', element: <IapTransactionsPage /> },
      { path: '/subscriptions', element: <div>subscriptions-marker</div> },
    ]
    const { router } = renderWithProviders(<IapTransactionsPage />, {
      routes,
      initialEntries: ['/iap?platform=apple&status=failed'],
    })

    expect(await screen.findByText('subscriptions-marker')).toBeInTheDocument()
    expect(router.state.location.search).toContain('provider=apple')
    expect(router.state.location.search).toContain('status=failed')
  })

  it('ignores unknown platform values instead of forcing a provider filter', async () => {
    authedAs(['*'])
    const routes: RouteObject[] = [
      { path: '/iap', element: <IapTransactionsPage /> },
      { path: '/subscriptions', element: <div>subscriptions-marker</div> },
    ]
    const { router } = renderWithProviders(<IapTransactionsPage />, {
      routes,
      initialEntries: ['/iap?platform=stripe'],
    })

    expect(await screen.findByText('subscriptions-marker')).toBeInTheDocument()
    expect(router.state.location.search).not.toContain('provider=')
  })
})
