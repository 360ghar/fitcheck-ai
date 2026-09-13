import { act, fireEvent, render, screen, waitFor } from '@testing-library/react'
import { MemoryRouter, Route, Routes, useNavigate } from 'react-router-dom'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import GiftClaimPage from '../GiftClaimPage'

const { getPublicGift } = vi.hoisted(() => ({
  getPublicGift: vi.fn(),
}))

vi.mock('@/api/gifts', () => ({
  claimGift: vi.fn(),
  getPublicGift,
  giftErrorMessage: () => 'This gift could not be loaded.',
}))

vi.mock('@/components/gifts/GiftCardPreview', () => ({
  GiftCardPreview: () => <div data-testid="gift-card-preview" />,
}))

vi.mock('@/components/seo', () => ({ SEO: () => null }))

vi.mock('@/lib/gift-claim-credential', () => ({
  captureGiftClaimCredentialFromLocation: () => null,
  forgetGiftClaimCredential: vi.fn(),
  readGiftClaimCredential: () => '',
}))

vi.mock('@/stores/authStore', () => ({
  useAuthStore: <T,>(selector: (state: { user: { email_verified: boolean } }) => T) =>
    selector({ user: { email_verified: true } }),
  useIsAuthenticated: () => true,
}))

describe('GiftClaimPage credential safety', () => {
  beforeEach(() => {
    getPublicGift.mockResolvedValue({
      public_id: 'gift-123',
      from_name: 'Sam',
      to_name: 'Alex',
      duration_months: 1,
      retail_value_cents: 1200,
      status: 'issued',
      created_at: '2026-08-29T00:00:00Z',
      artwork_version: 1,
      og_image_url: '/gift.png',
    })
  })

  it('excludes the printed gift credential field from session recording', async () => {
    render(
      <MemoryRouter initialEntries={['/gift/gift-123']}>
        <Routes>
          <Route path="/gift/:publicId" element={<GiftClaimPage />} />
        </Routes>
      </MemoryRouter>,
    )

    expect(
      await screen.findByRole('textbox', { name: 'Enter a code from a legacy gift' }),
    ).toHaveClass('ph-no-capture')
  })

  it('explains the verified-email rule for named gifts', async () => {
    render(
      <MemoryRouter initialEntries={['/gift/gift-123']}>
        <Routes>
          <Route path="/gift/:publicId" element={<GiftClaimPage />} />
        </Routes>
      </MemoryRouter>,
    )

    expect(
      await screen.findByText(/Named gifts can only be claimed by the recipient's verified email\./),
    ).toBeInTheDocument()
  })

  it('ignores a public-gift response superseded by route navigation', async () => {
    let resolveFirst!: (value: Record<string, unknown>) => void
    let resolveSecond!: (value: Record<string, unknown>) => void
    const first = new Promise<Record<string, unknown>>((resolve) => {
      resolveFirst = resolve
    })
    const second = new Promise<Record<string, unknown>>((resolve) => {
      resolveSecond = resolve
    })
    getPublicGift.mockReset()
    getPublicGift.mockReturnValueOnce(first)
    getPublicGift.mockReturnValueOnce(second)

    function NavigateToSecondGift() {
      const navigate = useNavigate()
      return <button onClick={() => navigate('/gift/gift-456')}>Next gift</button>
    }

    render(
      <MemoryRouter initialEntries={['/gift/gift-123']}>
        <NavigateToSecondGift />
        <Routes>
          <Route path="/gift/:publicId" element={<GiftClaimPage />} />
        </Routes>
      </MemoryRouter>,
    )

    await waitFor(() => expect(getPublicGift).toHaveBeenCalledWith('gift-123'))
    fireEvent.click(screen.getByRole('button', { name: 'Next gift' }))
    await waitFor(() => expect(getPublicGift).toHaveBeenCalledWith('gift-456'))

    await act(async () => {
      resolveSecond({
        public_id: 'gift-456',
        from_name: 'Second sender',
        to_name: 'Alex',
        duration_months: 1,
        retail_value_cents: 1200,
        status: 'issued',
        created_at: '2026-08-29T00:00:00Z',
        artwork_version: 1,
        og_image_url: '/gift.png',
      })
    })
    await act(async () => {
      resolveFirst({
        public_id: 'gift-123',
        from_name: 'First sender',
        to_name: 'Alex',
        duration_months: 1,
        retail_value_cents: 1200,
        status: 'issued',
        created_at: '2026-08-29T00:00:00Z',
        artwork_version: 1,
        og_image_url: '/gift.png',
      })
    })

    expect(await screen.findByText('Second sender made this for you.')).toBeInTheDocument()
    expect(screen.queryByText('First sender made this for you.')).not.toBeInTheDocument()
  })
})
