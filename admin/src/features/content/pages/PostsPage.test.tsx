import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it } from 'vitest'

import { PostsPage } from './PostsPage'

import { useSessionStore } from '@/shared/stores/sessionStore'
import { createBlogHandlers } from '@/test/msw/handlers/blog'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

function authedAs(permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions })
}

describe('PostsPage', () => {
  beforeEach(() => {
    authedAs(['*'])
  })

  it('renders the post table with title, category, status and dates', async () => {
    const { handlers } = createBlogHandlers()
    server.use(...handlers)
    renderWithProviders(<PostsPage />)

    expect(await screen.findByText('Wardrobe Studio Guide')).toBeInTheDocument()
    expect(screen.getByText('Outfit Generation Tips')).toBeInTheDocument()
    expect(screen.getAllByText('Guides')).toHaveLength(2)
    const table = screen.getByRole('table')
    expect(within(table).getAllByText('Published')).toHaveLength(2)
    expect(within(table).getByText('Draft')).toBeInTheDocument()
    // edit links point at the editor route
    const editLink = screen.getByRole('link', { name: 'Wardrobe Studio Guide' })
    expect(editLink).toHaveAttribute('href', '/content/posts/edit/wardrobe-studio-guide')
  })

  it('status filter roundtrip sends the param and narrows rows', async () => {
    const { handlers, state } = createBlogHandlers()
    server.use(...handlers)
    renderWithProviders(<PostsPage />)

    await screen.findByText('Wardrobe Studio Guide')
    const user = userEvent.setup()
    await user.click(screen.getByRole('combobox', { name: 'Status' }))
    await user.click(await screen.findByRole('option', { name: 'Draft' }))

    await waitFor(() => {
      const lastRequest = state.requests.at(-1)
      expect(lastRequest?.searchParams.get('status')).toBe('draft')
    })
    expect(await screen.findByText('Seasonal Capsule (Draft)')).toBeInTheDocument()
    expect(screen.queryByText('Wardrobe Studio Guide')).not.toBeInTheDocument()
  })

  it('category filter roundtrip narrows to a single category (popover)', async () => {
    const { handlers, state } = createBlogHandlers()
    server.use(...handlers)
    renderWithProviders(<PostsPage />)

    await screen.findByText('Wardrobe Studio Guide')
    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: 'Filters' }))
    await user.click(await screen.findByRole('combobox', { name: 'Category' }))
    await user.click(await screen.findByRole('option', { name: 'Style' }))

    await waitFor(() => {
      const lastRequest = state.requests.at(-1)
      expect(lastRequest?.searchParams.get('category')).toBe('Style')
    })
    expect(await screen.findByText('Seasonal Capsule (Draft)')).toBeInTheDocument()
    expect(screen.queryByText('Wardrobe Studio Guide')).not.toBeInTheDocument()
  })

  it('search box sends q to the server', async () => {
    const { handlers, state } = createBlogHandlers()
    server.use(...handlers)
    renderWithProviders(<PostsPage />)

    await screen.findByText('Wardrobe Studio Guide')
    const user = userEvent.setup()
    await user.type(screen.getByRole('searchbox'), 'outfit')

    await waitFor(() => {
      const lastRequest = state.requests.at(-1)
      expect(lastRequest?.searchParams.get('search')).toBe('outfit')
    })
    expect(await screen.findByText('Outfit Generation Tips')).toBeInTheDocument()
    expect(screen.queryByText('Wardrobe Studio Guide')).not.toBeInTheDocument()
  })

  it('deletes a post after confirmation and refreshes the list', async () => {
    const { handlers, state } = createBlogHandlers()
    server.use(...handlers)
    renderWithProviders(<PostsPage />)

    await screen.findByText('Wardrobe Studio Guide')
    const user = userEvent.setup()
    const rows = screen.getAllByRole('row')
    const targetRow = rows.find((row) => within(row).queryByText('Wardrobe Studio Guide'))
    expect(targetRow).toBeDefined()
    await user.click(within(targetRow as HTMLElement).getByRole('button', { name: 'Delete' }))

    const dialog = await screen.findByRole('dialog')
    expect(within(dialog).getByText('Delete post')).toBeInTheDocument()
    expect(within(dialog).getByText(/Wardrobe Studio Guide/)).toBeInTheDocument()
    await user.click(within(dialog).getByRole('button', { name: 'Delete' }))

    await waitFor(() => {
      expect(screen.queryByText('Wardrobe Studio Guide')).not.toBeInTheDocument()
    })
    expect(state.posts.some((post) => post.slug === 'wardrobe-studio-guide')).toBe(false)
    expect(await screen.findByText('Post deleted.')).toBeInTheDocument()
  })

  it('shows an error state with retry when the list request fails', async () => {
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
    renderWithProviders(<PostsPage />)

    expect(await screen.findByText('Could not load posts')).toBeInTheDocument()
    const user = userEvent.setup()
    fail = false
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    await waitFor(() => {
      expect(screen.queryByText('Could not load posts')).not.toBeInTheDocument()
    })
  })
})
