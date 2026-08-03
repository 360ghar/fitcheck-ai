import { beforeEach, describe, expect, it, vi } from 'vitest'

const mocks = vi.hoisted(() => ({
  getPhotoshootUsage: vi.fn(),
  generatePhotoshoot: vi.fn(),
}))

vi.mock('@/api/photoshoot', () => ({
  getPhotoshootUsage: mocks.getPhotoshootUsage,
  generatePhotoshoot: mocks.generatePhotoshoot,
}))

import { selectCanGenerate, usePhotoshootStore } from '../photoshootStore'

describe('photoshoot usage safety', () => {
  beforeEach(() => {
    mocks.getPhotoshootUsage.mockReset()
    mocks.generatePhotoshoot.mockReset()
    // reset() refreshes usage in the background. Keep that refresh pending so
    // it cannot race the state under test and reintroduce an entitlement.
    mocks.getPhotoshootUsage.mockImplementation(() => new Promise(() => undefined))
    usePhotoshootStore.getState().reset()
    usePhotoshootStore.setState({ usage: null, error: null })
  })

  it('does not invent a free entitlement when usage cannot be loaded', async () => {
    mocks.getPhotoshootUsage.mockRejectedValue(new Error('usage unavailable'))

    await usePhotoshootStore.getState().fetchUsage()

    expect(usePhotoshootStore.getState().usage).toBeNull()
    expect(usePhotoshootStore.getState().error).toContain('could not confirm')
  })

  it('blocks generation until the server confirms usage', async () => {
    usePhotoshootStore.getState().addPhotos([new File(['image'], 'look.png', { type: 'image/png' })])

    const result = await usePhotoshootStore.getState().generate()

    expect(result).toBeNull()
    expect(usePhotoshootStore.getState().error).toContain('could not confirm')
    expect(mocks.generatePhotoshoot).not.toHaveBeenCalled()
  })

  it('does not enable the generate action without confirmed usage', () => {
    usePhotoshootStore.getState().addPhotos([new File(['image'], 'look.png', { type: 'image/png' })])
    expect(selectCanGenerate(usePhotoshootStore.getState())).toBe(false)
  })

  it('does not start a second generation while one is already in flight', async () => {
    usePhotoshootStore.setState({
      photos: [new File(['image'], 'look.png', { type: 'image/png' })],
      usage: { used_today: 0, limit_today: 10, remaining: 10, plan_type: 'free' },
      isGenerating: true,
    })

    const result = await usePhotoshootStore.getState().generate()

    expect(result).toBeNull()
    expect(mocks.generatePhotoshoot).not.toHaveBeenCalled()
  })

  it('disables generate while a generation is in flight', () => {
    usePhotoshootStore.setState({
      photos: [new File(['image'], 'look.png', { type: 'image/png' })],
      usage: { used_today: 0, limit_today: 10, remaining: 10, plan_type: 'free' },
      isGenerating: true,
    })
    expect(selectCanGenerate(usePhotoshootStore.getState())).toBe(false)
  })

  it('refreshes usage after a quota-exhausted 429 so the wall renders and retries stop', async () => {
    mocks.getPhotoshootUsage.mockResolvedValue({
      used_today: 10,
      limit_today: 10,
      remaining: 0,
      plan_type: 'free',
    })
    mocks.generatePhotoshoot.mockRejectedValue({
      isAxiosError: true,
      message: 'Request failed with status code 429',
      response: {
        status: 429,
        data: { error: 'Daily limit exceeded', code: 'RATE_LIMIT_EXCEEDED' },
      },
    })

    usePhotoshootStore.setState({
      photos: [new File(['image'], 'look.png', { type: 'image/png' })],
      useCase: 'linkedin',
      numImages: 1,
      // Stale pre-429 entitlement: 5 remaining. After the 429 the store must
      // re-fetch usage (0 remaining) rather than trust this.
      usage: { used_today: 5, limit_today: 10, remaining: 5, plan_type: 'free' },
    })

    const result = await usePhotoshootStore.getState().generate()

    expect(result).toBeNull()
    expect(usePhotoshootStore.getState().error).toContain('daily photoshoot limit')
    // The refresh is fire-and-forget; flush the microtask queue.
    await Promise.resolve()
    expect(mocks.getPhotoshootUsage).toHaveBeenCalled()
    expect(usePhotoshootStore.getState().usage?.remaining).toBe(0)
    expect(selectCanGenerate(usePhotoshootStore.getState())).toBe(false)
  })
})
