/**
 * Locks in the stale-preview guard on `saveOutfitFromDraft`.
 *
 * A preview generated from an EARLIER draft (different item set or style)
 * must never be attached to the outfit as its look: the outfit grid would
 * show a photo of clothes that are not the outfit's item_ids. The store
 * already fingerprints the preview (`previewSourceKey`) for the UI; the save
 * path must treat a mismatched key as "no approved preview".
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
import { useOutfitStore } from '@/stores/outfitStore'
import type { Outfit } from '@/types'

// A realistic 36-char backend UUID exercises the worst case for the
// idempotency key length (the store comment assumes a UUID-sized id). The
// old 8-char 'outfit-1' fixture always produced a short key and the <=64
// assertion passed regardless of the real bound.
const OUTFIT_ID = '550e8400-e29b-41d4-a716-446655440000'

function seedCreationState(overrides: Partial<Parameters<typeof useOutfitStore.setState>[0]> = {}) {
  useOutfitStore.setState({
    creationItems: new Set(['item-1', 'item-2']),
    creationName: 'Weekend look',
    creationStyle: 'casual' as const,
    previewStatus: 'ready' as const,
    previewImageDataUrl: 'data:image/png;base64,aGk=',
    previewSourceKey: 'item-1,item-2|casual',
    isLoading: false,
    error: null,
    ...overrides,
  })
}

beforeEach(() => {
  vi.mocked(outfitsApi.createOutfit).mockResolvedValue({
    id: OUTFIT_ID,
    name: 'Weekend look',
    item_ids: ['item-1', 'item-2'],
    images: [],
  } as unknown as Outfit)
})

afterEach(() => {
  vi.restoreAllMocks()
  vi.clearAllMocks()
})

describe('outfitStore.saveOutfitFromDraft stale preview', () => {
  it('does not upload a preview whose source key no longer matches the draft', async () => {
    seedCreationState({
      // Draft changed AFTER the preview was generated (item-2 removed).
      creationItems: new Set(['item-1']),
    })

    const outfit = await useOutfitStore.getState().saveOutfitFromDraft()

    expect(outfit.id).toBe(OUTFIT_ID)
    expect(outfitsApi.createOutfit).toHaveBeenCalledTimes(1)
    expect(outfitsApi.uploadOutfitImage).not.toHaveBeenCalled()
  })

  it('does not upload a preview when the style changed after generation', async () => {
    seedCreationState({
      creationStyle: 'formal' as const,
    })

    await useOutfitStore.getState().saveOutfitFromDraft()

    expect(outfitsApi.uploadOutfitImage).not.toHaveBeenCalled()
  })

  it('uploads the preview when it still matches the draft', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        blob: () => Promise.resolve(new Blob(['x'], { type: 'image/png' })),
      })
    )
    vi.mocked(outfitsApi.uploadOutfitImage).mockResolvedValue({
      success: true,
      data: { id: 'img-1', is_primary: true },
    } as never)
    seedCreationState()

    const outfit = await useOutfitStore.getState().saveOutfitFromDraft()

    expect(outfit.id).toBe(OUTFIT_ID)
    expect(outfitsApi.uploadOutfitImage).toHaveBeenCalledTimes(1)
  })
})

describe('outfitStore preview idempotency key length (F1-07)', () => {
  it('keeps the client_request_id within the backend 64-char limit', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        blob: () => Promise.resolve(new Blob(['x'], { type: 'image/png' })),
      })
    )
    let capturedKey = ''
    vi.mocked(outfitsApi.uploadOutfitImage).mockImplementation(
      async (_id, _file, opts) => {
        capturedKey = opts?.client_request_id ?? ''
        return { success: true, data: { id: 'img-1', is_primary: true } } as never
      }
    )
    seedCreationState()

    await useOutfitStore.getState().saveOutfitFromDraft()

    expect(capturedKey).toBeTruthy()
    // The backend contract is max_length=64 (outfits.py Form(... max_length=64)).
    expect(capturedKey.length).toBeLessThanOrEqual(64)
    expect(capturedKey).toMatch(/^pv-/)
  })
})
