import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { renderHook } from '@testing-library/react'
import { useInfiniteScroll } from '../useInfiniteScroll'

/**
 * Minimal IntersectionObserver harness: every callback is recorded and can be
 * fired on demand. jsdom does not ship IntersectionObserver, so the hook's
 * `typeof IntersectionObserver === 'undefined'` guard would short-circuit
 * without this global.
 */
type IOCallback = (entries: IntersectionObserverEntry[]) => void
interface MockObserver {
  callback: IOCallback
  root: Element | null
  rootMargin: string
  threshold: number | number[]
  observe: ReturnType<typeof vi.fn>
  unobserve: ReturnType<typeof vi.fn>
  disconnect: ReturnType<typeof vi.fn>
}

describe('useInfiniteScroll', () => {
  let observers: MockObserver[]
  let IntersectionObserver: ReturnType<typeof vi.fn>

  beforeEach(() => {
    observers = []
    IntersectionObserver = vi.fn((callback: IOCallback, options: IntersectionObserverInit) => {
      const obs: MockObserver = {
        callback,
        root: (options.root as Element | null) ?? null,
        rootMargin: options.rootMargin ?? '0px',
        threshold: options.threshold ?? 0,
        observe: vi.fn(),
        unobserve: vi.fn(),
        disconnect: vi.fn(),
      }
      observers.push(obs)
      return obs
    })
    vi.stubGlobal('IntersectionObserver', IntersectionObserver)
  })

  afterEach(() => {
    vi.unstubAllGlobals()
    vi.restoreAllMocks()
  })

  function intersect(obs: MockObserver, isIntersecting: boolean) {
    obs.callback([
      { isIntersecting } as unknown as IntersectionObserverEntry,
    ])
  }

  it('fires onLoadMore when the sentinel intersects and more is available', () => {
    const onLoadMore = vi.fn()
    const { result } = renderHook(() =>
      useInfiniteScroll({ onLoadMore, hasMore: true, isLoading: false })
    )
    // Attach a node so the observer has something to observe.
    result.current(document.createElement('div'))
    expect(observers.length).toBe(1)

    intersect(observers[0], true)
    expect(onLoadMore).toHaveBeenCalledTimes(1)
  })

  it('does not fire when hasMore is false', () => {
    const onLoadMore = vi.fn()
    const { result } = renderHook(() =>
      useInfiniteScroll({ onLoadMore, hasMore: false, isLoading: false })
    )
    result.current(document.createElement('div'))
    intersect(observers[0], true)
    expect(onLoadMore).not.toHaveBeenCalled()
  })

  it('does not fire while a fetch is loading', () => {
    const onLoadMore = vi.fn()
    const { result, rerender } = renderHook(
      ({ isLoading }) => useInfiniteScroll({ onLoadMore, hasMore: true, isLoading }),
      { initialProps: { isLoading: false } }
    )
    result.current(document.createElement('div'))
    intersect(observers[0], true) // first fire lands
    expect(onLoadMore).toHaveBeenCalledTimes(1)

    // Flip to loading; the latch is set so a second intersect must not fire again.
    rerender({ isLoading: true })
    intersect(observers[0], true)
    expect(onLoadMore).toHaveBeenCalledTimes(1)

    // Leave the zone (latch resets), come back while still loading → still suppressed.
    intersect(observers[0], false)
    rerender({ isLoading: false })
    intersect(observers[0], true)
    expect(onLoadMore).toHaveBeenCalledTimes(2)
  })

  it('respects the disabled gate', () => {
    const onLoadMore = vi.fn()
    const { result } = renderHook(() =>
      useInfiniteScroll({ onLoadMore, hasMore: true, isLoading: false, disabled: true })
    )
    result.current(document.createElement('div'))
    intersect(observers[0], true)
    expect(onLoadMore).not.toHaveBeenCalled()
  })

  it('re-fires when a fetch settles while the sentinel is still intersecting (F1-08)', () => {
    // Regression: a failed or short append used to leave the one-shot latch
    // set with the sentinel still in the zone, stalling auto-paging until
    // the user scrolled away and back. The latch must clear when isLoading
    // flips true → false and the fire re-check runs.
    const onLoadMore = vi.fn()
    const { result, rerender } = renderHook(
      ({ isLoading, hasMore }) =>
        useInfiniteScroll({ onLoadMore, hasMore, isLoading }),
      { initialProps: { isLoading: false, hasMore: true } }
    )
    result.current(document.createElement('div'))

    intersect(observers[0], true)
    expect(onLoadMore).toHaveBeenCalledTimes(1)

    // Fetch in flight: no re-fire yet.
    rerender({ isLoading: true, hasMore: true })
    expect(onLoadMore).toHaveBeenCalledTimes(1)

    // Fetch settles with the sentinel STILL intersecting: the latch clears
    // and fire() re-checks (hasMore/isLoading) → auto-append continues.
    rerender({ isLoading: false, hasMore: true })
    expect(onLoadMore).toHaveBeenCalledTimes(2)

    // It must stop once the server reports no more pages.
    rerender({ isLoading: false, hasMore: false })
    expect(onLoadMore).toHaveBeenCalledTimes(2)
  })
})
