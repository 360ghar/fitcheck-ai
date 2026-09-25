import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { Logo } from '../Logo'

describe('Logo', () => {
  it('names the brand and hides the mark from assistive tech', () => {
    const { container } = render(<Logo />)
    expect(screen.getByText('FitCheck')).toBeInTheDocument()
    expect(container.querySelector('svg')).toHaveAttribute('aria-hidden', 'true')
  })

  it('keeps the name readable when compact', () => {
    render(<Logo compact />)
    expect(screen.getByText('FitCheck')).toHaveClass('sr-only')
  })

  it('gives each mark its own path id', () => {
    const { container } = render(
      <>
        <Logo />
        <Logo />
      </>,
    )
    const ids = [...container.querySelectorAll('path[id]')].map((p) => p.id)
    expect(new Set(ids).size).toBe(2)
  })
})
