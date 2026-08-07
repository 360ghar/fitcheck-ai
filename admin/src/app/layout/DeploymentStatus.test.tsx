import { screen } from '@testing-library/react'
import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it } from 'vitest'

import { DeploymentStatus } from './DeploymentStatus'

import type { AdminRole } from '@/shared/api/types'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

function authedAs(role: AdminRole, permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role, permissions })
}

describe('DeploymentStatus', () => {
  beforeEach(() => {
    authedAs('ops', ['ops.read'])
  })

  it('renders the operational pill when the role has ops.read', async () => {
    server.use(
      http.get('*/api/v1/admin/ops/health', () =>
        HttpResponse.json({
          status: 'ok',
          service: 'api',
          version: '1.0.0-test',
          commit: 'abc123',
          schema_ready: true,
        }),
      ),
    )
    renderWithProviders(<DeploymentStatus />)
    expect(await screen.findByText('Operational')).toBeInTheDocument()
  })

  it('renders a red Down pill when the health endpoint reports down', async () => {
    server.use(
      http.get('*/api/v1/admin/ops/health', () =>
        HttpResponse.json({
          status: 'down',
          service: 'api',
          version: '1.0.0-test',
          commit: 'abc123',
          schema_ready: false,
        }),
      ),
    )
    renderWithProviders(<DeploymentStatus />)
    expect(await screen.findByText('Down')).toBeInTheDocument()
  })

  it('renders nothing and never polls for roles without ops.read (no permanent 403 → red Down)', async () => {
    authedAs('support', ['users.read'])
    let healthCalls = 0
    server.use(
      http.get('*/api/v1/admin/ops/health', () => {
        healthCalls += 1
        return HttpResponse.json({
          status: 'ok',
          service: 'api',
          version: '1.0.0-test',
          commit: 'abc123',
          schema_ready: true,
        })
      }),
    )
    const { container } = renderWithProviders(<DeploymentStatus />)
    // No pill at all for roles without ops.read (the provider shell still
    // renders the theme script + toaster, so assert on the pill itself).
    expect(screen.queryByText(/Operational|Degraded|Down|Status unknown/)).not.toBeInTheDocument()
    expect(container.querySelector('.inline-flex')).toBeNull()
    // No polling happens while the role lacks ops.read.
    await new Promise((resolve) => setTimeout(resolve, 30))
    expect(healthCalls).toBe(0)
  })
})
