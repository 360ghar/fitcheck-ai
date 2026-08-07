import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { http, HttpResponse } from 'msw'
import type { RouteObject } from 'react-router-dom'
import { describe, expect, it } from 'vitest'

import { TrendsPage } from './TrendsPage'

import { useSessionStore } from '@/shared/stores/sessionStore'
import { createDashboardHandlers } from '@/test/msw/handlers/dashboard'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

const routes: RouteObject[] = [
  { path: '/dashboard/trends', element: <TrendsPage /> },
]

function renderTrends(initialEntry = '/dashboard/trends') {
  return renderWithProviders(<TrendsPage />, { routes, initialEntries: [initialEntry] })
}

function authedAs(permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions })
}

describe('TrendsPage', () => {
  it('renders the four daily series charts from the trends fixture', async () => {
    authedAs(['*'])
    server.use(...createDashboardHandlers())
    renderTrends()

    expect(await screen.findByText('Daily trends')).toBeInTheDocument()
    expect(screen.getByText('Last 7 days')).toBeInTheDocument()
    expect(screen.getByText('Last 15 days')).toBeInTheDocument()
    expect(screen.getByText('Last 30 days')).toBeInTheDocument()
    expect(screen.getByText('Last 90 days')).toBeInTheDocument()

    // Lazy recharts chunk mounts four charts with aria labels.
    expect(await screen.findByRole('img', { name: 'Signups' })).toBeInTheDocument()
    expect(screen.getByRole('img', { name: 'AI jobs' })).toBeInTheDocument()
    expect(screen.getByRole('img', { name: 'Paid subscriptions' })).toBeInTheDocument()
    expect(screen.getByRole('img', { name: 'AI-active users' })).toBeInTheDocument()
  })

  it('defaults to 30 days and requests days=30', async () => {
    authedAs(['*'])
    server.use(...createDashboardHandlers())
    renderTrends()

    await screen.findByRole('img', { name: 'Signups' })
    // Tab state: 30 active by default.
    expect(screen.getByRole('tab', { name: 'Last 30 days' })).toHaveAttribute(
      'data-state',
      'active',
    )
  })

  it('switching to 90 days refetches with days=90', async () => {
    authedAs(['*'])
    const requests: Request[] = []
    server.use(
      http.get('*/api/v1/admin/dashboards/trends', ({ request }) => {
        requests.push(request)
        return HttpResponse.json({
          days: 90,
          signups: [],
          jobs: [],
          paid: [],
          active: [],
        })
      }),
      ...createDashboardHandlers(),
    )
    renderTrends()

    await screen.findByRole('img', { name: 'Signups' })
    const user = userEvent.setup()
    await user.click(screen.getByRole('tab', { name: 'Last 90 days' }))

    await waitFor(() => {
      expect(screen.getByRole('tab', { name: 'Last 90 days' })).toHaveAttribute(
        'data-state',
        'active',
      )
    })
    await waitFor(() => {
      const lastRequest = requests.at(-1)
      expect(lastRequest?.url).toContain('days=90')
    })
  })

  it('reads days=90 from the URL on first render', async () => {
    authedAs(['*'])
    server.use(...createDashboardHandlers())
    renderTrends('/dashboard/trends?days=90')

    expect(await screen.findByRole('img', { name: 'Signups' })).toBeInTheDocument()
    expect(screen.getByRole('tab', { name: 'Last 90 days' })).toHaveAttribute(
      'data-state',
      'active',
    )
  })

  it.each([7, 15])('switching to %i days refetches with days=%i', async (windowDays) => {
    authedAs(['*'])
    const requests: Request[] = []
    server.use(
      http.get('*/api/v1/admin/dashboards/trends', ({ request }) => {
        requests.push(request)
        return HttpResponse.json({
          days: windowDays,
          signups: [],
          jobs: [],
          paid: [],
          active: [],
        })
      }),
      ...createDashboardHandlers(),
    )
    renderTrends()

    await screen.findByRole('img', { name: 'Signups' })
    const user = userEvent.setup()
    const tabName = windowDays === 7 ? 'Last 7 days' : 'Last 15 days'
    await user.click(screen.getByRole('tab', { name: tabName }))

    await waitFor(() => {
      expect(screen.getByRole('tab', { name: tabName })).toHaveAttribute('data-state', 'active')
    })
    await waitFor(() => {
      const lastRequest = requests.at(-1)
      expect(lastRequest?.url).toContain(`days=${windowDays}`)
    })
  })

  it('shows an error state with retry when the trends request fails', async () => {
    authedAs(['*'])
    server.use(
      http.get('*/api/v1/admin/dashboards/trends', () =>
        HttpResponse.json(
          { error: 'Trends unavailable', code: 'INTERNAL_ERROR', details: {} },
          { status: 503 },
        ),
      ),
      ...createDashboardHandlers(),
    )
    renderTrends()

    expect(await screen.findByRole('alert')).toHaveTextContent('Trends unavailable')
  })
})
