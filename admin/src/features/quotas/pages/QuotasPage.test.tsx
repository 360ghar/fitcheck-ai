import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { QuotasPage } from './QuotasPage'

import * as csv from '@/shared/lib/csv'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { createQuotasHandlers } from '@/test/msw/handlers/quotas'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

function authedAs(permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions })
}

describe('QuotasPage', () => {
  beforeEach(() => {
    authedAs(['*'])
  })

  it('renders quota rows with limits, override badge and remaining', async () => {
    const { handlers } = createQuotasHandlers()
    server.use(...handlers)
    renderWithProviders(<QuotasPage />)

    expect(await screen.findByText('Alice Example')).toBeInTheDocument()
    expect(screen.getByText('bob@example.com')).toBeInTheDocument()
    // plan labels via the users namespace
    expect(screen.getByText('Pro monthly')).toBeInTheDocument()
    // plan default vs custom override (column header + badge share the word)
    expect(screen.getAllByText('Plan default').length).toBeGreaterThanOrEqual(1)
    expect(screen.getAllByText('Override').length).toBeGreaterThanOrEqual(1)
    // alice: used = 14 + 6 + 22 = 42, custom limit 150 → remaining 108
    expect(screen.getByText('42')).toBeInTheDocument()
    expect(screen.getByText('108')).toBeInTheDocument()
  })

  it('override dialog: submit sends daily_limit and updates the row', async () => {
    const { handlers, state } = createQuotasHandlers()
    server.use(...handlers)
    renderWithProviders(<QuotasPage />)

    await screen.findByText('Alice Example')
    const user = userEvent.setup()
    const setButtons = screen.getAllByRole('button', { name: 'Set override' })
    await user.click(setButtons[0] as HTMLElement)

    const dialog = await screen.findByRole('dialog')
    const input = within(dialog).getByLabelText('Daily limit')
    expect(input).toHaveValue(150)
    await user.clear(input)
    await user.type(input, '200')
    await user.click(within(dialog).getByRole('button', { name: 'Save override' }))

    await waitFor(() => {
      expect(state.lastPatchBody).toEqual({ daily_limit: 200 })
    })
    expect(await screen.findByText('Override saved for Alice Example')).toBeInTheDocument()
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
    // refetched row reflects the new limit (used 42 → remaining 158)
    expect(await screen.findByText('158')).toBeInTheDocument()
  })

  it('clear override sends daily_limit: null and restores plan default', async () => {
    const { handlers, state } = createQuotasHandlers()
    server.use(...handlers)
    renderWithProviders(<QuotasPage />)

    await screen.findByText('Alice Example')
    const user = userEvent.setup()
    const setButtons = screen.getAllByRole('button', { name: 'Set override' })
    await user.click(setButtons[0] as HTMLElement)

    const dialog = await screen.findByRole('dialog')
    await user.click(within(dialog).getByRole('button', { name: 'Clear override' }))

    await waitFor(() => {
      expect(state.lastPatchBody).toEqual({ daily_limit: null })
    })
    expect(await screen.findByText('Override cleared for Alice Example')).toBeInTheDocument()
  })

  it('validates the daily limit inline (empty and below 1)', async () => {
    const { handlers } = createQuotasHandlers()
    server.use(...handlers)
    renderWithProviders(<QuotasPage />)

    await screen.findByText('Alice Example')
    const user = userEvent.setup()
    const setButtons = screen.getAllByRole('button', { name: 'Set override' })
    await user.click(setButtons[0] as HTMLElement)

    const dialog = await screen.findByRole('dialog')
    const input = within(dialog).getByLabelText('Daily limit')
    await user.clear(input)
    await user.click(within(dialog).getByRole('button', { name: 'Save override' }))
    expect(await within(dialog).findByText('Enter a daily limit')).toBeInTheDocument()

    await user.type(input, '0')
    await user.click(within(dialog).getByRole('button', { name: 'Save override' }))
    expect(await within(dialog).findByText('The limit must be at least 1')).toBeInTheDocument()
    // dialog stays open — no request was made
    expect(screen.getByRole('dialog')).toBeInTheDocument()
  })

  it('maps server errors into the dialog inline alert', async () => {
    const { handlers } = createQuotasHandlers()
    server.use(
      http.patch('*/api/v1/admin/users/:userId/quota-override', () =>
        HttpResponse.json(
          { error: 'Override rejected by backend', code: 'QUOTA_OVERRIDE_INVALID', details: {} },
          { status: 422 },
        ),
      ),
      ...handlers,
    )
    renderWithProviders(<QuotasPage />)

    await screen.findByText('Alice Example')
    const user = userEvent.setup()
    const setButtons = screen.getAllByRole('button', { name: 'Set override' })
    await user.click(setButtons[0] as HTMLElement)

    const dialog = await screen.findByRole('dialog')
    await user.click(within(dialog).getByRole('button', { name: 'Save override' }))

    expect(await within(dialog).findByRole('alert')).toHaveTextContent(
      'Override rejected by backend',
    )
    expect(screen.getByRole('dialog')).toBeInTheDocument()
  })

  it('search roundtrip sends q and narrows rows', async () => {
    const { handlers, state } = createQuotasHandlers()
    server.use(...handlers)
    renderWithProviders(<QuotasPage />)

    await screen.findByText('Alice Example')
    const user = userEvent.setup()
    await user.type(screen.getByRole('searchbox'), 'bob')

    await waitFor(() => {
      const lastRequest = state.requests.at(-1)
      expect(lastRequest?.searchParams.get('q')).toBe('bob')
    })
    expect(await screen.findByText('bob@example.com')).toBeInTheDocument()
    expect(screen.queryByText('Alice Example')).not.toBeInTheDocument()
  })

  it('shows an error state when the list request fails', async () => {
    const { handlers } = createQuotasHandlers()
    server.use(
      http.get('*/api/v1/admin/quotas', () =>
        HttpResponse.json(
          { error: 'Quota service unavailable', code: 'INTERNAL_ERROR', details: {} },
          { status: 503 },
        ),
      ),
      ...handlers,
    )
    renderWithProviders(<QuotasPage />)

    expect(await screen.findByRole('alert')).toHaveTextContent('Quota service unavailable')
  })

  it('exports the current page as CSV via shared/lib/csv', async () => {
    const downloadSpy = vi.spyOn(csv, 'downloadCsv').mockImplementation(() => undefined)
    const { handlers } = createQuotasHandlers()
    server.use(...handlers)
    renderWithProviders(<QuotasPage />)

    await screen.findByText('Alice Example')
    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: 'Export CSV' }))
    await waitFor(() => {
      expect(downloadSpy).toHaveBeenCalledTimes(1)
    })
    const [filename, content] = downloadSpy.mock.calls[0] as [string, string]
    expect(filename).toBe('quota-usage.csv')
    expect(content).toContain('Alice Example')
    expect(content).toContain('pro_monthly')
  })
})
