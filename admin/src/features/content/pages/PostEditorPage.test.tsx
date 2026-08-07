import { fireEvent, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it } from 'vitest'

import { PostEditorPage } from './PostEditorPage'

import { useSessionStore } from '@/shared/stores/sessionStore'
import { createBlogHandlers } from '@/test/msw/handlers/blog'
import { server } from '@/test/msw/server'
import { renderWithProviders } from '@/test/utils'

function authedAs(permissions: string[]): void {
  useSessionStore.setState({ status: 'authed', role: 'super_admin', permissions })
}

const routes = [
  { path: '/content/posts/new', element: <PostEditorPage /> },
  { path: '/content/posts/edit/:slug', element: <PostEditorPage /> },
  { path: '/content/posts', element: <div>POSTS LIST</div> },
]

async function fillRequiredFields(user: ReturnType<typeof userEvent.setup>): Promise<void> {
  await user.click(screen.getByLabelText('Category'))
  await user.click(await screen.findByRole('option', { name: 'Guides' }))
  fireEvent.change(screen.getByLabelText('Emoji'), { target: { value: '🚀' } })
  fireEvent.change(screen.getByLabelText('Publish date'), { target: { value: '2026-08-10' } })
  const keywordInput = screen.getByPlaceholderText('Add a keyword and press Enter')
  await user.type(keywordInput, 'summer{Enter}')
}

