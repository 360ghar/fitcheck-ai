/**
 * Tests for the top-level ErrorBoundary component.
 */
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { render, screen, fireEvent } from '@testing-library/react'

// Mock the error-reporting wrapper so componentDidCatch reporting is a no-op.
// The boundary no longer talks to @sentry/react directly — lib/error-reporting
// owns that, and lazy-imports the SDK only when a DSN is configured.
vi.mock('../../../lib/error-reporting', () => ({
  captureException: vi.fn(),
  initErrorReporting: vi.fn(),
}))

import ErrorBoundary from '@/components/errors/ErrorBoundary'

// Module-level mutable flag so the "reset" test can stop throwing before the
// boundary re-renders its children (props can't change mid-reset).
let shouldThrow = false

function Bomb() {
  if (shouldThrow) {
    throw new Error('Test render error')
  }
  return <div data-testid="child-content">All good</div>
}

describe('ErrorBoundary', () => {
  beforeEach(() => {
    shouldThrow = false
    // Suppress React error boundary console noise in test output.
    vi.spyOn(console, 'error').mockImplementation(() => {})
  })

  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('renders children when no error occurs', () => {
    render(
      <ErrorBoundary>
        <Bomb />
      </ErrorBoundary>
    )

    expect(screen.getByTestId('child-content')).toBeInTheDocument()
    expect(screen.getByText('All good')).toBeInTheDocument()
  })

  it('shows fallback UI when a child throws', () => {
    shouldThrow = true
    render(
      <ErrorBoundary>
        <Bomb />
      </ErrorBoundary>
    )

    expect(screen.getByText('Something went wrong')).toBeInTheDocument()
    expect(screen.getByText('Try Again')).toBeInTheDocument()
    expect(screen.getByText('Go Home')).toBeInTheDocument()
  })

  it('renders custom fallback when provided', () => {
    shouldThrow = true
    render(
      <ErrorBoundary fallback={<div data-testid="custom-fallback">Custom error</div>}>
        <Bomb />
      </ErrorBoundary>
    )

    expect(screen.getByTestId('custom-fallback')).toBeInTheDocument()
    expect(screen.queryByText('Something went wrong')).not.toBeInTheDocument()
  })

  it('resets and re-renders children when Try Again is clicked', () => {
    shouldThrow = true
    render(
      <ErrorBoundary>
        <Bomb />
      </ErrorBoundary>
    )

    // Error state
    expect(screen.getByText('Something went wrong')).toBeInTheDocument()

    // Stop throwing, then click Try Again to reset the boundary.
    shouldThrow = false
    fireEvent.click(screen.getByText('Try Again'))

    expect(screen.getByTestId('child-content')).toBeInTheDocument()
    expect(screen.getByText('All good')).toBeInTheDocument()
  })

  it('reports the error through lib/error-reporting', async () => {
    const { captureException } = await import('../../../lib/error-reporting')
    shouldThrow = true

    render(
      <ErrorBoundary>
        <Bomb />
      </ErrorBoundary>
    )

    expect(captureException).toHaveBeenCalledWith(
      expect.any(Error),
      expect.objectContaining({ extra: expect.any(Object) })
    )
  })
})
