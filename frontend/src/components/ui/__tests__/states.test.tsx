import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Shirt } from 'lucide-react'
import { EmptyState } from '../empty-state'
import { ErrorState } from '../error-state'

// These two components are now the shared empty/error surface across Wardrobe,
// Outfits, Calendar, Dashboard, Recommendations and Gamification. The point of
// rolling them out was that a failed load must always offer a way forward, so
// that is what these lock down.

describe('EmptyState', () => {
  it('offers a way forward and invokes it', async () => {
    const onAction = vi.fn()
    render(
      <EmptyState
        icon={Shirt}
        title="Your wardrobe is empty"
        description="Upload photos to get started."
        actionLabel="Upload photos"
        onAction={onAction}
      />
    )

    expect(screen.getByText('Your wardrobe is empty')).toBeInTheDocument()
    expect(screen.getByText('Upload photos to get started.')).toBeInTheDocument()

    await userEvent.click(screen.getByRole('button', { name: 'Upload photos' }))
    expect(onAction).toHaveBeenCalledOnce()
  })

  it('renders without an action when there is nothing to do', () => {
    render(<EmptyState title="Nothing here" />)
    expect(screen.queryByRole('button')).not.toBeInTheDocument()
  })
})

describe('ErrorState', () => {
  it('announces itself and retries', async () => {
    const onRetry = vi.fn()
    render(
      <ErrorState
        title="Couldn't load this month"
        description="Network request failed"
        onRetry={onRetry}
      />
    )

    // role="alert" so a screen reader hears the failure rather than a silently
    // empty region -- this is the whole reason the state exists.
    expect(screen.getByRole('alert')).toBeInTheDocument()
    expect(screen.getByText('Network request failed')).toBeInTheDocument()

    await userEvent.click(screen.getByRole('button', { name: /try again/i }))
    expect(onRetry).toHaveBeenCalledOnce()
  })
})
