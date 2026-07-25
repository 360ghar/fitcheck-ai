/**
 * Tests for the FeatureErrorBoundary component.
 */
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { render, screen, fireEvent } from '@testing-library/react'

// Mock Sentry so componentDidCatch reporting is a no-op.
vi.mock('@sentry/react', () => ({
  captureException: vi.fn(),
}))

import FeatureErrorBoundary from '@/components/errors/FeatureErrorBoundary'

// Module-level mutable flag so the "reset" test can stop throwing before the
// boundary re-renders its children (props can't change mid-reset).
let shouldThrow = false

function Bomb() {
  if (shouldThrow) {
    throw new Error('Feature exploded')
  }
  return <div data-testid="feature-content">Feature OK</div>
}

describe('FeatureErrorBoundary', () => {
  beforeEach(() => {
    shouldThrow = false
    vi.spyOn(console, 'error').mockImplementation(() => {})
  })

  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('renders children when no error occurs', () => {
    render(
      <FeatureErrorBoundary featureName="Recommendations">
        <Bomb />
      </FeatureErrorBoundary>
    )

    expect(screen.getByTestId('feature-content')).toBeInTheDocument()
    expect(screen.getByText('Feature OK')).toBeInTheDocument()
  })

  it('shows inline error card with feature name when a child throws', () => {
    shouldThrow = true
    render(
      <FeatureErrorBoundary featureName="Wardrobe">
        <Bomb />
      </FeatureErrorBoundary>
    )

    expect(screen.getByText('Something went wrong in Wardrobe')).toBeInTheDocument()
    expect(screen.getByRole('alert')).toBeInTheDocument()
    expect(screen.getByText('Try Again')).toBeInTheDocument()
  })

  it('does NOT render a full-screen error (inline card only)', () => {
    shouldThrow = true
    render(
      <FeatureErrorBoundary featureName="Calendar">
        <Bomb />
      </FeatureErrorBoundary>
    )

    // Full-screen boundary has a "Go Home" button; the feature boundary does not.
    expect(screen.queryByText('Go Home')).not.toBeInTheDocument()
    expect(screen.getByRole('alert')).toBeInTheDocument()
  })

  it('renders custom fallback when provided', () => {
    shouldThrow = true
    render(
      <FeatureErrorBoundary
        featureName="Outfits"
        fallback={<div data-testid="custom">Custom fallback</div>}
      >
        <Bomb />
      </FeatureErrorBoundary>
    )

    expect(screen.getByTestId('custom')).toBeInTheDocument()
    expect(screen.queryByText('Something went wrong in Outfits')).not.toBeInTheDocument()
  })

  it('resets and re-renders children when Try Again is clicked', () => {
    shouldThrow = true
    render(
      <FeatureErrorBoundary featureName="Photoshoot">
        <Bomb />
      </FeatureErrorBoundary>
    )

    expect(screen.getByText('Something went wrong in Photoshoot')).toBeInTheDocument()

    shouldThrow = false
    fireEvent.click(screen.getByText('Try Again'))

    expect(screen.getByTestId('feature-content')).toBeInTheDocument()
    expect(screen.getByText('Feature OK')).toBeInTheDocument()
  })
})
