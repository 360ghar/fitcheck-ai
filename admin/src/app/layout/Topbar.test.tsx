import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'

import { Topbar } from './Topbar'

import { useCommandStore } from '@/shared/stores/commandStore'
import { renderWithProviders } from '@/test/utils'

describe('Topbar', () => {
  it('renders a mobile-only search trigger with the translated label', () => {
    renderWithProviders(<Topbar onMenuClick={vi.fn()} />)
    const trigger = screen.getByRole('button', { name: 'Search' })
    // Visible below `sm` only — the desktop ⌘K input covers larger screens.
    expect(trigger).toHaveClass('sm:hidden')
    expect(trigger).toHaveAccessibleName('Search')
  })

  it('opens the command palette from the mobile search trigger', async () => {
    const user = userEvent.setup()
    useCommandStore.setState({ open: false })
    renderWithProviders(<Topbar onMenuClick={vi.fn()} />)
    await user.click(screen.getByRole('button', { name: 'Search' }))
    expect(useCommandStore.getState().open).toBe(true)
    useCommandStore.setState({ open: false })
  })

  it('keeps the desktop search input for larger screens', () => {
    renderWithProviders(<Topbar onMenuClick={vi.fn()} />)
    expect(screen.getByRole('button', { name: 'Global search' })).toBeInTheDocument()
  })
})
