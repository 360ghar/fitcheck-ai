/**
 * A missing thumbnail must not render as a broken tile.
 *
 * `materialize_image_urls` derives `{key}_thumb.webp` for every canonical key
 * when THUMBNAIL_SERVING is on, with NO existence check — and the object
 * legitimately may not exist (`_upload_thumbnail` is best-effort and returns
 * False without writing on an undecodable/failed encode; the whole pre-feature
 * corpus has none until the backfill runs). Clients prefer
 * `thumbnail_url || image_url`, which only falls back on an EMPTY field, never
 * on a 404 — so the tile stayed permanently broken while the full-size image was
 * present and healthy.
 */
import { act, fireEvent, render, renderHook, screen } from '@testing-library/react'
import { describe, expect, it, vi } from 'vitest'

import { ItemImage } from '@/components/ui/item-image'
import {
  thumbnailErrorFallback,
  useImageWithFallback,
} from '@/hooks/useImageWithFallback'
import type { Item } from '@/types'

function Probe({
  preferred,
  fallback,
  onExhausted,
  resetKey,
}: {
  preferred?: string
  fallback?: string
  onExhausted?: () => void
  resetKey?: unknown
}) {
  const { src, hasError, onError, usingFallback } = useImageWithFallback(preferred, fallback, {
    onExhausted,
    resetKey,
  })
  return (
    <div>
      <img
        src={src ?? undefined}
        alt="probe"
        onError={(e) => onError(e.currentTarget.currentSrc || e.currentTarget.src)}
      />
      <span data-testid="state">
        {hasError ? 'error' : usingFallback ? 'fallback' : 'preferred'}
      </span>
    </div>
  )
}

