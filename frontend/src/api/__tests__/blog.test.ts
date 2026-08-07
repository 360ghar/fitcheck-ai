import { beforeEach, describe, expect, it, vi } from 'vitest'

const { get } = vi.hoisted(() => ({ get: vi.fn() }))

vi.mock('@/api/client', () => ({
  apiClient: { get },
  getApiError: (error: unknown) => error,
}))

import { getBlogPosts } from '@/api/blog'

describe('blog API filters', () => {
  beforeEach(() => get.mockReset())

  it('sends both exact category and search filters without changing the endpoint contract', async () => {
    get.mockResolvedValue({ data: { data: { posts: [], total_pages: 1 } } })

    await getBlogPosts(2, 12, 'AI & Style', 'wardrobe')

    expect(get).toHaveBeenCalledWith('/api/v1/blog/posts', {
      params: { page: 2, page_size: 12, category: 'AI & Style', search: 'wardrobe' },
    })
  })
})
