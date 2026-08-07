import { screen } from '@testing-library/react'
import { http, HttpResponse } from 'msw'
import type { RouteObject } from 'react-router-dom'
import { describe, expect, it, vi } from 'vitest'
import { axe } from 'vitest-axe'

import { OAuthCallbackPage } from './OAuthCallbackPage'

import { STORAGE_KEYS } from '@/shared/lib/constants'
import { getSupabase } from '@/shared/lib/supabase'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

// The session store reads the OAuth session via getSupabase(); tests replace
// the client with a fake (the shared setup defers its store import so this
// mock registers first).
vi.mock('@/shared/lib/supabase', () => ({
  getSupabase: vi.fn(),
}))

const mockedGetSupabase = vi.mocked(getSupabase)

const oauthSession = {
  access_token: 'oauth-access-token',
  refresh_token: 'oauth-refresh-token',
}

const callbackRoutes: RouteObject[] = [
  { path: '/auth/callback', element: <OAuthCallbackPage /> },
  { path: '/login', element: <div>login-page-marker</div> },
  { path: '/dashboard', element: <div>dashboard-marker</div> },
  { path: '/users', element: <div>users-page-marker</div> },
]

function renderCallback() {
  return renderWithProviders(<OAuthCallbackPage />, {
    routes: callbackRoutes,
    initialEntries: ['/auth/callback'],
  })
}

function mockSessionReturn() {
  mockedGetSupabase.mockResolvedValue({
    auth: {
      getSession: vi.fn().mockResolvedValue({ data: { session: oauthSession }, error: null }),
    },
  } as never)
}

describe('OAuthCallbackPage', () => {
  it('completes sign-in and navigates to the stashed returnTo', async () => {
    mockSessionReturn()
    localStorage.setItem(STORAGE_KEYS.oauthReturnTo, '/users')

    renderCallback()

    expect(await screen.findByText('users-page-marker')).toBeInTheDocument()
    // The stash is consumed after a successful round-trip.
    expect(localStorage.getItem(STORAGE_KEYS.oauthReturnTo)).toBeNull()
  })

  it('navigates to /dashboard when no returnTo was stashed', async () => {
    mockSessionReturn()

    renderCallback()

    expect(await screen.findByText('dashboard-marker')).toBeInTheDocument()
  })

  it('bounces a non-admin to /login and flags permissionDenied', async () => {
    mockSessionReturn()
    server.use(
      http.get('*/api/v1/admin/me', () =>
        HttpResponse.json(
          { error: 'Forbidden', code: 'PERMISSION_DENIED', details: {} },
          { status: 403 },
        ),
      ),
    )

    renderCallback()

    expect(await screen.findByText('login-page-marker')).toBeInTheDocument()
    expect(useSessionStore.getState().permissionDenied).toBe(true)
  })

  it('shows the cancelled message when the redirect returned no session', async () => {
    mockedGetSupabase.mockResolvedValue({
      auth: { getSession: vi.fn().mockResolvedValue({ data: { session: null }, error: null }) },
    } as never)

    renderCallback()

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Google sign-in was cancelled. No changes were made.',
    )
    expect(screen.getByRole('link', { name: 'Back to sign in' })).toBeInTheDocument()
  })

  it('shows the failure message with a back link when the profile sync fails', async () => {
    mockSessionReturn()
    server.use(
      http.post('*/api/v1/auth/oauth/sync', () =>
        HttpResponse.json({ error: 'boom', code: 'INTERNAL_ERROR', details: {} }, { status: 500 }),
      ),
    )

    renderCallback()

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Sign-in with Google could not be completed.',
    )
    expect(screen.getByRole('link', { name: 'Back to sign in' })).toBeInTheDocument()
  })

  it('carries the pending returnTo into the back-to-login link after a failure', async () => {
    mockSessionReturn()
    server.use(
      http.post('*/api/v1/auth/oauth/sync', () =>
        HttpResponse.json({ error: 'boom', code: 'INTERNAL_ERROR', details: {} }, { status: 500 }),
      ),
    )
    localStorage.setItem(STORAGE_KEYS.oauthReturnTo, '/users')

    renderCallback()

    const link = await screen.findByRole('link', { name: 'Back to sign in' })
    expect(link).toHaveAttribute('href', '/login?returnTo=%2Fusers')
  })

  it('has no axe violations while completing sign-in', async () => {
    // Never-resolving session lookup keeps the page in its loading state.
    mockedGetSupabase.mockResolvedValue(new Promise(() => undefined) as never)

    const { container } = renderCallback()

    expect(await axe(container)).toHaveNoViolations()
  })
})
