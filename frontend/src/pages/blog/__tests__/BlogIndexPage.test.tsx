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
  it('uses responsive skeleton pills while categories load', () => {
    useBlogCategories.mockReturnValue({ data: undefined, isLoading: true })
    useInfiniteBlogPosts.mockReturnValue(mockEmptyInfinite())

    render(
      <MemoryRouter initialEntries={['/blog']}>
        <Routes>
          <Route path="/blog" element={<BlogIndexPage />} />
        </Routes>
      </MemoryRouter>
    )

    const search = screen.getByRole('search')
    const categoryRow = search.nextElementSibling as HTMLElement
    expect(categoryRow).toHaveClass(
      'flex',
      'flex-wrap',
      'min-h-[9.75rem]',
      'xs:min-h-[8rem]',
      'sm:min-h-[6.5rem]',
      'md:min-h-11'
    )
    expect(categoryRow).not.toHaveClass('h-[256px]', 'md:h-[44px]')
    expect(categoryRow.querySelectorAll('[aria-hidden="true"]')).toHaveLength(6)
  })

  it('renders the category pill row directly below the search form', async () => {
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
      const search = screen.getByRole('search')
      const categoryRow = search.nextElementSibling as HTMLElement
      expect(categoryRow).toHaveClass(
        'flex',
        'flex-wrap',
        'min-h-[9.75rem]',
        'xs:min-h-[8rem]',
        'sm:min-h-[6.5rem]',
        'md:min-h-11'
      )
      expect(categoryRow).toContainElement(screen.getByRole('link', { name: 'All' }))
      expect(categoryRow).toContainElement(screen.getByRole('link', { name: 'AI & Style' }))
    })
  })

  it('does not reserve a blank category band when category loading fails', () => {
    useBlogCategories.mockReturnValue({
      data: undefined,
      isLoading: false,
      error: new Error('categories unavailable'),
    })
    useInfiniteBlogPosts.mockReturnValue(mockEmptyInfinite())

    render(
      <MemoryRouter initialEntries={['/blog/category/ai-style']}>
        <Routes>
          <Route path="/blog/category/:category" element={<BlogIndexPage />} />
        </Routes>
      </MemoryRouter>
    )

    const search = screen.getByRole('search')
    const categoryRow = search.nextElementSibling as HTMLElement
    expect(categoryRow).not.toHaveClass('min-h-[9.75rem]', 'xs:min-h-[8rem]', 'sm:min-h-[6.5rem]', 'md:min-h-11')
    expect(screen.getByRole('alert')).toHaveTextContent('Unable to load blog categories.')
  })
})
