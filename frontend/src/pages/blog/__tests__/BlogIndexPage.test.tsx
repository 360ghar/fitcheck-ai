import { render, screen, waitFor } from '@testing-library/react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { describe, expect, it, vi } from 'vitest'

const { useBlogPosts, useBlogCategories } = vi.hoisted(() => ({
  useBlogPosts: vi.fn(),
  useBlogCategories: vi.fn(),
}))

vi.mock('@/hooks/useBlog', () => ({ useBlogPosts, useBlogCategories }))
vi.mock('@/components/landing/AnimatedSection', () => ({
  AnimatedSection: ({ children }: { children: React.ReactNode }) => <>{children}</>,
}))
vi.mock('@/components/seo/SEO', () => ({ default: () => null }))

import BlogIndexPage from '@/pages/blog/BlogIndexPage'

describe('BlogIndexPage filters', () => {
  it('resolves category slugs to the exact API category and forwards search', async () => {
    useBlogCategories.mockReturnValue({ data: ['AI & Style'], isLoading: false })
    useBlogPosts.mockReturnValue({
      data: { posts: [], total_pages: 1 },
      isLoading: false,
      error: null,
    })

    render(
      <MemoryRouter initialEntries={['/blog/category/ai-style?search=wardrobe']}>
        <Routes>
          <Route path="/blog/category/:category" element={<BlogIndexPage />} />
        </Routes>
      </MemoryRouter>
    )

    await waitFor(() => {
      expect(useBlogPosts).toHaveBeenLastCalledWith(
        1,
        12,
        'AI & Style',
        'wardrobe',
        expect.objectContaining({ enabled: true })
      )
    })
    expect(screen.getByText('AI & Style Articles')).toBeInTheDocument()
  })
})
