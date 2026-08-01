/**
 * Locks in the failure handling of the fire-and-forget auto-generation started
 * by `createOutfit`.
 *
 * The chain is kicked off without `await`, so a rejection anywhere in it must
 * (a) never escape as an unhandled rejection and (b) leave the outfit in a
 * `failed` entry in `generatingOutfits` — the state OutfitCard renders as a
 * retry affordance. A rejection that leaves the entry on `pending`/`processing`
 * is a permanent spinner.
 */
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'

vi.mock('@/api/outfits', () => ({
  createOutfit: vi.fn(),
  getOutfit: vi.fn(),
  getAvailableItems: vi.fn(),
  uploadOutfitImage: vi.fn(),
  generateOutfitVisualization: vi.fn(),
  getOutfits: vi.fn(),
}))

vi.mock('@/api/ai', () => ({
  generateOutfit: vi.fn(),
}))

import * as outfitsApi from '@/api/outfits'
import { generateOutfit } from '@/api/ai'
import { useOutfitStore } from '@/stores/outfitStore'
import type { Outfit } from '@/types'

const OUTFIT_ID = 'outfit-1'

function seedOutfit() {
  const outfit = {
    id: OUTFIT_ID,
    name: 'Test look',
    item_ids: ['item-1'],
    images: [],
  } as unknown as Outfit

  useOutfitStore.setState({
    outfits: [outfit],
    generatingOutfits: new Map([[OUTFIT_ID, { status: 'pending' as const }]]),
  })
}

describe('outfitStore.startGenerationForNewOutfit', () => {
  const unhandled: unknown[] = []
  const onUnhandled = (e: PromiseRejectionEvent) => {
    unhandled.push(e.reason)
    e.preventDefault()
  }

  beforeEach(() => {
    unhandled.length = 0
    window.addEventListener('unhandledrejection', onUnhandled)
    vi.spyOn(console, 'error').mockImplementation(() => {})
    seedOutfit()
  })

  afterEach(() => {
    window.removeEventListener('unhandledrejection', onUnhandled)
    vi.restoreAllMocks()
    vi.clearAllMocks()
  })

  it('moves the entry to `failed` when a step of the chain rejects', async () => {
    vi.mocked(outfitsApi.getAvailableItems).mockRejectedValue(new Error('boom'))

    useOutfitStore.getState().startGenerationForNewOutfit(OUTFIT_ID)

    await vi.waitFor(() => {
      const entry = useOutfitStore.getState().generatingOutfits.get(OUTFIT_ID)
      expect(entry?.status).toBe('failed')
    })

    expect(
      useOutfitStore.getState().generatingOutfits.get(OUTFIT_ID)?.error
    ).toBe('boom')
    expect(unhandled).toEqual([])
  })

  it('does not leave the entry stuck on `processing`', async () => {
    // Items resolve but none match the outfit -> the store throws its own error.
    vi.mocked(outfitsApi.getAvailableItems).mockResolvedValue([])

    useOutfitStore.getState().startGenerationForNewOutfit(OUTFIT_ID)

    await vi.waitFor(() => {
      const entry = useOutfitStore.getState().generatingOutfits.get(OUTFIT_ID)
      expect(entry?.status).toBe('failed')
    })
    expect(unhandled).toEqual([])
  })

  it('sends item_id so the backend can attach garment reference images', async () => {
    vi.mocked(outfitsApi.getAvailableItems).mockResolvedValue([
      { id: 'item-1', name: 'Cream sweater', category: 'tops', colors: ['cream'], image_url: 'https://x.test/a.jpg' },
    ])
    // Real return shape. The chain fails further down (uploadOutfitImage below),
    // which is fine: this test only asserts the payload the backend receives.
    vi.mocked(generateOutfit).mockResolvedValue({
      image_base64: 'aGk=',
      prompt: 'p',
      model: 'm',
      provider: 'fake',
    } as never)
    vi.mocked(outfitsApi.uploadOutfitImage).mockRejectedValue(new Error('stop'))

    useOutfitStore.getState().startGenerationForNewOutfit(OUTFIT_ID)

    await vi.waitFor(() => {
      expect(generateOutfit).toHaveBeenCalled()
    })
    expect(vi.mocked(generateOutfit).mock.calls[0][0]).toEqual([
      { item_id: 'item-1', name: 'Cream sweater', category: 'tops', colors: ['cream'] },
    ])
    // And the chain still lands on `failed` rather than a permanent spinner.
    await vi.waitFor(() => {
      expect(
        useOutfitStore.getState().generatingOutfits.get(OUTFIT_ID)?.status
      ).toBe('failed')
    })
    expect(unhandled).toEqual([])
  })

  it('defaults to NOT sending the source photo (builder/retry paths unchanged)', async () => {
    vi.mocked(outfitsApi.getAvailableItems).mockResolvedValue([
      { id: 'item-1', name: 'Cream sweater', category: 'tops', colors: ['cream'], image_url: 'https://x.test/a.jpg' },
    ])
    vi.mocked(generateOutfit).mockResolvedValue({
      image_base64: 'aGk=',
      prompt: 'p',
      model: 'm',
      provider: 'fake',
    } as never)
    vi.mocked(outfitsApi.uploadOutfitImage).mockRejectedValue(new Error('stop'))

    useOutfitStore.getState().startGenerationForNewOutfit(OUTFIT_ID)

    await vi.waitFor(() => {
      expect(generateOutfit).toHaveBeenCalled()
    })
    expect(vi.mocked(generateOutfit).mock.calls[0][1]).toMatchObject({
      useSourcePhoto: false,
    })
  })

  it('sends use_source_photo when the upload flow opts in', async () => {
    vi.mocked(outfitsApi.getAvailableItems).mockResolvedValue([
      { id: 'item-1', name: 'Cream sweater', category: 'tops', colors: ['cream'], image_url: 'https://x.test/a.jpg' },
    ])
    vi.mocked(generateOutfit).mockResolvedValue({
      image_base64: 'aGk=',
      prompt: 'p',
      model: 'm',
      provider: 'fake',
    } as never)
    vi.mocked(outfitsApi.uploadOutfitImage).mockRejectedValue(new Error('stop'))

    useOutfitStore.getState().startGenerationForNewOutfit(OUTFIT_ID, {
      useSourcePhoto: true,
    })

    await vi.waitFor(() => {
      expect(generateOutfit).toHaveBeenCalled()
    })
    expect(vi.mocked(generateOutfit).mock.calls[0][1]).toMatchObject({
      useSourcePhoto: true,
    })
  })
})
