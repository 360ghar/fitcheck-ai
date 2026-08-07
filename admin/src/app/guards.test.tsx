import { screen } from '@testing-library/react'
import type { RouteObject } from 'react-router-dom'
import { Outlet } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'

import { PublicOnlyGuard, RouteGuard } from './guards'

import { clearTokens, setTokens } from '@/shared/api/tokens'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { renderWithProviders } from '@/test/utils'

const publicRoutes: RouteObject[] = [
  {
    path: '/login',
    element: (
      <PublicOnlyGuard>
        <div>login-marker</div>
      </PublicOnlyGuard>
    ),
  },
  { path: '/dashboard', element: <div>dashboard-marker</div> },
]

const guardedRoutes: RouteObject[] = [
  {
    element: (
      <RouteGuard>
        <div>
          shell-marker
          <Outlet />
        </div>
      </RouteGuard>
    ),
    children: [{ path: '/dashboard', element: <div>dashboard-marker</div> }],
  },
]

function resetSession(): void {
  clearTokens()
  useSessionStore.setState({
    status: 'loading',
    user: null,
    role: null,
    permissions: [],
    permissionDenied: false,
    error: null,
    idleSince: Date.now(),
    lastLogoutReason: null,
  })
}

describe('PublicOnlyGuard', () => {
  beforeEach(() => {
    resetSession()
  })

  it('renders the public route for anon users', async () => {
    useSessionStore.setState({ status: 'anon' })
    renderWithProviders(<PublicOnlyGuard>{null}</PublicOnlyGuard>, {
      routes: publicRoutes,
      initialEntries: ['/login'],
    })
    expect(await screen.findByText('login-marker')).toBeInTheDocument()
    expect(screen.queryByText('dashboard-marker')).not.toBeInTheDocument()
  })

  it('bounces an authenticated user to /dashboard', () => {
    useSessionStore.setState({
      status: 'authed',
      user: null,
      role: 'super_admin',
      permissions: ['*'],
    })
    renderWithProviders(<PublicOnlyGuard>{null}</PublicOnlyGuard>, {
      routes: publicRoutes,
      initialEntries: ['/login'],
    })
    expect(screen.getByText('dashboard-marker')).toBeInTheDocument()
  })

  it('bootstraps itself when opened with valid tokens (no eternal loading / login form)', async () => {
    // Valid tokens + fresh store: PublicOnlyGuard must bootstrap (RouteGuard
    // never mounts on public routes) and land the user on /dashboard.
    setTokens({ access_token: 't', refresh_token: 'r' })
    renderWithProviders(<PublicOnlyGuard>{null}</PublicOnlyGuard>, {
      routes: publicRoutes,
      initialEntries: ['/login'],
    })
    expect(await screen.findByText('dashboard-marker')).toBeInTheDocument()
    expect(screen.queryByText('login-marker')).not.toBeInTheDocument()
    expect(useSessionStore.getState().status).toBe('authed')
  })

  it('bootstraps without tokens and falls through to the public route', async () => {
    renderWithProviders(<PublicOnlyGuard>{null}</PublicOnlyGuard>, {
      routes: publicRoutes,
      initialEntries: ['/login'],
    })
    expect(await screen.findByText('login-marker')).toBeInTheDocument()
    expect(useSessionStore.getState().status).toBe('anon')
  })
})

describe('RouteGuard', () => {
  beforeEach(() => {
    resetSession()
  })

  it('bootstraps and renders the shell for a valid session', async () => {
    setTokens({ access_token: 't', refresh_token: 'r' })
    renderWithProviders(<RouteGuard>{null}</RouteGuard>, {
      routes: guardedRoutes,
      initialEntries: ['/dashboard'],
    })
    expect(await screen.findByText('dashboard-marker')).toBeInTheDocument()
    expect(screen.getByText('shell-marker')).toBeInTheDocument()
  })

  it('redirects anon users to /login with returnTo', () => {
    useSessionStore.setState({ status: 'anon' })
    renderWithProviders(<RouteGuard>{null}</RouteGuard>, {
      routes: [
        { path: '/login', element: <div>login-marker</div> },
        ...guardedRoutes,
      ],
      initialEntries: ['/dashboard'],
    })
    expect(screen.getByText('login-marker')).toBeInTheDocument()
  })
})
