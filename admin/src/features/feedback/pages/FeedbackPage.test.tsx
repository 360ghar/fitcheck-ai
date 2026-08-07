import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import type { RouteObject } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { FeedbackPage } from './FeedbackPage'

import * as csv from '@/shared/lib/csv'
import { useSessionStore } from '@/shared/stores/sessionStore'
import { createFeedbackHandlers } from '@/test/msw/handlers/feedback'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

const routes: RouteObject[] = [
  { path: '/feedback', element: <FeedbackPage /> },
  { path: '/users/:id', element: <div>user-detail-marker</div> },
]

function renderFeedback(initialEntry = '/feedback') {
  return renderWithProviders(<FeedbackPage />, { routes, initialEntries: [initialEntry] })
}

function authedAs(permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions })
}

describe('FeedbackPage', () => {
  beforeEach(() => {
    authedAs(['*'])
  })

  it('renders tickets with subject, category, status and joined user', async () => {
    const { handlers } = createFeedbackHandlers()
    server.use(...handlers)
    renderFeedback()

    expect(await screen.findByText('Photoshoot stuck at 3 of 10')).toBeInTheDocument()
    expect(screen.getByText('Dark mode for outfits')).toBeInTheDocument()
    expect(screen.getByText('alice@example.com')).toBeInTheDocument()
    expect(screen.getByText('Bug report')).toBeInTheDocument()
    expect(screen.getByText('Resolved')).toBeInTheDocument()
  })

  it('exports the current page as CSV via shared/lib/csv', async () => {
    const downloadSpy = vi.spyOn(csv, 'downloadCsv').mockImplementation(() => undefined)
    const { handlers } = createFeedbackHandlers()
    server.use(...handlers)
    renderFeedback()

    await screen.findByText('Photoshoot stuck at 3 of 10')
    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: 'Export CSV' }))
    await waitFor(() => {
      expect(downloadSpy).toHaveBeenCalledTimes(1)
    })
    const [filename, content] = downloadSpy.mock.calls[0] as [string, string]
    expect(filename).toBe('support-tickets.csv')
    expect(content).toContain('Photoshoot stuck at 3 of 10')
    expect(content).toContain('bug_report')
  })
})
