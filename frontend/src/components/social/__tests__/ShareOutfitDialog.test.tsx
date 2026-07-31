import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

vi.mock('@/api/outfits', () => ({
  shareOutfit: vi.fn(),
}))

import ShareOutfitDialog from '@/components/social/ShareOutfitDialog'

describe('ShareOutfitDialog options', () => {
  it('does not expose an unsupported comments setting', async () => {
    const user = userEvent.setup()
    render(
      <ShareOutfitDialog
        isOpen
        onClose={vi.fn()}
        outfit={{ id: 'outfit-1', name: 'Weekend look', tags: [], images: [] } as never}
      />
    )

    await user.click(screen.getByRole('tab', { name: 'Options' }))

    expect(screen.getByText('Allow Feedback')).toBeInTheDocument()
    expect(screen.queryByText('Allow Comments')).not.toBeInTheDocument()
  })
})