describe('useImageWithFallback', () => {
  it('serves the thumbnail until it fails, then the full size', () => {
    render(<Probe preferred="/a_thumb.webp" fallback="/a.webp" />)
    const img = screen.getByAltText('probe')

    expect(img).toHaveAttribute('src', '/a_thumb.webp')
    expect(screen.getByTestId('state')).toHaveTextContent('preferred')

    fireEvent.error(img)

    expect(screen.getByAltText('probe')).toHaveAttribute('src', '/a.webp')
    expect(screen.getByTestId('state')).toHaveTextContent('fallback')
  })

  it('reports an error only once BOTH sources have failed', () => {
    render(<Probe preferred="/a_thumb.webp" fallback="/a.webp" />)

    fireEvent.error(screen.getByAltText('probe'))
    expect(screen.getByTestId('state')).toHaveTextContent('fallback')

    fireEvent.error(screen.getByAltText('probe'))
    expect(screen.getByTestId('state')).toHaveTextContent('error')
  })

  it('does not retry an identical fallback URL', () => {
    // The backend mirrors thumbnail_url onto image_url when thumbnail serving is
    // off, so retrying the same URL would just burn a second request.
    render(<Probe preferred="/same.webp" fallback="/same.webp" />)

    fireEvent.error(screen.getByAltText('probe'))

    expect(screen.getByTestId('state')).toHaveTextContent('error')
  })

  it('errors immediately when there is no fallback at all', () => {
    render(<Probe preferred="/only.webp" />)

    fireEvent.error(screen.getByAltText('probe'))

    expect(screen.getByTestId('state')).toHaveTextContent('error')
  })

  it('takes the fallback even when two error events land in ONE batch', () => {
    // Both handlers run before React re-renders, so both observe the same
    // pre-swap state. A ref latch made the second one skip straight to the error
    // state, so an element that reported twice in a single tick never tried the
    // full-size image at all. Guarding on state makes the second call idempotent.
    // fireEvent flushes between calls, so the batch has to be built by hand.
    render(<Probe preferred="/a_thumb.webp" fallback="/a.webp" />)
    const img = screen.getByAltText('probe')

    act(() => {
      img.dispatchEvent(new Event('error'))
      img.dispatchEvent(new Event('error'))
    })

    expect(screen.getByTestId('state')).toHaveTextContent('fallback')
    expect(screen.getByAltText('probe')).toHaveAttribute('src', '/a.webp')
  })

  it('calls onExhausted at most once, and only after both sources are spent', () => {
    const onExhausted = vi.fn()
    render(<Probe preferred="/a_thumb.webp" fallback="/a.webp" onExhausted={onExhausted} />)

    // Thumb 404: the fallback handles it, so the parent is not asked to re-mint.
    fireEvent.error(screen.getByAltText('probe'))
    expect(onExhausted).not.toHaveBeenCalled()

    // Full size 404 too: now the tile is genuinely broken.
    fireEvent.error(screen.getByAltText('probe'))
    expect(screen.getByTestId('state')).toHaveTextContent('error')

    // Further errors must not re-trigger a refetch storm.
    fireEvent.error(screen.getByAltText('probe'))
    fireEvent.error(screen.getByAltText('probe'))
    expect(onExhausted).toHaveBeenCalledTimes(1)
  })

  it('re-arms onExhausted when the URLs change', () => {
    const onExhausted = vi.fn()
    const { rerender } = render(
      <Probe preferred="/a_thumb.webp" fallback="/a.webp" onExhausted={onExhausted} />
    )

    fireEvent.error(screen.getByAltText('probe'))
    fireEvent.error(screen.getByAltText('probe'))
    fireEvent.error(screen.getByAltText('probe'))
    expect(onExhausted).toHaveBeenCalledTimes(1)

    // Freshly minted URLs: a stale failure must not suppress the new pair, and
    // the parent may be told again if these fail too.
    rerender(<Probe preferred="/b_thumb.webp" fallback="/b.webp" onExhausted={onExhausted} />)
    expect(screen.getByTestId('state')).toHaveTextContent('preferred')

    fireEvent.error(screen.getByAltText('probe'))
    fireEvent.error(screen.getByAltText('probe'))
    fireEvent.error(screen.getByAltText('probe'))
    expect(onExhausted).toHaveBeenCalledTimes(2)
  })

  it('ignores a duplicate failure signal for the same URL (effect poll + queued onError)', () => {
    // ItemImage reports ONE thumb failure twice: its settle effect
    // (`complete && naturalWidth === 0`) and the element's <img> onError. If
    // the effect lands first and swaps in the fallback, the queued onError —
    // still carrying the thumb URL before the swap commits — must not discard
    // the healthy fallback. Both signals here carry the same failing URL.
    const { result } = renderHook(() =>
      useImageWithFallback('/a_thumb.webp', '/a.webp')
    )

    // The effect's signal: swaps to the fallback.
    act(() => result.current.onError('/a_thumb.webp'))
    expect(result.current.src).toBe('/a.webp')
    expect(result.current.usingFallback).toBe(true)
    expect(result.current.hasError).toBe(false)

    // The queued onError for the same URL: a duplicate, not a new failure.
    act(() => result.current.onError('/a_thumb.webp'))
    expect(result.current.usingFallback).toBe(true)
    expect(result.current.hasError).toBe(false)
    expect(result.current.src).toBe('/a.webp')
  })

  it('still reports a real failure of the fallback after deduping the duplicate', () => {
    const { result } = renderHook(() =>
      useImageWithFallback('/a_thumb.webp', '/a.webp')
    )

    act(() => result.current.onError('/a_thumb.webp'))
    act(() => result.current.onError('/a_thumb.webp'))
    expect(result.current.hasError).toBe(false)

    // The full-size image genuinely 404s next: a DIFFERENT URL, so it must
    // not be swallowed by the dedupe.
    act(() => result.current.onError('/a.webp'))
    expect(result.current.hasError).toBe(true)
  })

  it('re-arms the URL dedupe when the sources change', () => {
    const { result, rerender } = renderHook(
      ({ preferred, fallback }) => useImageWithFallback(preferred, fallback),
      { initialProps: { preferred: '/a_thumb.webp', fallback: '/a.webp' } }
    )

    act(() => result.current.onError('/a_thumb.webp'))
    act(() => result.current.onError('/a_thumb.webp'))
    expect(result.current.hasError).toBe(false)

    // Freshly minted URLs: a stale dedupe key must not suppress the new pair.
    rerender({ preferred: '/b_thumb.webp', fallback: '/b.webp' })
    expect(result.current.src).toBe('/b_thumb.webp')
    expect(result.current.usingFallback).toBe(false)

    act(() => result.current.onError('/b_thumb.webp'))
    expect(result.current.usingFallback).toBe(true)
    expect(result.current.hasError).toBe(false)

    act(() => result.current.onError('/b.webp'))
    expect(result.current.hasError).toBe(true)
  })
})

describe('thumbnailErrorFallback', () => {
  it('swaps src once and never loops', () => {
    const el = document.createElement('img')
    el.src = 'http://localhost/a_thumb.webp'
    const handler = thumbnailErrorFallback('http://localhost/a.webp')

    handler({ currentTarget: el } as never)
    expect(el.src).toBe('http://localhost/a.webp')
    expect(el.dataset.fallbackFor).toBe('http://localhost/a.webp')

    // A fallback that also 404s must not re-enter and re-assign forever.
    handler({ currentTarget: el } as never)
    expect(el.src).toBe('http://localhost/a.webp')
    expect(el.dataset.fallbackFor).toBe('http://localhost/a.webp')
  })

  it('re-arms the swap when a NEW fallback URL arrives on the same node', () => {
    const el = document.createElement('img')
    el.src = 'http://localhost/a_thumb.webp'
    thumbnailErrorFallback('http://localhost/a.webp')({ currentTarget: el } as never)
    expect(el.src).toBe('http://localhost/a.webp')
    expect(el.dataset.fallbackFor).toBe('http://localhost/a.webp')

    // A re-minted (still missing) thumb with a NEW fallback URL must swap
    // again — a boolean marker would skip this and leave the tile permanently
    // broken.
    el.src = 'http://localhost/b_thumb.webp'
    thumbnailErrorFallback('http://localhost/b.webp')({ currentTarget: el } as never)
    expect(el.src).toBe('http://localhost/b.webp')
    expect(el.dataset.fallbackFor).toBe('http://localhost/b.webp')
  })

  it('never re-swaps for the same fallback URL (URL-keyed loop guard)', () => {
    const el = document.createElement('img')
    el.src = 'http://localhost/a_thumb.webp'
    const handler = thumbnailErrorFallback('http://localhost/a.webp')

    handler({ currentTarget: el } as never)
    expect(el.src).toBe('http://localhost/a.webp')

    // The fallback 404s too and the src gets re-assigned to something else:
    // the marker is keyed by URL, so the same fallback must still not loop.
    el.src = 'http://localhost/other.webp'
    handler({ currentTarget: el } as never)
    expect(el.src).toBe('http://localhost/other.webp')
    expect(el.dataset.fallbackFor).toBe('http://localhost/a.webp')
  })

  it('is a no-op without a fallback URL', () => {
    const el = document.createElement('img')
    el.src = 'http://localhost/a_thumb.webp'

    thumbnailErrorFallback(undefined)({ currentTarget: el } as never)

    expect(el.src).toBe('http://localhost/a_thumb.webp')
    expect(el.dataset.fallbackFor).toBeUndefined()
  })
})

