import { renderHook } from '@testing-library/react'
import { afterEach, describe, expect, it, vi } from 'vitest'

import { useColumnCount } from '../useColumnCount'

/**
 * The dense closet ladder: 3 columns below `xs` (375px), 4 from `xs` through
 * just below `md`, then md:5 lg:6 xl:7 2xl:8 — and the split (detail-open)
 * table at lg+ (lg:3 xl:4 2xl:4). jsdom has no matchMedia, so the viewport
 * is stubbed per test.
 */
function stubViewport(width: number) {
  vi.stubGlobal('matchMedia', vi.fn().mockImplementation((query: string) => {
    const min = Number(query.match(/min-width:\s*(\d+)px/)?.[1] ?? 0)
    return {
      matches: width >= min,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      addListener: vi.fn(),
      removeListener: vi.fn(),
    }
  }))
}

afterEach(() => {
  vi.unstubAllGlobals()
})

describe('useColumnCount', () => {
  it.each([
    [320, 3, 'small phone keeps 3 dense columns'],
    [360, 3, '360px phone keeps 3 dense columns'],
    [375, 4, 'xs (375px) steps up to 4'],
    [390, 4, 'large phone stays 4'],
    [640, 4, 'sm stays 4 (no down-step between xs and md)'],
    [767, 4, 'just below md stays 4'],
    [768, 5, 'md is 5'],
    [1024, 6, 'lg is 6'],
    [1280, 7, 'xl is 7'],
    [1536, 8, '2xl is 8'],
  ])('returns %i columns at %ipx (%s)', (width, expected) => {
    stubViewport(width)
    const { result } = renderHook(() => useColumnCount())
    expect(result.current).toBe(expected)
  })

  it.each([
    [1024, 3, 'lg split is 3'],
    [1280, 4, 'xl split is 4'],
    [1536, 4, '2xl split is 4'],
  ])('with the detail pane open returns %i columns at %ipx (%s)', (width, expected) => {
    stubViewport(width)
    const { result } = renderHook(() => useColumnCount({ isDetailOpen: true }))
    expect(result.current).toBe(expected)
  })

  it('ignores the split table below lg (md-band uses forced list rows instead)', () => {
    stubViewport(768)
    const { result } = renderHook(() => useColumnCount({ isDetailOpen: true }))
    expect(result.current).toBe(5)
  })
})
