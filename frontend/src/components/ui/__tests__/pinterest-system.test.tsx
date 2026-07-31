import { describe, expect, it } from 'vitest'
import { render, screen } from '@testing-library/react'
import { Button } from '../button'
import { FilterChip } from '../filter-chip'
import { SearchBar } from '../search-bar'
import { PinGrid } from '@/components/wardrobe/pin-grid'
import { AnimatedSection } from '@/components/landing/AnimatedSection'

describe('Pinterest visual primitives', () => {
  it('provides the documented primary and image-overlay button variants', () => {
    const { rerender } = render(<Button variant="primary">Save outfit</Button>)
    expect(screen.getByRole('button', { name: 'Save outfit' })).toHaveClass('bg-primary')
    expect(screen.getByRole('button', { name: 'Save outfit' })).toHaveClass('h-11')

    rerender(<Button variant="pill-on-image">Save</Button>)
    expect(screen.getByRole('button', { name: 'Save' })).toHaveClass('rounded-full')
  })

  it('keeps filter chips and search bars semantic and keyboard reachable', () => {
    render(<><FilterChip active>Outerwear</FilterChip><SearchBar aria-label="Search wardrobe" /></>)
    expect(screen.getByRole('button', { name: 'Outerwear' })).toHaveAttribute('aria-pressed', 'true')
    expect(screen.getByRole('searchbox', { name: 'Search wardrobe' })).toHaveClass('rounded-full')
  })

  it('uses column masonry without forcing its children into a crop', () => {
    const { container } = render(<PinGrid><article>Natural garment image</article></PinGrid>)
    expect(container.firstChild).toHaveClass('columns-2')
    expect(container.firstChild).toHaveClass('xl:columns-6')
    expect(container.firstChild).toHaveClass('[&>*]:break-inside-avoid')
  })

  it('renders content immediately instead of gating it behind a scroll reveal', () => {
    const { container } = render(
      <AnimatedSection delay={240}>
        <p>Visible wardrobe content</p>
      </AnimatedSection>
    )

    expect(screen.getByText('Visible wardrobe content')).toBeVisible()
    expect(container.firstChild).not.toHaveClass('opacity-0')
    expect(container.firstChild).toHaveAttribute('data-reveal-delay', '240')
  })
})
