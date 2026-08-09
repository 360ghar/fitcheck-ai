import { screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { axe } from 'vitest-axe'

import { Dialog, DialogContent, DialogTitle } from './dialog'

import { renderWithProviders } from '@/test/utils'

describe('DialogContent', () => {
  it('caps the height and scrolls so tall dialogs fit short phone viewports', () => {
    renderWithProviders(
      <Dialog open>
        <DialogContent>
          <DialogTitle>Edit user</DialogTitle>
        </DialogContent>
      </Dialog>,
    )
    const dialog = screen.getByRole('dialog')
    expect(dialog).toHaveClass('max-h-[85dvh]')
    expect(dialog).toHaveClass('overflow-y-auto')
  })

  it('keeps the translated close button reachable in the scrollable content', () => {
    renderWithProviders(
      <Dialog open>
        <DialogContent>
          <DialogTitle>Edit user</DialogTitle>
        </DialogContent>
      </Dialog>,
    )
    expect(screen.getByRole('button', { name: 'Close' })).toBeInTheDocument()
  })

  it('has no axe violations (WCAG 2.1 AA)', async () => {
    renderWithProviders(
      <Dialog open>
        <DialogContent>
          <DialogTitle>Edit user</DialogTitle>
        </DialogContent>
      </Dialog>,
    )
    // Radix portals the dialog into document.body — axe the full document.
    expect(await axe(document.body)).toHaveNoViolations()
  })
})
