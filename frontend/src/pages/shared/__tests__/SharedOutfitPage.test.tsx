import { render, screen, waitFor } from '@testing-library/react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { describe, expect, it, vi } from 'vitest'

const { getPublicOutfit } = vi.hoisted(() => ({ getPublicOutfit: vi.fn() }))

vi.mock('@/api/outfits', () => ({ getPublicOutfit }))
vi.mock('@/components/seo', () => ({ SEO: () => null, OutfitJsonLd: () => null }))

import SharedOutfitPage from '@/pages/shared/SharedOutfitPage'

describe('SharedOutfitPage', () => {
  it('preserves the outfit destination when sending a visitor to sign in', async () => {
    getPublicOutfit.mockResolvedValue({
      id: 'outfit-1',
      name: 'Weekend look',
      tags: [],
      images: [],
      items: [],
    })

    render(
      <MemoryRouter initialEntries={['/shared/outfits/outfit-1']}>
        <Routes>
          <Route path="/shared/outfits/:id" element={<SharedOutfitPage />} />
        </Routes>
      </MemoryRouter>
    )

    await waitFor(() => expect(screen.getByRole('link', { name: 'Sign in' })).toBeInTheDocument())
    expect(screen.getByRole('link', { name: 'Open in app' })).toHaveAttribute(
      'href',
      '/auth/login?returnTo=%2Foutfits%2Foutfit-1'
    )
  })
})
