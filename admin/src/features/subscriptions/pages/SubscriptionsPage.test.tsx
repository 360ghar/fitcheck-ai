import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import type { RouteObject } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { SubscriptionsPage } from './SubscriptionsPage'

import * as csv from '@/shared/lib/csv'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { createSubscriptionsHandlers } from '@/test/msw/handlers/subscriptions'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

const routes: RouteObject[] = [
  { path: '/subscriptions', element: <SubscriptionsPage /> },
  { path: '/users/:id', element: <div>user-detail-marker</div> },
]

function renderSubscriptions(initialEntry = '/subscriptions') {
  return renderWithProviders(<SubscriptionsPage />, { routes, initialEntries: [initialEntry] })
}

function authedAs(permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions })
}

describe('SubscriptionsPage', () => {
  beforeEach(() => {
    authedAs(['*'])
  })

  it('renders list amounts (display dollars from the list endpoint)', async () => {
    const { handlers } = createSubscriptionsHandlers()
    server.use(...handlers)
    renderSubscriptions()

    expect(await screen.findByText('alice@example.com')).toBeInTheDocument()
    // Backend list amounts are display dollars (19.99 / 8.99).
    expect(screen.getByText('$19.99')).toBeInTheDocument()
    expect(screen.getByText('$8.99')).toBeInTheDocument()
    // Store-billed row (amount null) renders an em dash, not "$0".
    expect(screen.getAllByText('—').length).toBeGreaterThan(0)
  })

  it('refund flow: confirm dialog and success toast show the amount converted from cents', async () => {
    const { handlers, state } = createSubscriptionsHandlers()
    server.use(...handlers)
    renderSubscriptions()

    await screen.findByText('alice@example.com')
    const user = userEvent.setup()
    // First row (alice, $19.99) — multiple rows expose a Refund action.
    const refundButtons = screen.getAllByRole('button', { name: 'Refund' })
    await user.click(refundButtons[0] as HTMLElement)

    const dialog = await screen.findByRole('dialog')
    // Dialog description + confirm label both render major units ($19.99).
    expect(
      within(dialog).getByText(
        'Refund $19.99 for alice@example.com. This is an irreversible full refund of the latest Stripe charge.',
      ),
    ).toBeInTheDocument()
    await user.click(within(dialog).getByRole('button', { name: 'Refund $19.99' }))

    await waitFor(() => {
      expect(state.lastRefundUserId).toBe('user_1')
    })
    // The refund response amount is Stripe cents (1999) — the toast must
    // divide by 100 and show $19.99, not $1,999.00.
    expect(
      await screen.findByText('Refund re_123 issued ($19.99, succeeded).'),
    ).toBeInTheDocument()
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
  })

  it('hides refund actions for roles without subscriptions.refund', async () => {
    authedAs(['subscriptions.read'])
    const { handlers } = createSubscriptionsHandlers()
    server.use(...handlers)
    renderSubscriptions()

    await screen.findByText('alice@example.com')
    expect(screen.queryByRole('button', { name: 'Refund' })).not.toBeInTheDocument()
  })

  it('exports the current page as CSV via shared/lib/csv', async () => {
    const downloadSpy = vi.spyOn(csv, 'downloadCsv').mockImplementation(() => undefined)
    const { handlers } = createSubscriptionsHandlers()
    server.use(...handlers)
    renderSubscriptions()

    await screen.findByText('alice@example.com')
    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: 'Export CSV' }))
    await waitFor(() => {
      expect(downloadSpy).toHaveBeenCalledTimes(1)
    })
    const [filename, content] = downloadSpy.mock.calls[0] as [string, string]
    expect(filename).toBe('subscriptions.csv')
    expect(content).toContain('alice@example.com')
    expect(content).toContain('pro_monthly')
  })
})
