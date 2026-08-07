import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import type { RouteObject } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { PromoPage } from './PromoPage'

import * as csv from '@/shared/lib/csv'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { createPromoHandlers } from '@/test/msw/handlers/promo'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

const routes: RouteObject[] = [{ path: '/promo', element: <PromoPage /> }]

function renderPromo(initialEntry = '/promo') {
  return renderWithProviders(<PromoPage />, { routes, initialEntries: [initialEntry] })
}

function authedAs(permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions })
}

describe('PromoPage', () => {
  beforeEach(() => {
    authedAs(['*'])
  })

  it('renders promo codes with plan, activity and redemption counts', async () => {
    const { handlers } = createPromoHandlers()
    server.use(...handlers)
    renderPromo()

    expect(await screen.findByText('SUMMER25')).toBeInTheDocument()
    expect(screen.getByText('PRO-FRIENDS')).toBeInTheDocument()
    expect(screen.getByText('12 / 100')).toBeInTheDocument()
    expect(screen.getByText('Inactive')).toBeInTheDocument()
  })

  it('exports the current page as CSV via shared/lib/csv', async () => {
    const downloadSpy = vi.spyOn(csv, 'downloadCsv').mockImplementation(() => undefined)
    const { handlers } = createPromoHandlers()
    server.use(...handlers)
    renderPromo()

    await screen.findByText('SUMMER25')
    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: 'Export CSV' }))
    await waitFor(() => {
      expect(downloadSpy).toHaveBeenCalledTimes(1)
    })
    const [filename, content] = downloadSpy.mock.calls[0] as [string, string]
    expect(filename).toBe('promo-codes.csv')
    expect(content).toContain('SUMMER25')
    expect(content).toContain('plus_monthly')
  })
})
