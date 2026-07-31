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
})
