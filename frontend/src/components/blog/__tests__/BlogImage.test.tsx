import { fireEvent, render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { BlogImage } from '@/components/blog/BlogImage'

const BASE_PROPS = {
  alt: 'A post',
  sizes: '100vw',
  widths: [320, 640],
  width: 640,
  height: 360,
}

describe('BlogImage', () => {
  it('rewrites Unsplash srcs to auto=format with a responsive srcset', () => {
    render(<BlogImage {...BASE_PROPS} src="https://images.unsplash.com/photo-abc?w=800&q=80" />)
    const img = screen.getByAltText('A post') as HTMLImageElement
    expect(img.src).toContain('images.unsplash.com/photo-abc')
    expect(img.src).toContain('auto=format')
    expect(img.src).not.toContain('w=800&q=80')
    expect(img.srcset).toContain('320w')
    expect(img.srcset).toContain('640w')
  })

  it('passes non-Unsplash URLs through unchanged', () => {
    render(<BlogImage {...BASE_PROPS} src="https://cdn.example.com/cover.jpg" />)
    const img = screen.getByAltText('A post') as HTMLImageElement
    expect(img.src).toBe('https://cdn.example.com/cover.jpg')
    expect(img.hasAttribute('srcset')).toBe(false)
  })

  it('lazy-loads by default and eager-loads priority images', () => {
    const { rerender } = render(<BlogImage {...BASE_PROPS} src="https://images.unsplash.com/photo-abc" />)
    // jsdom does not expose the `loading` IDL property — assert the attribute.
    expect((screen.getByAltText('A post') as HTMLImageElement).getAttribute('loading')).toBe('lazy')

    rerender(<BlogImage {...BASE_PROPS} src="https://images.unsplash.com/photo-abc" priority />)
    const img = screen.getByAltText('A post') as HTMLImageElement
    expect(img.getAttribute('loading')).toBe('eager')
    expect(img.getAttribute('fetchpriority')).toBe('high')
  })

  it('shows the emoji fallback when the image fails to load', () => {
    render(<BlogImage {...BASE_PROPS} src="https://images.unsplash.com/photo-abc" emoji="👖" />)
    fireEvent.error(screen.getByAltText('A post'))
    expect(screen.getByText('👖')).toBeTruthy()
    expect(screen.queryByAltText('A post')).toBeNull()
  })

  it('retries a new src after a previous src failed', () => {
    const { rerender } = render(
      <BlogImage {...BASE_PROPS} src="https://images.unsplash.com/photo-broken" emoji="👟" />
    )
    fireEvent.error(screen.getByAltText('A post'))
    expect(screen.getByText('👟')).toBeTruthy()
    expect(screen.queryByAltText('A post')).toBeNull()

    rerender(<BlogImage {...BASE_PROPS} src="https://images.unsplash.com/photo-fixed" emoji="👟" />)
    expect(screen.getByAltText('A post')).toBeTruthy()
    expect(screen.queryByText('👟')).toBeNull()

    rerender(<BlogImage {...BASE_PROPS} src="https://images.unsplash.com/photo-broken" emoji="👟" />)
    expect(screen.getByText('👟')).toBeTruthy()
    expect(screen.queryByAltText('A post')).toBeNull()
  })

  it('falls back to the width prop when widths is empty', () => {
    render(<BlogImage {...BASE_PROPS} src="https://images.unsplash.com/photo-abc" widths={[]} />)
    const img = screen.getByAltText('A post') as HTMLImageElement
    expect(img.src).toContain('w=640')
  })

  it('shows the emoji fallback when src is missing', () => {
    render(<BlogImage {...BASE_PROPS} emoji="👔" />)
    expect(screen.getByText('👔')).toBeTruthy()
  })

  it('renders nothing when src is missing and there is no emoji', () => {
    const { container } = render(<BlogImage {...BASE_PROPS} />)
    expect(container.firstChild).toBeNull()
  })
})
