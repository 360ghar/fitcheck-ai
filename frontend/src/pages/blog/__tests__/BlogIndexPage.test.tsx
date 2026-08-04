import { render, screen, waitFor } from '@testing-library/react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { describe, expect, it, vi } from 'vitest'

const { useInfiniteBlogPosts, useBlogCategories } = vi.hoisted(() => ({
  useInfiniteBlogPosts: vi.fn(),
  useBlogCategories: vi.fn(),
}))

vi.mock('@/hooks/useBlog', () => ({ useBlogCategories }))
vi.mock('@/hooks/useInfiniteBlogPosts', () => ({ useInfiniteBlogPosts }))
vi.mock('@/components/landing/AnimatedSection', () => ({
  AnimatedSection: ({ children }: { children: React.ReactNode }) => <>{children}</>,
}))
vi.mock('@/components/seo/SEO', () => ({ default: () => null }))

import BlogIndexPage from '@/pages/blog/BlogIndexPage'

function mockEmptyInfinite() {
  return {
    posts: [],
    hasNextPage: false,
    isFetchingNextPage: false,
    isLoading: false,
    isError: false,
    error: null,
    fetchNextPage: vi.fn(),
    refetch: vi.fn(),
  }
}

describe('BlogIndexPage filters', () => {
  it('resolves category slugs to the exact API category and forwards search', async () => {
    useBlogCategories.mockReturnValue({ data: ['AI & Style'], isLoading: false })
    useInfiniteBlogPosts.mockReturnValue(mockEmptyInfinite())

    render(
      <MemoryRouter initialEntries={['/blog/category/ai-style?search=wardrobe']}>
        <Routes>
          <Route path="/blog/category/:category" element={<BlogIndexPage />} />
        </Routes>
      </MemoryRouter>
    )

    await waitFor(() => {
      expect(useInfiniteBlogPosts).toHaveBeenLastCalledWith(
        expect.objectContaining({
          category: 'AI & Style',
          search: 'wardrobe',
          pageSize: 12,
          enabled: true,
        })
      )
    })
    expect(screen.getByText('AI & Style Articles')).toBeInTheDocument()
  })
})
