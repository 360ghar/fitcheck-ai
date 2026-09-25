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
    render(<a href="/dashboard"><Logo compact /></a>)
    expect(screen.getByRole('link')).toHaveAccessibleName('FitCheck AI')
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
