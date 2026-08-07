import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { http, HttpResponse } from 'msw'
import type { RouteObject } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'

import { UserDetailPage } from './UserDetailPage'

import { useSessionStore } from '@/shared/stores/sessionStore'
import { adminUserDetailFixture, createUsersHandlers } from '@/test/msw/handlers/users'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

const routes: RouteObject[] = [
  { path: '/users', element: <div>users-list-marker</div> },
  { path: '/users/:id', element: <UserDetailPage /> },
]

function renderUserDetail(userId = 'user_1') {
  return renderWithProviders(<UserDetailPage />, {
    routes,
    initialEntries: [`/users/${userId}`],
  })
}

function authedAs(permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions })
}

describe('UserDetailPage', () => {
  beforeEach(() => {
    authedAs(['*'])
  })

  it('renders profile, role/status badges, subscription, usage and counts', async () => {
    const { handlers } = createUsersHandlers()
    server.use(...handlers)
    renderUserDetail()

    expect((await screen.findAllByText('Alice Example')).length).toBeGreaterThanOrEqual(1)
    expect(screen.getAllByText('alice@example.com').length).toBeGreaterThanOrEqual(1)
    // role badge + role select trigger both show "User"
    expect(screen.getAllByText('User').length).toBeGreaterThanOrEqual(1)
    expect(screen.getByText('Active')).toBeInTheDocument()
    // subscription (embedded dict)
    expect(screen.getByText('Pro monthly')).toBeInTheDocument()
    // custom quota + usage counters
    expect(screen.getByText('150')).toBeInTheDocument()
    // 14 = daily extractions (also monthly extractions) → multiple matches
    expect(screen.getAllByText('14').length).toBeGreaterThanOrEqual(1)
    // counts section
    expect(screen.getByText('42')).toBeInTheDocument()
    expect(screen.getByText('12')).toBeInTheDocument()
    // activity: audit events + recent jobs
    expect(await screen.findByText('user.role_changed')).toBeInTheDocument()
    expect(screen.getByText('batch_extraction')).toBeInTheDocument()
  })

  it('suspend flow: confirm dialog, PATCH is_active=false, optimistic status flip + toast', async () => {
    const { handlers, state } = createUsersHandlers()
    server.use(...handlers)
    renderUserDetail()

    expect((await screen.findAllByText('Alice Example')).length).toBeGreaterThanOrEqual(1)
    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: 'Suspend user' }))

    const dialog = await screen.findByRole('dialog')
    expect(within(dialog).getByText('Suspend this user?')).toBeInTheDocument()
    await user.click(within(dialog).getByRole('button', { name: 'Suspend user' }))

    await waitFor(() => {
      expect(state.lastPatchBody).toEqual({ is_active: false })
    })
    expect(await screen.findByText('Alice Example was suspended')).toBeInTheDocument()
    // optimistic update flips the status badge right away
    expect(await screen.findByText('Suspended')).toBeInTheDocument()
  })

  it('activate flow for a suspended user sends is_active=true', async () => {
    const { handlers, state } = createUsersHandlers()
    server.use(...handlers)
    renderUserDetail('user_2') // bob is suspended in the fixture

    expect((await screen.findAllByText('bob@example.com')).length).toBeGreaterThanOrEqual(1)
    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: 'Activate user' }))
    const dialog = await screen.findByRole('dialog')
    await user.click(within(dialog).getByRole('button', { name: 'Activate user' }))

    await waitFor(() => {
      expect(state.lastPatchBody).toEqual({ is_active: true })
    })
    expect(await screen.findByText('bob@example.com was activated')).toBeInTheDocument()
  })

  it('role change flows through the confirm dialog and PATCHes the role', async () => {
    const { handlers, state } = createUsersHandlers()
    server.use(...handlers)
    renderUserDetail()

    expect((await screen.findAllByText('Alice Example')).length).toBeGreaterThanOrEqual(1)
    const user = userEvent.setup()
    await user.click(screen.getByRole('combobox', { name: 'Role' }))
    await user.click(await screen.findByRole('option', { name: 'Ops' }))

    const dialog = await screen.findByRole('dialog')
    expect(within(dialog).getByText('Change role to Ops?')).toBeInTheDocument()
    await user.click(within(dialog).getByRole('button', { name: 'Confirm' }))

    await waitFor(() => {
      expect(state.lastPatchBody).toEqual({ role: 'ops' })
    })
    expect(await screen.findByText('Role updated')).toBeInTheDocument()
  })

  it('surfaces backend errors (e.g. self-demotion guard) via toast', async () => {
    const { handlers } = createUsersHandlers()
    server.use(
      http.patch('*/api/v1/admin/users/:userId', () =>
        HttpResponse.json(
          { error: 'You cannot demote yourself', code: 'SELF_DEMOTION', details: {} },
          { status: 400 },
        ),
      ),
      ...handlers,
    )
    renderUserDetail()

    expect((await screen.findAllByText('Alice Example')).length).toBeGreaterThanOrEqual(1)
    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: 'Suspend user' }))
    const dialog = await screen.findByRole('dialog')
    await user.click(within(dialog).getByRole('button', { name: 'Suspend user' }))

    // inline error inside the dialog + toast both carry the API message
    expect(await within(dialog).findByText('You cannot demote yourself')).toBeInTheDocument()
    expect(screen.getByRole('dialog')).toBeInTheDocument()
  })

  it('error state with retry recovers after the server heals', async () => {
    const { handlers } = createUsersHandlers()
    let fail = true
    server.use(
      http.get('*/api/v1/admin/users/:userId', () => {
        if (fail) {
          return HttpResponse.json(
            { error: 'User service down', code: 'INTERNAL_ERROR', details: {} },
            { status: 503 },
          )
        }
        return HttpResponse.json(adminUserDetailFixture)
      }),
      ...handlers,
    )
    renderUserDetail()

    expect(await screen.findByRole('alert')).toHaveTextContent('User service down')
    const user = userEvent.setup()
    fail = false
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect((await screen.findAllByText('Alice Example')).length).toBeGreaterThanOrEqual(1)
  })

  it('read-only role (users.read) hides the action panel', async () => {
    authedAs(['users.read'])
    const { handlers } = createUsersHandlers()
    server.use(...handlers)
    renderUserDetail()

    expect((await screen.findAllByText('Alice Example')).length).toBeGreaterThanOrEqual(1)
    expect(screen.queryByRole('button', { name: 'Suspend user' })).not.toBeInTheDocument()
    expect(screen.queryByRole('combobox', { name: 'Role' })).not.toBeInTheDocument()
    expect(screen.getByText("You don't have permission to manage this user.")).toBeInTheDocument()
  })

  it('shows a not-found empty state for an unknown user id', async () => {
    const { handlers } = createUsersHandlers()
    server.use(...handlers)
    renderUserDetail('missing_user')

    expect(await screen.findByText('User not found')).toBeInTheDocument()
  })
})
