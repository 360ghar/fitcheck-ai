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

describe('BlogIndexPage responsive layout', () => {
  it('reserves spaced height for loading pills without overlapping the search form', () => {
    useBlogCategories.mockReturnValue({ data: undefined, isLoading: true })
    useInfiniteBlogPosts.mockReturnValue(mockEmptyInfinite())

    const { container } = render(
      <MemoryRouter initialEntries={['/blog']}>
        <Routes>
          <Route path="/blog" element={<BlogIndexPage />} />
        </Routes>
      </MemoryRouter>
    )

    const spacer = container.querySelector('[data-testid="categories-loading"]')
    expect(spacer).toHaveClass('mt-6', 'h-[256px]', 'md:h-[44px]')
    expect(screen.queryByTestId('category-pills')).not.toBeInTheDocument()
    expect(screen.getByRole('search')).toHaveClass('mt-6', 'w-full', 'max-w-xl')
  })

  it('renders the category pill row below the search form with spacing', async () => {
    useBlogCategories.mockReturnValue({ data: ['AI & Style'], isLoading: false })
    useInfiniteBlogPosts.mockReturnValue(mockEmptyInfinite())

    render(
      <MemoryRouter initialEntries={['/blog']}>
        <Routes>
          <Route path="/blog" element={<BlogIndexPage />} />
        </Routes>
      </MemoryRouter>
    )

    await waitFor(() => {
      expect(screen.getByTestId('category-pills')).toHaveClass('mt-6')
    })
  })
})
