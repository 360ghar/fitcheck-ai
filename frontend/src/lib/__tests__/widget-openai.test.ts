import { describe, expect, it } from 'vitest'

import {
  extractItems,
  extractOutfits,
  firstImageUrl,
} from '../../../../widgets/src/lib/openai'

describe('widget API output normalization', () => {
  it('extracts item lists and outfit lists from standard API envelopes', () => {
    const items = [{ id: 'item-1', name: 'Blue shirt' }]
    const outfits = [{ id: 'outfit-1', name: 'Weekend casual' }]

    expect(extractItems({ data: { items } })).toEqual(items)
    expect(extractOutfits({ data: { outfits } })).toEqual(outfits)
  })

  it('keeps a singular outfit together instead of rendering its clothing as outfits', () => {
    const outfit = {
      id: 'outfit-1',
      name: 'Weekend casual',
      items: [{ id: 'item-1', name: 'Blue shirt' }],
    }

    expect(extractOutfits({ data: outfit })).toEqual([outfit])
    expect(extractOutfits(outfit)).toEqual([outfit])
  })

  it('uses the first image from API image arrays', () => {
    expect(
      firstImageUrl({
        images: [
          { thumbnail_url: 'https://cdn.example.com/thumb.jpg' },
          { image_url: 'https://cdn.example.com/full.jpg' },
        ],
      }),
    ).toBe('https://cdn.example.com/thumb.jpg')
  })
})
