import { describe, expect, it } from 'vitest'
import { isUnsplashImageUrl, unsplashSrc, unsplashSrcSet } from './images'

const STORED_URL = 'https://images.unsplash.com/photo-1551232864-3f0890e580d9?w=800&q=80'

describe('isUnsplashImageUrl', () => {
  it('accepts https unsplash image URLs', () => {
    expect(isUnsplashImageUrl(STORED_URL)).toBe(true)
  })

  it('rejects non-unsplash and malformed URLs', () => {
    expect(isUnsplashImageUrl('https://example.com/photo.jpg')).toBe(false)
    expect(isUnsplashImageUrl('not a url')).toBe(false)
  })
})

describe('unsplashSrc', () => {
  it('replaces stored params with optimized ones', () => {
    const out = unsplashSrc(STORED_URL, 640)
    const url = new URL(out)
    expect(url.origin + url.pathname).toBe('https://images.unsplash.com/photo-1551232864-3f0890e580d9')
    expect(url.searchParams.get('auto')).toBe('format')
    expect(url.searchParams.get('w')).toBe('640')
    expect(url.searchParams.get('q')).toBe('70')
    expect(url.searchParams.get('fm')).toBeNull()
  })

  it('honours a custom quality', () => {
    const url = new URL(unsplashSrc(STORED_URL, 1280, 75))
    expect(url.searchParams.get('q')).toBe('75')
  })

  it('passes non-unsplash URLs through unchanged', () => {
    const other = 'https://images.example.com/storage/photo.webp?w=200'
    expect(unsplashSrc(other, 640)).toBe(other)
  })

  it('is idempotent on already-optimized URLs', () => {
    const once = unsplashSrc(STORED_URL, 480)
    const twice = unsplashSrc(once, 480)
    expect(twice).toBe(once)
  })

  it('keeps unrelated stored params while replacing w and q', () => {
    const out = unsplashSrc('https://images.unsplash.com/photo-abc?w=800&q=80&ixid=abc&fit=crop', 640)
    expect(out).toContain('ixid=abc')
    expect(out).toContain('fit=crop')
    expect(out).toContain('w=640')
    expect(out).toContain('q=70')
    expect(out).toContain('auto=format')
  })
})

describe('unsplashSrcSet', () => {
  it('emits width descriptors in order', () => {
    const set = unsplashSrcSet(STORED_URL, [320, 480, 640])
    expect(set).toBe(
      `${unsplashSrc(STORED_URL, 320)} 320w, ${unsplashSrc(STORED_URL, 480)} 480w, ${unsplashSrc(STORED_URL, 640)} 640w`
    )
  })
})
