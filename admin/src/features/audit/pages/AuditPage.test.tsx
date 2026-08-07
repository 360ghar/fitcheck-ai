import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { AuditPage } from './AuditPage'

import * as csv from '@/shared/lib/csv'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { createAuditHandlers } from '@/test/msw/handlers/audit'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

function authedAs(permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions })
}

describe('AuditPage', () => {
  beforeEach(() => {
    authedAs(['*'])
  })

  it('renders audit rows with actor email, action badge, entity and ip', async () => {
    const { handlers } = createAuditHandlers()
    server.use(...handlers)
    renderWithProviders(<AuditPage />)

    expect(await screen.findByText('user.suspended')).toBeInTheDocument()
    // admin@ acted on 4 of the 6 events
    expect(screen.getAllByText('admin@fitcheckaiapp.com').length).toBeGreaterThanOrEqual(1)
    expect(screen.getAllByText('ops@fitcheckaiapp.com').length).toBeGreaterThanOrEqual(1)
    expect(screen.getByText('promo.created')).toBeInTheDocument()
    expect(screen.getByText('promo_code')).toBeInTheDocument()
    expect(screen.getAllByText('203.0.113.10').length).toBeGreaterThanOrEqual(1)
  })

  it('action filter roundtrip: select sends action param and narrows rows', async () => {
    const { handlers, state } = createAuditHandlers()
    server.use(...handlers)
    renderWithProviders(<AuditPage />)

    await screen.findByText('user.suspended')
    const user = userEvent.setup()
    await user.click(screen.getByRole('combobox', { name: 'Action' }))
    await user.click(await screen.findByRole('option', { name: 'promo.created' }))

    await waitFor(() => {
      const lastRequest = state.requests.at(-1)
      expect(lastRequest?.searchParams.get('action')).toBe('promo.created')
    })
    // the filter trigger shows the selected value, so the action text appears
    // in both the trigger and the (single) row
    expect((await screen.findAllByText('promo.created')).length).toBeGreaterThanOrEqual(1)
    await waitFor(() => {
      expect(screen.queryByText('user.suspended')).not.toBeInTheDocument()
    })
  })

  it('entity_type filter roundtrip narrows to user events (popover)', async () => {
    const { handlers, state } = createAuditHandlers()
    server.use(...handlers)
    renderWithProviders(<AuditPage />)

    await screen.findByText('user.suspended')
    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: 'Filters' }))
    await user.click(await screen.findByRole('combobox', { name: 'Entity type' }))
    await user.click(await screen.findByRole('option', { name: 'user' }))

    await waitFor(() => {
      const lastRequest = state.requests.at(-1)
      expect(lastRequest?.searchParams.get('entity_type')).toBe('user')
    })
    expect(await screen.findByText('user.suspended')).toBeInTheDocument()
    expect(screen.queryByText('promo.created')).not.toBeInTheDocument()
  })

  it('client-side q filter matches actor email on the current page', async () => {
    const { handlers, state } = createAuditHandlers()
    server.use(...handlers)
    renderWithProviders(<AuditPage />)

    await screen.findByText('user.suspended')
    const user = userEvent.setup()
    await user.type(screen.getByRole('searchbox'), 'ops@')

    // q is NOT sent to the server (schema has no q param)…
    await waitFor(() => {
      const lastRequest = state.requests.at(-1)
      expect(lastRequest?.searchParams.get('q')).toBeNull()
    })
    // …but filters the visible page client-side (debounced)
    expect(await screen.findByText('promo.created')).toBeInTheDocument()
    await waitFor(() => {
      expect(screen.queryByText('user.suspended')).not.toBeInTheDocument()
    })
  })

  it('paginates with a custom page size', async () => {
    const { handlers, state } = createAuditHandlers()
    server.use(...handlers)
    renderWithProviders(<AuditPage />, { initialEntries: ['/audit?pageSize=2'] })

    expect(await screen.findByText('user.suspended')).toBeInTheDocument()
    expect(screen.getByText('user.role_changed')).toBeInTheDocument()
    expect(screen.queryByText('promo.created')).not.toBeInTheDocument()

    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: 'Next page' }))

    await waitFor(() => {
      const lastRequest = state.requests.at(-1)
      expect(lastRequest?.searchParams.get('page')).toBe('2')
    })
    expect(await screen.findByText('promo.created')).toBeInTheDocument()
    expect(screen.queryByText('user.suspended')).not.toBeInTheDocument()
  })

  it('exports the current page as CSV via shared/lib/csv', async () => {
    const downloadSpy = vi.spyOn(csv, 'downloadCsv').mockImplementation(() => undefined)
    const { handlers } = createAuditHandlers()
    server.use(...handlers)
    renderWithProviders(<AuditPage />)

    await screen.findByText('user.suspended')
    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: 'Export CSV' }))

    await waitFor(() => {
      expect(downloadSpy).toHaveBeenCalledTimes(1)
    })
    const [filename, content] = downloadSpy.mock.calls[0] as [string, string]
    expect(filename).toBe('audit-events.csv')
    expect(content).toContain('user.suspended')
    expect(content).toContain('admin@fitcheckaiapp.com')
    expect(content).toContain('203.0.113.10')
    // payload column is included (quoted CSV cell)
    expect(content).toContain('spam')
    expect(await screen.findByText('Exported 6 audit events')).toBeInTheDocument()
  })

  it('opens a payload dialog with pretty-printed JSON and user agent', async () => {
    const { handlers } = createAuditHandlers()
    server.use(...handlers)
    renderWithProviders(<AuditPage />)

    await screen.findByText('user.suspended')
    const user = userEvent.setup()
    const viewButtons = screen.getAllByRole('button', { name: 'View payload' })
    await user.click(viewButtons[0] as HTMLElement)

    const dialog = await screen.findByRole('dialog')
    expect(within(dialog).getByText('Audit event payload')).toBeInTheDocument()
    expect(within(dialog).getByText(/"reason": "spam"/)).toBeInTheDocument()
    expect(within(dialog).getByText(/Mozilla\/5\.0/)).toBeInTheDocument()
  })

  it('blocks roles without audit.read (e.g. content_editor)', () => {
    authedAs(['content.read', 'content.write', 'promo.read', 'dashboards.read', 'search'])
    const { handlers } = createAuditHandlers()
    server.use(...handlers)
    renderWithProviders(<AuditPage />)

    expect(screen.getByText('No access')).toBeInTheDocument()
    expect(screen.queryByText('user.suspended')).not.toBeInTheDocument()
    expect(screen.queryByRole('searchbox')).not.toBeInTheDocument()
  })

  it('shows an error state with retry when the list request fails', async () => {
    const { handlers } = createAuditHandlers()
    let fail = true
    server.use(
      http.get('*/api/v1/admin/audit', () => {
        if (fail) {
          return HttpResponse.json(
            { error: 'Audit store unavailable', code: 'INTERNAL_ERROR', details: {} },
            { status: 503 },
          )
        }
        return HttpResponse.json({ items: [], total: 0, page: 1, page_size: 20 })
      }),
      ...handlers,
    )
    renderWithProviders(<AuditPage />)

    expect(await screen.findByRole('alert')).toHaveTextContent('Audit store unavailable')
    const user = userEvent.setup()
    fail = false
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    await waitFor(() => {
      expect(screen.queryByRole('alert')).not.toBeInTheDocument()
    })
  })
})
