import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { http, HttpResponse } from 'msw'
import { describe, expect, it } from 'vitest'

import { DashboardPage } from './DashboardPage'

import { useSessionStore } from '@/shared/stores/sessionStore'
import { createAuditHandlers } from '@/test/msw/handlers/audit'
import { createDashboardHandlers } from '@/test/msw/handlers/dashboard'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

function authedAs(permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions })
}

describe('DashboardPage', () => {
  it('renders the ops-console grid: metric strip, charts, top users, referrals, activity', async () => {
    authedAs(['*'])
    server.use(...createDashboardHandlers(), ...createAuditHandlers().handlers)
    renderWithProviders(<DashboardPage />)

    // Metric strip from overview aggregates
    expect(await screen.findByText('Signups (7 days)')).toBeInTheDocument()
    expect(screen.getByText('42')).toBeInTheDocument()
    expect(screen.getByText('Signups (30 days)')).toBeInTheDocument()
    expect(screen.getByText('180')).toBeInTheDocument()
    expect(screen.getByText('Active users (7 days)')).toBeInTheDocument()
    // "Paid subscriptions" labels both the overview metric and the revenue strip.
    expect(screen.getAllByText('Paid subscriptions').length).toBeGreaterThanOrEqual(1)
    // 47 appears twice: the overview metric AND the revenue strip's paid count.
    expect(screen.getAllByText('47').length).toBeGreaterThanOrEqual(2)
    expect(screen.getByText('AI jobs (7 days)')).toBeInTheDocument()
    expect(screen.getByText('321')).toBeInTheDocument()
    expect(screen.getByText('301 succeeded · 20 failed')).toBeInTheDocument()

    // Trend charts mount lazily (recharts chunk), compact layout
    expect(
      await screen.findByRole('img', { name: 'Signups & Active users' }),
    ).toBeInTheDocument()
    expect(screen.getByRole('img', { name: 'Total' })).toBeInTheDocument()

    // Tabbed top users — outfits tab active by default
    expect(screen.getByRole('tab', { name: 'Most outfits' })).toHaveAttribute(
      'data-state',
      'active',
    )
    expect(screen.getByRole('tab', { name: 'Most items' })).toBeInTheDocument()
    expect(screen.getByRole('tab', { name: 'Most referrals' })).toBeInTheDocument()
    expect(screen.getByText('Alice Example')).toBeInTheDocument()
    expect(screen.getByText('Carol Example')).toBeInTheDocument()
    expect(screen.getByText('erin@example.com')).toBeInTheDocument()

    // Switching tabs swaps the list
    const user = userEvent.setup()
    await user.click(screen.getByRole('tab', { name: 'Most items' }))
    expect(await screen.findByText('Frank Example')).toBeInTheDocument()
    // alice's items count (42) plus the signups-7d metric (42)
    expect(screen.getAllByText('42').length).toBeGreaterThanOrEqual(2)
    await user.click(screen.getByRole('tab', { name: 'Most referrals' }))
    expect(await screen.findByText('Grace Example')).toBeInTheDocument()

    // Referral totals (compact 2×2)
    expect(screen.getByText('Referral program')).toBeInTheDocument()
    expect(screen.getByText('Codes issued')).toBeInTheDocument()
    expect(screen.getByText('84')).toBeInTheDocument()
    expect(screen.getByText('Credits pending')).toBeInTheDocument()
    expect(screen.getByText('10')).toBeInTheDocument()

    // Recent admin activity from the audit endpoint
    expect(screen.getByText('Recent admin activity')).toBeInTheDocument()
    expect((await screen.findAllByText('admin@fitcheckaiapp.com')).length).toBeGreaterThanOrEqual(1)
    expect(screen.getByText('user.suspended')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'View audit log' })).toBeInTheDocument()

    // Revenue strip (MRR estimate, paid/trials, churn)
    expect(screen.getByText('Revenue')).toBeInTheDocument()
    expect(screen.getByText('$1,240.50')).toBeInTheDocument()
    expect(screen.getByText('$930.25')).toBeInTheDocument()
    expect(screen.getByText('$310.25')).toBeInTheDocument()
    // Trials (5) and churn (3) collide with top-referrer counts on the
    // active tab — assert presence, not uniqueness.
    expect(screen.getAllByText('5').length).toBeGreaterThanOrEqual(1)
    expect(screen.getAllByText('3').length).toBeGreaterThanOrEqual(1)
    expect(screen.getByText('2 refunds (30d)')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'View daily trends' })).toHaveAttribute(
      'href',
      '/dashboard/trends',
    )

    // Refresh control shows a relative updated timestamp
    expect(screen.getByRole('button', { name: 'Refresh' })).toBeInTheDocument()
  })

  it('shows an error state with retry when the overview request fails', async () => {
    authedAs(['*'])
    server.use(
      http.get('*/api/v1/admin/dashboards/overview', () =>
        HttpResponse.json(
          { error: 'Overview service unavailable', code: 'INTERNAL_ERROR', details: {} },
          { status: 503 },
        ),
      ),
      ...createDashboardHandlers(),
      ...createAuditHandlers().handlers,
    )
    renderWithProviders(<DashboardPage />)

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Overview service unavailable',
    )
    expect(screen.queryByText('Signups (7 days)')).not.toBeInTheDocument()
  })

  it('recovers after retry once the server heals', async () => {
    authedAs(['*'])
    let fail = true
    server.use(
      http.get('*/api/v1/admin/dashboards/overview', () => {
        if (fail) {
          return HttpResponse.json(
            { error: 'Overview service unavailable', code: 'INTERNAL_ERROR', details: {} },
            { status: 503 },
          )
        }
        return HttpResponse.json({
          signups: { '7d': 1, '30d': 2 },
          active_users: { '7d': 1, '30d': 2 },
          paid_subscriptions: 3,
          ai_jobs_7d: { total: 4, succeeded: 3, failed: 1 },
        })
      }),
      ...createDashboardHandlers(),
      ...createAuditHandlers().handlers,
    )
    renderWithProviders(<DashboardPage />)

    expect(await screen.findByRole('alert')).toBeInTheDocument()
    const user = userEvent.setup()
    fail = false
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(await screen.findByText('Signups (7 days)')).toBeInTheDocument()
    await waitFor(() => {
      expect(screen.queryByRole('alert')).not.toBeInTheDocument()
    })
  })
})
