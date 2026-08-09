import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { renderHook, act } from '@testing-library/react'

const mocks = vi.hoisted(() => ({
  subscribeToBatchJobEvents: vi.fn(),
}))

vi.mock('@/api/batch', () => ({
  subscribeToBatchJobEvents: mocks.subscribeToBatchJobEvents,
}))

import { useBatchSSE } from '../useBatchSSE'

interface ConnectionHandlers {
  onMessage: (event: { type: string; data: unknown; id?: number }) => void
  onError: (error: Error) => void
  onClose: (sawTerminal: boolean) => void
}

/**
 * Captures the SSE handlers for each (jobId, lastEventId) subscription so a
 * test can push events, errors, and silent closes exactly like the transport.
 */
function captureConnections(): Map<string, ConnectionHandlers> {
  const connections = new Map<string, ConnectionHandlers>()
  mocks.subscribeToBatchJobEvents.mockImplementation(
    (
      jobId: string,
      onMessage: ConnectionHandlers['onMessage'],
      onError: ConnectionHandlers['onError'],
      onClose: ConnectionHandlers['onClose']
    ) => {
      connections.set(jobId, { onMessage, onError, onClose })
      return () => {
        connections.delete(jobId)
      }
    }
  )
  return connections
}

describe('useBatchSSE reconnect budget', () => {
  beforeEach(() => {
    vi.useFakeTimers()
    mocks.subscribeToBatchJobEvents.mockReset()
  })

  afterEach(() => {
    vi.useRealTimers()
    vi.restoreAllMocks()
  })

  it('does not let heartbeats reset the reconnect budget (F1-11)', () => {
    // Regression: a heartbeat-only stream (job still running, connection
    // flapping) used to reset the budget on every event and reconnect
    // forever — onStreamEnded never ran and the caller never reconciled via
    // /status.
    const connections = captureConnections()
    const onStreamEnded = vi.fn()
    const onEvent = vi.fn()
    const onReconnect = vi.fn()

    renderHook(() =>
      useBatchSSE({ jobId: 'job-1', onEvent, onReconnect, onStreamEnded })
    )

    for (let i = 0; i < 4; i++) {
      const conn = connections.get('job-1')
      expect(conn).toBeTruthy()
      // Heartbeat every 30s is the only traffic.
      act(() => {
        conn!.onMessage({ type: 'heartbeat', data: {}, id: i + 1 })
      })
      act(() => {
        conn!.onClose(false) // silent stream death
      })
      // Reconnect after the backoff delay.
      act(() => {
        vi.advanceTimersByTime(1000 * (i + 1))
      })
    }

    expect(onReconnect).toHaveBeenCalledTimes(3)
    // Budget exhausted without a terminal event → hand off to the caller.
    expect(onStreamEnded).toHaveBeenCalledTimes(1)
    // Heartbeats are forwarded to the caller (which ignores them) — the
    // point is they never reset the reconnect budget.
    expect(onEvent).toHaveBeenCalledTimes(4)
  })

  it('resets the budget on a real event, not heartbeats (F1-11)', () => {
    const connections = captureConnections()
    const onStreamEnded = vi.fn()
    const onEvent = vi.fn()

    renderHook(() => useBatchSSE({ jobId: 'job-1', onEvent, onStreamEnded }))

    const conn = connections.get('job-1')!
    // Heartbeat + silent drop.
    act(() => {
      conn.onMessage({ type: 'heartbeat', data: {}, id: 1 })
      conn.onClose(false)
    })
    act(() => vi.advanceTimersByTime(1000))
    // A real event lands on the new connection → budget resets.
    const conn2 = connections.get('job-1')!
    act(() => {
      conn2.onMessage({ type: 'extraction_started', data: {}, id: 2 })
    })
    // Four more silent drops exhaust the budget (a heartbeat reset would
    // keep it alive past this point): three reconnect, the fourth hands off.
    for (let i = 0; i < 4; i++) {
      const c = connections.get('job-1')!
      act(() => {
        c.onClose(false)
      })
      act(() => vi.advanceTimersByTime(1000 * (i + 1)))
    }
    expect(onEvent).toHaveBeenCalledTimes(2) // heartbeat + extraction_started
    expect(onStreamEnded).toHaveBeenCalledTimes(1)
  })

  it('enforces a wall-clock cap on reconnects (F1-11)', () => {
    const connections = captureConnections()
    const onStreamEnded = vi.fn()

    // Control Date.now directly: advancing fake timers far enough to lapse
    // the 90s window would also trip the 45s idle watchdog (which owns the
    // drop path), so the cap is exercised by moving the clock instead.
    let now = 1000
    vi.spyOn(Date, 'now').mockImplementation(() => now)

    renderHook(() => useBatchSSE({ jobId: 'job-1', onEvent: vi.fn(), onStreamEnded }))

    // One flap inside the window reconnects normally.
    const conn = connections.get('job-1')!
    act(() => {
      conn.onClose(false)
    })
    act(() => {
      now = 2000
      vi.advanceTimersByTime(1000)
    })
    expect(onStreamEnded).not.toHaveBeenCalled()

    // The new connection lives past the 90s wall-clock window; its next drop
    // must hand off to the caller instead of reconnecting forever.
    const conn2 = connections.get('job-1')!
    act(() => {
      now = 200_000
      conn2.onClose(false)
    })
    expect(onStreamEnded).toHaveBeenCalledTimes(1)
  })
})
