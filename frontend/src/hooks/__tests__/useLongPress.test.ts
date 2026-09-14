import { act, renderHook } from '@testing-library/react'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import { useLongPress } from '../useLongPress'

const PRIMARY_POINTER_ID = 1

function pointerEvent(
  type: string,
  opts: Partial<{
    clientX: number
    clientY: number
    button: number
    pointerId: number
    isPrimary: boolean
  }> = {}
) {
  return {
    type,
    button: opts.button ?? 0,
    clientX: opts.clientX ?? 10,
    clientY: opts.clientY ?? 10,
    pointerId: opts.pointerId ?? PRIMARY_POINTER_ID,
    // Real browsers always set isPrimary (touch/mouse); the tests must too,
    // because the gesture follows exactly one primary pointer.
    isPrimary: opts.isPrimary ?? true,
    preventDefault: vi.fn(),
    stopPropagation: vi.fn(),
  } as unknown as React.PointerEvent
}

function clickEvent() {
  return { preventDefault: vi.fn(), stopPropagation: vi.fn() } as unknown as React.MouseEvent
}

describe('useLongPress', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  it('fires after the hold delay and suppresses the follow-up click', () => {
    const onLongPress = vi.fn()
    const onClick = vi.fn()
    const { result } = renderHook(() => useLongPress({ onLongPress, onClick }))
    const { onPointerDown, onPointerUp, onClick: click } = result.current.handlers

    act(() => {
      onPointerDown(pointerEvent('pointerdown'))
    })
    expect(onLongPress).not.toHaveBeenCalled()

    act(() => {
      vi.advanceTimersByTime(450)
    })
    expect(onLongPress).toHaveBeenCalledTimes(1)

    // Releasing after a fired long-press dispatches click — it must be eaten.
    const event = clickEvent()
    act(() => {
      onPointerUp(pointerEvent('pointerup'))
      click(event)
    })
    expect(onClick).not.toHaveBeenCalled()
    expect(event.preventDefault).toHaveBeenCalledTimes(1)
    expect(event.stopPropagation).toHaveBeenCalledTimes(1)
  })

  it('does not fire when released before the delay', () => {
    const onLongPress = vi.fn()
    const { result } = renderHook(() => useLongPress({ onLongPress }))
    const { onPointerDown, onPointerUp } = result.current.handlers

    act(() => {
      onPointerDown(pointerEvent('pointerdown'))
      vi.advanceTimersByTime(200)
      onPointerUp(pointerEvent('pointerup'))
      vi.advanceTimersByTime(1000)
    })
    expect(onLongPress).not.toHaveBeenCalled()
  })

  it('cancels when the pointer moves beyond the slop (scroll takes over)', () => {
    const onLongPress = vi.fn()
    const { result } = renderHook(() => useLongPress({ onLongPress }))
    const { onPointerDown, onPointerMove, onPointerUp } = result.current.handlers

    act(() => {
      onPointerDown(pointerEvent('pointerdown'))
      onPointerMove(pointerEvent('pointermove', { clientX: 40, clientY: 10 }))
      vi.advanceTimersByTime(1000)
      onPointerUp(pointerEvent('pointerup'))
    })
    expect(onLongPress).not.toHaveBeenCalled()
  })

  it('ignores non-primary buttons', () => {
    const onLongPress = vi.fn()
    const { result } = renderHook(() => useLongPress({ onLongPress }))
    const { onPointerDown } = result.current.handlers

    act(() => {
      onPointerDown(pointerEvent('pointerdown', { button: 2 }))
      vi.advanceTimersByTime(1000)
    })
    expect(onLongPress).not.toHaveBeenCalled()
  })

  it('cancels when the pointer leaves the element before firing', () => {
    const onLongPress = vi.fn()
    const { result } = renderHook(() => useLongPress({ onLongPress }))
    const { onPointerDown, onPointerLeave } = result.current.handlers

    act(() => {
      onPointerDown(pointerEvent('pointerdown'))
      // Mouse has no implicit capture: once the cursor drifts off the tile,
      // no further move/up arrives, so leaving must kill the pending timer.
      onPointerLeave(pointerEvent('pointerleave'))
      vi.advanceTimersByTime(1000)
    })
    expect(onLongPress).not.toHaveBeenCalled()
  })

  it('a second pointer can neither schedule a second callback nor cancel the first press', () => {
    const onLongPress = vi.fn()
    const { result } = renderHook(() => useLongPress({ onLongPress }))
    const { onPointerDown, onPointerUp } = result.current.handlers

    act(() => {
      // First finger lands (primary, id 1)…
      onPointerDown(pointerEvent('pointerdown', { pointerId: 1, isPrimary: true }))
      // …a second pointer lands on the same tile before the delay.
      onPointerDown(pointerEvent('pointerdown', { pointerId: 2, isPrimary: false }))
      // …and the second pointer lifts, which must not cancel finger one.
      onPointerUp(pointerEvent('pointerup', { pointerId: 2, isPrimary: false }))
      vi.advanceTimersByTime(450)
    })
    // Two timers would toggle the item twice and leave it unselected.
    expect(onLongPress).toHaveBeenCalledTimes(1)
  })

  it('a right-click after a fired long-press does not suppress the native context menu', () => {
    const onLongPress = vi.fn()
    const { result } = renderHook(() => useLongPress({ onLongPress }))
    const { onPointerDown, onPointerUp, onContextMenu } = result.current.handlers

    // Long-press fires; the post-release click is eaten elsewhere (onClick),
    // leaving firedRef set.
    act(() => {
      onPointerDown(pointerEvent('pointerdown'))
      vi.advanceTimersByTime(450)
      onPointerUp(pointerEvent('pointerup'))
    })

    // The right-click's pointerdown must reset the stale flags…
    act(() => {
      onPointerDown(pointerEvent('pointerdown', { button: 2 }))
    })
    // …so this contextmenu is a legitimate native menu, not our press.
    const menuEvent = clickEvent()
    act(() => {
      onContextMenu(menuEvent)
    })
    expect(menuEvent.preventDefault).not.toHaveBeenCalled()
  })

  it('suppresses exactly one click after a fired long-press, then forwards taps', () => {
    const onLongPress = vi.fn()
    const onClick = vi.fn()
    const { result } = renderHook(() => useLongPress({ onLongPress, onClick }))
    const { onPointerDown, onPointerUp, onClick: click } = result.current.handlers

    act(() => {
      onPointerDown(pointerEvent('pointerdown'))
      vi.advanceTimersByTime(450)
      onPointerUp(pointerEvent('pointerup'))
    })
    const releaseClick = clickEvent()
    act(() => {
      click(releaseClick)
    })
    expect(onClick).not.toHaveBeenCalled()
    expect(releaseClick.stopPropagation).toHaveBeenCalledTimes(1)

    // A second click (the next tap) must pass through to the consumer.
    act(() => {
      click(clickEvent())
    })
    expect(onClick).toHaveBeenCalledTimes(1)
  })

  it('forwards taps to the consumer onClick when no long-press fired', () => {
    const onLongPress = vi.fn()
    const onClick = vi.fn()
    const { result } = renderHook(() => useLongPress({ onLongPress, onClick }))
    const { onPointerDown, onPointerUp, onClick: click } = result.current.handlers

    act(() => {
      onPointerDown(pointerEvent('pointerdown'))
      vi.advanceTimersByTime(100)
      onPointerUp(pointerEvent('pointerup'))
      click(clickEvent())
    })
    expect(onLongPress).not.toHaveBeenCalled()
    expect(onClick).toHaveBeenCalledTimes(1)
  })
})
