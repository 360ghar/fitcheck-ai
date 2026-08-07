import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import type { RouteObject } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { IapTransactionsPage } from './IapTransactionsPage'

import * as csv from '@/shared/lib/csv'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { createIapHandlers } from '@/test/msw/handlers/iap'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

const routes: RouteObject[] = [
  { path: '/iap', element: <IapTransactionsPage /> },
  { path: '/users/:id', element: <div>user-detail-marker</div> },
]

function renderIap(initialEntry = '/iap') {
  return renderWithProviders(<IapTransactionsPage />, { routes, initialEntries: [initialEntry] })
}

function authedAs(permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions })
}

describe('IapTransactionsPage', () => {
  beforeEach(() => {
    authedAs(['*'])
  })

  it('renders transactions and dashes for rows without a provider transaction id', async () => {
    const { handlers } = createIapHandlers()
    server.use(...handlers)
    renderIap()

    expect(await screen.findByText('alice@example.com')).toBeInTheDocument()
    expect(screen.getByText('txn_apple_1001')).toBeInTheDocument()
    expect(screen.getByText('bob@example.com')).toBeInTheDocument()
    expect(screen.getByText('carol@example.com')).toBeInTheDocument()
    // Store-billed row: transaction id and amount both render dashes.
    const carolRow = screen.getByText('carol@example.com').closest('tr')
    expect(within(carolRow as HTMLElement).getAllByText('—').length).toBeGreaterThan(0)
  })

  it('detail dialog fetches and shows receipt fields for a provider transaction id', async () => {
    const { handlers, state } = createIapHandlers()
    server.use(...handlers)
    renderIap()

    const row = (await screen.findByText('alice@example.com')).closest('tr')
    expect(row).not.toBeNull()
    const user = userEvent.setup()
    await user.click(row as HTMLElement)

    const dialog = await screen.findByRole('dialog')
    expect(within(dialog).getByText('Transaction detail')).toBeInTheDocument()
    // Detail was fetched (single request to the detail endpoint).
    await waitFor(() => {
      expect(
        state.requests.some((url) => url.pathname.endsWith('/api/v1/admin/iap/transactions/txn_apple_1001')),
      ).toBe(true)
    })
    expect(await within(dialog).findByText('Apple App Store')).toBeInTheDocument()
    expect(within(dialog).getByRole('button', { name: 'Mark refunded' })).toBeInTheDocument()
  })

  it('store-billed row without transaction id shows the explicit no-provider state (no infinite skeleton)', async () => {
    const { handlers, state } = createIapHandlers()
    server.use(...handlers)
    renderIap()

    const row = (await screen.findByText('carol@example.com')).closest('tr')
    expect(row).not.toBeNull()
    const user = userEvent.setup()
    await user.click(row as HTMLElement)

    const dialog = await screen.findByRole('dialog')
    expect(
      within(dialog).getByText(
        'This row has no provider transaction id (store-billed). Details and refund-marking are unavailable for store-billed transactions.',
      ),
    ).toBeInTheDocument()
    // No skeleton, no mark-refunded affordance, and no detail request.
    expect(within(dialog).queryByRole('button', { name: 'Mark refunded' })).not.toBeInTheDocument()
    await new Promise((resolve) => setTimeout(resolve, 20))
    expect(
      state.requests.some((url) => url.pathname.includes('/api/v1/admin/iap/transactions/')),
    ).toBe(false)
  })

  it('mark refunded flow: confirm dialog then toast', async () => {
    const { handlers, state } = createIapHandlers()
    server.use(...handlers)
    renderIap()

    const row = (await screen.findByText('alice@example.com')).closest('tr')
    expect(row).not.toBeNull()
    const user = userEvent.setup()
    await user.click(row as HTMLElement)

    const detailDialog = await screen.findByRole('dialog')
    await user.click(within(detailDialog).getByRole('button', { name: 'Mark refunded' }))

    const confirmDialog = await screen.findByRole('dialog')
    expect(
      within(confirmDialog).getByText(
        'Mark txn_apple_1001 as refunded. This only updates the stored status — the store-side refund must already exist (webhooks record it).',
      ),
    ).toBeInTheDocument()
    await user.click(within(confirmDialog).getByRole('button', { name: 'Mark refunded' }))

    await waitFor(() => {
      expect(state.markedRefunded).toContain('txn_apple_1001')
    })
    expect(await screen.findByText('Transaction txn_apple_1001 marked refunded.')).toBeInTheDocument()
  })

  it('exports the current page as CSV via shared/lib/csv', async () => {
    const downloadSpy = vi.spyOn(csv, 'downloadCsv').mockImplementation(() => undefined)
    const { handlers } = createIapHandlers()
    server.use(...handlers)
    renderIap()

    await screen.findByText('alice@example.com')
    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: 'Export CSV' }))
    await waitFor(() => {
      expect(downloadSpy).toHaveBeenCalledTimes(1)
    })
    const [filename, content] = downloadSpy.mock.calls[0] as [string, string]
    expect(filename).toBe('iap-transactions.csv')
    expect(content).toContain('alice@example.com')
    expect(content).toContain('apple')
  })
})
