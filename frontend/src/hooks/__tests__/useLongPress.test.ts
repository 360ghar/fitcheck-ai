import { act, renderHook } from '@testing-library/react'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import { useLongPress } from '../useLongPress'

function pointerEvent(type: string, opts: Partial<{ clientX: number; clientY: number; button: number }> = {}) {
  return {
    type,
    button: opts.button ?? 0,
    clientX: opts.clientX ?? 10,
    clientY: opts.clientY ?? 10,
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
      onPointerUp()
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
      onPointerUp()
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
      onPointerUp()
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

  it('suppresses exactly one click after a fired long-press, then forwards taps', () => {
    const onLongPress = vi.fn()
    const onClick = vi.fn()
    const { result } = renderHook(() => useLongPress({ onLongPress, onClick }))
    const { onPointerDown, onPointerUp, onClick: click } = result.current.handlers

    act(() => {
      onPointerDown(pointerEvent('pointerdown'))
      vi.advanceTimersByTime(450)
      onPointerUp()
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
      onPointerUp()
      click(clickEvent())
    })
    expect(onLongPress).not.toHaveBeenCalled()
    expect(onClick).toHaveBeenCalledTimes(1)
  })
})
