import { renderHook } from '@testing-library/react'
import { afterEach, describe, expect, it, vi } from 'vitest'

import { useColumnCount } from '../useColumnCount'

/**
 * The dense closet ladder: 3 columns below `xs` (375px), 4 from `xs` through
 * `md`, then lg:5 xl:6 2xl:7 — and the split (detail-open) table at lg+.
 * jsdom has no matchMedia, so the viewport is stubbed per test.
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
    [768, 4, 'md is 4'],
    [1024, 5, 'lg is 5'],
    [1280, 6, 'xl is 6'],
    [1536, 7, '2xl is 7'],
  ])('at %ipx returns %i columns (%s)', (width, expected) => {
    stubViewport(width)
    const { result } = renderHook(() => useColumnCount())
    expect(result.current).toBe(expected)
  })

  it.each([
    [1024, 2, 'lg split is 2'],
    [1280, 3, 'xl split is 3'],
    [1536, 4, '2xl split is 4'],
  ])('with the detail pane open at %ipx returns %i columns (%s)', (width, expected) => {
    stubViewport(width)
    const { result } = renderHook(() => useColumnCount({ isDetailOpen: true }))
    expect(result.current).toBe(expected)
  })

  it.each([
    [320, 4, 'small phone is 4'],
    [390, 4, 'large phone is 4'],
    [767, 4, 'just below md is 4'],
    [768, 6, 'md is 6'],
    [1024, 7, 'lg is 7'],
    [1280, 8, 'xl is 8'],
    [1536, 9, '2xl is 9'],
  ])('dense (item cutouts) at %ipx returns %i columns (%s)', (width, expected) => {
    stubViewport(width)
    const { result } = renderHook(() => useColumnCount({ dense: true }))
    expect(result.current).toBe(expected)
  })

  it.each([
    [1024, 4, 'lg dense split is 4'],
    [1280, 5, 'xl dense split is 5'],
    [1536, 6, '2xl dense split is 6'],
  ])('dense with the detail pane open at %ipx returns %i columns (%s)', (width, expected) => {
    stubViewport(width)
    const { result } = renderHook(() => useColumnCount({ dense: true, isDetailOpen: true }))
    expect(result.current).toBe(expected)
  })

  it('ignores the split table below lg (md-band uses forced list rows instead)', () => {
    stubViewport(768)
    const { result } = renderHook(() => useColumnCount({ isDetailOpen: true }))
    expect(result.current).toBe(4)
  })
})
