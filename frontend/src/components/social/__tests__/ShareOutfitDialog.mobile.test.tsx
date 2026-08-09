/**
 * ShareOutfitDialog mobile responsive contracts.
 *
 * jsdom ships no `matchMedia`, so the mobile (<xs / 375px, incl. the 320px
 * audit viewport) layout is the default render — no stub needed. Tailwind
 * classes are not evaluated in jsdom, so responsive state is asserted
 * structurally (class presence), matching the repo's other
 * responsive-contract tests (see ProfilePage.mobile.test.tsx).
 */
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

vi.mock('@/api/outfits', () => ({
  shareOutfit: vi.fn(),
}))

import ShareOutfitDialog from '@/components/social/ShareOutfitDialog'

function renderDialog() {
  return render(
    <ShareOutfitDialog
      isOpen
      onClose={vi.fn()}
      outfit={{ id: 'outfit-1', name: 'Weekend look', tags: [], images: [] } as never}
    />
  )
}

describe('ShareOutfitDialog mobile layout (<xs, no matchMedia)', () => {
  it('renders without crashing at mobile width', () => {
    renderDialog()

    expect(screen.getByRole('heading', { name: 'Share Outfit' })).toBeInTheDocument()
    // Both tabs and the preview row are present.
    expect(screen.getByRole('tab', { name: /Social/ })).toBeInTheDocument()
    expect(screen.getByRole('tab', { name: 'Share Link' })).toBeInTheDocument()
    expect(screen.getByRole('tab', { name: 'Options' })).toBeInTheDocument()
    expect(screen.getByText('Weekend look')).toBeInTheDocument()
  })

  it('splits the Social tab label below xs (full label from xs up)', () => {
    renderDialog()

    const fullLabel = screen.getByText('Social Media')
    expect(fullLabel).toHaveClass('hidden', 'xs:inline')
    const shortLabel = screen.getByText('Social')
    expect(shortLabel).toHaveClass('xs:hidden')
    // The short label is a strict subset of the full label — same trigger.
    expect(shortLabel.closest('button')).toBe(fullLabel.closest('button'))
  })

  it('keeps the tabs functional at mobile width', async () => {
    const user = userEvent.setup()
    renderDialog()

    await user.click(screen.getByRole('tab', { name: 'Options' }))
    expect(screen.getByText('Allow Feedback')).toBeInTheDocument()
  })

  it('stacks the outfit preview row and shrinks the image box below xs', () => {
    renderDialog()

    const row = screen.getByText('Weekend look').closest('div.flex')
    expect(row).not.toBeNull()
    expect(row).toHaveClass('flex-col', 'xs:flex-row')
    // Image box: w-24 on phones, w-32 from xs up.
    const imageBox = row?.querySelector('div.flex-shrink-0')
    expect(imageBox).not.toBeNull()
    expect(imageBox).toHaveClass('w-24', 'h-24', 'xs:w-32', 'xs:h-32')
  })
})
