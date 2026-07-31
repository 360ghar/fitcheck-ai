import { render, screen } from '@testing-library/react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { describe, expect, it, vi } from 'vitest'

const { useBlogPost, useBlogPosts } = vi.hoisted(() => ({
  useBlogPost: vi.fn(),
  useBlogPosts: vi.fn(() => ({ data: undefined })),
}))

vi.mock('@/hooks/useBlog', () => ({ useBlogPost, useBlogPosts }))
vi.mock('@/components/landing/AnimatedSection', () => ({
  AnimatedSection: ({ children }: { children: React.ReactNode }) => <>{children}</>,
}))
vi.mock('@/components/seo/SEO', () => ({ default: () => null }))
vi.mock('@/components/seo/JsonLd', () => ({ BreadcrumbJsonLd: () => null }))

import BlogPostPage from '@/pages/blog/BlogPostPage'

function renderPost() {
  return render(
    <MemoryRouter initialEntries={['/blog/missing-post']}>
      <Routes>
        <Route path="/blog/:slug" element={<BlogPostPage />} />
      </Routes>
    </MemoryRouter>
  )
}

describe('BlogPostPage error states', () => {
  it('renders not found only for a 404 response', () => {
    useBlogPost.mockReturnValue({ data: undefined, isLoading: false, error: { status: 404, message: 'Missing' } })
    renderPost()
    expect(screen.getByRole('heading', { name: 'Post not found' })).toBeInTheDocument()
  })

  it('renders a retryable load error for network failures', () => {
    useBlogPost.mockReturnValue({ data: undefined, isLoading: false, error: { message: 'Network unavailable' } })
    renderPost()
    expect(screen.getByRole('heading', { name: 'Unable to load article' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Try again' })).toBeInTheDocument()
  })
})
