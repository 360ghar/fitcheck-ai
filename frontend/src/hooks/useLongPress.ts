/**
 * useLongPress — press-and-hold gesture that starts the wardrobe bulk
 * selection (hold a tile ~450ms), while a plain tap still opens the item.
 *
 * Pointer-events based, so one code path covers touch and mouse-hold. The
 * canonical mobile pitfall is handled explicitly: holding fires a
 * `contextmenu` on most mobile browsers, which would pop a menu / text
 * selection UI over the tile — the hook suppresses it for the whole press.
 *
 * The returned `onClick` is the element's ONLY click handler: it eats the
 * release-click that follows a fired long-press (or the tap would act on the
 * tile right after entering selection mode) and forwards genuine taps to
 * `options.onClick`. Movement >10px cancels: a scroll started on a tile must
 * scroll, not select.
 */

import { useCallback, useEffect, useRef } from 'react'

export interface UseLongPressOptions {
  /** Hold duration before the callback fires (ms). */
  delay?: number
  /** Called once the press has been held for `delay`. */
  onLongPress: () => void
  /** The element's real tap handler; skipped on the post-long-press release click. */
  onClick?: (event: React.MouseEvent) => void
}

export function useLongPress({ delay = 450, onLongPress, onClick }: UseLongPressOptions) {
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null)
  const originRef = useRef<{ x: number; y: number } | null>(null)
  const firedRef = useRef(false)
  // Kept in a ref so handlers.onClick can read it synchronously.
  const suppressClickRef = useRef(false)

  const clearTimer = useCallback(() => {
    if (timerRef.current !== null) {
      clearTimeout(timerRef.current)
      timerRef.current = null
    }
    originRef.current = null
  }, [])

  useEffect(() => clearTimer, [clearTimer])

  const onPointerDown = useCallback(
    (event: React.PointerEvent) => {
      // Multi-button mice (right-click) are not long-press gestures.
      if (event.button !== 0) return
      firedRef.current = false
      suppressClickRef.current = false
      originRef.current = { x: event.clientX, y: event.clientY }
      timerRef.current = setTimeout(() => {
        timerRef.current = null
        firedRef.current = true
        suppressClickRef.current = true
        onLongPress()
      }, delay)
    },
    [delay, onLongPress]
  )

  const onPointerMove = useCallback(
    (event: React.PointerEvent) => {
      const origin = originRef.current
      if (!origin) return
      const moved =
        Math.abs(event.clientX - origin.x) > 10 || Math.abs(event.clientY - origin.y) > 10
      if (moved) {
        clearTimer()
        // A scroll takes over; the coming click (if any) is the user's tap on
        // a different scroll position, so do not suppress it.
      }
    },
    [clearTimer]
  )

  const onPointerUp = useCallback(() => {
    clearTimer()
  }, [clearTimer])

  const onContextMenu = useCallback((event: React.MouseEvent) => {
    // Long-press on touch fires contextmenu; swallow it while our press is
    // live (or just fired) so no native menu appears over the tile.
    if (timerRef.current !== null || firedRef.current) {
      event.preventDefault()
    }
  }, [])

  const onClickHandler = useCallback(
    (event: React.MouseEvent) => {
      if (suppressClickRef.current) {
        suppressClickRef.current = false
        event.preventDefault()
        event.stopPropagation()
        return
      }
      onClick?.(event)
    },
    [onClick]
  )

  return {
    handlers: {
      onPointerDown,
      onPointerMove,
      onPointerUp,
      onPointerCancel: onPointerUp,
      onContextMenu,
      onClick: onClickHandler,
    },
  }
}
