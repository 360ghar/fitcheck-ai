import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it, vi } from 'vitest'
import { axe } from 'vitest-axe'

import { ConfirmDialog } from './ConfirmDialog'

import { renderWithProviders } from '@/test/utils'

describe('ConfirmDialog', () => {
  it('confirms and closes on success', async () => {
    const onConfirm = vi.fn().mockResolvedValue(undefined)
    const onOpenChange = vi.fn()
    renderWithProviders(
      <ConfirmDialog
        open
        title="Delete user"
        description="This cannot be undone."
        onConfirm={onConfirm}
        onOpenChange={onOpenChange}
      />,
    )
    expect(screen.getByText('Delete user')).toBeInTheDocument()
    expect(screen.getByText('This cannot be undone.')).toBeInTheDocument()

    await userEvent.click(screen.getByRole('button', { name: 'Confirm' }))
    expect(onConfirm).toHaveBeenCalledTimes(1)
    expect(onOpenChange).toHaveBeenCalledWith(false)
  })

  it('cancels without calling onConfirm', async () => {
    const onConfirm = vi.fn()
    const onOpenChange = vi.fn()
    renderWithProviders(
      <ConfirmDialog open title="Delete user" onConfirm={onConfirm} onOpenChange={onOpenChange} />,
    )
    await userEvent.click(screen.getByRole('button', { name: 'Cancel' }))
    expect(onConfirm).not.toHaveBeenCalled()
    expect(onOpenChange).toHaveBeenCalledWith(false)
  })

  it('disables buttons and shows a spinner while onConfirm is pending', async () => {
    let resolveConfirm: (() => void) | undefined
    const onConfirm = vi.fn().mockImplementation(
      () =>
        new Promise<void>((resolve) => {
          resolveConfirm = resolve
        }),
    )
    renderWithProviders(
      <ConfirmDialog open title="Delete user" onConfirm={onConfirm} onOpenChange={vi.fn()} />,
    )
    await userEvent.click(screen.getByRole('button', { name: 'Confirm' }))
    expect(onConfirm).toHaveBeenCalledTimes(1)
    expect(screen.getByRole('button', { name: 'Confirm' })).toBeDisabled()
    expect(screen.getByRole('button', { name: 'Cancel' })).toBeDisabled()
    // Radix portals dialog content into document.body, so query the document.
    expect(document.querySelector('.animate-spin')).not.toBeNull()
    resolveConfirm?.()
  })

  it('keeps the dialog open and shows an error when onConfirm rejects', async () => {
    const onConfirm = vi.fn().mockRejectedValue(new Error('backend exploded'))
    const onOpenChange = vi.fn()
    renderWithProviders(
      <ConfirmDialog open title="Delete user" onConfirm={onConfirm} onOpenChange={onOpenChange} />,
    )
    await userEvent.click(screen.getByRole('button', { name: 'Confirm' }))
    const alert = await screen.findByRole('alert')
    expect(alert).toHaveTextContent('The action failed. Try again.')
    expect(onOpenChange).not.toHaveBeenCalledWith(false)
  })

  it('has no axe violations (WCAG 2.1 AA)', async () => {
    renderWithProviders(
      <ConfirmDialog
        open
        title="Delete user"
        description="This cannot be undone."
        onConfirm={vi.fn()}
        onOpenChange={vi.fn()}
      />,
    )
    // Radix portals the dialog into document.body — axe the full document.
    expect(await axe(document.body)).toHaveNoViolations()
  })
})
