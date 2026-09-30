import { describe, expect, it } from 'vitest'

describe('Node-compatible abort globals', () => {
  it('supports signals from constructors and static factories in Request', () => {
    const controller = new AbortController()
    const signals = [controller.signal, AbortSignal.abort(), AbortSignal.timeout(0)]
    for (const signal of signals) {
      expect(signal).toBeInstanceOf(AbortSignal)
      expect(() => new Request('https://example.test', { signal })).not.toThrow()
    }
    controller.abort()
    expect(controller.signal.aborted).toBe(true)
  })
})