describe('ItemImage thumbnail fallback', () => {
  it('falls back to the full-size image instead of the broken-image state', () => {
    const item = {
      id: 'item-1',
      name: 'Linen shirt',
      images: [{ image_url: '/linen.webp', thumbnail_url: '/linen_thumb.webp', is_primary: true }],
    } as unknown as Item

    render(<ItemImage item={item} size="sm" />)
    const img = screen.getByAltText('Linen shirt')
    expect(img).toHaveAttribute('src', '/linen_thumb.webp')

    fireEvent.error(img)

    // Still the photograph, not the AlertTriangle placeholder.
    expect(screen.getByAltText('Linen shirt')).toHaveAttribute('src', '/linen.webp')
    expect(
      screen.queryByLabelText('Image for Linen shirt could not be loaded')
    ).toBeNull()
  })

  it('shows the error state once the full size fails too', () => {
    const item = {
      id: 'item-1',
      name: 'Linen shirt',
      images: [{ image_url: '/linen.webp', thumbnail_url: '/linen_thumb.webp', is_primary: true }],
    } as unknown as Item

    render(<ItemImage item={item} size="sm" />)

    fireEvent.error(screen.getByAltText('Linen shirt'))
    fireEvent.error(screen.getByAltText('Linen shirt'))

    expect(
      screen.getByLabelText('Image for Linen shirt could not be loaded')
    ).toBeInTheDocument()
  })

  it('still prefers the thumbnail for small tiles', () => {
    // The egress win depends on the small grid tiles asking for the thumb.
    const spy = vi.fn()
    const item = {
      id: 'item-2',
      name: 'Wool coat',
      images: [{ image_url: '/coat.webp', thumbnail_url: '/coat_thumb.webp', is_primary: true }],
    } as unknown as Item

    render(<ItemImage item={item} size="sm" />)
    spy(screen.getByAltText('Wool coat').getAttribute('src'))

    expect(spy).toHaveBeenCalledWith('/coat_thumb.webp')
  })

  it('ignores a stale error event for the swapped-from URL while the fallback is in flight', () => {
    // The settle effect can report the thumb failure BEFORE the browser's
    // queued <img> error event dispatches. When the swap commits first, the
    // event arrives with the element showing the FALLBACK while its fetch is
    // still in flight (complete === false) — the effect's `data-failure-polled`
    // marker proves this is the stale thumb event, not a fallback failure.
    const item = {
      id: 'item-3',
      name: 'Linen shirt',
      images: [{ image_url: '/linen.webp', thumbnail_url: '/linen_thumb.webp', is_primary: true }],
    } as unknown as Item

    render(<ItemImage item={item} size="sm" />)
    const img = screen.getByAltText('Linen shirt') as HTMLImageElement

    // Thumb 404: swap to the healthy full size.
    fireEvent.error(img)
    expect(img.getAttribute('src')).toBe('/linen.webp')

    // Simulate the effect having polled the thumb first (it marks the element),
    // then the stale error event arriving while the fallback is still loading.
    img.dataset.failurePolled = '/linen_thumb.webp'
    Object.defineProperty(img, 'complete', { configurable: true, value: false })
    fireEvent.error(img)

    expect(screen.getByAltText('Linen shirt').getAttribute('src')).toBe('/linen.webp')
    expect(screen.queryByLabelText('Image for Linen shirt could not be loaded')).toBeNull()

    // Once the fallback's fetch actually settles and fails (complete === true),
    // the same event shape is a genuine failure and must still be reported.
    Object.defineProperty(img, 'complete', { configurable: true, value: true })
    fireEvent.error(screen.getByAltText('Linen shirt'))

    expect(
      screen.getByLabelText('Image for Linen shirt could not be loaded')
    ).toBeInTheDocument()
  })
})
