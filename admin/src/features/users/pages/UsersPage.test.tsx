import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { http, HttpResponse } from 'msw'
import type { RouteObject } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { UsersPage } from './UsersPage'

import * as csv from '@/shared/lib/csv'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { createUsersHandlers } from '@/test/msw/handlers/users'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

const routes: RouteObject[] = [
  { path: '/users', element: <UsersPage /> },
  { path: '/users/:id', element: <div>user-detail-marker</div> },
]

function renderUsers(initialEntry = '/users') {
  return renderWithProviders(<UsersPage />, { routes, initialEntries: [initialEntry] })
}

function authedAs(permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions })
}

describe('UsersPage', () => {
  beforeEach(() => {
    authedAs(['*'])
  })

  it('renders users from the schema-typed fixture (email, role, plan, status)', async () => {
    const { handlers } = createUsersHandlers()
    server.use(...handlers)
    renderUsers()

    expect(await screen.findByText('alice@example.com')).toBeInTheDocument()
    expect(screen.getByText('bob@example.com')).toBeInTheDocument()
    expect(screen.getByText('carol@example.com')).toBeInTheDocument()
    // plan from the embedded subscription object
    expect(screen.getByText('Pro monthly')).toBeInTheDocument()
    // role labels
    expect(screen.getByText('Support')).toBeInTheDocument()
    // status derived from is_active
    expect(screen.getByText('Suspended')).toBeInTheDocument()
    // counts
    expect(screen.getByText('42')).toBeInTheDocument()
  })

  it('search roundtrip: debounced q reaches the server and filters rows', async () => {
    const { handlers, state } = createUsersHandlers()
    server.use(...handlers)
    renderUsers()

    await screen.findByText('alice@example.com')
    const user = userEvent.setup()
    await user.type(screen.getByRole('searchbox'), 'alice')

    await waitFor(() => {
      const lastRequest = state.requests.at(-1)
      expect(lastRequest?.searchParams.get('q')).toBe('alice')
    })
    expect(await screen.findByText('alice@example.com')).toBeInTheDocument()
    expect(screen.queryByText('bob@example.com')).not.toBeInTheDocument()
    expect(screen.queryByText('carol@example.com')).not.toBeInTheDocument()
  })

  it('status filter roundtrip: select sends status=suspended and filters rows', async () => {
    const { handlers, state } = createUsersHandlers()
    server.use(...handlers)
    renderUsers()

    await screen.findByText('alice@example.com')
    const user = userEvent.setup()
    await user.click(screen.getByRole('combobox', { name: 'Status' }))
    await user.click(await screen.findByRole('option', { name: 'Suspended' }))

    await waitFor(() => {
      const lastRequest = state.requests.at(-1)
      expect(lastRequest?.searchParams.get('status')).toBe('suspended')
    })
    expect(await screen.findByText('bob@example.com')).toBeInTheDocument()
    expect(screen.queryByText('alice@example.com')).not.toBeInTheDocument()
  })

  it('paginates: next page requests page=2 and renders the next slice', async () => {
    const { handlers, state } = createUsersHandlers()
    server.use(...handlers)
    renderUsers('/users?pageSize=2')

    // Page 1: newest first (created_at desc) → dave, carol
    expect(await screen.findByText('dave@example.com')).toBeInTheDocument()
    expect(screen.getByText('carol@example.com')).toBeInTheDocument()
    expect(screen.queryByText('alice@example.com')).not.toBeInTheDocument()

    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: 'Next page' }))

    await waitFor(() => {
      const lastRequest = state.requests.at(-1)
      expect(lastRequest?.searchParams.get('page')).toBe('2')
    })
    expect(await screen.findByText('bob@example.com')).toBeInTheDocument()
    expect(screen.getByText('alice@example.com')).toBeInTheDocument()
    expect(screen.queryByText('dave@example.com')).not.toBeInTheDocument()
  })

  it('suspend flow: confirm dialog then sequential PATCH and success toast', async () => {
    const { handlers, state } = createUsersHandlers()
    server.use(...handlers)
    renderUsers()

    await screen.findByText('alice@example.com')
    const user = userEvent.setup()
    const rowCheckboxes = screen.getAllByRole('checkbox', { name: 'Select row' })
    await user.click(rowCheckboxes[0] as HTMLElement)

    await user.click(screen.getByRole('button', { name: 'Suspend' }))
    const dialog = await screen.findByRole('dialog')
    expect(within(dialog).getByText('Suspend 1 selected user(s)?')).toBeInTheDocument()

    await user.click(within(dialog).getByRole('button', { name: 'Suspend' }))

    await waitFor(() => {
      expect(state.lastPatchBody).toEqual({ is_active: false })
    })
    expect(await screen.findByText('Suspended 1 of 1 selected users')).toBeInTheDocument()
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
  })

  it('activate flow targets suspended users with is_active: true', async () => {
    const { handlers, state } = createUsersHandlers()
    server.use(...handlers)
    renderUsers()

    await screen.findByText('bob@example.com')
    const user = userEvent.setup()
    const rowCheckboxes = screen.getAllByRole('checkbox', { name: 'Select row' })
    await user.click(rowCheckboxes[1] as HTMLElement)

    await user.click(screen.getByRole('button', { name: 'Activate' }))
    const dialog = await screen.findByRole('dialog')
    await user.click(within(dialog).getByRole('button', { name: 'Activate' }))

    await waitFor(() => {
      expect(state.lastPatchBody).toEqual({ is_active: true })
    })
    expect(await screen.findByText('Activated 1 of 1 selected users')).toBeInTheDocument()
  })

  it('read-only role (users.read only) hides bulk actions entirely', async () => {
    authedAs(['users.read'])
    const { handlers } = createUsersHandlers()
    server.use(...handlers)
    renderUsers()

    await screen.findByText('alice@example.com')
    expect(screen.queryByRole('checkbox', { name: 'Select row' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Suspend' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Activate' })).not.toBeInTheDocument()
  })

  it('row click navigates to the user detail route', async () => {
    const { handlers } = createUsersHandlers()
    server.use(...handlers)
    renderUsers()

    const user = userEvent.setup()
    const row = (await screen.findByText('alice@example.com')).closest('tr')
    expect(row).not.toBeNull()
    await user.click(row as HTMLElement)
    expect(await screen.findByText('user-detail-marker')).toBeInTheDocument()
  })

  it('only backend-whitelisted sort_by columns render sortable headers', async () => {
    const { handlers } = createUsersHandlers()
    server.use(...handlers)
    renderUsers()

    await screen.findByText('alice@example.com')

    // Whitelisted by GET /admin/users sort_by Literal: email, full_name, created_at.
    expect(screen.getByRole('button', { name: 'Email' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Name' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Created' })).toBeInTheDocument()
    // Everything else renders a plain header, so clicking can never send an
    // invalid sort_by (which 422s the whole list into the error state).
    expect(screen.queryByRole('button', { name: 'Role' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Plan' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Items' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Outfits' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Status' })).not.toBeInTheDocument()
  })

  it('exports the current page as CSV via shared/lib/csv', async () => {
    const downloadSpy = vi.spyOn(csv, 'downloadCsv').mockImplementation(() => undefined)
    const { handlers } = createUsersHandlers()
    server.use(...handlers)
    renderUsers()

    await screen.findByText('alice@example.com')
    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: 'Export CSV' }))
    await waitFor(() => {
      expect(downloadSpy).toHaveBeenCalledTimes(1)
    })
    const [filename, content] = downloadSpy.mock.calls[0] as [string, string]
    expect(filename).toBe('users.csv')
    expect(content).toContain('alice@example.com')
    expect(content).toContain('pro_monthly')
  })

  it('shows an error state with retry when the list request fails', async () => {
    const { handlers } = createUsersHandlers()
    let fail = true
    server.use(
      http.get('*/api/v1/admin/users', () => {
        if (fail) {
          return HttpResponse.json(
            { error: 'Database unavailable', code: 'INTERNAL_ERROR', details: {} },
            { status: 500 },
          )
        }
        return HttpResponse.json({
          items: [],
          total: 0,
          page: 1,
          page_size: 20,
        })
      }),
      ...handlers,
    )
    renderUsers()

    expect(await screen.findByRole('alert')).toHaveTextContent('Database unavailable')
    const user = userEvent.setup()
    fail = false
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    await waitFor(() => {
      expect(screen.queryByRole('alert')).not.toBeInTheDocument()
    })
  })
})
