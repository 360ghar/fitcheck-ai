import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { http, HttpResponse } from 'msw'
import type { RouteObject } from 'react-router-dom'
import { describe, expect, it } from 'vitest'
import { axe } from 'vitest-axe'

import { LoginPage } from './LoginPage'

import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

const loginRoutes: RouteObject[] = [
  { path: '/login', element: <LoginPage /> },
  { path: '/users', element: <div>users-page-marker</div> },
  { path: '/dashboard', element: <div>dashboard-marker</div> },
]

function renderLogin(initialEntry = '/login') {
  return renderWithProviders(<LoginPage />, {
    routes: loginRoutes,
    initialEntries: [initialEntry],
  })
}

describe('LoginPage', () => {
  it('shows inline validation errors on an empty submit', async () => {
    renderLogin()
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }))
    expect(await screen.findByText('Email is required')).toBeInTheDocument()
    expect(screen.getByText('Password is required')).toBeInTheDocument()
  })

  it('rejects an invalid email format', async () => {
    renderLogin()
    await userEvent.type(screen.getByLabelText('Email'), 'not-an-email')
    await userEvent.type(screen.getByLabelText('Password'), 'correct-horse')
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }))
    expect(await screen.findByText('Enter a valid email address')).toBeInTheDocument()
  })

  it('signs in and redirects to returnTo', async () => {
    renderLogin('/login?returnTo=/users')
    await userEvent.type(screen.getByLabelText('Email'), 'admin@fitcheckaiapp.com')
    await userEvent.type(screen.getByLabelText('Password'), 'correct-horse')
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }))
    expect(await screen.findByText('users-page-marker')).toBeInTheDocument()
  })

  it('falls back to /dashboard when no returnTo is present', async () => {
    renderLogin()
    await userEvent.type(screen.getByLabelText('Email'), 'admin@fitcheckaiapp.com')
    await userEvent.type(screen.getByLabelText('Password'), 'correct-horse')
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }))
    expect(await screen.findByText('dashboard-marker')).toBeInTheDocument()
  })

  it('shows a banner for invalid credentials', async () => {
    renderLogin()
    await userEvent.type(screen.getByLabelText('Email'), 'admin@fitcheckaiapp.com')
    await userEvent.type(screen.getByLabelText('Password'), 'wrong-password')
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }))
    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Incorrect email or password. Try again.',
    )
    // Still on the login page.
    expect(screen.getByRole('button', { name: 'Sign in' })).toBeInTheDocument()
  })

  it('shows a banner for an unconfirmed email', async () => {
    renderLogin()
    await userEvent.type(screen.getByLabelText('Email'), 'admin@fitcheckaiapp.com')
    await userEvent.type(screen.getByLabelText('Password'), 'unconfirmed')
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }))
    expect(await screen.findByRole('alert')).toHaveTextContent(
      'This email has not been confirmed yet. Check your inbox.',
    )
  })

  it('shows the suspended banner when /me 401s with ACCOUNT_SUSPENDED after login', async () => {
    server.use(
      http.get('*/api/v1/admin/me', () =>
        HttpResponse.json(
          { error: 'Account is suspended', code: 'ACCOUNT_SUSPENDED', details: {} },
          { status: 401 },
        ),
      ),
    )
    renderLogin()
    await userEvent.type(screen.getByLabelText('Email'), 'admin@fitcheckaiapp.com')
    await userEvent.type(screen.getByLabelText('Password'), 'correct-horse')
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }))
    expect(await screen.findByRole('alert')).toHaveTextContent(
      'This account has been suspended. Contact the owner.',
    )
    // Still on the login page — no silent bounce into the route guard loop.
    expect(screen.getByRole('button', { name: 'Sign in' })).toBeInTheDocument()
  })

  it('shows a banner for network failures', async () => {
    server.use(http.post('*/api/v1/auth/login', () => HttpResponse.error()))
    renderLogin()
    await userEvent.type(screen.getByLabelText('Email'), 'admin@fitcheckaiapp.com')
    await userEvent.type(screen.getByLabelText('Password'), 'correct-horse')
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }))
    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Could not reach the server. Check your connection and try again.',
    )
  })

  it('shows a banner when /me 404s after a successful login (no silent bounce)', async () => {
    server.use(
      http.get('*/api/v1/admin/me', () =>
        HttpResponse.json(
          { error: 'Not Found', code: 'HTTP_ERROR', details: {}, correlation_id: 'me-404-cid' },
          { status: 404 },
        ),
      ),
    )
    renderLogin()
    await userEvent.type(screen.getByLabelText('Email'), 'admin@fitcheckaiapp.com')
    await userEvent.type(screen.getByLabelText('Password'), 'correct-horse')
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }))
    expect(await screen.findByRole('alert')).toHaveTextContent(
      "Sign-in is unavailable right now — the server returned 'Not Found' (404).",
    )
    // Still on the login page.
    expect(screen.getByRole('button', { name: 'Sign in' })).toBeInTheDocument()
  })

  it('shows a not-found banner with a correlation reference for a 404 login endpoint', async () => {
    server.use(
      http.post('*/api/v1/auth/login', () =>
        HttpResponse.json(
          { error: 'Not Found', code: 'HTTP_ERROR', details: {}, correlation_id: 'login-404-cid' },
          { status: 404 },
        ),
      ),
    )
    renderLogin()
    await userEvent.type(screen.getByLabelText('Email'), 'admin@fitcheckaiapp.com')
    await userEvent.type(screen.getByLabelText('Password'), 'correct-horse')
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }))
    const alert = await screen.findByRole('alert')
    expect(alert).toHaveTextContent('Sign-in is unavailable right now')
    expect(alert).toHaveTextContent('Reference: login-404-cid')
  })

  it('shows a server error banner on a 5xx login response', async () => {
    server.use(
      http.post('*/api/v1/auth/login', () =>
        HttpResponse.json(
          { error: 'Internal Server Error', code: 'HTTP_ERROR', details: {} },
          { status: 500 },
        ),
      ),
    )
    renderLogin()
    await userEvent.type(screen.getByLabelText('Email'), 'admin@fitcheckaiapp.com')
    await userEvent.type(screen.getByLabelText('Password'), 'correct-horse')
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }))
    expect(await screen.findByRole('alert')).toHaveTextContent(
      "The server couldn't complete sign-in. Try again in a moment.",
    )
  })

  it('shows a rate-limit banner on 429', async () => {
    server.use(
      http.post('*/api/v1/auth/login', () =>
        HttpResponse.json(
          {
            error: 'Too many requests',
            code: 'RATE_LIMIT_EXCEEDED',
            details: { retry_after_seconds: 3600 },
          },
          { status: 429 },
        ),
      ),
    )
    renderLogin()
    await userEvent.type(screen.getByLabelText('Email'), 'admin@fitcheckaiapp.com')
    await userEvent.type(screen.getByLabelText('Password'), 'correct-horse')
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }))
    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Too many sign-in attempts from this network. Wait a moment and try again.',
    )
  })

  it('shows the generic banner when login returns no session (no fake network message)', async () => {
    server.use(
      http.post('*/api/v1/auth/login', () =>
        HttpResponse.json({ data: {}, message: 'OK' }, { status: 200 }),
      ),
    )
    renderLogin()
    await userEvent.type(screen.getByLabelText('Email'), 'admin@fitcheckaiapp.com')
    await userEvent.type(screen.getByLabelText('Password'), 'correct-horse')
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }))
    expect(await screen.findByRole('alert')).toHaveTextContent('Sign-in failed. Try again.')
    // Still on the login page.
    expect(screen.getByRole('button', { name: 'Sign in' })).toBeInTheDocument()
  })

  it('has no axe violations in the idle state (WCAG 2.1 AA)', async () => {
    const { container } = renderLogin()
    expect(await axe(container)).toHaveNoViolations()
  })

  it('has no axe violations with inline validation errors', async () => {
    const { container } = renderLogin()
    await userEvent.click(screen.getByRole('button', { name: 'Sign in' }))
    expect(await screen.findByText('Email is required')).toBeInTheDocument()
    // aria-describedby must wire the error to its field.
    const emailInput = screen.getByLabelText('Email')
    expect(emailInput).toHaveAttribute('aria-invalid', 'true')
    const describedBy = emailInput.getAttribute('aria-describedby')
    expect(describedBy).not.toBeNull()
    // Both field errors announce via role=alert.
    const alerts = screen.getAllByRole('alert').map((el) => el.textContent)
    expect(alerts).toContain('Email is required')
    expect(alerts).toContain('Password is required')
    expect(await axe(container)).toHaveNoViolations()
  })
})