describe('PostEditorPage', () => {
  beforeEach(() => {
    authedAs(['*'])
  })

  it('validates required fields on submit', async () => {
    const { handlers } = createBlogHandlers()
    server.use(...handlers)
    renderWithProviders(<PostEditorPage />, { routes, initialEntries: ['/content/posts/new'] })

    const user = userEvent.setup()
    const saveButtons = await screen.findAllByRole('button', { name: 'Save' })
    await user.click(saveButtons[0] as HTMLElement)

    expect(await screen.findByText('Enter a title.')).toBeInTheDocument()
    expect(screen.getByText('Enter a slug.')).toBeInTheDocument()
    expect(screen.getByText('Enter an excerpt.')).toBeInTheDocument()
    // Shown both as the editor's error and the FormMessage under Content.
    expect(screen.getAllByText('Write some content.').length).toBeGreaterThan(0)
    expect(screen.getByText('Choose a category.')).toBeInTheDocument()
    expect(screen.getByText('Add at least one keyword.')).toBeInTheDocument()
  })

  it('auto-suggests a slug from the title', async () => {
    const { handlers } = createBlogHandlers()
    server.use(...handlers)
    renderWithProviders(<PostEditorPage />, { routes, initialEntries: ['/content/posts/new'] })

    const user = userEvent.setup()
    await user.type(screen.getByLabelText('Title'), 'My Brand New Post!')

    const slugInput = screen.getByLabelText('Slug')
    await waitFor(() => {
      expect(slugInput).toHaveValue('my-brand-new-post')
    })
  })

  it('creates a post and navigates back to the list', async () => {
    const { handlers, state } = createBlogHandlers()
    server.use(...handlers)
    renderWithProviders(<PostEditorPage />, { routes, initialEntries: ['/content/posts/new'] })

    const user = userEvent.setup()
    await user.type(screen.getByLabelText('Title'), 'Summer Style Guide')
    await user.type(screen.getByLabelText('Excerpt'), 'How to dress for the season.')
    const contentEditor = screen.getByRole('textbox', { name: 'Content' })
    await user.type(contentEditor, '## Summer tips\n\nLight layers win.')
    await fillRequiredFields(user)

    const saveButtons = screen.getAllByRole('button', { name: 'Save' })
    await user.click(saveButtons[0] as HTMLElement)

    expect(await screen.findByText('POSTS LIST')).toBeInTheDocument()
    expect(await screen.findByText('Post created.')).toBeInTheDocument()
    const created = state.posts.find((post) => post.title === 'Summer Style Guide')
    expect(created).toBeDefined()
    expect(created?.slug).toBe('summer-style-guide')
    expect(created?.is_published).toBe(false)
    expect(created?.keywords).toEqual(['summer'])
  })

  it('loads an existing post into the form for editing', async () => {
    const { handlers } = createBlogHandlers()
    server.use(...handlers)
    renderWithProviders(<PostEditorPage />, {
      routes,
      initialEntries: ['/content/posts/edit/wardrobe-studio-guide'],
    })

    expect(await screen.findByLabelText('Title')).toHaveValue('Wardrobe Studio Guide')
    expect(screen.getByLabelText('Slug')).toHaveValue('wardrobe-studio-guide')
    expect(screen.getByLabelText('Excerpt')).toHaveValue(
      'How to digitize your closet in 10 minutes.',
    )
    expect(screen.getByRole('textbox', { name: 'Content' })).toHaveValue(
      '## Getting started\n\nUpload photos of your clothes to build your digital wardrobe.',
    )
    expect(screen.getByLabelText('Author')).toHaveValue('FitCheck AI Team')
  })

  it('updates an existing post and navigates back', async () => {
    const { handlers, state } = createBlogHandlers()
    server.use(...handlers)
    renderWithProviders(<PostEditorPage />, {
      routes,
      initialEntries: ['/content/posts/edit/wardrobe-studio-guide'],
    })

    await screen.findByLabelText('Title')
    const user = userEvent.setup()
    const titleInput = screen.getByLabelText('Title')
    await user.clear(titleInput)
    await user.type(titleInput, 'Wardrobe Studio Guide v2')

    const saveButtons = screen.getAllByRole('button', { name: 'Save' })
    await user.click(saveButtons[0] as HTMLElement)

    expect(await screen.findByText('POSTS LIST')).toBeInTheDocument()
    await waitFor(() => {
      const updated = state.posts.find((post) => post.slug === 'wardrobe-studio-guide')
      expect(updated?.title).toBe('Wardrobe Studio Guide v2')
    })
  })

  it('guards against leaving with unsaved changes', async () => {
    const { handlers } = createBlogHandlers()
    server.use(...handlers)
    renderWithProviders(<PostEditorPage />, { routes, initialEntries: ['/content/posts/new'] })

    const user = userEvent.setup()
    await user.type(screen.getByLabelText('Title'), 'Half-written post')

    // Capture the button before the modal opens — while the guard dialog is
    // open, Radix hides the rest of the page from accessibility queries.
    const backButton = screen.getByRole('button', { name: 'Back to posts' })
    await user.click(backButton)
    const dialog = await screen.findByRole('dialog')
    expect(
      within(dialog).getByText('You have unsaved changes. Leave without saving?'),
    ).toBeInTheDocument()

    // Stay: dialog closes, still on the editor.
    await user.click(within(dialog).getByRole('button', { name: 'Keep editing' }))
    await waitFor(() => {
      expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
    })
    expect(screen.getByLabelText('Title')).toHaveValue('Half-written post')

    // Leave: navigates away.
    await user.click(backButton)
    const dialogAgain = await screen.findByRole('dialog')
    await user.click(within(dialogAgain).getByRole('button', { name: 'Leave' }))
    expect(await screen.findByText('POSTS LIST')).toBeInTheDocument()
  })

  it('surfaces a duplicate-slug validation error from the backend', async () => {
    server.use(
      http.post('*/api/v1/blog/posts', () =>
        HttpResponse.json(
          {
            error: 'A post with this slug already exists',
            code: 'VALIDATION_ERROR',
            details: { field: 'slug' },
          },
          { status: 422 },
        ),
      ),
    )
    renderWithProviders(<PostEditorPage />, { routes, initialEntries: ['/content/posts/new'] })

    const user = userEvent.setup()
    await user.type(screen.getByLabelText('Title'), 'Duplicate Slug Post')
    await user.type(screen.getByLabelText('Excerpt'), 'Excerpt here.')
    const contentEditor = screen.getByRole('textbox', { name: 'Content' })
    await user.type(contentEditor, 'Content body.')
    await fillRequiredFields(user)

    const saveButtons = screen.getAllByRole('button', { name: 'Save' })
    await user.click(saveButtons[0] as HTMLElement)

    expect(
      await screen.findByText('A post with this slug already exists.'),
    ).toBeInTheDocument()
    // Still on the editor after a failed save.
    expect(screen.getByLabelText('Title')).toHaveValue('Duplicate Slug Post')
  })
})
