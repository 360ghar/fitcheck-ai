import { render, screen } from '@testing-library/react'
import { describe, expect, it, vi } from 'vitest'

import { ErrorBoundary } from './ErrorBoundary'

function Boom(): never {
  throw new Error('boom')
}

describe('ErrorBoundary', () => {
  it('renders children when nothing throws', () => {
    render(
      <ErrorBoundary>
        <div>healthy-content</div>
      </ErrorBoundary>,
    )
    expect(screen.getByText('healthy-content')).toBeInTheDocument()
  })

  it('catches render errors and shows the themed fallback with a correlation id', () => {
    const onError = vi.fn((_error: Error, _info: unknown) => {})
    const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
    render(
      <ErrorBoundary onError={onError}>
        <Boom />
      </ErrorBoundary>,
    )
    expect(screen.getByText('Something went wrong')).toBeInTheDocument()
    expect(onError).toHaveBeenCalledTimes(1)
    const caught = onError.mock.calls[0]?.[0]
    expect(caught).toBeInstanceOf(Error)
    expect(caught?.message).toBe('boom')
    expect(screen.getByText(/corr-/)).toBeInTheDocument()
    consoleSpy.mockRestore()
  })

  it('offers reload and shows the error detail in dev builds', () => {
    const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
    render(
      <ErrorBoundary>
        <Boom />
      </ErrorBoundary>,
    )
    expect(screen.getByText('Something went wrong')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /reload/i })).toBeInTheDocument()
    expect(screen.getByText('boom')).toBeInTheDocument()
    consoleSpy.mockRestore()
  })
})
