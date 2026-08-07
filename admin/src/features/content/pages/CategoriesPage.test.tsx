import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it } from 'vitest'

import { CategoriesPage } from './CategoriesPage'

import { useSessionStore } from '@/shared/stores/sessionStore'
import { createBlogHandlers } from '@/test/msw/handlers/blog'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

function authedAs(permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions })
}

describe('CategoriesPage', () => {
  beforeEach(() => {
    authedAs(['*'])
  })

  it('derives category rows with total and published counts', async () => {
    const { handlers } = createBlogHandlers()
    server.use(...handlers)
    renderWithProviders(<CategoriesPage />)

    expect(await screen.findByText('Guides')).toBeInTheDocument()
    expect(screen.getByText('Style')).toBeInTheDocument()
    // Guides: 2 total, 2 published · Style: 1 total, 0 published
    const rows = screen.getAllByRole('row')
    const guidesRow = rows.find((row) => row.textContent?.includes('Guides'))
    expect(guidesRow?.textContent).toContain('2 posts')
    const styleRow = rows.find((row) => row.textContent?.includes('Style'))
    expect(styleRow?.textContent).toContain('0 posts')
  })

  it('shows an empty state when no posts exist', async () => {
    server.use(...createBlogHandlers({ posts: [] }).handlers)
    renderWithProviders(<CategoriesPage />)

    expect(await screen.findByText('No categories')).toBeInTheDocument()
  })

  it('shows an error state with retry when the catalogue fails to load', async () => {
    let fail = true
    server.use(
      http.get('*/api/v1/blog/admin/posts', () => {
        if (fail) {
          return HttpResponse.json(
            { error: 'Blog store unavailable', code: 'INTERNAL_ERROR', details: {} },
            { status: 503 },
          )
        }
        return HttpResponse.json({
          data: { posts: [], total: 0, page: 1, page_size: 100 },
          message: 'OK',
        })
      }),
    )
    renderWithProviders(<CategoriesPage />)

    expect(await screen.findByText('Could not load categories')).toBeInTheDocument()
    const user = userEvent.setup()
    fail = false
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    await waitFor(() => {
      expect(screen.queryByText('Could not load categories')).not.toBeInTheDocument()
    })
  })
})
